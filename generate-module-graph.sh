#!/usr/bin/env bash

# Generate module dependency graph for Hindsight library

set -euo pipefail

# Configuration
OUTPUT_FORMAT="${1:-svg}"
OUTPUT_FILE="${2:-module-graph.${OUTPUT_FORMAT}}"
GRAPH_TYPE="${3:-full}"  # full, pruned, or store-only

echo "Generating ${GRAPH_TYPE} module dependency graph..."

# Build list of all Haskell source files
# First, find all .hs files, excluding .hs-boot files
ALL_HS_FILES=$(find hindsight/src -name "*.hs" ! -name "*.hs-boot" | sort)

# Key modules we want to ensure are included
KEY_MODULES=(
    "hindsight/src/Hindsight.hs"
    "hindsight/src/Hindsight/Core.hs"
    "hindsight/src/Hindsight/Store.hs"
    "hindsight/src/Hindsight/Store/Memory.hs"
    "hindsight/src/Hindsight/Store/Filesystem.hs"
    "hindsight/src/Hindsight/Store/PostgreSQL.hs"
    "hindsight/src/Hindsight/Projection.hs"
    "hindsight/src/Hindsight/Tracing.hs"
)

echo "Found $(echo "$ALL_HS_FILES" | wc -l) Haskell source files"

# Function to generate graph with different options
generate_graph() {
    local prune_option="$1"
    local output_file="$2"
    
    echo "Generating graph with options: $prune_option"
    echo "Including key modules:"
    printf "%s\n" "${KEY_MODULES[@]}"
    
    # Use graphmod to generate the dependency graph
    if [[ "$prune_option" == "--prune-edges" ]]; then
        echo "Using --prune-edges (may hide some dependencies)"
    else
        echo "Showing all dependencies (no pruning)"
    fi
    
    # Run graphmod with explicit module list
    graphmod \
        -i hindsight/src \
        $prune_option \
        "${KEY_MODULES[@]}" \
        $ALL_HS_FILES \
        | dot -T"${OUTPUT_FORMAT}" -o "$output_file"
}

# Generate the requested graph type
case "$GRAPH_TYPE" in
    "full")
        generate_graph "" "$OUTPUT_FILE"
        ;;
    "pruned")
        generate_graph "--prune-edges" "$OUTPUT_FILE"
        ;;
    "store-only")
        # Generate a graph focused only on Store modules
        STORE_FILES=$(echo "$ALL_HS_FILES" | grep -E "(Store|Hindsight\.hs)")
        echo "Generating Store-focused graph with $(echo "$STORE_FILES" | wc -l) modules"
        graphmod \
            -i hindsight/src \
            $(echo "$STORE_FILES" | tr '\n' ' ') \
            | dot -T"${OUTPUT_FORMAT}" -o "$OUTPUT_FILE"
        ;;
    *)
        echo "Unknown graph type: $GRAPH_TYPE"
        echo "Available types: full, pruned, store-only"
        exit 1
        ;;
esac

echo "Module dependency graph generated: ${OUTPUT_FILE}"

# Provide feedback on what dependencies should be visible
echo ""
echo "Expected key dependencies in the graph:"
echo "- Hindsight.Store.Memory → Hindsight.Store"
echo "- Hindsight.Store.Filesystem → Hindsight.Store"  
echo "- Hindsight.Store.PostgreSQL → Hindsight.Store"
echo "- PostgreSQL submodules → their parent modules"

# Optional: open the file if on macOS
if [[ "$OSTYPE" == "darwin"* ]] && [[ "${OUTPUT_FORMAT}" == "svg" || "${OUTPUT_FORMAT}" == "png" ]]; then
    echo "Opening ${OUTPUT_FILE}..."
    open "${OUTPUT_FILE}"
fi