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

module Hindsight.Projection
  ( -- * Projection types
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
import Hasql.TH (maybeStatement, resultlessStatement)
import Hasql.Transaction qualified as Transaction
import Hasql.Transaction.Sessions qualified as Session
import Hindsight.Projection.Matching (ProjectionHandler, ProjectionHandlers (..))
import Hindsight.Store
  ( BackendHandle,
    Cursor,
    EventEnvelope (position),
    EventHandler,
    EventMatcher (..),
    EventSelector (EventSelector, startupPosition, streamId),
    EventStore (StoreConstraints, subscribe),
    StartupPosition (FromBeginning, FromLastProcessed),
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
  | ProjectionSkipped  -- ^ Handler didn't match the event
  | ProjectionError ProjectionError
  deriving (Show, Eq)

-- | Types of projection errors
data ProjectionError
  = ParseError Text
  | HandlerError SomeException
  | BackendError Text
  deriving (Show)

-- | Manual Eq instance for ProjectionError
--
-- SomeException doesn't have an Eq instance, so we compare based on the string representation
instance Eq ProjectionError where
  (ParseError t1) == (ParseError t2) = t1 == t2
  (HandlerError e1) == (HandlerError e2) = show e1 == show e2
  (BackendError t1) == (BackendError t2) = t1 == t2
  _ == _ = False

data ProjectionState backend = ProjectionState
  { projectionId :: ProjectionId,
    lastProcessed :: Cursor backend,
    lastUpdated :: UTCTime
  }

data ProjectionStateError = ProjectionStateError
  {errorMessage :: Text}
  deriving (Show, Eq, Generic, FromJSON, ToJSON)

instance Exception ProjectionStateError

--------------------------------------------------------------------------------
-- Main projection runner
--------------------------------------------------------------------------------

runProjection ::
  forall backend m ts.
  ( EventStore backend,
    MonadFail m,
    Show (Cursor backend),
    FromJSON (Cursor backend),
    ToJSON (Cursor backend),
    StoreConstraints backend m,
    MonadUnliftIO m
  ) =>
  ProjectionId ->
  Pool ->
  Maybe (TVar (Maybe (ProjectionState backend))) ->
  BackendHandle backend ->
  ProjectionHandlers ts backend ->
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
        { streamId = AllStreams,
          startupPosition = maybe FromBeginning FromLastProcessed (fmap (.lastProcessed) mbLastState)
        }

  pure ()

-- Helper to load projection state
loadProjectionState ::
  (MonadUnliftIO m, MonadFail m, FromJSON (Cursor backend)) =>
  ProjectionId ->
  Pool ->
  m (Maybe (ProjectionState backend))
loadProjectionState projId pool = do
  result <- liftIO $ Pool.use pool $ getProjectionState projId
  case result of
    Left err -> do
      -- Database error - propagate it with context
      liftIO $ throwIO $ ProjectionStateError $ 
        "Failed to query projection state for " <> (pack $ show projId) <> ": " <> (pack $ show err)
    Right mbStateResult -> case mbStateResult of
      Nothing -> pure Nothing  -- Table exists, but no row for this projection
      Just (Left err) -> liftIO $ throwIO err  -- JSON parsing error
      Just (Right state) -> pure $ Just state  -- Successfully loaded state

--------------------------------------------------------------------------------
-- Event matcher
--------------------------------------------------------------------------------

makeEventMatcher ::
  forall ts backend m.
  (MonadUnliftIO m, Show (Cursor backend), ToJSON (Cursor backend)) =>
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
              { projectionId = projId,
                lastProcessed = envelope.position,
                lastUpdated = now
              }

      -- Run projection logic in transaction
      result <- liftIO $
        Pool.use pool $
          Session.transaction Session.ReadCommitted Session.Write $ do
            projHandler envelope
            Transaction.statement state (updateProjectionStatement )

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
            Nothing -> Nothing  -- Never processed
            Just cursorJson -> 
              case Aeson.fromJSON cursorJson of
                Aeson.Success cursor ->
                  Just $
                    Right $
                      ProjectionState
                        { projectionId = ProjectionId id',
                          lastProcessed = cursor,
                          lastUpdated = updated
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
  [resultlessStatement|
        insert into projections (
            id, last_updated, head_position, is_active
        ) values (
            $1 :: text,
            $2 :: timestamptz,
            $3 :: jsonb,
            true
        )
        on conflict (id) do update set
            last_updated = excluded.last_updated,
            head_position = excluded.head_position
    |]
    & dimap
      (\(ProjectionState (ProjectionId pid) cursor ts) -> (pid, ts, Aeson.toJSON cursor))
      id

--------------------------------------------------------------------------------
-- Waiting on events
--------------------------------------------------------------------------------

waitForEvent ::
  forall backend m.
  ( Ord (Cursor backend),
    MonadUnliftIO m,
    FromJSON (Cursor backend)
  ) =>
  ProjectionId ->
  Cursor backend ->
  Connection ->
  m ()
waitForEvent projectionId@(ProjectionId projId) targetCursor conn = do
  let pgId = Notifications.toPgIdentifier projId
  liftIO $
    bracket_
      (Notifications.listen conn pgId)
      (Notifications.unlisten conn pgId)
      ( do
          result <- Session.run (getProjectionState  projectionId) conn
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

data NotificationPayload backend = NotificationPayload
  { headPosition :: Cursor backend,
    lastUpdated :: UTCTime
  }
  deriving (Generic)

deriving instance (Show (Cursor backend)) => Show (NotificationPayload backend)

deriving instance (Eq (Cursor backend)) => Eq (NotificationPayload backend)

instance (FromJSON (Cursor backend)) => FromJSON (NotificationPayload backend) where
  parseJSON = Aeson.withObject "NotificationPayload" $ \obj -> do
    headPosition <- obj .: "head_position"
    lastUpdated <- obj .: "last_updated"
    pure NotificationPayload {..}
