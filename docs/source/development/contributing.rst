Contributing to Hindsight
========================

We welcome contributions to Hindsight! This guide will help you get started.

Development Setup
-----------------

1. Clone the repository
2. Set up the development environment using devenv:

.. code-block:: bash

   devenv shell

3. Build and test to ensure everything works:

.. code-block:: bash

   cabal build all
   cabal run hindsight-test

Code Style
----------

Hindsight follows these coding conventions:

Formatting
~~~~~~~~~~
- Use Ormolu for automatic code formatting
- Pre-commit hooks enforce formatting
- Line length: 80 characters preferred, 100 maximum

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

5. **Format code** with Ormolu:

   .. code-block:: bash
   
      ormolu --mode inplace $(find . -name '*.hs')

6. **Submit a pull request** with:
   - Clear description of changes
   - Reference to any related issues
   - Test coverage information

Review Process
--------------

All pull requests go through code review:

- **Automated checks**: CI runs tests and formatting checks
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