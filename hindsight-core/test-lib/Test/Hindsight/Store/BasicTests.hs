{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}

{- | Basic subscription and event handling tests

Tests fundamental event store operations:
- Event insertion and subscription
- Stream selection (all streams vs. single stream)
- Position-based subscription startup
- Correlation ID preservation
- Async subscription behavior
- Subscription stop semantics
- Exception handling and enrichment
-}
module Test.Hindsight.Store.BasicTests (basicTests) where

import Control.Concurrent (MVar, newEmptyMVar, putMVar, takeMVar, threadDelay)
import Control.Monad (mapM_)
import Data.Aeson (FromJSON, ToJSON)
import Data.IORef
import Data.Map.Strict qualified as Map
import Data.Proxy (Proxy (..))
import Data.Text (Text)
import Data.UUID.V4 qualified as UUID
import GHC.Generics (Generic)
import Hindsight.Events
import Hindsight.Store
import Test.Hindsight.Examples (Tombstone, UserCreated, UserInformation2 (..), makeTombstone, makeUserEvent)
import Test.Hindsight.Store.Common (collectEvents, extractPayload, handleTombstone)
import Test.Hindsight.Store.TestRunner (EventStoreTestRunner (..))
import Test.Tasty
import Test.Tasty.HUnit
import UnliftIO.Exception (fromException, throwIO, tryAny)

-- * Counter Events for Stop/Fail Testing

-- | Counter increment event for testing subscription stop behavior
type CounterInc = "counter_inc"

data CounterIncPayload = CounterIncPayload
    deriving stock (Show, Eq, Generic)
    deriving anyclass (FromJSON, ToJSON)

type instance MaxVersion CounterInc = 0
type instance Versions CounterInc = '[CounterIncPayload]
instance Event CounterInc
instance MigrateVersion 0 CounterInc

-- | Counter stop event for testing subscription stop behavior
type CounterStop = "counter_stop"

data CounterStopPayload = CounterStopPayload
    deriving stock (Show, Eq, Generic)
    deriving anyclass (FromJSON, ToJSON)

type instance MaxVersion CounterStop = 0
type instance Versions CounterStop = '[CounterStopPayload]
instance Event CounterStop
instance MigrateVersion 0 CounterStop

-- | Counter fail event for testing exception handling
type CounterFail = "counter_fail"

data CounterFailPayload = CounterFailPayload
    deriving stock (Show, Eq, Generic)
    deriving anyclass (FromJSON, ToJSON)

type instance MaxVersion CounterFail = 0
type instance Versions CounterFail = '[CounterFailPayload]
instance Event CounterFail
instance MigrateVersion 0 CounterFail

-- | Helper to create a counter increment event
makeCounterInc :: SomeLatestEvent
makeCounterInc =
    SomeLatestEvent
        (Proxy @CounterInc)
        CounterIncPayload

-- | Helper to create a counter stop event
makeCounterStop :: SomeLatestEvent
makeCounterStop =
    SomeLatestEvent
        (Proxy @CounterStop)
        CounterStopPayload

-- | Helper to create a counter fail event
makeCounterFail :: SomeLatestEvent
makeCounterFail =
    SomeLatestEvent
        (Proxy @CounterFail)
        CounterFailPayload

-- * Test Utilities

repeatTest :: Int -> TestName -> Assertion -> TestTree
repeatTest n name assertion =
    testGroup (name <> " x" <> show n) $
        replicate n $
            testCase name assertion

-- | Basic test suite for event store backends
basicTests ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) =>
    EventStoreTestRunner backend ->
    [TestTree]
basicTests runner =
    [ testCase "Basic Event Reception" $ withStore runner testBasicEventReception
    , testCase "Correlation ID Preservation" $ withStore runner testCorrelationIdPreservation
    , testCase "Single Stream Selection" $ withStore runner testSingleStreamSelection
    , testCase "Start From Position" $ withStore runner testStartFromPosition
    , repeatTest 20 "Async Subscription Reception" $ withStore runner testAsyncSubscription
    , testCase "Subscription Honors Stop Result" $ withStore runner testSubscriptionStopBehavior
    , testCase "Handler Exception Enrichment" $ withStore runner testHandlerExceptionEnrichment
    ]

-- * Test Implementations

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
                    ( match UserCreated (collectEvents receivedEvents)
                        :? match Tombstone (handleTombstone completionVar)
                        :? MatchEnd
                    )
                    EventSelector{streamId = AllStreams, startupPosition = FromBeginning}

            takeMVar completionVar
            handle.cancel -- Cancel subscription after completion
            events <- reverse <$> readIORef receivedEvents
            length events @?= 3

            let userInfos = map extractPayload events
            length userInfos @?= 3
            let userNames :: [Text]
                userNames = map (.userName) userInfos
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
            ( match UserCreated (collectEvents receivedEvents)
                :? match Tombstone (handleTombstone completionVar)
                :? MatchEnd
            )
            EventSelector{streamId = SingleStream stream1, startupPosition = FromBeginning}

    takeMVar completionVar
    handle.cancel -- Cancel subscription after completion
    events <- reverse <$> readIORef receivedEvents
    let userInfos = map extractPayload events
    length userInfos @?= 3
    let userNames = map (.userName) userInfos
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
                    ( match UserCreated (collectEvents receivedEvents)
                        :? match Tombstone (handleTombstone completionVar)
                        :? MatchEnd
                    )
                    EventSelector{streamId = AllStreams, startupPosition = FromPosition cursor}

            takeMVar completionVar
            handle.cancel -- Cancel subscription after completion
            events <- reverse <$> readIORef receivedEvents
            let userInfos = map extractPayload events
            length userInfos @?= 2
            let userNames :: [Text]
                userNames = map (.userName) userInfos
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
                    ( match UserCreated (collectEvents receivedEvents)
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
            ( match UserCreated (collectEvents receivedEvents)
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
            let userInfos = map extractPayload events
            length userInfos @?= 3
            let userNames :: [Text]
                userNames = map (.userName) userInfos
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
