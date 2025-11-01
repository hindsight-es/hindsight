# hindsight-kurrentdb-store

KurrentDB backend for Hindsight event sourcing library.

## Overview

This package provides a KurrentDB-backed event store implementation for Hindsight, using gRPC for communication with KurrentDB 25.1+.

## Features

- ✅ Multi-stream atomic appends (KurrentDB 25.1+)
- ✅ Optimistic concurrency control
- ✅ Real-time event subscriptions via gRPC
- ✅ Native Haskell gRPC client (grapesy)

## Requirements

- KurrentDB 25.1 or later
- GHC 9.10.2
- Docker (for testing)

## Installation

Add to your `cabal.project`:

```cabal
packages:
  hindsight-kurrentdb-store
```

## Quick Start

```haskell
import Hindsight.Store.KurrentDB

main :: IO ()
main = do
  -- Connect to KurrentDB
  store <- newKurrentStore "esdb://localhost:2113?tls=false"

  -- Insert events
  streamId <- StreamId <$> UUID.nextRandom
  result <- insertEvents store Nothing $
    singleEvent streamId NoStream myEvent

  -- Cleanup
  shutdownKurrentStore store
```

## Testing

Start KurrentDB with Docker:

```bash
docker compose up -d
cabal test hindsight-kurrentdb-store
```

## Status

🚧 **In Development** - Phase 0: Environment Setup

See [grpc-design.md](../grpc-design.md) for implementation plan and progress.
