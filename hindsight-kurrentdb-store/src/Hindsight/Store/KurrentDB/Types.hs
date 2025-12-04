{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE TypeFamilies #-}

{- |
Module      : Hindsight.Store.KurrentDB.Types
Description : Core types for KurrentDB backend
Copyright   : (c) 2025
License     : BSD3
Maintainer  : gael@hindsight.events
Stability   : experimental

KurrentDB-specific types including cursors, handles, and backend tag.
-}
module Hindsight.Store.KurrentDB.Types (
    KurrentStore,
    KurrentCursor (..),
    KurrentHandle (..),
    KurrentConfig (..),
) where

import Data.Aeson (FromJSON, ToJSON)
import Data.ByteString (ByteString)
import Data.Pool (Pool)
import Data.Word (Word64)
import GHC.Generics (Generic)
import Hindsight.Store (BackendHandle, Cursor)
import Network.GRPC.Client (Connection)

-- | Backend type tag for KurrentDB
data KurrentStore

-- | Type family instances for KurrentDB backend
type instance Cursor KurrentStore = KurrentCursor

type instance BackendHandle KurrentStore = KurrentHandle

{- | Cursor position in KurrentDB global event log.

KurrentDB uses a dual-position cursor with commit and prepare positions
for distributed transaction coordination. For per-stream operations,
we also track the stream revision to enable ExactVersion checks.
-}
data KurrentCursor = KurrentCursor
    { commitPosition :: Word64
    -- ^ Commit position in the global log
    , preparePosition :: Word64
    -- ^ Prepare position (for distributed tx coordination)
    , streamRevision :: Maybe Word64
    -- ^ Stream revision (when cursor is from a single-stream insert)
    }
    deriving stock (Eq, Ord, Show, Generic)
    deriving anyclass (FromJSON, ToJSON)

-- | Configuration for connecting to KurrentDB.
data KurrentConfig = KurrentConfig
    { host :: ByteString
    -- ^ KurrentDB hostname (e.g., "localhost")
    , port :: Int
    -- ^ KurrentDB port (default: 2113)
    , secure :: Bool
    -- ^ Use TLS (default: False for development)
    }
    deriving stock (Show, Eq)

{- | Handle for KurrentDB store connection.

Uses resource-pool to manage a pool of gRPC connections for:
- Fault tolerance: automatic connection recreation on failure
- Graceful shutdown: proper connection lifecycle management
- Resource limiting: prevents connection exhaustion
-}
data KurrentHandle = KurrentHandle
    { config :: KurrentConfig
    -- ^ Connection configuration
    , connectionPool :: Pool Connection
    -- ^ Connection pool for gRPC connections
    }
