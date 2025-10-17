API Reference
=============

Hindsight provides comprehensive API documentation through Haddock, Haskell's standard documentation tool.

Package Documentation
---------------------

Hindsight is organized into focused packages with clean dependency boundaries:

**Core Library**
  📚 `hindsight-core <../haddock/hindsight-core/index.html>`_ - Type-safe event system with versioning

**Storage Backends**
  📚 `hindsight-memory-store <../haddock/hindsight-memory-store/index.html>`_ - In-memory event store (testing/development)

  📚 `hindsight-filesystem-store <../haddock/hindsight-filesystem-store/index.html>`_ - File-based event persistence

  📚 `hindsight-postgresql-store <../haddock/hindsight-postgresql-store/index.html>`_ - PostgreSQL event store

**Projection System**
  📚 `hindsight-postgresql-projections <../haddock/hindsight-postgresql-projections/index.html>`_ - Backend-agnostic projection system

Generating API Documentation
----------------------------

The Haddock documentation is automatically generated for all packages when building the documentation:

.. code-block:: bash

   # Build complete documentation (includes Haddock for all packages)
   cd docs
   make html

   # For faster builds (reuses cached Haddock)
   make html-no-haddock

   # Open the documentation
   open build/html/index.html

You can also generate Haddock directly without Sphinx:

.. code-block:: bash

   # Generate Haddock for all packages
   cabal haddock all --haddock-hyperlink-source --haddock-quickjump

   # Generate Haddock for a specific package
   cabal haddock hindsight --haddock-hyperlink-source --haddock-quickjump

Key API Modules by Package
---------------------------

**hindsight-core** (Core)
  - ``Hindsight.Events`` - Type-safe event definitions and versioning
  - ``Hindsight.Store`` - Abstract event store interface
  - ``Hindsight.Store.Parsing`` - Event parsing utilities
  - ``Hindsight.TH`` - Template Haskell helpers for event definitions
  - ``Hindsight.Tracing`` - OpenTelemetry observability integration

**hindsight-memory-store**
  - ``Hindsight.Store.Memory`` - In-memory event storage implementation
  - ``Hindsight.Store.Memory.Internal`` - Shared memory store utilities

**hindsight-filesystem-store**
  - ``Hindsight.Store.Filesystem`` - File-based event persistence

**hindsight-postgresql-store**
  - ``Hindsight.Store.PostgreSQL`` - Main PostgreSQL store interface
  - ``Hindsight.Store.PostgreSQL.Core.*`` - Schema and type definitions
  - ``Hindsight.Store.PostgreSQL.Events.*`` - Event operations (insertion, subscription, parsing)
  - ``Hindsight.Store.PostgreSQL.Projections.*`` - Sync projection state management

**hindsight-postgresql-projections**
  - ``Hindsight.Projection`` - Projection interface and execution
  - ``Hindsight.Projection.Common`` - Shared projection utilities
  - ``Hindsight.Projection.Matching`` - Event pattern matching for projections

Architecture Notes
------------------

**Backend-Agnostic Projections**: Projections execute in PostgreSQL for state management but subscribe to events from ANY store backend (Memory/Filesystem/PostgreSQL). This enables flexible deployment patterns:

- **Development/Testing**: Memory store + PostgreSQL projections (fast!)
- **Single-node**: Filesystem store + PostgreSQL projections
- **PostgreSQL**: PostgreSQL store + PostgreSQL projections

**Clean Dependency Boundaries**: The package structure prevents circular dependencies while enabling flexible composition.

Online Documentation
--------------------

For the latest API documentation, see the project's documentation site or generate it locally using the commands above.