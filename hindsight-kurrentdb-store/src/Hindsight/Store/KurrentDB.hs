{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE OverloadedStrings #-}
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
    KurrentConfig (..),

    -- * Re-exports from Hindsight.Store
    module Hindsight.Store,
) where

import Control.Monad.IO.Class (MonadIO (..))
import Data.Default (def)
import Data.Foldable (toList)
import Data.Map.Strict qualified as Map
import Data.Pool (withResource)
import Data.ProtoLens (defMessage)
import Data.Proxy (Proxy (..))
import Data.Text qualified as T
import Data.Text.Encoding qualified as Text
import Data.UUID qualified as UUID
import Hindsight.Events (SomeLatestEvent)
import Hindsight.Store
import Hindsight.Store.KurrentDB.Client
import Hindsight.Store.KurrentDB.RPC
import Hindsight.Store.KurrentDB.Types
import Lens.Micro ((&), (.~))
import Network.GRPC.Client qualified as GRPC
import Network.GRPC.Common.Protobuf (Protobuf)
import Proto.Streams (Streams)

-- | EventStore instance for KurrentDB
instance EventStore KurrentStore where
    type StoreConstraints KurrentStore m = MonadIO m

    insertEvents handle _correlationId (Transaction streams) = liftIO $ do
        -- Phase 1: Only single-stream appends supported
        case Map.toList streams of
            [] ->
                -- No streams, return success with empty cursors
                pure $
                    SuccessfulInsertion $
                        InsertionSuccess
                            { finalCursor = KurrentCursor{commitPosition = 0, preparePosition = 0}
                            , streamCursors = Map.empty
                            }
            [(streamId, streamWrite)] -> insertSingleStream handle streamId streamWrite
            multipleStreams ->
                pure $
                    FailedInsertion $
                        OtherError $
                            ErrorInfo
                                { errorMessage =
                                    "Multi-stream atomic appends not yet implemented (Phase 2). "
                                        <> "Attempted to append to "
                                        <> T.pack (show (length multipleStreams))
                                        <> " streams."
                                , exception = Nothing
                                }

    subscribe = error "subscribe: Not yet implemented"

-- | Insert events into a single stream using Streams.Append RPC
insertSingleStream ::
    (Traversable t) =>
    KurrentHandle ->
    StreamId ->
    StreamWrite t SomeLatestEvent KurrentStore ->
    IO (InsertionResult KurrentStore)
insertSingleStream handle (StreamId streamUUID) streamWrite = do
    -- Get connection from pool
    withResource handle.connectionPool $ \conn -> do
        -- Open RPC
        GRPC.withRPC conn def (Proxy @(Protobuf Streams "append")) $ \call -> do
            -- Send stream options (identifier + expected revision)
            let streamName = Text.encodeUtf8 $ UUID.toText streamUUID
                options =
                    defMessage
                        & #streamIdentifier .~ (defMessage & #streamName .~ streamName)
                        -- TODO: Handle expected revision from streamWrite.expectedRevision

                optionsReq = defMessage & #options .~ options
            GRPC.sendNextInput call optionsReq

            -- Send events
            -- TODO: Send actual events from streamWrite.events
            -- For now, just send a placeholder
            error "insertSingleStream: Event sending not yet implemented"
