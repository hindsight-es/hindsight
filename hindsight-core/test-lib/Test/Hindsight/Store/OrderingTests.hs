{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE Strict #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NumericUnderscores #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

-- | Backend-agnostic comprehensive subscription ordering tests
--
-- Tests that all subscriptions (regardless of when they start) see events
-- in the same total order. Uses hash chain verification to detect any
-- ordering inconsistencies across concurrent subscriptions.
module Test.Hindsight.Store.OrderingTests (orderingTests) where

import Control.Concurrent (threadDelay, forkIO)
import Control.Concurrent.Async (async, wait, forConcurrently_, forConcurrently)
import Control.Concurrent.STM (TVar, atomically, newTVarIO, readTVar, writeTVar, modifyTVar)
import Control.Concurrent.MVar (MVar, newEmptyMVar, putMVar, takeMVar)
import System.Timeout (timeout)
import Control.Monad (replicateM, void, when, forM, forM_)
import Control.Monad.IO.Class (liftIO)
import Data.Aeson (FromJSON, ToJSON)
import Data.IORef (IORef, modifyIORef', newIORef, readIORef, atomicModifyIORef')
import Data.Map.Strict qualified as Map
import Data.Proxy (Proxy (..))
import Data.Text (Text, pack, unpack, isPrefixOf)
import qualified Data.Text as Text
import Data.UUID.V4 qualified as UUID
import GHC.Generics (Generic)
import Hindsight.Events
import Hindsight.Store
import System.Random (randomRIO)
import Test.Hindsight.Store.TestRunner (EventStoreTestRunner (..))
import Test.Tasty
import Test.Tasty.HUnit
import Data.Time (UTCTime, getCurrentTime, diffUTCTime)
import Data.Int (Int64)
import Data.Set qualified as Set
import System.IO (hFlush, stdout)


-- | Comprehensive test event type
type ComprehensiveTestEvent = "comprehensive_test_event"

data ComprehensiveTestPayload = ComprehensiveTestPayload
  { compValue :: Int
  , text :: Text
  , bytes :: String  -- Changed from ByteString for JSON compatibility
  , timestamp :: UTCTime
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)

type instance MaxVersion ComprehensiveTestEvent = 0
type instance Versions ComprehensiveTestEvent = '[ComprehensiveTestPayload]
instance Hindsight.Events.Event ComprehensiveTestEvent

instance MigrateVersion 0 ComprehensiveTestEvent

-- | Completion sentinel event to signal end of test
type CompletionEvent = "test_completion_event"

data CompletionPayload = CompletionPayload
  { completionId :: Text
  , completionTotalTransactions :: Int
  , totalExpectedEvents :: Int
  , completedAt :: UTCTime
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)

type instance MaxVersion CompletionEvent = 0
type instance Versions CompletionEvent = '[CompletionPayload]
instance Hindsight.Events.Event CompletionEvent

instance MigrateVersion 0 CompletionEvent

-- | Subscription tracking data with optimized hash storage
-- Now generic over position type
data SubscriptionState position = SubscriptionState
  { subscriptionId :: Text
  , startedAt :: UTCTime
  , currentHash :: !Int64  -- Hash chain (optimized: Int64)
  , subEventCount :: Int
  , firstEventTime :: Maybe UTCTime
  , lastEventTime :: Maybe UTCTime
  , completionReceived :: Bool
  , completionReceivedAt :: Maybe UTCTime
  , expectedTotalEvents :: Maybe Int
  , completionMVar :: MVar ()  -- Signal for completion
  , streamIdHashes :: !(Map.Map StreamId Int)  -- Memoized UUID hashes
  , textHashes :: !(Map.Map Text Int)          -- Memoized text hashes
  , positionsSeen :: ![position]               -- Track positions for debugging
  } -- Cannot derive Show/Eq due to MVar

-- | Transaction plan for test execution
data TransactionPlan = TransactionPlan
  { planId :: Int
  , planEventCount :: Int  -- Number of events to insert
  , targetStreams :: [StreamId]  -- Streams to insert into
  , basePayload :: ComprehensiveTestPayload  -- Base payload to vary
  , delayBeforeStart :: Int  -- Microseconds delay before starting
  , expectedSlowness :: Int  -- Expected processing time factor
  } deriving (Show)

-- | Final result from a subscription (renamed to avoid conflict)
data TestSubscriptionResult position = TestSubscriptionResult
  { resultSubscriptionId :: Text
  , resultStartedAt :: UTCTime
  , resultFinalHash :: !Int64  -- Optimized: Int64
  , resultEventCount :: Int
  , resultFirstEventTime :: Maybe UTCTime
  , resultLastEventTime :: Maybe UTCTime
  , resultCompletedAt :: UTCTime
  , resultCompletionReceived :: Bool
  , resultCompletionReceivedAt :: Maybe UTCTime
  , resultExpectedTotalEvents :: Maybe Int
  , resultProcessingDurationMs :: Int64
  , resultPositionsSeen :: ![position]  -- For debugging
  }

-- Manual Show instance for debugging (position list can be very long)
instance forall position. Show position => Show (TestSubscriptionResult position) where
  show r = "TestSubscriptionResult{" ++
    "subId=" ++ unpack r.resultSubscriptionId ++
    ", events=" ++ show r.resultEventCount ++
    ", hash=" ++ show r.resultFinalHash ++
    ", completed=" ++ show r.resultCompletionReceived ++
    ", positions=" ++ show (length r.resultPositionsSeen) ++ " items" ++
    "}"

-- | Configuration for comprehensive consistency test
data TestConfiguration = TestConfiguration
  { configNumTransactions :: Int        -- Number of concurrent transactions (default: 40)
  , configMinEventsPerTx :: Int         -- Minimum events per transaction (default: 1)
  , configMaxEventsPerTx :: Int         -- Maximum events per transaction (default: 100)
  , configMinStreamsPerTx :: Int        -- Minimum streams per transaction (default: 1)
  , configMaxStreamsPerTx :: Int        -- Maximum streams per transaction (default: 3)
  , configTxExecutionWindowMs :: Int    -- Total window for all tx execution in ms (default: 5000)
  , configNumEarlySubscriptions :: Int  -- Early subscriptions count (default: 5)
  , configNumConcurrentSubscriptions :: Int -- Concurrent subscriptions count (default: 10)
  , configNumValidationSubscriptions :: Int -- Validation subscriptions count (default: 5)
  , configSubExecutionWindowMs :: Int   -- Total window for subscription starts in ms (default: 7000)
  , configProcessingTimeMs :: Int       -- Wait time for event processing in ms (default: 3000)
  , configMaxSlownessFactor :: Int      -- Max artificial slowness multiplier (default: 10)
  } deriving (Show, Eq)

-- | Default test configuration for standard testing
defaultTestConfig :: TestConfiguration
defaultTestConfig = TestConfiguration
  { configNumTransactions = 10
  , configMinEventsPerTx = 10
  , configMaxEventsPerTx = 10
  , configMinStreamsPerTx = 1
  , configMaxStreamsPerTx = 5
  , configTxExecutionWindowMs = 20000
  , configNumEarlySubscriptions = 2
  , configNumConcurrentSubscriptions = 10
  , configNumValidationSubscriptions = 2
  , configSubExecutionWindowMs = 7000
  , configProcessingTimeMs = 3000
  , configMaxSlownessFactor = 10
  }

-- | Light test configuration for quick testing
lightTestConfig :: TestConfiguration
lightTestConfig = defaultTestConfig
  { configNumTransactions = 5
  , configMaxEventsPerTx = 10
  , configTxExecutionWindowMs = 10000
  , configNumEarlySubscriptions = 1
  , configNumConcurrentSubscriptions = 3
  , configNumValidationSubscriptions = 1
  , configSubExecutionWindowMs = 3000
  , configProcessingTimeMs = 1000
  }

-- | Stress test configuration for heavy load testing
stressTestConfig :: TestConfiguration
stressTestConfig = defaultTestConfig
  { configNumTransactions = 100           -- 10x more transactions
  , configMaxEventsPerTx = 10             -- Keep moderate event count
  , configTxExecutionWindowMs = 6000      -- 6 seconds for all transactions
  , configNumEarlySubscriptions = 1000    -- Massive subscription load
  , configNumConcurrentSubscriptions = 1000
  , configNumValidationSubscriptions = 1000
  , configSubExecutionWindowMs = 12000    -- 12 seconds for subscription starts
  , configProcessingTimeMs = 20000        -- Longer processing time
  , configMaxSlownessFactor = 20          -- More variation in slowness
  }

-- | Debug test configuration for race condition analysis
debugTestConfig :: TestConfiguration
debugTestConfig = defaultTestConfig
  { configNumTransactions = 100          -- Moderate number of transactions
  , configMinEventsPerTx = 10            -- HIGH events per tx to trigger full batches
  , configMaxEventsPerTx = 15            -- Range to create burst conditions
  , configTxExecutionWindowMs = 1000     -- FAST execution to create bursts
  , configNumEarlySubscriptions = 1      -- Minimal subscriptions
  , configNumConcurrentSubscriptions = 3
  , configNumValidationSubscriptions = 1
  , configSubExecutionWindowMs = 500     -- Fast subscription starts
  , configProcessingTimeMs = 100         -- Very short processing time
  }

-- | Progress tracking for coordinated reporting
data ProgressState = ProgressState
  { transactionsCompleted :: Int
  , transactionsFailed :: Int
  , totalTransactions :: Int
  , subscriptionsStarted :: Int
  , subscriptionsCompleted :: Int
  , totalSubscriptions :: Int
  , testStartTime :: UTCTime
  , lastUpdateTime :: UTCTime
  , currentPhase :: Text
  , detailMessage :: Text
  } deriving (Show)

-- | Progress manager with thread-safe updates
data ProgressManager = ProgressManager
  { progressState :: TVar ProgressState
  , shouldStop :: TVar Bool
  , updateIntervalMs :: Int
  }

-- | Create a new progress manager
newProgressManager :: TestConfiguration -> UTCTime -> IO ProgressManager
newProgressManager config startTime = do
  let totalSubs = config.configNumEarlySubscriptions +
                  config.configNumConcurrentSubscriptions +
                  config.configNumValidationSubscriptions

  initialState <- newTVarIO $ ProgressState
    { transactionsCompleted = 0
    , transactionsFailed = 0
    , totalTransactions = config.configNumTransactions
    , subscriptionsStarted = 0
    , subscriptionsCompleted = 0
    , totalSubscriptions = totalSubs
    , testStartTime = startTime
    , lastUpdateTime = startTime
    , currentPhase = "Initializing"
    , detailMessage = ""
    }

  shouldStop <- newTVarIO False

  let updateInterval = case config.configNumTransactions of
        n | n <= 50 -> 500      -- 500ms for light tests
        n | n <= 500 -> 1000    -- 1s for normal tests
        _ -> 2000               -- 2s for stress tests

  pure $ ProgressManager initialState shouldStop updateInterval

-- | Update transaction progress
reportTransactionCompleted :: ProgressManager -> Bool -> IO ()
reportTransactionCompleted pm success = atomically $ do
  modifyTVar pm.progressState $ \s ->
    if success
      then s { transactionsCompleted = s.transactionsCompleted + 1 }
      else s { transactionsFailed = s.transactionsFailed + 1 }

-- | Update subscription progress
reportSubscriptionStarted :: ProgressManager -> IO ()
reportSubscriptionStarted pm = atomically $ do
  modifyTVar pm.progressState $ \s ->
    s { subscriptionsStarted = s.subscriptionsStarted + 1 }

reportSubscriptionCompleted :: ProgressManager -> IO ()
reportSubscriptionCompleted pm = atomically $ do
  modifyTVar pm.progressState $ \s ->
    s { subscriptionsCompleted = s.subscriptionsCompleted + 1 }


reportPhaseChangeIO :: ProgressManager -> Text -> Text -> IO ()
reportPhaseChangeIO pm phase detail = do
  now <- getCurrentTime
  atomically $ do
    modifyTVar pm.progressState $ \s ->
      s { currentPhase = phase, detailMessage = detail, lastUpdateTime = now }

-- | Format progress display
formatProgress :: ProgressState -> String
formatProgress s =
  let elapsed = diffUTCTime s.lastUpdateTime s.testStartTime
      elapsedSecs = round elapsed :: Int

      txProgress = s.transactionsCompleted + s.transactionsFailed
      txPercent = if s.totalTransactions > 0
                  then (txProgress * 100) `div` s.totalTransactions
                  else 0

      subPercent = if s.totalSubscriptions > 0
                   then (s.subscriptionsCompleted * 100) `div` s.totalSubscriptions
                   else 0

      overallPercent = (txPercent * 70 + subPercent * 30) `div` 100

      etaStr = if txProgress > 0 && s.transactionsCompleted < s.totalTransactions
               then let rate = fromIntegral txProgress / realToFrac elapsed :: Double
                        remaining = fromIntegral (s.totalTransactions - txProgress) :: Double
                        etaSecs = round (remaining / rate) :: Int
                    in " | ETA: " ++ show etaSecs ++ "s"
               else ""

      txStatus = show txProgress ++ "/" ++ show s.totalTransactions ++
                 " (" ++ show txPercent ++ "%)" ++
                 (if s.transactionsFailed > 0 then " [" ++ show s.transactionsFailed ++ " failed]" else "")

      subStatus = show s.subscriptionsCompleted ++ "/" ++ show s.totalSubscriptions ++
                  " (" ++ show subPercent ++ "%)" ++
                  " [" ++ show s.subscriptionsStarted ++ " started]"

  in "[" ++ show elapsedSecs ++ "s] " ++ unpack s.currentPhase ++
     " | Tx: " ++ txStatus ++
     " | Subs: " ++ subStatus ++
     " | Overall: " ++ show overallPercent ++ "%" ++ etaStr ++
     (if not (Text.null s.detailMessage) then " | " ++ unpack s.detailMessage else "")

-- | Start progress reporting thread
startProgressReporting :: ProgressManager -> IO ()
startProgressReporting pm = do
  void $ forkIO $ progressLoop
  where
    progressLoop = do
      shouldStop <- atomically $ readTVar pm.shouldStop
      if shouldStop
        then do
          state <- atomically $ readTVar pm.progressState
          putStrLn $ "\n" ++ formatProgress state
          putStrLn "Progress reporting stopped."
        else do
          state <- atomically $ readTVar pm.progressState
          putStr $ "\r" ++ formatProgress state
          hFlush stdout
          threadDelay (pm.updateIntervalMs * 1000)
          progressLoop

-- | Stop progress reporting
stopProgressReporting :: ProgressManager -> IO ()
stopProgressReporting pm = atomically $ writeTVar pm.shouldStop True

-- | Generic hash chain utilities with memoization
-- Now uses Show position instead of PostgreSQL-specific txNo/seqNo
updateHashChainGeneric :: forall position. (Show position)
                       => Int64
                       -> position  -- Generic position type
                       -> StreamId
                       -> ComprehensiveTestPayload
                       -> Map.Map StreamId Int
                       -> Map.Map Text Int
                       -> (Int64, Map.Map StreamId Int, Map.Map Text Int)
updateHashChainGeneric prevHash position streamId payload streamHashes textHashes =
  let -- Look up or compute StreamId hash with memoization
      (streamHashVal, newStreamHashes) = case Map.lookup streamId streamHashes of
        Just cached -> (cached, streamHashes)
        Nothing ->
          let computed = fastTextHash (show streamId)
          in (computed, Map.insert streamId computed streamHashes)

      -- Look up or compute payload text hash with memoization
      (textHashVal, newTextHashes) = case Map.lookup payload.text textHashes of
        Just cached -> (cached, textHashes)
        Nothing ->
          let computed = fastTextHash (unpack payload.text)
          in (computed, Map.insert payload.text computed textHashes)

      -- Hash the position generically using Show
      positionHash = fastTextHash (show position)

      -- Optimized polynomial rolling hash using Int64 arithmetic
      combined = (prevHash * 31) + (fromIntegral positionHash * 37) +
                 (fromIntegral (abs streamHashVal) * 43) +
                 (fromIntegral payload.compValue * 47) +
                 (fromIntegral (abs textHashVal) * 53)
      newHash = combined `mod` 982451653  -- Large prime for good distribution

  in (newHash, newStreamHashes, newTextHashes)
  where
    -- Fast hash function for strings - optimized for performance
    fastTextHash :: String -> Int
    fastTextHash = foldl' (\acc c -> acc * 31 + fromEnum c) 0

-- | Wait for subscription completion with timeout
-- Simpler than crash detection - just waits for completion MVar with 60s timeout
waitForCompletion :: forall position. IORef (SubscriptionState position) -> IO ()
waitForCompletion stateRef = do
  state <- readIORef stateRef
  result <- timeout 60_000_000 $ takeMVar state.completionMVar  -- 60 seconds
  case result of
    Nothing -> assertFailure $ "Subscription " <> unpack state.subscriptionId <> " timed out after 60 seconds"
    Just () -> pure ()

-- | Generate random transaction plans based on configuration
generateTransactionPlans :: TestConfiguration -> IO [TransactionPlan]
generateTransactionPlans config = do
  baseTime <- getCurrentTime
  forM [1..config.configNumTransactions] $ \planId -> do
    eventCount <- randomRIO (config.configMinEventsPerTx, config.configMaxEventsPerTx)
    numStreams <- randomRIO (config.configMinStreamsPerTx, config.configMaxStreamsPerTx)
    targetStreams <- replicateM numStreams (StreamId <$> UUID.nextRandom)

    value <- randomRIO (1, 10000)
    textSuffix <- pack . show <$> randomRIO (1000 :: Int, 9999)
    let text = "transaction-" <> pack (show planId) <> "-" <> textSuffix
    bytes <- show <$> randomRIO (100000 :: Int, 999999)

    delayBeforeStart <- randomRIO (0, config.configTxExecutionWindowMs * 1000)
    expectedSlowness <- randomRIO (1, config.configMaxSlownessFactor)

    pure $ TransactionPlan
      { planId = planId
      , planEventCount = eventCount
      , targetStreams = targetStreams
      , basePayload = ComprehensiveTestPayload
          { compValue = value
          , text = text
          , bytes = bytes
          , timestamp = baseTime
          }
      , delayBeforeStart = delayBeforeStart
      , expectedSlowness = expectedSlowness
      }

-- | Create and start a subscription with hash tracking that stops on completion
-- Generic over backend type
startHashTrackingSubscription
  :: forall backend.
     (EventStore backend, StoreConstraints backend IO, Show (Cursor backend))
  => BackendHandle backend
  -> Text
  -> UTCTime
  -> Maybe ProgressManager
  -> IO (SubscriptionHandle backend, IORef (SubscriptionState (Cursor backend)))
startHashTrackingSubscription store subId startTime mProgressManager =
  startHashTrackingSubscriptionWithPosition store subId startTime mProgressManager FromBeginning

-- | Create and start a subscription with specific starting position
startHashTrackingSubscriptionWithPosition
  :: forall backend.
     (EventStore backend, StoreConstraints backend IO, Show (Cursor backend))
  => BackendHandle backend
  -> Text
  -> UTCTime
  -> Maybe ProgressManager
  -> StartupPosition backend
  -> IO (SubscriptionHandle backend, IORef (SubscriptionState (Cursor backend)))
startHashTrackingSubscriptionWithPosition store subId startTime mProgressManager startPos = do
  completionMVar <- newEmptyMVar
  stateRef <- newIORef $ SubscriptionState
    { subscriptionId = subId
    , startedAt = startTime
    , currentHash = 0
    , subEventCount = 0
    , firstEventTime = Nothing
    , lastEventTime = Nothing
    , completionReceived = False
    , completionReceivedAt = Nothing
    , expectedTotalEvents = Nothing
    , completionMVar = completionMVar
    , streamIdHashes = Map.empty
    , textHashes = Map.empty
    , positionsSeen = []
    }

  let handler =
        (Proxy @ComprehensiveTestEvent, \envelope -> do
          now <- liftIO getCurrentTime
          liftIO $ atomicModifyIORef' stateRef $ \state ->
            let position = envelope.position
                (newHash, newStreamHashes, newTextHashes) = updateHashChainGeneric
                           state.currentHash
                           position
                           envelope.streamId
                           envelope.payload
                           state.streamIdHashes
                           state.textHashes
                newState = state
                  { currentHash = newHash
                  , streamIdHashes = newStreamHashes
                  , textHashes = newTextHashes
                  , subEventCount = state.subEventCount + 1
                  , firstEventTime = case state.firstEventTime of
                      Nothing -> Just now
                      Just t -> Just t
                  , lastEventTime = Just now
                  , positionsSeen = state.positionsSeen ++ [position]
                  }
            in (newState, ())
          pure Continue)
        :? (Proxy @CompletionEvent, \envelope -> do
          now <- liftIO getCurrentTime
          liftIO $ atomicModifyIORef' stateRef $ \state ->
            let newState = state
                  { completionReceived = True
                  , completionReceivedAt = Just now
                  , expectedTotalEvents = Just envelope.payload.totalExpectedEvents
                  , lastEventTime = Just now
                  }
            in (newState, ())
          liftIO $ putMVar completionMVar ()
          case mProgressManager of
            Just pm -> liftIO $ reportSubscriptionCompleted pm
            Nothing -> pure ()
          pure Stop)
        :? MatchEnd

  -- Use generic subscribe API
  subscriptionHandle <- subscribe store handler (EventSelector AllStreams startPos)

  case mProgressManager of
    Just pm -> reportSubscriptionStarted pm
    Nothing -> pure ()

  pure (subscriptionHandle, stateRef)

-- | Execute a transaction plan
executeTransactionPlan
  :: forall backend.
     (EventStore backend, StoreConstraints backend IO, Show (Cursor backend))
  => BackendHandle backend
  -> TransactionPlan
  -> Maybe ProgressManager
  -> IO (Either String ())
executeTransactionPlan store plan mProgressManager = do
  threadDelay plan.delayBeforeStart

  let makeEvent i =
        let payload = plan.basePayload
              { compValue = plan.basePayload.compValue + i
              , text = plan.basePayload.text <> "-" <> pack (show i)
              }
        in SomeLatestEvent (Proxy @ComprehensiveTestEvent) payload

  let events = map makeEvent [1..plan.planEventCount]

  let streamsWithEvents = zip (cycle plan.targetStreams) events
      groupedEvents = Map.fromListWith (++)
        [(streamId, [event]) | (streamId, event) <- streamsWithEvents]
      eventBatches = Map.map (\es -> StreamWrite NoStream es) groupedEvents

  when (plan.expectedSlowness > 5) $
    threadDelay (plan.expectedSlowness * 50_000)

  let tryInsert n = do
        result <- insertEvents store Nothing (Transaction eventBatches)
        case result of
          FailedInsertion err -> if (n>(0 :: Int))
            then tryInsert (n-(1 :: Int))
            else do
              case mProgressManager of
                Just pm -> reportTransactionCompleted pm False
                Nothing -> pure ()
              pure $ Left $ "Transaction " ++ show plan.planId ++ " failed: " ++ show err

          SuccessfulInsertion _ -> do
            case mProgressManager of
              Just pm -> reportTransactionCompleted pm True
              Nothing -> pure ()
            pure $ Right ()

  tryInsert 10

-- | Comprehensive consistency test with configurable parameters
-- Generic over backend type
testComprehensiveConsistencyWithConfig
  :: forall backend.
     (EventStore backend, StoreConstraints backend IO, Show (Cursor backend))
  => EventStoreTestRunner backend
  -> TestConfiguration
  -> Assertion
testComprehensiveConsistencyWithConfig runner config = do
  putStrLn "\n=== Starting Comprehensive Consistency Test ==="
  putStrLn $ "Config: " ++ show config.configNumTransactions ++ " transactions over " ++
             show config.configTxExecutionWindowMs ++ "ms, " ++
             show (config.configNumEarlySubscriptions + config.configNumConcurrentSubscriptions + config.configNumValidationSubscriptions) ++ " subscriptions over " ++
             show config.configSubExecutionWindowMs ++ "ms"

  testStartTime <- getCurrentTime
  progressManager <- newProgressManager config testStartTime
  startProgressReporting progressManager

  withStore runner $ \store -> do
    transactionPlans <- generateTransactionPlans config
    let totalEvents = sum $ map (.planEventCount) transactionPlans
    reportPhaseChangeIO progressManager "Planning" $ "Generated " <> pack (show (length transactionPlans)) <> " transaction plans, " <> pack (show totalEvents) <> " total events"

    subscriptionsRef <- newIORef []

    reportPhaseChangeIO progressManager "Starting" "Launching concurrent transactions and subscriptions"

    transactionResults <- async $ do
      reportPhaseChangeIO progressManager "Transactions" $ "Executing " <> pack (show (length transactionPlans)) <> " transactions over " <> pack (show config.configTxExecutionWindowMs) <> "ms window"
      forConcurrently_ transactionPlans $ \plan -> do
        result <- executeTransactionPlan store plan (Just progressManager)
        case result of
          Left _err -> pure ()
          Right _ -> pure ()

    earlySubscriptionsAsync <- async $ do
      reportPhaseChangeIO progressManager "Early Subs" $ "Starting " <> pack (show config.configNumEarlySubscriptions) <> " early subscriptions"
      earlyStartTime <- getCurrentTime
      subs <- forConcurrently [1..config.configNumEarlySubscriptions] $ \i -> do
        let subId = "early-" <> pack (show i)
        (handle, stateRef) <- startHashTrackingSubscription store subId earlyStartTime (Just progressManager)
        pure (handle, stateRef)
      mapM_ (modifyIORef' subscriptionsRef . (:)) subs
      pure subs

    concurrentSubscriptionsAsync <- async $ do
      reportPhaseChangeIO progressManager "Concurrent Subs" $ "Starting " <> pack (show config.configNumConcurrentSubscriptions) <> " concurrent subscriptions over " <> pack (show config.configSubExecutionWindowMs) <> "ms window"

      let startPos = FromBeginning

      subs <- forConcurrently [1..config.configNumConcurrentSubscriptions] $ \i -> do
        delay <- randomRIO (0, config.configSubExecutionWindowMs * 1000)
        threadDelay delay

        subStartTime <- getCurrentTime
        let subId = "concurrent-" <> pack (show i)
        (handle, stateRef) <- startHashTrackingSubscriptionWithPosition store subId subStartTime (Just progressManager) startPos
        pure (handle, stateRef)

      mapM_ (modifyIORef' subscriptionsRef . (:)) subs
      pure subs

    reportPhaseChangeIO progressManager "Waiting" "Waiting for concurrent activities to complete"
    wait transactionResults
    _ <- wait earlySubscriptionsAsync
    _ <- wait concurrentSubscriptionsAsync
    reportPhaseChangeIO progressManager "Completed" "All transactions and concurrent subscriptions completed"

    reportPhaseChangeIO progressManager "Validation Subs" $ "Starting " <> pack (show config.configNumValidationSubscriptions) <> " validation subscriptions"
    validationTime <- getCurrentTime
    validationSubscriptions <- forM [1..config.configNumValidationSubscriptions] $ \i -> do
      let subId = "validation-" <> pack (show i)
      (handle, stateRef) <- startHashTrackingSubscription store subId validationTime (Just progressManager)
      pure (handle, stateRef)

    mapM_ (modifyIORef' subscriptionsRef . (:)) validationSubscriptions

    reportPhaseChangeIO progressManager "Activating" "Waiting for subscriptions to activate"
    threadDelay 500_000

    reportPhaseChangeIO progressManager "Completion" "Sending completion event"
    completionTime <- getCurrentTime
    completionStream <- StreamId <$> UUID.nextRandom
    let completionPayload = CompletionPayload
          { completionId = "test-completion-" <> pack (show $ length transactionPlans)
          , completionTotalTransactions = length transactionPlans
          , totalExpectedEvents = totalEvents
          , completedAt = completionTime
          }

    void $ insertEvents store Nothing $
      Transaction (Map.singleton completionStream $ StreamWrite NoStream
        [SomeLatestEvent (Proxy @CompletionEvent) completionPayload])

    reportPhaseChangeIO progressManager "Waiting Complete" "Waiting for all subscriptions to receive completion event"

    allSubscriptions <- readIORef subscriptionsRef
    reportPhaseChangeIO progressManager "Waiting Complete" $ "Waiting for " <> pack (show (length allSubscriptions)) <> " subscriptions to complete"

    let completionMVars = map (\(_, stateRef) -> stateRef) allSubscriptions
    forConcurrently_ completionMVars $ \stateRef ->
      waitForCompletion stateRef
    reportPhaseChangeIO progressManager "Analyzing" "All subscriptions completed, collecting results"

    results <- forM allSubscriptions $ \(handle, stateRef) -> do
      state <- readIORef stateRef
      completedAt <- getCurrentTime
      handle.cancel  -- Clean up (should already be stopped)

      let processingDurationMs = case state.completionReceivedAt of
            Nothing -> 0
            Just eventCompletionTime ->
              round $ (fromRational $ toRational $ diffUTCTime eventCompletionTime state.startedAt) * (1000 :: Double)

      pure $ TestSubscriptionResult
        { resultSubscriptionId = state.subscriptionId
        , resultStartedAt = state.startedAt
        , resultFinalHash = state.currentHash
        , resultEventCount = state.subEventCount
        , resultFirstEventTime = state.firstEventTime
        , resultLastEventTime = state.lastEventTime
        , resultCompletedAt = completedAt
        , resultCompletionReceived = state.completionReceived
        , resultCompletionReceivedAt = state.completionReceivedAt
        , resultExpectedTotalEvents = state.expectedTotalEvents
        , resultProcessingDurationMs = processingDurationMs
        , resultPositionsSeen = state.positionsSeen
        }

    stopProgressReporting progressManager
    analyzeResults results

-- | Analyze subscription results for consistency
analyzeResults :: forall position. [TestSubscriptionResult position] -> Assertion
analyzeResults results = do
  putStrLn $ "\n=== Analysis of " ++ show (length results) ++ " subscriptions ==="

  let (earlyResults, concurrentResults, validationResults) =
        foldr (\r (e,c,v) ->
          if "early-" `isPrefixOf` r.resultSubscriptionId then (r:e,c,v)
          else if "concurrent-" `isPrefixOf` r.resultSubscriptionId then (e,r:c,v)
          else (e,c,r:v)
        ) ([],[],[]) results

  putStrLn $ "Early subscriptions: " ++ show (length earlyResults)
  putStrLn $ "Concurrent subscriptions: " ++ show (length concurrentResults)
  putStrLn $ "Validation subscriptions: " ++ show (length validationResults)

  let eventCounts = map (.resultEventCount) results
      minEvents = minimum eventCounts
      maxEvents = maximum eventCounts

  let avgEvents = fromIntegral (sum eventCounts) / fromIntegral (length eventCounts) :: Double
  putStrLn $ "Event counts - Min: " ++ show minEvents ++ ", Max: " ++ show maxEvents ++
             ", Avg: " ++ show (round avgEvents :: Int)

  let completedSubs = filter (.resultCompletionReceived) results
      incompleteSubs = filter (not . (.resultCompletionReceived)) results

  putStrLn $ "Completion status - Completed: " ++ show (length completedSubs) ++
             ", Incomplete: " ++ show (length incompleteSubs)

  let hashes = map (.resultFinalHash) results
      uniqueHashes = Set.size $ Set.fromList hashes

  putStrLn $ "Unique final hashes: " ++ show uniqueHashes

  putStrLn "\n=== SUMMARY STATISTICS ==="
  let processingDurations = map (.resultProcessingDurationMs) results
      minDuration = minimum processingDurations
      maxDuration = maximum processingDurations
      avgDuration = fromIntegral (sum processingDurations) / fromIntegral (length processingDurations) :: Double

  putStrLn $ "Processing durations - Min: " ++ show minDuration ++ "ms, Max: " ++
             show maxDuration ++ "ms, Avg: " ++ show (round avgDuration :: Int) ++ "ms"

  if uniqueHashes == 1
    then do
      putStrLn "\n✅ Hash consistency verified"

      when (minEvents /= maxEvents) $
        putStrLn $ "⚠️  Event count mismatch: min=" ++ show minEvents ++ ", max=" ++ show maxEvents

      let validationHashes = map (.resultFinalHash) validationResults
          earlyHashes = map (.resultFinalHash) earlyResults

      case (validationHashes, earlyHashes) of
        (vh:_, eh:_) -> assertEqual "Validation vs early mismatch" eh vh
        _ -> pure ()

    else do
      putStrLn "\n❌ Hash mismatch detected"
      let hashGroups = Map.fromListWith ((+) :: Int -> Int -> Int) [(h, (1::Int)) | h <- hashes]
      forM_ (Map.toList hashGroups) $ \(hash, count) ->
        putStrLn $ "  Hash " ++ show hash ++ ": " ++ show count ++ " subscriptions"

      assertFailure $ show uniqueHashes ++ " different hashes across " ++ show (length results) ++ " subscriptions"

-- | Generate test label from configuration parameters
generateTestLabel :: String -> TestConfiguration -> String
generateTestLabel testType config =
  let totalSubs = config.configNumEarlySubscriptions +
                  config.configNumConcurrentSubscriptions +
                  config.configNumValidationSubscriptions
  in testType ++ " consistency test (" ++
     show config.configNumTransactions ++ " tx, " ++
     show totalSubs ++ " subs)"

-- | Backend-agnostic ordering test suite
orderingTests
  :: forall backend.
     (EventStore backend, StoreConstraints backend IO, Show (Cursor backend))
  => EventStoreTestRunner backend
  -> [TestTree]
orderingTests runner =
  [ testGroup "Debug Tests"
    [ testCase (generateTestLabel "Debug" debugTestConfig)
        (testComprehensiveConsistencyWithConfig runner debugTestConfig)
    ],
    testGroup "Comprehensive Consistency Tests"
    [ testCase (generateTestLabel "Light" lightTestConfig)
        (testComprehensiveConsistencyWithConfig runner lightTestConfig),
      testCase (generateTestLabel "Standard" defaultTestConfig)
        (testComprehensiveConsistencyWithConfig runner defaultTestConfig),
      testCase (generateTestLabel "Stress" stressTestConfig)
        (testComprehensiveConsistencyWithConfig runner stressTestConfig)
    ]
  ]
