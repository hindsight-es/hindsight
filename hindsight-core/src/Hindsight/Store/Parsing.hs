{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}

{- |
Module      : Hindsight.Store.Parsing
Description : Event parsing utilities for event stores
Copyright   : (c) 2024
License     : BSD3
Maintainer  : maintainer@example.com
Stability   : experimental

This module provides core event parsing utilities used by all event store backends
to convert stored events into properly typed event envelopes. These utilities handle
version-aware parsing and envelope creation.

These utilities are shared across Memory, Filesystem, and PostgreSQL backends
for consistent event parsing and envelope construction.
-}
module Hindsight.Store.Parsing (
    -- * Event Processing Utilities
    parseEventPayload,
    parseStoredEventToEnvelope,
    createEventEnvelope,
)
where

import Data.Aeson qualified as Aeson
import Data.Aeson.Types (parseEither)
import Data.Map qualified as Map
import Data.Proxy (Proxy (..))
import Data.Time (UTCTime)
import Hindsight.Events (CurrentPayloadType, Event, parseMapFromProxy)
import Hindsight.Store (CorrelationId, Cursor, EventEnvelope (..), EventId, StreamId, StreamVersion)

{- | Parse event payload from JSON using the event's parse map with proper version handling

This function implements correct version-aware parsing:
1. Uses the stored event version to select the appropriate parser
2. The parser automatically migrates to the latest version via MigrateVersion
3. Returns the current version payload type
-}
parseEventPayload ::
    forall event.
    (Event event) =>
    -- | Proxy for the event type
    Proxy event ->
    -- | JSON payload from storage
    Aeson.Value ->
    -- | Event payload version
    Integer ->
    -- | Parsed and upgraded payload, or Nothing if parsing fails
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

{- | Create event envelope from parsed payload and metadata

This unified function creates consistent event envelopes across
both projection systems.
-}
createEventEnvelope ::
    forall event backend.
    -- | Unique event identifier
    EventId ->
    -- | Stream this event belongs to
    StreamId ->
    -- | Global position in event store
    Cursor backend ->
    -- | Local version within the stream
    StreamVersion ->
    -- | Optional correlation identifier
    Maybe CorrelationId ->
    -- | Event creation timestamp
    UTCTime ->
    -- | Parsed event payload at latest version
    CurrentPayloadType event ->
    -- | Complete event envelope with metadata
    EventEnvelope event backend
createEventEnvelope eventId streamId cursor streamVer corrId timestamp payload =
    EventWithMetadata
        { eventId = eventId
        , streamId = streamId
        , position = cursor
        , streamVersion = streamVer
        , correlationId = corrId
        , createdAt = timestamp
        , payload = payload
        }

{- | Parse stored event data into an event envelope

This function handles the database → envelope conversion with proper version handling:
1. Takes raw event data from storage (JSON + version + metadata)
2. Uses the stored version to parse at the correct version
3. Automatically upgrades to the latest version
4. Creates a properly typed event envelope
-}
parseStoredEventToEnvelope ::
    forall event backend.
    (Event event) =>
    -- | Proxy for the event type
    Proxy event ->
    -- | Unique event identifier
    EventId ->
    -- | Stream this event belongs to
    StreamId ->
    -- | Global position in event store
    Cursor backend ->
    -- | Local version within the stream
    StreamVersion ->
    -- | Optional correlation identifier
    Maybe CorrelationId ->
    -- | Event creation timestamp
    UTCTime ->
    -- | Raw JSON payload from storage
    Aeson.Value ->
    -- | Event payload version (from eventVersion field)
    Integer ->
    -- | Parsed envelope, or Nothing if parsing fails
    Maybe (EventEnvelope event backend)
parseStoredEventToEnvelope proxy eventId streamId cursor streamVer corrId timestamp payloadJson eventPayloadVersion = do
    -- Parse payload using the stored event payload version (with automatic upgrade)
    payload <- parseEventPayload proxy payloadJson eventPayloadVersion
    pure $ createEventEnvelope eventId streamId cursor streamVer corrId timestamp payload
