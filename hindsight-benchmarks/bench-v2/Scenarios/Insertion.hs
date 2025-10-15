{-# LANGUAGE DataKinds #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

module Scenarios.Insertion 
  ( runStandardSuite
  , runInsertionBenchmarks
  , makeBenchEvent
  , makeBenchEventBatch
  ) where

import Backends.Common
import Core.Metrics
import Core.Types
import Core.Types qualified as CT
import Criterion
import Criterion.Main (defaultMain)
import Data.Proxy (Proxy(..))
import Data.Text (pack)
import Data.UUID.V4 qualified as UUID
import Hindsight.Core
import Hindsight.Store

-- | Generate benchmark event of specified size
makeBenchEvent :: Int -> Int -> SomeLatestEvent
makeBenchEvent eventId sizeBytes =
  SomeLatestEvent (Proxy @BenchEvent) $
    BenchPayload
      { eventData = pack $ replicate sizeBytes 'x'
      , eventSize = sizeBytes
      , benchTimestamp = "bench-v2-" <> pack (show eventId)
      }

-- | Generate a batch of benchmark events
makeBenchEventBatch :: Int -> Int -> [SomeLatestEvent]
makeBenchEventBatch count sizeBytes =
  [makeBenchEvent i sizeBytes | i <- [1..count]]

-- | Run the standard insertion benchmark suite
runStandardSuite :: IO ()
runStandardSuite = do
  putStrLn "Running insertion benchmarks across all stores..."
  
  -- Get benchmarks for all backends
  memBenchmarks <- singleStoreBenchmarks memoryRunner
  fsBenchmarks <- singleStoreBenchmarks filesystemRunner  
  pgBenchmarks <- singleStoreBenchmarks postgresqlRunner
  
  -- Run them all
  defaultMain $
    [ bgroup "Insertion Benchmarks" $
        [ bgroup "Memory Store" memBenchmarks
        , bgroup "Filesystem Store" fsBenchmarks  
        , bgroup "PostgreSQL Store" pgBenchmarks
        ]
    ]

-- | Create insertion benchmarks for a single store
singleStoreBenchmarks :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BenchmarkRunner backend -> IO [Benchmark]
singleStoreBenchmarks runner = return
  [ bench "Single Event Insert" $ 
      whnfIO $ (withBackend runner) $ \(backend :: BackendHandle backend) -> do
        streamId <- StreamId <$> UUID.nextRandom
        let event = makeBenchEvent 1 1000  -- 1KB event
        result <- insertEvents backend Nothing $
          singleEvent streamId Any event
        case result of
          SuccessfulInsertion _ -> pure ()
          FailedInsertion err -> error $ (backendName runner) <> " insertion failed: " <> show err
          
  , bench "Batch Insert (10 events)" $
      whnfIO $ (withBackend runner) $ \(backend :: BackendHandle backend) -> do
        streamId <- StreamId <$> UUID.nextRandom
        let events = makeBenchEventBatch 10 1000  -- 10 x 1KB events
        result <- insertEvents backend Nothing $
          multiEvent streamId Any events
        case result of
          SuccessfulInsertion _ -> pure ()
          FailedInsertion err -> error $ (backendName runner) <> " batch insertion failed: " <> show err
          
  , bench "Large Batch Insert (100 events)" $
      whnfIO $ (withBackend runner) $ \(backend :: BackendHandle backend) -> do
        streamId <- StreamId <$> UUID.nextRandom
        let events = makeBenchEventBatch 100 1000  -- 100 x 1KB events
        result <- insertEvents backend Nothing $
          multiEvent streamId Any events
        case result of
          SuccessfulInsertion _ -> pure ()
          FailedInsertion err -> error $ (backendName runner) <> " large batch insertion failed: " <> show err

  , bench "Small Event Batch (1000 x 100B)" $
      whnfIO $ (withBackend runner) $ \(backend :: BackendHandle backend) -> do
        streamId <- StreamId <$> UUID.nextRandom
        let events = makeBenchEventBatch 1000 100  -- 1000 x 100B events
        result <- insertEvents backend Nothing $
          multiEvent streamId Any events
        case result of
          SuccessfulInsertion _ -> pure ()
          FailedInsertion err -> error $ (backendName runner) <> " small event batch failed: " <> show err

  , bench "Large Event Batch (10 x 10KB)" $
      whnfIO $ (withBackend runner) $ \(backend :: BackendHandle backend) -> do
        streamId <- StreamId <$> UUID.nextRandom
        let events = makeBenchEventBatch 10 10000  -- 10 x 10KB events
        result <- insertEvents backend Nothing $
          multiEvent streamId Any events
        case result of
          SuccessfulInsertion _ -> pure ()
          FailedInsertion err -> error $ (backendName runner) <> " large event batch failed: " <> show err
  ]

-- | Run insertion benchmarks for all backends with detailed metrics
runInsertionBenchmarks :: IO [BenchmarkResult]
runInsertionBenchmarks = runForAllBackends $ \(runner :: BenchmarkRunner backend) -> do
  putStrLn $ "Running detailed insertion benchmark for " <> (backendName runner) <> "..."
  
  let config = defaultConfig { numTransactions = 1000, eventsPerTransaction = 10 }
      numTx = case config of CT.BenchmarkConfig nt _ _ _ _ -> nt
      eventsPerTx = case config of CT.BenchmarkConfig _ et _ _ _ -> et
      eventSize = case config of CT.BenchmarkConfig _ _ _ es _ -> es
  
  (withBackend runner) $ \(backend :: BackendHandle backend) -> do
    ((_, avgLatency), memMetrics) <- withMemoryProfiling $ do
      withLatencyMeasurement (numTx * eventsPerTx) $ do
        -- Run the actual benchmark
        let insertTransaction _i = do
              streamId <- StreamId <$> UUID.nextRandom
              let events = makeBenchEventBatch eventsPerTx eventSize
              result <- insertEvents backend Nothing $
                multiEvent streamId Any events
              case result of
                SuccessfulInsertion _ -> pure ()
                FailedInsertion err -> error $ "Insertion failed: " <> show err
        mapM_ insertTransaction [1..numTx]
    
    let totalEvents = numTx * eventsPerTx
        -- Use avgLatency directly as insertion time (it's the total time)
        insertionTimeVal = case avgLatency of
          Just lat -> lat * fromIntegral numTx  -- Total time for all transactions
          Nothing -> 0
        throughput = fromIntegral totalEvents / realToFrac insertionTimeVal
    
    return $ BenchmarkResult
      { backend = backendType runner
      , config = config
      , scenarioName = "Detailed Insertion"
      , insertionTime = insertionTimeVal
      , insertionThroughput = throughput
      , avgLatency = avgLatency
      , latencyPercentiles = Nothing  -- Could be enhanced
      , memoryMetrics = Just memMetrics
      , subscriptionCatchUpTime = Nothing
      , subscriptionThroughput = Nothing
      , queueMetrics = Nothing
      }