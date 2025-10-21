{- |
Module      : Hindsight
Description : Type-safe event sourcing system for Haskell
Copyright   : (c) 2024
License     : BSD3
Maintainer  : maintainer@example.com
Stability   : experimental

Hindsight is a type-safe event sourcing system that provides strong compile-time
guarantees for event handling, versioning, and consistency in event-driven applications.

= Getting Started

To get started with Hindsight, you'll typically want to:

1. Define your events using 'Event' instances and type families
2. Choose a storage backend (Memory, Filesystem, or PostgreSQL)
3. Set up projections to build read models
4. Insert and query events through the event store

= Example Usage

@
import Hindsight
import Hindsight.Store.Memory (newMemoryStore)

-- Define your event (using type-level string)
type UserRegistered = "user_registered"

data UserInfo = UserInfo { userId :: UUID, name :: Text }
  deriving (Show, Eq, Generic, FromJSON, ToJSON)

-- Declare versions and register event
type instance MaxVersion UserRegistered = 0
type instance Versions UserRegistered = '[UserInfo]

instance Event UserRegistered
instance MigrateVersion 0 UserRegistered

-- Use it
main = do
  store <- newMemoryStore
  streamId <- StreamId \<$\> UUID.nextRandom
  let event = mkEvent UserRegistered (UserInfo userId "Alice")
  result <- insertEvents store Nothing $ singleEvent streamId NoStream event
  case result of
    SuccessfulInsertion _ -> putStrLn "Event inserted successfully"
    FailedInsertion err -> putStrLn $ "Failed: " <> show err
@

= Storage Backends

Storage backends are in separate packages:

* "Hindsight.Store.Memory" (package: hindsight-memory-store) - In-memory storage for testing and development
* "Hindsight.Store.Filesystem" (package: hindsight-filesystem-store) - File-based persistence for durable event storage
* "Hindsight.Store.PostgreSQL" (package: hindsight-postgresql-store) - PostgreSQL backend with ACID guarantees and projection system

= Core Concepts

* "Hindsight.Events" - Event definitions, versioning, and type-level utilities
* "Hindsight.Store" - Common event store interface and data types

For projection system, see the hindsight-postgresql-projections package.
-}
module Hindsight (
    module Hindsight.Events,
    module Hindsight.Store,
)
where

import Hindsight.Events
import Hindsight.Store
