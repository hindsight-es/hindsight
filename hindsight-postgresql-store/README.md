# hindsight-postgresql-store

PostgreSQL event store with ACID guarantees and horizontal scalability.

## Overview

Provides durable, scalable event storage backed by PostgreSQL. Features full ACID guarantees, global total ordering via compound keys, optimistic locking with stream versions, and low-latency subscriptions using LISTEN/NOTIFY.

## Schema Overview

The store uses a carefully designed schema for correctness and performance:

**event_transactions** - Transaction sequence for global ordering
**events** - Event storage with compound key `(transaction_no, seq_no)` for total ordering
**stream_heads** - Stream metadata and version tracking
**projections** - Subscription cursor positions (exactly-once delivery)

Events receive sequential `(transaction_no, seq_no)` pairs. Subscriptions read in this order, ensuring if event A was committed before event B, subscribers see A before B across all streams.

## Quick Start

```haskell
import Hindsight
import Hindsight.Store.PostgreSQL (newPostgreSQLStore)
import Hindsight.Store.PostgreSQL.Core.Schema (createSchema)
import Hasql.Connection (settings)

main :: IO ()
main = do
  let connSettings = settings "localhost" 5432 "user" "pass" "eventstore"
  pool <- createPool connSettings 10 1 60

  -- Initialize schema
  run pool createSchema

  -- Create store
  store <- newPostgreSQLStore pool

  -- Insert events
  streamId <- StreamId <$> UUID.nextRandom
  let event = mkEvent UserRegistered (UserInfo "U001" "Alice")

  result <- insertEvents store Nothing $
    multiEvent streamId Any [event]

  -- Subscribe to events
  handle <- subscribe store
    (match UserRegistered handleEvent :? MatchEnd)
    (EventSelector AllStreams FromBeginning)
```

## Documentation

- [Introduction](https://hindsight.events/introduction.html)
- [Getting Started](https://hindsight.events/tutorials/01-getting-started.html)
- [PostgreSQL Projections](https://hindsight.events/tutorials/03-postgresql-projections.html)
- [Advanced PostgreSQL](https://hindsight.events/tutorials/07-advanced-postgresql.html)
- [API Reference](https://hindsight.events/haddock/hindsight-postgresql-store/)

## License

BSD-3-Clause. See [LICENSE](../LICENSE) for details.
