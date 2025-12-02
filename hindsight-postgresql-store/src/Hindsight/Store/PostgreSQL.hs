{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

{- |
Module      : Hindsight.Store.PostgreSQL
Description : PostgreSQL-backed event store with ACID guarantees
Copyright   : (c) 2025
License     : BSD3
Maintainer  : gael@hindsight.events
Stability   : experimental

= Overview

PostgreSQL-backed event store providing full ACID guarantees, scalability, and
production-ready durability. Supports both synchronous and asynchronous projections.

Recommended for production systems, distributed deployments, and applications
requiring strong consistency guarantees.

= Quick Start

@
import Hindsight.Store.PostgreSQL

main :: IO ()
main = do
  -- Create store
  let connStr = "postgresql://localhost/events"
  store <- newSQLStore connStr

  -- Initialize schema (run once)
  Pool.use (getPool store) createSQLSchema

  -- Insert events (see Hindsight.Store for details)
  streamId <- StreamId \<$\> UUID.nextRandom
  let event = mkEvent MyEvent myData
  result <- insertEvents store Nothing $ singleEvent streamId NoStream event

  -- Subscribe to events
  handle <- subscribe store matcher (EventSelector AllStreams FromBeginning)
  -- ... process events ...

  -- Cleanup when done
  shutdownSQLStore store
@

= Configuration

Connection via PostgreSQL connection string. Pool size defaults to 10 connections.

For custom configuration, use 'newSQLStoreWithProjections' to register synchronous projections
that execute within event insertion transactions.

= Use Cases

__When to use PostgreSQL store:__

* Production systems requiring durability and ACID guarantees
* Distributed multi-node deployments
* High event throughput scenarios
* Large event volumes (millions+ events)
* Applications needing advanced SQL querying
* Systems requiring synchronous projections (strong consistency)

__When NOT to use PostgreSQL store:__

* Simple testing (use Memory store)
* Single-node apps without database (use Filesystem store)
* Environments where PostgreSQL can't be deployed
* Prototypes and development (unless testing PostgreSQL-specific features)

= Trade-offs

__Advantages:__

* Full ACID guarantees (PostgreSQL transactions)
* Scales to millions of events
* Distributed multi-node support
* Advanced querying via SQL
* Synchronous projections (consistency within single transaction)
* LISTEN/NOTIFY for efficient subscriptions
* Battle-tested PostgreSQL reliability

__Limitations:__

* Requires PostgreSQL database
* More complex deployment than Memory/Filesystem
* Higher resource requirements
* Network latency for remote databases

= Sync vs Async Projections

__Synchronous Projections:__ Execute within event insertion transaction. Changes to events
and projection state are atomic. Use 'registerSyncProjection' and 'newSQLStoreWithProjections'.
Guarantees strong consistency but adds latency to writes.

__Asynchronous Projections:__ Run separately using 'runProjection' from hindsight-postgresql-projections.
Process events after they're committed. Better write performance but eventual consistency.

= Implementation

Events stored in @events@ table with compound key @(transaction_no, seq_no)@ for total ordering.
Stream metadata in @stream_heads@ table. Projection state in @projections@ table.
LISTEN/NOTIFY used for efficient subscription updates.

See 'Hindsight.Store.PostgreSQL.Core.Schema' for complete schema DDL.
-}
module Hindsight.Store.PostgreSQL (
    newSQLStore,
    newSQLStoreWithProjections,
    shutdownSQLStore,
    SQLStoreHandle,
    getPool,
    getConnectionString,
    SQLStore,
    SQLCursor (..),
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
import Data.Text (Text, pack)
import Data.Text qualified
import Data.Text.Encoding (decodeUtf8)
import Hasql.Connection.Setting qualified as ConnectionSetting
import Hasql.Connection.Setting.Connection qualified as ConnectionSettingConnection
import Hasql.Pool (Pool)
import Hasql.Pool qualified as Pool
import Hasql.Pool.Config qualified as Config
import Hasql.Session (Session)
import Hasql.Transaction.Sessions qualified as Session
import Hindsight.Projection (ProjectionId (..))
import Hindsight.Store
import Hindsight.Store.PostgreSQL.Core.Schema (createSchema)
import Hindsight.Store.PostgreSQL.Core.Types (SQLCursor (..), SQLStore, SQLStoreHandle (..), SyncProjectionRegistry)
import Hindsight.Store.PostgreSQL.Events.Concurrency (checkVersions)
import Hindsight.Store.PostgreSQL.Events.Insertion qualified as Insertion
import Hindsight.Store.PostgreSQL.Events.Subscription qualified as Subscription
import Hindsight.Store.PostgreSQL.Projections.Sync (CatchUpError (..), catchUpSyncProjections, emptySyncProjectionRegistry, registerSyncProjection)
import UnliftIO (MonadUnliftIO)

-- | Re-export createSchema with a more specific name to avoid conflicts
createSQLSchema :: Session ()
createSQLSchema = createSchema

{- | Get the connection pool from a store handle.

Useful for running custom queries or projections that need direct database access.
-}
getPool :: SQLStoreHandle -> Pool
getPool = (.pool)

{- | Get the connection string from a store handle.

Useful for creating additional store instances with the same configuration.
-}
getConnectionString :: SQLStoreHandle -> ByteString
getConnectionString = (.connectionString)

{- | Create a PostgreSQL event store with default configuration.

Uses a connection pool size of 10 and an empty sync projection registry.
-}
newSQLStore :: ByteString -> IO SQLStoreHandle
newSQLStore connectionString = newSQLStoreWithProjections connectionString emptySyncProjectionRegistry

{- | Create a PostgreSQL event store with custom sync projections.

Sync projections run within the same transaction as event insertion,
providing guaranteed consistency between events and their projections.

On startup, this function will:
1. Register all sync projections in the database
2. Catch up any projections that are behind
3. Fail with an exception if catch-up fails
-}
newSQLStoreWithProjections :: ByteString -> SyncProjectionRegistry -> IO SQLStoreHandle
newSQLStoreWithProjections connectionString syncProjRegistry = do
    let connectionSettings = [ConnectionSetting.connection $ ConnectionSettingConnection.string (decodeUtf8 connectionString)]
        -- Pool size set to 10 (conservative default for typical event store workloads)
        -- Leaves ample headroom below PostgreSQL max_connections (~100)
        -- Pool queues excess requests rather than overwhelming the database
        hasqlConfig = Config.settings [Config.size 10, Config.staticConnectionSettings connectionSettings]
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
                    EventParseError{..} ->
                        pack "Event parse error during sync projection catch-up: "
                            <> eventParseErrorMessage
                            <> pack " (event: "
                            <> eventParseFailedEventName
                            <> pack " v"
                            <> pack (show eventParseFailedEventVersion)
                            <> pack ")"
            throwIO $ userError $ Data.Text.unpack errorMsg
        Right () -> do
            -- Create centralized notifier for efficient resource use
            notifier <- Subscription.startNotifier connectionString

            -- Create store handle with notifier
            pure $ SQLStoreHandle pool connectionString syncProjRegistry notifier

{- | PostgreSQL 'EventStore' instance.

This instance automatically uses the sync projections configured in the handle.
All insertEvents calls will execute the sync projections that were registered
when the store was created.
-}
instance EventStore SQLStore where
    type StoreConstraints SQLStore m = MonadUnliftIO m

    -- \| Insert events using the sync projection infrastructure.
    --
    -- This function automatically uses the sync projection registry from the handle,
    -- ensuring any registered sync projections are executed during insertion.
    insertEvents ::
        (Traversable t, MonadUnliftIO m) =>
        BackendHandle SQLStore ->
        Maybe CorrelationId ->
        Transaction t SQLStore ->
        m (InsertionResult SQLStore)
    insertEvents handle corrId transaction =
        insertEventsWithSyncProjections handle handle.syncProjectionRegistry corrId transaction

    subscribe handle matcher selector = Subscription.subscribe handle matcher selector

{- | Insert events with synchronous projections using a custom registry.

Events and projections are committed atomically in a single PostgreSQL
transaction. If any projection fails, the entire transaction is rolled
back, ensuring consistency.

This function allows you to override the sync projection registry from
the handle. In most cases, you should use the generic 'insertEvents'
function instead, which automatically uses the registry from the handle.

This function is useful for testing or scenarios where you need to use
a different registry than the one configured in the handle.
-}
insertEventsWithSyncProjections ::
    (Traversable t, MonadUnliftIO m) =>
    -- | Store handle with connection pool
    SQLStoreHandle ->
    -- | Registry of sync projections to execute
    SyncProjectionRegistry ->
    -- | Optional correlation ID for event tracking
    Maybe CorrelationId ->
    -- | Transaction containing events to insert
    Transaction t SQLStore ->
    -- | Result indicating success or failure
    m (InsertionResult SQLStore)
insertEventsWithSyncProjections handle syncRegistry corrId (Transaction batches) = liftIO $ do
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
                            { errorMessage = pack "Database error: " <> tshow dbError
                            , exception = Just $ SomeException dbError
                            }
        -- Handle business errors
        Right (Left err) ->
            pure $ FailedInsertion err
        -- Handle success
        Right (Right insertedEvents) ->
            pure $
                SuccessfulInsertion $
                    InsertionSuccess
                        { finalCursor = Insertion.finalCursor insertedEvents
                        , streamCursors = Insertion.streamCursors insertedEvents
                        }

{- | Shutdown the SQL store gracefully

This function should be called before releasing the connection pool.
It shuts down the event dispatcher used by all subscriptions.
-}
shutdownSQLStore :: SQLStoreHandle -> IO ()
shutdownSQLStore handle = do
    -- Shutdown the notifier
    Subscription.shutdownNotifier handle.notifier

-- | Convert showable values to 'Text'.
tshow :: (Show a) => a -> Text
tshow = pack . show
