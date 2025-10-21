{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE TypeFamilies #-}

{- |
Module      : Hindsight.Store.PostgreSQL.Core.Types
Description : Shared types for PostgreSQL event store backend
Copyright   : (c) 2024
License     : BSD3
Maintainer  : maintainer@example.com
Stability   : internal

Shared types for the PostgreSQL backend. This module exists to break
circular dependencies between other PostgreSQL modules.
-}
module Hindsight.Store.PostgreSQL.Core.Types (
    -- * Backend phantom type
    SQLStore,

    -- * Store handle
    SQLStoreHandle (..),
    Notifier (..),

    -- * Cursors
    SQLCursor (..),
    ExtendedSQLCursor (..),

    -- * Projection types
    SyncProjectionRegistry (..),
    SomeProjectionHandlers (..),

    -- * Re-exports for convenience
    Pool,
    ByteString,
) where

import Control.Concurrent.Async (Async)
import Control.Concurrent.STM (TChan)
import Data.Aeson (FromJSON, ToJSON)
import Data.ByteString (ByteString)
import Data.Int (Int32, Int64)
import Data.Map (Map)
import GHC.Generics (Generic)
import Hasql.Pool (Pool)
import Hindsight.Projection (ProjectionId (..))
import Hindsight.Projection.Matching (ProjectionHandlers (..))
import Hindsight.Store (BackendHandle, Cursor, StreamVersion)

-- | Phantom type representing the PostgreSQL storage backend.
data SQLStore

{- | A handle to the notification broadcaster.
It holds the channel to send ticks on and the thread that listens to Postgres.
-}
data Notifier = Notifier
    { notifierChannel :: TChan ()
    , notifierThread :: Async ()
    }

-- | Existential wrapper for projection handlers
data SomeProjectionHandlers backend = forall ts. SomeProjectionHandlers (ProjectionHandlers ts backend)

-- | Registry of synchronous projections
newtype SyncProjectionRegistry = SyncProjectionRegistry
    { projections :: Map ProjectionId (SomeProjectionHandlers SQLStore)
    }

type instance BackendHandle SQLStore = SQLStoreHandle

type instance Cursor SQLStore = SQLCursor

-- | Handle for interacting with PostgreSQL event store.
data SQLStoreHandle = SQLStoreHandle
    { pool :: !Pool
    -- ^ Database connection pool
    , connectionString :: !ByteString
    -- ^ Connection string (needed for LISTEN/NOTIFY)
    , syncProjectionRegistry :: !SyncProjectionRegistry
    -- ^ Sync projections to execute with insertions
    , notifier :: !Notifier
    -- ^ Centralized notifier for subscriptions
    }

{- | Position cursor for PostgreSQL event store.

Uses a compound key of (transactionNo, sequenceNo) to provide
total ordering across all events. The Ord instance uses
lexicographical ordering, so events are ordered first by
transaction number, then by sequence within transaction.
-}
data SQLCursor = SQLCursor
    { transactionNo :: !Int64
    -- ^ Transaction number (globally increasing)
    , sequenceNo :: !Int32
    -- ^ Sequence within transaction (1, 2, 3...)
    }
    deriving stock (Show, Eq, Ord, Generic)
    deriving anyclass (FromJSON, ToJSON)

{- | Cursor that tracks both global position and stream-local version.

Used internally for projections that need to track their position
in both the global event log and individual streams.
-}
data ExtendedSQLCursor = ExtendedSQLCursor
    { globalCursor :: !SQLCursor
    -- ^ Position in global event log
    , streamVersion :: !StreamVersion
    -- ^ Version within the specific stream
    }
    deriving stock (Show, Eq, Ord, Generic)
    deriving anyclass (FromJSON, ToJSON)
