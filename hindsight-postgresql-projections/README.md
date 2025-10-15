# hindsight-postgresql-projections

Backend-agnostic PostgreSQL projections for building read models.

## Overview

`hindsight-postgresql-projections` provides a projection system for transforming event streams into read models (database views). The key insight: **projections always use PostgreSQL for execution and state management, but can subscribe to events from any backend** (Memory, Filesystem, or PostgreSQL).

This separation enables flexible deployment:
- **Test fast**: Memory store events + PostgreSQL projections
- **Deploy flexibly**: Filesystem or PostgreSQL events, always PostgreSQL projections
- **Validate SQL logic**: Test real projection code against fast in-memory events

## Features

- **Backend-agnostic** - Subscribe to any event store, execute in PostgreSQL
- **Transactional** - Projection handlers run as PostgreSQL transactions
- **Cursor management** - Automatic position tracking for exactly-once delivery
- **Type-safe matching** - Same event pattern matching as subscriptions
- **Error handling** - Failed projections marked inactive with error details
- **Asynchronous by default** - Eventual consistency model
- **Synchronous mode** - Optional strong consistency (PostgreSQL events only)

## Usage

### Basic Async Projection

```haskell
import Hindsight
import Hindsight.Projection
import Hasql.Transaction (Transaction)
import Hasql.Pool (Pool)

-- Projection handler runs in PostgreSQL transaction
userProjection :: EventHandler UserRegistered (Transaction ()) backend
userProjection envelope = do
  let user = envelope.payload

  -- Execute SQL in current transaction
  statement sql (user.userId, user.userName)

  return Continue

-- Run projection (subscribes to events, executes in PostgreSQL)
main :: IO ()
main = do
  store <- newMemoryStore  -- Or any backend!
  pool <- createPool pgSettings 10 1 60

  runProjection
    "user-projection"         -- Projection ID (for cursor tracking)
    pool                       -- PostgreSQL pool
    Nothing                    -- Timeout (Nothing = default)
    store                      -- Event store backend
    (match UserRegistered userProjection :? MatchEnd)
```

### Why Backend-Agnostic?

This architecture enables testing patterns that are impossible with coupled systems:

```haskell
-- Test: fast in-memory events, real SQL projection logic
testProjection :: IO ()
testProjection = do
  memStore <- newMemoryStore
  testPool <- createPool testDBSettings 10 1 60

  -- Insert test events (fast!)
  insertEvents memStore Nothing testEvents

  -- Run real projection with actual SQL
  runProjection projectionId testPool Nothing memStore handlers

  -- Verify results in database
  actual <- query testPool "SELECT * FROM users"
  actual @?= expected
```

You get:
- **Fast test execution** (memory store is 100x faster than PostgreSQL for inserts)
- **Real projection code** (actual SQL transactions, real hasql-transaction)
- **Full validation** (tests the projection logic you'll deploy)

### Multi-Event Projection

Projections can match multiple event types:

```haskell
accountProjection :: Matcher backend (Transaction ())
accountProjection =
  match AccountCreated handleCreated :?
  match MoneyDeposited handleDeposit :?
  match MoneyWithdrawn handleWithdrawal :?
  MatchEnd

handleCreated :: EventHandler AccountCreated (Transaction ()) backend
handleCreated env = do
  statement insertAccount (env.payload.accountId, env.payload.initialBalance)
  return Continue

handleDeposit :: EventHandler MoneyDeposited (Transaction ()) backend
handleDeposit env = do
  statement updateBalance (env.payload.amount, env.payload.accountId)
  return Continue
```

All handlers execute as PostgreSQL transactions. If a handler fails, the transaction rolls back and the projection is marked inactive.

## Implementation Details

### Cursor Tracking

Projection state is stored in the `projections` table:

```sql
CREATE TABLE projections (
    id TEXT PRIMARY KEY,
    head_position JSONB,              -- Cursor: {transaction_no: 42, seq_no: 0}
    last_updated TIMESTAMPTZ NOT NULL,
    is_active BOOLEAN NOT NULL,
    error_message TEXT
);
```

After successfully processing an event:
1. Handler transaction commits (event processing complete)
2. Cursor updates to next position
3. If failure: projection marked inactive, error recorded

### Exactly-Once Delivery

The cursor ensures each event processes exactly once:

```
Initial cursor: (tx=10, seq=0)

Fetch events WHERE (transaction_no, seq_no) > (10, 0)
→ Returns: [(10, 1), (11, 0), (11, 1), ...]

Process (10, 1): ✓ Success → cursor = (10, 1)
Process (11, 0): ✓ Success → cursor = (11, 0)
Process (11, 1): ✗ Failure → cursor stays (11, 0), projection inactive

On restart:
Fetch events WHERE (transaction_no, seq_no) > (11, 0)
→ Returns: [(11, 1), ...] (retry failed event)
```

No duplicates, no gaps.

### Transaction Scope

Each event handler execution is a separate PostgreSQL transaction:

```haskell
-- Pseudocode showing transaction boundaries
forever $ do
  events <- fetchNewEvents cursor
  for event in events:
    result <- runTransaction pool $ do
      -- Handler runs here
      userHandler event

    case result of
      Success -> updateCursor (nextPosition event)
      Failure err -> markInactive err
```

This means:
- Each event processes atomically
- Failure doesn't affect previous events
- Handlers can use full PostgreSQL transactional semantics

## Synchronous Projections

When using PostgreSQL for both events AND projections, you can use synchronous mode:

```haskell
-- In application code
result <- insertEventsSync postgresStore projectionId events

-- This blocks until projection has processed these events
-- Provides strong consistency (read-your-writes)
```

Implementation:
1. Insert events in transaction
2. Caller waits on projection notification channel
3. Projection processes events, updates cursor
4. Cursor update triggers LISTEN/NOTIFY
5. Caller receives notification, returns

Use cases:
- User creates account → immediately redirect to account page (needs projection updated)
- Command validation requires projection state (inventory check before order)
- Cross-aggregate invariants (account balance check before transfer)

See [Multi-Stream Consistency](https://hindsight.events/tutorials/08-multi-stream-consistency/) for patterns.

## Running Multiple Projections

Each projection runs independently:

```haskell
main :: IO ()
main = do
  store <- newPostgreSQLStore pool

  -- Spawn multiple projections concurrently
  async $ runProjection "user-projection" pool Nothing store userHandlers
  async $ runProjection "order-projection" pool Nothing store orderHandlers
  async $ runProjection "inventory-projection" pool Nothing store inventoryHandlers

  -- Each maintains independent cursor
  -- Each can fail/restart independently
```

Projections share the event stream but maintain separate cursors. One projection's failure doesn't affect others.

## Error Handling

When a handler fails, the projection stops:

```haskell
handleEvent :: EventHandler UserCreated (Transaction ()) backend
handleEvent env = do
  result <- statement insertUser (env.payload.userId, env.payload.userName)
  case result of
    Just err -> throwIO (ProjectionError err)  -- Marks projection inactive
    Nothing -> return Continue
```

The `projections` table records the error:

```sql
SELECT id, is_active, error_message, error_timestamp
FROM projections
WHERE is_active = false;

-- id                 | is_active | error_message                     | error_timestamp
-- -------------------+-----------+-----------------------------------+-----------------
-- user-projection    | false     | "duplicate key value violates..." | 2025-10-15 18:30
```

To restart:
1. Fix the underlying issue (e.g., remove duplicate row)
2. Mark projection active: `UPDATE projections SET is_active = true, error_message = NULL WHERE id = 'user-projection'`
3. Projection resumes from last successful cursor

## Deployment Patterns

### Pattern 1: Test with Memory, Deploy with PostgreSQL

```haskell
-- Test environment
testConfig = do
  store <- newMemoryStore
  pool <- createPool testDBSettings 10 1 60
  runProjection projId pool Nothing store handlers

-- Production environment
prodConfig = do
  store <- newPostgreSQLStore prodPool
  pool <- prodPool  -- Same pool for events and projections
  runProjection projId pool Nothing store handlers
```

Same projection code, different backends.

### Pattern 2: Filesystem Events, PostgreSQL Projections

```haskell
-- Single-node deployment without database for events
config = do
  store <- newFilesystemStore "/var/lib/app/events"
  pool <- createPool pgSettings 10 1 60
  runProjection projId pool Nothing store handlers
```

Simple event storage, powerful projection queries.

### Pattern 3: All PostgreSQL

```haskell
-- Full PostgreSQL deployment
config = do
  pool <- createPool pgSettings 10 1 60
  store <- newPostgreSQLStore pool
  runProjection projId pool Nothing store handlers
```

Full ACID, scalable, operational maturity.

## API Reference

### Core Functions

```haskell
-- Run async projection
runProjection
  :: EventStore backend
  => Text                          -- Projection ID
  -> Pool                          -- PostgreSQL pool
  -> Maybe Duration                -- Timeout
  -> BackendHandle backend         -- Event source
  -> Matcher backend (Transaction ()) -- Event handlers
  -> IO ()

-- Check projection status
getProjectionState
  :: Pool
  -> Text                          -- Projection ID
  -> IO (Maybe ProjectionState)

-- Manually update cursor (advanced)
updateProjectionCursor
  :: Pool
  -> Text
  -> Position
  -> IO ()
```

## Trade-offs

**Advantages**:
- ✅ Backend flexibility - test fast, deploy anywhere
- ✅ Transactional guarantees - ACID for projection updates
- ✅ Cursor management - automatic exactly-once delivery
- ✅ SQL power - full PostgreSQL query capabilities
- ✅ Independent scaling - projections separate from event store

**Limitations**:
- ❌ PostgreSQL required - even with memory/filesystem events
- ❌ Per-event transactions - not ideal for very high throughput (batch instead)
- ❌ Eventual consistency default - sync mode only with PostgreSQL events

## Documentation

- **[In-Memory Projections Tutorial](https://hindsight.events/tutorials/02-in-memory-projections/)** - Basic concepts
- **[PostgreSQL Projections Tutorial](https://hindsight.events/tutorials/03-postgresql-projections/)** - Durable projections
- **[Advanced PostgreSQL](https://hindsight.events/tutorials/07-advanced-postgresql/)** - Performance patterns
- **[Multi-Stream Consistency](https://hindsight.events/tutorials/08-multi-stream-consistency/)** - Cross-aggregate patterns
- **[API Reference](https://hindsight.events/api/Hindsight-Projection.html)** - Module docs

## Related Packages

- [`hindsight`](../hindsight/) - Core event system
- [`hindsight-memory-store`](../hindsight-memory-store/) - Fast test backend
- [`hindsight-filesystem-store`](../hindsight-filesystem-store/) - Durable single-node storage
- [`hindsight-postgresql-store`](../hindsight-postgresql-store/) - Production event store
