# Hindsight Core

Core type-safe event sourcing library with compile-time versioning.

## What's in This Package

The `hindsight` package provides the foundation for type-safe event sourcing:

- **Type-level event definitions** using DataKinds and type families
- **Compile-time version tracking** for event schema evolution
- **Abstract `EventStore` interface** implemented by storage backends
- **Event subscriptions** for processing streams with pattern matching
- **Serialization support** with automatic version handling

This is the core library. You'll need a storage backend to actually persist events:

- [`hindsight-memory-store`](../hindsight-memory-store/) - In-memory (testing)
- [`hindsight-filesystem-store`](../hindsight-filesystem-store/) - File-based (single-node)
- [`hindsight-postgresql-store`](../hindsight-postgresql-store/) - PostgreSQL (production)

## The Versioning System

Event sourcing's core challenge: **events are immutable, but schemas evolve**. When you change an event's structure, old events remain in the original format forever. Your code must handle all versions.

Hindsight solves this by encoding versions in types.

### Basic Event Definition

```haskell
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}

import Hindsight.Core

-- Type-level event name
type UserRegistered = "user_registered"

-- Payload for version 0
data UserInfo = UserInfo
  { userId :: Text
  , userName :: Text
  } deriving (Generic, FromJSON, ToJSON)

-- Version declaration
type instance MaxVersion UserRegistered = 0
type instance Versions UserRegistered = FirstVersion UserInfo

instance Event UserRegistered
instance UpgradableToLatest UserRegistered 0 where
  upgradeToLatest = id  -- Latest version, no upgrade needed
```

### Schema Evolution

When you need to add fields or change structure, add a new version:

```haskell
-- New version with additional field
data UserInfoV1 = UserInfoV1
  { userId :: Text
  , userName :: Text
  , email :: Text  -- new!
  } deriving (Generic, FromJSON, ToJSON)

-- Update version declarations
type instance MaxVersion UserRegistered = 1
type instance Versions UserRegistered =
  FirstVersion UserInfo :> UserInfoV1

-- Provide upgrade from v0 to v1
instance UpgradableToLatest UserRegistered 0 where
  upgradeToLatest (UserInfo uid name) =
    UserInfoV1 uid name "unknown@example.com"

instance UpgradableToLatest UserRegistered 1 where
  upgradeToLatest = id
```

**Critical insight**: GHC enforces exhaustiveness. Forget an upgrade path? Compile error. Event handlers always receive the latest version—upcasting happens automatically during deserialization.

### How It Works

The type system encodes:

1. **All versions ever created** via the `Versions` type family
2. **Current maximum version** via `MaxVersion`
3. **Upgrade paths** via `UpgradableToLatest` instances

When Hindsight deserializes an event:
1. JSON includes version number: `{"event_name": "user_registered", "version": 0, ...}`
2. Deserialize to version 0 payload
3. Call `upgradeToLatest @UserRegistered @0` to get current version
4. Handler receives `UserInfoV1` regardless of stored version

If you add version 2 but forget the v0→v2 upgrade instance, your code won't compile.

## Event Store Interface

All storage backends implement `EventStore`:

```haskell
class EventStore store where
  -- Insert events into streams
  insertEvents :: BackendHandle store
               -> Maybe Duration  -- Timeout
               -> Map StreamId (StreamWrite store)
               -> IO InsertionResult

  -- Subscribe to event stream
  subscribe :: BackendHandle store
            -> Matcher store m
            -> EventSelector
            -> IO (SubscriptionHandle m)
```

Code written against this interface works with any backend. Change storage by swapping the handle:

```haskell
-- Testing
store <- newMemoryStore
result <- insertEvents store Nothing events

-- Production (same code, different store)
store <- newPostgreSQLStore connectionString
result <- insertEvents store Nothing events
```

## Usage

Import the core module:

```haskell
import Hindsight  -- Re-exports commonly used types and functions
```

Or import specific modules:

```haskell
import Hindsight.Core           -- Event definitions and versioning
import Hindsight.Store          -- EventStore interface
import Hindsight.Store.Parsing  -- Event parsing utilities
```

Then choose a backend:

```haskell
import Hindsight.Store.Memory (newMemoryStore)
import Hindsight.Store.Filesystem (newFilesystemStore)
import Hindsight.Store.PostgreSQL (newPostgreSQLStore)
```

## Testing Facilities

The `hindsight:event-testing` internal library provides test generation:

```haskell
import Test.Hindsight.Generate

-- Generate golden test for event serialization
goldenTest (Proxy @UserRegistered) "golden/user_registered.json"
```

See the [Testing Guide](https://hindsight.events/development/testing/) for details on property-based testing and golden tests.

## Documentation

- **[Tutorials](https://hindsight.events/tutorials/)** - Start here
- **[Event Versioning Tutorial](https://hindsight.events/tutorials/04-event-versioning/)** - Deep dive on versioning
- **[API Reference](https://hindsight.events/api/)** - Haddock docs
- **[Root README](../)** - Project overview

## Design Notes

### Why Type Families?

Type families let us associate version information with type-level event names:

```haskell
type UserRegistered = "user_registered"  -- Type-level string

-- Associated types
type instance MaxVersion UserRegistered = 1
type instance Versions UserRegistered = FirstVersion V0 :> V1
```

This means the version information is part of the type signature. Functions that work with `UserRegistered` events have access to version metadata at compile time.

### Why DataKinds?

DataKinds promotes values to types. The event name `"user_registered"` becomes a type:

```haskell
type UserRegistered = "user_registered"  -- Type, not value

-- Can use in type signatures
handler :: EventHandler UserRegistered IO store
```

This enables type-safe pattern matching in subscriptions. You can't accidentally match the wrong event type.

### Trade-offs

**Pros**:
- Schema evolution is checked at compile time
- Impossible to forget upgrade paths
- Handlers are simpler (always receive latest version)
- No runtime version registry

**Cons**:
- Requires advanced type system features
- Error messages can be cryptic (improving!)
- More boilerplate than untyped systems
- Version changes require recompilation

We believe the type safety is worth it for systems that need to run reliably over long periods with evolving schemas.
