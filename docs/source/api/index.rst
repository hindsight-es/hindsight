API Reference
=============

Hindsight provides comprehensive API documentation through Haddock, Haskell's standard documentation tool.

Package Documentation
---------------------

Hindsight is organized into focused packages with clean dependency boundaries:

**Core Library**
  📚 `hindsight-core <../haddock/hindsight-core/index.html>`_ - Type-safe event system with versioning

**Testing Libraries** (in hindsight-core)
  📚 `event-testing <../haddock/hindsight-core/event-testing/index.html>`_ - Test utilities for event generation

  📚 `store-testing <../haddock/hindsight-core/store-testing/index.html>`_ - Store testing utilities and property tests

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
