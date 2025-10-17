Hindsight: Type-Safe Event Sourcing Documentation
================================================

Welcome to Hindsight, a type-safe event sourcing system implemented in Haskell. Hindsight provides strong compile-time guarantees for event handling, versioning, and consistency in event-driven applications with multiple storage backends.

.. image:: https://img.shields.io/badge/language-Haskell-blue.svg
   :target: https://www.haskell.org/
   :alt: Haskell

.. image:: https://img.shields.io/badge/license-MIT-green.svg
   :alt: License

Overview
--------

Hindsight provides type-safe event sourcing with:

- Compile-time event versioning and automatic upgrades
- Multiple storage backends (Memory, Filesystem, PostgreSQL)
- Backend-agnostic projections for building read models
- Real-time event subscriptions with pattern matching

See :doc:`introduction` for detailed feature descriptions.

Documentation Contents
----------------------

.. toctree::
   :maxdepth: 2
   :caption: Introduction

   introduction
   installation

.. toctree::
   :maxdepth: 2
   :caption: Tutorials

   tutorials/index

.. toctree::
   :maxdepth: 2
   :caption: API Reference
   
   api/index

.. toctree::
   :maxdepth: 1
   :caption: Development
   
   development/building
   development/testing
   development/contributing

Quick Start
-----------

Check out our :doc:`tutorials/01-getting-started` to begin using Hindsight in your project.

For installation instructions and development setup, see :doc:`development/building`.

Community
---------

- **Issues**: Report bugs and request features on our issue tracker
- **Discussions**: Join the community discussions
- **Contributing**: See our :doc:`development/contributing` guide

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`