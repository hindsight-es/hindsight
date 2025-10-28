---
title: "Announcing Hindsight: Typesafe, Evolvable Event Sourcing for Haskell"
date: 2025-10-28
author: Gaël Deest
---

A month and a half ago, at [Munihac 2025](https://munihac.de/2025.html), I had the pleasure to present the design of _Hindsight_, an opinionated event sourcing library I was working on. While I had hoped to make the repository public and gather contributions during the Hackathon, I still felt the project was a bit too early for prime time: the user-facing API needed a lot of polish, the project was needlessly monolithic and we had essentially no documentation. Moreover, while working on the slides, I noticed a few improvement opportunities I could not help but explore.

Today, I have the pleasure to invite everyone interested to try it out. The code is available [on GitHub](https://github.com/hindsight-es/hindsight) and the website features an extensive [documentation](/docs/) section. I particularly encourage you to read the [tutorials](/docs/tutorials/index.html) if you want to see what the library looks like. If you are using Nix, running the tutorials should be as easy as checking out the repository and typing:

```
nix develop            # Enter the Nix development shell
cabal run tutorial-01  # Run the first tutorial (and so forth)
```

## Hindsight in a Nutshell

Hindsight is composed of:

- `hindsight-core`: the foundation library that defines:
   - A declarative event versioning DSL
   - An event store interface
- `hindsight-*-store`: various event store implementations conforming to the store interface defined in `hindsight-core`.
   - `hindsight-memory-store`: mostly intended for testing.
   - `hindsight-filesystem-store`: persistent store for single-node deployments.
   - `hindsight-postgresql-store`: robust, multi-node / multi-instance store implementation.
- `hindsight-postgresql-projections`: a store-agnostic SQL projection engine.

### Event Definition DSL and Event Versioning

Hindsight identifies events by a typelevel string. Users specify:

- The maximum version of an event.
- Its successive payloads.
- How to upgrade an event to the next version.

Here is how it looks for an event that only supports one version:

```haskell
-- The event type name
type UserRegistered = "user_registered"

-- The payload
data UserInfo = UserInfo
  { userId :: Text
  , userName :: Text
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)

-- Event Declaration
instance Event UserRegistered
type instance MaxVersion UserRegistered = 0
type instance Versions UserRegistered = '[UserInfo]
instance MigrateVersion 0 UserRegistered
```

To add a new version of the same event, you need to define the new payload, bump the `MaxVersion` counter, append the new payload to the `Versions` list and implement an `Upcast` instance:

```haskell
type instance MaxVersion UserRegistered = 1
type instance Versions UserRegistered = '[UserInfo, UserInfoImproved]
instance Upcast 0 UserRegistered where
    upcast v0Event = ... -- Convert to v1
instance MigrateVersion 1 UserRegistered
```

And Hindsight automatically migrates old events at runtime to the latest version for you. See [tutorial 04](/docs/tutorials/04-event-versioning.html) for a concrete example.

Moreover, to prevent you from accidentally modifying the definition of legacy payloads, `hindsight-core` provides a testing library, [`hindsight-core:event-testing`](https://hindsight.events/docs/haddock/hindsight-core/event-testing/index.html), that helps you generate golden and roundtrip tests fully automatically, given `Arbitrary` instances for all your payloads. 

### Event Stores

The event store abstraction supported by Hindsight supports state-of-the-art features such as:

- Transactional multi-stream appends
- Version expectation assertions for optimistic concurrency control
- Multi/single-stream subscriptions (with an optional starting position)

Hindsight subscriptions provide exactly-once delivery semantics and total, reproducible event ordering. The three event stores share most of their test-suite, also provided by a core [testing library](https://hindsight.events/docs/haddock/hindsight-core/store-testing/index.html).

The memory store (STM-based) is very fast but non-persistent and essentially intended for testing. The PostgreSQL implementation is undoubtedly the most mature backend we provide and the most scalable one: it supports multiple application instances appending and subscribing events to the same database, while maintaining the same consistency and ordering guarantees. The filesystem store is admittedly less mature.

New implementations are definitely possible. A lightweight [SQLite](https://sqlite.org/) backend or a distributed [KurrentDB](https://www.kurrent.io/) (formerly known as EventStoreDB) would, for example, be very welcome.

### SQL Projections

Finally, Hindsight supports persisting your projections in a PostgreSQL database. Additionally, the PostgreSQL backend supports _synchronous projections_ (also known as _inline projections_ in MartenDB's parlance), which makes SQL projections part of the event insertion logic. Synchronous projections provide at least two advantages:

- They make your read models immediately consistent. Eschewing eventual consistency allows you to avoid many pains of distributed architectures. I believe this to be particularly valuable for your core business models, especially when you are just starting out and do not yet encounter scalability issues (synchronous projections can easily be made asynchronous later on if the need arises).
- They allow you to implement custom validation of your events via SQL checks and triggers. In my opinion, this provides a solid alternative to other multi-stream consistency approaches such as the [Dynamic Consistency Boundaries](https://dcb.events/) proposal supported by the [Axon Event Store](https://www.axoniq.io/blog/rethinking-microservices-architecture-through-dynamic-consistency-boundaries).

## Conclusion

This is only skimming the surface of what Hindsight provides, but hopefully, it already gives you a solid idea of what we have in store (pun intended) for you. There still are many areas where Hindsight can be improved (e.g. observability), but I believe the foundation is there for a solid Haskell-based event sourcing solution.

I strongly invite everyone to check it out, read through the tutorials, write some code and try to break it. **Any contribution or feedback** is considered valuable, big or small, including, but not limited to:

- Bug reports
- Documentation fixes
- Questions
- Usability issues
- Feedback (negative or positive)

No matter your reason, please reach out through the [issue tracker](https://github.com/hindsight-es/hindsight/issues) or directly [by email](mailto:gael@hindsight.events).

Finally, please keep in mind that Hindsight is currently the work of a single individual. If you're interested in supporting this project and seeing it grow, there are several ways to help:

- Try it and share your experience - even "I tried to build X and got stuck at Y" is valuable feedback
- Contribute code - whether it's a new store backend, improved documentation, or bug fixes
- Spread the word - if Hindsight solves a problem for you, let others know
- Sponsor development - if your company would benefit from Hindsight, consider supporting its continued development

Thanks for reading, and happy hacking!