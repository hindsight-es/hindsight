In-Memory Projections
=====================

Now that you can store and read events, let's build something useful: **read models**.
Projections transform event streams into queryable views using STM (Software Transactional Memory).

What Are Projections?
---------------------

Events tell you **what happened**. Projections answer **questions about the current state**.

For example:

- Events: "UserRegistered", "UserDeactivated", "UserReactivated"
- Projection: "How many active users are there right now?"

Projections are **derived data** - you can always rebuild them from events.

Prerequisites
-------------

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
import Control.Concurrent.STM
import Control.Monad (void)
import Data.Aeson (FromJSON, ToJSON)
import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Text (Text)
import Data.UUID.V4 qualified as UUID
import GHC.Generics (Generic)
import Hindsight
import Hindsight.Store.Memory (MemoryStore, newMemoryStore)
\end{code}

Define Domain Events
--------------------

Let's model user lifecycle events:

\begin{code}
type UserRegistered = "user_registered"
type UserDeactivated = "user_deactivated"

data UserInfo = UserInfo
  { userId :: Text
  , userName :: Text
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)

data DeactivationInfo = DeactivationInfo
  { userId :: Text
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)

-- Event versioning
type instance MaxVersion UserRegistered = 0
type instance Versions UserRegistered = '[UserInfo]
instance Event UserRegistered
instance MigrateVersion 0 UserRegistered

type instance MaxVersion UserDeactivated = 0
type instance Versions UserDeactivated = '[DeactivationInfo]
instance Event UserDeactivated
instance MigrateVersion 0 UserDeactivated

-- Event helpers
registerUser :: Text -> Text -> SomeLatestEvent
registerUser uid name =
  mkEvent UserRegistered (UserInfo uid name)

deactivateUser :: Text -> SomeLatestEvent
deactivateUser uid =
  mkEvent UserDeactivated (DeactivationInfo uid)
\end{code}

Building a Simple Projection
-----------------------------

Let's count active users using a TVar (transactional variable):

\begin{code}
-- Our read model: a simple counter
type UserCountModel = TVar Int

-- Create an empty model
newUserCountModel :: IO UserCountModel
newUserCountModel = newTVarIO 0

-- Query the current count
queryUserCount :: UserCountModel -> IO Int
queryUserCount = readTVarIO

-- Update handlers for each event type
handleRegistration :: UserCountModel -> EventHandler UserRegistered IO MemoryStore
handleRegistration countModel envelope = do
  let user = envelope.payload
  atomically $ modifyTVar' countModel (+1)
  putStrLn $ "  → Registered: " <> show user.userName <> " (count +1)"
  return Continue

handleDeactivation :: UserCountModel -> EventHandler UserDeactivated IO MemoryStore
handleDeactivation countModel envelope = do
  let user = envelope.payload
  atomically $ modifyTVar' countModel (subtract 1)
  putStrLn $ "  → Deactivated: " <> show user.userId <> " (count -1)"
  return Continue
\end{code}

Demo: Counting Active Users
---------------------------

\begin{code}
demoUserCount :: IO ()
demoUserCount = do
  putStrLn "=== User Count Projection ==="

  store <- newMemoryStore
  streamId <- StreamId <$> UUID.nextRandom

  -- Create our read model
  countModel <- newUserCountModel

  -- Subscribe to events and update the model
  handle <- subscribe store
    ( match UserRegistered (handleRegistration countModel)
    :? match UserDeactivated (handleDeactivation countModel)
    :? MatchEnd
    )
    (EventSelector AllStreams FromBeginning)

  -- Insert some events
  let events = [ registerUser "U001" "Alice"
               , registerUser "U002" "Bob"
               , registerUser "U003" "Carol"
               , deactivateUser "U002"  -- Bob leaves
               ]

  void $ insertEvents store Nothing $
    multiEvent streamId Any events

  -- Wait for projection to update
  threadDelay 100000

  -- Query the result
  activeUsers <- queryUserCount countModel
  putStrLn $ "\n✓ Active users: " <> show activeUsers

  handle.cancel
  threadDelay 10000
\end{code}

Building a Richer Projection
-----------------------------

Let's build a projection that tracks actual user details:

\begin{code}
-- Our read model: a map of active users
type UserDirectoryModel = TVar (Map Text Text)  -- userId -> userName

newUserDirectory :: IO UserDirectoryModel
newUserDirectory = newTVarIO Map.empty

-- Query operations
getAllUsers :: UserDirectoryModel -> IO [(Text, Text)]
getAllUsers model = Map.toList <$> readTVarIO model

lookupUser :: UserDirectoryModel -> Text -> IO (Maybe Text)
lookupUser model uid = Map.lookup uid <$> readTVarIO model

-- Update handlers
handleRegistrationDir :: UserDirectoryModel -> EventHandler UserRegistered IO MemoryStore
handleRegistrationDir dirModel envelope = do
  let user = envelope.payload
  atomically $ modifyTVar' dirModel (Map.insert user.userId user.userName)
  return Continue

handleDeactivationDir :: UserDirectoryModel -> EventHandler UserDeactivated IO MemoryStore
handleDeactivationDir dirModel envelope = do
  let user = envelope.payload
  atomically $ modifyTVar' dirModel (Map.delete user.userId)
  return Continue
\end{code}

Demo: User Directory
-------------------

\begin{code}
demoUserDirectory :: IO ()
demoUserDirectory = do
  putStrLn "\n=== User Directory Projection ==="

  store <- newMemoryStore
  streamId <- StreamId <$> UUID.nextRandom

  -- Create the directory model
  dirModel <- newUserDirectory

  -- Subscribe
  handle <- subscribe store
    ( match UserRegistered (handleRegistrationDir dirModel)
    :? match UserDeactivated (handleDeactivationDir dirModel)
    :? MatchEnd
    )
    (EventSelector AllStreams FromBeginning)

  -- Insert events
  let events = [ registerUser "U001" "Alice"
               , registerUser "U002" "Bob"
               , deactivateUser "U001"  -- Alice leaves
               ]

  void $ insertEvents store Nothing $
    multiEvent streamId Any events

  threadDelay 100000

  -- Query the directory
  allUsers <- getAllUsers dirModel
  putStrLn $ "\n✓ Active users: " <> show allUsers

  -- Look up a specific user
  maybeBob <- lookupUser dirModel "U002"
  putStrLn $ "✓ User U002: " <> show maybeBob

  handle.cancel
  threadDelay 10000
\end{code}

Running the Examples
-------------------

\begin{code}
main :: IO ()
main = do
  putStrLn "=== Hindsight Tutorial 02: In-Memory Projections ==="
  putStrLn ""

  demoUserCount
  demoUserDirectory

  putStrLn ""
  putStrLn "Tutorial complete!"
\end{code}

Summary
-------

Key concepts:

- **Projections** transform events into queryable state
- **TVar** provides transactional updates (STM)
- **Handlers** process events and update the projection
- **Queries** read from the projection (not from events directly)

Why STM?
--------

STM (Software Transactional Memory) ensures:

- **Atomicity**: Updates happen completely or not at all
- **Consistency**: Your read model stays consistent
- **Isolation**: Concurrent updates don't interfere

Next Steps
----------

In the next tutorial, we'll explore **PostgreSQL projections** - building
read models that persist to a database and survive application restarts.
