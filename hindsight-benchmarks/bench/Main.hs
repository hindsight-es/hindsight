{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Bench.ConcurrencyBenchmarks
import Bench.PostgreSQLOptimized
import Bench.PostgreSQLPerformance
import Bench.ScaleBenchmarks
import Bench.Simple
import Criterion.Main
import System.Environment (getArgs)

main :: IO ()
main = do
  args <- getArgs
  
  case args of
    ["perf"] -> do
      -- Run comprehensive performance analysis
      putStrLn "Running PostgreSQL Performance Analysis"
      putStrLn "======================================="
      runAllScenarios
    
    ["scale"] -> do
      -- Run large-scale benchmarks with CSV export
      runAllScaleBenchmarks Nothing
    
    ["scale-tx"] -> do
      -- Run transaction scaling only
      runTransactionScalingOnly Nothing
    
    ["scale-sub"] -> do 
      -- Run subscription scaling only
      runSubscriptionScalingOnly Nothing
    
    ("scale":"--csv":path:_) -> do
      -- Run large-scale benchmarks with custom CSV path
      runAllScaleBenchmarks (Just path)
      
    ("scale-tx":"--csv":path:_) -> do
      -- Run transaction scaling with custom CSV path
      runTransactionScalingOnly (Just path)
      
    ("scale-sub":"--csv":path:_) -> do
      -- Run subscription scaling with custom CSV path  
      runSubscriptionScalingOnly (Just path)
    
    ["scale-stats"] -> do
      -- Run statistical analysis benchmarks with replications
      runStatisticalBenchmarks Nothing
      
    ("scale-stats":"--csv":path:_) -> do
      -- Run statistical benchmarks with custom CSV path
      runStatisticalBenchmarks (Just path)
      
    ["quick-test"] -> do
      -- Run quick replication test for validation
      runQuickTest Nothing
      
    ["phase2"] -> do
      -- Run Phase 2 comprehensive scaling benchmarks
      runPhase2Benchmarks Nothing
    
    ("phase2":"--csv":path:_) -> do
      -- Run Phase 2 benchmarks with custom CSV path
      runPhase2Benchmarks (Just path)
    
    ["profile"] -> do
      -- Run profiling benchmark for bottleneck analysis
      putStrLn "Running Profiling Benchmark"
      putStrLn "==========================="
      putStrLn "Run with: +RTS -l -RTS for eventlog (analyze with threadscope)"
      putStrLn "Or with: +RTS -p -RTS for time profiling"
      putStrLn "Or with: +RTS -s -RTS for runtime statistics"
      putStrLn ""
      runProfilingBenchmark
    
    ["test-insertion"] -> do
      -- Test insertion throughput with disabled event processing
      runInsertionOnlyTest
    
    ["test-pgtune"] -> do
      -- Test pgtune configuration functionality
      putStrLn "Testing pgtune configuration..."
      runTuningConfigTest
    
    ["--help"] -> do
      putStrLn "Hindsight Benchmarks"
      putStrLn "===================="
      putStrLn ""
      putStrLn "Usage:"
      putStrLn "  hindsight-benchmarks              - Run standard Criterion benchmarks"
      putStrLn "  hindsight-benchmarks perf         - Run performance analysis (small scale)"
      putStrLn "  hindsight-benchmarks scale        - Run large-scale benchmarks with CSV export"
      putStrLn "  hindsight-benchmarks scale-tx     - Run transaction scaling benchmarks only"
      putStrLn "  hindsight-benchmarks scale-sub    - Run subscription scaling benchmarks only"
      putStrLn "  hindsight-benchmarks scale-stats  - Run statistical benchmarks with replications"
      putStrLn "  hindsight-benchmarks quick-test   - Run quick validation test (4 runs)"
      putStrLn "  hindsight-benchmarks phase2       - Run Phase 2 comprehensive scaling (33 runs)"
      putStrLn "  hindsight-benchmarks test-pgtune  - Test pgtune configuration"
      putStrLn "  hindsight-benchmarks scale --csv DIR - Export CSV to custom directory"
      putStrLn ""
      putStrLn "Analysis:"
      putStrLn "  After running scale benchmarks, analyze results with:"
      putStrLn "  Rscript hindsight/scripts/analyze-benchmarks.R results.csv [output-dir]"
    
    _ -> do
      -- Run standard benchmarks
      putStrLn "Starting Hindsight Event Store Benchmarks"
      putStrLn "This will benchmark Memory, Filesystem, and PostgreSQL backends"
      putStrLn "Use --help to see all available modes"
      putStrLn "========================================================"

      -- Get optimized PostgreSQL benchmarks
      optimizedBenchmarks <- optimizedPostgreSQLBenchmarks

      -- Get concurrency benchmarks
      concurrencyBenchmarks' <- concurrencyBenchmarks
      
      -- Get performance benchmarks
      perfBenchmarks <- performanceBenchmarks

      defaultMain $ simpleBenchmarks ++ optimizedBenchmarks ++ concurrencyBenchmarks' ++ perfBenchmarks
