{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -Wno-orphans #-}

{- |
Module      : Hindsight.Store.PostgreSQL.Projections.Sync
Description : PostgreSQL synchronous projection system
Copyright   : (c) 2024
License     : BSD3
Maintainer  : maintainer@example.com
Stability   : experimental

This module provides a complete synchronous projection system for PostgreSQL,
including registry management, event processing, catch-up functionality, and
transaction-based execution. It merges functionality from the original
SyncProjection, SyncProjectionCatchUp, and Projection.Sync modules.
-}
module Hindsight.Store.PostgreSQL.Projections.Sync (
    -- * Registry Management
    SyncProjectionRegistry,
    emptySyncProjectionRegistry,
    registerSyncProjection,

    -- * Event Processing
    executeSyncProjectionForEvent,

    -- * Catch-up Functionality
    catchUpSyncProjections,
    CatchUpError (..),

    -- * PostgreSQL-Specific Projection Functions
    matchEventHandlers,
    executeHandlerChain,
    handleProjectionError,
)
where

import Control.Exception (Exception)
import Control.Monad (forM, forM_)
import Data.Aeson qualified as Aeson
import Data.Int (Int32, Int64)
import Data.Map qualified as Map
import Data.Proxy (Proxy (..))
import Data.Text (Text, pack)
import Data.Time (UTCTime)
import Data.Typeable (Typeable)
import Data.UUID (UUID)
import Data.Vector qualified as Vector
import Hasql.Pool (Pool)
import Hasql.Pool qualified as Pool
import Hasql.Statement (Statement)
import Hasql.TH
import Hasql.Transaction qualified as HasqlTransaction
import Hasql.Transaction.Sessions qualified as TransactionSession
import Hindsight.Events (Event)
import Hindsight.Projection (ProjectionError (..), ProjectionId (..), ProjectionResult (..))
import Hindsight.Projection.Matching (ProjectionHandler, ProjectionHandlers (..), SomeProjectionHandler (..), extractMatchingHandlers, handlersForEventName)
import Hindsight.Store (CorrelationId (..), EventEnvelope (..), EventId (..), StreamId (..), StreamVersion (..))
import Hindsight.Store.Parsing (parseStoredEventToEnvelope)
import Hindsight.Store.PostgreSQL.Core.Types (SQLCursor (..), SQLStore, SomeProjectionHandlers (..), SyncProjectionRegistry (..))
import Hindsight.Store.PostgreSQL.Projections.State (
    SyncProjectionState (..),
    getActiveProjections,
    registerSyncProjectionInDb,
    updateSyncProjectionState,
 )

-- | Errors that can occur during catch-up
data CatchUpError
    = ProjectionExecutionError ProjectionId Text
    | DatabaseError Text
    | NoActiveProjections
    deriving (Show, Eq, Typeable)

instance Exception CatchUpError

-- | Stored event data from database
data StoredEvent = StoredEvent
    { transactionXid8 :: Int64
    , seqNo :: Int32
    , streamId :: StreamId
    , eventId :: EventId
    , createdAt :: UTCTime
    , correlationId :: Maybe UUID
    , eventName :: Text
    , eventVersion :: Int32
    , payload :: Aeson.Value
    , streamVersion :: Int64
    }

-- =============================================================================
-- PostgreSQL-Specific Projection Functions
-- =============================================================================

{- | Type-safe handler matching using unified logic

Uses the common handler matching logic from Hindsight.Projection.Matching
-}
matchEventHandlers ::
    forall event ts backend.
    (Event event) =>
    ProjectionHandlers ts backend ->
    Proxy event ->
    [ProjectionHandler event backend]
matchEventHandlers = extractMatchingHandlers

{- | Execute a chain of handlers for an event (PostgreSQL Transaction context)

This processes handlers in sequence, collecting results.
Unlike the generic version, this is specialized for PostgreSQL transactions.
-}
executeHandlerChain ::
    forall event backend.
    (Event event) =>
    [ProjectionHandler event backend] ->
    EventEnvelope event backend ->
    HasqlTransaction.Transaction [ProjectionResult]
executeHandlerChain [] _ = pure []
executeHandlerChain (handler : rest) envelope = do
    -- Execute the handler directly - exceptions will naturally propagate up
    -- and cause the transaction to be rolled back by the higher level code
    result <- do
        handler envelope
        pure ProjectionSuccess
    results <- executeHandlerChain rest envelope
    pure (result : results)

-- | Handle projection errors in PostgreSQL Transaction context
handleProjectionError :: ProjectionError -> HasqlTransaction.Transaction ProjectionResult
handleProjectionError err = do
    -- In sync projections, errors should propagate to roll back the transaction
    HasqlTransaction.condemn
    pure (ProjectionError err)

-- =============================================================================
-- Registry Management
-- =============================================================================

-- | Create an empty registry
emptySyncProjectionRegistry :: SyncProjectionRegistry
emptySyncProjectionRegistry = SyncProjectionRegistry Map.empty

-- | Register a synchronous projection
registerSyncProjection ::
    ProjectionId ->
    ProjectionHandlers ts SQLStore ->
    SyncProjectionRegistry ->
    SyncProjectionRegistry
registerSyncProjection projId handlers (SyncProjectionRegistry reg) =
    let newReg = Map.insert projId (SomeProjectionHandlers handlers) reg
     in SyncProjectionRegistry newReg

-- =============================================================================
-- Event Processing
-- =============================================================================

-- | Execute all registered synchronous projections for a single event
executeSyncProjectionForEvent ::
    forall event.
    (Event event) =>
    SyncProjectionRegistry ->
    Proxy event ->
    EventEnvelope event SQLStore ->
    HasqlTransaction.Transaction ()
executeSyncProjectionForEvent (SyncProjectionRegistry reg) eventProxy envelope = do
    forM_ (Map.elems reg) $ \(SomeProjectionHandlers handlers) ->
        processHandlersWithCommonLogic handlers eventProxy envelope

-- | Process a set of handlers for a specific event
processHandlersWithCommonLogic ::
    forall event ts.
    (Event event) =>
    ProjectionHandlers ts SQLStore ->
    Proxy event ->
    EventEnvelope event SQLStore ->
    HasqlTransaction.Transaction ()
processHandlersWithCommonLogic handlers eventProxy envelope = do
    -- Use the common handler matching logic
    let matchingHandlers = matchEventHandlers handlers eventProxy

    -- Execute all matching handlers using the common execution logic
    results <- executeHandlerChain matchingHandlers envelope

    -- Handle any errors (will condemn the transaction)
    sequence_ [handleProjectionError err | ProjectionError err <- results]

-- =============================================================================
-- Catch-up Functionality
-- =============================================================================

-- | Catch up all sync projections to the latest events
catchUpSyncProjections ::
    Pool ->
    SyncProjectionRegistry ->
    IO (Either CatchUpError ())
catchUpSyncProjections pool registry@(SyncProjectionRegistry regMap) = do
    if Map.null regMap
        then pure (Right ()) -- No projections to catch up
        else do
            result <-
                Pool.use pool $
                    TransactionSession.transaction
                        TransactionSession.ReadCommitted
                        TransactionSession.Write
                        (catchUpTransaction registry)

            case result of
                Left err -> pure $ Left $ DatabaseError $ pack $ show err
                Right res -> pure res

-- | Internal transaction for catching up projections
catchUpTransaction :: SyncProjectionRegistry -> HasqlTransaction.Transaction (Either CatchUpError ())
catchUpTransaction registry@(SyncProjectionRegistry regMap) = do
    -- Register all projections in the database
    forM_ (Map.keys regMap) $ \projId ->
        registerSyncProjectionInDb projId

    -- Get active projections
    activeProjections <- getActiveProjections

    if null activeProjections
        then do
            -- If there are registered projections but none are active in DB,
            -- we need to process all of them from the beginning
            let allProjections = Map.keys regMap
            results <- forM allProjections $ \projId ->
                catchUpProjection registry projId (SQLCursor 0 0)

            -- Check if any failed
            let errors = [err | Left err <- results]
            if null errors
                then pure $ Right ()
                else case errors of
                    (err : _) -> pure $ Left err
                    [] -> pure $ Right ()
        else do
            -- Process each active projection
            results <- forM activeProjections $ \projState -> do
                let cursor =
                        SQLCursor
                            projState.lastProcessedTransactionXid8
                            projState.lastProcessedSeqNo
                catchUpProjection registry projState.projectionId cursor

            -- Check if any failed
            let errors = [err | Left err <- results]
            if null errors
                then pure $ Right ()
                else case errors of
                    (err : _) -> pure $ Left err
                    [] -> pure $ Right ()

-- | Catch up a single projection
catchUpProjection ::
    SyncProjectionRegistry ->
    ProjectionId ->
    SQLCursor ->
    HasqlTransaction.Transaction (Either CatchUpError ())
catchUpProjection (SyncProjectionRegistry regMap) projId cursor = do
    -- Check if this projection is actually registered
    case Map.lookup projId regMap of
        Nothing -> pure $ Right () -- Skip unregistered projections
        Just (SomeProjectionHandlers handlers) -> do
            -- Get unprocessed events
            events <- getUnprocessedEvents cursor

            -- Process each event
            forM_ events $ \storedEvent -> do
                -- Process this event through the projection handlers
                processStoredEvent handlers storedEvent

                -- Update projection state after successful processing
                let eventCursor = SQLCursor storedEvent.transactionXid8 storedEvent.seqNo
                updateSyncProjectionState projId eventCursor

            pure $ Right ()

-- | Process a stored event through projection handlers
processStoredEvent ::
    forall ts.
    ProjectionHandlers ts SQLStore ->
    StoredEvent ->
    HasqlTransaction.Transaction ()
processStoredEvent handlers storedEvent = do
    -- Find matching handlers for the event
    let matchingHandlers = handlersForEventName storedEvent.eventName handlers

    -- Process each matching handler
    forM_ matchingHandlers $ \(SomeProjectionHandler eventProxy handler) -> do
        -- Try to parse and process the event
        case parseStoredEventToEnvelope
            eventProxy
            storedEvent.eventId
            storedEvent.streamId
            (SQLCursor storedEvent.transactionXid8 storedEvent.seqNo)
            (StreamVersion storedEvent.streamVersion)
            (CorrelationId <$> storedEvent.correlationId)
            storedEvent.createdAt
            storedEvent.payload
            (fromIntegral storedEvent.eventVersion) of
            Just envelope -> handler envelope
            Nothing -> pure () -- Skip if parsing fails

-- | Get unprocessed events from the database
getUnprocessedEvents ::
    SQLCursor ->
    HasqlTransaction.Transaction [StoredEvent]
getUnprocessedEvents (SQLCursor lastTxNo lastSeqNo) = do
    results <- HasqlTransaction.statement (lastTxNo, lastSeqNo) getEventsStmt
    pure $ map toStoredEvent $ Vector.toList results
  where
    getEventsStmt :: Statement (Int64, Int32) (Vector.Vector (Int64, Int32, UUID, UUID, UTCTime, Maybe UUID, Text, Int32, Aeson.Value, Int64))
    getEventsStmt =
        [vectorStatement|
        SELECT
          e.transaction_xid8::text::bigint :: int8,
          e.seq_no :: int4,
          e.stream_id :: uuid,
          e.event_id :: uuid,
          e.created_at :: timestamptz,
          e.correlation_id :: uuid?,
          e.event_name :: text,
          e.event_version :: int4,
          e.payload :: jsonb,
          e.stream_version :: int8
        FROM events e
        WHERE (e.transaction_xid8::text::bigint > $1 :: int8)
           OR (e.transaction_xid8::text::bigint = $1 :: int8 AND e.seq_no > $2 :: int4)
        ORDER BY e.transaction_xid8, e.seq_no
        LIMIT 1000
      |]

    toStoredEvent (txNo, seqNo, streamId, eventId, createdAt, corrId, eventName, eventVersion, payload, streamVer) =
        StoredEvent
            { transactionXid8 = txNo
            , seqNo = seqNo
            , streamId = StreamId streamId
            , eventId = EventId eventId
            , createdAt = createdAt
            , correlationId = corrId
            , eventName = eventName
            , eventVersion = eventVersion
            , payload = payload
            , streamVersion = streamVer
            }
