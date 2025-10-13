{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TypeFamilies #-}

module Core.Types where

import Control.DeepSeq (NFData)
import Data.Aeson (FromJSON, ToJSON)
import Data.Text (Text)
import Data.Time (NominalDiffTime)
import GHC.Generics (Generic)
import Hindsight.Core

-- | Benchmark event type (same across all scenarios)
type BenchEvent = "bench_v2_event"

-- | Simple payload for benchmark events
data BenchPayload = BenchPayload
  { eventData :: Text,
    eventSize :: Int,
    benchTimestamp :: Text
  }
  deriving (Show, Eq, Generic, FromJSON, ToJSON, NFData)

-- | Version info for benchmark event (single version)
type instance MaxVersion BenchEvent = 0
type instance Versions BenchEvent = FirstVersion BenchPayload

-- | Event instance
instance Event BenchEvent

-- | No upgrade needed for single version
instance UpgradableToLatest BenchEvent 0 where
  upgradeToLatest = id

-- | Backend identification
data Backend = Memory | Filesystem | PostgreSQL
  deriving (Show, Eq, Ord, Generic, FromJSON, ToJSON)

-- | Benchmark configuration
data BenchmarkConfig = BenchmarkConfig
  { numTransactions :: Int
  , eventsPerTransaction :: Int
  , numSubscriptions :: Int
  , eventSizeBytes :: Int
  , warmupTransactions :: Int  -- Transactions to insert before measuring
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)

-- | Comprehensive benchmark result
data BenchmarkResult = BenchmarkResult
  { backend :: Backend
  , config :: BenchmarkConfig
  , scenarioName :: Text
  -- Core metrics
  , insertionTime :: NominalDiffTime
  , insertionThroughput :: Double  -- events per second
  -- Latency metrics
  , avgLatency :: Maybe NominalDiffTime
  , latencyPercentiles :: Maybe LatencyPercentiles
  -- Memory metrics
  , memoryMetrics :: Maybe MemoryMetrics
  -- Queue/subscription metrics
  , subscriptionCatchUpTime :: Maybe NominalDiffTime
  , subscriptionThroughput :: Maybe Double
  , queueMetrics :: Maybe QueueMetrics
  } deriving (Show, Generic, FromJSON, ToJSON)

-- | Latency percentiles for performance analysis
data LatencyPercentiles = LatencyPercentiles
  { p50 :: NominalDiffTime   -- median
  , p95 :: NominalDiffTime   -- 95th percentile  
  , p99 :: NominalDiffTime   -- 99th percentile
  , p999 :: NominalDiffTime  -- 99.9th percentile
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)

-- | Memory profiling metrics
data MemoryMetrics = MemoryMetrics
  { initialMemoryMB :: Int     -- Memory at start
  , peakMemoryMB :: Int        -- Peak memory usage
  , finalMemoryMB :: Int       -- Memory at end
  , gcCount :: Int             -- Number of GC cycles
  , gcTimeMs :: Double         -- Time spent in GC (milliseconds)
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)

-- | Queue and subscription metrics
data QueueMetrics = QueueMetrics
  { maxQueueDepth :: Int       -- Maximum queue depth observed
  , avgQueueDepth :: Double    -- Average queue depth
  , subscriptionLagMs :: Double -- Average subscription lag in ms
  , queueOverflowCount :: Int   -- Number of queue overflow events
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)

-- | Default benchmark configuration
defaultConfig :: BenchmarkConfig
defaultConfig = BenchmarkConfig
  { numTransactions = 1000
  , eventsPerTransaction = 10
  , numSubscriptions = 1
  , eventSizeBytes = 1000
  , warmupTransactions = 0
  }