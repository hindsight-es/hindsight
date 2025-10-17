Testing Guide
=============

Hindsight uses a comprehensive testing strategy combining property-based testing, integration tests, and golden tests.

Test Structure
--------------

The test suite is organized as follows:

- **Property-based tests**: Using Hedgehog and QuickCheck for testing laws and invariants
- **Integration tests**: Full end-to-end testing with real storage backends
- **Golden tests**: JSON serialization compatibility tests
- **Store-agnostic tests**: Tests that run against all storage backends

Running Tests
-------------

Run all tests:

.. code-block:: bash

   cabal run hindsight-test

Run with streaming output for better visibility:

.. code-block:: bash

   cabal test --test-show-details=streaming

Run specific test modules:

.. code-block:: bash

   # Store backend tests
   cabal run hindsight-test -- --pattern "Store"
   
   # Projection system tests  
   cabal run hindsight-test -- --pattern "Projection"
   
   # PostgreSQL-specific tests
   cabal run hindsight-test -- --pattern "PostgreSQL"

PostgreSQL Testing
------------------

PostgreSQL integration tests use tmp-postgres to create isolated test databases:

- Each test gets a fresh PostgreSQL instance
- Schema is automatically created and migrated
- Tests run in parallel without interference
- Cleanup is automatic

Golden Tests
------------

Golden tests ensure JSON serialization compatibility across versions:

.. code-block:: bash

   # Location of golden test files
   test/golden/
   golden/events/

When event formats change, regenerate golden files:

.. code-block:: bash

   # This will update the expected outputs
   cabal run hindsight-test -- --accept

Property-Based Testing
----------------------

The project uses Hedgehog for property-based testing. Key properties tested:

Event Store Properties
~~~~~~~~~~~~~~~~~~~~~~
- **Append-only**: Events once written cannot be modified
- **Ordering**: Events maintain causal ordering
- **Atomicity**: Transaction boundaries are respected

Projection Properties  
~~~~~~~~~~~~~~~~~~~~~
- **Idempotency**: Replaying events produces same result
- **Consistency**: Projections reflect all committed events
- **Concurrency**: Multiple projections don't interfere

Writing Tests
-------------

When adding new features, include:

1. **Unit tests** for individual functions
2. **Property tests** for invariants and laws
3. **Integration tests** for end-to-end scenarios
4. **Golden tests** for serialization formats

Test Organization
-----------------

Tests are organized to match the source structure:

.. code-block::

   test/
   ├── Test/
   │   ├── Hindsight/
   │   │   ├── Store/
   │   │   │   ├── Common.hs          # Store-agnostic tests
   │   │   │   ├── PostgreSQL/        # PostgreSQL-specific tests
   │   │   │   └── ...
   │   │   ├── Projection.hs
   │   │   └── ...
   │   └── Main.hs
   └── golden/                        # Golden test files