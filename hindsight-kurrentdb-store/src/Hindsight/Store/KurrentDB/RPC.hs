{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeFamilies #-}

{- |
Module      : Hindsight.Store.KurrentDB.RPC
Description : gRPC type definitions for KurrentDB
Copyright   : (c) 2025
License     : BSD3
Maintainer  : gael@hindsight.events
Stability   : experimental

RPC type instances and metadata for KurrentDB gRPC API.
-}
module Hindsight.Store.KurrentDB.RPC (
    -- * RPC Types
    KurrentMetadata (..),

    -- * Re-exports
    Protobuf,
) where

import Data.ByteString (ByteString)
import Data.Default (Default (..))
import Network.GRPC.Common (BuildMetadata (..), CustomMetadata (..), NoMetadata, RequestMetadata, ResponseInitialMetadata, ResponseTrailingMetadata)
import Network.GRPC.Common.Protobuf (Protobuf)
import Proto.Streams (Streams)
import Proto.V2.Streams (StreamsService)

-- | Metadata required by KurrentDB for event append operations.
-- KurrentDB requires event type and content-type to be specified
-- in the ProposedMessage.metadata map field (not as gRPC headers).
data KurrentMetadata = KurrentMetadata
    { eventType :: ByteString
    -- ^ Event type name
    , contentType :: ByteString
    -- ^ Content type (e.g., "application/json")
    }
    deriving (Show, Eq)

instance Default KurrentMetadata where
    def = KurrentMetadata
        { eventType = "Event"
        , contentType = "application/json"
        }

instance BuildMetadata KurrentMetadata where
    buildMetadata KurrentMetadata{..} =
        -- Note: These are NOT used as gRPC headers, but provided for
        -- compatibility. The actual metadata goes in ProposedMessage.metadata
        [ CustomMetadata "type" eventType
        , CustomMetadata "es-content-type" contentType
        ]

-- | Metadata type instances for Streams.Append RPC
-- KurrentDB uses NoMetadata for gRPC-level metadata
type instance RequestMetadata (Protobuf Streams "append") = NoMetadata
type instance ResponseInitialMetadata (Protobuf Streams "append") = NoMetadata
type instance ResponseTrailingMetadata (Protobuf Streams "append") = NoMetadata

-- | Metadata type instances for Streams.Read RPC
type instance RequestMetadata (Protobuf Streams "read") = NoMetadata
type instance ResponseInitialMetadata (Protobuf Streams "read") = NoMetadata
type instance ResponseTrailingMetadata (Protobuf Streams "read") = NoMetadata

-- | Metadata type instances for Streams.BatchAppend RPC
type instance RequestMetadata (Protobuf Streams "batchAppend") = NoMetadata
type instance ResponseInitialMetadata (Protobuf Streams "batchAppend") = NoMetadata
type instance ResponseTrailingMetadata (Protobuf Streams "batchAppend") = NoMetadata

-- | Metadata type instances for V2 StreamsService.AppendSession RPC
-- V2 protocol for multi-stream atomic appends with proper atomicity guarantees
type instance RequestMetadata (Protobuf StreamsService "appendSession") = NoMetadata
type instance ResponseInitialMetadata (Protobuf StreamsService "appendSession") = NoMetadata
type instance ResponseTrailingMetadata (Protobuf StreamsService "appendSession") = NoMetadata
