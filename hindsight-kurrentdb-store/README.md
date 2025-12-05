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

## Protocol Buffers

This package uses `proto-lens-setup` for automatic protobuf code generation.
The `Proto.*` modules are generated from `.proto` files in the `proto/` directory.

Generation happens automatically during `cabal build`. To force regeneration
(e.g., after modifying `.proto` files):

```bash
cabal clean && cabal build hindsight-kurrentdb-store
```

The proto files are sourced from [KurrentDB's protos repository](https://github.com/kurrent-io/kurrentdb-clients/tree/master/protos).
