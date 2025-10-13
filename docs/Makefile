# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line, and also
# from the environment for the first two.
SPHINXOPTS    ?=
SPHINXBUILD  ?= sphinx-build
SOURCEDIR    = source
BUILDDIR     = build
HADDOCKDIR   = $(BUILDDIR)/haddock
PROJECTDIR   = ..

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile haddock html html-no-haddock convert-lhs clean

# Convert LHS files to RST before building
convert-lhs:
	@echo "Converting Literate Haskell files to reStructuredText..."
	@python3 convert_lhs.py

# Generate Haddock documentation with cross-package links
haddock:
	@echo "Updating Hackage package index..."
	@cd $(PROJECTDIR) && cabal update
	@echo "Generating Haddock documentation with cabal haddock-project..."
	@cd $(PROJECTDIR) && cabal haddock-project --html-location='https://hackage.haskell.org/package/$$pkg-$$version/docs' --output=$(CURDIR)/$(HADDOCKDIR)
	@echo "Post-processing Haddock to fix internal package links..."
	@python3 fix_haddock_links.py $(HADDOCKDIR)
	@echo "Haddock documentation generated at $(HADDOCKDIR)/"

# Build HTML documentation with LHS conversion and Haddock
html: convert-lhs haddock
	@$(SPHINXBUILD) -M html "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
	@if [ -d "$(HADDOCKDIR)" ] && [ -f "$(HADDOCKDIR)/hindsight/index.html" ]; then \
		mkdir -p $(BUILDDIR)/html/haddock; \
		cp -r $(HADDOCKDIR)/* $(BUILDDIR)/html/haddock/; \
		echo "Haddock documentation integrated at $(BUILDDIR)/html/haddock/"; \
	fi
	@echo "HTML documentation built in $(BUILDDIR)/html/"

# Build PDF documentation
pdf: convert-lhs
	@$(SPHINXBUILD) -M latexpdf "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

# Clean all build files
clean:
	@$(SPHINXBUILD) -M clean "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
	@echo "Cleaning converted tutorial files..."
	@rm -rf "$(SOURCEDIR)/tutorials"
	@echo "Cleaning Haddock output..."
	@rm -rf "$(HADDOCKDIR)"

# Build HTML without regenerating Haddock (faster for iterative docs work)
html-no-haddock: convert-lhs
	@$(SPHINXBUILD) -M html "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
	@if [ -d "$(HADDOCKDIR)" ] && [ -f "$(HADDOCKDIR)/hindsight/index.html" ]; then \
		mkdir -p $(BUILDDIR)/html/haddock; \
		cp -r $(HADDOCKDIR)/* $(BUILDDIR)/html/haddock/; \
		echo "Using cached Haddock documentation at $(BUILDDIR)/html/haddock/"; \
	else \
		echo "WARNING: No cached Haddock found. Run 'make html' to generate."; \
	fi
	@echo "HTML documentation built in $(BUILDDIR)/html/"

# Live reload for development
live: convert-lhs
	@echo "Starting live reload server..."
	@sphinx-autobuild "$(SOURCEDIR)" "$(BUILDDIR)/html" --watch ../hindsight-tutorials/tutorials

# Install documentation dependencies
install-deps:
	@echo "Installing documentation dependencies..."
	@pip install -r requirements.txt

# Check for required tools
check-deps:
	@echo "Checking for required tools..."
	@which pandoc > /dev/null || (echo "ERROR: pandoc not found. Install with: brew install pandoc" && exit 1)
	@which sphinx-build > /dev/null || (echo "ERROR: sphinx not found. Run: make install-deps" && exit 1)
	@echo "All dependencies found!"

# Full build with dependency check
build: check-deps html
	@echo "Documentation build complete!"

# Development setup
setup: install-deps check-deps
	@echo "Documentation environment setup complete!"

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)