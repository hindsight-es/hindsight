#!/bin/bash

# Run PostgreSQL performance benchmarks

echo "PostgreSQL Performance Benchmark"
echo "================================"
echo ""
echo "This will run various scenarios to measure performance characteristics."
echo ""

# Build the benchmarks first
echo "Building benchmarks..."
nix develop -c cabal build hindsight-benchmarks

# Run the performance analysis mode
echo ""
echo "Running performance analysis..."
nix develop -c cabal run hindsight-benchmarks -- perf

# Optionally run criterion benchmarks for more detailed measurements
# echo ""
# echo "Running criterion benchmarks..."
# nix develop -c cabal run hindsight-benchmarks -- --output benchmark-results.html