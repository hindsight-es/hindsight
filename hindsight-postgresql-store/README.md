# hindsight-postgresql-store

PostgreSQL event store with ACID guarantees and scalability.

## Overview

`hindsight-postgresql-store` provides a robust, scalable event store backed by PostgreSQL. It offers full ACID guarantees, global total ordering, and efficient subscriptions via LISTEN/NOTIFY.

Features:
- **Full ACID guarantees** - Atomicity, consistency, isolation, durability
- **Global total ordering** - Compound keys `(transaction_no, seq_no)` for deterministic event sequence
- **Causal consistency** - Transaction-level ordering preserves causality
- **Optimistic locking** - Stream version expectations prevent conflicts
- **Multi-stream transactions** - Atomic inserts across streams
- **Low-latency subscriptions** - LISTEN/NOTIFY for sub-millisecond notification
- **Horizontal scalability** - Multiple app servers, single PostgreSQL (or replicas for reads)

## Usage

```haskell
import Hindsight
import Hindsight.Store.PostgreSQL (newPostgreSQLStore)
import Hasql.Connection (settings)

example :: IO ()
example = do
  -- Create connection pool
  let connSettings = settings "localhost" 5432 "myuser" "mypass" "eventstore"
  pool <- createPool connSettings 10 1 60

  -- Create store
  store <- newPostgreSQLStore pool

  -- Use like any event store
  streamId <- StreamId <$> UUID.nextRandom
  let event = mkEvent UserRegistered (UserInfo "U001" "Alice")

  result <- insertEvents store Nothing $
    multiEvent streamId Any [event]

  -- Subscribe to events (resumes from cursor on restart)
  handle <- subscribe store
    (match UserRegistered handleEvent :? MatchEnd)
    (EventSelector AllStreams FromBeginning)
```

## Schema Overview

The PostgreSQL backend uses a carefully designed schema for correctness and performance:

### Core Tables

**`event_transactions`** - Transaction sequence
```sql
CREATE TABLE event_transactions (
    transaction_no BIGINT PRIMARY KEY DEFAULT nextval('transaction_seq')
);
```
Each insert allocates a transaction number. This provides global ordering.

**`events`** - Event storage
```sql
CREATE TABLE events (
    transaction_no BIGINT NOT NULL,
    seq_no INT NOT NULL,
    event_id UUID NOT NULL PRIMARY KEY,
    stream_id UUID NOT NULL,
    event_name TEXT NOT NULL,
    event_version INT NOT NULL,
    payload JSONB NOT NULL,
    stream_version BIGINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ...
);
```
Compound key `(transaction_no, seq_no)` provides total ordering. Multiple events in the same transaction get sequential `seq_no` values (0, 1, 2, ...).

**`stream_heads`** - Stream metadata
```sql
CREATE TABLE stream_heads (
    stream_id UUID PRIMARY KEY,
    latest_transaction_no BIGINT NOT NULL,
    latest_seq_no INT NOT NULL,
    stream_version BIGINT NOT NULL,
    ...
);
```
Tracks the latest position and version for each stream. Used for version expectations and conflict detection.

**`projections`** - Subscription cursors
```sql
CREATE TABLE projections (
    id TEXT PRIMARY KEY,
    head_position JSONB,
    last_updated TIMESTAMPTZ NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true
);
```
Stores cursor positions for subscriptions, enabling exactly-once delivery across restarts.

## Ordering Guarantees

### Global Total Ordering

Events receive `(transaction_no, seq_no)` compound keys:

```
Transaction 1: events[(1, 0), (1, 1)]        # Two events, same transaction
Transaction 2: events[(2, 0)]                 # One event
Transaction 3: events[(3, 0), (3, 1), (3, 2)] # Three events
```

Subscriptions read in `(transaction_no, seq_no)` order. If event A was committed before event B, subscribers see A before B. This holds **across all streams**.

### Causal Consistency

Events inserted in the same transaction are causally related and maintain their ordering:

```haskell
-- These events will appear consecutively in global order
result <- insertEvents store Nothing $
  Map.fromList
    [ (streamA, StreamWrite Any [eventA1, eventA2])
    , (streamB, StreamWrite Any [eventB1])
    ]
-- Global order: (tx, 0)=eventA1, (tx, 1)=eventA2, (tx, 2)=eventB1
```

This is critical for maintaining invariants across aggregates.

### Stream Versioning

Each stream has a `stream_version` that increments with each event. Version expectations enable optimistic locking:

```haskell
-- Expect stream to be at version 5
result <- insertEvents store Nothing $
  multiEvent streamId (ExpectedVersion 5) [event]

case result of
  SuccessfulInsertion _ -> ...  -- Success: stream was at version 5
  ConflictingVersion actual -> ...  -- Conflict: stream is at different version
```

## Subscription Implementation

### LISTEN/NOTIFY

When a transaction commits, a trigger fires:

```sql
CREATE TRIGGER transaction_notify
    AFTER INSERT ON event_transactions
    FOR EACH ROW
    EXECUTE PROCEDURE notify_transaction();
```

This sends a notification on the `event_store_transaction` channel. Subscribers listening on this channel wake up immediately (<1ms latency) and fetch new events.

### Cursor Tracking

Subscriptions store their cursor in the `projections` table:

```json
{
  "transaction_no": 42,
  "seq_no": 0
}
```

On restart, the subscription resumes from this position. The cursor updates after successful event processing, ensuring exactly-once delivery.

### MVCC-Safe Catchup

When catching up from a cursor, the subscription uses `get_safe_transaction_number_mvcc()` to find the highest transaction number that's visible to all readers:

```sql
SELECT * FROM events
WHERE (transaction_no, seq_no) > (cursor_tx, cursor_seq)
  AND transaction_no <= get_safe_transaction_number_mvcc()
ORDER BY transaction_no, seq_no
```

This prevents reading uncommitted transactions during concurrent writes.

## Synchronous Projections

PostgreSQL store uniquely supports synchronous projections via `insertEventsSync`:

```haskell
result <- insertEventsSync store projectionId $
  multiEvent streamId Any [event]
```

This blocks until the specified projection has processed the inserted events. The insert and projection update execute in **separate transactions** but the caller waits for both to complete.

Use cases:
- Strong consistency requirements (read-your-writes)
- Cross-aggregate validation before confirming writes
- Systems where eventual consistency isn't acceptable

See [Advanced PostgreSQL](https://hindsight.events/tutorials/07-advanced-postgresql/) for patterns.

## Performance Characteristics

**Write throughput**: ~10,000-100,000 events/sec
- Depends on transaction size, hardware, PostgreSQL tuning
- Batching multiple events per transaction increases throughput
- Network RTT dominant for small transactions

**Read throughput**: ~100,000+ events/sec
- Index-based sequential scans are very fast
- Shared reads allow many concurrent subscriptions
- Hot data cached by PostgreSQL

**Latency**:
- Insert latency: 1-10ms (network + commit)
- Notification latency: <1ms (LISTEN/NOTIFY)
- Subscription delivery: ~2-5ms end-to-end

**Scalability**:
- Vertical: single PostgreSQL instance to 100K+ events/sec
- Horizontal: multiple app servers, single write DB
- Read replicas: route subscriptions to replicas (with replication lag)

## Operations

### Schema Setup

The schema is embedded in the library. Initialize with:

```haskell
import Hindsight.Store.PostgreSQL.Core.Schema (initializeSchema)

main = do
  pool <- createPool connSettings 10 1 60
  initializeSchema pool
```

Or apply manually:
```bash
psql -d eventstore < sql/sql-store-schema.sql
```

### Monitoring

Key metrics to monitor:

- **Transaction sequence**: `SELECT last_value FROM transaction_seq;`
- **Event count**: `SELECT COUNT(*) FROM events;`
- **Stream count**: `SELECT COUNT(*) FROM stream_heads;`
- **Active subscriptions**: `SELECT COUNT(*) FROM projections WHERE is_active = true;`
- **Subscription lag**: Compare cursor `transaction_no` to max `transaction_no`

### Backup

```bash
# Full backup (includes all events, projections, metadata)
pg_dump eventstore > backup.sql

# Continuous archiving with WAL
# See PostgreSQL documentation for PITR setup
```

### Maintenance

**Vacuum**: Events table can grow large. Regular VACUUM recommended:
```sql
VACUUM ANALYZE events;
```

**Index maintenance**: Rebuild indexes if performance degrades:
```sql
REINDEX TABLE events;
```

**Event archival**: Not currently supported. Plan for unbounded growth or implement custom archival.

## Configuration

Connection pooling is critical for performance:

```haskell
import Hasql.Pool (Pool, acquire, use)

-- Create pool (size = concurrent connections)
pool <- acquire 10 1800 connSettings

-- Pool automatically manages connection lifecycle
result <- use pool $ statement sql params
```

Recommended pool sizing:
- Development: 1-5 connections
- Production: 10-50 connections (depends on concurrency)
- Subscriptions: 1 connection per long-running subscription

## Trade-offs

**Advantages**:
- ✅ Full ACID - no data loss, consistent views
- ✅ Proven technology - PostgreSQL is battle-tested
- ✅ SQL power - custom queries, reporting, debugging
- ✅ Operational maturity - monitoring, backup, replication
- ✅ Horizontal read scaling - replicas for subscriptions

**Limitations**:
- ❌ PostgreSQL dependency - adds operational complexity vs filesystem
- ❌ Network overhead - slower than in-memory for tests
- ❌ Write scaling limit - single-node write bottleneck (though high)
- ❌ Storage cost - JSONB payloads consume space

## When to Use

**Use PostgreSQL store for**:
- Systems requiring durable storage and horizontal scaling
- Applications needing horizontal scaling
- Systems with strong consistency requirements
- Deployments where PostgreSQL expertise is available
- Event volumes from thousands to billions of events

**Consider alternatives if**:
- You're writing tests (use memory store)
- Single-node deployment without scaling needs (filesystem store works)
- You need higher write throughput than ~100K events/sec (consider EventStoreDB)

## Documentation

- **[Introduction](https://hindsight.events/introduction/)** - Event sourcing fundamentals
- **[Getting Started](https://hindsight.events/tutorials/01-getting-started/)** - Basic usage
- **[PostgreSQL Projections](https://hindsight.events/tutorials/03-postgresql-projections/)** - Building read models
- **[Advanced PostgreSQL](https://hindsight.events/tutorials/07-advanced-postgresql/)** - Performance patterns
- **[API Reference](https://hindsight.events/api/Hindsight-Store-PostgreSQL.html)** - Module docs

## Related Packages

- [`hindsight`](../hindsight/) - Core event system
- [`hindsight-memory-store`](../hindsight-memory-store/) - Fast testing backend
- [`hindsight-filesystem-store`](../hindsight-filesystem-store/) - File-based storage
- [`hindsight-postgresql-projections`](../hindsight-postgresql-projections/) - Projection system
