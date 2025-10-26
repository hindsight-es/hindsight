{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Test.Hindsight.Store.TestRunner (
    -- * Test Infrastructure
    EventStoreTestRunner (..),
    runTest,
    runMultiInstanceTest,
    repeatTest,

    -- * Generic Test Suites
    genericEventStoreTests,
    multiInstanceTests,

    -- * Helper Functions
    collectEventsUntilTombstone,
    handleTombstone,
    extractUserInfo,
)
where

import Control.Concurrent (MVar, newEmptyMVar, putMVar, takeMVar, threadDelay)
import Control.Monad (forM, forM_, replicateM, replicateM_, when)
import Crypto.Hash (Digest, SHA256, hash)
import Data.ByteArray qualified as BA
import Data.Bits (shiftR)
import Data.ByteString (ByteString)
import Data.ByteString qualified as BS
import Data.ByteString.Lazy qualified as BSL
import Data.Int (Int64)
import Data.IORef
import Data.Map.Strict qualified as Map
import Data.Maybe (mapMaybe)
import Data.Proxy (Proxy (..))
import Data.Text (Text)
import Data.Typeable (cast)
import Data.UUID (toByteString)
import Data.UUID.V4 qualified as UUID
import Data.Word (Word8)
import Hindsight.Events (SomeLatestEvent)
import Hindsight.Store
import System.Random (randomRIO)
import System.Timeout (timeout)
import Test.Hindsight.Examples (UserCreated, UserInformation2 (..))
import Test.Hindsight.Store.Common
import Test.Tasty
import Test.Tasty.HUnit
import UnliftIO.Async (async, concurrently, forConcurrently, forConcurrently_, wait)
import UnliftIO.Exception (fromException, throwIO, tryAny)

-- | Test runner for event store tests
data EventStoreTestRunner backend = EventStoreTestRunner
    { withStore :: forall a. (BackendHandle backend -> IO a) -> IO ()
    , withStores :: forall a. Int -> ([BackendHandle backend] -> IO a) -> IO ()
    {- ^ For multi-instance tests: provides N handles to the same backend storage
    Simulates multiple processes accessing the same backend
    -}
    }

-- | Common event store test cases split into basic and consistency tests
genericEventStoreTests ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO, Show (Cursor backend), Ord (Cursor backend)) =>
    EventStoreTestRunner backend ->
    [TestTree]
genericEventStoreTests runner =
    [ testGroup
        "Basic Tests"
        [ testCase "Basic Event Reception" $ runTest runner (testBasicEventReception)
        , testCase "Correlation ID Preservation" $ runTest runner (testCorrelationIdPreservation)
        , testCase "Single Stream Selection" $ runTest runner (testSingleStreamSelection)
        , testCase "Start From Position" $ runTest runner (testStartFromPosition)
        , repeatTest 20 "Async Subscription Reception" $ runTest runner (testAsyncSubscription)
        , testCase "Subscription Honors Stop Result" $ runTest runner (testSubscriptionStopBehavior)
        , testCase "Handler Exception Enrichment" $ runTest runner (testHandlerExceptionEnrichment)
        ]
    , testGroup
        "Stream Version Tests"
        [ testCase "Stream Versions Start At 1" $ runTest runner (testStreamVersionsStartAt1)
        , testCase "Stream Versions Are Contiguous" $ runTest runner (testStreamVersionsContiguous)
        , testCase "Stream Versions Exposed In Subscription" $ runTest runner (testStreamVersionExposedInSubscription)
        , testCase "Multiple Streams Have Independent Versions" $ runTest runner (testIndependentStreamVersions)
        ]
    , testGroup
        "Consistency Tests"
        [ testCase "No Stream Condition" $ runTest runner (testNoStreamCondition)
        , testCase "Stream Exists Condition" $ runTest runner (testStreamExistsCondition)
        , testCase "Exact Version Condition" $ runTest runner (testExactVersionCondition)
        , testCase "Exact Stream Version Condition" $ runTest runner (testExactStreamVersionCondition)
        , testCase "Concurrent Writes" $ runTest runner (testConcurrentWrites)
        , testCase "Batch Atomicity" $ runTest runner (testBatchAtomicity)
        , testCase "Multi-Stream Consistency" $ runTest runner (testMultiStreamConsistency)
        , testCase "Version Expectation Race Condition" $ runTest runner (testVersionExpectationRaceCondition)
        , testCase "Any Expectation Concurrency" $ runTest runner (testAnyExpectationConcurrency)
        , testCase "Mixed Version Expectations" $ runTest runner (testMixedVersionExpectations)
        , testCase "Cascading Version Dependencies" $ runTest runner (testCascadingVersionDependencies)
        , testCase "Multi-Stream Head Consistency" $ runTest runner (testMultiStreamHeadConsistency)
        , testCase "Empty Batch Insertion" $ runTest runner (testEmptyBatchInsertion)
        , testCase "Mixed Empty and Non-Empty Streams" $ runTest runner (testMixedEmptyStreams)
        ]
    , testGroup
        "Per-Stream Cursor Tests"
        [ testCase "Per-Stream Cursor Extraction" $ runTest runner (testPerStreamCursorExtraction)
        , testCase "Cursor Independence" $ runTest runner (testCursorIndependence)
        , testCase "Stale Cursor Per Stream" $ runTest runner (testStaleCursorPerStream)
        , testCase "Cursor Completeness" $ runTest runner (testCursorCompleteness)
        , testCase "Empty Stream Cursor Handling" $ runTest runner (testEmptyStreamCursorHandling)
        ]
    ]

-- | Multi-instance test cases (for backends that support cross-process subscriptions)
multiInstanceTests ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) =>
    EventStoreTestRunner backend ->
    [TestTree]
multiInstanceTests runner =
    [ testGroup
        "Multi-Instance Tests"
        [ testCase "Multi-Instance Subscriptions (2 instances)" $ runMultiInstanceTest runner 2 (testMultiInstanceSubscription)
        , testCase "Multi-Instance Subscriptions (5 instances)" $ runMultiInstanceTest runner 5 (testMultiInstanceSubscription)
        , testCase "Multi-Instance Subscriptions (10 instances)" $ runMultiInstanceTest runner 10 (testMultiInstanceSubscription)
        ]
    , testGroup
        "Multi-Instance Event Ordering Tests (AllStreams)"
        [ testCase "Event Ordering AllStreams (2 instances, 5 events each)" $
            runMultiInstanceTest runner 2 (testMultiInstanceEventOrdering_AllStreams 5 2)
        , testCase "Event Ordering AllStreams (3 instances, 10 events each)" $
            runMultiInstanceTest runner 3 (testMultiInstanceEventOrdering_AllStreams 10 3)
        , testCase "Event Ordering AllStreams (5 instances, 20 events each)" $
            runMultiInstanceTest runner 5 (testMultiInstanceEventOrdering_AllStreams 20 5)
        ]
    , testGroup
        "Multi-Instance Event Ordering Tests (SingleStream)"
        [ testCase "Event Ordering SingleStream (2 instances, 5 events each)" $
            runMultiInstanceTest runner 2 (testMultiInstanceEventOrdering_SingleStream 5 2)
        , testCase "Event Ordering SingleStream (3 instances, 10 events each)" $
            runMultiInstanceTest runner 3 (testMultiInstanceEventOrdering_SingleStream 10 3)
        , testCase "Event Ordering SingleStream (5 instances, 20 events each)" $
            runMultiInstanceTest runner 5 (testMultiInstanceEventOrdering_SingleStream 20 5)
        ]
    ]

repeatTest :: Int -> TestName -> Assertion -> TestTree
repeatTest n name assertion =
    testGroup (name <> " x" <> show n) $
        replicate n $
            testCase name assertion

-- | Run a test with the test runner
runTest :: EventStoreTestRunner backend -> (BackendHandle backend -> IO ()) -> IO ()
runTest runner action = withStore runner action

-- | Run a multi-instance test with the test runner
runMultiInstanceTest :: EventStoreTestRunner backend -> Int -> ([BackendHandle backend] -> IO ()) -> IO ()
runMultiInstanceTest runner n action = withStores runner n action

-- | Helper functions
collectEventsUntilTombstone :: IORef [EventEnvelope UserCreated backend] -> EventHandler UserCreated IO backend
collectEventsUntilTombstone ref event = do
    atomicModifyIORef' ref (\events -> (event : events, ()))
    pure Continue

handleTombstone :: MVar () -> EventHandler Tombstone IO backend
handleTombstone completionVar _ = do
    putMVar completionVar ()
    pure Stop

extractUserInfo :: EventEnvelope UserCreated backend -> Maybe UserInformation2
extractUserInfo envelope = cast envelope.payload

-- Basic Test implementations --

testBasicEventReception :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BackendHandle backend -> IO ()
testBasicEventReception store = do
    streamId <- StreamId <$> UUID.nextRandom
    receivedEvents <- newIORef []
    completionVar <- newEmptyMVar

    let testEvents = map makeUserEvent [1 .. 3] ++ [makeTombstone]
    result <- insertEvents store Nothing (Transaction (Map.fromList [(streamId, StreamWrite Any testEvents)]))

    case result of
        FailedInsertion err -> assertFailure $ "Failed to insert events: " ++ show err
        SuccessfulInsertion _ -> do
            handle <-
                subscribe
                    store
                    ( match UserCreated (collectEventsUntilTombstone receivedEvents)
                        :? match Tombstone (handleTombstone completionVar)
                        :? MatchEnd
                    )
                    EventSelector{streamId = AllStreams, startupPosition = FromBeginning}

            takeMVar completionVar
            handle.cancel -- Cancel subscription after completion
            events <- reverse <$> readIORef receivedEvents
            length events @?= 3

            let userInfos = mapMaybe extractUserInfo events
            length userInfos @?= 3
            let userNames :: [Text]
                userNames = map userName userInfos
            userNames @?= ["user1", "user2", "user3"]

testSingleStreamSelection :: forall backend. (EventStore backend, StoreConstraints backend IO) => BackendHandle backend -> IO ()
testSingleStreamSelection store = do
    stream1 <- StreamId <$> UUID.nextRandom
    stream2 <- StreamId <$> UUID.nextRandom
    receivedEvents <- newIORef []
    completionVar <- newEmptyMVar

    _ <- insertEvents store Nothing (multiEvent stream1 Any (map makeUserEvent [1 .. 3]))
    _ <- insertEvents store Nothing (multiEvent stream2 Any (map makeUserEvent [4 .. 6]))
    _ <- insertEvents store Nothing (Transaction (Map.fromList [(stream1, StreamWrite Any [makeTombstone])]))

    handle <-
        subscribe
            store
            ( match UserCreated (collectEventsUntilTombstone receivedEvents)
                :? match Tombstone (handleTombstone completionVar)
                :? MatchEnd
            )
            EventSelector{streamId = SingleStream stream1, startupPosition = FromBeginning}

    takeMVar completionVar
    handle.cancel -- Cancel subscription after completion
    events <- reverse <$> readIORef receivedEvents
    let userInfos = mapMaybe extractUserInfo events
    length userInfos @?= 3
    let userNames = map userName userInfos
    userNames @?= ["user1", "user2", "user3"]

testStartFromPosition :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BackendHandle backend -> IO ()
testStartFromPosition store = do
    streamId <- StreamId <$> UUID.nextRandom
    let testEvents = map makeUserEvent [1 .. 5]

    result <- insertEvents store Nothing (Transaction (Map.fromList [(streamId, StreamWrite Any (take 3 testEvents))]))
    case result of
        FailedInsertion err -> assertFailure $ "Failed to insert first batch: " ++ show err
        SuccessfulInsertion (InsertionSuccess{finalCursor = cursor}) -> do
            _ <- insertEvents store Nothing (Transaction (Map.fromList [(streamId, StreamWrite Any (drop 3 testEvents))]))
            _ <- insertEvents store Nothing (Transaction (Map.fromList [(streamId, StreamWrite Any [makeTombstone])]))

            receivedEvents <- newIORef []
            completionVar <- newEmptyMVar

            handle <-
                subscribe
                    store
                    ( match UserCreated (collectEventsUntilTombstone receivedEvents)
                        :? match Tombstone (handleTombstone completionVar)
                        :? MatchEnd
                    )
                    EventSelector{streamId = AllStreams, startupPosition = FromLastProcessed cursor}

            takeMVar completionVar
            handle.cancel -- Cancel subscription after completion
            events <- reverse <$> readIORef receivedEvents
            let userInfos = mapMaybe extractUserInfo events
            length userInfos @?= 2
            let userNames :: [Text]
                userNames = map userName userInfos
            userNames @?= ["user4", "user5"]

testCorrelationIdPreservation :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BackendHandle backend -> IO ()
testCorrelationIdPreservation store = do
    streamId <- StreamId <$> UUID.nextRandom
    corrId <- CorrelationId <$> UUID.nextRandom
    receivedEvents <- newIORef []
    completionVar <- newEmptyMVar

    let testEvents = map makeUserEvent [1 .. 3] ++ [makeTombstone]
    result <- insertEvents store (Just corrId) (Transaction (Map.fromList [(streamId, StreamWrite Any testEvents)]))

    case result of
        FailedInsertion err -> assertFailure $ "Failed to insert events: " ++ show err
        SuccessfulInsertion _ -> do
            handle <-
                subscribe
                    store
                    ( match UserCreated (collectEventsUntilTombstone receivedEvents)
                        :? match Tombstone (handleTombstone completionVar)
                        :? MatchEnd
                    )
                    EventSelector{streamId = AllStreams, startupPosition = FromBeginning}

            takeMVar completionVar
            handle.cancel -- Cancel subscription after completion
            events <- readIORef receivedEvents
            mapM_ (\evt -> evt.correlationId @?= Just corrId) events

testAsyncSubscription :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BackendHandle backend -> IO ()
testAsyncSubscription store = do
    streamId <- StreamId <$> UUID.nextRandom
    receivedEvents <- newIORef []
    completionVar <- newEmptyMVar

    handle <-
        subscribe
            store
            ( match UserCreated (collectEventsUntilTombstone receivedEvents)
                :? match Tombstone (handleTombstone completionVar)
                :? MatchEnd
            )
            EventSelector{streamId = AllStreams, startupPosition = FromBeginning}

    let testEvents = map makeUserEvent [1 .. 3] ++ [makeTombstone]
    result <- insertEvents store Nothing (Transaction (Map.fromList [(streamId, StreamWrite Any testEvents)]))

    case result of
        FailedInsertion err -> do
            handle.cancel
            assertFailure $ "Failed to insert events: " ++ show err
        SuccessfulInsertion _ -> do
            takeMVar completionVar
            handle.cancel
            events <- reverse <$> readIORef receivedEvents
            length events @?= 3
            let userInfos = mapMaybe extractUserInfo events
            length userInfos @?= 3
            let userNames :: [Text]
                userNames = map userName userInfos
            userNames @?= ["user1", "user2", "user3"]

{- | Test that subscriptions honor the Stop result from handlers

This is a critical property: when a handler returns Stop, the subscription
must not process any subsequent events. This test verifies that all backends
correctly implement this behavior.

Test sequence:
  1. Insert: [Inc, Inc, Stop, Inc, Inc]
  2. Handler: increments counter on Inc, returns Stop on Stop event
  3. Expected: counter = 2 (stopped before processing the last two Incs)
-}
testSubscriptionStopBehavior :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BackendHandle backend -> IO ()
testSubscriptionStopBehavior store = do
    streamId <- StreamId <$> UUID.nextRandom
    counter <- newIORef (0 :: Int)
    completionVar <- newEmptyMVar

    -- Handler that increments counter and returns Continue
    let handleInc :: EventHandler CounterInc IO backend
        handleInc _ = do
            atomicModifyIORef' counter (\n -> (n + 1, ()))
            pure Continue

    -- Handler that returns Stop (signaling subscription should end)
    let handleStop :: EventHandler CounterStop IO backend
        handleStop _ = do
            putMVar completionVar ()
            pure Stop

    -- Start subscription before inserting events
    handle <-
        subscribe
            store
            ( match CounterInc handleInc
                :? match CounterStop handleStop
                :? MatchEnd
            )
            EventSelector{streamId = AllStreams, startupPosition = FromBeginning}

    -- Insert test sequence: 2 increments, then Stop, then 2 more increments
    let testEvents =
            [ makeCounterInc -- counter = 1
            , makeCounterInc -- counter = 2
            , makeCounterStop -- STOP HERE - should not process further
            , makeCounterInc -- should NOT be processed
            , makeCounterInc -- should NOT be processed
            ]

    result <- insertEvents store Nothing (Transaction (Map.fromList [(streamId, StreamWrite Any testEvents)]))

    case result of
        FailedInsertion err -> do
            handle.cancel
            assertFailure $ "Failed to insert events: " ++ show err
        SuccessfulInsertion _ -> do
            -- Wait for the Stop handler to signal completion
            takeMVar completionVar

            -- Give a small grace period to catch any erroneous event processing
            -- If the backend is broken, it might process events after Stop
            threadDelay 100000 -- 100ms
            handle.cancel

            -- Verify counter stopped at 2 (before the Stop event)
            finalCount <- readIORef counter
            finalCount @?= 2

{- | Test that handler exceptions enrich failures with event context

When a handler throws an exception, the subscription should die (fail-fast).
The exception should be enriched with full event metadata for debugging.

Test sequence:
  1. Insert: [Inc, Inc, Fail, Inc, Inc]
  2. Handler: increments counter on Inc, throws exception on Fail
  3. Expected: counter = 2, subscription dies with HandlerException containing event metadata
-}
testHandlerExceptionEnrichment :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BackendHandle backend -> IO ()
testHandlerExceptionEnrichment store = do
    streamId <- StreamId <$> UUID.nextRandom
    counter <- newIORef (0 :: Int)

    -- Handler that increments counter and returns Continue
    let handleInc :: EventHandler CounterInc IO backend
        handleInc _ = do
            atomicModifyIORef' counter (\n -> (n + 1, ()))
            pure Continue

    -- Handler that throws a test exception
    let handleFail :: EventHandler CounterFail IO backend
        handleFail _envelope = do
            throwIO $ userError "Test exception from CounterFail handler"

    -- Insert test sequence BEFORE starting subscription (to ensure events are ready)
    let testEvents =
            [ makeCounterInc -- counter = 1
            , makeCounterInc -- counter = 2
            , makeCounterFail -- EXCEPTION HERE - subscription should die
            , makeCounterInc -- should NOT be processed
            , makeCounterInc -- should NOT be processed
            ]

    result <- insertEvents store Nothing (Transaction (Map.fromList [(streamId, StreamWrite Any testEvents)]))

    case result of
        FailedInsertion err -> do
            assertFailure $ "Failed to insert events: " ++ show err
        SuccessfulInsertion _ -> do
            -- Start subscription AFTER inserting events
            handle <-
                subscribe
                    store
                    ( match CounterInc handleInc
                        :? match CounterFail handleFail
                        :? MatchEnd
                    )
                    EventSelector{streamId = AllStreams, startupPosition = FromBeginning}

            -- Wait for subscription to complete or fail
            waitResult <- tryAny handle.wait

            -- Verify counter stopped at 2 (subscription died on Fail event)
            finalCount <- readIORef counter
            finalCount @?= 2

            -- Verify the exception is a HandlerException with proper metadata
            case waitResult of
                Left exc -> case fromException exc of
                    Just (HandlerException{..}) -> do
                        -- Verify exception enrichment
                        failedEventName @?= "counter_fail"
                        show originalException @?= "user error (Test exception from CounterFail handler)"
                    Nothing -> assertFailure $ "Expected HandlerException, got: " ++ show exc
                Right () -> assertFailure "Expected subscription to fail with HandlerException"

-- Consistency Test implementations --

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

-- Stream version condition tests --

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

-- Per-Stream Cursor Test implementations --

{- | Test that per-stream cursors can be extracted from multi-stream transactions
and used for optimistic locking on specific streams.

This is the core use case from Tutorial 08: when inserting events to multiple
streams in a single transaction, we need to get back individual cursors for
each stream to use in subsequent optimistic locking operations.
-}
testPerStreamCursorExtraction :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BackendHandle backend -> IO ()
testPerStreamCursorExtraction store = do
    streamA <- StreamId <$> UUID.nextRandom
    streamB <- StreamId <$> UUID.nextRandom
    streamC <- StreamId <$> UUID.nextRandom

    -- Multi-stream transaction
    result1 <-
        insertEvents store Nothing $
            Transaction
                ( Map.fromList
                    [ (streamA, StreamWrite NoStream [makeUserEvent 1])
                    , (streamB, StreamWrite NoStream [makeUserEvent 10])
                    , (streamC, StreamWrite NoStream [makeUserEvent 100])
                    ]
                )

    case result1 of
        FailedInsertion err -> assertFailure $ "Initial multi-stream write failed: " ++ show err
        SuccessfulInsertion (InsertionSuccess{streamCursors}) -> do
            -- Extract cursor for stream A
            case Map.lookup streamA streamCursors of
                Nothing -> assertFailure "Stream A cursor missing from streamCursors"
                Just cursorA -> do
                    -- Use cursor A to append to stream A with optimistic locking
                    result2 <-
                        insertEvents store Nothing $
                            singleEvent streamA (ExactVersion cursorA) (makeUserEvent 2)

                    case result2 of
                        FailedInsertion err -> assertFailure $ "Append with stream A cursor failed: " ++ show err
                        SuccessfulInsertion _ -> do
                            -- Try to use the same cursor again - should fail (stale)
                            result3 <-
                                insertEvents store Nothing $
                                    singleEvent streamA (ExactVersion cursorA) (makeUserEvent 3)

                            case result3 of
                                FailedInsertion (ConsistencyError _) -> pure () -- Expected!
                                _ -> assertFailure "Should not be able to reuse stale cursor"

{- | Test that cursors for different streams are independent.

Updating stream A should not invalidate stream B's cursor. This is critical
for concurrent multi-stream operations where different processes may be
updating different streams.
-}
testCursorIndependence :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BackendHandle backend -> IO ()
testCursorIndependence store = do
    streamA <- StreamId <$> UUID.nextRandom
    streamB <- StreamId <$> UUID.nextRandom

    -- Tx1: Initialize both streams
    result1 <-
        insertEvents store Nothing $
            Transaction
                ( Map.fromList
                    [ (streamA, StreamWrite NoStream [makeUserEvent 1])
                    , (streamB, StreamWrite NoStream [makeUserEvent 10])
                    ]
                )

    case result1 of
        FailedInsertion err -> assertFailure $ "Initial write failed: " ++ show err
        SuccessfulInsertion (InsertionSuccess{streamCursors}) -> do
            case (Map.lookup streamA streamCursors, Map.lookup streamB streamCursors) of
                (Just cursorA, Just cursorB) -> do
                    -- Tx2: Update stream A (should NOT affect cursorB)
                    result2 <-
                        insertEvents store Nothing $
                            singleEvent streamA (ExactVersion cursorA) (makeUserEvent 2)

                    case result2 of
                        FailedInsertion err -> assertFailure $ "Stream A update failed: " ++ show err
                        SuccessfulInsertion _ -> do
                            -- Tx3: Use cursorB to append to stream B
                            -- This should succeed because stream B hasn't been modified
                            result3 <-
                                insertEvents store Nothing $
                                    singleEvent streamB (ExactVersion cursorB) (makeUserEvent 11)

                            case result3 of
                                FailedInsertion err ->
                                    assertFailure $ "Stream B cursor should still be valid after stream A update: " ++ show err
                                SuccessfulInsertion _ -> pure () -- Success! Independence verified
                _ -> assertFailure "Missing cursors from initial transaction"

{- | Test that using a stale cursor for one stream in a multi-stream transaction
causes the entire transaction to fail atomically.
-}
testStaleCursorPerStream :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BackendHandle backend -> IO ()
testStaleCursorPerStream store = do
    streamA <- StreamId <$> UUID.nextRandom
    streamB <- StreamId <$> UUID.nextRandom

    -- Initialize streams
    result1 <-
        insertEvents store Nothing $
            Transaction
                ( Map.fromList
                    [ (streamA, StreamWrite NoStream [makeUserEvent 1])
                    , (streamB, StreamWrite NoStream [makeUserEvent 10])
                    ]
                )

    case result1 of
        FailedInsertion err -> assertFailure $ "Initial write failed: " ++ show err
        SuccessfulInsertion (InsertionSuccess{streamCursors}) -> do
            case (Map.lookup streamA streamCursors, Map.lookup streamB streamCursors) of
                (Just cursorA, Just cursorB) -> do
                    -- Update stream A separately (makes cursorA stale)
                    result2 <-
                        insertEvents store Nothing $
                            singleEvent streamA (ExactVersion cursorA) (makeUserEvent 2)

                    case result2 of
                        FailedInsertion err -> assertFailure $ "Stream A update failed: " ++ show err
                        SuccessfulInsertion _ -> do
                            -- Try multi-stream transaction with stale cursorA
                            -- Even though cursorB is still valid, the transaction should fail
                            result3 <-
                                insertEvents store Nothing $
                                    Transaction
                                        ( Map.fromList
                                            [ (streamA, StreamWrite (ExactVersion cursorA) [makeUserEvent 3]) -- stale!
                                            , (streamB, StreamWrite (ExactVersion cursorB) [makeUserEvent 11]) -- valid
                                            ]
                                        )

                            case result3 of
                                FailedInsertion (ConsistencyError _) -> pure () -- Expected! Atomic failure
                                _ -> assertFailure "Transaction with stale cursor should fail atomically"
                _ -> assertFailure "Missing cursors from initial transaction"

{- | Test that all streams in a multi-stream transaction get cursors,
and that the cursors map is complete.
-}
testCursorCompleteness :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend), Ord (Cursor backend)) => BackendHandle backend -> IO ()
testCursorCompleteness store = do
    streamA <- StreamId <$> UUID.nextRandom
    streamB <- StreamId <$> UUID.nextRandom
    streamC <- StreamId <$> UUID.nextRandom

    -- Multi-stream transaction to 3 streams
    result <-
        insertEvents store Nothing $
            Transaction
                ( Map.fromList
                    [ (streamA, StreamWrite NoStream [makeUserEvent 1, makeUserEvent 2])
                    , (streamB, StreamWrite NoStream [makeUserEvent 10])
                    , (streamC, StreamWrite NoStream [makeUserEvent 100, makeUserEvent 101, makeUserEvent 102])
                    ]
                )

    case result of
        FailedInsertion err -> assertFailure $ "Multi-stream write failed: " ++ show err
        SuccessfulInsertion (InsertionSuccess{finalCursor, streamCursors}) -> do
            -- Verify all 3 streams have cursors
            Map.size streamCursors @?= 3

            -- Verify all stream IDs are present
            assertBool "Stream A missing from cursors" (Map.member streamA streamCursors)
            assertBool "Stream B missing from cursors" (Map.member streamB streamCursors)
            assertBool "Stream C missing from cursors" (Map.member streamC streamCursors)

            -- Verify ordering invariant: all stream cursors <= finalCursor
            forM_ (Map.toList streamCursors) $ \(sid, cursor) ->
                assertBool
                    ("Cursor for " ++ show sid ++ " violates ordering invariant")
                    (cursor <= finalCursor)

            -- Verify we can actually use each cursor
            case (Map.lookup streamA streamCursors, Map.lookup streamB streamCursors, Map.lookup streamC streamCursors) of
                (Just cursorA, Just cursorB, Just cursorC) -> do
                    -- Try using each cursor
                    resultA <- insertEvents store Nothing $ singleEvent streamA (ExactVersion cursorA) (makeUserEvent 3)
                    resultB <- insertEvents store Nothing $ singleEvent streamB (ExactVersion cursorB) (makeUserEvent 11)
                    resultC <- insertEvents store Nothing $ singleEvent streamC (ExactVersion cursorC) (makeUserEvent 103)

                    case (resultA, resultB, resultC) of
                        (SuccessfulInsertion _, SuccessfulInsertion _, SuccessfulInsertion _) -> pure ()
                        _ -> assertFailure "One or more stream cursors were not usable"
                _ -> assertFailure "Failed to extract all cursors from map"

{- | Test that streams with EMPTY event lists still get proper cursor handling
in multi-stream transactions. This is a critical edge case - implementations
might fail to track cursors for streams that have no events written.

The user specifically flagged this: "Check that we get the proper cursor event
for EMPTY stream writes - that's the kind of places where nasty stupid bugs may lie."
-}
testEmptyStreamCursorHandling :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BackendHandle backend -> IO ()
testEmptyStreamCursorHandling store = do
    streamA <- StreamId <$> UUID.nextRandom
    streamB <- StreamId <$> UUID.nextRandom
    streamC <- StreamId <$> UUID.nextRandom

    -- Multi-stream transaction with one EMPTY stream (streamB has no events)
    result <-
        insertEvents store Nothing $
            Transaction
                ( Map.fromList
                    [ (streamA, StreamWrite NoStream [makeUserEvent 1])
                    , (streamB, StreamWrite NoStream []) -- EMPTY! This is the edge case
                    , (streamC, StreamWrite NoStream [makeUserEvent 100])
                    ]
                )

    case result of
        FailedInsertion err -> assertFailure $ "Multi-stream with empty stream failed: " ++ show err
        SuccessfulInsertion (InsertionSuccess{streamCursors}) -> do
            -- Critical question: Does streamB get a cursor even though it has no events?
            -- Behavior expectation: streamB should NOT appear in streamCursors because
            -- it didn't actually write any events. Only streams with events get cursors.

            -- Verify streams A and C have cursors (they have events)
            assertBool "Stream A should have cursor (has events)" (Map.member streamA streamCursors)
            assertBool "Stream C should have cursor (has events)" (Map.member streamC streamCursors)

            -- Verify streamB does NOT have cursor (no events written)
            -- An empty stream write is effectively a no-op
            case Map.lookup streamB streamCursors of
                Nothing -> do
                    -- Expected: streamB shouldn't get a cursor for empty write
                    -- Verify streamB stream doesn't exist (empty write is a no-op)
                    resultB <-
                        insertEvents store Nothing $
                            singleEvent streamB NoStream (makeUserEvent 10)

                    case resultB of
                        FailedInsertion err -> assertFailure $ "Stream B should not exist after empty write: " ++ show err
                        SuccessfulInsertion _ -> pure () -- Good! StreamB was never created
                Just cursorB -> do
                    -- Alternative behavior: backend gave cursor for empty stream
                    -- In this case, verify the cursor is still usable and stream was created
                    resultB <-
                        insertEvents store Nothing $
                            singleEvent streamB (ExactVersion cursorB) (makeUserEvent 10)

                    case resultB of
                        FailedInsertion err ->
                            assertFailure $ "If empty stream gets cursor, it should be usable: " ++ show err
                        SuccessfulInsertion _ -> pure () -- Alternative behavior is OK if consistent

-- Stream Version Test implementations --

-- | Test that stream versions start at 1
testStreamVersionsStartAt1 :: forall backend. (EventStore backend, StoreConstraints backend IO) => BackendHandle backend -> IO ()
testStreamVersionsStartAt1 store = do
    streamId <- StreamId <$> UUID.nextRandom
    receivedVersions <- newIORef []
    completionVar <- newEmptyMVar

    let collectVersions ref event = do
            atomicModifyIORef' ref (\versions -> (event.streamVersion : versions, ()))
            pure Continue

    -- Insert first event
    _ <- insertEvents store Nothing (Transaction (Map.fromList [(streamId, StreamWrite NoStream [makeUserEvent 1, makeTombstone])]))

    handle <-
        subscribe
            store
            ( match UserCreated (collectVersions receivedVersions)
                :? match Tombstone (handleTombstone completionVar)
                :? MatchEnd
            )
            EventSelector{streamId = SingleStream streamId, startupPosition = FromBeginning}

    takeMVar completionVar
    handle.cancel

    versions <- reverse <$> readIORef receivedVersions
    versions @?= [StreamVersion 1]

-- | Test that stream versions are contiguous (no gaps)
testStreamVersionsContiguous :: forall backend. (EventStore backend, StoreConstraints backend IO) => BackendHandle backend -> IO ()
testStreamVersionsContiguous store = do
    streamId <- StreamId <$> UUID.nextRandom
    receivedVersions <- newIORef []
    completionVar <- newEmptyMVar

    let collectVersions ref event = do
            atomicModifyIORef' ref (\versions -> (event.streamVersion : versions, ()))
            pure Continue

    -- Insert 5 events in multiple batches
    _ <- insertEvents store Nothing (Transaction (Map.fromList [(streamId, StreamWrite NoStream [makeUserEvent 1, makeUserEvent 2])]))
    _ <- insertEvents store Nothing (Transaction (Map.fromList [(streamId, StreamWrite StreamExists [makeUserEvent 3])]))
    _ <- insertEvents store Nothing (Transaction (Map.fromList [(streamId, StreamWrite StreamExists [makeUserEvent 4, makeUserEvent 5, makeTombstone])]))

    handle <-
        subscribe
            store
            ( match UserCreated (collectVersions receivedVersions)
                :? match Tombstone (handleTombstone completionVar)
                :? MatchEnd
            )
            EventSelector{streamId = SingleStream streamId, startupPosition = FromBeginning}

    takeMVar completionVar
    handle.cancel

    versions <- reverse <$> readIORef receivedVersions
    -- Should be contiguous: 1, 2, 3, 4, 5
    versions @?= [StreamVersion 1, StreamVersion 2, StreamVersion 3, StreamVersion 4, StreamVersion 5]

-- | Test that stream versions are exposed in subscriptions
testStreamVersionExposedInSubscription :: forall backend. (EventStore backend, StoreConstraints backend IO) => BackendHandle backend -> IO ()
testStreamVersionExposedInSubscription store = do
    streamId <- StreamId <$> UUID.nextRandom
    receivedVersionRef <- newIORef Nothing
    completionVar <- newEmptyMVar

    let captureVersion ref event = do
            atomicModifyIORef' ref (\_ -> (Just event.streamVersion, ()))
            pure Continue

    _ <- insertEvents store Nothing (Transaction (Map.fromList [(streamId, StreamWrite NoStream [makeUserEvent 1, makeTombstone])]))

    handle <-
        subscribe
            store
            ( match UserCreated (captureVersion receivedVersionRef)
                :? match Tombstone (handleTombstone completionVar)
                :? MatchEnd
            )
            EventSelector{streamId = SingleStream streamId, startupPosition = FromBeginning}

    takeMVar completionVar
    handle.cancel

    mbVersion <- readIORef receivedVersionRef
    mbVersion @?= Just (StreamVersion 1)

-- | Test that multiple streams have independent version sequences
testIndependentStreamVersions :: forall backend. (EventStore backend, StoreConstraints backend IO) => BackendHandle backend -> IO ()
testIndependentStreamVersions store = do
    streamA <- StreamId <$> UUID.nextRandom
    streamB <- StreamId <$> UUID.nextRandom
    streamC <- StreamId <$> UUID.nextRandom

    versionsA <- newIORef []
    versionsB <- newIORef []
    versionsC <- newIORef []
    completionVar <- newEmptyMVar

    let collectVersionsFor ref event = do
            atomicModifyIORef' ref (\versions -> (event.streamVersion : versions, ()))
            pure Continue

    -- Insert events to all three streams in mixed order, in the SAME transaction
    _ <-
        insertEvents store Nothing $
            Transaction
                ( Map.fromList
                    [ (streamA, StreamWrite NoStream [makeUserEvent 1, makeUserEvent 2]) -- A: versions 1, 2
                    , (streamB, StreamWrite NoStream [makeUserEvent 10]) -- B: version 1
                    , (streamC, StreamWrite NoStream [makeUserEvent 100, makeUserEvent 101, makeUserEvent 102]) -- C: versions 1, 2, 3
                    ]
                )

    -- Insert more events to verify independent counting
    _ <-
        insertEvents store Nothing $
            Transaction
                ( Map.fromList
                    [ (streamA, StreamWrite StreamExists [makeUserEvent 3]) -- A: version 3
                    , (streamB, StreamWrite StreamExists [makeUserEvent 11, makeUserEvent 12]) -- B: versions 2, 3
                    ]
                )

    -- Add tombstones
    _ <-
        insertEvents store Nothing $
            Transaction
                ( Map.fromList
                    [ (streamA, StreamWrite StreamExists [makeTombstone])
                    , (streamB, StreamWrite StreamExists [makeTombstone])
                    , (streamC, StreamWrite StreamExists [makeTombstone])
                    ]
                )

    -- Subscribe to all streams
    remainingTombstones <- newIORef (3 :: Int)
    let handleTombstones _ = do
            remaining <- atomicModifyIORef' remainingTombstones (\n -> (n - 1, n - 1))
            if remaining == 0
                then putMVar completionVar () >> pure Stop
                else pure Continue

    handle <-
        subscribe
            store
            ( match
                UserCreated
                ( \event -> do
                    case event.streamId of
                        sid
                            | sid == streamA -> collectVersionsFor versionsA event
                            | sid == streamB -> collectVersionsFor versionsB event
                            | sid == streamC -> collectVersionsFor versionsC event
                            | otherwise -> pure Continue
                )
                :? match Tombstone handleTombstones
                :? MatchEnd
            )
            EventSelector{streamId = AllStreams, startupPosition = FromBeginning}

    takeMVar completionVar
    handle.cancel

    -- Verify each stream has independent version sequences
    vA <- reverse <$> readIORef versionsA
    vB <- reverse <$> readIORef versionsB
    vC <- reverse <$> readIORef versionsC

    vA @?= [StreamVersion 1, StreamVersion 2, StreamVersion 3]
    vB @?= [StreamVersion 1, StreamVersion 2, StreamVersion 3]
    vC @?= [StreamVersion 1, StreamVersion 2, StreamVersion 3]

-- Multi-Instance Test implementations --

{- | Test that multiple "processes" (separate handles) can subscribe to events
written by another "process". This validates cross-process notification works.
-}
testMultiInstanceSubscription ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) =>
    [BackendHandle backend] ->
    IO ()
testMultiInstanceSubscription stores = do
    case stores of
        [] -> assertFailure "Expected at least 1 store handle"
        (writerStore : subscriberStores) -> do
            streamId <- StreamId <$> UUID.nextRandom

            -- Create completion vars for each subscriber
            completionVars <- replicateM (length subscriberStores) newEmptyMVar
            receivedEventsRefs <- replicateM (length subscriberStores) (newIORef [])

            -- Start subscriptions on all subscriber stores (simulating separate processes)
            subscriptionHandles <- forM (zip3 subscriberStores completionVars receivedEventsRefs) $
                \(store, completionVar, eventsRef) -> do
                    subscribe
                        store
                        ( match UserCreated (collectEventsUntilTombstone eventsRef)
                            :? match Tombstone (handleTombstone completionVar)
                            :? MatchEnd
                        )
                        EventSelector{streamId = AllStreams, startupPosition = FromBeginning}

            -- Write events from the writer store (simulating different process)
            let testEvents = map makeUserEvent [1 .. 5] ++ [makeTombstone]
            result <-
                insertEvents
                    writerStore
                    Nothing
                    (Transaction (Map.fromList [(streamId, StreamWrite Any testEvents)]))

            case result of
                FailedInsertion err -> do
                    -- Cancel all subscriptions on failure
                    mapM_ (.cancel) subscriptionHandles
                    assertFailure $ "Failed to insert events: " ++ show err
                SuccessfulInsertion _ -> do
                    -- Wait for all subscribers to complete
                    forM_ completionVars takeMVar

                    -- Cancel all subscriptions
                    mapM_ (.cancel) subscriptionHandles

                    -- Verify all subscribers received the same events
                    allReceivedEvents <- mapM (fmap reverse . readIORef) receivedEventsRefs
                    forM_ allReceivedEvents $ \events -> do
                        length events @?= 5
                        let userInfos = mapMaybe extractUserInfo events
                        length userInfos @?= 5
                        let userNames :: [Text]
                            userNames = map userName userInfos
                        userNames @?= ["user1", "user2", "user3", "user4", "user5"]

                    -- All subscribers should have received identical events
                    case allReceivedEvents of
                        [] -> pure ()
                        (firstEvents : restEvents) ->
                            forM_ restEvents $ \events ->
                                length events @?= length firstEvents

{- | Test that multiple instances observe events in the same total order (AllStreams mode).

This test validates a critical property for event sourcing: all subscribers,
regardless of when they start or which instance they're on, MUST see events
in the same global order.

Test design:
  - N instances (separate store handles to same backend)
  - Each instance writes M events to its own stream
  - Each instance runs 2 subscriptions:
    1. Started BEFORE its writes (sees all events from all instances)
    2. Started AFTER its writes (sees events from other instances)
  - All subscriptions watch AllStreams
  - Each subscription computes a blockchain-style hash chain:
      hash_n = SHA256(hash_{n-1} || eventId || streamId || streamVersion)
  - All subscriptions MUST produce the same final hash (proves same ordering)

Why this is strong:
  - Hash chaining makes ordering violations detectable
  - EventId is stable across subscriptions
  - Multiple subscriptions per instance catch notification bugs
  - Different start positions catch catch-up vs live bugs
-}
testMultiInstanceEventOrdering_AllStreams ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) =>
    Int ->
    -- ^ Number of events each instance writes
    Int ->
    -- ^ Number of instances
    [BackendHandle backend] ->
    IO ()
testMultiInstanceEventOrdering_AllStreams numEventsPerInstance numInstances stores = do
    -- Validate inputs
    when (length stores /= numInstances) $
        assertFailure $
            "Expected " <> show numInstances <> " store handles, got " <> show (length stores)

    -- Each instance gets a unique stream
    streamIds <- replicateM numInstances (StreamId <$> UUID.nextRandom)

    -- Shared tombstone stream (signals end of test)
    tombstoneStream <- StreamId <$> UUID.nextRandom

    -- Each subscription tracks its hash chain in an IORef
    -- We'll have 2 * numInstances subscriptions (before + after writes per instance)
    hashRefs <- replicateM (2 * numInstances) (newIORef (initialHash :: Digest SHA256))

    -- Completion tracking
    completionVars <- replicateM (2 * numInstances) newEmptyMVar

    -- Phase 1: Start "before" subscriptions (one per instance) with jitter
    beforeHandles <- forConcurrently (zip3 stores (take numInstances hashRefs) (take numInstances completionVars)) $
        \(store, hashRef, doneVar) -> do
            -- Random jitter 0-200ms to simulate subscriptions starting at different times
            jitter <- randomRIO (0, 200_000)
            threadDelay jitter
            subscribe
                store
                ( match UserCreated (hashEventHandler hashRef)
                    :? match Tombstone (handleTombstone doneVar)
                    :? MatchEnd
                )
                EventSelector{streamId = AllStreams, startupPosition = FromBeginning}

    -- Phase 2: Each instance writes M events to its own stream with jitter
    forConcurrently_ (zip stores streamIds) $ \(store, streamId) -> do
        -- Random jitter 0-50ms to simulate concurrent writers with scheduling variance
        jitter <- randomRIO (0, 50_000)
        threadDelay jitter
        let events = map makeUserEvent [1 .. numEventsPerInstance]
        result <- insertEvents store Nothing (multiEvent streamId Any events)
        case result of
            FailedInsertion err -> assertFailure $ "Failed to insert events: " ++ show err
            SuccessfulInsertion _ -> pure ()

    -- Phase 3: Start "after" subscriptions (one per instance) with jitter
    afterHandles <- forConcurrently (zip3 stores (drop numInstances hashRefs) (drop numInstances completionVars)) $
        \(store, hashRef, doneVar) -> do
            -- Random jitter 0-200ms to simulate staggered catch-up subscriptions
            jitter <- randomRIO (0, 200_000)
            threadDelay jitter
            subscribe
                store
                ( match UserCreated (hashEventHandler hashRef)
                    :? match Tombstone (handleTombstone doneVar)
                    :? MatchEnd
                )
                EventSelector{streamId = AllStreams, startupPosition = FromBeginning}

    -- Phase 4: Write tombstone to signal end of test
    result <-
        insertEvents
            (head stores)
            Nothing
            (singleEvent tombstoneStream Any makeTombstone)

    case result of
        FailedInsertion err -> do
            -- Cancel all subscriptions
            mapM_ (.cancel) (beforeHandles <> afterHandles)
            assertFailure $ "Failed to insert tombstone: " ++ show err
        SuccessfulInsertion _ -> do
            -- Wait for all subscriptions to complete (with timeout)
            timeoutResult <- timeout 30_000_000 $ do
                forM_ completionVars takeMVar

            -- Cancel all subscriptions
            mapM_ (.cancel) (beforeHandles <> afterHandles)

            case timeoutResult of
                Nothing -> assertFailure "Test timed out waiting for subscriptions"
                Just _ -> do
                    -- Read all final hashes
                    finalHashes <- mapM readIORef hashRefs

                    -- All hashes MUST be identical
                    case finalHashes of
                        [] -> assertFailure "No subscriptions completed"
                        (expectedHash : restHashes) ->
                            forM_ (zip [1 :: Int ..] restHashes) $ \(idx, actualHash) ->
                                when (actualHash /= expectedHash) $
                                    assertFailure $
                                        "Subscription "
                                            <> show idx
                                            <> " saw different event order.\n"
                                            <> "Expected hash: "
                                            <> show expectedHash
                                            <> "\nActual hash:   "
                                            <> show actualHash
  where
    -- Initial hash (empty chain)
    initialHash :: Digest SHA256
    initialHash = hash (BS.empty :: ByteString)

    -- Hash event handler: chains previous hash with event metadata
    hashEventHandler :: IORef (Digest SHA256) -> EventHandler UserCreated IO backend
    hashEventHandler hashRef envelope = do
        let eventIdBytes = BSL.toStrict $ toByteString (envelope.eventId.toUUID)
            streamIdBytes = BSL.toStrict $ toByteString (envelope.streamId.toUUID)
            streamVersionBytes = encodeStreamVersion envelope.streamVersion

        prevHash <- readIORef hashRef
        let prevHashBytes = hashToBytes prevHash
            combined = BS.concat [prevHashBytes, eventIdBytes, streamIdBytes, streamVersionBytes]
            newHash = hash combined

        writeIORef hashRef newHash
        pure Continue

    -- Convert Digest to ByteString (for hashing)
    hashToBytes :: Digest SHA256 -> ByteString
    hashToBytes = BA.convert

    -- Encode StreamVersion as bytes
    encodeStreamVersion :: StreamVersion -> ByteString
    encodeStreamVersion (StreamVersion n) = BS.pack $ encodeInt64 n

    -- Encode Int64 as big-endian bytes
    encodeInt64 :: Int64 -> [Word8]
    encodeInt64 n =
        [ fromIntegral (n `shiftR` 56)
        , fromIntegral (n `shiftR` 48)
        , fromIntegral (n `shiftR` 40)
        , fromIntegral (n `shiftR` 32)
        , fromIntegral (n `shiftR` 24)
        , fromIntegral (n `shiftR` 16)
        , fromIntegral (n `shiftR` 8)
        , fromIntegral n
        ]

{- | Test that multiple instances observe events in the same total order (SingleStream mode).

This test validates that single-stream subscriptions maintain ordering consistency
across multiple instances writing to and reading from the same stream.

Test design:
  - N instances (separate store handles to same backend)
  - All instances write M events to a SHARED stream (not separate streams)
  - Each instance runs 2 subscriptions:
    1. Started BEFORE its writes
    2. Started AFTER its writes
  - All subscriptions watch SingleStream(sharedStream) (not AllStreams)
  - Each subscription computes a blockchain-style hash chain:
      hash_n = SHA256(hash_{n-1} || eventId || streamId || streamVersion)
  - All subscriptions MUST produce the same final hash (proves same ordering)

What this tests:
  - Multiple instances writing to the same stream (concurrent writes)
  - Multiple instances subscribing to the same specific stream
  - Cross-instance notification works for single-stream subscriptions
  - Global ordering preserved even when watching a single stream

Key difference from AllStreams test:
  - Write target: all instances → 1 shared stream (not N separate streams)
  - Subscription selector: SingleStream(sharedStream) (not AllStreams)
-}
testMultiInstanceEventOrdering_SingleStream ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) =>
    Int ->
    -- ^ Number of events each instance writes
    Int ->
    -- ^ Number of instances
    [BackendHandle backend] ->
    IO ()
testMultiInstanceEventOrdering_SingleStream numEventsPerInstance numInstances stores = do
    -- Validate inputs
    when (length stores /= numInstances) $
        assertFailure $
            "Expected " <> show numInstances <> " store handles, got " <> show (length stores)

    -- Single shared stream that all instances write to
    sharedStream <- StreamId <$> UUID.nextRandom

    -- Each subscription tracks its hash chain in an IORef
    -- We'll have 2 * numInstances subscriptions (before + after writes per instance)
    hashRefs <- replicateM (2 * numInstances) (newIORef (initialHash :: Digest SHA256))

    -- Completion tracking
    completionVars <- replicateM (2 * numInstances) newEmptyMVar

    -- Phase 1: Start "before" subscriptions (one per instance) with jitter
    beforeHandles <- forConcurrently (zip3 stores (take numInstances hashRefs) (take numInstances completionVars)) $
        \(store, hashRef, doneVar) -> do
            -- Random jitter 0-200ms to simulate subscriptions starting at different times
            jitter <- randomRIO (0, 200_000)
            threadDelay jitter
            subscribe
                store
                ( match UserCreated (hashEventHandler hashRef)
                    :? match Tombstone (handleTombstone doneVar)
                    :? MatchEnd
                )
                EventSelector{streamId = SingleStream sharedStream, startupPosition = FromBeginning}

    -- Phase 2: Each instance writes M events to the SHARED stream with jitter
    forConcurrently_ stores $ \store -> do
        -- Random jitter 0-50ms to simulate concurrent writers with scheduling variance
        jitter <- randomRIO (0, 50_000)
        threadDelay jitter
        let events = map makeUserEvent [1 .. numEventsPerInstance]
        result <- insertEvents store Nothing (multiEvent sharedStream Any events)
        case result of
            FailedInsertion err -> assertFailure $ "Failed to insert events: " ++ show err
            SuccessfulInsertion _ -> pure ()

    -- Phase 3: Start "after" subscriptions (one per instance) with jitter
    afterHandles <- forConcurrently (zip3 stores (drop numInstances hashRefs) (drop numInstances completionVars)) $
        \(store, hashRef, doneVar) -> do
            -- Random jitter 0-200ms to simulate staggered catch-up subscriptions
            jitter <- randomRIO (0, 200_000)
            threadDelay jitter
            subscribe
                store
                ( match UserCreated (hashEventHandler hashRef)
                    :? match Tombstone (handleTombstone doneVar)
                    :? MatchEnd
                )
                EventSelector{streamId = SingleStream sharedStream, startupPosition = FromBeginning}

    -- Phase 4: Write tombstone to the SHARED stream to signal end of test
    result <-
        insertEvents
            (head stores)
            Nothing
            (singleEvent sharedStream Any makeTombstone)

    case result of
        FailedInsertion err -> do
            -- Cancel all subscriptions
            mapM_ (.cancel) (beforeHandles <> afterHandles)
            assertFailure $ "Failed to insert tombstone: " ++ show err
        SuccessfulInsertion _ -> do
            -- Wait for all subscriptions to complete (with timeout)
            timeoutResult <- timeout 30_000_000 $ do
                forM_ completionVars takeMVar

            -- Cancel all subscriptions
            mapM_ (.cancel) (beforeHandles <> afterHandles)

            case timeoutResult of
                Nothing -> assertFailure "Test timed out waiting for subscriptions"
                Just _ -> do
                    -- Read all final hashes
                    finalHashes <- mapM readIORef hashRefs

                    -- All hashes MUST be identical
                    case finalHashes of
                        [] -> assertFailure "No subscriptions completed"
                        (expectedHash : restHashes) ->
                            forM_ (zip [1 :: Int ..] restHashes) $ \(idx, actualHash) ->
                                when (actualHash /= expectedHash) $
                                    assertFailure $
                                        "Subscription "
                                            <> show idx
                                            <> " saw different event order.\n"
                                            <> "Expected hash: "
                                            <> show expectedHash
                                            <> "\nActual hash:   "
                                            <> show actualHash
  where
    -- Initial hash (empty chain)
    initialHash :: Digest SHA256
    initialHash = hash (BS.empty :: ByteString)

    -- Hash event handler: chains previous hash with event metadata
    hashEventHandler :: IORef (Digest SHA256) -> EventHandler UserCreated IO backend
    hashEventHandler hashRef envelope = do
        let eventIdBytes = BSL.toStrict $ toByteString (envelope.eventId.toUUID)
            streamIdBytes = BSL.toStrict $ toByteString (envelope.streamId.toUUID)
            streamVersionBytes = encodeStreamVersion envelope.streamVersion

        prevHash <- readIORef hashRef
        let prevHashBytes = hashToBytes prevHash
            combined = BS.concat [prevHashBytes, eventIdBytes, streamIdBytes, streamVersionBytes]
            newHash = hash combined

        writeIORef hashRef newHash
        pure Continue

    -- Convert Digest to ByteString (for hashing)
    hashToBytes :: Digest SHA256 -> ByteString
    hashToBytes = BA.convert

    -- Encode StreamVersion as bytes
    encodeStreamVersion :: StreamVersion -> ByteString
    encodeStreamVersion (StreamVersion n) = BS.pack $ encodeInt64 n

    -- Encode Int64 as big-endian bytes
    encodeInt64 :: Int64 -> [Word8]
    encodeInt64 n =
        [ fromIntegral (n `shiftR` 56)
        , fromIntegral (n `shiftR` 48)
        , fromIntegral (n `shiftR` 40)
        , fromIntegral (n `shiftR` 32)
        , fromIntegral (n `shiftR` 24)
        , fromIntegral (n `shiftR` 16)
        , fromIntegral (n `shiftR` 8)
        , fromIntegral n
        ]
