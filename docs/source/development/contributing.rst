Contributing to Hindsight
========================

We welcome contributions to Hindsight! This guide will help you get started.

Development Setup
-----------------

1. **Clone the repository**

.. code-block:: bash

   git clone https://github.com/hindsight-es/hindsight.git
   cd hindsight

2. **Enter Development Environment**

Binary caching is configured automatically in ``flake.nix``:

.. code-block:: bash

   # Full development environment (recommended for contributors)
   nix develop

   # OR: Use direnv for automatic activation
   echo "use flake" > .envrc
   direnv allow

The development environment includes HLS, ghcid, weeder, and all necessary tools. Hindsight's cachix cache will be used automatically for pre-built binaries.

3. **Verify Setup**

.. code-block:: bash

   cabal build all
   cabal run hindsight-test

If tests pass, you're ready to contribute!

Code Style
----------

Hindsight follows these coding conventions:

Formatting
~~~~~~~~~~
- Use Fourmolu for automatic code formatting (more flexible than Ormolu)
- Run ``fourmolu --mode inplace $(find . -name '*.hs')`` before committing
- Line length: 80 characters preferred, 100 maximum
- Fourmolu is provided in the Nix development environment

Haskell Style
~~~~~~~~~~~~~
- Use qualified imports for clarity
- Prefer explicit type signatures
- Use record syntax for data types with multiple fields
- Follow naming conventions:
  - Functions: camelCase
  - Types: PascalCase
  - Modules: hierarchical (e.g., Hindsight.Store.PostgreSQL)

Language Extensions
~~~~~~~~~~~~~~~~~~~
- Use GHC2021 as the base language
- Additional extensions in .cabal file
- Avoid language extensions in individual modules when possible

Commit Guidelines
-----------------

Commit Message Format
~~~~~~~~~~~~~~~~~~~~~
Use conventional commit format:

.. code-block::

   type(scope): description
   
   [optional body]
   
   [optional footer]

Types:
- ``feat``: New feature
- ``fix``: Bug fix
- ``docs``: Documentation changes
- ``style``: Code style changes (formatting, etc.)
- ``refactor``: Code refactoring
- ``test``: Adding or updating tests
- ``chore``: Maintenance tasks

Examples:

.. code-block::

   feat(store): add PostgreSQL notification system
   
   fix(projection): resolve race condition in event processing
   
   docs(tutorials): add advanced projection patterns guide

Testing Requirements
--------------------

All contributions must include appropriate tests:

New Features
~~~~~~~~~~~~
- Unit tests for core functionality
- Property-based tests for invariants
- Integration tests for end-to-end behavior
- Documentation updates

Bug Fixes
~~~~~~~~~
- Regression test demonstrating the bug
- Fix implementation
- Ensure all existing tests pass

Documentation
~~~~~~~~~~~~~
- Update relevant documentation
- Add examples for new features
- Update tutorials if applicable

Pull Request Process
--------------------

1. **Fork** the repository
2. **Create a branch** for your changes
3. **Implement** your changes with tests
4. **Run the full test suite**:

   .. code-block:: bash
   
      cabal run hindsight-test

5. **Format code** with Fourmolu:

   .. code-block:: bash

      fourmolu --mode inplace $(find . -name '*.hs')

   **Note:** CI automatically checks code formatting and will reject unformatted code. You can test this locally with:

   .. code-block:: bash

      fourmolu --mode check $(find . -name '*.hs')

6. **Submit a pull request** with:
   - Clear description of changes
   - Reference to any related issues
   - Test coverage information

Review Process
--------------

All pull requests go through code review:

- **Automated checks**: CI runs tests, formatting checks, and weeder
- **Manual review**: Core maintainers review code and design
- **Discussion**: Address feedback and questions
- **Approval**: At least one maintainer approval required

Release Process
---------------

Hindsight follows semantic versioning:

- **Major**: Breaking API changes
- **Minor**: New features, backward compatible
- **Patch**: Bug fixes, backward compatible

Architecture Guidelines
-----------------------

When contributing, keep these principles in mind:

Type Safety
~~~~~~~~~~~
- Leverage Haskell's type system for correctness
- Use DataKinds for compile-time guarantees
- Prefer total functions over partial ones

Modularity
~~~~~~~~~~
- Keep modules focused and cohesive
- Use abstract interfaces for backend implementations
- Minimize dependencies between modules

Performance
~~~~~~~~~~~
- Profile before optimizing
- Consider memory usage in long-running projections
- Use appropriate data structures for use cases

Getting Help
------------

- **Issues**: Ask questions on GitHub issues
- **Discussions**: Join community discussions
- **Code Review**: Request feedback on draft PRs