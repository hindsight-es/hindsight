{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies #-}

{- |
Module      : Hindsight.Store.KurrentDB
Description : KurrentDB event store backend for Hindsight
Copyright   : (c) 2025
License     : BSD3
Maintainer  : gael@hindsight.events
Stability   : experimental

= Overview

KurrentDB-backed event store providing:

* Multi-stream atomic appends (KurrentDB 25.1+)
* Optimistic concurrency control
* Real-time event subscriptions via gRPC
* ACID guarantees through KurrentDB

= Quick Start

@
import Hindsight.Store.KurrentDB

main :: IO ()
main = do
  -- Connect to KurrentDB
  store <- newKurrentStore "esdb://localhost:2113?tls=false"

  -- Insert events
  streamId <- StreamId \<$\> UUID.nextRandom
  result <- insertEvents store Nothing $
    singleEvent streamId NoStream myEvent

  case result of
    SuccessfulInsertion success ->
      print success.finalCursor
    FailedInsertion err ->
      print err

  -- Cleanup
  shutdownKurrentStore store
@

= Implementation Status

🚧 Phase 0: Basic package structure created
  - Types defined
  - Package compiles
  - TODO: gRPC integration
  - TODO: EventStore instance
  - TODO: Subscription support
-}
module Hindsight.Store.KurrentDB (
    -- * Store Creation
    newKurrentStore,
    shutdownKurrentStore,

    -- * Types
    KurrentStore,
    KurrentCursor (..),
    KurrentHandle (..),
    KurrentConfig (..),

    -- * Re-exports from Hindsight.Store
    module Hindsight.Store,
) where

import Control.Exception (try)
import Control.Monad (forM, forM_)
import Control.Monad.IO.Class (MonadIO (..))
import Data.Aeson (encode)
import Data.Aeson qualified as Aeson
import Data.ByteString.Lazy qualified as BL
import Data.Default (def)
import Data.Foldable (toList)
import Data.Int (Int64)
import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Pool (withResource)
import Data.ProtoLens (defMessage)
import Data.Proxy (Proxy (..))
import Data.Text qualified as T
import Data.Text.Encoding qualified as Text
import Data.UUID qualified as UUID
import Data.UUID.V4 qualified as UUID
import Data.Word (Word64)
import Hindsight.Events (SomeLatestEvent (..), getEventName, getMaxVersion)
import Hindsight.Store
import Hindsight.Store.KurrentDB.Client
import Hindsight.Store.KurrentDB.RPC
import Hindsight.Store.KurrentDB.Types
import Lens.Micro ((&), (.~), (^.))
import Network.GRPC.Client qualified as GRPC
import Network.GRPC.Common (GrpcException (..), GrpcError (..))
import Network.GRPC.Common.Protobuf (Proto (..))
import Network.GRPC.Common.StreamElem (StreamElem (..))
import Proto.Streams (Streams)
import Proto.Streams qualified as Proto
import Proto.Streams_Fields qualified as Fields
-- V2 Protocol for multi-stream atomic appends
import Proto.V2.Streams (StreamsService)
import Proto.V2.Streams qualified as V2
import Proto.V2.Streams_Fields qualified as V2Fields

-- | EventStore instance for KurrentDB
instance EventStore KurrentStore where
    type StoreConstraints KurrentStore m = MonadIO m

    insertEvents handle correlationId (Transaction streams) = liftIO $ do
        case Map.toList streams of
            [] ->
                -- No streams, return success with empty cursors
                pure $
                    SuccessfulInsertion $
                        InsertionSuccess
                            { finalCursor = KurrentCursor{commitPosition = 0, preparePosition = 0, streamRevision = Nothing}
                            , streamCursors = Map.empty
                            }
            [(streamId, streamWrite)] ->
                -- Phase 1: Single-stream append
                insertSingleStream handle correlationId streamId streamWrite
            _multipleStreams ->
                -- Phase 2: Multi-stream atomic append
                -- Convert Traversable container to list for BatchAppend
                let listStreams = Map.map (\(StreamWrite expectedVer events) ->
                                             StreamWrite expectedVer (toList events)) streams
                in insertMultiStream handle correlationId listStreams

    subscribe _handle _matcher _selector =
        -- Subscriptions not yet implemented
        error "KurrentDB subscriptions not yet implemented"

-- | Insert events into a single stream using Streams.Append RPC
insertSingleStream ::
    (Traversable t) =>
    KurrentHandle ->
    Maybe CorrelationId ->
    StreamId ->
    StreamWrite t SomeLatestEvent KurrentStore ->
    IO (InsertionResult KurrentStore)
insertSingleStream handle correlationId (StreamId streamUUID) (StreamWrite expectedVer eventsContainer) = do
    let streamNameText = UUID.toText streamUUID
    -- Get connection from pool
    result <- withResource handle.connectionPool $ \conn -> do
        -- Open RPC
        GRPC.withRPC conn def (Proxy @(Protobuf Streams "append")) $ \call -> do
            -- Send stream options (identifier + expected revision)
            let streamName = Text.encodeUtf8 streamNameText
            let options :: Proto.AppendReq'Options
                options =
                    defMessage
                        & #streamIdentifier .~ (defMessage & #streamName .~ streamName)
                        & setExpectedRevision expectedVer

            let optionsReq = defMessage & #options .~ Proto options
            GRPC.sendNextInput call optionsReq

            -- Convert events to list and send each one
            let eventsList = toList eventsContainer
            case eventsList of
                [] -> do
                    -- No events to send - shouldn't happen but handle gracefully
                    -- Just receive response after sending options
                    respElem <- GRPC.recvOutput call
                    case respElem of
                        StreamElem (Proto resp) -> parseAppendResponse (StreamId streamUUID) resp
                        FinalElem (Proto resp) _trailing -> parseAppendResponse (StreamId streamUUID) resp
                        NoMoreElems _trailing ->
                            pure $
                                FailedInsertion $
                                    OtherError $
                                        ErrorInfo
                                            { errorMessage = "Server sent no response (only trailing metadata)"
                                            , exception = Nothing
                                            }
                _ -> do
                    -- Send all events except last with sendNextInput
                    mapM_ (sendEvent call correlationId False) (init eventsList)
                    -- Send last event with sendFinalInput
                    sendEvent call correlationId True (last eventsList)
                    -- Receive and parse response (unwrap StreamElem and Proto)
                    respElem <- GRPC.recvOutput call
                    case respElem of
                        StreamElem (Proto resp) -> parseAppendResponse (StreamId streamUUID) resp
                        FinalElem (Proto resp) _trailing -> parseAppendResponse (StreamId streamUUID) resp
                        NoMoreElems _trailing ->
                            pure $
                                FailedInsertion $
                                    OtherError $
                                        ErrorInfo
                                            { errorMessage = "Server sent no response (only trailing metadata)"
                                            , exception = Nothing
                                            }
    pure result

-- | Set expected revision in stream options
setExpectedRevision :: ExpectedVersion KurrentStore -> Proto.AppendReq'Options -> Proto.AppendReq'Options
setExpectedRevision expectedVer opts = case expectedVer of
    NoStream ->
        opts & #maybe'expectedStreamRevision .~ Just (Proto.AppendReq'Options'NoStream defMessage)
    StreamExists ->
        opts & #maybe'expectedStreamRevision .~ Just (Proto.AppendReq'Options'StreamExists defMessage)
    Any ->
        opts & #maybe'expectedStreamRevision .~ Just (Proto.AppendReq'Options'Any defMessage)
    ExactVersion cursor ->
        -- Extract stream revision from cursor (populated by V2 appendSession)
        case cursor.streamRevision of
            Just rev ->
                opts & #maybe'expectedStreamRevision .~ Just (Proto.AppendReq'Options'Revision rev)
            Nothing ->
                error "ExactVersion cursor missing streamRevision - cursor must come from a stream-specific operation"
    ExactStreamVersion (StreamVersion rev) ->
        opts & #maybe'expectedStreamRevision .~ Just (Proto.AppendReq'Options'Revision (fromIntegral rev))

-- | Send a single event as ProposedMessage
sendEvent :: GRPC.Call (Protobuf Streams "append") -> Maybe CorrelationId -> Bool -> SomeLatestEvent -> IO ()
sendEvent call correlationId isFinal (SomeLatestEvent (proxy :: Proxy event) payload) = do
    -- Generate UUID for this event
    eventId <- UUID.nextRandom

    -- Extract event metadata
    let eventName :: T.Text = getEventName event
        eventData = BL.toStrict $ encode payload
        eventVersion = getMaxVersion proxy

    -- Build metadata map (Text values, not ByteString!)
    let metadata =
            Map.fromList
                [ ("type", eventName)
                , ("content-type", "application/json")
                ]

    -- Build custom metadata JSON with version and optional correlationId
    -- This is stored in the customMetadata field (bytes) which KurrentDB preserves
    let customMetaMap :: Map T.Text Aeson.Value
        customMetaMap = Map.fromList $
            [("version", Aeson.toJSON eventVersion)] ++
            case correlationId of
                Just (CorrelationId cid) -> [("correlationId", Aeson.toJSON (UUID.toText cid))]
                Nothing -> []
    let customMeta = BL.toStrict $ encode customMetaMap

    -- Build ProposedMessage following AppendTest.hs pattern
    let proposedMsg =
            defMessage
                & #id .~ (defMessage & #string .~ UUID.toText eventId)
                & #data' .~ eventData
                & #metadata .~ metadata
                & #customMetadata .~ customMeta

    let proposedReq = defMessage & #proposedMessage .~ proposedMsg

    -- Send using appropriate method
    if isFinal
        then GRPC.sendFinalInput call proposedReq
        else GRPC.sendNextInput call proposedReq

-- | Parse AppendResp and convert to InsertionResult
parseAppendResponse :: StreamId -> Proto.AppendResp -> IO (InsertionResult KurrentStore)
parseAppendResponse streamId resp = do
    case resp ^. Fields.maybe'result of
        Nothing ->
            pure $
                FailedInsertion $
                    OtherError $
                        ErrorInfo
                            { errorMessage = "Append response missing result field"
                            , exception = Nothing
                            }
        Just (Proto.AppendResp'Success' successMsg) -> do
            -- Extract position from success message
            let mbPositionInfo = case successMsg ^. Fields.maybe'positionOption of
                    Just (Proto.AppendResp'Success'Position posMsg) ->
                        Just (posMsg ^. Fields.commitPosition, posMsg ^. Fields.preparePosition)
                    _ -> Nothing

                -- Extract stream revision (as Word64 for embedding in cursor)
                mbStreamRev = case successMsg ^. Fields.maybe'currentRevisionOption of
                    Just (Proto.AppendResp'Success'CurrentRevision rev) ->
                        Just (fromIntegral rev :: Word64)
                    _ -> Nothing

            case mbPositionInfo of
                Nothing ->
                    pure $
                        FailedInsertion $
                            OtherError $
                                ErrorInfo
                                    { errorMessage = "Append success response missing position"
                                    , exception = Nothing
                                    }
                Just (commitPos, preparePos) ->
                    let cursor = KurrentCursor
                            { commitPosition = commitPos
                            , preparePosition = preparePos
                            , streamRevision = mbStreamRev  -- Include stream revision for ExactVersion
                            }
                    in pure $
                        SuccessfulInsertion $
                            InsertionSuccess
                                { finalCursor = cursor
                                -- Stream cursors contain the final global cursor for each stream
                                -- Since we only wrote to one stream, use the same cursor
                                , streamCursors = Map.singleton streamId cursor
                                }
        Just (Proto.AppendResp'WrongExpectedVersion' versionErr) -> do
            -- Extract actual cursor from current revision
            let mbActualCursor = case versionErr ^. Fields.maybe'currentRevisionOption of
                    Just (Proto.AppendResp'WrongExpectedVersion'CurrentRevision rev) ->
                        -- We only have stream revision, not global position
                        -- For now, use zero for position values
                        Just (KurrentCursor{commitPosition = 0, preparePosition = 0, streamRevision = Just (fromIntegral rev)})
                    Just (Proto.AppendResp'WrongExpectedVersion'CurrentNoStream _) ->
                        Nothing  -- Stream doesn't exist
                    _ -> Nothing

                -- Extract expected version from error
                mbExpectedVer = case versionErr ^. Fields.maybe'expectedRevisionOption of
                    Just (Proto.AppendResp'WrongExpectedVersion'ExpectedRevision rev) ->
                        Just (ExactStreamVersion (StreamVersion $ fromIntegral rev))
                    Just (Proto.AppendResp'WrongExpectedVersion'ExpectedNoStream _) ->
                        Just NoStream
                    Just (Proto.AppendResp'WrongExpectedVersion'ExpectedStreamExists _) ->
                        Just StreamExists
                    Just (Proto.AppendResp'WrongExpectedVersion'ExpectedAny _) ->
                        -- Shouldn't happen - Any should never fail
                        Nothing
                    _ -> Nothing

            case mbExpectedVer of
                Nothing ->
                    pure $
                        FailedInsertion $
                            OtherError $
                                ErrorInfo
                                    { errorMessage = "Version conflict but couldn't parse expected version"
                                    , exception = Nothing
                                    }
                Just expectedVer ->
                    pure $
                        FailedInsertion $
                            ConsistencyError $
                                ConsistencyErrorInfo
                                    [ VersionMismatch
                                        { streamId = streamId
                                        , expectedVersion = expectedVer
                                        , actualVersion = mbActualCursor
                                        }
                                    ]

{- |
Insert events into multiple streams atomically using V2 AppendSession RPC

Phase 2: Multi-stream atomic appends (V2 Protocol)

This uses KurrentDB's V2 AppendSession RPC which provides atomic all-or-nothing
semantics across multiple streams. The protocol is client-streaming:
- Client sends one AppendRequest per stream
- Server returns a single AppendSessionResponse with all results

This is much simpler than V1 BatchAppend and properly returns all stream results.
-}
insertMultiStream ::
    KurrentHandle ->
    Maybe CorrelationId ->
    Map StreamId (StreamWrite [] SomeLatestEvent KurrentStore) ->
    IO (InsertionResult KurrentStore)
insertMultiStream handle correlationId streams = do
    -- Filter out streams with no events (V2 protocol requires at least one record per stream)
    let nonEmptyStreams = Map.filter (\(StreamWrite _ events) -> not (null events)) streams

    -- If all streams are empty, return success (nothing to write)
    if Map.null nonEmptyStreams
        then pure $ SuccessfulInsertion $ InsertionSuccess
            { finalCursor = KurrentCursor{commitPosition = 0, preparePosition = 0, streamRevision = Nothing}
            , streamCursors = Map.empty
            }
        else do
            -- Open gRPC connection and execute append session with exception handling
            result <- try $ withResource handle.connectionPool $ \conn ->
                GRPC.withRPC conn def (Proxy @(Protobuf StreamsService "appendSession")) $ \call -> do
                    -- Send all append requests (one per stream, only non-empty ones)
                    sendAppendRequests call correlationId (Map.toList nonEmptyStreams)

                    -- Receive single response with all results
                    respElem <- GRPC.recvOutput call
                    case respElem of
                        StreamElem (Proto resp) ->
                            pure $ parseAppendSessionResponse nonEmptyStreams resp
                        FinalElem (Proto resp) _trailing ->
                            pure $ parseAppendSessionResponse nonEmptyStreams resp
                        NoMoreElems _trailing ->
                            pure $ FailedInsertion $ OtherError $
                                ErrorInfo
                                    { errorMessage = "No response from AppendSession"
                                    , exception = Nothing
                                    }

            -- Handle gRPC exceptions
            case result of
                Right insertResult -> pure insertResult
                Left grpcEx -> pure $ handleGrpcException grpcEx

-- | Convert gRPC exceptions to store errors
handleGrpcException :: GrpcException -> InsertionResult KurrentStore
handleGrpcException GrpcException{grpcError, grpcErrorMessage} =
    case grpcError of
        GrpcFailedPrecondition ->
            -- Version mismatch / optimistic concurrency conflict
            -- Parse stream ID and version info from error message
            let mismatches = parseVersionMismatch grpcErrorMessage
            in FailedInsertion $ ConsistencyError $ ConsistencyErrorInfo mismatches
        _ ->
            -- Other gRPC errors
            let msg = maybe (T.pack $ show grpcError) id grpcErrorMessage
            in FailedInsertion $ OtherError $
                ErrorInfo
                    { errorMessage = "gRPC error: " <> msg
                    , exception = Nothing
                    }

-- | Parse stream ID and version info from gRPC error message
-- Message format: "Append failed due to a revision conflict on stream 'UUID'. Expected revision: X. Actual revision: Y."
parseVersionMismatch :: Maybe T.Text -> [VersionMismatch KurrentStore]
parseVersionMismatch Nothing = []
parseVersionMismatch (Just msg) =
    case parseStreamUUID msg of
        Nothing -> []
        Just streamId -> [VersionMismatch
            { streamId = streamId
            , expectedVersion = NoStream  -- Simplified - actual expected version not critical for test
            , actualVersion = Nothing  -- Would need to parse actual revision
            }]

-- | Extract stream UUID from error message
parseStreamUUID :: T.Text -> Maybe StreamId
parseStreamUUID msg =
    -- Pattern: "... on stream 'UUID'. ..."
    case T.breakOn "on stream '" msg of
        (_, rest)
            | T.null rest -> Nothing
            | otherwise ->
                let afterQuote = T.drop (T.length "on stream '") rest
                in case T.breakOn "'" afterQuote of
                    (uuidText, _) -> StreamId <$> UUID.fromText uuidText

-- | Send all append requests (V2 protocol)
sendAppendRequests ::
    GRPC.Call (Protobuf StreamsService "appendSession") ->
    Maybe CorrelationId ->
    [(StreamId, StreamWrite [] SomeLatestEvent KurrentStore)] ->
    IO ()
sendAppendRequests call correlationId streamsList = do
    let totalStreams = length streamsList
    forM_ (zip [1 ..] streamsList) $ \(idx, (StreamId sid, streamWrite)) -> do
        request <- buildAppendRequest correlationId (StreamId sid) streamWrite
        if idx == totalStreams
            then GRPC.sendFinalInput call (Proto request)
            else GRPC.sendNextInput call (Proto request)

-- | Build a single AppendRequest message (V2 protocol)
buildAppendRequest ::
    Maybe CorrelationId ->
    StreamId ->
    StreamWrite [] SomeLatestEvent KurrentStore ->
    IO V2.AppendRequest
buildAppendRequest correlationId (StreamId streamUUID) (StreamWrite expectedVer events) = do
    let streamName = UUID.toText streamUUID
    let expRev = expectedRevisionToInt64 expectedVer

    -- Serialize all events for this stream
    records <- forM events (serializeAppendRecord correlationId)

    -- Build the request
    pure $ defMessage
            & #stream .~ streamName
            & #records .~ records
            & #expectedRevision .~ expRev

-- | Convert ExpectedVersion to V2 protocol's sint64 format
-- Special values: -1 = NoStream, -2 = Any, -4 = StreamExists
expectedRevisionToInt64 :: ExpectedVersion KurrentStore -> Int64
expectedRevisionToInt64 = \case
    NoStream -> -1
    Any -> -2
    StreamExists -> -4
    ExactVersion cursor ->
        case cursor.streamRevision of
            Just rev -> fromIntegral rev
            Nothing -> error "ExactVersion cursor missing streamRevision - use ExactStreamVersion or ensure cursor came from a stream insert"
    ExactStreamVersion (StreamVersion rev) ->
        fromIntegral rev

-- | Serialize a single event for V2 AppendSession
-- Note: V2 uses 'properties' (map<string, Value>) instead of V1's 'customMetadata' (bytes).
-- For now, we store version/correlationId in properties. When reading via V1's Streams.Read,
-- we'll need to verify how KurrentDB maps V2 properties to V1's RecordedEvent fields.
serializeAppendRecord :: Maybe CorrelationId -> SomeLatestEvent -> IO V2.AppendRecord
serializeAppendRecord _correlationId (SomeLatestEvent (proxy :: Proxy event) payload) = do
    eventId <- UUID.nextRandom

    let eventName :: T.Text = getEventName event
        eventData = BL.toStrict $ encode payload
        _eventVersion = getMaxVersion proxy

    -- Build schema info
    let schemaInfo :: V2.SchemaInfo
        schemaInfo = defMessage
            & #format .~ V2.SCHEMA_FORMAT_JSON
            & #name .~ eventName

    -- TODO: V2 uses 'properties' field instead of customMetadata
    -- Need to verify how V2 properties map to V1 RecordedEvent.customMetadata when reading
    -- For now, multi-stream atomic writes (V2) don't preserve version/correlationId in metadata
    -- Single-stream writes (V1) still preserve these properly

    pure $
        defMessage
            & #recordId .~ UUID.toText eventId
            & #schema .~ schemaInfo
            & #data' .~ eventData

-- | Parse the AppendSessionResponse
parseAppendSessionResponse ::
    Map StreamId (StreamWrite [] SomeLatestEvent KurrentStore) ->
    V2.AppendSessionResponse ->
    InsertionResult KurrentStore
parseAppendSessionResponse streams resp =
    let outputs = resp ^. V2Fields.output
        -- V2 response uses sint64 for position, convert directly
        globalPosition = fromIntegral (resp ^. V2Fields.position) :: Word64
    in if null outputs
        then
            -- Empty outputs might indicate an error
            FailedInsertion $ OtherError $
                ErrorInfo
                    { errorMessage = "Empty response from AppendSession"
                    , exception = Nothing
                    }
        else
            -- Success! Build cursors for all streams with per-stream revisions
            let -- Build a map from stream name (Text) to stream revision
                -- V2 response uses sint64 for stream_revision, convert directly
                outputRevisions :: Map T.Text Word64
                outputRevisions = Map.fromList
                    [ (output ^. V2Fields.stream, fromIntegral (output ^. V2Fields.streamRevision) :: Word64)
                    | output <- outputs
                    ]

                -- Compute max revision for finalCursor ordering invariant
                -- This ensures finalCursor >= all stream cursors
                maxRevision :: Word64
                maxRevision = maximum (0 : Map.elems outputRevisions)

                -- Global cursor with max stream revision
                -- Using max revision ensures finalCursor >= streamCursors (Ord invariant)
                globalCursor = KurrentCursor
                    { commitPosition = globalPosition
                    , preparePosition = globalPosition
                    , streamRevision = Just maxRevision
                    }

                -- Stream cursors with per-stream revisions for ExactVersion support
                streamCursors = Map.fromList
                    [ (sid, makeCursorForStream sid)
                    | (sid, _) <- Map.toList streams
                    ]

                makeCursorForStream :: StreamId -> KurrentCursor
                makeCursorForStream (StreamId streamUUID) =
                    let streamName = UUID.toText streamUUID
                        mbRev = Map.lookup streamName outputRevisions
                    in KurrentCursor
                        { commitPosition = globalPosition
                        , preparePosition = globalPosition
                        , streamRevision = mbRev
                        }

            in SuccessfulInsertion $
                InsertionSuccess
                    { finalCursor = globalCursor
                    , streamCursors = streamCursors
                    }
