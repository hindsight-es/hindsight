{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import System.Environment (getArgs)
import qualified Scenarios.Insertion as Insertion
import qualified Scenarios.Scaling as Scaling
import qualified Scenarios.Concurrency as Concurrency
import qualified Backends.PostgreSQL.Specific as PGSpecific

main :: IO ()
main = do
  args <- getArgs
  
  case args of
    [] -> do
      -- Run standard benchmark suite across all stores
      putStrLn "Hindsight Benchmark Suite v2"
      putStrLn "Running standard benchmarks across Memory, Filesystem, and PostgreSQL stores..."
      putStrLn "============================================================================"
      Insertion.runStandardSuite
    
    ["scale"] -> do
      -- Run scaling benchmarks with CSV output
      putStrLn "Running scaling benchmarks..."
      putStrLn "============================"
      Scaling.runScalingBenchmarks Nothing
    
    ("scale":"--csv":path:_) -> do
      -- Run scaling benchmarks with custom CSV path
      putStrLn $ "Running scaling benchmarks with CSV output to: " ++ path
      putStrLn "=================================================="
      Scaling.runScalingBenchmarks (Just path)
      
    ["profile"] -> do
      -- Run profiling benchmarks
      putStrLn "Running profiling benchmarks..."
      putStrLn "==============================="
      putStrLn "Run with: +RTS -l -RTS for eventlog (analyze with threadscope)"
      putStrLn "Or with: +RTS -p -RTS for time profiling"
      putStrLn "Or with: +RTS -s -RTS for runtime statistics"
      putStrLn ""
      Concurrency.runProfilingBenchmarks
    
    ["postgres"] -> do
      -- Run PostgreSQL-specific benchmarks
      putStrLn "Running PostgreSQL-specific benchmarks..."
      putStrLn "========================================="
      PGSpecific.runPostgreSQLSpecificBenchmarks
      
    ["--help"] -> do
      putStrLn "Hindsight Benchmark Suite v2"
      putStrLn "============================="
      putStrLn ""
      putStrLn "Usage:"
      putStrLn "  hindsight-bench-v2              - Run standard suite (all stores)"
      putStrLn "  hindsight-bench-v2 scale        - Run scaling benchmarks with CSV"
      putStrLn "  hindsight-bench-v2 scale --csv DIR - Custom CSV output directory"
      putStrLn "  hindsight-bench-v2 profile      - Run profiling benchmarks"
      putStrLn "  hindsight-bench-v2 postgres     - Run PostgreSQL-specific features"
      putStrLn ""
      putStrLn "Analysis:"
      putStrLn "  After running scale benchmarks, analyze with:"
      putStrLn "  Rscript bench-v2/scripts/analyze.R results.csv [output-dir]"
    
    _ -> do
      putStrLn "Unknown command. Use --help for usage information."