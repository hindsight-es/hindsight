Backend-Agnostic Code
=====================

Whenever possible, write code that depends on **interfaces** rather than concrete implementations.
This enables switching backends: use PostgreSQL in production for durability, but the blazing-fast
Memory backend for tests. Here's how to do it.

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

Use the `EventStore` constraint to write functions that work with any backend:

\begin{code}
-- Works with Memory, Filesystem, PostgreSQL - any EventStore backend
processTask :: forall backend. (EventStore backend, StoreConstraints backend IO)
            => BackendHandle backend
            -> Text  -- Task ID
            -> Text  -- Task name
            -> IO Int  -- Returns count of all tasks
processTask store taskId taskName = do
  streamId <- StreamId <$> UUID.nextRandom

  -- Insert the task event
  void $ insertEvents store Nothing $
    singleEvent streamId Any (createTask taskId taskName)

  -- Count all tasks by subscribing to events
  countVar <- newTVarIO (0 :: Int)
  handle <- subscribe store
    (match TaskCreated (countHandler countVar) :? MatchEnd)
    (EventSelector AllStreams FromBeginning)

  threadDelay 100000  -- Wait for subscription
  handle.cancel

  readTVarIO countVar
  where
    countHandler countVar _envelope = do
      atomically $ modifyTVar' countVar (+1)
      return Continue
\end{code}

Use with Different Backends
----------------------------

The same function works with any backend:

\begin{code}
demoWithMemory :: IO ()
demoWithMemory = do
  putStrLn "=== Using Memory Backend ==="
  store <- newMemoryStore

  count1 <- processTask store "T1" "Learn Haskell"
  putStrLn $ "  After task 1: " <> show count1 <> " tasks"

  count2 <- processTask store "T2" "Write docs"
  putStrLn $ "  After task 2: " <> show count2 <> " tasks\n"

demoWithFilesystem :: IO ()
demoWithFilesystem = do
  putStrLn "=== Using Filesystem Backend ==="

  tmpDir <- getCanonicalTemporaryDirectory
  storePath <- createTempDirectory tmpDir "hindsight-tutorial"

  bracket
    (newFilesystemStore $ mkDefaultConfig storePath)
    cleanupFilesystemStore
    $ \store -> do
      count1 <- processTask store "T3" "Fix bug"
      putStrLn $ "  After task 1: " <> show count1 <> " tasks"

      count2 <- processTask store "T4" "Deploy"
      putStrLn $ "  After task 2: " <> show count2 <> " tasks"

  removeDirectoryRecursive storePath
  putStrLn "  (Cleaned up)\n"
\end{code}

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
\end{code}

Summary
-------

Key concepts:

- **EventStore constraint**: Makes functions work with any backend
- **Same logic, different storage**: Write once, test with Memory, deploy with PostgreSQL
- **Type inference**: Haskell figures out the backend type from usage

Next Steps
----------

You now have all the core concepts! In the final tutorial, we'll explore
advanced features and deployment patterns.
