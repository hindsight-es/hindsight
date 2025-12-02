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

Phase 3: Event subscriptions using KurrentDB's Streams.Read RPC.
-}
module Hindsight.Store.KurrentDB.Subscription (
    buildReadRequest,
    workerLoop,
) where

import Control.Monad.IO.Class (MonadIO (..))
import UnliftIO (MonadUnliftIO, withRunInIO)
import Data.Aeson qualified as Aeson
import Data.ByteString qualified as BS
import Data.ByteString.Lazy qualified as BL
import Data.Default (def)
import Data.Map.Strict qualified as Map
import Data.Pool (withResource)
import Data.ProtoLens (defMessage)
import Data.Proxy (Proxy (..))
import Data.String (fromString)
import GHC.TypeLits (symbolVal)
import Data.Text qualified as T
import Data.Text.Encoding qualified as Text
import Data.Time (getCurrentTime)
import Data.UUID qualified as UUID
import GHC.TypeLits (Symbol)
import Hindsight.Events (Event, getEventName)
import Hindsight.Store
import Hindsight.Store.KurrentDB.RPC ()
import Hindsight.Store.KurrentDB.Types
import Hindsight.Store.Parsing (parseStoredEventToEnvelope)
import Lens.Micro ((&), (.~), (^.))
import Network.GRPC.Client qualified as GRPC
import Network.GRPC.Common (NoMetadata (..))
import Network.GRPC.Common.Protobuf (Proto (..), Protobuf)
import Network.GRPC.Common.StreamElem (StreamElem (..))
import Proto.Shared qualified
import Proto.Streams (Streams)
import Proto.Streams qualified as Proto
import Proto.Streams_Fields qualified as Fields
import System.IO (hFlush, stdout)

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

Note: Single streams use stream-specific revision numbers, not global positions.
For Phase 3a, FromPosition with SingleStream will start from beginning.
This is a known limitation to be addressed in Phase 3b.
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
            FromPosition _cursor ->
                -- TODO: Single stream subscriptions need stream-specific revision, not global position
                -- For now, start from beginning. This is a Phase 3b improvement.
                Proto.ReadReq'Options'StreamOptions'Start defMessage
     in defMessage
            & #streamIdentifier .~ streamIdentifier
            & #maybe'revisionOption .~ Just revisionOpt

{- | Try to match and handle an event using the EventMatcher

This function walks through the EventMatcher GADT recursively, attempting to:
1. Match the event type name against each handler's event type
2. Parse the event payload at the correct version
3. Invoke the matched handler

Returns:
- Just Continue/Stop if event was matched and handled
- Nothing if no handler matched this event type
-}
tryMatchAndHandle ::
    forall ts m.
    (MonadIO m) =>
    T.Text ->
    -- ^ Event type name from metadata
    Aeson.Value ->
    -- ^ Event data JSON
    Integer ->
    -- ^ Event payload version
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
tryMatchAndHandle eventTypeName eventJson eventVersion eventId streamId cursor streamVer corrId matcher =
    case matcher of
        MatchEnd -> pure Nothing
        ((proxy :: Proxy event), handler) :? rest -> do
            let thisEventName = fromString $ symbolVal (Proxy @event) :: T.Text
            if thisEventName == eventTypeName
                then do
                    -- Found matching event type - try to parse and handle
                    timestamp <- liftIO getCurrentTime
                    case parseStoredEventToEnvelope proxy eventId streamId cursor streamVer corrId timestamp eventJson eventVersion of
                        Just envelope -> do
                            -- Successfully parsed - invoke handler
                            result <- handler envelope
                            pure (Just result)
                        Nothing ->
                            -- Parse failed (version mismatch or malformed data) - silently skip
                            pure Nothing
                else
                    -- Not a match - try next handler
                    tryMatchAndHandle eventTypeName eventJson eventVersion eventId streamId cursor streamVer corrId rest

{- | Worker loop for subscription

This function:
1. Gets a connection from the pool
2. Builds the ReadReq
3. Opens a server-streaming RPC call
4. Processes the stream of ReadResp messages
5. Deserializes events and invokes handlers

Phase 3b: Full event deserialization and handler invocation
-}
workerLoop ::
    forall ts m.
    (MonadUnliftIO m) =>
    KurrentHandle ->
    EventMatcher ts KurrentStore m ->
    EventSelector KurrentStore ->
    m ()
workerLoop handle matcher selector = withRunInIO $ \runInIO -> do
    putStrLn "Starting subscription worker..."
    hFlush stdout

    withResource handle.connectionPool $ \conn -> do
        let request = buildReadRequest selector

        putStrLn "Opening gRPC stream..."
        hFlush stdout

        GRPC.withRPC conn def (Proxy @(Protobuf Streams "read")) $ \call -> do
            -- Send the subscription request
            putStrLn "Sending subscription request..."
            hFlush stdout
            GRPC.sendFinalInput call (Proto request)

            -- Process response stream
            putStrLn "Processing response stream..."
            hFlush stdout
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
processResponseStream runInIO matcher call = loop 0
  where
    loop :: Int -> IO ()
    loop count = do
        mbResp <- GRPC.recvOutput call
        case mbResp of
            StreamElem (Proto resp) -> do
                shouldContinue <- handleReadResponse runInIO matcher count resp
                if shouldContinue
                    then loop (count + 1)
                    else do
                        putStrLn "Subscription stopped by handler"
                        hFlush stdout
            FinalElem (Proto resp) _ -> do
                -- Final element with trailing metadata
                shouldContinue <- handleReadResponse runInIO matcher count resp
                if shouldContinue
                    then do
                        putStrLn $ "Subscription stream ended after " ++ show (count + 1) ++ " messages (final element)"
                        hFlush stdout
                    else do
                        putStrLn "Subscription stopped by handler (on final element)"
                        hFlush stdout
            NoMoreElems _ -> do
                putStrLn $ "Subscription stream ended after " ++ show count ++ " messages"
                hFlush stdout
                pure ()

{- | Handle a single ReadResp message

Phase 3b: Full event deserialization and handler invocation

Returns True to continue processing, False to stop subscription
-}
handleReadResponse ::
    forall ts m.
    (MonadIO m) =>
    (forall a. m a -> IO a) ->
    EventMatcher ts KurrentStore m ->
    Int ->
    Proto.ReadResp ->
    IO Bool
handleReadResponse runInIO matcher msgNum resp =
    case resp ^. #maybe'content of
        Just (Proto.ReadResp'Event readEvent) -> do
            let recordedEvent = readEvent ^. #event

            -- Extract event metadata
            let protoEventId = recordedEvent ^. #id
            let eventIdText = case protoEventId ^. #maybe'value of
                    Just (Proto.Shared.UUID'String str) -> str
                    _ -> ""

            case UUID.fromText eventIdText of
                Nothing -> do
                    putStrLn $ "[" ++ show msgNum ++ "] WARNING: Invalid event UUID: " ++ T.unpack eventIdText
                    hFlush stdout
                    pure True
                Just eventUuid -> do
                    let eventId = EventId eventUuid

                    -- Extract stream ID
                    let protoStreamName = recordedEvent ^. #streamIdentifier . #streamName
                    case UUID.fromText (Text.decodeUtf8 protoStreamName) of
                        Nothing ->
                            -- Skip non-UUID streams (e.g. system streams like $settings, $stats in $all)
                            pure True
                        Just streamUuid -> do
                            let streamId = StreamId streamUuid

                            -- Extract positions
                            let commitPos = recordedEvent ^. #commitPosition
                            let preparePos = recordedEvent ^. #preparePosition
                            let cursor = KurrentCursor{commitPosition = commitPos, preparePosition = preparePos}

                            -- Extract stream version
                            let streamVer = StreamVersion $ fromIntegral $ recordedEvent ^. #streamRevision

                            -- Extract event data and metadata
                            let eventData = recordedEvent ^. #data'
                            let metadataMap = recordedEvent ^. #metadata

                            -- Get event type from metadata
                            case Map.lookup "type" metadataMap of
                                Nothing -> do
                                    putStrLn $ "[" ++ show msgNum ++ "] WARNING: Event missing 'type' in metadata"
                                    hFlush stdout
                                    pure True
                                Just eventTypeName -> do
                                    -- Parse JSON event data
                                    case Aeson.decodeStrict' eventData of
                                        Nothing -> do
                                            putStrLn $ "[" ++ show msgNum ++ "] WARNING: Failed to decode event JSON"
                                            hFlush stdout
                                            pure True
                                        Just eventJson -> do
                                            -- Try to match and handle the event
                                            -- For now, assume version 1 (TODO: extract from metadata if stored)
                                            result <- runInIO $ tryMatchAndHandle eventTypeName eventJson 1 eventId streamId cursor streamVer Nothing matcher
                                            case result of
                                                Nothing ->
                                                    -- No handler matched - silently skip
                                                    pure True
                                                Just Continue -> pure True
                                                Just Stop -> pure False

        Just (Proto.ReadResp'Confirmation confirmation) -> do
            let subId = confirmation ^. #subscriptionId
            putStrLn $ "[" ++ show msgNum ++ "] Subscription confirmed: " ++ T.unpack subId
            hFlush stdout
            pure True

        Just (Proto.ReadResp'Checkpoint' checkpoint) -> do
            let commitPos = checkpoint ^. #commitPosition
            let preparePos = checkpoint ^. #preparePosition
            putStrLn $ "[" ++ show msgNum ++ "] Checkpoint: commit=" ++ show commitPos ++ " prepare=" ++ show preparePos
            hFlush stdout
            pure True

        Just (Proto.ReadResp'CaughtUp' _) -> do
            putStrLn $ "[" ++ show msgNum ++ "] *** Caught up to live ***"
            hFlush stdout
            pure True

        Just (Proto.ReadResp'FellBehind' _) -> do
            putStrLn $ "[" ++ show msgNum ++ "] *** Fell behind ***"
            hFlush stdout
            pure True

        Just (Proto.ReadResp'StreamNotFound' _) -> do
            putStrLn $ "[" ++ show msgNum ++ "] ERROR: Stream not found"
            hFlush stdout
            pure False  -- Stop on stream not found

        Just (Proto.ReadResp'FirstStreamPosition pos) -> do
            putStrLn $ "[" ++ show msgNum ++ "] First stream position: " ++ show pos
            hFlush stdout
            pure True

        Just (Proto.ReadResp'LastStreamPosition pos) -> do
            putStrLn $ "[" ++ show msgNum ++ "] Last stream position: " ++ show pos
            hFlush stdout
            pure True

        Just (Proto.ReadResp'LastAllStreamPosition pos) -> do
            putStrLn $ "[" ++ show msgNum ++ "] Last $all position: " ++ show pos
            hFlush stdout
            pure True

        Nothing -> do
            putStrLn $ "[" ++ show msgNum ++ "] WARNING: Malformed response (no content)"
            hFlush stdout
            pure True
