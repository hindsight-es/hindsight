Getting Started with Hindsight
=============================

This tutorial introduces Hindsight, a type-safe event sourcing library for Haskell.
We'll learn the basics by building a simple working example.

What is Event Sourcing?
-----------------------

Event sourcing stores changes to your application as a sequence of events.
Instead of storing just the current state, we keep a log of everything that happened.

Hindsight provides:

- Type-safe event definitions
- Multiple storage backends
- Tools for reading and processing events

Let's Start Coding
------------------

First, our imports and language extensions:

\begin{code}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RequiredTypeArguments #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Main where

import Control.Concurrent (threadDelay)
import Data.Aeson (FromJSON, ToJSON)
import Data.Text (Text)
import Data.UUID.V4 qualified as UUID
import GHC.Generics (Generic)
import Hindsight
import Hindsight.Store.Memory (MemoryStore, newMemoryStore)
\end{code}

Defining Your First Event
--------------------------

Let's create a simple user registration event:

\begin{code}
-- The event type name
type UserRegistered = "user_registered"

-- The data this event carries
data UserInfo = UserInfo
  { userId :: Text
  , userName :: Text
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)

-- Tell Hindsight about this event (version 0)
type instance MaxVersion UserRegistered = 0
type instance Versions UserRegistered = '[UserInfo]
instance Event UserRegistered
instance MigrateVersion 0 UserRegistered
\end{code}

The event is now registered with the versioning system and ready to use.

Creating Events
---------------

Hindsight provides two key functions for working with events:

- **mkEvent** - Creates a single event from a type-level name and payload:

  .. code-block:: haskell

     mkEvent :: Event eventName => eventName -> LatestVersion eventName -> SomeLatestEvent

  This wraps your event data in a version-aware container that Hindsight can store and deserialize.

- **multiEvent** - Creates a transaction to insert multiple events into a single stream:

  .. code-block:: haskell

     multiEvent :: StreamId -> ExpectedVersion backend -> [SomeLatestEvent] -> Transaction [] backend

  The ``ExpectedVersion`` parameter controls optimistic concurrency control:

  - ``Any`` - No version check (always succeeds, used for append-only logs)
  - ``NoStream`` - Stream must not exist (for creating new aggregates)
  - ``StreamExists`` - Stream must exist (any version acceptable)
  - ``ExactStreamVersion v`` - Stream must be at exact version ``v`` (for updates)

  In this tutorial we use ``Any`` because we're just appending events without conflict detection.

Storing Events
--------------

Let's create an in-memory store and add some events:

\begin{code}
example :: IO ()
example = do
  putStrLn "Creating store and inserting events..."

  -- Create a memory store (good for testing)
  store <- newMemoryStore

  -- Generate a stream ID (streams group related events)
  streamId <- StreamId <$> UUID.nextRandom

  -- Create some events
  let event1 = mkEvent UserRegistered (UserInfo "U001" "Alice")
      event2 = mkEvent UserRegistered (UserInfo "U002" "Bob")

  -- Insert events into the stream
  result <- insertEvents store Nothing $
    multiEvent streamId Any [event1, event2]

  case result of
    SuccessfulInsertion _ -> do
      putStrLn "✓ Events inserted successfully"
      readEventsBack store

    FailedInsertion err ->
      putStrLn $ "✗ Failed to insert: " <> show err
\end{code}

Reading Events Back
-------------------

To read events, we use subscriptions:

\begin{code}
readEventsBack :: BackendHandle MemoryStore -> IO ()
readEventsBack store = do
  putStrLn "\nReading events..."

  -- Subscribe to all events from the beginning
  handle <- subscribe store
    (match UserRegistered handleUserEvent :? MatchEnd)
    (EventSelector AllStreams FromBeginning)

  -- Wait for events to be processed
  threadDelay 100000  -- 0.1 seconds

  -- Clean up
  handle.cancel

-- Handle each UserRegistered event
handleUserEvent :: EventHandler UserRegistered IO MemoryStore
handleUserEvent envelope = do
  let user = envelope.payload
  putStrLn $ "  → User registered: " <> show user.userName
  return Continue
\end{code}

Running the Example
-------------------

\begin{code}
main :: IO ()
main = do
  putStrLn "=== Hindsight Tutorial 01: Getting Started ==="
  putStrLn ""
  example
  putStrLn ""
  putStrLn "Tutorial complete!"
\end{code}

Summary
-------

Key concepts:

- **Events** are defined with a type-level name and a payload
- **Stores** persist events (we used MemoryStore for simplicity)
- **Streams** group related events together
- **Subscriptions** let you process events as they arrive

Next Steps
----------

In the next tutorials, we'll explore:

- Different storage backends (filesystem, PostgreSQL)
- Event versioning and migrations
- Advanced subscription patterns