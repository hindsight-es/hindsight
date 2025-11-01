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

import Control.Concurrent.Async (async, cancel, wait)
import Control.Monad (forM, forM_)
import Control.Monad.IO.Class (MonadIO (..))
import Data.Aeson (encode, toJSON)
import Data.ByteString qualified as BS
import Data.ByteString.Lazy qualified as BL
import Data.Default (def)
import Data.Foldable (toList)
import Data.Int (Int64)
import Data.List (maximumBy)
import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Maybe (fromMaybe)
import Data.Ord (comparing)
import Data.Pool (withResource)
import Data.ProtoLens (defMessage)
import Data.Proxy (Proxy (..))
import Data.Set (Set)
import Data.Set qualified as Set
import Data.String (fromString)
import Data.Text qualified as T
import Data.Text.Encoding qualified as Text
import Data.UUID (UUID)
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
import Network.GRPC.Common.Protobuf (Protobuf, Proto (..))
import Network.GRPC.Common.StreamElem (StreamElem (..))
import Proto.Status_Fields qualified as StatusFields
import Proto.Streams (Streams)
import Proto.Streams qualified as Proto
import Proto.Streams_Fields qualified as Fields

-- | EventStore instance for KurrentDB
instance EventStore KurrentStore where
    type StoreConstraints KurrentStore m = MonadIO m

    insertEvents handle _correlationId (Transaction streams) = liftIO $ do
        case Map.toList streams of
            [] ->
                -- No streams, return success with empty cursors
                pure $
                    SuccessfulInsertion $
                        InsertionSuccess
                            { finalCursor = KurrentCursor{commitPosition = 0, preparePosition = 0}
                            , streamCursors = Map.empty
                            }
            [(streamId, streamWrite)] ->
                -- Phase 1: Single-stream append
                insertSingleStream handle streamId streamWrite
            _multipleStreams ->
                -- Phase 2: Multi-stream atomic append
                -- Convert Traversable container to list for BatchAppend
                let listStreams = Map.map (\(StreamWrite expectedVer events) ->
                                             StreamWrite expectedVer (toList events)) streams
                in insertMultiStream handle listStreams

    subscribe _handle _matcher _selector = liftIO $ do
        -- TODO: Implement actual subscription using Streams.Read RPC
        -- For now, return a stub that does nothing
        workerThread <- async $ pure ()
        pure $ SubscriptionHandle
            { cancel = cancel workerThread
            , wait = wait workerThread
            }

-- | Insert events into a single stream using Streams.Append RPC
insertSingleStream ::
    (Traversable t) =>
    KurrentHandle ->
    StreamId ->
    StreamWrite t SomeLatestEvent KurrentStore ->
    IO (InsertionResult KurrentStore)
insertSingleStream handle (StreamId streamUUID) (StreamWrite expectedVer eventsContainer) = do
    -- Get connection from pool
    withResource handle.connectionPool $ \conn -> do
        -- Open RPC
        GRPC.withRPC conn def (Proxy @(Protobuf Streams "append")) $ \call -> do
            -- Send stream options (identifier + expected revision)
            let streamName = Text.encodeUtf8 $ UUID.toText streamUUID
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
                    mapM_ (sendEvent call False) (init eventsList)
                    -- Send last event with sendFinalInput
                    sendEvent call True (last eventsList)
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

-- | Set expected revision in stream options
setExpectedRevision :: ExpectedVersion KurrentStore -> Proto.AppendReq'Options -> Proto.AppendReq'Options
setExpectedRevision expectedVer opts = case expectedVer of
    NoStream ->
        opts & #maybe'expectedStreamRevision .~ Just (Proto.AppendReq'Options'NoStream defMessage)
    StreamExists ->
        opts & #maybe'expectedStreamRevision .~ Just (Proto.AppendReq'Options'StreamExists defMessage)
    ExactVersion cursor ->
        -- KurrentDB Append uses stream revision, not global position
        -- This is a limitation - we'll need to track stream revisions separately
        -- For now, error out as this needs design work
        error "ExactVersion with global cursor not yet supported - use ExactStreamVersion"
    ExactStreamVersion (StreamVersion rev) ->
        opts & #maybe'expectedStreamRevision .~ Just (Proto.AppendReq'Options'Revision (fromIntegral rev))

-- | Send a single event as ProposedMessage
sendEvent :: GRPC.Call (Protobuf Streams "append") -> Bool -> SomeLatestEvent -> IO ()
sendEvent call isFinal (SomeLatestEvent (proxy :: Proxy event) payload) = do
    -- Generate UUID for this event
    eventId <- UUID.nextRandom

    -- Extract event metadata
    let eventName :: T.Text = getEventName event
        eventVersion = getMaxVersion proxy
        eventData = BL.toStrict $ encode payload

    -- Build metadata map (Text values, not ByteString!)
    let metadata =
            Map.fromList
                [ ("type", eventName)
                , ("content-type", "application/json")
                ]

    -- Build ProposedMessage following AppendTest.hs pattern
    let proposedMsg =
            defMessage
                & #id .~ (defMessage & #string .~ UUID.toText eventId)
                & #data' .~ eventData
                & #metadata .~ metadata

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
            let mbPosition = case successMsg ^. Fields.maybe'positionOption of
                    Just (Proto.AppendResp'Success'Position posMsg) ->
                        Just
                            KurrentCursor
                                { commitPosition = posMsg ^. Fields.commitPosition
                                , preparePosition = posMsg ^. Fields.preparePosition
                                }
                    _ -> Nothing

                -- Extract stream revision
                mbStreamRevision = case successMsg ^. Fields.maybe'currentRevisionOption of
                    Just (Proto.AppendResp'Success'CurrentRevision rev) ->
                        Just (StreamVersion $ fromIntegral rev)
                    _ -> Nothing

            case mbPosition of
                Nothing ->
                    pure $
                        FailedInsertion $
                            OtherError $
                                ErrorInfo
                                    { errorMessage = "Append success response missing position"
                                    , exception = Nothing
                                    }
                Just cursor ->
                    pure $
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
                        Just (KurrentCursor{commitPosition = 0, preparePosition = 0})
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
Insert events into multiple streams atomically using Streams.BatchAppend RPC

Phase 2: Multi-stream atomic appends

This uses KurrentDB's BatchAppend RPC which provides atomic all-or-nothing
semantics across multiple streams. The protocol is bidirectional streaming:
- Client sends one BatchAppendReq per stream
- Server responds with one BatchAppendResp per stream (may be out of order)
- Correlation IDs are used to match responses to requests

The final request must have is_final=true to signal completion.
-}
insertMultiStream ::
    KurrentHandle ->
    Map StreamId (StreamWrite [] SomeLatestEvent KurrentStore) ->
    IO (InsertionResult KurrentStore)
insertMultiStream handle streams = do
    -- 1. Assign unique correlation ID to each stream
    correlatedStreams <- assignCorrelations streams
    let streamsList = Map.toList correlatedStreams     -- [(UUID, (StreamId, StreamWrite))]
        -- BatchAppend returns ONE response for the entire batch
        -- The correlation ID will match the final request (with is_final=true)
        (finalCorrId, _) = last streamsList

    -- 2. Open gRPC connection and execute batch append
    withResource handle.connectionPool $ \conn ->
        GRPC.withRPC conn def (Proxy @(Protobuf Streams "batchAppend")) $ \call -> do
            -- 3. Send all batch requests
            sendBatchRequests call streamsList

            -- 4. Collect THE single response (atomic batch result)
            batchResp <- collectBatchResponse finalCorrId call

            -- 5. Convert batch response to InsertionResult for all streams
            pure $ convertBatchResponse streams batchResp

-- | Assign unique correlation IDs to each stream
assignCorrelations ::
    Map StreamId (StreamWrite [] SomeLatestEvent KurrentStore) ->
    IO (Map UUID (StreamId, StreamWrite [] SomeLatestEvent KurrentStore))
assignCorrelations streams = do
    pairs <- forM (Map.toList streams) $ \(streamId, streamWrite) -> do
        correlationId <- UUID.nextRandom
        pure (correlationId, (streamId, streamWrite))
    pure $ Map.fromList pairs

-- | Send all batch append requests
sendBatchRequests ::
    GRPC.Call (Protobuf Streams "batchAppend") ->
    [(UUID, (StreamId, StreamWrite [] SomeLatestEvent KurrentStore))] ->
    IO ()
sendBatchRequests call streamsList = do
    let totalStreams = length streamsList
    forM_ (zip [1 ..] streamsList) $ \(idx, (corrId, (streamId, streamWrite))) -> do
        let isFinal = (idx == totalStreams)
        request <- buildBatchRequest corrId streamId streamWrite isFinal
        if isFinal
            then GRPC.sendFinalInput call (Proto request)
            else GRPC.sendNextInput call (Proto request)

-- | Build a single BatchAppendReq message
buildBatchRequest ::
    UUID ->
    StreamId ->
    StreamWrite [] SomeLatestEvent KurrentStore ->
    Bool ->
    IO Proto.BatchAppendReq
buildBatchRequest corrId (StreamId streamUUID) (StreamWrite expectedVer events) isFinal = do
    let streamName = Text.encodeUtf8 $ UUID.toText streamUUID

    -- Build options with stream identifier and expected version
    let options =
            defMessage
                & #streamIdentifier .~ (defMessage & #streamName .~ streamName)
                & setBatchExpectedPosition expectedVer

    -- Serialize all events for this stream
    proposedMessages <- forM events serializeBatchEvent

    -- Build the complete request
    pure $
        defMessage
            & #correlationId .~ (defMessage & #string .~ UUID.toText corrId)
            & #options .~ options
            & #proposedMessages .~ proposedMessages
            & #isFinal .~ isFinal

-- | Set expected stream position for BatchAppend (similar to setExpectedRevision but for BatchAppend)
setBatchExpectedPosition :: ExpectedVersion KurrentStore -> Proto.BatchAppendReq'Options -> Proto.BatchAppendReq'Options
setBatchExpectedPosition expectedVer opts = case expectedVer of
    NoStream ->
        opts & #maybe'expectedStreamPosition .~ Just (Proto.BatchAppendReq'Options'NoStream defMessage)
    StreamExists ->
        opts & #maybe'expectedStreamPosition .~ Just (Proto.BatchAppendReq'Options'StreamExists defMessage)
    ExactVersion _ ->
        error "ExactVersion with global cursor not supported in BatchAppend - use ExactStreamVersion"
    ExactStreamVersion (StreamVersion rev) ->
        opts & #maybe'expectedStreamPosition .~ Just (Proto.BatchAppendReq'Options'StreamPosition (fromIntegral rev))

-- | Serialize a single event for BatchAppend
serializeBatchEvent :: SomeLatestEvent -> IO Proto.BatchAppendReq'ProposedMessage
serializeBatchEvent (SomeLatestEvent (proxy :: Proxy event) payload) = do
    eventId <- UUID.nextRandom

    let eventName :: T.Text = getEventName event
        eventData = BL.toStrict $ encode payload

    let metadata =
            Map.fromList
                [ ("type", eventName)
                , ("content-type", "application/json")
                ]

    pure $
        defMessage
            & #id .~ (defMessage & #string .~ UUID.toText eventId)
            & #data' .~ eventData
            & #metadata .~ metadata

-- | Collect THE single batch append response
-- BatchAppend is atomic: one response for the entire batch
collectBatchResponse ::
    UUID ->
    GRPC.Call (Protobuf Streams "batchAppend") ->
    IO Proto.BatchAppendResp
collectBatchResponse expectedCorrId call = do
    respElem <- GRPC.recvOutput call
    case respElem of
        StreamElem (Proto resp) -> validateAndReturn resp
        FinalElem (Proto resp) _trailing -> validateAndReturn resp
        NoMoreElems _trailing ->
            error "Server closed stream without sending batch response"
  where
    validateAndReturn resp = do
        -- Verify correlation ID matches
        let corrIdProto = resp ^. Fields.correlationId
            mbCorrId = UUID.fromText (corrIdProto ^. Fields.string)

        case mbCorrId of
            Nothing ->
                error "Invalid correlation ID in batch response"
            Just corrId
                | corrId == expectedCorrId -> pure resp
                | otherwise ->
                    error $
                        "Correlation ID mismatch. Expected: "
                            <> show expectedCorrId
                            <> ", Got: "
                            <> show corrId

-- | Convert single batch response to InsertionResult for all streams
-- BatchAppend is atomic: success/failure applies to ALL streams
convertBatchResponse ::
    Map StreamId (StreamWrite [] SomeLatestEvent KurrentStore) ->
    Proto.BatchAppendResp ->
    InsertionResult KurrentStore
convertBatchResponse streams resp =
    case resp ^. Fields.maybe'result of
        Just (Proto.BatchAppendResp'Success' successMsg) -> do
            -- Extract global position from the batch operation
            let mbPosition = case successMsg ^. Fields.maybe'positionOption of
                    Just (Proto.BatchAppendResp'Success'Position posMsg) ->
                        KurrentCursor
                            { commitPosition = posMsg ^. Fields.commitPosition
                            , preparePosition = posMsg ^. Fields.preparePosition
                            }
                    _ -> KurrentCursor{commitPosition = 0, preparePosition = 0}

            -- All streams succeeded - create cursors for each
            -- Note: BatchAppend returns a single global position, not per-stream positions
            -- We use the same cursor for all streams since they were written atomically
            let streamCursors = Map.map (const mbPosition) streams

            SuccessfulInsertion $
                InsertionSuccess
                    { finalCursor = mbPosition
                    , streamCursors = streamCursors
                    }
        Just (Proto.BatchAppendResp'Error status) ->
            -- All streams failed atomically
            -- Create version mismatches for all streams
            let errorCode = fromEnum $ status ^. StatusFields.code
                errorMsg = status ^. StatusFields.message
                mismatches =
                    [ VersionMismatch
                        { streamId = sid
                        , expectedVersion = sw.expectedVersion
                        , actualVersion = Nothing -- TODO: Parse from error if available
                        }
                    | (sid, sw) <- Map.toList streams
                    ]
             in FailedInsertion $ ConsistencyError (ConsistencyErrorInfo mismatches)
        Nothing ->
            -- Missing result - treat as error for all streams
            let mismatches =
                    [ VersionMismatch
                        { streamId = sid
                        , expectedVersion = sw.expectedVersion
                        , actualVersion = Nothing
                        }
                    | (sid, sw) <- Map.toList streams
                    ]
             in FailedInsertion $ ConsistencyError (ConsistencyErrorInfo mismatches)
