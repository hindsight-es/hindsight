# Hindsight

Type-safe event sourcing for Haskell with strong compile-time guarantees.

## What is Hindsight?

Hindsight is a battery-included [event-sourcing](https://en.wikipedia.org/wiki/Event-driven_architecture) sets of libraries
for Haskell. It primarily targets applications where correctness is a critical (financial systems, compliance systems,
healthcare, etc.).

A key feature of Hindsight is to make schema evolution a **compile-time** concern: event-versioning leverages the type system
to provide strong safety guarantees without sacrificing on performance. Hindsight provides a testing toolkit to generate
roundtrip and golden tests automatically for you, ensuring that you never accidentally break past events (see TODO below).

Hindsight defines a stream-based [event store](https://en.wikipedia.org/wiki/Event_store) interface. Event stores manage
event insertion  and live subscriptions (single stream / all streams). They honor the following semantics:

- Exactly-once delivery (no duplicate or missing event).
- Total event ordering: subscriptions always process events in the same order.

Event stores support multi-stream event transactions. They provide the means to implement complex consistency requirements
with optimistic concurrency control via version expectations à la [KurrentDB](https://github.com/kurrent-io/KurrentDB).

Three event store implementations are currently provided:

- **[hindsight-memory-store](hindsight-memory-store/)** - In-memory implementation (mostly intended for testing).
- **[hindsight-filesystem-store](hindsight-filesystem-store/)** - File-based implementation (single-node deployments).
- **[hindsight-postgresql-store](hindsight-postgresql-store/)** - PostgreSQL implementation (multi-node deployments).

Hindsight also provides a PostgreSQL projection system:

- **[hindsight-postgresql-projections](hindsight-postgresql-projections/)**.

PostgreSQL projections are built on top of the generic subscription API and can be used with any event store backend (see TODO link below).
As a backend-specific feature, the PostgreSQL store also supports synchronous projections (called [inline projections](https://martendb.io/events/projections/inline) in MartenDB). Synchronous projections are processed in the same transaction as event insertion
and SQL errors in synchronous projections prevent events from being inserted. They can thus be used:

- To sidestep [eventual consistency](https://en.wikipedia.org/wiki/Eventual_consistency) concerns that typically affect
  event-driven architectures.
- To implement complex event validation logic and consistency requirements that are hard / impossible to implement through
  event versioning alone, for example via:
  - SQL Constraints (`FOREIGN KEY`, `CHECK`).
  - Advanced PostgreSQL queries (CTEs, [temporal extensions](https://github.com/xocolatl/periods) etc.)
  - Triggers.


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

When you need to evolve the schema, add a new version and define consecutive upgrades. The system automatically composes them:

```haskell
-- Add version 1 with additional field
data UserInfoWithEmail = UserInfoWithEmail
  { userId :: Text
  , userName :: Text
  , email :: Text  -- new field
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)

type instance MaxVersion UserRegistered = 1
type instance Versions UserRegistered =
  '[UserInfo, UserInfoWithEmail]

-- Consecutive upgrade from v0 to v1
instance Upcast 0 UserRegistered where
  upcast (UserInfo uid name) =
    UserInfoWithEmail uid name "unknown@example.com"

-- Migration instances use automatic composition
instance MigrateVersion 0 UserRegistered  -- Automatic: V0 → V1
instance MigrateVersion 1 UserRegistered  -- Automatic: V1 → V1 (identity)
```


## Projections

The **[hindsight-postgresql-projections](hindsight-postgresql-projections/)** package a projection system for building SQL-based
read models. Projections execute in PostgreSQL transactions but can subscribe to events from any backend:

TODO: Write a very very simple SQL-based projection example using hasql (not hasql-th)

## Testing Support

Hindsight includes facilities for generating serialization (roundtrip) and golden tests, critical for ensuring you never accidentally break
compatibility with stored events:

```haskell
TODO
```

Golden tests should be run locally when updating an event, and their output committed along with your code.
By running them on continuous integration, accidental breakages can be automatically detected.

TODO: Show in detail how that works (Some diagram ? Examples on how to run with to either generate the golden output /
fail and/or fail if different/not-generated).



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

TODO: 

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