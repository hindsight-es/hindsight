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

import Control.Monad.IO.Class (MonadIO (..))
import Data.Aeson (encode, toJSON)
import Data.ByteString qualified as BS
import Data.ByteString.Lazy qualified as BL
import Data.Default (def)
import Data.Foldable (toList)
import Data.Int (Int64)
import Data.Map.Strict qualified as Map
import Data.Pool (withResource)
import Data.ProtoLens (defMessage)
import Data.Proxy (Proxy (..))
import Data.String (fromString)
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
import Network.GRPC.Common.Protobuf (Protobuf, Proto (..))
import Network.GRPC.Common.StreamElem (StreamElem (..))
import Proto.Streams (Streams)
import Proto.Streams qualified as Proto
import Proto.Streams_Fields qualified as Fields

-- | EventStore instance for KurrentDB
instance EventStore KurrentStore where
    type StoreConstraints KurrentStore m = MonadIO m

    insertEvents handle _correlationId (Transaction streams) = liftIO $ do
        -- Phase 1: Only single-stream appends supported
        case Map.toList streams of
            [] ->
                -- No streams, return success with empty cursors
                pure $
                    SuccessfulInsertion $
                        InsertionSuccess
                            { finalCursor = KurrentCursor{commitPosition = 0, preparePosition = 0}
                            , streamCursors = Map.empty
                            }
            [(streamId, streamWrite)] -> insertSingleStream handle streamId streamWrite
            multipleStreams ->
                pure $
                    FailedInsertion $
                        OtherError $
                            ErrorInfo
                                { errorMessage =
                                    "Multi-stream atomic appends not yet implemented (Phase 2). "
                                        <> "Attempted to append to "
                                        <> T.pack (show (length multipleStreams))
                                        <> " streams."
                                , exception = Nothing
                                }

    subscribe = error "subscribe: Not yet implemented"

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
