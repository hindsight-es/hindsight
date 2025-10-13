.PHONY: all build-website build-docs clean-website clean-docs clean watch help

# Default target - build everything
all: build-website

# Build complete website (docs + site)
build-website: build-docs
	@echo "Building Hakyll site..."
	cd website && cabal run site -- build
	@echo ""
	@echo "✓ Website built successfully!"
	@echo "  Output: website/_site/"
	@echo "  Preview: cd website && cabal run site -- watch"

# Build Sphinx documentation (and Haddock)
build-docs:
	@echo "Building documentation..."
	cd docs && $(MAKE) html
	@echo "✓ Documentation built successfully!"

# Preview website with live server
watch: build-website
	@echo "Starting preview server at http://localhost:8000"
	cd website && cabal run site -- watch

# Clean website build artifacts
clean-website:
	@echo "Cleaning website build artifacts..."
	cd website && cabal run site -- clean
	@echo "✓ Website cleaned"

# Clean documentation build artifacts
clean-docs:
	@echo "Cleaning documentation artifacts..."
	cd docs && $(MAKE) clean
	@echo "✓ Documentation cleaned"

# Clean everything
clean: clean-website clean-docs
	@echo "✓ All build artifacts cleaned"

# Rebuild everything from scratch
rebuild: clean all

# Show help
help:
	@echo "Hindsight Website Build System"
	@echo ""
	@echo "Targets:"
	@echo "  all            Build complete website (default)"
	@echo "  build-website  Build Hakyll site (includes docs)"
	@echo "  build-docs     Build Sphinx documentation only"
	@echo "  watch          Build and start preview server"
	@echo "  clean          Remove all build artifacts"
	@echo "  clean-website  Remove website artifacts only"
	@echo "  clean-docs     Remove documentation artifacts only"
	@echo "  rebuild        Clean and rebuild everything"
	@echo "  help           Show this help message"
	@echo ""
	@echo "Usage:"
	@echo "  make              # Build everything"
	@echo "  make watch        # Preview at http://localhost:8000"
	@echo "  make clean        # Clean all artifacts"
	@echo "  make rebuild      # Full rebuild from scratch"
