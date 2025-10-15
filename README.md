# Hindsight

Type-safe event sourcing for Haskell with compile-time versioning guarantees.

## What is Hindsight?

Hindsight is an event sourcing library that uses Haskell's type system to manage event schema evolution. When you modify an event's structure, old events in your store remain in their original format forever. Hindsight brings versioning into the type system: GHC tracks all versions at compile time, automatically upcasts old events, and catches missing upgrade paths as type errors.

The result is event sourcing where schema evolution is checked by the compiler, not discovered at runtime.

## Core Guarantees

- **Compile-time version tracking** - GHC knows about all versions of every event
- **Automatic upcasting** - Old events transparently upgrade to latest version
- **Type-safe handlers** - Event handlers always receive the current schema
- **Exhaustiveness checking** - Missing upgrade paths are compile errors
- **Multiple storage backends** - Memory, Filesystem, and PostgreSQL implementations
- **Backend-agnostic projections** - Build read models using PostgreSQL, subscribe to events from any store

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
type instance Versions UserRegistered = FirstVersion UserInfo
instance Event UserRegistered
instance UpgradableToLatest UserRegistered 0 where
  upgradeToLatest = id
```

Store and retrieve events:

```haskell
import Data.UUID.V4 qualified as UUID

example :: IO ()
example = do
  -- Create a store
  store <- newMemoryStore

  -- Generate stream ID
  streamId <- StreamId <$> UUID.nextRandom

  -- Insert events
  let event = mkEvent UserRegistered (UserInfo "U001" "Alice")
  result <- insertEvents store Nothing $
    multiEvent streamId Any [event]

  -- Subscribe to events
  handle <- subscribe store
    (match UserRegistered handleEvent :? MatchEnd)
    (EventSelector AllStreams FromBeginning)

  where
    handleEvent envelope = do
      print envelope.payload.userName
      return Continue
```

When you need to evolve the schema, add a new version and provide an upgrade function. GHC ensures you handle all upgrade paths:

```haskell
-- Add version 1 with additional field
data UserInfoV1 = UserInfoV1
  { userId :: Text
  , userName :: Text
  , email :: Text  -- new field
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)

type instance MaxVersion UserRegistered = 1
type instance Versions UserRegistered =
  FirstVersion UserInfo :> UserInfoV1

-- Upgrade function from v0 to v1
instance UpgradableToLatest UserRegistered 0 where
  upgradeToLatest (UserInfo uid name) =
    UserInfoV1 uid name "unknown@example.com"

instance UpgradableToLatest UserRegistered 1 where
  upgradeToLatest = id
```

## Storage Backends

- **[hindsight-memory-store](hindsight-memory-store/)** - STM-based in-memory storage for testing
- **[hindsight-filesystem-store](hindsight-filesystem-store/)** - File-based persistence for single-node deployments
- **[hindsight-postgresql-store](hindsight-postgresql-store/)** - Production PostgreSQL backend with ACID guarantees

All backends implement the same `EventStore` interface.

## Projections

**[hindsight-postgresql-projections](hindsight-postgresql-projections/)** provides a projection system for building read models. Projections execute in PostgreSQL transactions but can subscribe to events from any backend:

```haskell
-- Test with in-memory events, real SQL projections
runProjection projectionId pool Nothing memoryStore handlers

-- Production with PostgreSQL events
runProjection projectionId pool Nothing postgresqlStore handlers
```

This enables fast testing with realistic projection logic.

## Testing Support

Hindsight includes facilities for generating serialization tests, critical for ensuring you never accidentally break compatibility with stored events:

```haskell
-- Golden tests: verify serialization format never changes
import Test.Hindsight.Generate (goldenTest)

-- Automatically generates JSON snapshots for all event versions
goldenTest :: Event eventName => Proxy eventName -> FilePath -> TestTree

-- Roundtrip tests: serialize → deserialize → verify equality
import Test.Tasty.QuickCheck (testProperty)

testProperty "UserRegistered roundtrips" $ \userInfo ->
  let event = mkEvent UserRegistered userInfo
      json = encode event
  in decode json === Just event
```

These tests prevent breaking changes to event serialization—the most dangerous kind of bug in an event-sourced system. If you modify an event's JSON format by accident, these tests fail.

## Store Guarantees

All backends provide **total ordering** of events and **exactly-once delivery** for subscriptions. Different backends offer different durability and consistency guarantees:

**Memory Store**:
- Atomicity and isolation via STM transactions
- Total ordering within the process
- Exactly-once delivery for subscriptions
- No durability (data lost on process termination)
- Use case: fast testing, development

**Filesystem Store**:
- Durable writes with file-based locking
- Multi-process support via `flock`
- Total ordering per store instance
- Exactly-once delivery for subscriptions
- Watch-based notifications via `fsnotify`
- Use case: single-node deployments without database

**PostgreSQL Store**:
- Full ACID guarantees (atomicity, consistency, isolation, durability)
- Global total ordering via compound keys `(transaction_no, seq_no)`
- Causal consistency across all events
- Exactly-once delivery for subscriptions via cursor tracking
- LISTEN/NOTIFY for low-latency notifications
- Use case: production systems requiring durability and scalability

**Ordering Guarantee**: Events are delivered to subscriptions in the order they were committed. If event A was inserted before event B, subscribers will see A before B. This holds across all streams (global ordering).

**Delivery Guarantee**: Each event is delivered exactly once to each subscription. Hindsight tracks cursor positions to ensure no duplicates and no missed events, even across restarts (for durable stores).

For details on ordering guarantees and concurrency control, see the [PostgreSQL Store documentation](https://hindsight.events/stores/postgresql/).

## Consistency Facilities

Hindsight provides several mechanisms for managing consistency:

**Optimistic Locking**:
```haskell
-- Require stream to be at specific version
insertEvents store Nothing $
  multiEvent streamId (ExpectedVersion 5) [event]
-- Fails with ConflictingVersion if stream is not at version 5
```

**Multi-Stream Transactions**:
```haskell
-- Insert to multiple streams atomically (PostgreSQL only)
insertEvents store Nothing $
  Map.fromList
    [ (streamA, StreamWrite Any [eventA])
    , (streamB, StreamWrite Any [eventB])
    ]
-- Both streams updated or neither - atomic transaction
```

**Synchronous Projections**:
```haskell
-- Event insertion waits for projection to complete (PostgreSQL only)
result <- insertEventsSync store projectionId $
  multiEvent streamId Any [event]
-- Strong consistency: projection is up-to-date when insert returns
```

For patterns like cross-aggregate invariants and process managers, see [Consistency Patterns](https://hindsight.events/tutorials/05-consistency-patterns/) and [Multi-Stream Consistency](https://hindsight.events/tutorials/08-multi-stream-consistency/).

## Documentation

- **[Introduction](https://hindsight.events/introduction/)** - Why event sourcing? Why type-safe versioning?
- **[Tutorials](https://hindsight.events/tutorials/)** - Hands-on learning from basics to advanced patterns
- **[API Reference](https://hindsight.events/api/)** - Complete Haddock documentation
- **[Building & Testing](https://hindsight.events/development/building/)** - Development setup

## Project Status

Hindsight is experimental. The core versioning system is working and tested, but the API is evolving. This is a good time to explore and provide feedback, but expect some rough edges.

Current state:
- ✅ Event versioning with compile-time guarantees
- ✅ Multiple storage backends (Memory, Filesystem, PostgreSQL)
- ✅ Event subscriptions with type-safe pattern matching
- ✅ PostgreSQL projections with transaction support
- ✅ Property-based and integration testing
- ⚠️  API may change - not production-hardened yet

## Contributing

Contributions welcome. See [development/contributing](docs/source/development/contributing.rst) for guidelines.

Areas of particular interest:
- Real-world usage feedback and bug reports
- Improved error messages and developer ergonomics
- Additional storage backends (EventStoreDB, KurrentDB)
- Performance testing and optimization
- Documentation improvements

## License

To be determined.