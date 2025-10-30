{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

{- |
Module      : Hindsight.Store.PostgreSQL.Events.Insertion
Description : Event insertion logic for PostgreSQL backend
Copyright   : (c) 2024
License     : BSD3
Maintainer  : maintainer@example.com
Stability   : internal

Handles the insertion of events into PostgreSQL tables, including
transaction management, sequence number assignment, stream head updates,
and optional synchronous projection execution.
-}
module Hindsight.Store.PostgreSQL.Events.Insertion (
    -- * Types
    InsertedEvents (..),

    -- * Main insertion functions
    insertEventsWithSyncProjections,

    -- * Stream version utilities
    calculateStreamVersions,
    nextStreamVersions,
)
where

import Control.Monad (foldM, forM_, replicateM)
import Data.Aeson (Value, toJSON)
import Data.Foldable qualified as Foldable
import Data.Functor.Contravariant ((>$<))
import Data.Int (Int32, Int64)
import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Proxy (Proxy (..))
import Data.Text (Text)
import Data.Time (UTCTime)
import Data.Time.Clock (getCurrentTime)
import Data.UUID (UUID)
import Data.UUID.V4 qualified as UUID
import Hasql.Decoders qualified as D
import Hasql.Encoders qualified as E
import Hasql.Statement (Statement (..))
import Hasql.Transaction qualified as HasqlTransaction
import Hindsight.Events (SomeLatestEvent (..), getEventName, getMaxVersion)
import Hindsight.Store (CorrelationId (..), EventEnvelope (..), EventId (..), StreamId (..), StreamVersion (..), StreamWrite (..))
import Hindsight.Store.PostgreSQL.Core.Types (SQLCursor (..), SQLStore, SyncProjectionRegistry (..))
import Hindsight.Store.PostgreSQL.Projections.State (updateSyncProjectionState)
import Hindsight.Store.PostgreSQL.Projections.Sync (executeSyncProjectionForEvent)

-- * Types

-- | Result of event insertion
data InsertedEvents = InsertedEvents
    { finalCursor :: SQLCursor
    , streamCursors :: Map StreamId SQLCursor
    -- ^ Per-stream final cursors
    , insertedStreamIds :: [StreamId]
    , eventIds :: [UUID]
    , createdAt :: UTCTime
    , streamVersions :: Map StreamId [StreamVersion]
    }

-- * Database statements

{- | Get current transaction's xid8 from PostgreSQL
This uses PostgreSQL's native transaction ID which integrates with MVCC
-}
getTransactionXid8 :: Statement () Int64
getTransactionXid8 = Statement sql E.noParams decoder True
  where
    sql = "SELECT pg_current_xact_id()::text::bigint"
    decoder = D.singleRow $ D.column $ D.nonNullable D.int8

-- | Insert transaction xid8 into event_transactions table
insertTransactionXid8 :: Statement Int64 ()
insertTransactionXid8 = Statement sql encoder D.noResult True
  where
    sql = "INSERT INTO event_transactions (transaction_xid8) VALUES ($1::text::xid8)"
    encoder = E.param (E.nonNullable E.int8)

-- | Insert a single event into the events table
insertEventStatement :: Statement (Int64, Int32, EventId, StreamId, Maybe UUID, UTCTime, Text, Int32, Value, StreamVersion) ()
insertEventStatement = Statement sql encoder D.noResult True
  where
    sql =
        "INSERT INTO events (\
        \    transaction_xid8, seq_no, event_id, stream_id,\
        \    correlation_id, created_at, event_name, event_version, payload, stream_version\
        \) VALUES ($1::text::xid8, $2, $3, $4, $5, $6, $7, $8, $9, $10)"

    encoder =
        ((\(a, _, _, _, _, _, _, _, _, _) -> a) >$< E.param (E.nonNullable E.int8))
            <> ((\(_, b, _, _, _, _, _, _, _, _) -> b) >$< E.param (E.nonNullable E.int4))
            <> ((\(_, _, EventId c, _, _, _, _, _, _, _) -> c) >$< E.param (E.nonNullable E.uuid))
            <> ((\(_, _, _, StreamId d, _, _, _, _, _, _) -> d) >$< E.param (E.nonNullable E.uuid))
            <> ((\(_, _, _, _, e, _, _, _, _, _) -> e) >$< E.param (E.nullable E.uuid))
            <> ((\(_, _, _, _, _, f, _, _, _, _) -> f) >$< E.param (E.nonNullable E.timestamptz))
            <> ((\(_, _, _, _, _, _, g, _, _, _) -> g) >$< E.param (E.nonNullable E.text))
            <> ((\(_, _, _, _, _, _, _, h, _, _) -> h) >$< E.param (E.nonNullable E.int4))
            <> ((\(_, _, _, _, _, _, _, _, i, _) -> i) >$< E.param (E.nonNullable E.jsonb))
            <> ((\(_, _, _, _, _, _, _, _, _, StreamVersion j) -> j) >$< E.param (E.nonNullable E.int8))

-- | Update or insert a stream head record
updateStreamHeadStatement :: Statement (StreamId, Int64, Int32, EventId, StreamVersion) ()
updateStreamHeadStatement = Statement sql encoder D.noResult True
  where
    sql =
        "INSERT INTO stream_heads (\
        \    stream_id, latest_transaction_xid8, latest_seq_no, last_event_id, stream_version\
        \) VALUES ($1, $2::text::xid8, $3, $4, $5)\
        \  ON CONFLICT (stream_id) DO UPDATE SET\
        \    latest_transaction_xid8 = excluded.latest_transaction_xid8,\
        \    latest_seq_no = excluded.latest_seq_no,\
        \    last_event_id = excluded.last_event_id,\
        \    stream_version = excluded.stream_version"

    encoder =
        ((\(StreamId a, _, _, _, _) -> a) >$< E.param (E.nonNullable E.uuid))
            <> ((\(_, b, _, _, _) -> b) >$< E.param (E.nonNullable E.int8))
            <> ((\(_, _, c, _, _) -> c) >$< E.param (E.nonNullable E.int4))
            <> ((\(_, _, _, EventId d, _) -> d) >$< E.param (E.nonNullable E.uuid))
            <> ((\(_, _, _, _, StreamVersion e) -> e) >$< E.param (E.nonNullable E.int8))

-- | Get current stream version
getCurrentStreamVersionStmt :: Statement UUID (Maybe StreamVersion)
getCurrentStreamVersionStmt = Statement sql encoder decoder True
  where
    sql = "SELECT stream_version FROM stream_heads WHERE stream_id = $1"
    encoder = E.param (E.nonNullable E.uuid)
    decoder = D.rowMaybe $ D.column $ D.nonNullable $ fmap StreamVersion D.int8

-- * Helper functions

-- | Calculate stream versions for events based on current stream state
calculateStreamVersions ::
    Map StreamId (StreamWrite t SomeLatestEvent SQLStore) ->
    HasqlTransaction.Transaction (Map StreamId StreamVersion)
calculateStreamVersions eventBatches = do
    -- Get current stream versions for all streams
    currentVersions <- mapM getCurrentStreamVersion (Map.keys eventBatches)
    pure $ Map.fromList $ zip (Map.keys eventBatches) currentVersions
  where
    getCurrentStreamVersion :: StreamId -> HasqlTransaction.Transaction StreamVersion
    getCurrentStreamVersion (StreamId streamUUID) = do
        result <- HasqlTransaction.statement streamUUID getCurrentStreamVersionStmt
        pure $ maybe (StreamVersion 0) id result

-- | Calculate next stream versions for each stream
nextStreamVersions ::
    (Foldable t) =>
    Map StreamId (StreamWrite t SomeLatestEvent SQLStore) ->
    Map StreamId StreamVersion ->
    Map StreamId [StreamVersion]
nextStreamVersions eventBatches currentVersions =
    Map.mapWithKey calculateNextVersionsForStream eventBatches
  where
    calculateNextVersionsForStream streamId batch =
        let currentVersion = Map.findWithDefault (StreamVersion 0) streamId currentVersions
            eventCount = length $ Foldable.toList batch.events
         in [currentVersion + 1 .. currentVersion + fromIntegral eventCount]

-- * Main insertion functions

-- | Insert events and execute synchronous projections within the same transaction
insertEventsWithSyncProjections ::
    forall t.
    (Traversable t) =>
    SyncProjectionRegistry ->
    Maybe CorrelationId ->
    Map StreamId (StreamWrite t SomeLatestEvent SQLStore) ->
    IO (HasqlTransaction.Transaction InsertedEvents)
insertEventsWithSyncProjections syncRegistry correlationId eventBatches = do
    -- Generate metadata once
    eventIds <- replicateM totalEventCount UUID.nextRandom
    createdAt <- getCurrentTime

    pure $ do
        -- Get current transaction's xid8 from PostgreSQL
        -- This integrates with MVCC for consistent ordering across subscribers
        txXid8 <- HasqlTransaction.statement () getTransactionXid8

        -- Insert transaction xid8 into event_transactions table
        HasqlTransaction.statement txXid8 insertTransactionXid8

        -- Calculate current stream versions and determine next versions
        currentVersions <- calculateStreamVersions eventBatches
        let streamVersionMap = nextStreamVersions eventBatches currentVersions

        -- Process all events in a single traversal, generating EventWithMetadata for each
        -- Sync projections receive identical metadata to what's persisted
        streamHeadMetadata <- processEventsWithUnifiedMetadata syncRegistry correlationId eventIds createdAt streamVersionMap txXid8 eventBatches

        -- Compute per-stream cursors from stream head metadata
        let perStreamCursors =
                Map.mapWithKey
                    (\_ (_lastEventId, lastSeqNo) -> SQLCursor txXid8 lastSeqNo)
                    streamHeadMetadata

        -- Return final cursor and updated streams
        pure
            InsertedEvents
                { finalCursor =
                    SQLCursor
                        { transactionXid8 = txXid8
                        , sequenceNo = fromIntegral totalEventCount - 1
                        }
                , streamCursors = perStreamCursors
                , insertedStreamIds = Map.keys eventBatches
                , eventIds = eventIds
                , createdAt = createdAt
                , streamVersions = streamVersionMap
                }
  where
    totalEventCount = sum $ map (length . (.events)) $ Map.elems eventBatches

    -- Process all events in unified manner: database insertion AND sync projections
    -- Returns the stream head metadata mapping (streamId -> (lastEventId, lastSeqNo))
    processEventsWithUnifiedMetadata ::
        SyncProjectionRegistry ->
        Maybe CorrelationId ->
        [UUID] ->
        UTCTime ->
        Map StreamId [StreamVersion] ->
        Int64 ->
        Map StreamId (StreamWrite t SomeLatestEvent SQLStore) ->
        HasqlTransaction.Transaction (Map StreamId (UUID, Int32))
    processEventsWithUnifiedMetadata registry corrId allEventIds createdAtTime streamVersionMap txNo batches = do
        let streamList = Map.toList batches
        -- Process each stream, distributing event IDs and tracking sequence numbers
        -- Track per-stream last event metadata (eventId, seqNo) for stream heads
        (finalSeqNoOffset, _, streamHeadMetadata) <- foldM processStream (0, allEventIds, Map.empty) streamList

        -- Update sync projection state once for all projections with the final cursor
        let SyncProjectionRegistry projMap = registry
            finalCursor = SQLCursor txNo (finalSeqNoOffset - 1) -- Final seq is last event's position
        forM_ (Map.keys projMap) $ \projId ->
            updateSyncProjectionState projId finalCursor

        -- Update stream heads with correct per-stream values
        updateStreamHeadsFromVersionMap streamVersionMap streamHeadMetadata txNo

        -- Return stream head metadata for per-stream cursor computation
        pure streamHeadMetadata
      where
        processStream (seqNoOffset, remainingIds, headMetadata) (streamId, batch) = do
            let events = Foldable.toList batch.events
                numEvents = length events
                (streamEventIds, leftoverIds) = splitAt numEvents remainingIds
                streamVersions = Map.findWithDefault [] streamId streamVersionMap

            -- Process each event in this stream
            forM_ (zip3 events streamEventIds streamVersions `zip` [0 :: Int32 ..]) $
                \((event, eventId, streamVer), idx) -> do
                    let seqNo = seqNoOffset + idx
                        cursor = SQLCursor txNo seqNo

                    -- Process with unified metadata (database insert + sync projections)
                    processEventWithUnifiedMetadata eventId streamId cursor corrId createdAtTime streamVer event

            -- Update sync projection state for all registered projections
            let SyncProjectionRegistry projMap = registry
                finalSeqNo = seqNoOffset + fromIntegral numEvents - 1
                finalCursor = SQLCursor txNo finalSeqNo
            forM_ (Map.keys projMap) $ \projId ->
                updateSyncProjectionState projId finalCursor

            -- Capture last event metadata for this stream (for stream head update)
            -- Only update metadata if there are events in this stream
            let updatedMetadata = case streamEventIds of
                    [] -> headMetadata -- No events, don't update
                    _ ->
                        let lastEventId = Prelude.last streamEventIds -- Last event ID for THIS stream
                            lastSeqNo = seqNoOffset + fromIntegral numEvents - 1
                         in Map.insert streamId (lastEventId, lastSeqNo) headMetadata

            pure (seqNoOffset + fromIntegral numEvents, leftoverIds, updatedMetadata)

        -- Create envelope and execute both database insertion and sync projections
        -- Ensures identical metadata for both database insertion and projection execution
        processEventWithUnifiedMetadata :: UUID -> StreamId -> SQLCursor -> Maybe CorrelationId -> UTCTime -> StreamVersion -> SomeLatestEvent -> HasqlTransaction.Transaction ()
        processEventWithUnifiedMetadata eventId streamId cursor corrId' timestamp streamVer (SomeLatestEvent (eventProxy :: Proxy event) payload) = do
            let envelope =
                    EventWithMetadata
                        { position = cursor
                        , eventId = EventId eventId
                        , streamId = streamId
                        , streamVersion = streamVer
                        , correlationId = corrId'
                        , createdAt = timestamp
                        , payload = payload
                        }

            -- Database insertion using the envelope
            insertSingleEventFromEnvelope envelope streamVer eventProxy payload

            -- Sync projection using the SAME envelope
            executeSyncProjectionForEvent registry eventProxy envelope

        insertSingleEventFromEnvelope envelope streamVer (proxy :: Proxy event) payload = do
            let SQLCursor cursorTxNo cursorSeqNo = envelope.position
                EventId eventId = envelope.eventId
                name = getEventName event
                ver = getMaxVersion proxy
            HasqlTransaction.statement
                ( cursorTxNo
                , cursorSeqNo
                , EventId eventId
                , envelope.streamId
                , (.toUUID) <$> envelope.correlationId
                , envelope.createdAt
                , name
                , fromIntegral ver
                , toJSON payload
                , streamVer
                )
                insertEventStatement

        updateStreamHeadsFromVersionMap versionMap headMetadata txNo' = do
            forM_ (Map.toList versionMap) $ \(streamId, versions) -> do
                case reverse versions of -- Get the last (highest) version
                    [] -> pure ()
                    (finalVersion : _) -> do
                        -- Look up the actual last event ID and sequence number for THIS stream
                        case Map.lookup streamId headMetadata of
                            Nothing -> pure () -- Stream has no events, skip
                            Just (lastEventId, lastSeqNo) ->
                                HasqlTransaction.statement
                                    (streamId, txNo', lastSeqNo, EventId lastEventId, finalVersion)
                                    updateStreamHeadStatement
