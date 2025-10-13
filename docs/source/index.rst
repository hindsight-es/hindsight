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

Hindsight provides:

- **Type-safe event definitions** using DataKinds
- **Compile-time event versioning** guarantees
- **Multiple storage backends** (Memory, Filesystem, PostgreSQL)
- **Event subscriptions** for real-time stream processing
- **Projection system** built on subscriptions for read models
- **Strong consistency** guarantees across all operations

Key Features
------------

Event System
~~~~~~~~~~~~
- Type-safe event definitions with automatic versioning
- Compile-time guarantees for event compatibility
- Support for event migrations and schema evolution

Storage Backends
~~~~~~~~~~~~~~~~
- **Memory**: In-memory store for testing and development
- **Filesystem**: File-based persistence for single-node deployments
- **PostgreSQL**: Production backend with ACID guarantees and scalability

Event Subscriptions
~~~~~~~~~~~~~~~~~~~
- Subscribe to event streams with pattern matching and filtering
- Real-time event notifications as they're appended
- Backend-agnostic subscription API works across all storage backends
- Foundation for building projections, process managers, and integrations

Projection System
~~~~~~~~~~~~~~~~~
- Built on top of event subscriptions
- Transform event streams into read models using PostgreSQL transactions
- Works with any event store backend (Memory, Filesystem, or PostgreSQL)
- Automatic state tracking and cursor management

Documentation Contents
----------------------

.. toctree::
   :maxdepth: 2
   :caption: Introduction

   introduction

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

Architecture
------------

Hindsight follows a modular architecture with clear separation between:

1. **Core Event System** - Type-safe event definitions and versioning
2. **Storage Layer** - Pluggable backends for different use cases
3. **Subscription System** - Real-time event stream processing
4. **Projection System** - Built on subscriptions for read model generation

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