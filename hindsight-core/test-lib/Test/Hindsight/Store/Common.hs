{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE RecordWildCards #-}

{- |
Module      : Test.Hindsight.Store.Common
Description : Common utilities and types for event store tests
Copyright   : (c) 2025
License     : BSD3
Maintainer  : gael@hindsight.events
Stability   : experimental

Shared test utilities, helper functions, and types used across all event store
backend test suites.
-}
module Test.Hindsight.Store.Common where

import Control.Concurrent (MVar, putMVar)
import Data.IORef (IORef, atomicModifyIORef')
import Hindsight.Events (CurrentPayloadType)
import Hindsight.Store (EventEnvelope (EventWithMetadata), EventHandler, SubscriptionResult (Continue, Stop))

-- * Event Handler Helpers

-- | Collect events into an IORef (generic over event type)
collectEvents :: IORef [EventEnvelope event backend] -> EventHandler event IO backend
collectEvents ref event = do
    atomicModifyIORef' ref (\events -> (event : events, ()))
    pure Continue

-- | Handle tombstone event by signaling completion (generic over any event type)
handleTombstone :: MVar () -> EventHandler event IO backend
handleTombstone completionVar _ = do
    putMVar completionVar ()
    pure Stop

-- | Extract payload from event envelope (no cast needed - type guaranteed!)
extractPayload :: EventEnvelope event backend -> CurrentPayloadType event
extractPayload (EventWithMetadata _ _ _ _ _ _ payload) = payload
