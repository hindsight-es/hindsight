{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}

module Test.Hindsight.Store.PostgreSQL.VersionStress where

import Control.Concurrent (newEmptyMVar, putMVar, readMVar)
import Control.Monad (foldM, forM, replicateM, void)
import Data.Map.Strict qualified as Map
import Data.Time (diffUTCTime, getCurrentTime)
import Data.UUID.V4 qualified as UUID
import Hindsight.Store
import Hindsight.Store.PostgreSQL (SQLStoreHandle)
import System.Random (randomRIO)
import Test.Hindsight.PostgreSQL.Temp (defaultConfig, withTempPostgreSQL)
import Test.Hindsight.Store.Common (makeUserEvent)
import Test.Tasty
import Test.Tasty.HUnit
import UnliftIO.Async (async, mapConcurrently, wait)

-- | High contention test - many writers to same stream
testHighContentionVersionChecks :: SQLStoreHandle -> IO ()
testHighContentionVersionChecks store = do
    streamId <- StreamId <$> UUID.nextRandom

    -- Initialize stream
    void $
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

-- | Test version expectation performance under load
testVersionExpectationPerformance :: SQLStoreHandle -> IO ()
testVersionExpectationPerformance store = do
    numStreams <- randomRIO (10, 20)
    streams <- replicateM numStreams (StreamId <$> UUID.nextRandom)

    -- Initialize all streams
    void $
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

-- | Test cascading failures with version dependencies
testCascadingVersionFailures :: SQLStoreHandle -> IO ()
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

-- | Test multi-stream atomic operations
testMultiStreamVersionAtomicity :: SQLStoreHandle -> IO ()
testMultiStreamVersionAtomicity store = do
    -- Create 10 streams
    streams <- replicateM 10 (StreamId <$> UUID.nextRandom)

    -- Initialize half of them
    let (initialized, uninitialized) = splitAt 5 streams

    void $
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

-- | Test rapid version advancement
testRapidVersionAdvancement :: SQLStoreHandle -> IO ()
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

-- | Stress test suite
versionStressTests :: TestTree
versionStressTests =
    testGroup
        "Version Expectation Stress Tests"
        [ testCase "High Contention Version Checks" $ withTempPostgreSQL defaultConfig testHighContentionVersionChecks
        , testCase "Version Expectation Performance" $ withTempPostgreSQL defaultConfig testVersionExpectationPerformance
        , testCase "Cascading Version Failures" $ withTempPostgreSQL defaultConfig testCascadingVersionFailures
        , testCase "Multi-Stream Version Atomicity" $ withTempPostgreSQL defaultConfig testMultiStreamVersionAtomicity
        , testCase "Rapid Version Advancement" $ withTempPostgreSQL defaultConfig testRapidVersionAdvancement
        ]
