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

{- |
Module      : Hindsight.Store.Memory
Description : In-memory event store for testing and development
Copyright   : (c) 2024
License     : BSD3
Maintainer  : maintainer@example.com
Stability   : experimental

= Overview

In-memory event store using STM (Software Transactional Memory) for fast, concurrent access.
Ideal for testing, development, and scenarios where events don't need to survive process restarts.

⚠️  __Data is lost on process termination__ - not suitable for production use.

= Quick Start

@
import Hindsight.Store.Memory (newMemoryStore)
import Hindsight

main :: IO ()
main = do
  -- Create store
  store <- newMemoryStore

  -- Insert events (see Hindsight.Store for details)
  streamId <- StreamId \<$\> UUID.nextRandom
  let event = mkEvent MyEvent myData
  result <- insertEvents store Nothing $ singleEvent streamId NoStream event

  -- Subscribe to events
  handle <- subscribe store matcher (EventSelector AllStreams FromBeginning)
  -- ... process events ...
@

= Use Cases

__When to use Memory store:__

* Unit and integration tests (fast, isolated)
* Development and prototyping
* Temporary event processing pipelines
* Scenarios where persistence isn't required

__When NOT to use Memory store:__

* Production systems requiring durability
* Multi-process applications (each process has separate state)
* Long-running services that can't afford data loss

= Trade-offs

__Advantages:__

* Fastest performance (no I/O)
* No external dependencies
* Simple setup (single function call)
* Thread-safe via STM

__Limitations:__

* Data lost on process termination or crash
* Memory usage grows with event count
* Single-process only (no sharing between instances)
* No built-in persistence or snapshots

= Implementation

Events and stream metadata stored in-memory using STM 'TVar's.
Subscriptions use 'STM' retry mechanism for efficient event notification.
-}
module Hindsight.Store.Memory (
    -- * Core Types
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
import Data.Aeson (FromJSON (..), ToJSON (..))
import Data.Map.Strict qualified as Map
import Data.Time (getCurrentTime)
import Data.UUID.V4 qualified as UUID
import GHC.Generics (Generic)
import Hindsight.Store
import Hindsight.Store.Memory.Internal
import UnliftIO (MonadUnliftIO)

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
            { nextSequence = 0
            , events = Map.empty
            , streamEvents = Map.empty
            , streamVersions = Map.empty
            , streamLocalVersions = Map.empty
            , streamNotifications = Map.empty
            , globalNotification = globalVar
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

                    pure $
                        SuccessfulInsertion $
                            InsertionSuccess
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
