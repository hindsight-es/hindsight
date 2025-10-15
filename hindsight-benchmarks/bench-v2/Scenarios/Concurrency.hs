{-# LANGUAGE DataKinds #-}
{-# LANGUAGE LambdaCase #-}  
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

module Scenarios.Concurrency
  ( runProfilingBenchmarks
  , runConcurrencyTests
  ) where

import Backends.Common
import Control.Concurrent.Async (forConcurrently_)
import Control.Exception (Exception, throwIO)
import Control.Monad (replicateM)
import Core.Metrics
import Core.Types
import Data.Map.Strict qualified as Map
import Data.UUID.V4 qualified as UUID
import Hindsight.Store
import Scenarios.Insertion (makeBenchEvent)
import System.IO (hFlush, stdout)

data BenchmarkError = BenchmarkError String
  deriving (Show)

instance Exception BenchmarkError

-- | Run profiling benchmarks for performance analysis
runProfilingBenchmarks :: IO ()
runProfilingBenchmarks = do
  putStrLn "Running concurrency profiling benchmarks..."
  putStrLn "==========================================="
  
  -- Run across all backends
  _ <- runForAllBackends $ \(runner :: BenchmarkRunner backend) -> do
    putStrLn $ "\n--- " ++ backendName runner ++ " Concurrency Tests ---"
    
    withBackend runner $ \(backend :: BackendHandle backend) -> do
      putStrLn "1. Low contention (different streams)"
      runLowContentionTest runner backend 10
      
      putStrLn "2. High contention (same stream)" 
      runHighContentionTest runner backend 10
      
      putStrLn "3. Mixed contention (few shared streams)"
      runMixedContentionTest runner backend 10
      return ()
    return ()
  return ()

-- | Run comprehensive concurrency tests with metrics
runConcurrencyTests :: IO [BenchmarkResult]
runConcurrencyTests = do
  putStrLn "Running detailed concurrency analysis..."
  
  concat <$> sequence
    [ runConcurrencyScenario "Low Contention" runLowContentionBenchmark
    , runConcurrencyScenario "High Contention" runHighContentionBenchmark  
    , runConcurrencyScenario "Mixed Contention" runMixedContentionBenchmark
    ]
  
  where
    runConcurrencyScenario :: String -> (forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BenchmarkRunner backend -> BackendHandle backend -> IO BenchmarkResult) -> IO [BenchmarkResult]
    runConcurrencyScenario name benchFunc = do
      putStrLn $ "Running " ++ name ++ " tests..."
      runForAllBackends $ \(runner :: BenchmarkRunner backend) -> do
        withBackend runner $ \(backend :: BackendHandle backend) -> benchFunc runner backend

-- | Low contention benchmark - concurrent insertions to different streams
runLowContentionBenchmark :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend))
                          => BenchmarkRunner backend
                          -> BackendHandle backend
                          -> IO BenchmarkResult
runLowContentionBenchmark runner backend = do
  let config = defaultConfig { numTransactions = 100, eventsPerTransaction = 10 }
      numConcurrent = 10
  
  ((_, maybeLatency), memMetrics) <- withMemoryProfiling $ do
    withLatencyMeasurement (numConcurrent * eventsPerTransaction config) $ do
      -- Run concurrent insertions to different streams (low contention)
      forConcurrently_ [1..numConcurrent] $ \i -> do
        streamId <- StreamId <$> UUID.nextRandom
        let events = Transaction $ Map.singleton streamId (StreamWrite Any [makeBenchEvent i (eventSizeBytes config)])
        result <- insertEvents backend Nothing events
        case result of
          FailedInsertion err -> throwIO $ BenchmarkError $ "Low contention insertion failed: " <> show err
          SuccessfulInsertion _ -> pure ()
  
  let totalEvents = numConcurrent * eventsPerTransaction config
      elapsedTime = case maybeLatency of
        Just lat -> lat
        Nothing -> 0.001  -- Default fallback
      throughput = fromIntegral totalEvents / realToFrac elapsedTime
  
  return $ BenchmarkResult
    { backend = backendType runner
    , config = config
    , scenarioName = "Low Contention Concurrent"
    , insertionTime = elapsedTime
    , insertionThroughput = throughput
    , avgLatency = Nothing
    , latencyPercentiles = Nothing
    , memoryMetrics = Just memMetrics
    , subscriptionCatchUpTime = Nothing
    , subscriptionThroughput = Nothing
    , queueMetrics = Nothing
    }

-- | High contention benchmark - concurrent insertions to same stream
runHighContentionBenchmark :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend))
                           => BenchmarkRunner backend
                           -> BackendHandle backend  
                           -> IO BenchmarkResult
runHighContentionBenchmark runner backend = do
  let config = defaultConfig { numTransactions = 100, eventsPerTransaction = 1 }
      numConcurrent = 10
  
  -- Use the same stream ID for all concurrent insertions (maximum contention)
  sharedStreamId <- StreamId <$> UUID.nextRandom
  
  ((_, maybeLatency), memMetrics) <- withMemoryProfiling $ do
    withLatencyMeasurement numConcurrent $ do
      -- Run concurrent insertions to same stream (high contention)
      forConcurrently_ [1..numConcurrent] $ \i -> do
        let events = Transaction $ Map.singleton sharedStreamId (StreamWrite Any [makeBenchEvent i (eventSizeBytes config)])
        result <- insertEvents backend Nothing events
        case result of
          FailedInsertion err -> throwIO $ BenchmarkError $ "High contention insertion failed: " <> show err
          SuccessfulInsertion _ -> pure ()
  
  let elapsedTime = case maybeLatency of
        Just lat -> lat
        Nothing -> 0.001  -- Default fallback
      throughput = fromIntegral numConcurrent / realToFrac elapsedTime
  
  return $ BenchmarkResult
    { backend = backendType runner
    , config = config
    , scenarioName = "High Contention Concurrent" 
    , insertionTime = elapsedTime
    , insertionThroughput = throughput
    , avgLatency = Nothing
    , latencyPercentiles = Nothing
    , memoryMetrics = Just memMetrics
    , subscriptionCatchUpTime = Nothing
    , subscriptionThroughput = Nothing
    , queueMetrics = Nothing
    }

-- | Mixed contention benchmark - moderate contention with few shared streams
runMixedContentionBenchmark :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend))
                            => BenchmarkRunner backend
                            -> BackendHandle backend
                            -> IO BenchmarkResult  
runMixedContentionBenchmark runner backend = do
  let config = defaultConfig { numTransactions = 100, eventsPerTransaction = 1 }
      numConcurrent = 20
      numSharedStreams = 3
  
  -- Create a few shared streams (moderate contention)
  sharedStreams <- replicateM numSharedStreams (StreamId <$> UUID.nextRandom)
  
  ((_, maybeLatency), memMetrics) <- withMemoryProfiling $ do
    withLatencyMeasurement numConcurrent $ do
      -- Run concurrent insertions with moderate contention
      forConcurrently_ [1..numConcurrent] $ \i -> do
        -- Pick a stream (some contention but not maximum)
        let streamId = sharedStreams !! (i `mod` length sharedStreams)
        let events = Transaction $ Map.singleton streamId (StreamWrite Any [makeBenchEvent i (eventSizeBytes config)])
        result <- insertEvents backend Nothing events
        case result of
          FailedInsertion err -> throwIO $ BenchmarkError $ "Mixed contention insertion failed: " <> show err
          SuccessfulInsertion _ -> pure ()
  
  let elapsedTime = case maybeLatency of
        Just lat -> lat
        Nothing -> 0.001  -- Default fallback
      throughput = fromIntegral numConcurrent / realToFrac elapsedTime
  
  return $ BenchmarkResult
    { backend = backendType runner
    , config = config
    , scenarioName = "Mixed Contention Concurrent"
    , insertionTime = elapsedTime  
    , insertionThroughput = throughput
    , avgLatency = Nothing
    , latencyPercentiles = Nothing
    , memoryMetrics = Just memMetrics
    , subscriptionCatchUpTime = Nothing
    , subscriptionThroughput = Nothing
    , queueMetrics = Nothing
    }

-- Helper functions for simple profiling tests

runLowContentionTest :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend))
                     => BenchmarkRunner backend
                     -> BackendHandle backend
                     -> Int
                     -> IO ()
runLowContentionTest _runner backend numConcurrent = do
  putStr $ "  Running " ++ show numConcurrent ++ " concurrent insertions to different streams... "
  hFlush stdout
  
  forConcurrently_ [1..numConcurrent] $ \i -> do
    streamId <- StreamId <$> UUID.nextRandom
    let events = Transaction $ Map.singleton streamId (StreamWrite Any [makeBenchEvent i 100])
    result <- insertEvents backend Nothing events
    case result of
      FailedInsertion err -> throwIO $ BenchmarkError $ "Insertion failed: " <> show err
      SuccessfulInsertion _ -> pure ()
  
  putStrLn "✓"

runHighContentionTest :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend))
                      => BenchmarkRunner backend
                      -> BackendHandle backend
                      -> Int
                      -> IO ()
runHighContentionTest _runner backend numConcurrent = do
  putStr $ "  Running " ++ show numConcurrent ++ " concurrent insertions to same stream... "
  hFlush stdout
  
  sharedStreamId <- StreamId <$> UUID.nextRandom
  
  forConcurrently_ [1..numConcurrent] $ \i -> do
    let events = Transaction $ Map.singleton sharedStreamId (StreamWrite Any [makeBenchEvent i 100])
    result <- insertEvents backend Nothing events
    case result of
      FailedInsertion err -> throwIO $ BenchmarkError $ "High contention insertion failed: " <> show err
      SuccessfulInsertion _ -> pure ()
  
  putStrLn "✓"

runMixedContentionTest :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend))
                       => BenchmarkRunner backend
                       -> BackendHandle backend
                       -> Int
                       -> IO ()
runMixedContentionTest _runner backend numConcurrent = do
  putStr $ "  Running " ++ show numConcurrent ++ " concurrent insertions with mixed contention... "
  hFlush stdout
  
  sharedStreams <- replicateM 3 (StreamId <$> UUID.nextRandom)
  
  forConcurrently_ [1..numConcurrent] $ \i -> do
    let streamId = sharedStreams !! (i `mod` length sharedStreams)
    let events = Transaction $ Map.singleton streamId (StreamWrite Any [makeBenchEvent i 100])
    result <- insertEvents backend Nothing events
    case result of
      FailedInsertion err -> throwIO $ BenchmarkError $ "Mixed contention insertion failed: " <> show err
      SuccessfulInsertion _ -> pure ()
  
  putStrLn "✓"