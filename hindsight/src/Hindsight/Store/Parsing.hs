{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}

{-|
Module      : Hindsight.Store.Parsing
Description : Event parsing utilities for event stores
Copyright   : (c) 2024
License     : BSD3
Maintainer  : maintainer@example.com
Stability   : experimental

This module provides core event parsing utilities used by all event store backends
to convert stored events into properly typed event envelopes. These utilities handle
version-aware parsing and envelope creation.
-}
module Hindsight.Store.Parsing
  ( -- * Event Processing Utilities
    parseEventPayload,
    parseStoredEventToEnvelope,
    createEventEnvelope,
    
        
    -- * Common Types
    ProjectionResult (..),
    ProjectionError (..),
  )
where

import Control.Exception (SomeException)
import Data.Aeson qualified as Aeson
import Data.Aeson.Types (parseEither)
import Data.Map qualified as Map
import Data.Proxy (Proxy (..))
import Data.Text (Text)
import Data.Time (UTCTime)
import Hindsight.Core (IsEvent, parseMapFromProxy, CurrentPayloadType)
import Hindsight.Store (EventEnvelope (..), EventId, StreamId, CorrelationId, Cursor, StreamVersion)

-- | Result of projection execution
data ProjectionResult
  = ProjectionSuccess
  | ProjectionSkipped  -- Handler didn't match the event
  | ProjectionError ProjectionError
  deriving (Show, Eq)

-- | Types of projection errors
data ProjectionError
  = ParseError Text
  | HandlerError SomeException
  | BackendError Text
  deriving (Show)

-- | Manual Eq instance for ProjectionError
-- 
-- SomeException doesn't have an Eq instance, so we compare based on the string representation
instance Eq ProjectionError where
  (ParseError t1) == (ParseError t2) = t1 == t2
  (HandlerError e1) == (HandlerError e2) = show e1 == show e2
  (BackendError t1) == (BackendError t2) = t1 == t2
  _ == _ = False


-- | Parse event payload from JSON using the event's parse map with proper version handling
--
-- This function implements correct version-aware parsing:
-- 1. Uses the stored event version to select the appropriate parser
-- 2. The parser automatically upgrades to the latest version via UpgradableToLatest
-- 3. Returns the current version payload type
parseEventPayload ::
  forall event.
  (IsEvent event) =>
  Proxy event ->
  Aeson.Value ->
  Integer ->              -- Event payload version (not StreamVersion!)
  Maybe (CurrentPayloadType event)
parseEventPayload proxy payloadJson eventPayloadVersion = do
  let parserMap = parseMapFromProxy proxy
  -- Use the actual stored event payload version to select the correct parser
  -- The parser will automatically upgrade to the latest version
  case Map.lookup (fromIntegral eventPayloadVersion) parserMap of
    Just parser -> case parseEither parser payloadJson of
      Right payload -> Just payload
      Left _ -> Nothing
    Nothing -> Nothing

-- | Create event envelope from parsed payload and metadata
--
-- This unified function creates consistent event envelopes across
-- both projection systems.
createEventEnvelope ::
  forall event backend.
  EventId ->
  StreamId ->
  Cursor backend ->
  StreamVersion ->
  Maybe CorrelationId ->
  UTCTime ->
  CurrentPayloadType event ->
  EventEnvelope event backend
createEventEnvelope eventId streamId cursor streamVer corrId timestamp payload =
  EventWithMetadata
    { eventId = eventId,
      streamId = streamId,
      position = cursor,
      streamVersion = streamVer,
      correlationId = corrId,
      createdAt = timestamp,
      payload = payload
    }

-- | Parse stored event data into an event envelope
--
-- This function handles the database → envelope conversion with proper version handling:
-- 1. Takes raw event data from storage (JSON + version + metadata)
-- 2. Uses the stored version to parse at the correct version
-- 3. Automatically upgrades to the latest version
-- 4. Creates a properly typed event envelope
parseStoredEventToEnvelope ::
  forall event backend.
  (IsEvent event) =>
  Proxy event ->
  EventId ->
  StreamId ->
  Cursor backend ->
  StreamVersion ->
  Maybe CorrelationId ->
  UTCTime ->
  Aeson.Value ->      -- Raw JSON payload from storage
  Integer ->          -- Event payload version (from eventVersion field)
  Maybe (EventEnvelope event backend)
parseStoredEventToEnvelope proxy eventId streamId cursor streamVer corrId timestamp payloadJson eventPayloadVersion = do
  -- Parse payload using the stored event payload version (with automatic upgrade)
  payload <- parseEventPayload proxy payloadJson eventPayloadVersion
  pure $ createEventEnvelope eventId streamId cursor streamVer corrId timestamp payload
