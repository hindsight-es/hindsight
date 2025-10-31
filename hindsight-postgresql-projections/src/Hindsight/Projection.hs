{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}

{- |
Module      : Hindsight.Projection
Description : Backend-agnostic projection system for building read models
Copyright   : (c) 2025
License     : BSD3
Maintainer  : gael@hindsight.events
Stability   : experimental

This module provides the projection system for transforming event streams into
queryable read models using PostgreSQL.

= Overview

Projections subscribe to events from ANY backend (Memory, Filesystem, or PostgreSQL)
and execute handlers within PostgreSQL transactions. State is persisted in the
@projections@ table, enabling:

* Automatic resumption after restarts
* Progress tracking via cursors
* LISTEN\/NOTIFY for efficient waiting

= Backend-Agnostic Design

The key insight: projection execution and state are ALWAYS in PostgreSQL, but
events can come from any storage backend:

@
-- Events from MemoryStore, projections in PostgreSQL
runProjection projId pool Nothing memoryStore handlers

-- Events from PostgreSQL, projections in PostgreSQL
runProjection projId pool Nothing sqlStore handlers
@

This enables testing with fast in-memory events while validating real SQL projection logic.

= Asynchronous Projections (This Module)

Projections run in a separate thread and process events asynchronously:

* Eventually consistent (small delay between insert and projection update)
* Work with ANY event store backend
* Failures don't block event insertion

For synchronous projections (PostgreSQL-only), see "Hindsight.Store.PostgreSQL".

= Example: User Directory Projection

@
import Hindsight.Projection
import Hindsight.Projection.Matching (ProjectionHandlers(..))
import Hindsight.Store (match)

-- Define handler
userProjection :: ProjectionHandlers '[\"user_registered\"] backend
userProjection =
  match \"user_registered\" handleUser :-> ProjectionEnd
  where
    handleUser envelope = do
      let user = envelope.payload
      Transaction.statement (user.userId, user.email)
        [resultlessStatement|
          INSERT INTO users (id, email) VALUES (\$1 :: uuid, \$2 :: text)
        |]

-- Run projection
main = do
  pool <- createPool postgresSettings
  store <- newMemoryStore  -- Or any backend
  runProjection (ProjectionId \"users\") pool Nothing store userProjection
@

= Waiting for Projection Progress

Use 'waitForEvent' to synchronize with projection progress:

@
result <- insertEvents store Nothing batch
case result of
  SuccessfulInsertion cursor -> do
    -- Wait for projection to catch up
    bracket
      (Connection.acquire settings)
      Connection.release
      (waitForEvent projId cursor.finalCursor)
@

This uses PostgreSQL LISTEN\/NOTIFY for efficient waiting without polling.

= Projection State Management

Projection state is tracked in the @projections@ table with:

* @id@ - Unique projection identifier
* @last_updated@ - Timestamp of last event processed
* @head_position@ - Cursor position of last processed event (JSON)
* @is_active@ - Whether projection is currently running

The 'loadProjectionState' function reads this state, and handlers automatically
update it after each successful event.
-}
module Hindsight.Projection (
    -- * Projection types
    ProjectionId (..),
    ProjectionState (..),
    ProjectionStateError (..),

    -- * Projection results and errors
    ProjectionResult (..),
    ProjectionError (..),

    -- * Running projections
    runProjection,
    loadProjectionState,

    -- * Waiting for events
    waitForEvent,
)
where

import Control.Concurrent (forkIO, killThread)
import Control.Concurrent.MVar (newEmptyMVar, putMVar, takeMVar)
import Control.Exception (Exception, SomeException, bracket, bracket_, throwIO)
import Control.Monad (when)
import Control.Monad.IO.Class (liftIO)
import Data.Aeson (FromJSON, ToJSON, (.:))
import Data.Aeson qualified as Aeson
import Data.ByteString.Char8 qualified as ByteString
import Data.Function ((&))
import Data.Profunctor (dimap)
import Data.Text (Text, pack)
import Data.Text.Encoding qualified as Data.Text
import Data.Time (UTCTime, getCurrentTime)
import GHC.Generics (Generic)
import Hasql.Connection (Connection)
import Hasql.Notifications qualified as Notifications
import Hasql.Pool (Pool)
import Hasql.Pool qualified as Pool
import Hasql.Session (Session)
import Hasql.Session qualified as Session
import Hasql.Statement (Statement)
import Hasql.TH (maybeStatement)
import Hasql.Transaction qualified as Transaction
import Hasql.Transaction.Sessions qualified as Session
import Hindsight.Projection.Matching (ProjectionHandler, ProjectionHandlers (..))
import Hindsight.Projection.State qualified as ProjectionState
import Hindsight.Store (
    BackendHandle,
    Cursor,
    EventEnvelope (position),
    EventHandler,
    EventMatcher (..),
    EventSelector (EventSelector, startupPosition, streamId),
    EventStore (StoreConstraints, subscribe),
    StartupPosition (FromBeginning, FromPosition),
    StreamSelector (AllStreams),
    SubscriptionResult (Continue, Stop),
 )
import UnliftIO (MonadUnliftIO (..))
import UnliftIO.STM (TVar, atomically, writeTVar)

--------------------------------------------------------------------------------
-- Projection types
--------------------------------------------------------------------------------

newtype ProjectionId = ProjectionId
    {unProjectionId :: Text}
    deriving (Show, Eq, Ord)

--------------------------------------------------------------------------------
-- Projection results and errors
--------------------------------------------------------------------------------

-- | Result of projection execution
data ProjectionResult
    = ProjectionSuccess
    | -- | Handler didn't match the event
      ProjectionSkipped
    | ProjectionError ProjectionError
    deriving (Show, Eq)

-- | Types of projection errors
data ProjectionError
    = ParseError Text
    | HandlerError SomeException
    | BackendError Text
    deriving (Show)

{- | Manual Eq instance for ProjectionError

SomeException doesn't have an Eq instance, so we compare based on the string representation
-}
instance Eq ProjectionError where
    (ParseError t1) == (ParseError t2) = t1 == t2
    (HandlerError e1) == (HandlerError e2) = show e1 == show e2
    (BackendError t1) == (BackendError t2) = t1 == t2
    _ == _ = False

-- | State of a running projection tracked in PostgreSQL.
data ProjectionState backend = ProjectionState
    { projectionId :: ProjectionId
    -- ^ Unique identifier for this projection
    , lastProcessed :: Cursor backend
    -- ^ Last event cursor successfully processed
    , lastUpdated :: UTCTime
    -- ^ Timestamp of last state update
    }

data ProjectionStateError = ProjectionStateError
    {errorMessage :: Text}
    deriving (Show, Eq, Generic, FromJSON, ToJSON)

instance Exception ProjectionStateError

--------------------------------------------------------------------------------
-- Main projection runner
--------------------------------------------------------------------------------

{- | Run a projection continuously, processing events and maintaining state in PostgreSQL.

The projection subscribes to events from the provided backend and executes handlers
within PostgreSQL transactions. State is persisted after each successful event processing.
-}
runProjection ::
    forall backend m ts.
    ( EventStore backend
    , MonadFail m
    , FromJSON (Cursor backend)
    , ToJSON (Cursor backend)
    , StoreConstraints backend m
    , MonadUnliftIO m
    ) =>
    -- | Unique identifier for this projection
    ProjectionId ->
    -- | PostgreSQL connection pool for state management
    Pool ->
    -- | Optional TVar for exposing state to other threads
    Maybe (TVar (Maybe (ProjectionState backend))) ->
    -- | Event store backend to subscribe to
    BackendHandle backend ->
    -- | Handlers for processing events
    ProjectionHandlers ts backend ->
    -- | Returns when subscription ends
    m ()
runProjection projId pool mbTVar store handlers = do
    -- Load projection state
    mbLastState <- loadProjectionState projId pool

    -- Update TVar if provided
    case (mbTVar, mbLastState) of
        (Just tvar, Just state) ->
            liftIO $ atomically $ writeTVar tvar (Just state)
        _ -> pure ()

    -- Start subscription

    _ <-
        subscribe
            store
            (makeEventMatcher projId pool mbTVar handlers)
            EventSelector
                { streamId = AllStreams
                , startupPosition = maybe FromBeginning FromPosition (fmap (.lastProcessed) mbLastState)
                }

    pure ()

{- | Load the current state of a projection from PostgreSQL.

Returns Nothing if the projection has never been run, or throws ProjectionStateError
if there's a database or JSON parsing error.
-}
loadProjectionState ::
    (MonadUnliftIO m, MonadFail m, FromJSON (Cursor backend)) =>
    -- | Projection identifier
    ProjectionId ->
    -- | PostgreSQL connection pool
    Pool ->
    -- | Current state, or Nothing if never run
    m (Maybe (ProjectionState backend))
loadProjectionState projId pool = do
    result <- liftIO $ Pool.use pool $ getProjectionState projId
    case result of
        Left err -> do
            -- Database error - propagate it with context
            liftIO $
                throwIO $
                    ProjectionStateError $
                        "Failed to query projection state for " <> (pack $ show projId) <> ": " <> (pack $ show err)
        Right mbStateResult -> case mbStateResult of
            Nothing -> pure Nothing -- Table exists, but no row for this projection
            Just (Left err) -> liftIO $ throwIO err -- JSON parsing error
            Just (Right state) -> pure $ Just state -- Successfully loaded state

--------------------------------------------------------------------------------
-- Event matcher
--------------------------------------------------------------------------------

makeEventMatcher ::
    forall ts backend m.
    (MonadUnliftIO m, ToJSON (Cursor backend)) =>
    ProjectionId ->
    Pool ->
    Maybe (TVar (Maybe (ProjectionState backend))) ->
    ProjectionHandlers ts backend ->
    EventMatcher ts backend m
makeEventMatcher projId pool mbTVar = go
  where
    go :: ProjectionHandlers ts' backend -> EventMatcher ts' backend m
    go ProjectionEnd = MatchEnd
    go ((proxy, handler) :-> rest) =
        (proxy, handleEvent handler) :? go rest

    handleEvent ::
        forall event.
        ProjectionHandler event backend ->
        EventHandler event m backend
    handleEvent projHandler envelope = do
        now <- liftIO getCurrentTime
        let state =
                ProjectionState
                    { projectionId = projId
                    , lastProcessed = envelope.position
                    , lastUpdated = now
                    }

        -- Run projection logic in transaction
        result <- liftIO $
            Pool.use pool $
                Session.transaction Session.ReadCommitted Session.Write $ do
                    projHandler envelope
                    Transaction.statement state (updateProjectionStatement)

        case result of
            Left _err -> do
                pure Stop
            Right _ -> do
                case mbTVar of
                    Nothing -> pure ()
                    Just tvar -> liftIO $ atomically $ writeTVar tvar (Just state)
                pure Continue

-- Rest of the module remains largely unchanged, including:
-- - Schema setup
-- - Database operations
-- - Notification handling
-- These parts don't need tracing modifications as they're either
-- infrastructure setup or already properly scoped operations

--------------------------------------------------------------------------------
-- Fetching/updating projection state
--------------------------------------------------------------------------------

getProjectionState ::
    (FromJSON (Cursor backend)) =>
    ProjectionId ->
    Session (Maybe (Either ProjectionStateError (ProjectionState backend)))
getProjectionState (ProjectionId pid) =
    Session.statement
        pid
        [maybeStatement|
            select 
                id :: text,
                last_updated :: timestamptz,
                head_position :: jsonb?
            from projections
            where id = $1 :: text
        |]
        & fmap transform
  where
    transform res =
        case res of
            Nothing -> Nothing
            Just (id', updated, mbCursorJson) ->
                case mbCursorJson of
                    Nothing -> Nothing -- Never processed
                    Just cursorJson ->
                        case Aeson.fromJSON cursorJson of
                            Aeson.Success cursor ->
                                Just $
                                    Right $
                                        ProjectionState
                                            { projectionId = ProjectionId id'
                                            , lastProcessed = cursor
                                            , lastUpdated = updated
                                            }
                            Aeson.Error err ->
                                Just $
                                    Left $
                                        ProjectionStateError $
                                            "Could not parse projection state cursor: " <> pack err

updateProjectionStatement ::
    (ToJSON (Cursor backend)) =>
    Statement (ProjectionState backend) ()
updateProjectionStatement =
    ProjectionState.upsertProjectionCursor
        & dimap
            (\(ProjectionState (ProjectionId pid) cursor _ts) -> (pid, Aeson.toJSON cursor))
            id

--------------------------------------------------------------------------------
-- Waiting on events
--------------------------------------------------------------------------------

{- | Wait for a projection to process up to (or past) a specific cursor position.

This function uses PostgreSQL LISTEN/NOTIFY to efficiently wait for projection
progress without polling. It returns once the projection has processed the target
cursor or throws an error if the projection state cannot be read.
-}
waitForEvent ::
    forall backend m.
    ( Ord (Cursor backend)
    , MonadUnliftIO m
    , FromJSON (Cursor backend)
    ) =>
    -- | Projection to monitor
    ProjectionId ->
    -- | Target cursor position to wait for
    Cursor backend ->
    -- | PostgreSQL connection for LISTEN/NOTIFY
    Connection ->
    -- | Returns when target cursor reached or throws on error
    m ()
waitForEvent projectionId@(ProjectionId projId) targetCursor conn = do
    let pgId = Notifications.toPgIdentifier projId
    liftIO $
        bracket_
            (Notifications.listen conn pgId)
            (Notifications.unlisten conn pgId)
            ( do
                result <- Session.run (getProjectionState projectionId) conn
                case result of
                    Right (Just (Right currState))
                        | currState.lastProcessed >= targetCursor ->
                            pure ()
                    Right Nothing ->
                        waitForNotifications
                    Right (Just (Right _)) ->
                        waitForNotifications
                    Right (Just (Left err)) ->
                        throwIO err
                    Left err ->
                        throwIO err
            )
  where
    waitForNotifications = do
        completionVar <- newEmptyMVar
        bracket
            ( forkIO $ flip Notifications.waitForNotifications conn $ \channel notifPayload -> do
                when (Data.Text.decodeASCII channel == projId) $ do
                    case Aeson.decode @(NotificationPayload backend) $ ByteString.fromStrict notifPayload of
                        Nothing ->
                            throwIO $
                                ProjectionStateError $
                                    "Could not decode notification payload: "
                                        <> Data.Text.pack (show $ ByteString.unpack notifPayload)
                        Just payload ->
                            when (payload.headPosition >= targetCursor) $
                                putMVar completionVar ()
            )
            killThread
            (\_ -> takeMVar completionVar)

-- | Payload sent via PostgreSQL NOTIFY when projection state updates.
data NotificationPayload backend = NotificationPayload
    { headPosition :: Cursor backend
    -- ^ Latest cursor position processed by projection
    , lastUpdated :: UTCTime
    -- ^ Timestamp of the state update
    }
    deriving (Generic)

deriving instance (Show (Cursor backend)) => Show (NotificationPayload backend)

deriving instance (Eq (Cursor backend)) => Eq (NotificationPayload backend)

instance (FromJSON (Cursor backend)) => FromJSON (NotificationPayload backend) where
    parseJSON = Aeson.withObject "NotificationPayload" $ \obj -> do
        headPosition <- obj .: "head_position"
        lastUpdated <- obj .: "last_updated"
        pure NotificationPayload{..}
