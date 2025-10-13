Consistency Patterns
====================

When multiple processes try to modify the same stream, you need **consistency control**.
Hindsight uses **optimistic locking** with stream version expectations.

The Problem
-----------

Imagine two processes trying to append to the same stream:

```
Process A: Read stream (version 5) → Append event → ...
Process B: Read stream (version 5) → Append event → ...
```

Both think version 5 is current! Without checks, you get lost updates.

Solution: **Version Expectations**.

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

import Data.Aeson (FromJSON, ToJSON)
import Data.Map.Strict qualified as Map
import Data.Text (Text)
import Data.UUID.V4 qualified as UUID
import GHC.Generics (Generic)
import Hindsight
import Hindsight.Store.Memory (MemoryStore, newMemoryStore)
\end{code}

Define a Simple Event
---------------------

\begin{code}
type CounterIncremented = "counter_incremented"

data IncrementInfo = IncrementInfo
  { counterId :: Text
  , amount :: Int
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)

-- Event versioning
type instance MaxVersion CounterIncremented = 0
type instance Versions CounterIncremented = FirstVersion IncrementInfo
instance Event CounterIncremented
instance UpgradableToLatest CounterIncremented 0 where
  upgradeToLatest = id

-- Helper
increment :: Text -> Int -> SomeLatestEvent
increment cid amt =
  mkEvent CounterIncremented (IncrementInfo cid amt)
\end{code}

Pattern 1: Any (No Checking)
-----------------------------

`Any` means "accept any version, don't check for conflicts":

\begin{code}
demoAny :: IO ()
demoAny = do
  putStrLn "=== Pattern: Any ==="

  store <- newMemoryStore
  streamId <- StreamId <$> UUID.nextRandom

  -- First insert - Any always succeeds
  result1 <- insertEvents store Nothing $
    Map.singleton streamId (StreamEventBatch Any [increment "C1" 1])

  putStrLn $ "  First insert: " <> case result1 of
    SuccessfulInsertion _ -> "✓ Success"
    FailedInsertion err -> "✗ Failed: " <> show err

  -- Second insert - Any always succeeds (no version check)
  result2 <- insertEvents store Nothing $
    Map.singleton streamId (StreamEventBatch Any [increment "C1" 2])

  putStrLn $ "  Second insert: " <> case result2 of
    SuccessfulInsertion _ -> "✓ Success (no conflict check)"
    FailedInsertion err -> "✗ Failed: " <> show err

  putStrLn "  → Use 'Any' when you don't care about conflicts\n"
\end{code}

Pattern 2: NoStream (Must Be New)
----------------------------------

`NoStream` means "this stream must NOT exist yet":

\begin{code}
demoNoStream :: IO ()
demoNoStream = do
  putStrLn "=== Pattern: NoStream ==="

  store <- newMemoryStore
  streamId <- StreamId <$> UUID.nextRandom

  -- First insert - succeeds (stream doesn't exist)
  result1 <- insertEvents store Nothing $
    Map.singleton streamId (StreamEventBatch NoStream [increment "C2" 1])

  putStrLn $ "  First insert: " <> case result1 of
    SuccessfulInsertion _ -> "✓ Success (stream created)"
    FailedInsertion err -> "✗ Failed: " <> show err

  -- Second insert - FAILS (stream now exists!)
  result2 <- insertEvents store Nothing $
    Map.singleton streamId (StreamEventBatch NoStream [increment "C2" 2])

  putStrLn $ "  Second insert: " <> case result2 of
    SuccessfulInsertion _ -> "✓ Success"
    FailedInsertion (ConsistencyError _) -> "✗ Failed (stream already exists) ← Expected!"
    FailedInsertion err -> "✗ Failed: " <> show err

  putStrLn "  → Use 'NoStream' for stream creation\n"
\end{code}

Pattern 3: ExactVersion (Optimistic Locking)
---------------------------------------------

`ExactVersion n` means "the stream must be at exactly version n":

\begin{code}
demoExactVersion :: IO ()
demoExactVersion = do
  putStrLn "=== Pattern: ExactVersion ==="

  store <- newMemoryStore
  streamId <- StreamId <$> UUID.nextRandom

  -- Create the stream (version will be 0 after this)
  result1 <- insertEvents store Nothing $
    Map.singleton streamId (StreamEventBatch NoStream [increment "C3" 1])

  case result1 of
    SuccessfulInsertion cursor -> do
      putStrLn $ "  Created stream, cursor: " <> show cursor

      -- Append expecting the cursor we just got
      result2 <- insertEvents store Nothing $
        Map.singleton streamId (StreamEventBatch (ExactVersion cursor) [increment "C3" 2])

      case result2 of
        SuccessfulInsertion cursor2 -> do
          putStrLn $ "  Append at cursor: ✓ Success"

          -- Try to append at old cursor again - FAILS (stream moved forward)
          result3 <- insertEvents store Nothing $
            Map.singleton streamId (StreamEventBatch (ExactVersion cursor) [increment "C3" 3])

          putStrLn $ "  Append at old cursor: " <> case result3 of
            SuccessfulInsertion _ -> "✓ Success"
            FailedInsertion (ConsistencyError _) -> "✗ Failed (wrong version) ← Expected!"
            FailedInsertion err -> "✗ Failed: " <> show err

        FailedInsertion err ->
          putStrLn $ "  ✗ Append failed: " <> show err

    FailedInsertion err ->
      putStrLn $ "  ✗ Initial insert failed: " <> show err

  putStrLn "  → Use 'ExactVersion' for optimistic locking\n"
\end{code}

Real-World Pattern: Read-Modify-Write
--------------------------------------

A common pattern using optimistic locking:

\begin{code}
{-
readModifyWrite :: IO ()
readModifyWrite = do
  -- 1. Read current stream state
  (currentVersion, events) <- readStream streamId

  -- 2. Compute new event based on current state
  let newEvent = computeNewEvent events

  -- 3. Try to append, expecting the version we read
  result <- insertEvents store Nothing $
    Map.singleton streamId (StreamEventBatch (ExactVersion currentVersion) [newEvent])

  case result of
    SuccessfulInsertion _ ->
      -- Success! Our update was based on current state
      pure ()
    FailedInsertion (ConsistencyError _) ->
      -- Someone else modified the stream. Retry!
      readModifyWrite
    FailedInsertion err ->
      -- Other error
      handleError err
-}
\end{code}

Running the Examples
-------------------

\begin{code}
main :: IO ()
main = do
  putStrLn "=== Hindsight Tutorial 05: Consistency Patterns ==="
  putStrLn ""

  demoAny
  demoNoStream
  demoExactVersion

  putStrLn "Tutorial complete!"
\end{code}

Summary
-------

**Stream Expectations**:

- `Any`: No version checking (fast, no conflict protection)
- `NoStream`: Ensure stream is being created (idempotent creates)
- `ExactVersion n`: Optimistic locking (retry on conflict)

**When to Use**:

- **Any**: Logging, metrics, events where order doesn't matter critically
- **NoStream**: Creating aggregates, ensuring single creation
- **ExactVersion**: Bank accounts, inventory, any state where conflicts matter

**Pattern**: Read → Compute → Write with ExactVersion → Retry on conflict

Next Steps
----------

In the next tutorial, we'll explore **backend-agnostic code** - writing
application logic that works with any storage backend.
