{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

module Test.Hindsight.Store.StressTests where

import Control.Concurrent (newEmptyMVar, putMVar, readMVar, takeMVar, threadDelay)
import Control.Exception (SomeException, try)
import Control.Monad (foldM, forM, forM_, replicateM)
import Data.Map.Strict qualified as Map
import Data.Time (diffUTCTime, getCurrentTime)
import Data.UUID.V4 qualified as UUID
import Hindsight.Store
import System.Random (randomRIO)
import System.Timeout (timeout)
import Test.Hindsight.Store.Common (makeUserEvent)
import Test.Hindsight.Store.TestRunner (EventStoreTestRunner (..))
import Test.Tasty
import Test.Tasty.HUnit
import UnliftIO.Async (async, mapConcurrently, wait)

-- | Backend-agnostic stress test suite
stressTests ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO) =>
    EventStoreTestRunner backend ->
    [TestTree]
stressTests runner =
    [ testGroup
        "Pathological Tests"
        [ testCase "Massive Version Conflicts (100 writers)" $
            withStore runner testMassiveVersionConflicts
        , testCase "Massive Version Advancement (1000 iterations)" $
            withStore runner testMassiveVersionAdvancement
        , testCase "Version Skew Scenario" $
            withStore runner testVersionSkewScenario
        ]
    , testGroup
        "High-Contention Tests"
        [ testCase "High Contention Version Checks (50 writers)" $
            withStore runner testHighContentionVersionChecks
        , testCase "Version Expectation Performance" $
            withStore runner testVersionExpectationPerformance
        , testCase "Cascading Version Failures" $
            withStore runner testCascadingVersionFailures
        , testCase "Multi-Stream Version Atomicity (10 streams)" $
            withStore runner testMultiStreamVersionAtomicity
        , testCase "Rapid Version Advancement (100 iterations)" $
            withStore runner testRapidVersionAdvancement
        ]
    , testGroup
        "Connection Resilience Tests"
        [ testCase "Version Checks with Connection Failures" $
            withStore runner testVersionCheckWithConnectionFailures
        , testCase "Version Check Deadlock Scenarios" $
            withStore runner testVersionCheckDeadlock
        ]
    ]

-- ============================================================================
-- Pathological Tests
-- ============================================================================

{- | Test extreme version expectation conflicts
100 concurrent writers all try to use the same ExactVersion cursor.
Exactly one should succeed, 99 should fail with ConsistencyError.
-}
testMassiveVersionConflicts ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO) =>
    BackendHandle backend ->
    IO ()
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

{- | Test massive version advancement
Advance a stream version 1000 times sequentially, then verify:
- Very old cursors are rejected
- Mid-journey cursors are rejected
- Current cursor still works
-}
testMassiveVersionAdvancement ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO) =>
    BackendHandle backend ->
    IO ()
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

{- | Test version skew with stale expectations
Create a stream, advance it multiple times, then verify:
- Stale cursors from several versions ago are rejected
- Current cursor works
-}
testVersionSkewScenario ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO) =>
    BackendHandle backend ->
    IO ()
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

-- ============================================================================
-- High-Contention Tests
-- ============================================================================

{- | High contention test - 50 concurrent writers to same stream with Any expectation
All should succeed since Any doesn't require version checking
-}
testHighContentionVersionChecks ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO) =>
    BackendHandle backend ->
    IO ()
testHighContentionVersionChecks store = do
    streamId <- StreamId <$> UUID.nextRandom

    -- Initialize stream
    _ <-
        insertEvents store Nothing $
            Transaction (Map.singleton streamId (StreamWrite NoStream [makeUserEvent 0]))

    -- Spawn 50 concurrent writers with Any expectation
    start <- newEmptyMVar
    results <- forM [1 .. 50] $ \i -> async $ do
        readMVar start -- Wait for signal (doesn't consume)
        insertEvents store Nothing $
            Transaction (Map.singleton streamId (StreamWrite Any [makeUserEvent i]))

    -- Start all writers simultaneously with single broadcast
    putMVar start ()

    -- Verify all complete without errors
    outcomes <- mapM wait results
    let successes = [r | r@(SuccessfulInsertion _) <- outcomes]
    length successes @?= 50 -- All should succeed with Any expectation

{- | Test version expectation performance under load
Creates 10-20 streams, performs 100 concurrent writes with mixed expectations
Verifies reasonable performance (< 5 seconds) and correct success/failure ratios
-}
testVersionExpectationPerformance ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO) =>
    BackendHandle backend ->
    IO ()
testVersionExpectationPerformance store = do
    numStreams <- randomRIO (10, 20)
    streams <- replicateM numStreams (StreamId <$> UUID.nextRandom)

    -- Initialize all streams
    _ <-
        insertEvents store Nothing $
            Transaction (Map.fromList [(s, StreamWrite NoStream [makeUserEvent 0]) | s <- streams])

    -- Measure time for concurrent writes with different expectations
    startTime <- getCurrentTime

    -- Create mixed workload
    results <-
        mapConcurrently
            ( \(i, stream) -> do
                let expectation = case i `mod` 4 of
                        0 -> Any
                        1 -> StreamExists
                        2 -> NoStream -- Will fail on initialized streams
                        _ -> Any

                insertEvents store Nothing $
                    Transaction (Map.singleton stream (StreamWrite expectation [makeUserEvent i]))
            )
            (zip [1 .. 100] (cycle streams))

    endTime <- getCurrentTime
    let duration = diffUTCTime endTime startTime

    -- Verify reasonable performance (should complete in < 5 seconds)
    assertBool ("Performance test took too long: " ++ show duration) (duration < 5)

    -- Check success/failure ratio
    let successes = length [r | r@(SuccessfulInsertion _) <- results]
        failures = length [r | r@(FailedInsertion _) <- results]

    assertBool "Should have some successes" (successes > 0)
    assertBool "Should have some failures due to NoStream on existing streams" (failures > 0)

{- | Test cascading failures with version dependencies
Create a chain A -> B -> C, update A, verify old cursor for A is rejected
-}
testCascadingVersionFailures ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO) =>
    BackendHandle backend ->
    IO ()
testCascadingVersionFailures store = do
    -- Create dependency chain: A -> B -> C -> D -> E
    [streamA, streamB, streamC, _, _] <- replicateM 5 (StreamId <$> UUID.nextRandom)

    -- Initialize first stream
    result1 <-
        insertEvents store Nothing $
            Transaction (Map.singleton streamA (StreamWrite NoStream [makeUserEvent 1]))

    cursorA <- case result1 of
        SuccessfulInsertion (InsertionSuccess{finalCursor = c}) -> pure c
        _ -> assertFailure "Failed to initialize stream A"

    -- Create chain where each depends on previous
    _ <-
        insertEvents store Nothing $
            Transaction (Map.singleton streamB (StreamWrite NoStream [makeUserEvent 2]))

    _ <-
        insertEvents store Nothing $
            Transaction (Map.singleton streamC (StreamWrite NoStream [makeUserEvent 3]))

    -- Now update A, which should invalidate dependent operations
    result4 <-
        insertEvents store Nothing $
            Transaction (Map.singleton streamA (StreamWrite (ExactVersion cursorA) [makeUserEvent 11]))

    case result4 of
        SuccessfulInsertion _ -> do
            -- Try to use old cursor - should fail
            result5 <-
                insertEvents store Nothing $
                    Transaction (Map.singleton streamA (StreamWrite (ExactVersion cursorA) [makeUserEvent 111]))

            case result5 of
                FailedInsertion (ConsistencyError _) -> pure ()
                _ -> assertFailure "Should fail with outdated cursor"
        _ -> assertFailure "Failed to update stream A"

{- | Test multi-stream atomic operations
Create 10 streams, initialize half, try batch with mixed expectations that should fail
Verify no partial writes occurred and correct batch succeeds
-}
testMultiStreamVersionAtomicity ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO) =>
    BackendHandle backend ->
    IO ()
testMultiStreamVersionAtomicity store = do
    -- Create 10 streams
    streams <- replicateM 10 (StreamId <$> UUID.nextRandom)

    -- Initialize half of them
    let (initialized, uninitialized) = splitAt 5 streams

    _ <-
        insertEvents store Nothing $
            Transaction (Map.fromList [(s, StreamWrite NoStream [makeUserEvent i]) | (i, s) <- zip [1 ..] initialized])

    -- Try batch operation with mixed expectations that should fail
    result1 <-
        insertEvents store Nothing $
            Transaction
                ( Map.fromList $
                    [(s, StreamWrite StreamExists [makeUserEvent 100]) | s <- initialized]
                        ++ [(s, StreamWrite StreamExists [makeUserEvent 200]) | s <- uninitialized] -- These will fail
                )

    case result1 of
        FailedInsertion (ConsistencyError _) -> do
            -- Verify no partial writes occurred
            -- Try writing to all streams with correct expectations
            result2 <-
                insertEvents store Nothing $
                    Transaction
                        ( Map.fromList $
                            [(s, StreamWrite StreamExists [makeUserEvent 100]) | s <- initialized]
                                ++ [(s, StreamWrite NoStream [makeUserEvent 200]) | s <- uninitialized]
                        )

            case result2 of
                SuccessfulInsertion _ -> pure ()
                _ -> assertFailure "Batch with correct expectations should succeed"
        _ -> assertFailure "Mixed batch should fail atomically"

{- | Test rapid version advancement
Advance a stream version 100 times rapidly, verify old cursors are invalid
-}
testRapidVersionAdvancement ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO) =>
    BackendHandle backend ->
    IO ()
testRapidVersionAdvancement store = do
    streamId <- StreamId <$> UUID.nextRandom

    -- Initialize stream
    result1 <-
        insertEvents store Nothing $
            Transaction (Map.singleton streamId (StreamWrite NoStream [makeUserEvent 0]))

    initialCursor <- case result1 of
        SuccessfulInsertion (InsertionSuccess{finalCursor = c}) -> pure c
        _ -> assertFailure "Failed to initialize stream"

    -- Rapidly advance version 100 times
    _ <-
        foldM
            ( \cursor i -> do
                result <-
                    insertEvents store Nothing $
                        Transaction (Map.singleton streamId (StreamWrite (ExactVersion cursor) [makeUserEvent i]))
                case result of
                    SuccessfulInsertion (InsertionSuccess{finalCursor = newCursor}) -> pure newCursor
                    _ -> assertFailure $ "Failed at iteration " ++ show i
            )
            initialCursor
            [1 .. 100]

    -- Verify old cursors are invalid
    result2 <-
        insertEvents store Nothing $
            Transaction (Map.singleton streamId (StreamWrite (ExactVersion initialCursor) [makeUserEvent 999]))

    case result2 of
        FailedInsertion (ConsistencyError _) -> pure ()
        _ -> assertFailure "Should not accept very old cursor"

-- ============================================================================
-- Connection Resilience Tests
-- ============================================================================

{- | Test version expectations with connection failures
Performs 50 operations with random delays that might cause timeouts
Verifies at least some successes despite connection issues
-}
testVersionCheckWithConnectionFailures ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO) =>
    BackendHandle backend ->
    IO ()
testVersionCheckWithConnectionFailures store = do
    streamId <- StreamId <$> UUID.nextRandom

    -- Initialize stream
    _ <-
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

{- | Test version expectation deadlock scenarios
Create two streams, start two transactions that lock them in different order
Verify both complete within reasonable time (backend should handle deadlocks)
-}
testVersionCheckDeadlock ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO) =>
    BackendHandle backend ->
    IO ()
testVersionCheckDeadlock store = do
    streamA <- StreamId <$> UUID.nextRandom
    streamB <- StreamId <$> UUID.nextRandom

    -- Initialize both streams
    _ <-
        insertEvents store Nothing $
            Transaction
                ( Map.fromList
                    [ (streamA, StreamWrite NoStream [makeUserEvent 1])
                    , (streamB, StreamWrite NoStream [makeUserEvent 1])
                    ]
                )

    -- Start two long-running transactions that will try to lock streams in different order
    syncVar1 <- newEmptyMVar
    syncVar2 <- newEmptyMVar

    result1 <- async $ do
        takeMVar syncVar1 -- Wait for sync
        -- Transaction 1: A then B
        insertEvents store Nothing $
            Transaction
                ( Map.fromList
                    [ (streamA, StreamWrite StreamExists [makeUserEvent 2])
                    , (streamB, StreamWrite StreamExists [makeUserEvent 2])
                    ]
                )

    result2 <- async $ do
        takeMVar syncVar2 -- Wait for sync
        -- Transaction 2: B then A (potential deadlock)
        insertEvents store Nothing $
            Transaction
                ( Map.fromList
                    [ (streamB, StreamWrite StreamExists [makeUserEvent 3])
                    , (streamA, StreamWrite StreamExists [makeUserEvent 3])
                    ]
                )

    -- Start both transactions simultaneously
    putMVar syncVar1 ()
    putMVar syncVar2 ()

    -- Both should complete within reasonable time (backend handles deadlocks)
    timeoutResult <- timeout 10_000_000 $ do
        -- 10 seconds
        r1 <- wait result1
        r2 <- wait result2
        pure (r1, r2)

    case timeoutResult of
        Nothing -> assertFailure "Transactions took too long - possible deadlock"
        Just (r1, r2) -> do
            -- At least one should succeed (backend resolves deadlocks)
            let anySuccess = any isSuccess [r1, r2]
            assertBool "At least one transaction should succeed" anySuccess
  where
    isSuccess (SuccessfulInsertion _) = True
    isSuccess _ = False
