#!/usr/bin/env bash
#
# Build Hindsight packages with Nix and push to Cachix
#
# Prerequisites:
# - Docker installed and running
# - Cachix auth token in .cachix-token file at repo root
#
# Usage:
#   ./scripts/build-and-cache.sh [package-name]
#
# Examples:
#   ./scripts/build-and-cache.sh                    # Build default (hindsight-website)
#   ./scripts/build-and-cache.sh hindsight          # Build library
#   ./scripts/build-and-cache.sh hindsight-website  # Build website
#   ./scripts/build-and-cache.sh munihac            # Build munihac demo

set -euo pipefail

# Configuration
CACHIX_CACHE="hindsight-es"
PACKAGE="${1:-hindsight-website}"
CACHIX_TOKEN_FILE=".cachix-token"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Check Docker is available
if ! command -v docker &> /dev/null; then
    error "Docker is not installed or not in PATH"
    exit 1
fi

# Check Docker daemon is running
if ! docker info &> /dev/null; then
    error "Docker daemon is not running"
    exit 1
fi

# Check Cachix token file exists
if [[ ! -f "$CACHIX_TOKEN_FILE" ]]; then
    error "Cachix token file not found: $CACHIX_TOKEN_FILE"
    echo ""
    echo "Please create $CACHIX_TOKEN_FILE with your Cachix auth token:"
    echo "  echo 'your-token-here' > $CACHIX_TOKEN_FILE"
    exit 1
fi

info "Building package: $PACKAGE"
info "Cachix cache: $CACHIX_CACHE"

# Run build in Docker with NixOS
info "Starting Docker build environment (NixOS)..."

docker run --rm \
    -v "$(pwd):/workspace" \
    -v "$CACHIX_TOKEN_FILE:/cachix-token:ro" \
    -w /workspace \
    nixos/nix:latest \
    bash -c "
        set -euo pipefail

        echo '🔧 Setting up Nix environment...'

        # Enable flakes
        mkdir -p ~/.config/nix
        echo 'experimental-features = nix-command flakes' > ~/.config/nix/nix.conf

        # Install cachix
        echo '📦 Installing Cachix...'
        nix-env -iA cachix -f https://cachix.org/api/v1/install

        # Configure cachix with token
        echo '🔑 Configuring Cachix authentication...'
        export CACHIX_AUTH_TOKEN=\$(cat /cachix-token)
        cachix use $CACHIX_CACHE

        # Build package and push to cache
        echo '🏗️  Building package: $PACKAGE'
        nix build .#$PACKAGE --print-build-logs 2>&1 | cachix push $CACHIX_CACHE

        echo '✅ Build complete! Package pushed to Cachix cache.'
    "

info "Build completed successfully!"
info "View cache at: https://app.cachix.org/cache/$CACHIX_CACHE"
