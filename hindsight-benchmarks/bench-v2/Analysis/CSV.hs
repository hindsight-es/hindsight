{-# LANGUAGE OverloadedStrings #-}

module Analysis.CSV
  ( writeCSVResults
  , BenchmarkRecord(..)
  , resultToCSVRecord
  ) where

import Core.Types qualified as CT
import Data.Csv
import Data.Text (Text, pack)
import Data.Time (UTCTime, formatTime, defaultTimeLocale, getCurrentTime)
import System.Directory (createDirectoryIfMissing)
import System.FilePath (takeDirectory)
import qualified Data.ByteString.Lazy as BL

-- | CSV record for benchmark results
data BenchmarkRecord = BenchmarkRecord
  { timestamp :: Text
  , scenario :: Text
  , backend :: Text
  , txCount :: Int
  , eventsPerTx :: Int
  , subCount :: Int
  , eventSizeBytes :: Int
  , insertionTimeMs :: Double
  , insertionThroughput :: Double
  -- Latency metrics
  , avgLatencyMs :: Maybe Double
  , latencyP50Ms :: Maybe Double
  , latencyP95Ms :: Maybe Double
  , latencyP99Ms :: Maybe Double
  , latencyP999Ms :: Maybe Double
  -- Memory metrics
  , initialMemoryMb :: Maybe Int
  , peakMemoryMb :: Maybe Int
  , finalMemoryMb :: Maybe Int
  , gcCount :: Maybe Int
  , gcTimeMs :: Maybe Double
  -- Subscription metrics
  , subscriptionCatchUpTimeMs :: Maybe Double
  , subscriptionThroughput :: Maybe Double
  -- Queue metrics (placeholders for future PostgreSQL-specific features)
  , avgQueueDepth :: Maybe Double
  , subscriptionLagMs :: Maybe Double
  , queueOverflowCount :: Maybe Int
  } deriving (Show)

instance ToNamedRecord BenchmarkRecord where
  toNamedRecord rec = namedRecord
    [ "timestamp" .= timestamp rec
    , "scenario" .= scenario rec
    , "backend" .= backend rec
    , "tx_count" .= txCount rec
    , "events_per_tx" .= eventsPerTx rec
    , "sub_count" .= subCount rec
    , "event_size_bytes" .= eventSizeBytes rec
    , "insertion_time_ms" .= insertionTimeMs rec
    , "insertion_throughput_eps" .= insertionThroughput rec
    , "avg_latency_ms" .= avgLatencyMs rec
    , "latency_p50_ms" .= latencyP50Ms rec
    , "latency_p95_ms" .= latencyP95Ms rec
    , "latency_p99_ms" .= latencyP99Ms rec
    , "latency_p999_ms" .= latencyP999Ms rec
    , "initial_memory_mb" .= initialMemoryMb rec
    , "peak_memory_mb" .= peakMemoryMb rec
    , "final_memory_mb" .= finalMemoryMb rec
    , "gc_count" .= gcCount rec
    , "gc_time_ms" .= gcTimeMs rec
    , "subscription_catchup_time_ms" .= subscriptionCatchUpTimeMs rec
    , "subscription_throughput_eps" .= subscriptionThroughput rec
    , "avg_queue_depth" .= avgQueueDepth rec
    , "subscription_lag_ms" .= subscriptionLagMs rec
    , "queue_overflow_count" .= queueOverflowCount rec
    ]

instance DefaultOrdered BenchmarkRecord where
  headerOrder _ = header
    [ "timestamp"
    , "scenario" 
    , "backend"
    , "tx_count"
    , "events_per_tx"
    , "sub_count"
    , "event_size_bytes"
    , "insertion_time_ms"
    , "insertion_throughput_eps"
    , "avg_latency_ms"
    , "latency_p50_ms"
    , "latency_p95_ms"
    , "latency_p99_ms"
    , "latency_p999_ms"
    , "initial_memory_mb"
    , "peak_memory_mb"
    , "final_memory_mb"
    , "gc_count"
    , "gc_time_ms"
    , "subscription_catchup_time_ms"
    , "subscription_throughput_eps"
    , "avg_queue_depth"
    , "subscription_lag_ms"
    , "queue_overflow_count"
    ]

-- | Convert BenchmarkResult to CSV record
resultToCSVRecord :: UTCTime -> CT.BenchmarkResult -> BenchmarkRecord
resultToCSVRecord timestamp (CT.BenchmarkResult backend (CT.BenchmarkConfig numTransactions eventsPerTransaction numSubscriptions eventSizeBytes _) scenarioName insertionTime insertionThroughput avgLatency latencyPercentiles memoryMetrics subscriptionCatchUpTime subscriptionThroughput queueMetrics) = BenchmarkRecord
  { timestamp = pack $ formatTime defaultTimeLocale "%Y-%m-%d %H:%M:%S" timestamp
  , scenario = scenarioName
  , backend = pack $ show backend
  , txCount = numTransactions
  , eventsPerTx = eventsPerTransaction
  , subCount = numSubscriptions
  , eventSizeBytes = eventSizeBytes
  , insertionTimeMs = realToFrac (insertionTime * 1000)
  , insertionThroughput = insertionThroughput
  -- Latency metrics
  , avgLatencyMs = fmap (realToFrac . (*1000)) avgLatency
  , latencyP50Ms = case latencyPercentiles of
      Just (CT.LatencyPercentiles p50 _ _ _) -> Just $ realToFrac (p50 * 1000)
      Nothing -> Nothing
  , latencyP95Ms = case latencyPercentiles of
      Just (CT.LatencyPercentiles _ p95 _ _) -> Just $ realToFrac (p95 * 1000)
      Nothing -> Nothing
  , latencyP99Ms = case latencyPercentiles of
      Just (CT.LatencyPercentiles _ _ p99 _) -> Just $ realToFrac (p99 * 1000)
      Nothing -> Nothing
  , latencyP999Ms = case latencyPercentiles of
      Just (CT.LatencyPercentiles _ _ _ p999) -> Just $ realToFrac (p999 * 1000)
      Nothing -> Nothing
  -- Memory metrics
  , initialMemoryMb = case memoryMetrics of
      Just (CT.MemoryMetrics initial _ _ _ _) -> Just initial
      Nothing -> Nothing
  , peakMemoryMb = case memoryMetrics of
      Just (CT.MemoryMetrics _ peak _ _ _) -> Just peak  
      Nothing -> Nothing
  , finalMemoryMb = case memoryMetrics of
      Just (CT.MemoryMetrics _ _ final _ _) -> Just final
      Nothing -> Nothing
  , gcCount = case memoryMetrics of
      Just (CT.MemoryMetrics _ _ _ count _) -> Just count
      Nothing -> Nothing
  , gcTimeMs = case memoryMetrics of
      Just (CT.MemoryMetrics _ _ _ _ time) -> Just time
      Nothing -> Nothing
  -- Subscription metrics
  , subscriptionCatchUpTimeMs = fmap (realToFrac . (*1000)) subscriptionCatchUpTime
  , subscriptionThroughput = subscriptionThroughput
  -- Queue metrics (mostly for PostgreSQL)
  , avgQueueDepth = case queueMetrics of
      Just (CT.QueueMetrics _ avgDepth _ _) -> Just avgDepth
      Nothing -> Nothing
  , subscriptionLagMs = case queueMetrics of
      Just (CT.QueueMetrics _ _ lagMs _) -> Just lagMs
      Nothing -> Nothing
  , queueOverflowCount = case queueMetrics of
      Just (CT.QueueMetrics _ _ _ overflow) -> Just overflow
      Nothing -> Nothing
  }

-- | Write benchmark results to CSV file
writeCSVResults :: String -> [CT.BenchmarkResult] -> IO ()
writeCSVResults csvFile results = do
  -- Create directory if it doesn't exist
  createDirectoryIfMissing True (takeDirectory csvFile)
  
  -- Get current timestamp for all records
  timestamp <- getCurrentTime
  let csvRecords = map (resultToCSVRecord timestamp) results
  
  -- Write CSV
  BL.writeFile csvFile $ encodeDefaultOrderedByName csvRecords
  
  putStrLn $ "Exported " ++ show (length results) ++ " benchmark results to " ++ csvFile