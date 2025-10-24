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

All with strong event ordering guarantees, multi-stream consistency features and a polished API.

Hindsight is currently in **public beta**, and bugs are to be expected. Bug reports, critics

Quick Start
-----------

**Learning**: Check out the :doc:`tutorials/index` for a step-by-step introduction.
Visit the `Hindsight example <https://github.com/hindsight-es/hindsight-example.git>`_ repository for a quick demonstration.

**Using Hindsight in my project**: See :doc:`installation`.

**Contributing**: For development setup, see :doc:`development`.

Documentation Contents
----------------------

.. toctree::
   :maxdepth: 2
   :caption: Getting Started

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

   development


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`