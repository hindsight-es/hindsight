Building Hindsight
==================

This guide covers building, testing, and developing Hindsight.

Prerequisites
-------------

- GHC 9.10.2 or later (tested with 9.10.2 and 9.12.2)
- Cabal 3.8 or later
- PostgreSQL (for PostgreSQL backend tests)

Building the Library
--------------------

Build the main library:

.. code-block:: bash

   cabal build hindsight

Build all targets including tests and benchmarks:

.. code-block:: bash

   cabal build all

Running Tests
-------------

Run the complete test suite:

.. code-block:: bash

   cabal run hindsight-test

Run tests with detailed output:

.. code-block:: bash

   cabal test --test-show-details=streaming

Run specific test patterns:

.. code-block:: bash

   # Test only Store modules
   cabal run hindsight-test -- --pattern "Store"
   
   # Test only Projection modules  
   cabal run hindsight-test -- --pattern "Projection"

Development Environment
-----------------------

This project uses Nix flakes for development environment management.

**Binary Caching (Automatic)**

Binary caching is configured automatically via ``nixConfig`` in ``flake.nix``. When you enter the development environment, Nix will automatically use the Hindsight cachix cache (``hindsight-es.cachix.org``) for pre-built binaries.

**Enter Development Environment**

.. code-block:: bash

   # Full environment (HLS, ghcid, all dev tools)
   nix develop

   # OR: Minimal CI environment (faster, subset of tools)
   nix develop .#ci

   # OR: Automatic with direnv (recommended)
   echo "use flake" > .envrc
   direnv allow

**Available Development Shells:**

- ``nix develop`` (default): **Full development environment**

  - Haskell Language Server (HLS)
  - ghcid (fast rebuilds)
  - graphmod (dependency visualization)
  - weeder (dead code detection)
  - Documentation tools (Sphinx, Pandoc)
  - PostgreSQL for testing
  - R and plotting tools (for benchmarks)

- ``nix develop .#ci``: **Minimal CI environment**

  - Core build tools only
  - weeder, documentation tools
  - Faster to build, used in CI
  - Good for quick builds or testing CI locally

**Without Nix:**

If not using Nix, ensure you have:

- Haskell Language Server (HLS)
- Fourmolu code formatter
- PostgreSQL for testing

Install these manually via your Haskell toolchain (GHCup, stack, etc.)

Code Formatting
---------------

The project uses Fourmolu for code formatting. Format all Haskell files:

.. code-block:: bash

   fourmolu --mode inplace $(find . -name '*.hs')

**Note:** Pre-commit hooks are not currently configured. Contributors should run Fourmolu manually before committing.

Fourmolu is provided in the Nix development environment (``nix develop``).