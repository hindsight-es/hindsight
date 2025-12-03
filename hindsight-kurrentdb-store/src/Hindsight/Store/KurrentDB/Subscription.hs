{-# LANGUAGE GADTs #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}

{- |
Module      : Hindsight.Store.KurrentDB.Subscription
Description : Event subscription implementation for KurrentDB
Copyright   : (c) 2025
License     : BSD3
Maintainer  : gael@hindsight.events
Stability   : experimental

Event subscriptions using KurrentDB's Streams.Read RPC.
-}
module Hindsight.Store.KurrentDB.Subscription (
    buildReadRequest,
    workerLoop,
) where

import Control.Exception (SomeException, bracket, catch, throwIO)
import Control.Monad.IO.Class (MonadIO (..))
import UnliftIO (MonadUnliftIO, withRunInIO)
import Data.Aeson qualified as Aeson
import Data.Aeson.Types qualified as Aeson
import Data.Default (def)
import Data.Map.Strict qualified as Map
import Data.Maybe (fromMaybe)
import Data.ProtoLens (defMessage)
import Data.Proxy (Proxy (..))
import Data.String (fromString)
import GHC.TypeLits (symbolVal)
import Data.Text qualified as T
import Data.Text.Encoding qualified as Text
import Data.Time (getCurrentTime)
import Data.UUID qualified as UUID
import Hindsight.Events (Event, getMaxVersion, parseMapFromProxy)
import Hindsight.Store
import Hindsight.Store qualified as Store
import Hindsight.Store.KurrentDB.Client (serverFromConfig)
import Hindsight.Store.KurrentDB.RPC ()
import Hindsight.Store.KurrentDB.Types
import Hindsight.Store.Parsing (createEventEnvelope)
import Lens.Micro ((&), (.~), (^.))
import Network.GRPC.Client qualified as GRPC
import Network.GRPC.Common.Protobuf (Proto (..), Protobuf)
import Network.GRPC.Common.StreamElem (StreamElem (..))
import Proto.Shared qualified
import Proto.Streams (Streams)
import Proto.Streams qualified as Proto
import Proto.Streams_Fields qualified as Fields

{- | Build a ReadReq for subscribing to events

This creates a gRPC request for the Streams.Read RPC based on the event selector.
-}
buildReadRequest :: EventSelector KurrentStore -> Proto.ReadReq
buildReadRequest selector =
    defMessage
        & #options .~ buildReadOptions selector

{- | Build ReadReq options for subscription

Configures:
- Stream selection ($all or specific stream)
- Start position (beginning or specific cursor)
- Subscription mode (live, not count-limited)
- No filtering (for now)
- Forward direction
- No link resolution
-}
buildReadOptions :: EventSelector KurrentStore -> Proto.ReadReq'Options
buildReadOptions selector =
    let uuidOption = defMessage & #maybe'content .~ Just (Proto.ReadReq'Options'UUIDOption'String defMessage)
     in defMessage
            & #maybe'streamOption .~ buildStreamOption selector.streamId selector.startupPosition
            & #readDirection .~ Proto.ReadReq'Options'Forwards
            & #resolveLinks .~ False
            & #maybe'countOption .~ Just (Proto.ReadReq'Options'Subscription defMessage)
            & #maybe'filterOption .~ Just (Proto.ReadReq'Options'NoFilter defMessage)
            & #uuidOption .~ uuidOption

{- | Build stream option (single stream or $all)

Determines whether to subscribe to:
- AllStreams: Subscribe to the $all stream (global event log)
- SingleStream: Subscribe to a specific stream
-}
buildStreamOption ::
    StreamSelector ->
    StartupPosition KurrentStore ->
    Maybe Proto.ReadReq'Options'StreamOption
buildStreamOption streamSel startPos = case streamSel of
    AllStreams ->
        Just $ Proto.ReadReq'Options'All $ buildAllOptions startPos
    SingleStream streamId ->
        Just $ Proto.ReadReq'Options'Stream $ buildStreamOptions streamId startPos

{- | Build options for $all stream subscription

The $all stream uses global commit/prepare positions for positioning.
-}
buildAllOptions :: StartupPosition KurrentStore -> Proto.ReadReq'Options'AllOptions
buildAllOptions = \case
    FromBeginning ->
        defMessage & #maybe'allOption .~ Just (Proto.ReadReq'Options'AllOptions'Start defMessage)
    FromPosition cursor ->
        let position =
                defMessage
                    & #commitPosition .~ cursor.commitPosition
                    & #preparePosition .~ cursor.preparePosition
         in defMessage & #maybe'allOption .~ Just (Proto.ReadReq'Options'AllOptions'Position position)

{- | Build options for single stream subscription

Single streams use stream-specific revision numbers for positioning.
When FromPosition is used with a cursor that has streamRevision, we use that revision.
If the cursor lacks streamRevision (e.g., from AllStreams read), we fall back to start.
-}
buildStreamOptions :: StreamId -> StartupPosition KurrentStore -> Proto.ReadReq'Options'StreamOptions
buildStreamOptions (StreamId streamUuid) startPos =
    let streamName = Text.encodeUtf8 $ UUID.toText streamUuid
        streamIdentifier =
            defMessage
                & #streamName .~ streamName
        revisionOpt = case startPos of
            FromBeginning ->
                Proto.ReadReq'Options'StreamOptions'Start defMessage
            FromPosition cursor ->
                -- Use stream revision if available in cursor
                case cursor.streamRevision of
                    Just rev ->
                        Proto.ReadReq'Options'StreamOptions'Revision (fromIntegral rev)
                    Nothing ->
                        -- Fallback: cursor from AllStreams read lacks stream revision
                        Proto.ReadReq'Options'StreamOptions'Start defMessage
     in defMessage
            & #streamIdentifier .~ streamIdentifier
            & #maybe'revisionOption .~ Just revisionOpt

{- | Try to match and handle an event using the EventMatcher

This function walks through the EventMatcher GADT recursively, attempting to:
1. Match the event type name against each handler's event type
2. Parse the event payload at the correct version (using parseMapFromProxy)
3. Invoke the matched handler

Returns:
- Just Continue/Stop if event was matched and handled
- Nothing if no handler matched this event type

This follows the same pattern as the PostgreSQL store's processEventBatch:
- Use parseMapFromProxy to get versioned parsers
- Look up the stored version in the parse map
- If version not stored, default to the event's MaxVersion
-}
tryMatchAndHandle ::
    forall ts m.
    (MonadIO m) =>
    T.Text ->
    -- ^ Event type name from metadata
    Aeson.Value ->
    -- ^ Event data JSON
    Maybe Integer ->
    -- ^ Event payload version (Nothing = use MaxVersion)
    EventId ->
    -- ^ Unique event identifier
    StreamId ->
    -- ^ Stream this event belongs to
    KurrentCursor ->
    -- ^ Global position
    StreamVersion ->
    -- ^ Stream version
    Maybe CorrelationId ->
    -- ^ Optional correlation ID
    EventMatcher ts KurrentStore m ->
    -- ^ Event matcher with handlers
    m (Maybe SubscriptionResult)
tryMatchAndHandle eventTypeName eventJson mbVersion eventId streamId cursor streamVer corrId matcher =
    case matcher of
        MatchEnd -> pure Nothing
        ((proxy :: Proxy event), handler) :? rest -> do
            let thisEventName = fromString $ symbolVal (Proxy @event) :: T.Text
            if thisEventName == eventTypeName
                then do
                    -- Found matching event type - use parseMapFromProxy like PostgreSQL does
                    let parserMap = parseMapFromProxy proxy
                    -- Use stored version if available, otherwise use MaxVersion of this event type
                    let eventVersion = fromMaybe (fromIntegral $ getMaxVersion proxy) mbVersion
                    case Map.lookup (fromIntegral eventVersion) parserMap of
                        Just parser ->
                            case Aeson.parseEither parser eventJson of
                                Right parsedPayload -> do
                                    -- Successfully parsed - create envelope and invoke handler
                                    timestamp <- liftIO getCurrentTime
                                    let envelope = createEventEnvelope eventId streamId cursor streamVer corrId timestamp parsedPayload
                                    result <- handler envelope
                                    pure (Just result)
                                Left _err ->
                                    -- JSON parse failed - skip this event
                                    pure Nothing
                        Nothing ->
                            -- Unknown version - skip this event
                            pure Nothing
                else
                    -- Not a match - try next handler
                    tryMatchAndHandle eventTypeName eventJson mbVersion eventId streamId cursor streamVer corrId rest

{- | Worker loop for subscription

This function:
1. Creates a dedicated connection (not from pool - subscriptions are long-lived)
2. Builds the ReadReq
3. Opens a server-streaming RPC call
4. Processes the stream of ReadResp messages
5. Deserializes events and invokes handlers

Note: Subscriptions use dedicated connections instead of borrowing from the pool
because gRPC streaming holds the connection for the subscription's entire lifetime.
Using pool connections would exhaust the pool and block transactions.
-}
workerLoop ::
    forall ts m.
    (MonadUnliftIO m) =>
    KurrentHandle ->
    EventMatcher ts KurrentStore m ->
    EventSelector KurrentStore ->
    m ()
workerLoop handle matcher selector = withRunInIO $ \runInIO -> do
    -- Create dedicated connection for this subscription (not from pool)
    -- Subscriptions hold connections for their lifetime, so using the pool
    -- would exhaust it and block transactions
    bracket
        (GRPC.openConnection def (serverFromConfig handle.config))
        GRPC.closeConnection
        $ \conn -> do
            let request = buildReadRequest selector

            GRPC.withRPC conn def (Proxy @(Protobuf Streams "read")) $ \call -> do
                -- Send the subscription request
                GRPC.sendFinalInput call (Proto request)

                -- Process response stream
                processResponseStream runInIO matcher call

{- | Process stream of ReadResp messages

Receives ReadResp messages from the server in a loop until the stream ends.
Invokes event handlers and respects Stop/Continue results.
-}
processResponseStream ::
    forall ts m.
    (MonadIO m) =>
    (forall a. m a -> IO a) ->
    EventMatcher ts KurrentStore m ->
    GRPC.Call (Protobuf Streams "read") ->
    IO ()
processResponseStream runInIO matcher call = loop
  where
    loop :: IO ()
    loop = do
        mbResp <- GRPC.recvOutput call
        case mbResp of
            StreamElem (Proto resp) -> do
                shouldContinue <- handleReadResponse runInIO matcher resp
                if shouldContinue
                    then loop
                    else pure ()
            FinalElem (Proto resp) _ -> do
                -- Final element with trailing metadata
                _ <- handleReadResponse runInIO matcher resp
                pure ()
            NoMoreElems _ ->
                pure ()

{- | Handle a single ReadResp message

Returns True to continue processing, False to stop subscription
-}
handleReadResponse ::
    forall ts m.
    (MonadIO m) =>
    (forall a. m a -> IO a) ->
    EventMatcher ts KurrentStore m ->
    Proto.ReadResp ->
    IO Bool
handleReadResponse runInIO matcher resp =
    case resp ^. #maybe'content of
        Just (Proto.ReadResp'Event readEvent) -> do
            let recordedEvent = readEvent ^. #event

            -- Extract event metadata
            let protoEventId = recordedEvent ^. #id
            let eventIdText = case protoEventId ^. #maybe'value of
                    Just (Proto.Shared.UUID'String str) -> str
                    _ -> ""

            -- Extract stream name
            let protoStreamName = recordedEvent ^. #streamIdentifier . #streamName
            let streamNameText = Text.decodeUtf8 protoStreamName
            let metadataMap = recordedEvent ^. #metadata

            case UUID.fromText eventIdText of
                Nothing ->
                    -- Invalid event UUID - skip
                    pure True
                Just eventUuid -> do
                    let eventId = EventId eventUuid

                    -- Extract stream ID
                    case UUID.fromText streamNameText of
                        Nothing ->
                            -- Skip non-UUID streams (e.g. system streams like $settings, $stats in $all)
                            pure True
                        Just streamUuid -> do
                            let streamId = StreamId streamUuid

                            -- Extract positions and stream revision
                            let commitPos = recordedEvent ^. #commitPosition
                            let preparePos = recordedEvent ^. #preparePosition
                            let streamRev = fromIntegral $ recordedEvent ^. #streamRevision
                            let cursor = KurrentCursor{commitPosition = commitPos, preparePosition = preparePos, streamRevision = Just streamRev}

                            -- Extract stream version (0-indexed, same as KurrentDB)
                            let streamVer = StreamVersion $ fromIntegral $ recordedEvent ^. #streamRevision

                            -- Extract event data
                            let eventData = recordedEvent ^. #data'

                            -- Extract customMetadata (bytes field containing JSON with version)
                            let customMetaBytes = recordedEvent ^. #customMetadata

                            -- Get event type from metadata
                            case Map.lookup "type" metadataMap of
                                Nothing ->
                                    -- Event missing type - skip
                                    pure True
                                Just eventTypeName -> do
                                    -- Parse JSON event data
                                    case Aeson.decodeStrict' eventData of
                                        Nothing ->
                                            -- Failed to decode event JSON - skip
                                            pure True
                                        Just eventJson -> do
                                            -- Parse customMetadata JSON to extract version and correlationId
                                            -- customMetadata is stored as JSON: {"version": N, "correlationId": "uuid-string"}
                                            let customMeta = Aeson.decodeStrict' customMetaBytes :: Maybe (Map.Map T.Text Aeson.Value)
                                            let mbVersion :: Maybe Integer = do
                                                    cm <- customMeta
                                                    verVal <- Map.lookup "version" cm
                                                    case verVal of
                                                        Aeson.Number n -> Just (round n)
                                                        _ -> Nothing
                                            let mbCorrId :: Maybe CorrelationId = do
                                                    cm <- customMeta
                                                    corrVal <- Map.lookup "correlationId" cm
                                                    case corrVal of
                                                        Aeson.String corrText -> CorrelationId <$> UUID.fromText corrText
                                                        _ -> Nothing
                                            -- Get timestamp for exception enrichment
                                            timestamp <- getCurrentTime
                                            -- Run handler with exception wrapping
                                            result <- (runInIO $ tryMatchAndHandle eventTypeName eventJson mbVersion eventId streamId cursor streamVer mbCorrId matcher)
                                                `catch` \(e :: SomeException) ->
                                                    throwIO $ Store.HandlerException
                                                        { Store.originalException = e
                                                        , Store.failedEventPosition = T.pack $ show cursor
                                                        , Store.failedEventId = eventId
                                                        , Store.failedEventName = eventTypeName
                                                        , Store.failedEventStreamId = streamId
                                                        , Store.failedEventStreamVersion = streamVer
                                                        , Store.failedEventCorrelationId = mbCorrId
                                                        , Store.failedEventCreatedAt = timestamp
                                                        }
                                            case result of
                                                Nothing ->
                                                    -- No handler matched - continue
                                                    pure True
                                                Just Continue ->
                                                    pure True
                                                Just Stop ->
                                                    pure False

        Just (Proto.ReadResp'Confirmation _) ->
            -- Subscription confirmed - continue
            pure True

        Just (Proto.ReadResp'Checkpoint' _) ->
            -- Checkpoint - continue
            pure True

        Just (Proto.ReadResp'CaughtUp' _) ->
            -- Caught up to live - continue
            pure True

        Just (Proto.ReadResp'FellBehind' _) ->
            -- Fell behind - continue
            pure True

        Just (Proto.ReadResp'StreamNotFound' _) ->
            -- Stream not found - stop
            pure False

        Just (Proto.ReadResp'FirstStreamPosition _) ->
            pure True

        Just (Proto.ReadResp'LastStreamPosition _) ->
            pure True

        Just (Proto.ReadResp'LastAllStreamPosition _) ->
            pure True

        Nothing ->
            -- Malformed response - continue
            pure True
