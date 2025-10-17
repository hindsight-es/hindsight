Building Hindsight
==================

This guide covers building, testing, and developing Hindsight.

Prerequisites
-------------

- GHC 9.8.2 or later
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

This project uses devenv.nix for development environment management. To set up:

.. code-block:: bash

   # Enter development shell
   devenv shell
   
   # Start development services (PostgreSQL, etc.)
   devenv up

The development environment includes:
- Haskell Language Server (HLS)
- Ormolu code formatter
- Pre-commit hooks
- PostgreSQL for testing

Code Formatting
---------------

The project uses Ormolu for code formatting. Format all Haskell files:

.. code-block:: bash

   ormolu --mode inplace $(find . -name '*.hs')

Pre-commit hooks automatically format code on commit.