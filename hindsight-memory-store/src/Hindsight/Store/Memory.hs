{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}

{-|
Module      : Hindsight.Store.Memory
Description : In-memory event store for testing and development
Copyright   : (c) 2024
License     : BSD3
Maintainer  : maintainer@example.com
Stability   : experimental

In-memory implementation using STM. Data is lost on process termination.
-}
module Hindsight.Store.Memory
  ( -- * Core Types
    MemoryStore,
    MemoryStoreHandle,
    MemoryCursor (..),

    -- * Store Operations
    newMemoryStore,

    -- * Re-exports
    module Hindsight.Store,
  )
where

import Control.Concurrent.STM
import Control.Monad (forM, forM_)
import Control.Monad.IO.Class (liftIO)
import UnliftIO (MonadUnliftIO)
import Data.Aeson (FromJSON (..), ToJSON (..))
import Data.Map.Strict qualified as Map
import Data.Time (getCurrentTime)
import Data.UUID.V4 qualified as UUID
import GHC.Generics (Generic)
import Hindsight.Store
import Hindsight.Store.Memory.Internal

-- | Cursor implementation for the memory store
newtype MemoryCursor = MemoryCursor
  { getSequenceNo :: Integer
  }
  deriving stock (Show, Eq, Ord, Generic)
  deriving anyclass (FromJSON, ToJSON)

-- | Type family instances
type instance Cursor MemoryStore = MemoryCursor

type instance BackendHandle MemoryStore = MemoryStoreHandle

-- | Handle for the memory store
newtype MemoryStoreHandle = MemoryStoreHandle
  { stateVar :: TVar (StoreState MemoryStore)
  }

-- | Creates a new memory store instance
newMemoryStore :: IO MemoryStoreHandle
newMemoryStore = do
  globalVar <- newTVarIO (-1)
  MemoryStoreHandle <$> newTVarIO (initialState globalVar)
  where
    initialState globalVar =
      StoreState
        { nextSequence = 0,
          events = Map.empty,
          streamEvents = Map.empty,
          streamVersions = Map.empty,
          streamLocalVersions = Map.empty,
          streamNotifications = Map.empty,
          globalNotification = globalVar
        }

data MemoryStore

-- | Memory store implementation
instance EventStore MemoryStore where
  type StoreConstraints MemoryStore m = (MonadUnliftIO m)

  insertEvents handle corrId transaction = liftIO $ do
    -- First perform the basic insertion
    now <- getCurrentTime
    eventIds <- forM [1 .. totalEvents] $ \_ -> EventId <$> UUID.nextRandom

    atomically $ do
      state <- readTVar handle.stateVar

      -- Check version constraints
      case checkAllVersions state batches of
        Left mismatch -> pure $ FailedInsertion mismatch
        Right () -> do
          -- Perform insertion
          let (newState, finalCursor, streamCursors) = insertAllEvents state corrId now eventIds batches
          writeTVar handle.stateVar newState

          -- Notify listeners
          forM_ (Map.keys batches) $ \streamId -> do
            forM_ (Map.lookup streamId state.streamNotifications) $ \var ->
              writeTVar var (getSequenceNo finalCursor)
          writeTVar state.globalNotification (getSequenceNo finalCursor)

          pure $ SuccessfulInsertion $ InsertionSuccess
            { finalCursor = finalCursor
            , streamCursors = streamCursors
            }
    where
      batches = transaction.transactionWrites
      totalEvents = sum $ map (length . (.events)) $ Map.elems batches

  subscribe handle matcher selector = subscribeToEvents handle.stateVar matcher selector

instance StoreCursor MemoryStore where
  makeCursor = MemoryCursor
  makeSequenceNo = (.getSequenceNo)
