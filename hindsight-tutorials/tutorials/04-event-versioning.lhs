Event Versioning
================

Event schemas evolve over time. This tutorial shows how to add fields to events
while maintaining backward compatibility with old data.

The Versioning Challenge
------------------------

Imagine you store these events:

- `{ userId: 1, userName: "Alice" }`
- `{ userId: 2, userName: "Bob" }`

Later, you need to add an email field. But you can't change the old events!
Event sourcing systems are **append-only** - you never modify historical data.

Hindsight's solution: **version upgrades**.

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

Defining the Upgrade
--------------------

Hindsight uses **consecutive upcasts** - you only define how to upgrade from
one version to the next. The system automatically composes these to handle
any version gap!

\begin{code}
-- Define the upgrade: V0 → V1
instance Upcast 0 UserCreated where
  upcast old = UserInfoV1
    { userId = old.userId
    , userName = old.userName
    , userEmail = Nothing  -- Old events don't have email, so use Nothing
    }
\end{code}

Wiring It Up
------------

Tell Hindsight about both versions:

\begin{code}
-- MaxVersion says "version 1 is the latest"
type instance MaxVersion UserCreated = 1

-- Versions lists all versions in order
type instance Versions UserCreated = '[UserInfoV0, UserInfoV1]

-- Event instance (required for all events)
instance Event UserCreated

-- Migration instances - the system automatically uses consecutive upcasts!
instance MigrateVersion 0 UserCreated  -- Automatic: V0 → V1 (via Upcast 0)
instance MigrateVersion 1 UserCreated  -- Automatic: V1 → V1 (identity)
\end{code}

Using Versioned Events
----------------------

Now you can work with both old and new events:

\begin{code}
demoVersioning :: IO ()
demoVersioning = do
  putStrLn "=== Event Versioning Demo ==="

  store <- newMemoryStore
  streamId <- StreamId <$> UUID.nextRandom

  -- Insert events using the LATEST version (V1)
  let event1 = mkEvent UserCreated $
        UserInfoV1 1 "Alice" (Just "alice@example.com")

      event2 = mkEvent UserCreated $
        UserInfoV1 2 "Bob" Nothing  -- Old user without email

  void $ insertEvents store Nothing $
    multiEvent streamId Any [event1, event2]

  putStrLn "✓ Inserted events (V1 format)"

  -- Read them back - both will be V1!
  handle <- subscribe store
    (match UserCreated handleUser :? MatchEnd)
    (EventSelector AllStreams FromBeginning)

  threadDelay 100000
  handle.cancel
  threadDelay 10000

  putStrLn "\n✓ All events are V1 (latest version)"

handleUser :: EventHandler UserCreated IO MemoryStore
handleUser envelope = do
  let user = envelope.payload :: UserInfoV1  -- Always receives latest version!
  putStrLn $ "  → User: " <> show user.userName
           <> ", Email: " <> show user.userEmail
  return Continue
\end{code}

Key Concepts
------------

**Version List**: `'[UserInfoV0, UserInfoV1]`
- Simple type-level list of all payload versions in order
- For many versions: `'[V0, V1, V2, V3]`

**Consecutive Upcasts**: Define only direct version transitions
- `Upcast 0 UserCreated`: V0 → V1
- For V2, just add `Upcast 1 UserCreated`: V1 → V2
- System automatically composes: V0 → V1 → V2

**MigrateVersion**: Automatic migration via composition
- V0 → Latest: Uses consecutive upcasts (V0 → V1)
- V1 → Latest: Identity (already latest)
- No manual upgrade functions needed!

**Automatic Upgrades**: When you read events, Hindsight automatically upgrades them
- Store V0, read as V1 ✓
- Store V1, read as V1 ✓
- Your handlers always get the latest version!

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

Best Practices
--------------

**Adding Fields**:

- Use `Maybe` for new optional fields
- Provide sensible defaults in `Upcast` instances
- Document why fields were added
- Only define V(n) → V(n+1) transitions

**Breaking Changes**:

- Never remove fields from old versions
- Create a new version instead
- Old events must always be readable

**Testing**:

- Test that old events upgrade correctly
- Test that new events work without upgrade
- Verify `Upcast` instances preserve semantics
- Test composition: V0 → V2 via V0 → V1 → V2

Summary
-------

Event versioning lets you:

- Evolve schemas over time
- Keep historical data intact
- Define only consecutive version transitions
- Get automatic composition for free
- Work with the latest version everywhere

Next Steps
----------

In the next tutorial, we'll explore **consistency patterns** - handling
concurrent writes and optimistic locking with stream expectations.
