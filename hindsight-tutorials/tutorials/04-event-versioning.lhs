Event Versioning
================

Event schemas evolve over time. This tutorial shows how to add fields to events
while maintaining backward compatibility with old data through Hindsight's
automatic version upgrade mechanism.

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
import Control.Monad (void)
import Data.Aeson (FromJSON, ToJSON)
import Data.Text (Text)
import Data.UUID.V4 qualified as UUID
import GHC.Generics (Generic)
import Hindsight
import Hindsight.Store.Memory (MemoryStore, newMemoryStore)
\end{code}

Version 0: The Original Event
------------------------------

\begin{code}
type UserCreated = "user_created"

-- Version 0: Basic user information
data UserInfoV0 = UserInfoV0
  { userId :: Int
  , userName :: Text
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)
\end{code}

Version 1: Adding Email
-----------------------

Later, we need email addresses:

\begin{code}
-- Version 1: Now with email!
data UserInfoV1 = UserInfoV1
  { userId :: Int
  , userName :: Text
  , userEmail :: Maybe Text  -- New field (Maybe because old events won't have it)
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)
\end{code}

Version 2: Adding User Status
------------------------------

Even later, we need to track user account status:

\begin{code}
-- User account status
data UserStatus = Active | Suspended
  deriving (Show, Eq, Generic, FromJSON, ToJSON)

-- Version 2: Now with status!
data UserInfoV2 = UserInfoV2
  { userId :: Int
  , userName :: Text
  , userEmail :: Maybe Text
  , userStatus :: UserStatus  -- New field (default to Active for old users)
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)
\end{code}

Defining the Upgrades
-----------------------

Define each consecutive upgrade (V0 → V1, V1 → V2):

\begin{code}
-- Upgrade V0 → V1
instance Upcast 0 UserCreated where
  upcast old = UserInfoV1
    { userId = old.userId
    , userName = old.userName
    , userEmail = Nothing  -- Old events don't have email
    }

-- Upgrade V1 → V2
instance Upcast 1 UserCreated where
  upcast old = UserInfoV2
    { userId = old.userId
    , userName = old.userName
    , userEmail = old.userEmail
    , userStatus = Active  -- Default to Active for existing users
    }
\end{code}

Wiring It Up
------------

Tell Hindsight about all versions:

\begin{code}
-- MaxVersion says "version 2 is the latest"
type instance MaxVersion UserCreated = 2

-- Versions lists all versions in order
type instance Versions UserCreated = '[UserInfoV0, UserInfoV1, UserInfoV2]

-- Event instance (required for all events)
instance Event UserCreated

-- Migration instances - automatically derived from consecutive upcasts
instance MigrateVersion 0 UserCreated  -- V0 → V2 via V0 → V1 → V2 (composed!)
instance MigrateVersion 1 UserCreated  -- V1 → V2 via V1 → V2
instance MigrateVersion 2 UserCreated  -- V2 → V2 (identity)
\end{code}

How Migration Works
-------------------

The magic happens through the interplay of `Upcast` and `MigrateVersion`:

- **`Upcast n`** defines a single upgrade step: version `n` → version `n+1`
- **`MigrateVersion n`** upgrades version `n` to the latest version (MaxVersion)

When you define `instance MigrateVersion n`, Hindsight automatically derives the full upgrade
path by composing consecutive `Upcast` instances:

- `MigrateVersion 0`: V0 → V1 (via `Upcast 0`) → V2 (via `Upcast 1`)
- `MigrateVersion 1`: V1 → V2 (via `Upcast 1`)
- `MigrateVersion 2`: V2 → V2 (identity, already latest)

**Opt-out**: If you need custom upgrade logic that bypasses consecutive composition,
define an explicit `MigrateVersion` instance with your own implementation (e.g. for performance). If 
you do so, it is for now your responsibility to maintain the consistency of the system
and make sure your manual upgrade matches the composition of consecutive upcasts.

Using Versioned Events
----------------------

Handlers always receive the latest version. Old V0/V1 events stored in the system
are automatically upgraded to V2 when read.

The following demo only inserts V2 events (since we can't easily insert old versions into
an in-memory store). To see real upgrades in action, try this exercise: use a persistent
store (Filesystem or PostgreSQL), insert V0 events, restart the application with V2 code,
and watch them automatically upgrade when read.

\begin{code}
demoVersioning :: IO ()
demoVersioning = do
  putStrLn "=== Event Versioning Demo ==="

  store <- newMemoryStore
  streamId <- StreamId <$> UUID.nextRandom

  -- Insert events using the LATEST version (V2)
  let event1 = mkEvent UserCreated $
        UserInfoV2 1 "Alice" (Just "alice@example.com") Active

      event2 = mkEvent UserCreated $
        UserInfoV2 2 "Bob" Nothing Suspended

  void $ insertEvents store Nothing $
    multiEvent streamId Any [event1, event2]

  putStrLn "✓ Inserted events (V2 format)"

  -- Read them back - all events arrive as V2
  handle <- subscribe store
    (match UserCreated handleUser :? MatchEnd)
    (EventSelector AllStreams FromBeginning)

  threadDelay 100000
  handle.cancel
  threadDelay 10000

  putStrLn "\n✓ All events received as V2 (latest version)"

handleUser :: EventHandler UserCreated IO MemoryStore
handleUser envelope = do
  let user = envelope.payload :: UserInfoV2  -- Always receives latest version!
  putStrLn $ "  → User: " <> show user.userName
           <> ", Email: " <> show user.userEmail
           <> ", Status: " <> show user.userStatus
  return Continue
\end{code}

Running the Example
-------------------

\begin{code}
main :: IO ()
main = do
  putStrLn "=== Hindsight Tutorial 04: Event Versioning ==="
  putStrLn ""

  demoVersioning

  putStrLn ""
  putStrLn "Tutorial complete!"
\end{code}

Summary
-------

Key concepts:

- **Consecutive upcasts** (`Upcast n`): define single-step upgrades (V_n → V_{n+1})
- **Automatic composition**: `MigrateVersion n` composes upcasts to reach latest version
- **Handlers always receive latest version**: V0/V1 events automatically upgrade to V2 when read
- **Opt-out available**: define custom `MigrateVersion` instance for non-standard upgrade logic

Next Steps
----------

In the next tutorial, we'll explore **consistency patterns** - handling
concurrent writes and optimistic locking with stream expectations.
