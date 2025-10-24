Development Guide
=================

This guide covers building, testing, and developing Hindsight.

Prerequisites
-------------

- GHC 9.10 or later (tested with 9.10.2, 9.10.3 and 9.12.2)
- Cabal 3.8 or later
- PostgreSQL (for PostgreSQL backend tests)

Building
--------

Basic Build Commands
~~~~~~~~~~~~~~~~~~~~

Build the main library:

.. code-block:: bash

   cabal build hindsight

Build all targets including tests and benchmarks:

.. code-block:: bash

   cabal build all

Development Environment
~~~~~~~~~~~~~~~~~~~~~~~

This project uses Nix flakes for development environment management.

**Enter Development Environment:**

.. code-block:: bash

   # Full environment (HLS, all dev and build tools)
   nix develop

   # OR: Minimal CI environment (faster, smaller subset of tools)
   nix develop .#ci

   # OR: Automatic with direnv (recommended)
   echo "use flake" > .envrc
   direnv allow

**Binary Caching:**

Binary caching is configured automatically via ``nixConfig`` in ``flake.nix``. When you enter the development environment, Nix automatically uses the Hindsight cachix cache (``hindsight-es.cachix.org``) for pre-built binaries.

**Without Nix:**

If not using Nix, ensure you have:

- Cabal and GHC
- Fourmolu code formatter
- PostgreSQL for testing
- Optional: Haskell Language Server (HLS)


Code Formatting
~~~~~~~~~~~~~~~

The project uses Fourmolu for code formatting:

.. code-block:: bash

   # Format all Haskell files
   fourmolu --mode inplace $(find . -name '*.hs')

   # Check formatting without modifying files
   fourmolu --mode check $(find . -name '*.hs')

Fourmolu is provided in the Nix development environment.

Testing
-------

Running Tests
~~~~~~~~~~~~~

Run the complete test suite:

.. code-block:: bash

   cabal run hindsight-test

Run with detailed streaming output:

.. code-block:: bash

   cabal test --test-show-details=streaming

Run specific test patterns:

.. code-block:: bash

   # Test only Store modules
   cabal run hindsight-test -- --pattern "Store"

   # Test only Projection modules
   cabal run hindsight-test -- --pattern "Projection"

   # Test PostgreSQL-specific functionality
   cabal run hindsight-test -- --pattern "PostgreSQL"

Test Structure
~~~~~~~~~~~~~~

Hindsight uses a comprehensive testing strategy:

- **Property-based tests**: Using Hedgehog and QuickCheck for invariants
- **Integration tests**: Full end-to-end testing with real storage backends
- **Golden tests**: JSON serialization compatibility tests
- **Store-agnostic tests**: Tests that run against all storage backends
- **Store-specific tests**: "whitebox" tests or testing store-specific features (such as synchronous projections in the PostgreSQL backend)


PostgreSQL Testing
~~~~~~~~~~~~~~~~~~

PostgreSQL tests use ``tmp-postgres`` to create isolated test databases.

Documentation
-------------

Building Documentation
~~~~~~~~~~~~~~~~~~~~~~

Hindsight uses Sphinx for narrative documentation and Haddock for API reference.

Build complete documentation:

.. code-block:: bash

   cd docs
   make html

   # Open the built documentation
   open build/html/index.html

Fast iteration (reuses cached Haddock):

.. code-block:: bash

   cd docs
   make html-no-haddock

Generate only Haddock:

.. code-block:: bash

   cd docs
   make haddock

   # Or directly with cabal
   cabal haddock all --haddock-hyperlink-source --haddock-quickjump

Clean documentation build:

.. code-block:: bash

   cd docs
   make clean

Contributing
------------

Contributions welcome: bug reports, documentation improvements, feedback, pull requests.

**Setup:**

.. code-block:: bash

   git clone https://github.com/hindsight-es/hindsight.git
   cd hindsight

**Build & Test:**

See sections above for build and test commands. Run ``cabal test all`` before submitting PRs.

**Format:**

Run ``fourmolu`` before committing (see Code Formatting section above).

**Help:**

Open an issue: https://github.com/hindsight-es/hindsight/issues
