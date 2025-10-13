---
title: Home
---

# Hindsight

**Type-safe and evolvable event sourcing for Haskell**

Hindsight is a type-safe event sourcing system that provides strong compile-time guarantees for event handling, versioning, and consistency. Built for production use with multiple storage backends.

## Hindsight in Action

::: {.code-carousel}
::: {.carousel-tabs role="tablist"}
<button class="carousel-tab" role="tab" aria-selected="true">Event Definition</button>
<button class="carousel-tab" role="tab" aria-selected="false">Live Subscriptions</button>
<button class="carousel-tab" role="tab" aria-selected="false">SQL Projections</button>
<button class="carousel-tab" role="tab" aria-selected="false">Multiple Backends</button>
:::

::: {.carousel-content}
::: {.carousel-panel .active role="tabpanel"}
### Type-Safe Event Definition

Define events with compile-time versioning guarantees. No runtime surprises.

```haskell
-- Event definition
instance Event "user_registered"

-- Event payload
data UserInfo = UserInfo
  { userId :: Text
  , email :: Text
  } deriving (Generic, FromJSON, ToJSON)

-- Version declaration
type instance MaxVersion UserRegistered = 0
type instance Versions UserRegistered =
  FirstVersion UserInfo

-- Upcasting
instance UpgradableToLatest UserRegistered 0 where
  upgradeToLatest = id
```
:::

::: {.carousel-panel role="tabpanel"}
### Backend-Agnostic Subscriptions

Subscribe to events with handlers that work across all backends.

```haskell
{-# LANGUAGE RequiredTypeArguments #-}

-- Subscribe to events (works with any backend)
subscribeToUsers :: BackendHandle backend -> IO ()
subscribeToUsers store = do
  handle <- subscribe store
    ( match "user_registered" handleUser :?
      MatchEnd )
    (EventSelector AllStreams FromBeginning)

  -- Handler runs for each event
  where
    handleUser :: EventHandler "user_registered" IO backend
    handleUser envelope = do
      let user = envelope.payload
      putStrLn $ "New user: " <> user.email
      return Continue
```
:::

::: {.carousel-panel role="tabpanel"}
### SQL Projection Handlers

Transform events into queryable read models with ACID guarantees.

```haskell
{-# LANGUAGE RequiredTypeArguments #-}

-- Projection handler (PostgreSQL transactions)
userProjection :: ProjectionHandler "user_registered" backend
userProjection envelope = do
  let user = envelope.payload

  -- Execute SQL in transaction
  statement () $ Statement sql encoder decoder True

  where
    sql = "INSERT INTO users (id, email) VALUES ($1, $2)"
    encoder = contrazip2
      (param (nonNullable text))
      (param (nonNullable text))
```
:::

::: {.carousel-panel role="tabpanel"}
### Flexible Backend Choice

Start simple, scale when ready. Same API, different backends.

```haskell
-- File system store
fsStore :: IO (BackendHandle FilesystemStore)
sqlStore =
  newFilesystemStore "./events"

-- PostgreSQL store
sqlStore :: IO (BackendHandle PostgreSQLStore)
sqlStore = do
  pool <- createPool postgresSettings
  newPostgreSQLStore pool

-- Same operations, different backends
insertEvents devStore   Nothing batch
insertEvents sqlStore  Nothing batch
```
:::
:::
:::

## Key Features

- **Type-safe events** with automatic versioning using DataKinds
- **Multiple backends**: Memory, Filesystem, and PostgreSQL
- **Real-time subscriptions** for event stream processing
- **Projection system** for building read models
- **Strong consistency** guarantees across all operations

## Get Started

Ready to dive in? Check out our comprehensive documentation:

<div class="cta-buttons">
  <a href="/docs/" class="btn btn-primary">Read Documentation</a>
  <a href="/docs/tutorials/01-getting-started.html" class="btn btn-secondary">Quick Start Guide</a>
</div>

## Why Hindsight?

Event sourcing provides powerful guarantees for distributed systems, but implementing it correctly is challenging. Hindsight leverages Haskell's type system to catch common mistakes at compile time:

- **No version mismatches**: The type system ensures events can always be deserialized
- **No ordering bugs**: Causal consistency is enforced through the API
- **No silent failures**: All error cases are explicit and handled

## Architecture

Hindsight follows a modular architecture:

1. **Core Event System** - Type-safe event definitions with versioning
2. **Storage Layer** - Pluggable backends for different use cases
3. **Subscription System** - Real-time event stream processing
4. **Projection System** - Transform events into queryable read models

Learn more in the [architecture documentation](/docs/index.html#architecture).
