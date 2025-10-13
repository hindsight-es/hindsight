#!/bin/bash

# Run large-scale PostgreSQL performance benchmarks with statistical analysis

echo "Hindsight Large-Scale Performance Benchmarks"
echo "============================================"
echo ""
echo "This will run comprehensive scaling tests and generate statistical analysis."
echo ""

# Parse arguments
BENCHMARK_TYPE="scale"
CSV_DIR="benchmark-results"
ANALYSIS_DIR="analysis-output"

while [[ $# -gt 0 ]]; do
  case $1 in
    --tx-only)
      BENCHMARK_TYPE="scale-tx"
      echo "Running transaction scaling benchmarks only"
      shift
      ;;
    --sub-only)
      BENCHMARK_TYPE="scale-sub" 
      echo "Running subscription scaling benchmarks only"
      shift
      ;;
    --csv-dir)
      CSV_DIR="$2"
      echo "CSV output directory: $CSV_DIR"
      shift 2
      ;;
    --analysis-dir)
      ANALYSIS_DIR="$2"
      echo "Analysis output directory: $ANALYSIS_DIR"
      shift 2
      ;;
    --help)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --tx-only           Run transaction scaling benchmarks only"
      echo "  --sub-only          Run subscription scaling benchmarks only"
      echo "  --csv-dir DIR       Specify CSV output directory (default: benchmark-results)"
      echo "  --analysis-dir DIR  Specify analysis output directory (default: analysis-output)"
      echo "  --help              Show this help message"
      echo ""
      echo "Examples:"
      echo "  $0                           # Run all benchmarks"
      echo "  $0 --tx-only                # Run transaction scaling only"
      echo "  $0 --csv-dir ./results      # Custom CSV output directory"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

echo ""

# Build the benchmarks first
echo "Building benchmarks..."
nix develop -c cabal build hindsight-benchmarks
BUILD_STATUS=$?

if [ $BUILD_STATUS -ne 0 ]; then
  echo "❌ Build failed"
  exit 1
fi

echo ""

# Run the benchmarks
echo "Running $BENCHMARK_TYPE benchmarks..."
echo "This may take 10-30 minutes depending on scale..."
echo ""

nix develop -c cabal run hindsight-benchmarks -- $BENCHMARK_TYPE --csv "$CSV_DIR" +RTS -T -RTS
BENCHMARK_STATUS=$?

if [ $BENCHMARK_STATUS -ne 0 ]; then
  echo "❌ Benchmarks failed"
  exit 1
fi

echo ""

# Find the most recent CSV file
CSV_FILE=$(find "$CSV_DIR" -name "*.csv" -type f -exec ls -1t {} + | head -n1)

if [ -z "$CSV_FILE" ]; then
  echo "❌ No CSV file found in $CSV_DIR"
  exit 1
fi

echo "Found benchmark results: $CSV_FILE"
echo ""

# Check if R is available
if ! command -v Rscript &> /dev/null; then
  echo "⚠️  R not found. Statistical analysis skipped."
  echo "   To install R:"
  echo "   - macOS: brew install r"
  echo "   - Ubuntu: apt install r-base"
  echo "   - Or use nix: nix-shell -p R"
  echo ""
  echo "Manual analysis:"
  echo "   Rscript hindsight/scripts/analyze-benchmarks.R '$CSV_FILE' '$ANALYSIS_DIR'"
  exit 0
fi

# Check R dependencies
echo "Checking R dependencies..."
Rscript -e "
required_pkgs <- c('ggplot2', 'dplyr', 'readr', 'broom', 'gridExtra', 'scales')
missing_pkgs <- required_pkgs[!(required_pkgs %in% installed.packages()[,'Package'])]
if (length(missing_pkgs) > 0) {
  cat('Installing missing R packages:', paste(missing_pkgs, collapse=', '), '\n')
  install.packages(missing_pkgs, repos='https://cran.rstudio.com/', quiet=TRUE)
}
"

# Run statistical analysis
echo ""
echo "Running statistical regression analysis..."
echo "Analysis output directory: $ANALYSIS_DIR"
echo ""

Rscript hindsight/scripts/analyze-benchmarks.R "$CSV_FILE" "$ANALYSIS_DIR"
ANALYSIS_STATUS=$?

if [ $ANALYSIS_STATUS -eq 0 ]; then
  echo ""
  echo "✅ Analysis complete!"
  echo ""
  echo "Results:"
  echo "📊 CSV data: $CSV_FILE"
  echo "📈 Analysis: $ANALYSIS_DIR/"
  echo "   - analysis_report.txt (detailed statistical results)"
  echo "   - *.png (performance plots)"
  echo ""
  echo "View plots:"
  echo "   open $ANALYSIS_DIR/*.png"
else
  echo "❌ Statistical analysis failed"
  echo "Manual analysis:"
  echo "   Rscript hindsight/scripts/analyze-benchmarks.R '$CSV_FILE' '$ANALYSIS_DIR'"
  exit 1
fi
