{-|
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

1. Define your events using 'IsEvent' instances
2. Choose a storage backend (Memory, Filesystem, or PostgreSQL)
3. Set up projections to build read models
4. Insert and query events through the event store

= Example Usage

@
import Hindsight

-- Define your events
data UserCreated = UserCreated { userId :: UUID, name :: Text }
  deriving (Show, Eq, Generic, FromJSON, ToJSON)

instance IsEvent UserCreated where
  eventName = "user_created"

-- Create a memory store and insert events
main = do
  store <- newMemoryStore
  result <- insertEvents store Nothing $ Map.singleton streamId batch
  case result of
    SuccessfulInsertion cursor -> putStrLn "Event inserted successfully"
    _ -> putStrLn "Insertion failed"
@

= Storage Backends

Storage backends are now in separate packages:

* "Hindsight.Store.Memory" (package: hindsight-memory-store) - In-memory storage for testing and development
* "Hindsight.Store.Filesystem" (package: hindsight-filesystem-store) - File-based persistence for durable event storage
* "Hindsight.Store.PostgreSQL" (package: hindsight-postgresql-store) - Production-ready PostgreSQL backend with ACID guarantees and projection system

= Core Concepts

* "Hindsight.Core" - Event definitions, versioning, and type-level utilities
* "Hindsight.Store" - Common event store interface and data types
* "Hindsight.TH" - Template Haskell utilities for code generation

For projection system, see the hindsight-postgresql-store package.
-}
module Hindsight
  ( module Hindsight.Core,
    module Hindsight.Store,
    module Hindsight.TH,
  )
where

import Hindsight.Core
import Hindsight.Store
import Hindsight.TH
