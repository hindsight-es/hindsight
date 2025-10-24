Installation
============

This guide shows how to add Hindsight to your Haskell project.

Two Ways to Add Hindsight
--------------------------

You can add Hindsight to your project either way:

1. **With Nix Flakes** - Reproducible builds with binary cache support
2. **Without Nix** - Plain ``cabal`` (fetches dependencies from GitHub)

Choose whichever fits your workflow.

Option A: With Nix Flakes
--------------------------

**Prerequisites:**

`Nix <https://nixos.org/>`_ with flakes enabled:

.. code-block:: bash

   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

**Setup:**

Add to your ``flake.nix``:

.. code-block:: nix

   {
     description = "My Hindsight project";

     nixConfig = {
       extra-substituters = [ "https://hindsight-es.cachix.org" ];
       extra-trusted-public-keys = [
         "hindsight-es.cachix.org-1:2UQwF1OeL+6JQqIEhPXRivkNIRuO5dNcBrWYZ3vbpWk="
       ];
     };

     inputs = {
       nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
       hindsight.url = "github:hindsight-es/hindsight/main";
       hindsight.inputs.nixpkgs.follows = "nixpkgs";  # Maximize cache hits
     };

     outputs = { self, nixpkgs, hindsight }:
       let
         system = "x86_64-linux";  # or aarch64-darwin, etc.
         pkgs = nixpkgs.legacyPackages.${system};

         haskellPackages = pkgs.haskell.packages.ghc910.extend (self: super: {
           my-project = self.callCabal2nix "my-project" ./. {};

           # Import Hindsight packages from flake input
           hindsight-core = hindsight.packages.${system}.hindsight-core;
           hindsight-memory-store = hindsight.packages.${system}.hindsight-memory-store;
           hindsight-postgresql-store = hindsight.packages.${system}.hindsight-postgresql-store;
           hindsight-postgresql-projections = hindsight.packages.${system}.hindsight-postgresql-projections;
         });

       in {
         packages.${system}.default = haskellPackages.my-project;

         devShells.${system}.default = haskellPackages.shellFor {
           packages = p: [ p.my-project ];
           buildInputs = [ pkgs.haskellPackages.cabal-install ];
         };
       };
   }

**Binary Cache:**

The ``nixConfig`` section automatically configures the Hindsight cachix cache for pre-built binaries.

- **Trusted users** (in ``/etc/nix/nix.conf``): Works automatically
- **Other users**: You'll see a warning about "ignoring untrusted flake configuration"

  The cache won't work unless your system administrator either:

  - Adds you to ``trusted-users`` in ``/etc/nix/nix.conf``, OR
  - Adds ``https://hindsight-es.cachix.org`` to ``trusted-substituters``

If the cache isn't available, the first build will compile from source (a few minutes).

Option B: Without Nix
----------------------

**Prerequisites:**

- GHC 9.10+
- Cabal 3.8 or later
- Git (for fetching dependencies)

**Setup:**

Add to your ``cabal.project``:

.. code-block:: cabal

   packages:
     ./your-package.cabal

   source-repository-package
       type: git
       location: https://github.com/hindsight-es/hindsight.git
       tag: main
       subdir: hindsight-core

   source-repository-package
       type: git
       location: https://github.com/hindsight-es/hindsight.git
       tag: main
       subdir: hindsight-memory-store

   -- Optional: Add other backends as needed
   -- hindsight-filesystem-store
   -- hindsight-postgresql-store
   -- hindsight-postgresql-projections

Add to your ``.cabal`` file:

.. code-block:: cabal

   build-depends:
       base >= 4.18 && < 5,
       hindsight-core,
       hindsight-memory-store,
       -- Optional: add other backends
       -- hindsight-postgresql-store,
       -- hindsight-postgresql-projections,
       aeson,
       text,
       uuid

   default-extensions:
       DataKinds
       DeriveAnyClass
       DeriveGeneric
       DuplicateRecordFields
       OverloadedRecordDot
       OverloadedStrings
       RequiredTypeArguments
       TypeApplications
       TypeFamilies

On first build, Cabal will fetch Hindsight packages from GitHub.

Available Packages
------------------

**Core Library:**

- ``hindsight-core`` - Type-safe event system with versioning (required)

**Storage Backends:**

- ``hindsight-memory-store`` - In-memory event store (testing/development)
- ``hindsight-filesystem-store`` - File-based event persistence
- ``hindsight-postgresql-store`` - PostgreSQL event store with ACID guarantees

**Projection System:**

- ``hindsight-postgresql-projections`` - Backend-agnostic projection system (always uses PostgreSQL for execution)

Basic Usage
-----------

Import Hindsight modules:

.. code-block:: haskell

   import Hindsight
   import Hindsight.Store.Memory (newMemoryStore)

   -- For PostgreSQL:
   -- import Hindsight.Store.PostgreSQL (newSQLStore, createSQLSchema)
   -- import Hindsight.Projection (runProjection)

PostgreSQL Setup
----------------

For PostgreSQL backend and projections, you need a running PostgreSQL instance.

The schema is automatically created when you initialize the store:

.. code-block:: haskell

   import Hindsight.Store.PostgreSQL (createSQLSchema, newSQLStore)
   import qualified Hasql.Pool as Pool

   main = do
     pool <- createPool postgresSettings

     -- Create schema (idempotent - safe to run multiple times)
     _ <- Pool.use pool createSQLSchema

     store <- newSQLStore connStr

Example Project
---------------

See the `Hindsight example repository <https://github.com/hindsight-es/hindsight-example>`_ for a complete, runnable example demonstrating:

- Event definitions
- Event storage
- Event subscriptions
- Both Nix and non-Nix builds

Next Steps
----------

Continue to :doc:`tutorials/01-getting-started` to learn how to define events and build event-sourced applications with Hindsight.
