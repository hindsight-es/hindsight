{-# LANGUAGE TypeFamilies #-}

{- |
Module      : Hindsight.Store.KurrentDB
Description : KurrentDB event store backend for Hindsight
Copyright   : (c) 2025
License     : BSD3
Maintainer  : gael@hindsight.events
Stability   : experimental

= Overview

KurrentDB-backed event store providing:

* Multi-stream atomic appends (KurrentDB 25.1+)
* Optimistic concurrency control
* Real-time event subscriptions via gRPC
* ACID guarantees through KurrentDB

= Quick Start

@
import Hindsight.Store.KurrentDB

main :: IO ()
main = do
  -- Connect to KurrentDB
  store <- newKurrentStore "esdb://localhost:2113?tls=false"

  -- Insert events
  streamId <- StreamId \<$\> UUID.nextRandom
  result <- insertEvents store Nothing $
    singleEvent streamId NoStream myEvent

  case result of
    SuccessfulInsertion success ->
      print success.finalCursor
    FailedInsertion err ->
      print err

  -- Cleanup
  shutdownKurrentStore store
@

= Implementation Status

🚧 Phase 0: Basic package structure created
  - Types defined
  - Package compiles
  - TODO: gRPC integration
  - TODO: EventStore instance
  - TODO: Subscription support
-}
module Hindsight.Store.KurrentDB (
    -- * Store Creation
    newKurrentStore,
    shutdownKurrentStore,

    -- * Types
    KurrentStore,
    KurrentCursor (..),
    KurrentHandle (..),

    -- * Re-exports from Hindsight.Store
    module Hindsight.Store,
) where

import Hindsight.Store
import Hindsight.Store.KurrentDB.Client
import Hindsight.Store.KurrentDB.Types

-- TODO: EventStore instance implementation
-- instance EventStore KurrentStore where
--   type StoreConstraints KurrentStore m = MonadUnliftIO m
--   insertEvents = insertEventsImpl
--   subscribe = subscribeImpl
