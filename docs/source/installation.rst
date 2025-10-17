Installation
============

Prerequisites
-------------

- GHC 9.10.2 or later
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

For development with Nix flakes:

.. code-block:: bash

   # Enter development shell
   nix develop

   # Or use direnv (recommended)
   direnv allow

This provides GHC, Cabal, HLS, and PostgreSQL for testing.

Next Steps
----------

Continue to :doc:`tutorials/01-getting-started` for your first event.
