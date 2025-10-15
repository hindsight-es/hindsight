{-# LANGUAGE OverloadedStrings #-}

module Core.Metrics 
  ( withMemoryProfiling
  , withLatencyMeasurement
  , calculateLatencyPercentiles
  , collectMemoryMetrics
  , BytesAllocated(..)
  ) where

import Core.Types
import Data.IORef (IORef, newIORef, readIORef, writeIORef)
import Data.List (sort)
import Data.Time (getCurrentTime, diffUTCTime, NominalDiffTime)
import GHC.Stats (getRTSStats, RTSStats(..), gcs, gcdetails_live_bytes, gc_cpu_ns, gc)
import System.IO.Unsafe (unsafePerformIO)

-- | Track bytes allocated for memory profiling
newtype BytesAllocated = BytesAllocated Int
  deriving (Show, Eq)

-- | Global reference for latency measurements (not ideal but works for benchmarking)
{-# NOINLINE latencyRef #-}
latencyRef :: IORef [NominalDiffTime]
latencyRef = unsafePerformIO $ newIORef []

-- | Clear latency measurements
clearLatencies :: IO ()
clearLatencies = writeIORef latencyRef []

-- | Get and clear latency measurements
getLatencies :: IO [NominalDiffTime]
getLatencies = do
  lats <- readIORef latencyRef
  writeIORef latencyRef []
  return lats

-- | Run action with memory profiling
withMemoryProfiling :: IO a -> IO (a, MemoryMetrics)
withMemoryProfiling action = do
  initialStats <- getRTSStats
  let initialMB = fromIntegral (gcdetails_live_bytes $ gc initialStats) `div` (1024 * 1024)
      initialGCs = gcs initialStats
      initialGCTime = fromIntegral (gc_cpu_ns initialStats) / 1_000_000  -- Convert to ms
  
  result <- action
  
  finalStats <- getRTSStats
  let finalMB = fromIntegral (gcdetails_live_bytes $ gc finalStats) `div` (1024 * 1024)
      finalGCs = gcs finalStats
      finalGCTime = fromIntegral (gc_cpu_ns finalStats) / 1_000_000  -- Convert to ms
      
      metrics = MemoryMetrics
        { initialMemoryMB = initialMB
        , peakMemoryMB = max initialMB finalMB  -- Approximation
        , finalMemoryMB = finalMB
        , gcCount = fromIntegral finalGCs - fromIntegral initialGCs
        , gcTimeMs = finalGCTime - initialGCTime
        }
  
  return (result, metrics)

-- | Run action with latency measurement
withLatencyMeasurement :: Int -> IO a -> IO (a, Maybe NominalDiffTime)
withLatencyMeasurement numOperations action = do
  clearLatencies
  
  startTime <- getCurrentTime
  result <- action
  endTime <- getCurrentTime
  
  latencies <- getLatencies
  
  let avgLatency = if null latencies
        then Just $ diffUTCTime endTime startTime / fromIntegral numOperations
        else Just $ sum latencies / fromIntegral (length latencies)
  
  return (result, avgLatency)

-- | Calculate latency percentiles from a list of measurements
calculateLatencyPercentiles :: [NominalDiffTime] -> Maybe LatencyPercentiles
calculateLatencyPercentiles [] = Nothing
calculateLatencyPercentiles latencies = 
  let sorted = sort latencies
      n = length sorted
      percentile p = sorted !! (round (fromIntegral n * p / 100) - 1)
  in if n < 4  -- Need at least 4 measurements for meaningful percentiles
       then Nothing
       else Just $ LatencyPercentiles
         { p50 = percentile 50
         , p95 = percentile 95
         , p99 = percentile 99
         , p999 = percentile 99.9
         }

-- | Collect memory metrics without running an action
collectMemoryMetrics :: IO MemoryMetrics
collectMemoryMetrics = do
  stats <- getRTSStats
  let memMB = fromIntegral (gcdetails_live_bytes $ gc stats) `div` (1024 * 1024)
      gcCount = gcs stats
      gcTime = fromIntegral (gc_cpu_ns stats) / 1_000_000  -- Convert to ms
  
  return $ MemoryMetrics
    { initialMemoryMB = memMB
    , peakMemoryMB = memMB
    , finalMemoryMB = memMB
    , gcCount = fromIntegral gcCount
    , gcTimeMs = gcTime
    }