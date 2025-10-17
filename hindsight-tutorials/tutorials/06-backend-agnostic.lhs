Backend-Agnostic Code
=====================

Write once, run anywhere. This tutorial shows how to write application code
that works with **any** Hindsight backend (Memory, Filesystem, PostgreSQL).

The Goal
--------

You want code like this to work with ANY backend:

```haskell
myApp :: BackendHandle backend -> IO ()
myApp store = do
  -- Insert events
  -- Subscribe to events
  -- Query projections
  -- Everything works regardless of backend!
```

Prerequisites
-------------

\begin{code}
{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE RequiredTypeArguments #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Main where

import Control.Concurrent (threadDelay)
import Control.Concurrent.STM (atomically, newTVarIO, readTVarIO, modifyTVar')
import Control.Exception (bracket)
import Control.Monad (void)
import Data.Aeson (FromJSON, ToJSON)
import Data.Text (Text)
import Data.UUID.V4 qualified as UUID
import GHC.Generics (Generic)
import Hindsight
import Hindsight.Store.Memory (newMemoryStore)
import Hindsight.Store.Filesystem (newFilesystemStore, mkDefaultConfig, cleanupFilesystemStore)
import System.Directory (removeDirectoryRecursive)
import System.IO.Temp (createTempDirectory, getCanonicalTemporaryDirectory)
\end{code}

Define Events
-------------

\begin{code}
type TaskCreated = "task_created"

data TaskInfo = TaskInfo
  { taskId :: Text
  , taskName :: Text
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)

-- Event versioning
type instance MaxVersion TaskCreated = 0
type instance Versions TaskCreated = '[TaskInfo]
instance Event TaskCreated
instance MigrateVersion 0 TaskCreated

-- Helper
createTask :: Text -> Text -> SomeLatestEvent
createTask tid name =
  mkEvent TaskCreated (TaskInfo tid name)
\end{code}

Write Backend-Agnostic Functions
---------------------------------

The key is to use `Backend` constraint:

\begin{code}
-- This works with ANY backend!
insertTaskGeneric :: forall backend. (EventStore backend, StoreConstraints backend IO)
                  => BackendHandle backend
                  -> Text
                  -> Text
                  -> IO (InsertionResult backend)
insertTaskGeneric store taskId taskName = do
  streamId <- StreamId <$> UUID.nextRandom

  let event = createTask taskId taskName

  insertEvents store Nothing $
    singleEvent streamId Any event

-- This also works with ANY backend!
countTasksGeneric :: forall backend. (EventStore backend, StoreConstraints backend IO)
                  => BackendHandle backend
                  -> IO Int
countTasksGeneric store = do
  countVar <- newTVarIO (0 :: Int)

  handle <- subscribe store
    (match TaskCreated (countTaskHandler countVar) :? MatchEnd)
    (EventSelector AllStreams FromBeginning)

  threadDelay 100000
  handle.cancel
  threadDelay 10000

  readTVarIO countVar
  where
    countTaskHandler countVar _envelope = do
      atomically $ modifyTVar' countVar (+1)
      return Continue
\end{code}

Demo with Different Backends
-----------------------------

Now use these generic functions with different backends:

\begin{code}
demoWithMemory :: IO ()
demoWithMemory = do
  putStrLn "=== Using Memory Backend ==="

  store <- newMemoryStore

  -- Use generic function
  void $ insertTaskGeneric  store "T1" "Learn Haskell"
  void $ insertTaskGeneric  store "T2" "Write docs"

  count <- countTasksGeneric  store
  putStrLn $ "  Tasks created: " <> show count <> "\n"

demoWithFilesystem :: IO ()
demoWithFilesystem = do
  putStrLn "=== Using Filesystem Backend ==="

  -- Create temporary directory
  tmpDir <- getCanonicalTemporaryDirectory
  storePath <- createTempDirectory tmpDir "hindsight-agnostic"

  bracket
    (newFilesystemStore $ mkDefaultConfig storePath)
    cleanupFilesystemStore
    $ \store -> do
      -- Same generic functions work!
      void $ insertTaskGeneric  store "T3" "Fix bug"
      void $ insertTaskGeneric  store "T4" "Deploy"

      count <- countTasksGeneric  store
      putStrLn $ "  Tasks created: " <> show count

  -- Cleanup
  removeDirectoryRecursive storePath
  putStrLn "  (Cleaned up temp directory)\n"
\end{code}

Key Concepts
-----------

**EventStore Constraint**: `EventStore backend =>`
- Makes functions work with any backend
- No hardcoded backend choice

**Type Application**: `@MemoryStore`, `@FilesystemStore`
- Explicitly specify which backend to use
- Required when calling generic functions

**Same Logic, Different Storage**:

- Write business logic once
- Test with Memory backend
- Deploy with PostgreSQL backend

Running the Examples
-------------------

\begin{code}
main :: IO ()
main = do
  putStrLn "=== Hindsight Tutorial 06: Backend-Agnostic Code ==="
  putStrLn ""

  demoWithMemory
  demoWithFilesystem

  putStrLn "Tutorial complete!"
  putStrLn "\nNote: The same functions work with PostgreSQL too!"
  putStrLn "Just use: insertTaskGeneric  store ..."
\end{code}

Best Practices
--------------

**Separate Backend Choice from Logic**:
```haskell
-- Good: Generic business logic
processOrder :: EventStore b => BackendHandle b -> Order -> IO ()

-- Bad: Hardcoded backend
processOrder :: BackendHandle MemoryStore -> Order -> IO ()
```

**Test with Memory, Deploy with PostgreSQL**:
```haskell
-- Tests
testOrderProcessing = do
  store <- newMemoryStore
  processOrder  store testOrder

-- Deployment
main = do
  store <- newSQLStore "postgresql://..."
  processOrder  store realOrder
```

Summary
-------

Backend-agnostic code:

- Uses `Backend` constraint
- Works with any storage backend
- Same logic everywhere
- Test fast (Memory), deploy robust (PostgreSQL)

Next Steps
----------

You now have all the core concepts! In the final tutorial, we'll explore
advanced features and deployment patterns.
