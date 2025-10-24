Getting Started with Hindsight
=============================

This tutorial introduces Hindsight, a type-safe event sourcing library for Haskell.
We'll learn the basics by building a simple working example.

In this tutorial, we will:

- Define an event with a single version ;
- Instantiate an in-memory event store ;
- Insert a few events ;
- Read those events back through a subscription.

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
-- Define all our versions (only one for now)
type instance Versions UserRegistered = '[UserInfo]
-- Declare this symbol as an event
instance Event UserRegistered
-- Register this event with the event upgrade mechanism
instance MigrateVersion 0 UserRegistered
\end{code}

The event is now ready to use.

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

Let's break this down:

- Events are organized into streams identified by an unique identifier (`UUID`).
  Streams are a low-level primitive and Hindsight does not make assumptions regarding how they are used.
  Typically, event sourcing applications use streams to store events associated to an aggregate, 
  but you can also forgo the concept of streams almost entirely and insert all of your events into a single stream,
  as we do here.
- Storeable events are created with the `mkEvent` function:

  ```haskell
    mkEvent ::
      forall (event :: Symbol) ->
      -- ^ Event name (type-level string)
      (Event event) =>
      -- | Event payload at current version
      CurrentPayloadType event ->
      -- | Wrapped event for storage
      SomeLatestEvent
  ````
  
  The first argument to `mkEvent` is a **required** type argument
  (note the `forall event ->` instead of `forall event.` syntax).

- We must define an **event transaction** with the `multiEvent` helper. This function is adequate to
  define a transaction inserting multiple events into a single stream:

  ```haskell
    multiEvent ::
      -- | Target stream identifier
      StreamId ->
      -- | Version expectation for concurrency control
      ExpectedVersion backend ->
      -- | Collection of events to insert (typically a list)
      t SomeLatestEvent ->
      -- | Transaction with multiple events
      Transaction t backend 
  ```

  The ``ExpectedVersion`` parameter controls optimistic concurrency control:

  - ``Any`` - No version check (always succeeds, used for append-only logs)
  - ``NoStream`` - Stream must not exist (for creating new aggregates)
  - ``StreamExists`` - Stream must exist (any version acceptable)
  - ``ExactStreamVersion v`` - Stream must be at exact version ``v`` (for updates)

  In this tutorial we use ``Any`` because we're just appending events without conflict detection.

- Finally we insert events into the store with the `insertEvents` method of the event store interface:

  ```haskell
    insertEvents ::
      (Traversable t, StoreConstraints backend m) =>
      BackendHandle backend ->
      Maybe CorrelationId ->
      Transaction t backend ->
      m (InsertionResult backend)
  ```

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

Let us break this down again:

- We use the `subscribe` method from the event store interface to define a subscription

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

- **Events** are identified by a typelevel symbol
- **Event versioning** must be explicitly declared through a typelevel DSL
- **Stores**, well, store and dispatch events (we used `MemoryStore` for simplicity)
- **Streams** are a fundamental storage primitive to group events
- **Subscriptions** let you process events as they arrive

Next Steps
-------------

In the next tutorial, we will put our subscriptions to good use by building in-memory projections.