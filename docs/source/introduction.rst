Introduction to Hindsight
=========================

Hindsight is a type-safe event sourcing library for Haskell. It uses the
type system to manage event schema evolution, providing compile-time
guarantees for event versioning and compatibility.

This introduction explains what Hindsight does and why you might use it.
For hands-on code examples, see the
:doc:``tutorials/01-getting-started``.

What is Event Sourcing?
-----------------------

Traditional applications store current state in a database. Event
sourcing instead stores a log of all changes that happened—an
append-only sequence of events. Current state is derived by replaying
these events.

Example:

::

   Events:        [MoneyDeposited 100, MoneyWithdrawn 30, MoneyDeposited 50]
   Current State: 120 (computed by folding over events)

This approach provides several benefits:

- Complete audit trail of all state changes
- Ability to reconstruct state at any point in time
- Flexibility to create new views of data without losing history
- Natural fit with event-driven architectures

The Schema Evolution Challenge
------------------------------

Event sourcing has a significant technical challenge: **your events are
immutable, but your application evolves**.

When you need to change an event’s structure, old events in the store
remain in the original format. Your code must handle multiple versions
of each event type indefinitely.

Example scenario:

.. code:: haskell

   -- Original event
   data MoneyDepositedV0 = MoneyDepositedV0 { amount :: Int }

   -- Later, you need to track the deposit method
   data MoneyDepositedV1
     = CashDeposit { amount :: Int }
     | WireTransfer { amount :: Int }

Now your system must: - Read and deserialize both V0 and V1 events -
Convert V0 events to V1 format when processing - Ensure handlers work
with all versions - Never break compatibility with stored events

Many event sourcing systems leave this to manual implementation. You
write deserialization code, maintain version registries, and handle
upgrades explicitly.

Hindsight’s Approach
--------------------

Hindsight brings event versioning into the type system. Using DataKinds,
type families, and GADTs, it tracks event versions at compile time.

The result:

- **Compile-time version tracking**: GHC knows about all versions of
  every event
- **Automatic upcasting**: Old events are transparently upgraded to the
  latest version
- **Type-safe handlers**: Event handlers always receive the latest
  version
- **Exhaustiveness checking**: Missing upgrade paths are compile errors
- **Golden testing**: Automatic serialization tests prevent breaking
  changes

Core Features
-------------

**Multiple Storage Backends**

- **Memory**: In-memory store for testing and development
- **Filesystem**: File-based persistence for single-node deployments
- **PostgreSQL**: Production backend with ACID guarantees

All backends implement the same ``EventStore`` interface.

**Event Subscriptions**

Subscribe to event streams with type-safe pattern matching.
Subscriptions work with any storage backend.

**Projection System**

Transform event streams into read models (SQL projections). Projections
run in PostgreSQL transactions regardless of which backend stores
events.

Hindsight supports both asynchronous projections (eventual consistency)
and synchronous projections (strong consistency, PostgreSQL only).

**Concurrency Control**

Optimistic locking using stream version expectations. Insert operations
can specify expected stream versions, failing if concurrent
modifications occurred.

**Multi-Stream Transactions**

Atomic transactions across multiple event streams, useful for enforcing
cross-aggregate invariants.

Example: Basic Event Definition
-------------------------------

Here’s what defining an event looks like in Hindsight:

.. code:: haskell

   -- Type-level event name
   type UserRegistered = "user_registered"

   -- Event payload
   data UserInfo = UserInfo
     { userId :: Text
     , userName :: Text
     } deriving (Generic, Eq, Show, FromJSON, ToJSON)

   -- Declare version and register with Hindsight
   type instance MaxVersion UserRegistered = 0
   type instance Versions UserRegistered = FirstVersion UserInfo
   instance Event UserRegistered
   instance UpgradableToLatest UserRegistered 0 where
     upgradeToLatest = id

When you need to add a new version, you extend the version list and
provide an upgrade function. The type system ensures you don’t forget
any upgrade paths.

Project Status
--------------

Hindsight is an experimental library exploring type-safe approaches to
event sourcing. The core versioning system is working and tested, but
the API is still evolving.

Current state:

- **Core features**: Event versioning, multiple backends, projections,
  subscriptions all functional
- **Testing**: Property-based tests, integration tests, golden tests for
  serialization
- **Maturity**: Early stage. APIs may change. Not yet used in production
  systems.
- **Documentation**: Tutorials, API docs, and examples available

This is a good time to explore the library and provide feedback, but
expect some rough edges.

When to Use Hindsight
---------------------

Consider Hindsight if you:

- Want compile-time guarantees for event schema evolution
- Value type safety in your event sourcing system
- Need multiple storage backends (testing with memory, deploying with
  PostgreSQL)
- Are building systems in Haskell and want tight integration with the
  type system

Hindsight may not be the right choice if you:

- Need a battle-tested production system (consider more mature options)
- Don’t want to work with Haskell’s advanced type system features
- Need very high throughput (performance characteristics not yet fully
  characterized)

Getting Started
---------------

To learn Hindsight, start with the hands-on tutorials:

1. :doc:``tutorials/01-getting-started`` - Basic event definitions and
   storage
2. :doc:``tutorials/02-in-memory-projections`` - Building read models
3. :doc:``tutorials/03-postgresql-projections`` - Durable projections
4. :doc:``tutorials/04-event-versioning`` - Schema evolution
5. :doc:``tutorials/05-consistency-patterns`` - Optimistic locking
6. :doc:``tutorials/06-backend-agnostic`` - Writing portable code
7. :doc:``tutorials/07-advanced-postgresql`` - SQL projection patterns
8. :doc:``tutorials/08-multi-stream-consistency`` - Cross-aggregate
   invariants

For API details, see the :doc:``api/index``.

Contributing
------------

Hindsight is open source and welcomes contributions. See
:doc:``development/contributing`` for guidelines.

Areas where contributions would be particularly valuable:

- **Real-world usage feedback**:

  - **Bug reports**: Hindsight is heavily tested, but still fairly new.
    Bugs are to be expected.
  - If Hindsight does or (most importantly) does **not** seem a good fit
    for your application, let us know. We want Hindsight to be usef

- **Improved ergonomics** and **error messages**: we want first in class
  developer friendliness. We deeply believe that powerful types should
  help developers writing correct code without becoming a hindrance.

- **Observability**: OpenTelemetry, monitoring tools / CLIs, etc.

- Additional tests.

- Additional storage backends (KurrentDB ?)

- Performance testing and optimization (there is some benchmark
  infrastructure already, but it needs some overhaul).

- Documentation improvements

Further Reading
---------------

- **Tutorials**: :doc:``tutorials/index``
- **API Reference**: :doc:``api/index``
- **Development Guide**: :doc:``development/building``
- **Testing Guide**: :doc:``development/testing``
