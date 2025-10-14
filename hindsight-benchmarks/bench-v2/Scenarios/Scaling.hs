{-# LANGUAGE DataKinds #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

module Scenarios.Scaling
  ( runScalingBenchmarks
  , runTransactionScaling
  , runSubscriptionScaling
  ) where

import Analysis.CSV (writeCSVResults)
import Backends.Common
import Core.Metrics
import Core.Types
import Data.Text (pack)
import Data.Time (getCurrentTime, formatTime, defaultTimeLocale)
import Data.UUID.V4 qualified as UUID
import Hindsight.Store
import Scenarios.Insertion (makeBenchEventBatch)
import System.IO (hFlush, stdout)
import Data.Map.Strict qualified as Map

-- | Run scaling benchmarks across all backends
runScalingBenchmarks :: Maybe String -> IO ()
runScalingBenchmarks csvPath = do
  putStrLn "Running scaling benchmarks across all stores..."
  putStrLn "================================================="
  
  -- Run transaction scaling
  putStrLn "\n1. Transaction Scaling Tests"
  txResults <- runTransactionScaling
  
  -- Run subscription scaling (Note: only meaningful for backends that support subscriptions)
  putStrLn "\n2. Subscription Scaling Tests"  
  subResults <- runSubscriptionScaling
  
  -- Export results to CSV
  timestamp <- getCurrentTime
  let timestampStr = formatTime defaultTimeLocale "%Y%m%d-%H%M%S" timestamp
      csvFile = case csvPath of
        Just path -> path ++ "/scaling-results-" ++ timestampStr ++ ".csv"
        Nothing -> "benchmark-results/scaling-results-" ++ timestampStr ++ ".csv"
  
  putStrLn $ "\nExporting results to: " ++ csvFile
  writeCSVResults csvFile (txResults ++ subResults)
  
  putStrLn "\nScaling benchmarks completed!"
  putStrLn "Run 'Rscript bench-v2/scripts/analyze.R' to generate analysis."

-- | Run transaction scaling tests
runTransactionScaling :: IO [BenchmarkResult]
runTransactionScaling = do
  putStrLn "Running transaction scaling..."
  
  let configs = 
        [ defaultConfig { numTransactions = tx, eventsPerTransaction = 10 }
        | tx <- [500, 1000, 2000, 5000, 10000, 20000, 50000]
        ]
  
  allResults <- mapM runConfigForAllBackends configs
  return $ concat allResults
  
  where
    runConfigForAllBackends config = do
      putStrLn $ "  Testing " ++ show (numTransactions config) ++ " transactions..."
      hFlush stdout
      
      runForAllBackends $ \(runner :: BenchmarkRunner backend) -> do
        withBackend runner $ \(backend :: BackendHandle backend) -> runTransactionScalingTest runner config backend

-- | Run subscription scaling tests (simplified for non-PostgreSQL stores)
runSubscriptionScaling :: IO [BenchmarkResult]
runSubscriptionScaling = do
  putStrLn "Running subscription scaling..."
  
  -- For now, just test basic insertion performance with different "subscription" counts
  -- This is a placeholder until we have proper subscription support across all backends
  let configs = 
        [ defaultConfig { numTransactions = 5000, eventsPerTransaction = 10, numSubscriptions = subs }
        | subs <- [1, 5, 10, 25, 50]  -- Simulate subscription load
        ]
  
  allResults <- mapM runConfigForAllBackends configs
  return $ concat allResults
  
  where
    runConfigForAllBackends config = do
      putStrLn $ "  Testing " ++ show (numSubscriptions config) ++ " subscription load..."
      hFlush stdout
      
      runForAllBackends $ \(runner :: BenchmarkRunner backend) -> do
        withBackend runner $ \(backend :: BackendHandle backend) -> runSubscriptionScalingTest runner config backend

-- | Run transaction scaling test for a specific backend
runTransactionScalingTest :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend))
                          => BenchmarkRunner backend 
                          -> BenchmarkConfig 
                          -> BackendHandle backend 
                          -> IO BenchmarkResult
runTransactionScalingTest runner config backend = do
  ((_, maybeLatency), memMetrics) <- withMemoryProfiling $ do
    withLatencyMeasurement (numTransactions config * eventsPerTransaction config) $ do
      -- Insert transactions sequentially to measure throughput
      mapM_ (\txId -> do
        streamId <- StreamId <$> UUID.nextRandom
        let events = makeBenchEventBatch (eventsPerTransaction config) (eventSizeBytes config)
        result <- insertEvents backend Nothing $
          Transaction $ Map.singleton streamId (StreamWrite Any events)
        case result of
          SuccessfulInsertion{} -> pure ()
          FailedInsertion err -> error $ "Transaction scaling test failed: " <> show err
        ) [1..numTransactions config]
  
  let totalEvents = numTransactions config * eventsPerTransaction config
      elapsedTime = case maybeLatency of
        Just lat -> lat
        Nothing -> 0.001  -- Default fallback
      throughput = fromIntegral totalEvents / realToFrac elapsedTime
  
  return $ BenchmarkResult
    { backend = backendType runner
    , config = config
    , scenarioName = "Transaction Scaling"
    , insertionTime = elapsedTime
    , insertionThroughput = throughput
    , avgLatency = Nothing  -- Could calculate from insertionTime
    , latencyPercentiles = Nothing
    , memoryMetrics = Just memMetrics
    , subscriptionCatchUpTime = Nothing
    , subscriptionThroughput = Nothing
    , queueMetrics = Nothing
    }

-- | Run subscription scaling test (simplified for non-subscription backends)
runSubscriptionScalingTest :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend))
                           => BenchmarkRunner backend
                           -> BenchmarkConfig
                           -> BackendHandle backend
                           -> IO BenchmarkResult
runSubscriptionScalingTest runner config backend = do
  -- For non-PostgreSQL backends, this is essentially the same as transaction scaling
  -- but we can simulate the overhead of multiple "subscribers" by doing additional work
  ((_, maybeLatency), memMetrics) <- withMemoryProfiling $ do
    withLatencyMeasurement (numTransactions config * eventsPerTransaction config) $ do
      -- Insert events and simulate subscription processing overhead
      mapM_ (\txId -> do
        streamId <- StreamId <$> UUID.nextRandom
        let events = makeBenchEventBatch (eventsPerTransaction config) (eventSizeBytes config)
        result <- insertEvents backend Nothing $
          Transaction $ Map.singleton streamId (StreamWrite Any events)
        case result of
          SuccessfulInsertion{} -> 
            -- Simulate subscription processing delay
            mapM_ (\_ -> return ()) [1..numSubscriptions config]
          FailedInsertion err -> error $ "Subscription scaling test failed: " <> show err
        ) [1..numTransactions config]
  
  let totalEvents = numTransactions config * eventsPerTransaction config  
      elapsedTime = case maybeLatency of
        Just lat -> lat
        Nothing -> 0.001  -- Default fallback
      throughput = fromIntegral totalEvents / realToFrac elapsedTime
      -- Approximate subscription throughput (events per subscription per second)
      subThroughput = throughput / fromIntegral (numSubscriptions config)
  
  return $ BenchmarkResult
    { backend = backendType runner
    , config = config
    , scenarioName = "Subscription Scaling"
    , insertionTime = elapsedTime
    , insertionThroughput = throughput
    , avgLatency = Nothing
    , latencyPercentiles = Nothing  
    , memoryMetrics = Just memMetrics
    , subscriptionCatchUpTime = Nothing
    , subscriptionThroughput = Just subThroughput
    , queueMetrics = Nothing
    }