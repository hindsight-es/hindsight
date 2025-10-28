---
title: About
---

# About Hindsight

Hindsight is an open-source event sourcing library for Haskell, designed to bring type safety and correctness to event-driven architectures.

## Status

Hindsight is currently in active development. The core API is stabilizing, and we're working toward a first Hackage release.

## Contributing

We welcome contributions! Whether it's:

- Reporting bugs or requesting features
- Improving documentation
- Submitting pull requests
- Sharing your use cases

Check out the [contributing section](/docs/development.html#contributing) of the documentation to get started, the [issue tracker](https://github.com/hindsight-es/hindsight/issues), or just send [an email](mailto:gael@hindsight.events).

## Community

Development is ongoing. Documentation and community channels coming soon.

## License

Hindsight is released under the BSD3-Clause License. See the repository for full license text.

## Acknowledgments

Hindsight builds on the excellent work of the Haskell community, including the excellent [Ghc compiler](https://www.haskell.org/ghc/) and libraries such as:

- `hasql` and `hasql-transaction` for PostgreSQL integration and transactional guarantees
- `tmp-postgres` for isolated PostgreSQL testing infrastructure
- `hedgehog` and `QuickCheck` for property-based testing
- `tasty` for test orchestration
- `aeson` for JSON serialization
- `stm`, `async`, and `unliftio` for concurrency and exception handling
- `fsnotify` and `filelock` for filesystem watching and multi-process coordination

... and many others.

Thank you to all contributors and the broader Haskell ecosystem.
