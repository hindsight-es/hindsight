{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}

module Bench.CSVReporter where

import Data.ByteString.Lazy qualified as BSL
import Data.Csv (DefaultOrdered (..), ToNamedRecord (..), ToRecord (..), (.=))
import Data.Csv qualified as CSV
import Data.Text (Text, pack)
import Data.Text.Encoding qualified as T
import Data.Time (UTCTime, formatTime, defaultTimeLocale, getCurrentTime)
import Data.Vector qualified as V
import GHC.Generics (Generic)
import System.Directory (createDirectoryIfMissing)
import System.FilePath ((</>), (<.>))

-- | Enhanced CSV record for benchmark measurements with Phase 3 metrics
data BenchmarkRecord = BenchmarkRecord
  { timestamp :: Text
  , scenario :: Text
  , txCount :: Int
  , subCount :: Int
  , eventsPerTx :: Int
  , insertionTimeMs :: Double
  , insertionThroughput :: Double  -- events/sec
  , subscriptionCatchUpTimeMs :: Maybe Double
  , subscriptionThroughput :: Maybe Double  -- events/sec
  , avgLatencyMs :: Maybe Double
  , maxQueueDepth :: Maybe Int
  , memoryUsageMb :: Maybe Int
  , enableNewIndexes :: Bool
  , warmupTxCount :: Int
  , notificationCoalescingMs :: Int
  , subscriptionLagPercent :: Int
  -- Phase 3.1: Latency percentiles
  , latencyP50Ms :: Maybe Double
  , latencyP95Ms :: Maybe Double  
  , latencyP99Ms :: Maybe Double
  , latencyP999Ms :: Maybe Double
  -- Phase 3.2: Memory profiling
  , initialMemoryMb :: Maybe Int
  , peakMemoryMb :: Maybe Int
  , finalMemoryMb :: Maybe Int
  , gcCount :: Maybe Int
  , gcTimeMs :: Maybe Double
  -- Phase 3.3: Queue metrics
  , avgQueueDepth :: Maybe Double
  , subscriptionLagMs :: Maybe Double
  , queueOverflowCount :: Maybe Int
  } deriving (Show, Generic)

instance ToRecord BenchmarkRecord where
  toRecord r = V.fromList
    [ CSV.toField r.timestamp
    , CSV.toField r.scenario  
    , CSV.toField r.txCount
    , CSV.toField r.subCount
    , CSV.toField r.eventsPerTx
    , CSV.toField r.insertionTimeMs
    , CSV.toField r.insertionThroughput
    , CSV.toField r.subscriptionCatchUpTimeMs
    , CSV.toField r.subscriptionThroughput
    , CSV.toField r.avgLatencyMs
    , CSV.toField r.maxQueueDepth
    , CSV.toField r.memoryUsageMb
    , CSV.toField (if r.enableNewIndexes then ("true" :: Text) else ("false" :: Text))
    , CSV.toField r.warmupTxCount
    , CSV.toField r.notificationCoalescingMs
    , CSV.toField r.subscriptionLagPercent
    -- Phase 3.1: Latency percentiles
    , CSV.toField r.latencyP50Ms
    , CSV.toField r.latencyP95Ms
    , CSV.toField r.latencyP99Ms
    , CSV.toField r.latencyP999Ms
    -- Phase 3.2: Memory profiling
    , CSV.toField r.initialMemoryMb
    , CSV.toField r.peakMemoryMb
    , CSV.toField r.finalMemoryMb
    , CSV.toField r.gcCount
    , CSV.toField r.gcTimeMs
    -- Phase 3.3: Queue metrics
    , CSV.toField r.avgQueueDepth
    , CSV.toField r.subscriptionLagMs
    , CSV.toField r.queueOverflowCount
    ]

instance DefaultOrdered BenchmarkRecord where
  headerOrder _ = V.fromList
    [ "timestamp"
    , "scenario"  
    , "tx_count"
    , "sub_count"
    , "events_per_tx"
    , "insertion_time_ms"
    , "insertion_throughput_eps"
    , "subscription_catchup_time_ms"
    , "subscription_throughput_eps"
    , "avg_latency_ms"
    , "max_queue_depth"
    , "memory_usage_mb"
    , "enable_new_indexes"
    , "warmup_tx_count"
    , "notification_coalescing_ms"
    , "subscription_lag_percent"
    -- Phase 3.1: Latency percentiles
    , "latency_p50_ms"
    , "latency_p95_ms"
    , "latency_p99_ms"
    , "latency_p999_ms"
    -- Phase 3.2: Memory profiling
    , "initial_memory_mb"
    , "peak_memory_mb"
    , "final_memory_mb"
    , "gc_count"
    , "gc_time_ms"
    -- Phase 3.3: Queue metrics
    , "avg_queue_depth"
    , "subscription_lag_ms"
    , "queue_overflow_count"
    ]

instance ToNamedRecord BenchmarkRecord where
  toNamedRecord r = CSV.namedRecord
    [ "timestamp" .= r.timestamp
    , "scenario" .= r.scenario  
    , "tx_count" .= r.txCount
    , "sub_count" .= r.subCount
    , "events_per_tx" .= r.eventsPerTx
    , "insertion_time_ms" .= r.insertionTimeMs
    , "insertion_throughput_eps" .= r.insertionThroughput
    , "subscription_catchup_time_ms" .= r.subscriptionCatchUpTimeMs
    , "subscription_throughput_eps" .= r.subscriptionThroughput
    , "avg_latency_ms" .= r.avgLatencyMs
    , "max_queue_depth" .= r.maxQueueDepth
    , "memory_usage_mb" .= r.memoryUsageMb
    , "enable_new_indexes" .= (if r.enableNewIndexes then ("true" :: Text) else ("false" :: Text))
    , "warmup_tx_count" .= r.warmupTxCount
    , "notification_coalescing_ms" .= r.notificationCoalescingMs
    , "subscription_lag_percent" .= r.subscriptionLagPercent
    -- Phase 3.1: Latency percentiles
    , "latency_p50_ms" .= r.latencyP50Ms
    , "latency_p95_ms" .= r.latencyP95Ms
    , "latency_p99_ms" .= r.latencyP99Ms
    , "latency_p999_ms" .= r.latencyP999Ms
    -- Phase 3.2: Memory profiling
    , "initial_memory_mb" .= r.initialMemoryMb
    , "peak_memory_mb" .= r.peakMemoryMb
    , "final_memory_mb" .= r.finalMemoryMb
    , "gc_count" .= r.gcCount
    , "gc_time_ms" .= r.gcTimeMs
    -- Phase 3.3: Queue metrics
    , "avg_queue_depth" .= r.avgQueueDepth
    , "subscription_lag_ms" .= r.subscriptionLagMs
    , "queue_overflow_count" .= r.queueOverflowCount
    ]

-- | CSV reporter configuration
data CSVReporterConfig = CSVReporterConfig
  { outputDirectory :: FilePath
  , filePrefix :: Text
  , includeTimestamp :: Bool
  } deriving (Show)

-- | Default CSV reporter configuration
defaultCSVConfig :: CSVReporterConfig
defaultCSVConfig = CSVReporterConfig
  { outputDirectory = "benchmark-results"
  , filePrefix = "hindsight-bench"
  , includeTimestamp = True
  }

-- | CSV reporter handle
data CSVReporter = CSVReporter
  { config :: CSVReporterConfig
  , records :: [BenchmarkRecord]
  , startTime :: UTCTime
  } deriving (Show)

-- | Initialize CSV reporter
initCSVReporter :: CSVReporterConfig -> IO CSVReporter
initCSVReporter cfg = do
  createDirectoryIfMissing True cfg.outputDirectory
  now <- getCurrentTime
  pure $ CSVReporter
    { config = cfg
    , records = []
    , startTime = now
    }

-- | Add a benchmark record
addRecord :: CSVReporter -> BenchmarkRecord -> CSVReporter
addRecord reporter record = reporter { records = record : reporter.records }

-- | Generate filename for CSV output
generateFilename :: CSVReporter -> FilePath
generateFilename reporter = 
  let timeStr = if reporter.config.includeTimestamp
                then "-" ++ formatTime defaultTimeLocale "%Y%m%d-%H%M%S" reporter.startTime
                else ""
      filename = show reporter.config.filePrefix ++ timeStr
  in reporter.config.outputDirectory </> filename <.> "csv"

-- | Export records to CSV file
exportToCSV :: CSVReporter -> IO (Either String FilePath)
exportToCSV reporter = do
  let filename = generateFilename reporter
      sortedRecords = reverse reporter.records  -- Chronological order
      csvData = CSV.encodeDefaultOrderedByName sortedRecords
  BSL.writeFile filename csvData
  pure $ Right filename

-- | Export and print summary
exportWithSummary :: CSVReporter -> IO ()
exportWithSummary reporter = do
  result <- exportToCSV reporter
  case result of
    Left err -> putStrLn $ "Failed to export CSV: " ++ err
    Right filename -> do
      putStrLn $ "\n=== CSV Export Summary ==="
      putStrLn $ "Records exported: " ++ show (length reporter.records)
      putStrLn $ "Output file: " ++ filename
      putStrLn $ "Analysis: Run 'Rscript hindsight/scripts/analyze-benchmarks.R " ++ filename ++ "'"