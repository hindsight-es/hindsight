Installation
============

Quick Start (Choose Your Path)
-------------------------------

**Path 1: Nix (Recommended)**

Fast setup with binary caching:

.. code-block:: bash

   # Binary caches are configured automatically in flake.nix (nixConfig)
   # Just enter development environment:
   nix develop           # Full environment (HLS, dev tools)
   # OR
   nix develop .#ci      # Minimal environment (faster)

**Note:** The Hindsight cachix cache (``hindsight-es.cachix.org``) is configured automatically in ``flake.nix``. If you have Nix flakes enabled, binary caching will work out of the box!

**Path 2: GHCup (Non-Nix)**

Manual installation via GHCup:

.. code-block:: bash

   # Install GHCup
   curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

   # Install GHC and Cabal
   ghcup install ghc 9.10.2
   ghcup install cabal 3.12.1.0
   ghcup set ghc 9.10.2

   # Install PostgreSQL (platform-specific)
   # Ubuntu/Debian: sudo apt-get install postgresql libpq-dev
   # macOS: brew install postgresql

Prerequisites
-------------

- GHC 9.10.2 or later (tested with 9.10.2 and 9.12.2)
- Cabal 3.8 or later
- PostgreSQL (for PostgreSQL backend and projections)

Adding to Your Project
----------------------

Add Hindsight packages to your ``.cabal`` file:

.. code-block:: cabal

   build-depends:
       hindsight-core
     , hindsight-memory-store       -- In-memory store (testing/development)
     , hindsight-postgresql-store   -- PostgreSQL store
     , hindsight-postgresql-projections  -- Projection system

Import in your modules:

.. code-block:: haskell

   import Hindsight
   import Hindsight.Store.Memory (newMemoryStore)
   import Hindsight.Store.PostgreSQL (newSQLStore)
   import Hindsight.Projection (runProjection)

PostgreSQL Setup
----------------

For PostgreSQL backend and projections, you'll need a running PostgreSQL instance.

The schema is automatically created when you initialize the store:

.. code-block:: haskell

   import Hindsight.Store.PostgreSQL (createSQLSchema, newSQLStore)

   main = do
     pool <- createPool postgresSettings
     -- Create schema (idempotent - safe to run multiple times)
     _ <- Pool.use pool createSQLSchema
     store <- newSQLStore connStr

Development Setup
-----------------

For Nix Users
~~~~~~~~~~~~~

**Binary Caching (Automatic)**

Binary caching is configured automatically via ``nixConfig`` in ``flake.nix``. The Hindsight cache (``hindsight-es.cachix.org``) will be used automatically when you enter the dev environment, dramatically reducing build times.

**Enter Development Environment**

.. code-block:: bash

   # Full environment (recommended for development)
   nix develop

   # OR: Minimal CI environment (faster, fewer tools)
   nix develop .#ci

   # OR: Use direnv for automatic activation (recommended)
   echo "use flake" > .envrc
   direnv allow

**What's Included:**

- **Both shells provide:**

  - GHC 9.10.x
  - Cabal 3.8+
  - PostgreSQL for testing
  - Documentation tools (Sphinx, Pandoc)
  - weeder (dead code detection)

- **Full shell (``nix develop``) additionally includes:**

  - Haskell Language Server (HLS)
  - ghcid (fast rebuilds)
  - graphmod (dependency visualization)
  - R and plotting tools (for benchmarks)

For Non-Nix Users
~~~~~~~~~~~~~~~~~

If you installed via GHCup, ensure you have:

- Haskell Language Server (for editor integration)
- Fourmolu (code formatter): ``cabal install fourmolu``
- PostgreSQL for testing

Install these manually via your Haskell toolchain.

Next Steps
----------

Continue to :doc:`tutorials/01-getting-started` for your first event.
