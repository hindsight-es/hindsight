{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}

module Bench.ScaleBenchmarks where

import Bench.CSVReporter
import Bench.PostgreSQLPerformance (BenchmarkConfig(..), BenchmarkResult(..), runScenario, PerfTestEvent, LatencyPercentiles(..), MemoryMetrics(..), QueueMetrics(..))
import Control.Exception (bracket, finally)
import Control.Monad (forM_, when, forM, foldM)
import Data.Text (Text, pack)
import Data.Time (UTCTime, getCurrentTime, formatTime, defaultTimeLocale, diffUTCTime)
import System.IO (hFlush, stdout)

-- | Large-scale benchmark scenarios
data ScaleScenario = ScaleScenario
  { scenarioName :: Text
  , description :: Text
  , testConfigs :: [BenchmarkConfig]
  , replications :: Int  -- Number of runs per configuration (default 1)
  } deriving (Show)

-- | Create a scenario with default single run
mkScenario :: Text -> Text -> [BenchmarkConfig] -> ScaleScenario
mkScenario name desc configs = ScaleScenario name desc configs 1

-- | Create a scenario with multiple replications for variance analysis
mkReplicatedScenario :: Text -> Text -> [BenchmarkConfig] -> Int -> ScaleScenario
mkReplicatedScenario name desc configs reps = ScaleScenario name desc configs reps

-- | Convert BenchmarkResult to enhanced CSV record with Phase 3 metrics
resultToCSVRecord :: Text -> UTCTime -> BenchmarkResult -> BenchmarkRecord
resultToCSVRecord scenario timestamp result = BenchmarkRecord
  { timestamp = pack $ formatTime defaultTimeLocale "%Y-%m-%d %H:%M:%S" timestamp
  , scenario = scenario
  , txCount = result.config.numTransactions
  , subCount = result.config.numSubscriptions  
  , eventsPerTx = result.config.eventsPerTransaction
  , insertionTimeMs = realToFrac (result.insertionTime * 1000)
  , insertionThroughput = result.insertionThroughput
  , subscriptionCatchUpTimeMs = fmap (realToFrac . (*1000)) result.subscriptionCatchUpTime
  , subscriptionThroughput = result.subscriptionThroughput
  , avgLatencyMs = fmap (realToFrac . (*1000)) result.avgLatency
  , maxQueueDepth = result.maxQueueDepth
  , memoryUsageMb = result.memoryUsage
  , enableNewIndexes = result.config.enableNewIndexes
  , warmupTxCount = result.config.warmupTransactions
  , notificationCoalescingMs = result.config.notificationCoalescingMs
  , subscriptionLagPercent = result.config.subscriptionLagPercent
  -- Phase 3.1: Extract latency percentiles (convert NominalDiffTime to milliseconds)
  , latencyP50Ms = case result.latencyPercentiles of
      Just (LatencyPercentiles p50 _ _ _) -> Just $ realToFrac (p50 * 1000)
      Nothing -> Nothing
  , latencyP95Ms = case result.latencyPercentiles of
      Just (LatencyPercentiles _ p95 _ _) -> Just $ realToFrac (p95 * 1000)
      Nothing -> Nothing  
  , latencyP99Ms = case result.latencyPercentiles of
      Just (LatencyPercentiles _ _ p99 _) -> Just $ realToFrac (p99 * 1000)
      Nothing -> Nothing
  , latencyP999Ms = case result.latencyPercentiles of
      Just (LatencyPercentiles _ _ _ p999) -> Just $ realToFrac (p999 * 1000)
      Nothing -> Nothing
  -- Phase 3.2: Extract memory metrics
  , initialMemoryMb = case result.memoryMetrics of
      Just (MemoryMetrics initial _ _ _ _) -> Just initial
      Nothing -> Nothing
  , peakMemoryMb = case result.memoryMetrics of
      Just (MemoryMetrics _ peak _ _ _) -> Just peak
      Nothing -> Nothing
  , finalMemoryMb = case result.memoryMetrics of
      Just (MemoryMetrics _ _ final _ _) -> Just final
      Nothing -> Nothing
  , gcCount = case result.memoryMetrics of
      Just (MemoryMetrics _ _ _ count _) -> Just count
      Nothing -> Nothing
  , gcTimeMs = case result.memoryMetrics of
      Just (MemoryMetrics _ _ _ _ time) -> Just time
      Nothing -> Nothing
  -- Phase 3.3: Extract queue metrics
  , avgQueueDepth = case result.queueMetrics of
      Just (QueueMetrics _ avgDepth _ _) -> Just avgDepth
      Nothing -> Nothing
  , subscriptionLagMs = case result.queueMetrics of
      Just (QueueMetrics _ _ lagMs _) -> Just lagMs
      Nothing -> Nothing
  , queueOverflowCount = case result.queueMetrics of
      Just (QueueMetrics _ _ _ overflow) -> Just overflow
      Nothing -> Nothing
  }

-- | Large-scale transaction scaling scenario (exponential sampling)
largeTransactionScaling :: ScaleScenario
largeTransactionScaling = mkScenario
  "Large Transaction Scaling"
  "Test performance with increasing transaction volumes (exponential sampling)"
  [ BenchmarkConfig numTx 10 1 0 50 True 100
  | numTx <- [1000, 2000, 4000, 8000, 16000, 32000, 64000, 100000]
  ]

-- | Large-scale subscription scaling scenario  
largeSubscriptionScaling :: ScaleScenario
largeSubscriptionScaling = mkScenario
  "Large Subscription Scaling"
  "Test performance with increasing subscription counts (enhanced coverage)"
  [ BenchmarkConfig 5000 10 numSubs 0 50 True 100
  | numSubs <- [1, 5, 10, 25, 50, 100, 250, 500, 750, 1000]
  ]

-- | Multi-dimensional scaling scenario
multiDimensionalScaling :: ScaleScenario  
multiDimensionalScaling = mkScenario
  "Multi-Dimensional Scaling"
  "Test combinations of high transactions and high subscriptions"
  [ BenchmarkConfig numTx 10 numSubs 0 50 True 100
  | numTx <- [1000, 5000, 10000, 25000]
  , numSubs <- [1, 10, 50, 100]
  ]

-- | Stress testing scenario
stressTestScenario :: ScaleScenario
stressTestScenario = mkScenario
  "Stress Test"
  "Extreme load testing for system limits"
  [ BenchmarkConfig 75000 20 100 0 50 True 500  -- 2M events, 100 subscriptions
  , BenchmarkConfig 50000 50 50 0 50 True 500    -- 2.5M events, 50 subscriptions  
  , BenchmarkConfig 25000 100 25 0 50 True 500   -- 2.5M events, 25 subscriptions
  ]

-- | Index effectiveness at scale
indexEffectivenessAtScale :: ScaleScenario
indexEffectivenessAtScale = mkScenario
  "Index Effectiveness at Scale"
  "Compare index performance under heavy load"
  [ BenchmarkConfig 25000 10 25 0 50 useIdx 500
  | useIdx <- [False, True]
  ]

-- | Replicated scenarios for statistical analysis (3 runs each)
replicatedSubscriptionScaling :: ScaleScenario
replicatedSubscriptionScaling = mkReplicatedScenario
  "Replicated Subscription Scaling"
  "Subscription scaling with 3 runs per config for variance analysis"
  [ BenchmarkConfig 5000 10 numSubs 0 50 True 100
  | numSubs <- [1, 5, 10, 25, 50, 100, 250, 500]
  ]
  3

replicatedTransactionScaling :: ScaleScenario
replicatedTransactionScaling = mkReplicatedScenario
  "Replicated Transaction Scaling"
  "Transaction scaling with 3 runs per config for variance analysis (exponential sampling)"
  [ BenchmarkConfig numTx 10 1 0 50 True 100
  | numTx <- [1000, 2000, 4000, 8000, 16000, 32000]  -- Reduced for statistical analysis
  ]
  3

-- | All large-scale scenarios
allScaleScenarios :: [ScaleScenario]
allScaleScenarios = 
  [ largeTransactionScaling
  , largeSubscriptionScaling  
  , multiDimensionalScaling
  , indexEffectivenessAtScale
  , stressTestScenario  -- Run stress test last
  ]

-- | Quick test scenario for validation (2 configs × 2 reps = 4 runs)
quickTestScenario :: ScaleScenario
quickTestScenario = mkReplicatedScenario
  "Quick Replication Test"  
  "Small test to verify replication functionality"
  [ BenchmarkConfig 1000 10 1 0 50 True 100
  , BenchmarkConfig 1000 10 5 0 50 True 100
  ]
  2

-- | Phase 2: Comprehensive scaling scenario with enhanced coverage
comprehensiveScaling :: ScaleScenario
comprehensiveScaling = mkReplicatedScenario
  "Comprehensive Scaling Analysis"
  "Phase 2: Enhanced coverage with exponential transaction and intermediate subscription points"
  -- Transaction scaling with exponential sampling
  ([ BenchmarkConfig numTx 10 1 0 50 True 100
   | numTx <- [1000, 2000, 4000, 8000]  -- 5 exponential points
   ] ++
   -- Subscription scaling with intermediate points  
   [ BenchmarkConfig 5000 10 numSubs 0 50 True 100
   | numSubs <- [1, 5, 10, 25, 50, 100]  -- 6 intermediate points
   ])
  3  -- 3 replications for statistical validity

-- | Statistical analysis scenarios (with replications)
statisticalAnalysisScenarios :: [ScaleScenario]
statisticalAnalysisScenarios =
  [ replicatedTransactionScaling
  , replicatedSubscriptionScaling
  ]

-- | Phase 2 scenarios for enhanced coverage
phase2Scenarios :: [ScaleScenario]
phase2Scenarios = [comprehensiveScaling]

-- | Quick test scenarios for validation
quickTestScenarios :: [ScaleScenario]
quickTestScenarios = [quickTestScenario]

-- | Run a single scale scenario
runScaleScenario :: CSVReporter -> ScaleScenario -> IO CSVReporter
runScaleScenario reporter scenario = do
  putStrLn $ "\n### " ++ show scenario.scenarioName ++ " ###"
  putStrLn $ show scenario.description
  let totalRuns = length scenario.testConfigs * scenario.replications
  putStrLn $ "Running " ++ show (length scenario.testConfigs) ++ " configurations × " 
           ++ show scenario.replications ++ " replications = " ++ show totalRuns ++ " total runs\n"
  
  let totalConfigs = length scenario.testConfigs
  
  allResults <- forM (zip [1..] scenario.testConfigs) $ \(i, config) -> do
    putStr $ "\n[Config " ++ show (i :: Int) ++ "/" ++ show totalConfigs ++ "] "
    putStr $ show config.numTransactions ++ " tx, " ++ show config.numSubscriptions ++ " subs"
    putStrLn $ " (" ++ show scenario.replications ++ " runs):"
    
    -- Run multiple replications for this configuration
    configResults <- forM [1..scenario.replications] $ \repNum -> do
      putStr $ "  Run " ++ show repNum ++ "/" ++ show scenario.replications ++ "... "
      hFlush stdout
      
      startTime <- getCurrentTime
      result <- runScenario config
      endTime <- getCurrentTime
      
      let duration = diffUTCTime endTime startTime
      putStrLn $ "completed in " ++ show duration ++ 
                 " (" ++ show (round result.insertionThroughput :: Int) ++ " eps)"
      
      let csvRecord = resultToCSVRecord 
            (scenario.scenarioName <> if scenario.replications > 1 
                                    then " (rep " <> pack (show repNum) <> ")"
                                    else "")
            endTime result
      pure csvRecord
    
    pure configResults
  
  let results = concat allResults
  putStrLn $ "\n✓ Completed " ++ show scenario.scenarioName ++ " (" ++ show (length results) ++ " total measurements)"
  
  -- Add all records to reporter
  pure $ foldr (flip addRecord) reporter results

-- | Run all large-scale benchmarks  
runAllScaleBenchmarks :: Maybe FilePath -> IO ()
runAllScaleBenchmarks csvPath = do
  putStrLn "PostgreSQL Large-Scale Performance Benchmarks"
  putStrLn "============================================="
  putStrLn ""
  
  -- Initialize CSV reporter
  let csvConfig = case csvPath of
        Just path -> defaultCSVConfig { outputDirectory = path }
        Nothing -> defaultCSVConfig
  reporter <- initCSVReporter csvConfig
  
  putStrLn $ "Results will be exported to: " ++ csvConfig.outputDirectory
  putStrLn ""
  
  -- Run all scenarios
  finalReporter <- foldM runScaleScenario reporter allScaleScenarios
  
  -- Export results
  putStrLn $ "\n" ++ replicate 50 '='
  exportWithSummary finalReporter
  putStrLn ""

-- | Run transaction scaling only (for faster testing)
runTransactionScalingOnly :: Maybe FilePath -> IO ()
runTransactionScalingOnly csvPath = do
  putStrLn "PostgreSQL Transaction Scaling Benchmarks"
  putStrLn "========================================"
  putStrLn ""
  
  let csvConfig = case csvPath of
        Just path -> defaultCSVConfig { outputDirectory = path }
        Nothing -> defaultCSVConfig
  reporter <- initCSVReporter csvConfig
  
  finalReporter <- runScaleScenario reporter largeTransactionScaling
  exportWithSummary finalReporter

-- | Run subscription scaling only
runSubscriptionScalingOnly :: Maybe FilePath -> IO ()
runSubscriptionScalingOnly csvPath = do
  putStrLn "PostgreSQL Subscription Scaling Benchmarks"  
  putStrLn "=========================================="
  putStrLn ""
  
  let csvConfig = case csvPath of
        Just path -> defaultCSVConfig { outputDirectory = path }
        Nothing -> defaultCSVConfig
  reporter <- initCSVReporter csvConfig
  
  finalReporter <- runScaleScenario reporter largeSubscriptionScaling
  exportWithSummary finalReporter

-- | Run statistical analysis benchmarks (with replications)
runStatisticalBenchmarks :: Maybe FilePath -> IO ()
runStatisticalBenchmarks csvPath = do
  putStrLn "PostgreSQL Statistical Analysis Benchmarks"
  putStrLn "=========================================="
  putStrLn "Running replicated benchmarks for variance analysis"
  putStrLn ""
  
  let csvConfig = case csvPath of
        Just path -> defaultCSVConfig { outputDirectory = path }
        Nothing -> defaultCSVConfig
  reporter <- initCSVReporter csvConfig
  
  putStrLn $ "Results will be exported to: " ++ csvConfig.outputDirectory
  putStrLn ""
  
  -- Run statistical scenarios
  finalReporter <- foldM runScaleScenario reporter statisticalAnalysisScenarios
  
  putStrLn $ "\n" ++ replicate 50 '='
  exportWithSummary finalReporter
  putStrLn ""

-- | Run quick test benchmarks for validation
runQuickTest :: Maybe FilePath -> IO ()
runQuickTest csvPath = do
  putStrLn "Quick Replication Test"
  putStrLn "====================="
  putStrLn "Running small test to verify replication functionality (4 runs total)"
  putStrLn ""
  
  let csvConfig = case csvPath of
        Just path -> defaultCSVConfig { outputDirectory = path }
        Nothing -> defaultCSVConfig
  reporter <- initCSVReporter csvConfig
  
  putStrLn $ "Results will be exported to: " ++ csvConfig.outputDirectory
  putStrLn ""
  
  -- Run quick test
  finalReporter <- foldM runScaleScenario reporter quickTestScenarios
  
  putStrLn $ "\n" ++ replicate 50 '='
  exportWithSummary finalReporter
  putStrLn ""

-- | Run Phase 2 comprehensive scaling benchmarks
runPhase2Benchmarks :: Maybe FilePath -> IO ()
runPhase2Benchmarks csvPath = do
  putStrLn "Phase 2: Comprehensive Scaling Benchmarks"
  putStrLn "========================================="
  putStrLn "Enhanced coverage with exponential transaction and intermediate subscription points"
  putStrLn "11 configurations × 3 replications = 33 total runs"
  putStrLn ""
  
  let csvConfig = case csvPath of
        Just path -> defaultCSVConfig { outputDirectory = path }
        Nothing -> defaultCSVConfig
  reporter <- initCSVReporter csvConfig
  
  putStrLn $ "Results will be exported to: " ++ csvConfig.outputDirectory
  putStrLn ""
  
  -- Run Phase 2 scenarios
  finalReporter <- foldM runScaleScenario reporter phase2Scenarios
  
  putStrLn $ "\n" ++ replicate 50 '='
  exportWithSummary finalReporter
  putStrLn ""