#!/usr/bin/env bash
# Manual deployment script for Hindsight website
# Builds Sphinx docs + Hakyll site locally

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🚀 Building Hindsight website..."
echo ""

# Build Sphinx documentation
echo "📚 Building Sphinx documentation..."
cd "$PROJECT_ROOT/docs"
make html
echo "✓ Sphinx docs built"
echo ""

# Build Hakyll site
echo "🏗️  Building Hakyll site..."
cd "$PROJECT_ROOT/website"
cabal run site build
echo "✓ Hakyll site built"
echo ""

# Show output location
echo "✅ Site built successfully!"
echo ""
echo "Output location: $PROJECT_ROOT/website/_site/"
echo ""
echo "To preview locally:"
echo "  cd website && cabal run site watch"
echo ""
echo "To deploy to GitHub Pages:"
echo "  git push hindsight-es main"
echo "  (GitHub Actions will automatically deploy)"
