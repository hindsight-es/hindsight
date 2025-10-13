{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

{-|
Module      : Hindsight.Store.PostgreSQL
Description : PostgreSQL-backed event store
Copyright   : (c) 2024
License     : BSD3
Maintainer  : maintainer@example.com
Stability   : experimental

PostgreSQL backend with ACID guarantees and support for sync/async projections.

Sync projections execute within the event insertion transaction and track
their state in the 'projections' table. On startup, projections catch up
from their last processed position.
-}
module Hindsight.Store.PostgreSQL
  ( newSQLStore,
    newSQLStoreWithProjections,
    shutdownSQLStore,
    SQLStoreHandle,
    getPool,
    getConnectionString,
    SQLStore,
    SQLCursor(..),
    SyncProjectionRegistry,
    emptySyncProjectionRegistry,
    registerSyncProjection,
    insertEventsWithSyncProjections,
    createSQLSchema,
    module Hindsight.Store,
  )
where

import Control.Exception (SomeException (..), throwIO)
import Control.Monad.IO.Class (MonadIO (liftIO))
import Data.ByteString (ByteString)
import Data.Map (Map)
import Data.Text (Text, pack)
import Data.Text qualified
import Data.Text.Encoding (decodeUtf8)
import Hasql.Connection.Setting qualified as ConnectionSetting
import Hasql.Connection.Setting.Connection qualified as ConnectionSettingConnection
import Hasql.Pool (Pool)
import Hasql.Pool qualified as Pool
import Hasql.Pool.Config qualified as Config
import Hasql.Transaction.Sessions qualified as Session
import Hindsight.Core (SomeLatestEvent)
import Hindsight.Store
import Hindsight.Store.PostgreSQL.Events.Insertion qualified as Insertion
import Hindsight.Store.PostgreSQL.Core.Types (SQLStore, SQLStoreHandle (..), SQLCursor(..), SyncProjectionRegistry)
import Hindsight.Store.PostgreSQL.Core.Schema (createSchema)
import Hasql.Session (Session)
import Hindsight.Store.PostgreSQL.Events.Subscription qualified as Subscription
import Hindsight.Store.PostgreSQL.Projections.Sync (emptySyncProjectionRegistry, registerSyncProjection, catchUpSyncProjections, CatchUpError (..))
import Hindsight.Store.PostgreSQL.Events.Concurrency (checkVersions)
import Hindsight.Projection (ProjectionId (..))
import UnliftIO (MonadUnliftIO)
import qualified Hasql.Transaction.Sessions as Session

-- | Re-export createSchema with a more specific name to avoid conflicts
createSQLSchema :: Session ()
createSQLSchema = createSchema

-- | Get the connection pool from a store handle.
--
-- Useful for running custom queries or projections that need direct database access.
getPool :: SQLStoreHandle -> Pool
getPool = (.pool)

-- | Get the connection string from a store handle.
--
-- Useful for creating additional store instances with the same configuration.
getConnectionString :: SQLStoreHandle -> ByteString
getConnectionString = (.connectionString)

-- | Create a PostgreSQL event store with default configuration.
--
-- Uses a connection pool size of 10 and an empty sync projection registry.
newSQLStore :: ByteString -> IO SQLStoreHandle
newSQLStore connectionString = newSQLStoreWithProjections connectionString emptySyncProjectionRegistry

-- | Create a PostgreSQL event store with custom sync projections.
--
-- Sync projections run within the same transaction as event insertion,
-- providing guaranteed consistency between events and their projections.
-- 
-- On startup, this function will:
-- 1. Register all sync projections in the database
-- 2. Catch up any projections that are behind
-- 3. Fail with an exception if catch-up fails
newSQLStoreWithProjections :: ByteString -> SyncProjectionRegistry -> IO SQLStoreHandle
newSQLStoreWithProjections connectionString syncProjRegistry = do
  let connectionSettings = [ConnectionSetting.connection $ ConnectionSettingConnection.string (decodeUtf8 connectionString)]
      hasqlConfig = Config.settings [Config.size 300, Config.staticConnectionSettings connectionSettings]
  pool <- Pool.acquire hasqlConfig
  
  -- Run catch-up for sync projections
  catchUpResult <- catchUpSyncProjections pool syncProjRegistry
  
  case catchUpResult of
    Left err -> do
      let errorMsg = case err of
            ProjectionExecutionError projId msg -> 
              pack "Sync projection catch-up failed for " <> unProjectionId projId <> pack ": " <> msg
            DatabaseError msg -> 
              pack "Database error during sync projection catch-up: " <> msg
            NoActiveProjections -> 
              pack "No active sync projections found in database"
      throwIO $ userError $ Data.Text.unpack errorMsg
    Right () -> do
      -- Create centralized notifier for efficient resource use
      notifier <- Subscription.startNotifier connectionString
      
      -- Create store handle with notifier
      pure $ SQLStoreHandle pool connectionString syncProjRegistry notifier

-- | PostgreSQL 'EventStore' instance.
-- 
-- This instance automatically uses the sync projections configured in the handle.
-- All insertEvents calls will execute the sync projections that were registered
-- when the store was created.
instance EventStore SQLStore where
  type StoreConstraints SQLStore m = MonadUnliftIO m

  -- | Insert events using the sync projection infrastructure.
  -- 
  -- This function automatically uses the sync projection registry from the handle,
  -- ensuring any registered sync projections are executed during insertion.
  insertEvents ::
    (Traversable t, MonadUnliftIO m) =>
    BackendHandle SQLStore ->
    Maybe CorrelationId ->
    Map StreamId (StreamEventBatch t SomeLatestEvent SQLStore) ->
    m (InsertionResult SQLStore)
  insertEvents handle corrId batches =
    insertEventsWithSyncProjections handle handle.syncProjectionRegistry corrId batches

  subscribe handle matcher selector = Subscription.subscribe handle matcher selector

-- | Insert events with synchronous projections using a custom registry.
--
-- Events and projections are committed atomically in a single PostgreSQL
-- transaction. If any projection fails, the entire transaction is rolled
-- back, ensuring consistency.
--
-- This function allows you to override the sync projection registry from
-- the handle. In most cases, you should use the generic 'insertEvents'
-- function instead, which automatically uses the registry from the handle.
--
-- This function is useful for testing or scenarios where you need to use
-- a different registry than the one configured in the handle.
insertEventsWithSyncProjections ::
  (Traversable t, MonadUnliftIO m) =>
  SQLStoreHandle ->
  SyncProjectionRegistry ->
  Maybe CorrelationId ->
  Map StreamId (StreamEventBatch t SomeLatestEvent SQLStore) ->
  m (InsertionResult SQLStore)
insertEventsWithSyncProjections handle syncRegistry corrId batches = liftIO $ do
  -- Create transaction that will insert events and run sync projections
  tx <- Insertion.insertEventsWithSyncProjections syncRegistry corrId batches

  -- Execute transaction with proper error handling
  result <- Pool.use handle.pool $ Session.transaction Session.Serializable Session.Write $ do
    -- First check version constraints
    mbError <- checkVersions batches
    case mbError of
      Just err -> pure $ Left $ ConsistencyError err
      Nothing -> do
        -- Then insert events (and run projections if applicable)
        Right <$> tx

  -- Convert result to InsertionResult
  case result of
    -- Handle database errors
    Left dbError ->
      pure $
        FailedInsertion $
          BackendError $
            ErrorInfo
              { errorMessage = pack "Database error: " <> tshow dbError,
                exception = Just $ SomeException dbError
              }
    -- Handle business errors
    Right (Left err) ->
      pure $ FailedInsertion err
    -- Handle success
    Right (Right insertedEvents) ->
      let cursor = Insertion.finalCursor insertedEvents
       in pure $ SuccessfulInsertion cursor

-- | Shutdown the SQL store gracefully
--
-- This function should be called before releasing the connection pool.
-- It shuts down the event dispatcher used by all subscriptions.
shutdownSQLStore :: SQLStoreHandle -> IO ()
shutdownSQLStore handle = do
  -- Shutdown the notifier
  Subscription.shutdownNotifier handle.notifier


-- | Convert showable values to 'Text'.
tshow :: (Show a) => a -> Text
tshow = pack . show