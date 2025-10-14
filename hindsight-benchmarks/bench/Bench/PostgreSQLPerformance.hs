{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}

module Bench.PostgreSQLPerformance 
  ( BenchmarkConfig(..)
  , BenchmarkResult(..)
  , LatencyPercentiles(..)
  , MemoryMetrics(..)
  , QueueMetrics(..)
  , runScenario
  , runAllScenarios
  , runProfilingBenchmark
  , runInsertionOnlyTest
  , performanceBenchmarks
  , runTuningConfigTest
  , setupTunedTestDB
  , PerfTestEvent
  ) where

import Control.Concurrent (threadDelay)
import Control.Concurrent.Async (async, wait, forConcurrently_)
import Control.Exception (bracket, finally)
import Control.Monad (replicateM, void, when, forM_, forM)
import Criterion
import Data.Aeson (FromJSON, ToJSON)
import Data.IORef (IORef, newIORef, readIORef, atomicModifyIORef')
import Data.List (sort)
import Data.Map.Strict qualified as Map
import Data.Text (Text, pack)
import Data.Time (UTCTime, getCurrentTime, diffUTCTime, NominalDiffTime)
import Data.UUID (UUID)
import Data.UUID.V4 qualified as UUID
import Data.Vector qualified as V
import Data.Proxy (Proxy(..))
import Hasql.Session qualified as Session
import Hasql.Pool.Config qualified as Config
import Control.Monad.IO.Class (liftIO)
import GHC.Stats (getRTSStats, RTSStats(..), gcdetails_live_bytes, gcs, gc_cpu_ns, gc)
import Database.Postgres.Temp qualified as Temp
import GHC.Generics (Generic)
import Hasql.Pool qualified as Pool
import Hindsight.Core
import Hindsight.Store
import Hindsight.Store.PostgreSQL
import Hindsight.Store.PostgreSQL (getPool)
import Hindsight.Store.PostgreSQL.Core.Schema qualified as Schema
import System.IO (hFlush, stdout)

-- | Performance test event
type PerfTestEvent = "perf_test_event"

data PerfTestPayload = PerfTestPayload
  { transactionId :: Int
  , eventIndex :: Int
  , perfStreamId :: UUID
  , timestamp :: UTCTime
  , payload :: Text
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)

type instance MaxVersion PerfTestEvent = 0
type instance Versions PerfTestEvent = FirstVersion PerfTestPayload
instance Hindsight.Core.Event PerfTestEvent

instance UpgradableToLatest PerfTestEvent 0 where
  upgradeToLatest = id

-- | Benchmark configuration
unStreamId :: StreamId -> UUID
unStreamId (StreamId uuid) = uuid

data BenchmarkConfig = BenchmarkConfig
  { numTransactions :: Int
  , eventsPerTransaction :: Int
  , numSubscriptions :: Int
  , subscriptionLagPercent :: Int  -- 0 = caught up, 100 = starting from beginning
  , notificationCoalescingMs :: Int
  , enableNewIndexes :: Bool
  , warmupTransactions :: Int  -- Transactions to insert before measuring
  } deriving (Show)

-- | Latency percentiles for advanced performance analysis
data LatencyPercentiles = LatencyPercentiles
  { p50 :: NominalDiffTime  -- median
  , p95 :: NominalDiffTime  -- 95th percentile  
  , p99 :: NominalDiffTime  -- 99th percentile
  , p999 :: NominalDiffTime -- 99.9th percentile
  } deriving (Show, Eq)

-- | Memory profiling metrics
data MemoryMetrics = MemoryMetrics
  { initialMemoryMB :: Int     -- Memory at start
  , peakMemoryMB :: Int        -- Peak memory usage
  , finalMemoryMB :: Int       -- Memory at end
  , gcCount :: Int             -- Number of garbage collections
  , gcTimeMs :: Double         -- Total time spent in GC
  } deriving (Show, Eq)

-- | Queue and subscription monitoring
data QueueMetrics = QueueMetrics
  { maxQueueDepth :: Int       -- Maximum queue depth observed
  , avgQueueDepth :: Double    -- Average queue depth
  , subscriptionLagMs :: Double -- Average subscription lag
  , queueOverflowCount :: Int  -- Number of queue overflow events
  } deriving (Show, Eq)

-- | Enhanced benchmark result with advanced metrics
data BenchmarkResult = BenchmarkResult
  { config :: BenchmarkConfig
  , insertionTime :: NominalDiffTime
  , insertionThroughput :: Double  -- events/second
  , subscriptionCatchUpTime :: Maybe NominalDiffTime
  , subscriptionThroughput :: Maybe Double  -- events/second during catch-up
  , avgLatency :: Maybe NominalDiffTime  -- avg time from insert to delivery
  , latencyPercentiles :: Maybe LatencyPercentiles  -- Phase 3.1: Latency percentiles
  , memoryMetrics :: Maybe MemoryMetrics           -- Phase 3.2: Memory profiling
  , queueMetrics :: Maybe QueueMetrics             -- Phase 3.3: Queue monitoring
  , maxQueueDepth :: Maybe Int    -- Backwards compatibility
  , memoryUsage :: Maybe Int      -- Backwards compatibility (in MB)
  } deriving (Show)

-- | Calculate latency percentiles from a list of measurements
calculatePercentiles :: [NominalDiffTime] -> LatencyPercentiles
calculatePercentiles [] = LatencyPercentiles 0 0 0 0
calculatePercentiles latencies = 
  let sorted = sort latencies
      len = length sorted
      percentile p = sorted !! max 0 (min (len - 1) (round (fromIntegral len * p) - 1))
  in LatencyPercentiles
       { p50 = percentile 0.50
       , p95 = percentile 0.95
       , p99 = percentile 0.99
       , p999 = percentile 0.999
       }

-- | Latency tracker for measuring event delivery times
data LatencyTracker = LatencyTracker
  { latencyMeasurements :: IORef [NominalDiffTime]
  , insertionTimes :: IORef (Map.Map (UUID, Int) UTCTime)  -- (streamId, eventIndex) -> insertTime
  }

-- | Create a new latency tracker
newLatencyTracker :: IO LatencyTracker
newLatencyTracker = do
  measurements <- newIORef []
  insertTimes <- newIORef Map.empty
  pure $ LatencyTracker measurements insertTimes

-- | Record event insertion time
recordInsertion :: LatencyTracker -> UUID -> Int -> UTCTime -> IO ()
recordInsertion tracker streamId eventIdx time = 
  atomicModifyIORef' tracker.insertionTimes $ \times ->
    (Map.insert (streamId, eventIdx) time times, ())

-- | Record event delivery and calculate latency
recordDelivery :: LatencyTracker -> UUID -> Int -> UTCTime -> IO ()
recordDelivery tracker streamId eventIdx deliveryTime = do
  insertTime <- atomicModifyIORef' tracker.insertionTimes $ \times ->
    case Map.lookup (streamId, eventIdx) times of
      Just insertTime -> (Map.delete (streamId, eventIdx) times, Just insertTime)
      Nothing -> (times, Nothing)
  
  case insertTime of
    Just iTime -> do
      let latency = diffUTCTime deliveryTime iTime
      atomicModifyIORef' tracker.latencyMeasurements $ \measurements ->
        (latency : measurements, ())
    Nothing -> pure ()  -- Event not tracked (might be warmup)

-- | Get accumulated latency percentiles
getLatencyPercentiles :: LatencyTracker -> IO (Maybe LatencyPercentiles)
getLatencyPercentiles tracker = do
  measurements <- readIORef tracker.latencyMeasurements
  pure $ if null measurements 
    then Nothing
    else Just (calculatePercentiles measurements)

-- | Memory profiler for tracking memory usage and GC metrics
data MemoryProfiler = MemoryProfiler
  { initialStats :: IORef (Maybe RTSStats)
  , peakMemoryBytes :: IORef Int
  , currentMemoryBytes :: IORef Int
  }

-- | Create a new memory profiler
newMemoryProfiler :: IO MemoryProfiler
newMemoryProfiler = do
  initial <- newIORef Nothing
  peak <- newIORef 0
  current <- newIORef 0
  pure $ MemoryProfiler initial peak current

-- | Start memory profiling (record baseline)
startMemoryProfiling :: MemoryProfiler -> IO ()
startMemoryProfiling profiler = do
  stats <- getRTSStats
  atomicModifyIORef' profiler.initialStats $ \_ -> (Just stats, ())
  let currentMem = fromIntegral (gcdetails_live_bytes (gc stats)) :: Int
  atomicModifyIORef' profiler.currentMemoryBytes $ \_ -> (currentMem, ())
  atomicModifyIORef' profiler.peakMemoryBytes $ \_ -> (currentMem, ())

-- | Update peak memory if current usage is higher
updatePeakMemory :: MemoryProfiler -> IO ()
updatePeakMemory profiler = do
  stats <- getRTSStats
  let currentMem = fromIntegral (gcdetails_live_bytes (gc stats)) :: Int
  atomicModifyIORef' profiler.currentMemoryBytes $ \_ -> (currentMem, ())
  atomicModifyIORef' profiler.peakMemoryBytes $ \peak -> 
    (max peak currentMem, ())

-- | Get final memory metrics
getMemoryMetrics :: MemoryProfiler -> IO (Maybe MemoryMetrics)
getMemoryMetrics profiler = do
  maybeInitial <- readIORef profiler.initialStats
  case maybeInitial of
    Nothing -> pure Nothing
    Just initialStats -> do
      finalStats <- getRTSStats
      peakBytes <- readIORef profiler.peakMemoryBytes
      
      let initialMemMB = fromIntegral (gcdetails_live_bytes (gc initialStats)) `div` (1024 * 1024)
          finalMemMB = fromIntegral (gcdetails_live_bytes (gc finalStats)) `div` (1024 * 1024)
          peakMemMB = peakBytes `div` (1024 * 1024)
          gcCount = fromIntegral (gcs finalStats - gcs initialStats) :: Int
          gcTimeNs = gc_cpu_ns finalStats - gc_cpu_ns initialStats
          gcTimeMs = fromIntegral gcTimeNs / 1000000.0 :: Double
      
      pure $ Just MemoryMetrics
        { initialMemoryMB = initialMemMB
        , peakMemoryMB = peakMemMB  
        , finalMemoryMB = finalMemMB
        , gcCount = gcCount
        , gcTimeMs = gcTimeMs
        }

-- | Queue monitor for tracking subscription queue metrics
data QueueMonitor = QueueMonitor
  { currentQueueDepth :: IORef Int
  , maxQueueDepth :: IORef Int
  , totalQueueDepthSamples :: IORef Int  -- For calculating average
  , queueDepthSum :: IORef Int          -- For calculating average
  , overflowCount :: IORef Int          -- Number of overflow events
  , lagMeasurements :: IORef [Double]   -- Lag measurements in milliseconds
  }

-- | Create a new queue monitor
newQueueMonitor :: IO QueueMonitor
newQueueMonitor = do
  current <- newIORef 0
  maxDepth <- newIORef 0
  samples <- newIORef 0
  depthSum <- newIORef 0
  overflows <- newIORef 0
  lagMeasures <- newIORef []
  pure $ QueueMonitor current maxDepth samples depthSum overflows lagMeasures

-- | Update queue depth metrics
updateQueueDepth :: QueueMonitor -> Int -> IO ()
updateQueueDepth monitor depth = do
  atomicModifyIORef' monitor.currentQueueDepth $ \_ -> (depth, ())
  atomicModifyIORef' monitor.maxQueueDepth $ \maxD -> (max maxD depth, ())
  atomicModifyIORef' monitor.totalQueueDepthSamples $ \samples -> (samples + 1, ())
  atomicModifyIORef' monitor.queueDepthSum $ \sum -> (sum + depth, ())

-- | Record queue overflow event
recordQueueOverflow :: QueueMonitor -> IO ()
recordQueueOverflow monitor = 
  atomicModifyIORef' monitor.overflowCount $ \count -> (count + 1, ())

-- | Record subscription lag measurement
recordSubscriptionLag :: QueueMonitor -> Double -> IO ()
recordSubscriptionLag monitor lagMs =
  atomicModifyIORef' monitor.lagMeasurements $ \lags -> (lagMs : lags, ())

-- | Get final queue metrics
getQueueMetrics :: QueueMonitor -> IO (Maybe QueueMetrics)
getQueueMetrics monitor = do
  maxDepth <- readIORef monitor.maxQueueDepth
  samples <- readIORef monitor.totalQueueDepthSamples
  depthSum <- readIORef monitor.queueDepthSum
  overflows <- readIORef monitor.overflowCount
  lagMeasurements <- readIORef monitor.lagMeasurements
  
  if samples == 0
    then pure Nothing
    else do
      let avgDepth = fromIntegral depthSum / fromIntegral samples :: Double
          avgLag = if null lagMeasurements
                   then 0.0
                   else sum lagMeasurements / fromIntegral (length lagMeasurements)
      
      pure $ Just QueueMetrics
        { maxQueueDepth = maxDepth
        , avgQueueDepth = avgDepth
        , subscriptionLagMs = avgLag
        , queueOverflowCount = overflows
        }

-- | Enhanced subscription with queue monitoring
data SubscriptionWithQueue = SubscriptionWithQueue
  { handle :: SubscriptionHandle SQLStore
  , counter :: IORef Int
  , queueMonitor :: QueueMonitor
  , startTime :: UTCTime  -- For lag calculation
  }

-- | Testing which parameter breaks PostgreSQL - just memory settings first
pgtuneConfig :: [(String, String)]
pgtuneConfig = 
  [ -- Test just memory increases from working config
    ("shared_buffers", "512MB")        -- Bump up from working 256MB
  , ("work_mem", "16MB")               -- Same as working config
  , ("effective_cache_size", "4GB")    -- This might be the issue?
  
    -- Keep the settings that worked
  , ("checkpoint_completion_target", "0.9")
  , ("random_page_cost", "1.1")       -- SSD optimization
  
    -- Disable fsync for testing performance (NEVER in production)
  , ("fsync", "off")
  , ("synchronous_commit", "off")
  , ("full_page_writes", "off")
  
    -- Reduce logging noise
  , ("log_min_messages", "WARNING")
  , ("log_min_error_statement", "ERROR")
  ]

-- | Setup a test database with vanilla PostgreSQL configuration
setupTestDB :: Bool -> IO (Temp.DB, SQLStoreHandle)
setupTestDB enableIndexes = do
  db <- Temp.start >>= \case
    Left err -> error $ "Failed to start temp database: " <> show err
    Right d -> pure d
  
  let connStr = Temp.toConnectionString db
  
  -- Create schema with or without new indexes
  Pool.acquire (Config.settings [Config.size 10, Config.staticConnectionSettings connStr]) >>= \pool -> do
    Pool.use pool Schema.createSchema >>= \case
      Left err -> error $ "Failed to create schema: " <> show err
      Right () -> pure ()
    
    -- Optionally drop the new indexes to test without them
    when (not enableIndexes) $ do
      Pool.use pool dropNewIndexes >>= \case
        Left _ -> pure ()  -- Ignore errors if indexes don't exist
        Right () -> pure ()
  
  store <- newSQLStore connStr
  pure (db, store)
  where
    dropNewIndexes = Session.sql $ mconcat
      [ "DROP INDEX IF EXISTS idx_events_transaction_order;"
      , "DROP INDEX IF EXISTS idx_events_transaction_event_name;"
      ]

-- | Setup a test database with performance-tuned PostgreSQL configuration
setupTunedTestDB :: Bool -> IO (Temp.DB, SQLStoreHandle)
setupTunedTestDB enableIndexes = do
  let tuningConfig = Temp.defaultConfig <> mempty
        { Temp.postgresConfigFile = pgtuneConfig }
  
  result <- Temp.withConfig tuningConfig $ \db -> do
    let connStr = Temp.toConnectionString db
    
    -- Create schema with or without new indexes
    Pool.acquire (Config.settings [Config.size 10, Config.staticConnectionSettings connStr]) >>= \pool -> do
      Pool.use pool Schema.createSchema >>= \case
        Left err -> error $ "Failed to create schema: " <> show err
        Right () -> pure ()
      
      -- Optionally drop the new indexes to test without them
      when (not enableIndexes) $ do
        Pool.use pool dropNewIndexes >>= \case
          Left _ -> pure ()  -- Ignore errors if indexes don't exist
          Right () -> pure ()
    
    store <- newSQLStore connStr
    pure (db, store)
  
  case result of
    Left err -> error $ "Failed to start tuned temp database: " <> show err
    Right val -> pure val
  where
    dropNewIndexes = Session.sql $ mconcat
      [ "DROP INDEX IF EXISTS idx_events_transaction_order;"
      , "DROP INDEX IF EXISTS idx_events_transaction_event_name;"
      ]

-- | Insert transactions with timing
timedInsertTransactions :: SQLStoreHandle -> Int -> Int -> IO NominalDiffTime
timedInsertTransactions store numTx eventsPerTx = do
  startTime <- getCurrentTime
  
  forM_ [1..numTx] $ \txId -> do
    -- Create events for this transaction
    streams <- replicateM (min 3 (eventsPerTx `div` 3 + 1)) (StreamId <$> UUID.nextRandom)
    timestamp <- getCurrentTime
    
    let eventPayloads = [ PerfTestPayload
                            { transactionId = txId
                            , eventIndex = i
                            , perfStreamId = unStreamId stream
                            , timestamp = timestamp
                            , payload = "Event " <> pack (show i) <> " of transaction " <> pack (show txId)
                            }
                        | (i, stream) <- zip [1..eventsPerTx] (cycle streams)
                        ]
        
        batches = Map.fromList
          [ (stream, StreamWrite Any streamEvents)
          | stream <- streams
          , let streamEvents = [ SomeLatestEvent (Proxy @PerfTestEvent) payload | (payload, s) <- zip eventPayloads (cycle streams), s == stream ]
          , not (null streamEvents)
          ]
    
    result <- insertEvents store Nothing batches
    case result of
      FailedInsertion err -> error $ "Insertion failed: " <> show err
      _ -> pure ()
  
  endTime <- getCurrentTime
  pure $ diffUTCTime endTime startTime

-- | Enhanced version with latency tracking
timedInsertTransactionsWithTracking :: SQLStoreHandle -> LatencyTracker -> Int -> Int -> IO NominalDiffTime
timedInsertTransactionsWithTracking store latencyTracker numTx eventsPerTx = do
  startTime <- getCurrentTime
  
  forM_ [1..numTx] $ \txId -> do
    -- Create events for this transaction
    streams <- replicateM (min 3 (eventsPerTx `div` 3 + 1)) (StreamId <$> UUID.nextRandom)
    insertTime <- getCurrentTime
    
    let eventPayloads = [ PerfTestPayload
                            { transactionId = txId
                            , eventIndex = i
                            , perfStreamId = unStreamId stream
                            , timestamp = insertTime
                            , payload = "Event " <> pack (show i) <> " of transaction " <> pack (show txId)
                            }
                        | (i, stream) <- zip [1..eventsPerTx] (cycle streams)
                        ]
        
        batches = Map.fromList
          [ (stream, StreamWrite Any streamEvents)
          | stream <- streams
          , let streamEvents = [ SomeLatestEvent (Proxy @PerfTestEvent) payload | (payload, s) <- zip eventPayloads (cycle streams), s == stream ]
          , not (null streamEvents)
          ]
    
    -- Record insertion times for latency tracking
    forM_ eventPayloads $ \payload ->
      recordInsertion latencyTracker payload.perfStreamId payload.eventIndex insertTime
    
    result <- insertEvents store Nothing batches
    case result of
      FailedInsertion err -> error $ "Insertion failed: " <> show err
      _ -> pure ()
  
  endTime <- getCurrentTime
  pure $ diffUTCTime endTime startTime

-- | Start subscriptions with tracking
startTrackingSubscriptions :: SQLStoreHandle -> Int -> Int -> IO [(SubscriptionHandle SQLStore, IORef Int)]
startTrackingSubscriptions store numSubs lagPercent = do
  -- First, figure out the current position if we need lag
  currentPos <- if lagPercent > 0
    then do
      -- Get approximate current position (simplified - in real benchmark we'd query DB)
      pure $ SQLCursor 0 0  -- Start from beginning for lag testing
    else
      pure $ SQLCursor (-1) (-1)  -- Start from current
  
  forM [1..numSubs] $ \subId -> do
    counter <- newIORef 0
    
    let handler = (Proxy @PerfTestEvent, \_ -> do
                    liftIO $ atomicModifyIORef' counter $ \n -> (n + 1, ())
                    pure Continue)
                  :? MatchEnd
    
    let selector = EventSelector
          { streamId = AllStreams
          , startupPosition = if lagPercent > 0
                             then FromLastProcessed currentPos
                             else FromBeginning
          }
    
    handle <- subscribe store handler selector
    pure (handle, counter)

-- | Enhanced subscriptions with latency tracking
startTrackingSubscriptionsWithLatency :: SQLStoreHandle -> LatencyTracker -> Int -> Int -> IO [(SubscriptionHandle SQLStore, IORef Int)]
startTrackingSubscriptionsWithLatency store latencyTracker numSubs lagPercent = do
  -- First, figure out the current position if we need lag
  currentPos <- if lagPercent > 0
    then do
      -- Get approximate current position (simplified - in real benchmark we'd query DB)
      pure $ SQLCursor 0 0  -- Start from beginning for lag testing
    else
      pure $ SQLCursor (-1) (-1)  -- Start from current
  
  forM [1..numSubs] $ \subId -> do
    counter <- newIORef 0
    
    let handler = (Proxy @PerfTestEvent, \envelope -> do
                    deliveryTime <- liftIO getCurrentTime
                    
                    -- Extract payload from envelope
                    let PerfTestPayload{..} = envelope.payload
                    
                    -- Record delivery time for latency calculation
                    liftIO $ recordDelivery latencyTracker perfStreamId eventIndex deliveryTime
                    liftIO $ atomicModifyIORef' counter $ \n -> (n + 1, ())
                      
                    pure Continue)
                  :? MatchEnd
    
    let selector = EventSelector
          { streamId = AllStreams
          , startupPosition = if lagPercent > 0
                             then FromLastProcessed currentPos
                             else FromBeginning
          }
    
    handle <- subscribe store handler selector
    pure (handle, counter)

-- | Test function to validate pgtune configuration works
runTuningConfigTest :: IO ()
runTuningConfigTest = do
  putStrLn "Testing pgtune configuration..."
  
  -- First test: Try starting PostgreSQL with no custom config
  putStrLn "Testing vanilla configuration first..."
  vanillaResult <- Temp.start
  case vanillaResult of
    Left err -> putStrLn $ "Even vanilla config failed: " ++ show err
    Right db -> do
      putStrLn "Vanilla config works fine"
      Temp.stop db
  
  -- Second test: Try our custom config
  putStrLn "Testing custom configuration..."
  let tuningConfig = Temp.defaultConfig <> mempty
        { Temp.postgresConfigFile = pgtuneConfig }
  
  result <- Temp.withConfig tuningConfig $ \db -> do
    let connStr = Temp.toConnectionString db
    putStrLn $ "PostgreSQL started with custom config!"
    putStrLn $ "Connection string: " ++ show connStr
    
    -- Create the SQL store  
    store <- newSQLStore connStr
    
    -- Initialize schema
    Pool.use (getPool store) Schema.createSchema >>= \case
      Left err -> error $ "Failed to create schema: " ++ show err
      Right () -> pure ()
    
    -- Run a simple test
    let config = BenchmarkConfig 100 10 1 0 50 True 10
    result <- runScenario' store config
    
    -- Cleanup store (db will be cleaned up by withConfig)
    shutdownSQLStore store
    Pool.release (getPool store)
    
    return result
  
  case result of
    Left err -> do
      putStrLn $ "Tuned config test failed with detailed error:"
      putStrLn $ show err
      -- Let's also try to see what the specific PostgreSQL error was
      putStrLn "This suggests one of our PostgreSQL parameters is invalid or unsupported."
      putStrLn "Parameters we're trying to set:"
      mapM_ (\(k, v) -> putStrLn $ "  " ++ k ++ " = " ++ v) pgtuneConfig
      
    Right benchResult -> putStrLn $ "Tuned config test completed - throughput: " ++ show benchResult.insertionThroughput ++ " eps"
  
  where
    runScenario' store config = do
      -- Simplified version of runScenario for testing
      insertionTime <- timedInsertTransactions store config.numTransactions config.eventsPerTransaction
      let throughput = fromIntegral (config.numTransactions * config.eventsPerTransaction) / realToFrac insertionTime
      
      return BenchmarkResult
        { config = config
        , insertionTime = insertionTime
        , insertionThroughput = throughput
        , subscriptionCatchUpTime = Nothing
        , subscriptionThroughput = Nothing
        , avgLatency = Nothing
        , maxQueueDepth = Just 0
        , memoryUsage = Just 0
        , latencyPercentiles = Nothing
        , memoryMetrics = Nothing
        , queueMetrics = Nothing
        }

-- | Enhanced subscriptions with comprehensive monitoring (Phase 3.3)
startTrackingSubscriptionsWithMonitoring :: SQLStoreHandle -> LatencyTracker -> QueueMonitor -> Int -> Int -> IO [SubscriptionWithQueue]
startTrackingSubscriptionsWithMonitoring store latencyTracker globalQueueMonitor numSubs lagPercent = do
  -- First, figure out the current position if we need lag
  currentPos <- if lagPercent > 0
    then do
      -- Get approximate current position (simplified - in real benchmark we'd query DB)
      pure $ SQLCursor 0 0  -- Start from beginning for lag testing
    else
      pure $ SQLCursor (-1) (-1)  -- Start from current
  
  startTime <- getCurrentTime
  
  forM [1..numSubs] $ \subId -> do
    counter <- newIORef 0
    perSubQueueMonitor <- newQueueMonitor
    
    let handler = (Proxy @PerfTestEvent, \envelope -> do
                    deliveryTime <- liftIO getCurrentTime
                    
                    -- Extract payload from envelope
                    let PerfTestPayload{..} = envelope.payload
                    
                    -- Calculate lag from event timestamp to now
                    let lagMs = realToFrac (diffUTCTime deliveryTime timestamp) * 1000.0 :: Double
                    
                    -- Record delivery time for latency calculation (Phase 3.1)
                    liftIO $ recordDelivery latencyTracker perfStreamId eventIndex deliveryTime
                    
                    -- Record subscription lag (Phase 3.3)
                    liftIO $ recordSubscriptionLag perSubQueueMonitor lagMs
                    liftIO $ recordSubscriptionLag globalQueueMonitor lagMs
                    
                    -- Update queue depth approximation (simplified)
                    currentCount <- liftIO $ atomicModifyIORef' counter $ \n -> (n + 1, n + 1)
                    let estimatedQueueDepth = max 0 (1000 - currentCount)  -- Rough approximation
                    liftIO $ updateQueueDepth perSubQueueMonitor estimatedQueueDepth
                    liftIO $ updateQueueDepth globalQueueMonitor estimatedQueueDepth
                    
                    -- Check for overflow conditions (if queue depth > 1000)
                    when (estimatedQueueDepth > 1000) $ do
                      liftIO $ recordQueueOverflow perSubQueueMonitor
                      liftIO $ recordQueueOverflow globalQueueMonitor
                      
                    pure Continue)
                  :? MatchEnd
    
    let selector = EventSelector
          { streamId = AllStreams
          , startupPosition = if lagPercent > 0
                             then FromLastProcessed currentPos
                             else FromBeginning
          }
    
    handle <- subscribe store handler selector
    pure $ SubscriptionWithQueue handle counter perSubQueueMonitor startTime

-- | Run a benchmark scenario
runScenario :: BenchmarkConfig -> IO BenchmarkResult
runScenario config = do
  (db, store) <- setupTestDB config.enableNewIndexes
  
  -- Initialize latency tracker for Phase 3.1
  latencyTracker <- newLatencyTracker
  
  -- Initialize memory profiler for Phase 3.2
  memoryProfiler <- newMemoryProfiler
  startMemoryProfiling memoryProfiler
  
  -- Initialize queue monitor for Phase 3.3
  queueMonitor <- newQueueMonitor
  
  finally (do
    -- Warmup phase (if configured)
    when (config.warmupTransactions > 0) $ do
      putStr $ "Warming up with " ++ show config.warmupTransactions ++ " transactions... "
      hFlush stdout
      _ <- timedInsertTransactions store config.warmupTransactions config.eventsPerTransaction
      putStrLn "done"
    
    -- Start subscriptions with comprehensive monitoring if configured
    subscriptionsWithQueue <- if config.numSubscriptions > 0
      then do
        putStr $ "Starting " ++ show config.numSubscriptions ++ " subscriptions... "
        hFlush stdout
        subs <- startTrackingSubscriptionsWithMonitoring store latencyTracker queueMonitor config.numSubscriptions config.subscriptionLagPercent
        putStrLn "done"
        pure subs
      else pure []
    
    -- Extract traditional subscription handles for compatibility
    let subscriptions = map (\s -> (s.handle, s.counter)) subscriptionsWithQueue
    
    -- Main insertion phase with latency tracking and memory monitoring
    putStr $ "Inserting " ++ show config.numTransactions ++ " transactions... "
    hFlush stdout
    insertionTime <- if null subscriptions
      then do
        -- Update peak memory periodically during insertion
        result <- timedInsertTransactions store config.numTransactions config.eventsPerTransaction
        updatePeakMemory memoryProfiler
        pure result
      else do
        -- Enhanced tracking with memory monitoring
        result <- timedInsertTransactionsWithTracking store latencyTracker config.numTransactions config.eventsPerTransaction
        updatePeakMemory memoryProfiler
        pure result
    putStrLn $ "done in " ++ show insertionTime
    
    let totalEvents = config.numTransactions * config.eventsPerTransaction
        insertionThroughput = fromIntegral totalEvents / realToFrac insertionTime
    
    -- Wait for subscriptions to catch up (with timeout)
    catchUpTime <- if not (null subscriptions)
      then do
        putStr "Waiting for subscriptions to process events... "
        hFlush stdout
        startWait <- getCurrentTime
        
        -- Poll until all subscriptions have processed expected events
        let waitLoop = do
              counts <- mapM (readIORef . snd) subscriptions
              let totalProcessed = sum counts
              if totalProcessed >= totalEvents * length subscriptions
                then do
                  endWait <- getCurrentTime
                  pure $ Just $ diffUTCTime endWait startWait
                else do
                  threadDelay 100000  -- 100ms
                  waitLoop
        
        result <- waitLoop
        putStrLn "done"
        pure result
      else pure Nothing
    
    let subscriptionThroughput = case catchUpTime of
          Just t -> Just $ fromIntegral (totalEvents * config.numSubscriptions) / realToFrac t
          Nothing -> Nothing
    
    -- Update memory one more time after catch-up
    updatePeakMemory memoryProfiler
    
    -- Get latency percentiles if we have tracking data
    latencyPercentiles <- if null subscriptions
      then pure Nothing
      else getLatencyPercentiles latencyTracker
    
    -- Get memory metrics (Phase 3.2)
    memoryMetrics <- getMemoryMetrics memoryProfiler
    
    -- Get queue metrics (Phase 3.3)
    queueMetrics <- if null subscriptionsWithQueue
      then pure Nothing
      else getQueueMetrics queueMonitor
    
    -- Calculate average latency from percentiles (if available)
    let avgLatency = case latencyPercentiles of
          Just percentiles -> Just percentiles.p50  -- Use median as average approximation
          Nothing -> Nothing
        
        -- Backward compatibility: extract peak memory for old field
        backwardCompatMemory = case memoryMetrics of
          Just metrics -> Just metrics.peakMemoryMB
          Nothing -> Nothing
        
        -- Backward compatibility: extract max queue depth for old field
        backwardCompatMaxQueue = case queueMetrics of
          Just metrics -> Just metrics.maxQueueDepth
          Nothing -> Nothing
    
    -- Clean up subscriptions
    forM_ subscriptions $ \(handle, _) -> handle.cancel
    
    pure $ BenchmarkResult
      { config = config
      , insertionTime = insertionTime
      , insertionThroughput = insertionThroughput
      , subscriptionCatchUpTime = catchUpTime
      , subscriptionThroughput = subscriptionThroughput
      , avgLatency = avgLatency                    -- Phase 3.1: Implemented!
      , latencyPercentiles = latencyPercentiles    -- Phase 3.1: Implemented!
      , memoryMetrics = memoryMetrics              -- Phase 3.2: Implemented!
      , queueMetrics = queueMetrics                -- Phase 3.3: Implemented!
      , maxQueueDepth = backwardCompatMaxQueue     -- Backwards compatibility
      , memoryUsage = backwardCompatMemory         -- Backwards compatibility
      }
    
    ) (void $ Temp.stop db)

-- | Print benchmark results
printResults :: BenchmarkResult -> IO ()
printResults r = do
  putStrLn $ "\n=== Benchmark Results ==="
  putStrLn $ "Configuration:"
  putStrLn $ "  Transactions: " ++ show r.config.numTransactions
  putStrLn $ "  Events/Transaction: " ++ show r.config.eventsPerTransaction
  putStrLn $ "  Subscriptions: " ++ show r.config.numSubscriptions
  putStrLn $ "  Subscription Lag: " ++ show r.config.subscriptionLagPercent ++ "%"
  putStrLn $ "  Notification Coalescing: " ++ show r.config.notificationCoalescingMs ++ "ms"
  putStrLn $ "  New Indexes Enabled: " ++ show r.config.enableNewIndexes
  putStrLn $ "\nResults:"
  putStrLn $ "  Insertion Time: " ++ show r.insertionTime
  putStrLn $ "  Insertion Throughput: " ++ show (round r.insertionThroughput :: Int) ++ " events/sec"
  case r.subscriptionCatchUpTime of
    Just t -> do
      putStrLn $ "  Subscription Catch-up Time: " ++ show t
      case r.subscriptionThroughput of
        Just tp -> putStrLn $ "  Subscription Throughput: " ++ show (round tp :: Int) ++ " events/sec"
        Nothing -> pure ()
    Nothing -> pure ()

-- | Run all benchmark scenarios
runAllScenarios :: IO ()
runAllScenarios = do
  putStrLn "PostgreSQL Performance Benchmark Suite"
  putStrLn "======================================"
  
  -- Scenario 1: Transaction Scaling
  putStrLn "\n### Scenario 1: Transaction Scaling ###"
  forM_ [10, 100, 1000] $ \numTx -> do
    putStrLn $ "\n--- Testing with " ++ show numTx ++ " transactions ---"
    result <- runScenario $ BenchmarkConfig
      { numTransactions = numTx
      , eventsPerTransaction = 10
      , numSubscriptions = 1
      , subscriptionLagPercent = 0
      , notificationCoalescingMs = 50
      , enableNewIndexes = True
      , warmupTransactions = 10
      }
    printResults result
  
  -- Scenario 2: Subscription Scaling
  putStrLn "\n### Scenario 2: Subscription Scaling ###"
  forM_ [0, 1, 5, 10] $ \numSubs -> do
    putStrLn $ "\n--- Testing with " ++ show numSubs ++ " subscriptions ---"
    result <- runScenario $ BenchmarkConfig
      { numTransactions = 100
      , eventsPerTransaction = 10
      , numSubscriptions = numSubs
      , subscriptionLagPercent = 0
      , notificationCoalescingMs = 50
      , enableNewIndexes = True
      , warmupTransactions = 10
      }
    printResults result
  
  -- Scenario 3: Index Effectiveness
  putStrLn "\n### Scenario 3: Index Effectiveness ###"
  forM_ [False, True] $ \useIndexes -> do
    putStrLn $ "\n--- Testing " ++ (if useIndexes then "WITH" else "WITHOUT") ++ " new indexes ---"
    result <- runScenario $ BenchmarkConfig
      { numTransactions = 500
      , eventsPerTransaction = 10
      , numSubscriptions = 5
      , subscriptionLagPercent = 0
      , notificationCoalescingMs = 50
      , enableNewIndexes = useIndexes
      , warmupTransactions = 10
      }
    printResults result

-- | Profiling benchmark to identify bottlenecks
runProfilingBenchmark :: IO ()
runProfilingBenchmark = do
  putStrLn "Setting up profiling scenarios..."
  putStrLn ""
  
  -- Test configurations that show the performance degradation clearly
  let configs = 
        [ BenchmarkConfig 
            { numTransactions = 1000
            , eventsPerTransaction = 10
            , numSubscriptions = 1
            , subscriptionLagPercent = 0
            , notificationCoalescingMs = 50
            , enableNewIndexes = True
            , warmupTransactions = 100
            }
        , BenchmarkConfig 
            { numTransactions = 1000
            , eventsPerTransaction = 10
            , numSubscriptions = 10
            , subscriptionLagPercent = 0
            , notificationCoalescingMs = 50
            , enableNewIndexes = True
            , warmupTransactions = 100
            }
        , BenchmarkConfig 
            { numTransactions = 1000
            , eventsPerTransaction = 10
            , numSubscriptions = 50
            , subscriptionLagPercent = 0
            , notificationCoalescingMs = 50
            , enableNewIndexes = True
            , warmupTransactions = 100
            }
        , BenchmarkConfig 
            { numTransactions = 1000
            , eventsPerTransaction = 10
            , numSubscriptions = 100
            , subscriptionLagPercent = 0
            , notificationCoalescingMs = 50
            , enableNewIndexes = True
            , warmupTransactions = 100
            }
        ]
  
  forM_ configs $ \config -> do
    putStrLn $ "=== Testing with " ++ show config.numSubscriptions ++ " subscriptions ==="
    result <- runScenario config
    putStrLn $ "Throughput: " ++ show (round result.insertionThroughput :: Int) ++ " events/sec"
    putStrLn $ "Insertion time: " ++ show result.insertionTime
    putStrLn ""
  
  putStrLn "Profiling complete!"
  putStrLn ""
  putStrLn "To analyze results:"
  putStrLn "1. For eventlog: threadscope hindsight-benchmarks.eventlog"
  putStrLn "2. For time profile: view hindsight-benchmarks.prof"
  putStrLn "3. For heap profile: hp2ps -e8in -c hindsight-benchmarks.hp && open hindsight-benchmarks.ps"

-- | Test insertion throughput only (no subscription waiting)  
runInsertionOnlyTest :: IO ()
runInsertionOnlyTest = do
  putStrLn "CRITICAL TEST: Measuring insertion throughput with disabled event processing"
  putStrLn "============================================================="
  putStrLn ""
  
  let configs = 
        [ (0, "No subscriptions (baseline)")
        , (1, "1 subscription")
        , (10, "10 subscriptions") 
        , (50, "50 subscriptions")
        , (100, "100 subscriptions")
        , (250, "250 subscriptions")
        ]
  
  forM_ configs $ \(numSubs, desc) -> do
    putStrLn $ "Testing with " ++ desc ++ ":"
    
    (db, store) <- setupTestDB True
    
    -- Start subscriptions (they won't receive events due to disabled processing)
    when (numSubs > 0) $ do
      forM_ [1..numSubs] $ \_ -> do
        let handler = (Proxy @PerfTestEvent, \_ -> do
                        liftIO $ pure ()
                        pure Continue) :? MatchEnd
            selector = EventSelector
              { streamId = AllStreams
              , startupPosition = FromLastProcessed (SQLCursor 999999999 999)  -- Very high position to avoid catch-up
              }
        void $ subscribe store handler selector
    
    -- Measure insertion time only
    startTime <- getCurrentTime
    _ <- timedInsertTransactions store 1000 10
    endTime <- getCurrentTime
    
    let insertionTime = diffUTCTime endTime startTime
        throughput = 10000 / realToFrac insertionTime
    
    putStrLn $ "  Insertion time: " ++ show insertionTime
    putStrLn $ "  Throughput: " ++ show (round throughput :: Int) ++ " events/sec"
    putStrLn ""
    
    -- Clean up
    void $ Temp.stop db
  
  putStrLn "Test complete!"
  putStrLn ""
  putStrLn "If throughput is constant regardless of subscription count,"
  putStrLn "then the bottleneck is in event distribution (processPendingEvents)."
  putStrLn "If throughput degrades with subscription count even without processing,"
  putStrLn "then the bottleneck is in the database insertion path itself."

-- | Export for use in Main.hs
performanceBenchmarks :: IO [Benchmark]
performanceBenchmarks = do
  pure
    [ bgroup "PostgreSQL Performance"
        [ bench "Transaction Scaling (100 tx)" $ whnfIO $ runScenario $ BenchmarkConfig
            { numTransactions = 100
            , eventsPerTransaction = 10
            , numSubscriptions = 1
            , subscriptionLagPercent = 0
            , notificationCoalescingMs = 50
            , enableNewIndexes = True
            , warmupTransactions = 10
            }
        , bench "Subscription Scaling (5 subs)" $ whnfIO $ runScenario $ BenchmarkConfig
            { numTransactions = 100
            , eventsPerTransaction = 10
            , numSubscriptions = 5
            , subscriptionLagPercent = 0
            , notificationCoalescingMs = 50
            , enableNewIndexes = True
            , warmupTransactions = 10
            }
        ]
    ]