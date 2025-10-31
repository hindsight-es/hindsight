{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

{- | Consistency and version expectation tests

Tests critical consistency guarantees:
- Stream creation conditions (NoStream, StreamExists)
- Version-based optimistic locking (ExactVersion, ExactStreamVersion)
- Concurrent write conflicts
- Batch transaction atomicity
- Multi-stream consistency
- Version expectation race conditions
- Empty batch handling
-}
module Test.Hindsight.Store.ConsistencyTests (consistencyTests) where

import Control.Concurrent (MVar, newEmptyMVar, putMVar, takeMVar)
import Control.Monad (forM, forM_, replicateM, replicateM_)
import Data.Map.Strict qualified as Map
import Data.UUID.V4 qualified as UUID
import Hindsight.Events (SomeLatestEvent)
import Hindsight.Store
import Test.Hindsight.Examples (makeUserEvent)
import Test.Hindsight.Store.TestRunner (EventStoreTestRunner (..))
import Test.Tasty
import Test.Tasty.HUnit
import UnliftIO.Async (async, concurrently, wait)

-- | Consistency test suite for event store backends
consistencyTests ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO, Show (Cursor backend), Show (EventStoreError backend)) =>
    EventStoreTestRunner backend ->
    [TestTree]
consistencyTests runner =
    [ testCase "No Stream Condition" $ withStore runner testNoStreamCondition
    , testCase "Stream Exists Condition" $ withStore runner testStreamExistsCondition
    , testCase "Exact Version Condition" $ withStore runner testExactVersionCondition
    , testCase "Exact Stream Version Condition" $ withStore runner testExactStreamVersionCondition
    , testCase "Concurrent Writes" $ withStore runner testConcurrentWrites
    , testCase "Batch Atomicity" $ withStore runner testBatchAtomicity
    , testCase "Multi-Stream Consistency" $ withStore runner testMultiStreamConsistency
    , testCase "Version Expectation Race Condition" $ withStore runner testVersionExpectationRaceCondition
    , testCase "Any Expectation Concurrency" $ withStore runner testAnyExpectationConcurrency
    , testCase "Mixed Version Expectations" $ withStore runner testMixedVersionExpectations
    , testCase "Cascading Version Dependencies" $ withStore runner testCascadingVersionDependencies
    , testCase "Multi-Stream Head Consistency" $ withStore runner testMultiStreamHeadConsistency
    , testCase "Empty Batch Insertion" $ withStore runner testEmptyBatchInsertion
    , testCase "Mixed Empty and Non-Empty Streams" $ withStore runner testMixedEmptyStreams
    ]

-- * Test Implementations

testNoStreamCondition :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BackendHandle backend -> IO ()
testNoStreamCondition store = do
    streamId <- StreamId <$> UUID.nextRandom

    result1 <-
        insertEvents store Nothing $
            singleEvent streamId NoStream (makeUserEvent 1)

    case result1 of
        FailedInsertion err -> assertFailure $ "First write failed: " ++ show err
        SuccessfulInsertion _ -> do
            result2 <-
                insertEvents store Nothing $
                    singleEvent streamId NoStream (makeUserEvent 2)

            case result2 of
                FailedInsertion (ConsistencyError _) -> pure ()
                FailedInsertion err -> assertFailure $ "Unexpected error: " ++ show err
                SuccessfulInsertion _ -> assertFailure "Second write should have failed"

testStreamExistsCondition :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BackendHandle backend -> IO ()
testStreamExistsCondition store = do
    streamId <- StreamId <$> UUID.nextRandom

    result1 <-
        insertEvents store Nothing $
            appendAfterAny streamId (makeUserEvent 1)

    case result1 of
        FailedInsertion (ConsistencyError _) -> do
            _ <-
                insertEvents store Nothing $
                    singleEvent streamId NoStream (makeUserEvent 1)

            result2 <-
                insertEvents store Nothing $
                    appendAfterAny streamId (makeUserEvent 2)

            case result2 of
                FailedInsertion err -> assertFailure $ "Second write failed: " ++ show err
                SuccessfulInsertion _ -> pure ()
        FailedInsertion err -> assertFailure $ "Unexpected error: " ++ show err
        SuccessfulInsertion _ -> assertFailure "First write should have failed"

testExactVersionCondition :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BackendHandle backend -> IO ()
testExactVersionCondition store = do
    streamId <- StreamId <$> UUID.nextRandom

    SuccessfulInsertion (InsertionSuccess{finalCursor = initCursor}) <-
        insertEvents store Nothing $
            singleEvent streamId NoStream (makeUserEvent 42)

    result1 <-
        insertEvents store Nothing $
            singleEvent streamId StreamExists (makeUserEvent 1)

    case result1 of
        FailedInsertion err -> assertFailure $ "First write failed: " ++ show err
        SuccessfulInsertion (InsertionSuccess{finalCursor = cursor1}) -> do
            -- Write with wrong version should fail
            result2 <-
                insertEvents store Nothing $
                    singleEvent streamId (ExactVersion initCursor) (makeUserEvent 2)

            case result2 of
                FailedInsertion (ConsistencyError _) -> do
                    -- Write with correct version should succeed
                    result3 <-
                        insertEvents store Nothing $
                            singleEvent streamId (ExactVersion cursor1) (makeUserEvent 3)

                    case result3 of
                        FailedInsertion err -> assertFailure $ "Third write failed: " ++ show err
                        SuccessfulInsertion _ -> pure ()
                FailedInsertion err -> assertFailure $ "Unexpected error: " ++ show err
                SuccessfulInsertion _ -> assertFailure "Second write should have failed"

testExactStreamVersionCondition :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BackendHandle backend -> IO ()
testExactStreamVersionCondition store = do
    streamId <- StreamId <$> UUID.nextRandom

    -- Insert first event
    result1 <-
        insertEvents store Nothing $
            singleEvent streamId NoStream (makeUserEvent 1)

    case result1 of
        FailedInsertion err -> assertFailure $ "First write failed: " ++ show err
        SuccessfulInsertion _ -> do
            -- Try with correct stream version
            result2 <-
                insertEvents store Nothing $
                    singleEvent streamId (ExactStreamVersion (StreamVersion 1)) (makeUserEvent 2)

            case result2 of
                FailedInsertion err -> assertFailure $ "Second write with correct stream version failed: " ++ show err
                SuccessfulInsertion _ -> do
                    -- Try with wrong stream version (still expecting version 1)
                    result3 <-
                        insertEvents store Nothing $
                            singleEvent streamId (ExactStreamVersion (StreamVersion 1)) (makeUserEvent 3)

                    case result3 of
                        FailedInsertion (ConsistencyError _) -> pure ()
                        FailedInsertion err -> assertFailure $ "Unexpected error: " ++ show err
                        SuccessfulInsertion _ -> assertFailure "Third write should have failed with wrong stream version"

testConcurrentWrites :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BackendHandle backend -> IO ()
testConcurrentWrites store = do
    streamId <- StreamId <$> UUID.nextRandom

    -- Initialize stream
    result1 <-
        insertEvents store Nothing $
            singleEvent streamId NoStream (makeUserEvent 1)

    case result1 of
        FailedInsertion err -> assertFailure $ "Initial write failed: " ++ show err
        SuccessfulInsertion (InsertionSuccess{finalCursor = cursor}) -> do
            -- Attempt concurrent writes with same expected version
            (result2, result3) <-
                concurrently
                    ( insertEvents store Nothing $
                        singleEvent streamId (ExactVersion cursor) (makeUserEvent 2)
                    )
                    ( insertEvents store Nothing $
                        singleEvent streamId (ExactVersion cursor) (makeUserEvent 3)
                    )

            -- Exactly one write should succeed
            case (result2, result3) of
                (SuccessfulInsertion _, FailedInsertion (ConsistencyError _)) -> pure ()
                (FailedInsertion (ConsistencyError _), SuccessfulInsertion _) -> pure ()
                _ -> assertFailure "Expected exactly one write to succeed"

testBatchAtomicity :: forall backend. (EventStore backend, StoreConstraints backend IO) => BackendHandle backend -> IO ()
testBatchAtomicity store = do
    streamId1 <- StreamId <$> UUID.nextRandom
    streamId2 <- StreamId <$> UUID.nextRandom

    -- Initialize first stream
    _ <-
        insertEvents store Nothing $
            singleEvent streamId1 NoStream (makeUserEvent 1)

    -- Try batch write with one valid and one invalid condition
    result <-
        insertEvents store Nothing $
            fromWrites
                [ (streamId1, StreamWrite StreamExists [makeUserEvent 2])
                , (streamId2, StreamWrite StreamExists [makeUserEvent 3])
                ]

    -- Entire batch should fail
    case result of
        FailedInsertion (ConsistencyError _) -> pure ()
        _ -> assertFailure "Batch write should have failed completely"

testMultiStreamConsistency :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BackendHandle backend -> IO ()
testMultiStreamConsistency store = do
    streams@[streamId1, streamId2, streamId3] <- replicateM 3 (StreamId <$> UUID.nextRandom)

    -- Initialize streams with different versions
    let initWrites =
            Transaction
                ( Map.fromList $
                    zip streams $
                        map
                            (\i -> StreamWrite NoStream [makeUserEvent i])
                            [1 ..]
                )

    result1 <- insertEvents store Nothing initWrites

    case result1 of
        FailedInsertion err -> assertFailure $ "Initial writes failed: " ++ show err
        SuccessfulInsertion (InsertionSuccess{finalCursor = cursor}) -> do
            -- Try writing to all streams with mix of correct and incorrect versions
            let batch =
                    Transaction
                        ( Map.fromList
                            [ (streamId1, StreamWrite (ExactVersion cursor) [makeUserEvent 4])
                            , (streamId2, StreamWrite NoStream [makeUserEvent 5]) -- Should fail
                            , (streamId3, StreamWrite StreamExists [makeUserEvent 6])
                            ]
                        )

            result2 <- insertEvents store Nothing batch

            case result2 of
                FailedInsertion (ConsistencyError _) -> pure ()
                _ -> assertFailure "Mixed version batch should fail"

testVersionExpectationRaceCondition :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BackendHandle backend -> IO ()
testVersionExpectationRaceCondition store = do
    streamId <- StreamId <$> UUID.nextRandom

    -- Initialize stream
    result <-
        insertEvents store Nothing $
            singleEvent streamId NoStream (makeUserEvent 0)

    case result of
        FailedInsertion err -> assertFailure $ "Initial write failed: " ++ show err
        SuccessfulInsertion (InsertionSuccess{finalCursor = cursor}) -> do
            -- Race 10 writers all expecting the same version
            results <- forM [1 .. 10] $ \i -> async $ do
                insertEvents store Nothing $
                    singleEvent streamId (ExactVersion cursor) (makeUserEvent i)

            outcomes <- mapM wait results
            let successes = [r | r@(SuccessfulInsertion _) <- outcomes]
                failures = [r | r@(FailedInsertion _) <- outcomes]

            length successes @?= 1 -- Exactly one should succeed
            length failures @?= 9 -- All others should fail

            -- Verify all failures are consistency errors
            forM_ failures $ \case
                FailedInsertion (ConsistencyError _) -> pure ()
                _ -> assertFailure "Expected ConsistencyError for version conflict"

testAnyExpectationConcurrency :: forall backend. (EventStore backend, StoreConstraints backend IO) => BackendHandle backend -> IO ()
testAnyExpectationConcurrency store = do
    streamId <- StreamId <$> UUID.nextRandom

    -- Initialize stream
    _ <-
        insertEvents store Nothing $
            singleEvent streamId NoStream (makeUserEvent 0)

    -- Spawn 20 concurrent writers with Any expectation
    start <- newEmptyMVar
    results <- forM [1 .. 20] $ \i -> async $ do
        takeMVar start -- Wait for signal
        insertEvents store Nothing $
            singleEvent streamId Any (makeUserEvent i)

    -- Start all writers simultaneously
    replicateM_ 20 (putMVar start ())

    -- Verify all complete successfully
    outcomes <- mapM wait results
    let successes = [r | r@(SuccessfulInsertion _) <- outcomes]
    length successes @?= 20 -- All should succeed with Any expectation

testMixedVersionExpectations :: forall backend. (EventStore backend, StoreConstraints backend IO) => BackendHandle backend -> IO ()
testMixedVersionExpectations store = do
    -- Create 5 streams
    streams <- replicateM 5 (StreamId <$> UUID.nextRandom)

    -- Initialize some streams
    case streams of
        [s1, s2, s3, s4, s5] -> do
            _ <-
                insertEvents store Nothing $
                    Transaction
                        ( Map.fromList
                            [ (s1, StreamWrite NoStream [makeUserEvent 1])
                            , (s3, StreamWrite NoStream [makeUserEvent 3])
                            ]
                        )

            -- Try batch with mixed expectations
            result <-
                insertEvents store Nothing $
                    Transaction
                        ( Map.fromList
                            [ (s1, StreamWrite StreamExists [makeUserEvent 11]) -- Should succeed
                            , (s2, StreamWrite NoStream [makeUserEvent 12]) -- Should succeed
                            , (s3, StreamWrite (ExactStreamVersion (StreamVersion 2)) [makeUserEvent 13]) -- Should fail (wrong version)
                            , (s4, StreamWrite Any [makeUserEvent 14]) -- Would succeed if batch succeeds
                            , (s5, StreamWrite StreamExists [makeUserEvent 15]) -- Would fail (stream doesn't exist)
                            ]
                        )

            -- Entire batch should fail due to any failure
            case result of
                FailedInsertion (ConsistencyError _) -> pure ()
                _ -> assertFailure "Batch with mixed expectations should fail if any expectation fails"
        _ -> assertFailure "Expected exactly 5 streams"

testCascadingVersionDependencies :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (EventStoreError backend)) => BackendHandle backend -> IO ()
testCascadingVersionDependencies store = do
    -- Create a chain of 5 streams
    streams <- replicateM 5 (StreamId <$> UUID.nextRandom)

    -- Build dependency chain: each stream depends on previous
    cursors <- forM (zip [0 ..] streams) $ \(i, stream) -> do
        result <-
            insertEvents store Nothing $
                singleEvent stream NoStream (makeUserEvent i)
        case result of
            SuccessfulInsertion (InsertionSuccess{finalCursor = cursor}) -> pure (stream, cursor)
            FailedInsertion err -> assertFailure $ "Failed to create dependency chain: " ++ show err

    -- Now update middle of chain and verify dependencies
    case cursors of
        [(_, _), (_, _), (s3, c3), (_, _), (_, _)] -> do
            -- Update s3
            result1 <-
                insertEvents store Nothing $
                    singleEvent s3 (ExactVersion c3) (makeUserEvent 33)

            case result1 of
                FailedInsertion err -> assertFailure $ "Failed to update middle stream: " ++ show err
                SuccessfulInsertion _ -> do
                    -- Old cursor for s3 should now be invalid
                    result2 <-
                        insertEvents store Nothing $
                            singleEvent s3 (ExactVersion c3) (makeUserEvent 333)

                    case result2 of
                        FailedInsertion (ConsistencyError _) -> pure () -- Expected
                        _ -> assertFailure "Should not be able to use old cursor after update"
        _ -> assertFailure "Expected exactly 5 cursors"

{- | Test that stream heads are tracked correctly when multiple streams
are inserted in a single transaction. This is validated indirectly by
checking that each stream can be appended to independently after a multi-stream insert.
-}
testMultiStreamHeadConsistency :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BackendHandle backend -> IO ()
testMultiStreamHeadConsistency store = do
    -- Create three distinct streams
    streamA <- StreamId <$> UUID.nextRandom
    streamB <- StreamId <$> UUID.nextRandom
    streamC <- StreamId <$> UUID.nextRandom

    -- Insert multiple events for each stream in a SINGLE transaction
    -- Stream A: 2 events, Stream B: 3 events, Stream C: 1 event
    result <-
        insertEvents store Nothing $
            Transaction
                ( Map.fromList
                    [ (streamA, StreamWrite NoStream [makeUserEvent 1, makeUserEvent 2])
                    , (streamB, StreamWrite NoStream [makeUserEvent 10, makeUserEvent 20, makeUserEvent 30])
                    , (streamC, StreamWrite NoStream [makeUserEvent 100])
                    ]
                )

    case result of
        FailedInsertion err -> assertFailure $ "Failed to insert multi-stream batch: " ++ show err
        SuccessfulInsertion{} -> do
            -- Verify each stream can be appended to independently
            -- If stream heads are tracked correctly, StreamExists should work for all streams

            -- Append to stream A
            resultA <-
                insertEvents store Nothing $
                    singleEvent streamA StreamExists (makeUserEvent 3)

            case resultA of
                FailedInsertion err -> assertFailure $ "Failed to append to stream A (stream heads may be corrupted): " ++ show err
                SuccessfulInsertion _ -> do
                    -- Append to stream B
                    resultB <-
                        insertEvents store Nothing $
                            singleEvent streamB StreamExists (makeUserEvent 40)

                    case resultB of
                        FailedInsertion err -> assertFailure $ "Failed to append to stream B (stream heads may be corrupted): " ++ show err
                        SuccessfulInsertion _ -> do
                            -- Append to stream C
                            resultC <-
                                insertEvents store Nothing $
                                    singleEvent streamC StreamExists (makeUserEvent 200)

                            case resultC of
                                FailedInsertion err -> assertFailure $ "Failed to append to stream C (stream heads may be corrupted): " ++ show err
                                SuccessfulInsertion _ -> pure () -- All streams updated successfully

-- | Test that empty batch insertion is handled correctly
testEmptyBatchInsertion :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BackendHandle backend -> IO ()
testEmptyBatchInsertion store = do
    -- Try to insert completely empty batch
    result <- insertEvents store Nothing (Transaction (Map.empty :: Map.Map StreamId (StreamWrite [] SomeLatestEvent backend)))

    case result of
        FailedInsertion _ -> pure () -- Acceptable to reject empty batches
        SuccessfulInsertion _ -> do
            -- If we allow empty batches, cursor should be valid (no negative sequence numbers)
            -- Can't easily validate cursor structure across backends, but at least
            -- verify we can query with it
            streamId <- StreamId <$> UUID.nextRandom
            result2 <-
                insertEvents store Nothing $
                    appendToOrCreateStream streamId (makeUserEvent 1)
            case result2 of
                FailedInsertion err -> assertFailure $ "Failed follow-up insert after empty batch: " ++ show err
                SuccessfulInsertion _ -> pure ()

-- | Test that streams with zero events in a multi-stream batch are handled correctly
testMixedEmptyStreams :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BackendHandle backend -> IO ()
testMixedEmptyStreams store = do
    streamA <- StreamId <$> UUID.nextRandom
    streamB <- StreamId <$> UUID.nextRandom
    streamC <- StreamId <$> UUID.nextRandom

    -- Insert batch where one stream has zero events
    -- Stream A: 2 events, Stream B: 0 events, Stream C: 1 event
    result <-
        insertEvents store Nothing $
            Transaction
                ( Map.fromList
                    [ (streamA, StreamWrite NoStream [makeUserEvent 1, makeUserEvent 2])
                    , (streamB, StreamWrite NoStream [])
                    , (streamC, StreamWrite NoStream [makeUserEvent 100])
                    ]
                )

    case result of
        FailedInsertion err -> assertFailure $ "Failed to insert mixed empty/non-empty batch: " ++ show err
        SuccessfulInsertion _ -> do
            -- Verify stream B (empty) can be created
            resultB <-
                insertEvents store Nothing $
                    singleEvent streamB NoStream (makeUserEvent 10)

            case resultB of
                FailedInsertion err -> assertFailure $ "Stream B should not exist yet, but got error: " ++ show err
                SuccessfulInsertion _ -> do
                    -- Verify streams A and C can be appended to (they should exist)
                    resultA <-
                        insertEvents store Nothing $
                            singleEvent streamA StreamExists (makeUserEvent 3)

                    resultC <-
                        insertEvents store Nothing $
                            singleEvent streamC StreamExists (makeUserEvent 200)

                    case (resultA, resultC) of
                        (SuccessfulInsertion _, SuccessfulInsertion _) -> pure ()
                        _ -> assertFailure "Streams A and C should exist after mixed batch"
