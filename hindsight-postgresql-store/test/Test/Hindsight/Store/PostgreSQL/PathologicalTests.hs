{-# LANGUAGE DataKinds #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}

module Test.Hindsight.Store.PostgreSQL.PathologicalTests where

import Control.Concurrent (newEmptyMVar, putMVar, takeMVar, threadDelay)
import Control.Exception (SomeException, try)
import Control.Monad (foldM, forM, forM_, void)
import Data.Map.Strict qualified as Map
import Data.UUID.V4 qualified as UUID
import Hindsight.Store
import Hindsight.Store.PostgreSQL (SQLStoreHandle)
import System.Timeout (timeout)
import System.Random (randomRIO)
import Test.Hindsight.Store.Common (makeUserEvent)
import Test.Hindsight.PostgreSQL.Temp (debugMode, withTempPostgreSQL)
import Test.Tasty
import Test.Tasty.HUnit
import UnliftIO.Async (async, mapConcurrently, wait)

-- | Test extreme version expectation conflicts
testMassiveVersionConflicts :: SQLStoreHandle -> IO ()
testMassiveVersionConflicts store = do
  streamId <- StreamId <$> UUID.nextRandom

  -- Initialize stream
  result1 <-
    insertEvents store Nothing $
      Transaction (Map.singleton streamId (StreamWrite NoStream [makeUserEvent 0]))

  cursor <- case result1 of
    SuccessfulInsertion (InsertionSuccess{finalCursor = c}) -> pure c
    _ -> assertFailure "Failed to initialize stream"

  -- Have 100 writers all try to use the same exact version
  results <-
    mapConcurrently
      ( \i -> do
          -- Add random delay to increase contention
          delay <- randomRIO (0, 1000) -- 0-1ms
          threadDelay delay
          insertEvents store Nothing $
            Transaction (Map.singleton streamId (StreamWrite (ExactVersion cursor) [makeUserEvent i]))
      )
      [1 .. 100]

  -- Exactly one should succeed
  let successes = [r | r@(SuccessfulInsertion _) <- results]
      failures = [r | r@(FailedInsertion _) <- results]

  length successes @?= 1
  length failures @?= 99

  -- All failures should be consistency errors
  forM_ failures $ \case
    FailedInsertion (ConsistencyError _) -> pure ()
    _ -> assertFailure "Expected ConsistencyError"

-- | Test version expectation deadlock scenarios
testVersionCheckDeadlock :: SQLStoreHandle -> IO ()
testVersionCheckDeadlock store = do
  streamA <- StreamId <$> UUID.nextRandom
  streamB <- StreamId <$> UUID.nextRandom

  -- Initialize both streams
  void $
    insertEvents store Nothing $
      Transaction (Map.fromList
        [ (streamA, StreamWrite NoStream [makeUserEvent 1]),
          (streamB, StreamWrite NoStream [makeUserEvent 1])
        ])

  -- Start two long-running transactions that will try to lock streams in different order
  syncVar1 <- newEmptyMVar
  syncVar2 <- newEmptyMVar

  result1 <- async $ do
    takeMVar syncVar1 -- Wait for sync
    -- Transaction 1: A then B
    insertEvents store Nothing $
      Transaction (Map.fromList
        [ (streamA, StreamWrite StreamExists [makeUserEvent 2]),
          (streamB, StreamWrite StreamExists [makeUserEvent 2])
        ])

  result2 <- async $ do
    takeMVar syncVar2 -- Wait for sync
    -- Transaction 2: B then A (potential deadlock)
    insertEvents store Nothing $
      Transaction (Map.fromList
        [ (streamB, StreamWrite StreamExists [makeUserEvent 3]),
          (streamA, StreamWrite StreamExists [makeUserEvent 3])
        ])

  -- Start both transactions simultaneously
  putMVar syncVar1 ()
  putMVar syncVar2 ()

  -- Both should complete within reasonable time (PostgreSQL handles deadlocks)
  timeoutResult <- timeout 10_000_000 $ do
    -- 10 seconds
    r1 <- wait result1
    r2 <- wait result2
    pure (r1, r2)

  case timeoutResult of
    Nothing -> assertFailure "Transactions took too long - possible deadlock"
    Just (r1, r2) -> do
      -- At least one should succeed (PostgreSQL resolves deadlocks)
      let anySuccess = any isSuccess [r1, r2]
      assertBool "At least one transaction should succeed" anySuccess
  where
    isSuccess (SuccessfulInsertion _) = True
    isSuccess _ = False

-- | Test massive version advancement
testMassiveVersionAdvancement :: SQLStoreHandle -> IO ()
testMassiveVersionAdvancement store = do
  streamId <- StreamId <$> UUID.nextRandom

  -- Initialize stream
  result1 <-
    insertEvents store Nothing $
      Transaction (Map.singleton streamId (StreamWrite NoStream [makeUserEvent 0]))

  initialCursor <- case result1 of
    SuccessfulInsertion (InsertionSuccess{finalCursor = c}) -> pure c
    _ -> assertFailure "Failed to initialize stream"

  -- Rapidly advance version 1000 times, tracking a mid-cursor
  (finalCursor, midCursor) <-
    foldM
      ( \(cursor, savedMid) i -> do
          result <-
            insertEvents store Nothing $
              Transaction (Map.singleton streamId (StreamWrite (ExactVersion cursor) [makeUserEvent i]))
          case result of
            SuccessfulInsertion (InsertionSuccess{finalCursor = newCursor}) ->
              -- Save cursor at iteration 500 as our "mid cursor"
              if i == 500
                then pure (newCursor, Just newCursor)
                else pure (newCursor, savedMid)
            _ -> assertFailure $ "Failed at iteration " ++ show i
      )
      (initialCursor, Nothing)
      [1 .. 1000]

  -- Test that very old cursors are rejected
  result2 <-
    insertEvents store Nothing $
      Transaction (Map.singleton streamId (StreamWrite (ExactVersion initialCursor) [makeUserEvent 9999]))

  case result2 of
    FailedInsertion (ConsistencyError _) -> pure ()
    _ -> assertFailure "Should reject very old cursor"

  -- Test that slightly old cursors are also rejected
  case midCursor of
    Nothing -> assertFailure "Failed to capture mid cursor"
    Just actualMidCursor -> do
      result3 <-
        insertEvents store Nothing $
          Transaction (Map.singleton streamId (StreamWrite (ExactVersion actualMidCursor) [makeUserEvent 10000]))

      case result3 of
        FailedInsertion (ConsistencyError _) -> pure ()
        _ -> assertFailure "Should reject reused cursor"

  -- Verify that the final cursor still works
  result4 <-
    insertEvents store Nothing $
      Transaction (Map.singleton streamId (StreamWrite (ExactVersion finalCursor) [makeUserEvent 10001]))

  case result4 of
    SuccessfulInsertion _ -> pure ()
    _ -> assertFailure "Final cursor should still be valid"

-- | Test version expectations with connection failures
testVersionCheckWithConnectionFailures :: SQLStoreHandle -> IO ()
testVersionCheckWithConnectionFailures store = do
  streamId <- StreamId <$> UUID.nextRandom

  -- Initialize stream
  void $
    insertEvents store Nothing $
      Transaction (Map.singleton streamId (StreamWrite NoStream [makeUserEvent 0]))

  -- Perform many operations and some should handle connection issues gracefully
  results <- forM [1 .. 50] $ \i -> do
    -- Randomly inject delays that might cause timeouts
    delay <- randomRIO (0, 100)
    threadDelay delay

    tryResult <-
      try $
        insertEvents store Nothing $
          Transaction (Map.singleton streamId (StreamWrite Any [makeUserEvent i]))

    case tryResult of
      Left (_ :: SomeException) -> pure Nothing -- Connection error
      Right insertResult -> pure $ Just insertResult

  let successfulInserts = [r | Just r@(SuccessfulInsertion _) <- results]

  -- Should have at least some successes
  assertBool "Should have some successful inserts" (length successfulInserts > 10)

-- | Test version skew with stale expectations
testVersionSkewScenario :: SQLStoreHandle -> IO ()
testVersionSkewScenario store = do
  streamId <- StreamId <$> UUID.nextRandom

  -- Initialize stream
  result1 <-
    insertEvents store Nothing $
      Transaction (Map.singleton streamId (StreamWrite NoStream [makeUserEvent 0]))

  cursor1 <- case result1 of
    SuccessfulInsertion (InsertionSuccess{finalCursor = c}) -> pure c
    _ -> assertFailure "Failed to initialize stream"

  -- Advance the stream multiple times quickly
  cursors <-
    foldM
      ( \acc i -> do
          let lastCursor = last acc
          result <-
            insertEvents store Nothing $
              Transaction (Map.singleton streamId (StreamWrite (ExactVersion lastCursor) [makeUserEvent i]))
          case result of
            SuccessfulInsertion (InsertionSuccess{finalCursor = newCursor}) -> pure (acc ++ [newCursor])
            _ -> assertFailure $ "Failed to advance at " ++ show i
      )
      [cursor1]
      [1 .. 10]

  let currentCursor = last cursors
      staleCursor = cursors !! 2 -- Use a cursor from several versions ago

  -- Now try operations with stale cursor (should fail)
  result2 <-
    insertEvents store Nothing $
      Transaction (Map.singleton streamId (StreamWrite (ExactVersion staleCursor) [makeUserEvent 999]))

  case result2 of
    FailedInsertion (ConsistencyError _) -> pure ()
    _ -> assertFailure "Should reject stale cursor"

  -- But current cursor should work
  result3 <-
    insertEvents store Nothing $
      Transaction (Map.singleton streamId (StreamWrite (ExactVersion currentCursor) [makeUserEvent 1000]))

  case result3 of
    SuccessfulInsertion _ -> pure ()
    _ -> assertFailure "Current cursor should work"


-- | Pathological test suite
pathologicalTests :: TestTree
pathologicalTests =
  testGroup
    "Pathological Version Expectation Tests"
    [ testCase "Massive Version Conflicts" $ withTempPostgreSQL debugMode testMassiveVersionConflicts,
      testCase "Version Check Deadlock" $ withTempPostgreSQL debugMode testVersionCheckDeadlock,
      testCase "Massive Version Advancement" $ withTempPostgreSQL debugMode testMassiveVersionAdvancement,
      testCase "Connection Failures" $ withTempPostgreSQL debugMode testVersionCheckWithConnectionFailures,
      testCase "Version Skew Scenario" $ withTempPostgreSQL debugMode testVersionSkewScenario
    ]
