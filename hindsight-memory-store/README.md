# hindsight-memory-store

In-memory event store implementation using STM for testing and development.

## Overview

`hindsight-memory-store` provides a fast, non-durable event store backed by STM (Software Transactional Memory). All data is held in memory and lost when the process terminates.

This backend is ideal for:
- **Unit tests** - Fast, no external dependencies
- **Integration tests** - Full event store semantics without database setup
- **Development** - Quick iteration without persistence overhead
- **CI/CD** - Reliable test runs without database infrastructure

## Features

- **STM transactions** - Atomicity and isolation guarantees
- **Total ordering** - Events delivered in commit order
- **Exactly-once delivery** - Subscription semantics match durable stores
- **Async notifications** - Subscribers notified via STM TVar changes
- **Full API compatibility** - Drop-in replacement for other backends

## Usage

```haskell
import Hindsight
import Hindsight.Store.Memory (newMemoryStore)

example :: IO ()
example = do
  -- Create in-memory store (no configuration needed)
  store <- newMemoryStore

  -- Use like any event store
  streamId <- StreamId <$> UUID.nextRandom
  let event = mkEvent UserRegistered (UserInfo "U001" "Alice")

  result <- insertEvents store Nothing $
    multiEvent streamId Any [event]

  -- Subscribe to events
  handle <- subscribe store
    (match UserRegistered handleEvent :? MatchEnd)
    (EventSelector AllStreams FromBeginning)

  -- Process events...
  threadDelay 100000
  handle.cancel
```

## Implementation Details

### Storage Structure

Events are stored in an STM `TVar` containing:
```haskell
data MemoryStore = MemoryStore
  { events :: TVar (Map StreamId [StoredEvent])
  , subscriptions :: TVar [SubscriptionState]
  , eventCounter :: TVar EventNumber
  }
```

All operations execute within STM transactions, providing atomicity and isolation.

### Ordering Guarantees

Events are assigned sequential `EventNumber` values at commit time. Subscriptions read events in `EventNumber` order, ensuring total ordering across all streams.

```haskell
-- Insert atomically increments counter
atomically $ do
  eventNum <- readTVar store.eventCounter
  writeTVar store.eventCounter (eventNum + 1)
  modifyTVar' store.events (insertEvent streamId event)
```

### Subscription Delivery

Subscriptions track cursor position via `TVar Int`. When new events arrive:
1. Publisher increments `eventCounter`
2. Subscribers detect change via STM `retry`
3. Each subscriber reads events from its cursor position
4. Cursor advances after successful processing

This ensures exactly-once delivery: each event delivered once per subscription, no duplicates, no gaps.

### Concurrency

Multiple concurrent operations are safe:
- Concurrent inserts to different streams: serialized by STM
- Concurrent reads and writes: readers see consistent snapshots
- Multiple subscriptions: each maintains independent cursor

## Trade-offs

**Advantages**:
- ✅ Zero setup - no external dependencies
- ✅ Fast - no I/O, everything in RAM
- ✅ Predictable - no network or disk variability
- ✅ Same semantics as durable stores

**Limitations**:
- ❌ No persistence - data lost on process exit
- ❌ Memory bounded - not suitable for large event volumes
- ❌ Single process - cannot share across processes
- ❌ No history - events not recoverable after restart

## When to Use

**Good for**:
- Testing (unit, integration, property-based)
- Development and prototyping
- Demonstrations and tutorials
- Temporary event processing pipelines

**Not for**:
- Production systems (no durability)
- Long-running processes with large event volumes
- Multi-process deployments
- Systems requiring audit trails

## Testing with Memory Store

Memory store is particularly valuable for testing projections:

```haskell
-- Test projection logic with fast in-memory events
testProjection :: IO ()
testProjection = do
  memStore <- newMemoryStore
  pool <- createPostgreSQLPool testConnectionString

  -- Insert test events quickly
  insertEvents memStore Nothing testEvents

  -- Run projection (uses PostgreSQL for state)
  runProjection projectionId pool Nothing memStore handlers

  -- Verify projection results in database
  results <- query pool "SELECT * FROM user_projections"
  results @?= expectedResults
```

This pattern gives you:
- Fast event insertion (no PostgreSQL insert overhead)
- Real SQL projection logic (actual hasql transactions)
- Reproducible tests (no timing issues from async subscriptions)

See [Backend-Agnostic Code](https://hindsight.events/tutorials/06-backend-agnostic/) tutorial for more patterns.

## Documentation

- **[Getting Started Tutorial](https://hindsight.events/tutorials/01-getting-started/)** - Uses memory store
- **[API Reference](https://hindsight.events/api/Hindsight-Store-Memory.html)** - Module documentation
- **[Testing Guide](https://hindsight.events/development/testing/)** - Testing patterns

## Related Packages

- [`hindsight`](../hindsight/) - Core event system
- [`hindsight-filesystem-store`](../hindsight-filesystem-store/) - Durable single-node storage
- [`hindsight-postgresql-store`](../hindsight-postgresql-store/) - Production PostgreSQL backend
