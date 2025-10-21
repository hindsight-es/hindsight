# hindsight-memory-store

In-memory event store using STM for testing and development.

## Overview

Fast, non-durable event store backed by STM (Software Transactional Memory). All data is held in memory and lost when the process terminates. Provides the same API and semantics as durable stores, making it ideal for tests and rapid prototyping.

## Quick Start

```haskell
import Hindsight
import Hindsight.Store.Memory (newMemoryStore)

main :: IO ()
main = do
  store <- newMemoryStore

  streamId <- StreamId <$> UUID.nextRandom
  let event = mkEvent UserRegistered (UserInfo "U001" "Alice")

  result <- insertEvents store Nothing $
    multiEvent streamId Any [event]

  handle <- subscribe store
    (match UserRegistered handleEvent :? MatchEnd)
    (EventSelector AllStreams FromBeginning)
```

## Documentation

- [Getting Started Tutorial](https://hindsight.events/tutorials/01-getting-started.html)
- [API Reference](https://hindsight.events/haddock/hindsight-memory-store/)
- [Testing Guide](https://hindsight.events/development/testing.html)

## License

BSD-3-Clause. See [LICENSE](../LICENSE) for details.
