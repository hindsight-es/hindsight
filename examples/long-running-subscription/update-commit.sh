#!/usr/bin/env bash
# Update cabal.project.docker to use the latest commit from hindsight-es/hindsight

set -e

BRANCH="${1:-main}"

echo "🔍 Fetching latest commit from hindsight-es/hindsight $BRANCH..."
COMMIT=$(git ls-remote https://github.com/hindsight-es/hindsight.git "$BRANCH" | awk '{print $1}')

if [ -z "$COMMIT" ]; then
    echo "❌ Failed to fetch commit hash"
    exit 1
fi

echo "📝 Latest commit: $COMMIT"

# Update cabal.project.docker
if [ -f "cabal.project.docker" ]; then
    # Use perl for cross-platform compatibility
    # Only replace the first tag (hindsight repo), not tmp-postgres
    perl -i -pe "s|(location: https://github.com/hindsight-es/hindsight.git\n    tag: )[a-f0-9]{40}|\${1}$COMMIT|" cabal.project.docker
    echo "✅ Updated cabal.project.docker"
else
    echo "❌ cabal.project.docker not found"
    exit 1
fi

echo ""
echo "🐳 Rebuild Docker images with:"
echo "  docker build -f Dockerfile.ghc-9.10 -t hindsight-example:ghc-9.10 ."
echo "  docker build -f Dockerfile.ghc-9.12 -t hindsight-example:ghc-9.12 ."
echo ""
echo "💡 Usage: $0 [branch]"
echo "   Default branch: main"
echo "   Example: $0 docker-example"
