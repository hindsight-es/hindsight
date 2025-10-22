# Hindsight

Type-safe event sourcing for Haskell with strong compile-time guarantees.

## What is Hindsight?

Hindsight is an opinionated event sourcing library for Haskell. A defining feature of Hindsight is to
make event versioning a compile-time concern, by separating the definition of an event (identifed by a typelevel `Symbol`)
from that of its successive payloads. By default, migrations are handled automatically through upcasting of successive versions
(but you can opt-out of that mechanism when you see fit).

The **testing toolkit** generates roundtrip and golden tests automatically to ensure you never accidentally break compatibility with stored events.

Moreover, Hindsight defines an event store interface featuring:

- Multi-stream event transactions with fine-grained version expectations à la KurrentDB
- Real-time, multi-stream subscriptions with exactly-once delivery semantics
- Strong (total) event ordering guarantees

These primitives allow you to implement arbitrary optimistic-concurrency control mechanisms, as well as common event
sourcing patterns (sagas, process managers, etc.)

Three store implementations are provided:

- An *in-memory* implementation for quick testing and prototyping ;
- A *filesystem* store that persists your events to your disk ;
- A scalable *PostgreSQL* implementation. 

Finally, a PostgreSQL-based (but store-agnostic) projection system is provided. As a store-specific feature, the PostgreSQL
store supports synchronous projections (called _inline projections_ in Marten DB). Synchronous projections are particularly
useful to:

- Eschew the pains of eventual consistency ;
- Implement PostgreSQL-backed validations.

## Quick Example

Define an event with type-level versioning:

```haskell
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE TypeFamilies #-}

import Data.Aeson (FromJSON, ToJSON)
import Data.Text (Text)
import GHC.Generics (Generic)
import Hindsight
import Hindsight.Store.Memory (newMemoryStore)

-- Event name at the type level
type UserRegistered = "user_registered"

-- Event payload
data UserInfo = UserInfo
  { userId :: Text
  , userName :: Text
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)

-- Version declaration (version 0)
type instance MaxVersion UserRegistered = 0
type instance Versions UserRegistered = '[UserInfo]
instance Event UserRegistered
instance MigrateVersion 0 UserRegistered
```

Store and retrieve events:

```haskell
import Data.UUID.V4 qualified as UUID

example :: IO ()
example = do
  store <- newMemoryStore
  streamId <- StreamId <$> UUID.nextRandom

  let event = mkEvent "user_registered" (UserInfo "U001" "Alice")
  result <- insertEvents store Nothing $
    singleEvent streamId Any [event]

  handle <- subscribe store
    (match "user_registered" handleEvent :? MatchEnd)
    (EventSelector AllStreams FromBeginning)
  
  ...

  where
    handleEvent envelope = do
      print envelope.payload.userName
      return Continue
```

## Features

**Event Stores**: Stream-based event storage with exactly-once delivery and total ordering
- **[hindsight-memory-store](hindsight-memory-store/)** - In-memory (testing)
- **[hindsight-filesystem-store](hindsight-filesystem-store/)** - File-based (single-node)
- **[hindsight-postgresql-store](hindsight-postgresql-store/)** - PostgreSQL (production)

**Projections**: SQL-based read models
- **[hindsight-postgresql-projections](hindsight-postgresql-projections/)** - Backend-agnostic PostgreSQL projections

**Type-Safe Versioning**: Compile-time event schema evolution with automatic migration composition

**Consistency**: Optimistic locking, multi-stream transactions, synchronous projections

## Documentation

- [Index](https://hindsight.events/docs/) - Documentation entry point
- [Tutorials](https://hindsight.events/docs/tutorials/) - Hands-on learning from basics to advanced patterns
- [API Reference](https://hindsight.events/docs/api/) - Complete Haddock documentation
- [Development Guide](https://hindsight.events/docs/development/building.html) - Building and contributing

## License

BSD-3-Clause. See [LICENSE](LICENSE) for details.
