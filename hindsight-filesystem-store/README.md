# hindsight-filesystem-store

File-based persistent event store for single-node deployments.

## Overview

Provides durable event storage using an append-only log file. Events survive process restarts without requiring a database. Uses file locking for multi-process coordination and fsnotify for low-latency change detection.

## Storage Format

Events are written to a single append-only file:

```
/var/lib/myapp/events/
├── events.log       # Append-only event log (one transaction per line)
└── store.lock       # Process coordination lock
```

Each line in `events.log` contains a transaction's events as JSON. The log is replayed on startup to rebuild in-memory indices.

## Quick Start

```haskell
import Hindsight
import Hindsight.Store.Filesystem (newFilesystemStore, mkDefaultConfig)

main :: IO ()
main = do
  config <- pure $ mkDefaultConfig "/var/lib/myapp/events"
  store <- newFilesystemStore config

  streamId <- StreamId <$> UUID.nextRandom
  let event = mkEvent UserRegistered (UserInfo "U001" "Alice")

  result <- insertEvents store Nothing $
    multiEvent streamId Any [event]

  void $ subscribe store
    (match UserRegistered handleEvent :? MatchEnd)
    (EventSelector AllStreams FromBeginning)
```

## License

BSD-3-Clause. See [LICENSE](../LICENSE) for details.
