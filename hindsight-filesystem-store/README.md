# hindsight-filesystem-store

File-based persistent event store for single-node deployments.

## Overview

`hindsight-filesystem-store` provides durable event storage using the filesystem. Events are written to JSON files with file-based locking for multi-process coordination. Changes are detected via filesystem watches (`fsnotify`), enabling low-latency subscriptions without polling.

This backend is ideal for:
- **Single-node deployments** - No database required
- **Edge computing** - Embedded systems or constrained environments
- **Development** - Persistent storage without PostgreSQL setup
- **Small-scale deployments** - Systems that don't need horizontal scaling

## Features

- **Durable persistence** - Events survive process restarts
- **Multi-process support** - Safe concurrent access via `flock`
- **Total ordering** - Sequential event numbering across all streams
- **Exactly-once delivery** - Subscription cursor tracking
- **Watch-based notifications** - Low-latency via `fsnotify`
- **Human-readable storage** - Events stored as JSON files

## Usage

```haskell
import Hindsight
import Hindsight.Store.Filesystem (newFilesystemStore)

example :: IO ()
example = do
  -- Create filesystem store (specify directory)
  store <- newFilesystemStore "/var/lib/myapp/events"

  -- Use like any event store
  streamId <- StreamId <$> UUID.nextRandom
  let event = mkEvent UserRegistered (UserInfo "U001" "Alice")

  result <- insertEvents store Nothing $
    multiEvent streamId Any [event]

  -- Subscribe to events (will catch up from disk, then watch for new events)
  handle <- subscribe store
    (match UserRegistered handleEvent :? MatchEnd)
    (EventSelector AllStreams FromBeginning)

  -- Subscription continues across restarts
  -- (cursor position persisted to disk)
```

## Storage Structure

Events are stored in a structured directory hierarchy:

```
/var/lib/myapp/events/
├── streams/
│   ├── <stream-id-1>/
│   │   ├── 0000000001.json  # Event 1
│   │   ├── 0000000002.json  # Event 2
│   │   └── ...
│   └── <stream-id-2>/
│       └── ...
├── global_index.json         # Global event ordering
├── subscriptions/
│   ├── <subscription-id-1>.json  # Cursor position
│   └── <subscription-id-2>.json
└── .lock                     # Process-level lock file
```

Each event file contains:
```json
{
  "event_name": "user_registered",
  "version": 0,
  "timestamp": "2025-10-15T18:30:00Z",
  "stream_id": "550e8400-e29b-41d4-a716-446655440000",
  "event_number": 42,
  "payload": {
    "userId": "U001",
    "userName": "Alice"
  }
}
```

## Implementation Details

### Locking Strategy

The store uses advisory file locks (`flock`) to coordinate multi-process access:

- **Shared locks** for reads (subscriptions)
- **Exclusive locks** for writes (event insertions)
- **Timeout-based** deadlock prevention

Locks are held only during I/O operations, not across entire transactions.

### Ordering Guarantees

Events receive sequential `EventNumber` values written to `global_index.json`. The index maps event numbers to `(stream_id, sequence)` pairs:

```json
{
  "1": {"stream": "uuid-1", "sequence": 0},
  "2": {"stream": "uuid-2", "sequence": 0},
  "3": {"stream": "uuid-1", "sequence": 1}
}
```

Subscriptions read from this index, ensuring total ordering across all streams.

### Change Detection

The store uses `fsnotify` to watch for:
- New event files in `streams/`
- Changes to `global_index.json`
- New entries in stream directories

When changes occur, subscriptions wake up and read new events. This provides low-latency notification without polling (typically <100ms from write to delivery).

### Subscription Resumption

Cursor positions are persisted in `subscriptions/<id>.json`:

```json
{
  "subscription_id": "my-projection",
  "cursor": 42,
  "last_updated": "2025-10-15T18:30:00Z"
}
```

On restart, subscriptions resume from the saved cursor, ensuring exactly-once delivery.

## Trade-offs

**Advantages**:
- ✅ No database required - just filesystem
- ✅ Durable - events persist across restarts
- ✅ Human-readable - JSON files inspectable with text tools
- ✅ Simple operations - backup with `rsync`, restore with `cp`
- ✅ Multi-process safe - `flock` coordination

**Limitations**:
- ❌ Single-node only - no horizontal scaling
- ❌ File I/O overhead - slower than in-memory or PostgreSQL
- ❌ Limited concurrent writers - lock contention possible
- ❌ No SQL queries - events accessible only via streams
- ❌ Filesystem dependent - performance varies by FS type

## Performance Characteristics

**Write throughput**: ~1,000-5,000 events/sec (depends on disk speed)
- Sequential writes to stream files
- Fsync on commit for durability
- Lock contention limits concurrent writers

**Read throughput**: ~10,000-50,000 events/sec
- Shared locks allow concurrent readers
- OS page cache helps repeated reads
- Watch-based updates avoid polling overhead

**Latency**:
- Write latency: 1-10ms (fsync dominant)
- Notification latency: <100ms (fsnotify detection)
- Subscription catchup: fast (sequential reads)

## When to Use

**Good for**:
- Single-node applications with durability requirements
- Edge deployments where PostgreSQL isn't available
- Development environments requiring persistence
- Systems with moderate event volumes (<millions of events)
- Deployments where operational simplicity matters

**Not for**:
- High-throughput systems (>10K events/sec)
- Horizontally scaled applications
- Systems requiring SQL-based event queries
- Use cases needing strong multi-process transactional semantics

## Migration Path

Filesystem store is a good intermediate step:

1. **Development**: Start with memory store (fast tests)
2. **Local deployment**: Upgrade to filesystem store (durability)
3. **Larger deployments**: Migrate to PostgreSQL store (scalability)

Code remains identical—just swap the backend handle.

## Operations

**Backup**:
```bash
# Stop application or ensure no writes
rsync -av /var/lib/myapp/events/ /backup/events-$(date +%Y%m%d)/
```

**Restore**:
```bash
rsync -av /backup/events-20251015/ /var/lib/myapp/events/
```

**Inspect events**:
```bash
# Find specific event
grep -r "UserRegistered" /var/lib/myapp/events/streams/

# Count events in stream
ls /var/lib/myapp/events/streams/<stream-id>/ | wc -l

# View event
cat /var/lib/myapp/events/streams/<stream-id>/0000000042.json | jq .
```

**Compaction**: Not currently supported. Events accumulate indefinitely. Plan for this in storage capacity.

## Documentation

- **[Getting Started Tutorial](https://hindsight.events/tutorials/01-getting-started/)** - Basics
- **[Backend-Agnostic Code](https://hindsight.events/tutorials/06-backend-agnostic/)** - Switching backends
- **[API Reference](https://hindsight.events/api/Hindsight-Store-Filesystem.html)** - Module docs

## Related Packages

- [`hindsight`](../hindsight/) - Core event system
- [`hindsight-memory-store`](../hindsight-memory-store/) - Fast non-durable storage
- [`hindsight-postgresql-store`](../hindsight-postgresql-store/) - Scalable PostgreSQL backend
