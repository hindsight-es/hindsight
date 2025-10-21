# Hindsight

Type-safe event sourcing for Haskell with strong compile-time guarantees.

## What is Hindsight?

Hindsight is an event sourcing library for Haskell that makes schema evolution a compile-time concern. Event versioning leverages the type system to provide strong safety guarantees, and the testing toolkit generates roundtrip and golden tests automatically to ensure you never accidentally break compatibility with stored events.

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

  let event = mkEvent UserRegistered (UserInfo "U001" "Alice")
  result <- insertEvents store Nothing $
    multiEvent streamId Any [event]

  handle <- subscribe store
    (match UserRegistered handleEvent :? MatchEnd)
    (EventSelector AllStreams FromBeginning)

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

- [Introduction](https://hindsight.events/introduction.html) - Why event sourcing? Why type-safe versioning?
- [Tutorials](https://hindsight.events/tutorials/) - Hands-on learning from basics to advanced patterns
- [API Reference](https://hindsight.events/api/) - Complete Haddock documentation
- [Development Guide](https://hindsight.events/development/building.html) - Building and contributing

## License

BSD-3-Clause. See [LICENSE](LICENSE) for details.
