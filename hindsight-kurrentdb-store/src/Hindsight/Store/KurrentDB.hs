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

KurrentDB-backed event store providing:

* Single-stream event appends via gRPC
* Optimistic concurrency control
* ACID guarantees through KurrentDB

Multi-stream atomic appends and subscriptions are not yet implemented.
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

import Control.Monad.IO.Class (MonadIO (..))
import Data.Aeson (encode)
import Data.Aeson qualified as Aeson
import Data.ByteString.Lazy qualified as BL
import Data.Default (def)
import Data.Foldable (toList)
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
import Network.GRPC.Common.Protobuf (Proto (..))
import Network.GRPC.Common.StreamElem (StreamElem (..))
import Proto.Streams (Streams)
import Proto.Streams qualified as Proto
import Proto.Streams_Fields qualified as Fields

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
                -- Single-stream append
                insertSingleStream handle correlationId streamId streamWrite
            _multipleStreams ->
                -- Multi-stream atomic append not yet implemented
                pure $
                    FailedInsertion $
                        OtherError $
                            ErrorInfo
                                { errorMessage = "Multi-stream atomic appends not yet implemented"
                                , exception = Nothing
                                }

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
