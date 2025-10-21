{-# LANGUAGE DataKinds #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TypeApplications #-}

module Test.Hindsight.Projection (projectionTests) where

import Control.Concurrent (forkIO, killThread)
import Control.Exception (bracket)
import Data.Aeson qualified as Aeson
import Data.ByteString (ByteString)
import Data.Map.Strict qualified as Map
import Data.Proxy (Proxy (..))
import Data.Text.Encoding (decodeUtf8)
import Data.UUID.V4 qualified as UUID
import Database.Postgres.Temp qualified as Temp
import Hasql.Connection qualified as Connection
import Hasql.Connection.Setting qualified as ConnectionSetting
import Hasql.Connection.Setting.Connection qualified as ConnectionSettingConnection
import Hasql.Pool (Pool)
import Hasql.Pool qualified as Pool
import Hasql.Pool.Config qualified as Config
import Hasql.Session qualified as Session
import Hasql.TH (maybeStatement, resultlessStatement)
import Hasql.Transaction qualified as Transaction
import Hindsight.Events
import Hindsight.Projection
import Hindsight.Projection.Matching (ProjectionHandler, ProjectionHandlers (..))
import Hindsight.Projection.Schema (createProjectionSchema)
import Hindsight.Store
import Hindsight.Store.Memory
import Test.Hindsight.Examples (UserCreated, UserInformation2 (..))
import Test.Hindsight.Store.TestRunner (EventStoreTestRunner (..))
import Test.Tasty
import Test.Tasty.HUnit
import UnliftIO.STM (newTVarIO)

--------------------------------------------------------------------------------
-- Test tree
--------------------------------------------------------------------------------

projectionTests :: TestTree
projectionTests =
  testGroup
    "Async Projection Tests"
    [ testCase "Basic SQL projection" testBasicProjection
    ]

--------------------------------------------------------------------------------
-- Helper: Temp PostgreSQL with schema
--------------------------------------------------------------------------------

-- | Create a temporary PostgreSQL database with projection schema initialized
withTempPostgresAndPool :: (Pool -> ByteString -> IO a) -> IO a
withTempPostgresAndPool action = do
  let config =
        Temp.defaultConfig
          <> mempty
            { Temp.postgresConfigFile =
                [ ("log_min_messages", "FATAL"),
                  ("log_min_error_statement", "FATAL"),
                  ("client_min_messages", "ERROR")
                ]
            }

  result <- Temp.withConfig config $ \db -> do
    let connStr = Temp.toConnectionString db
        connectionSettings = [ConnectionSetting.connection $ ConnectionSettingConnection.string (decodeUtf8 connStr)]

    -- Create connection pool
    bracket
      ( Pool.acquire $
          Config.settings
            [ Config.size 1,
              Config.staticConnectionSettings connectionSettings
            ]
      )
      Pool.release
      $ \pool -> do
        -- Initialize schema (create projections table and trigger)
        Pool.use pool createProjectionSchema >>= \case
          Left err -> assertFailure $ "Failed to initialize schema: " <> show err
          Right () -> action pool connStr

  case result of
    Left err -> error $ "Failed to start temporary database: " ++ show err
    Right val -> pure val

--------------------------------------------------------------------------------
-- Helper: Combine temp PostgreSQL + EventStoreTestRunner
--------------------------------------------------------------------------------

-- | Backend-agnostic projection test helper
--
-- Combines a temporary PostgreSQL instance (for projection execution) with
-- an event store from the EventStoreTestRunner (for events).
withProjectionTest ::
  EventStoreTestRunner backend ->
  (BackendHandle backend -> Pool -> ByteString -> IO ()) ->
  IO ()
withProjectionTest (EventStoreTestRunner{withStore}) testAction =
  withTempPostgresAndPool $ \pool connStr ->
    withStore $ \store ->
      testAction store pool connStr

--------------------------------------------------------------------------------
-- Helper: Wait for projection to reach cursor using LISTEN/NOTIFY
--------------------------------------------------------------------------------

-- | Wait for projection to process up to target cursor using PostgreSQL LISTEN/NOTIFY
--
-- This uses the production waitForEvent function which efficiently waits for
-- projection progress without polling.
waitForProjectionCursor ::
  forall backend.
  (Ord (Cursor backend), Aeson.FromJSON (Cursor backend)) =>
  ByteString ->          -- Connection string
  ProjectionId ->
  Cursor backend ->
  IO ()
waitForProjectionCursor connStr projId targetCursor = do
  -- Create connection settings
  let connectionSettings = [ConnectionSetting.connection $ ConnectionSettingConnection.string (decodeUtf8 connStr)]

  -- Acquire a dedicated connection for LISTEN/NOTIFY
  connResult <- Connection.acquire connectionSettings
  case connResult of
    Left err -> assertFailure $ "Failed to acquire connection: " <> show err
    Right conn ->
      bracket
        (pure conn)
        Connection.release
        (\c -> waitForEvent projId targetCursor c)

--------------------------------------------------------------------------------
-- Test cases
--------------------------------------------------------------------------------

-- | Test basic async projection functionality
--
-- This test demonstrates the backend-agnostic nature of projections:
-- - Events come from Memory store (fast!)
-- - Projections execute in PostgreSQL
-- - Projection state tracked in PostgreSQL
-- - Uses LISTEN/NOTIFY for efficient waiting
testBasicProjection :: IO ()
testBasicProjection =
  withProjectionTest memoryStoreRunner $ \store pool connStr -> do
    -- Create test table for projection results
    Pool.use pool createTestTable >>= \case
      Left err -> assertFailure $ "Failed to create test table: " <> show err
      Right () -> pure ()

    -- Create a test projection that writes to processed_messages table
    let projId = ProjectionId "test_proj"
        handler :: ProjectionHandler UserCreated MemoryStore
        handler evt =
          Transaction.statement
            evt.payload.userName
            [resultlessStatement|
              insert into processed_messages (message)
              values ($1 :: text)
            |]

        handlers = (Proxy @UserCreated, handler) :-> ProjectionEnd

    -- Create TVar to track projection state
    tvar <- newTVarIO Nothing

    -- Insert a test event into Memory store
    streamId <- StreamId <$> UUID.nextRandom
    let event = SomeLatestEvent (Proxy @UserCreated) $
          UserInformation2
            { userId = 123,
              userName = "TestUser",
              userEmail = Just "test@example.com",
              likeability = 5
            }

    insertionResult <-
      insertEvents store Nothing $
        Transaction (Map.singleton streamId (StreamWrite NoStream [event]))

    case insertionResult of
      FailedInsertion err -> assertFailure $ "Failed to insert event: " ++ show err
      SuccessfulInsertion (InsertionSuccess{finalCursor}) -> do
        -- Start projection in background thread
        projectionThread <-
          forkIO $
            runProjection projId pool (Just tvar) store handlers

        -- Wait for projection to process the event using LISTEN/NOTIFY
        waitForProjectionCursor connStr projId finalCursor

        -- Kill projection thread
        killThread projectionThread

        -- Verify message was stored in projection table
        result <-
          Pool.use pool $
            Session.statement
              ()
              [maybeStatement|
                select message :: text
                from processed_messages
                limit 1
              |]

        case result of
          Right (Just msg) -> msg @?= "TestUser"
          Right Nothing -> assertFailure "No message found in database"
          Left err -> assertFailure $ "Database error: " ++ show err

-- | Create test table for projection results
createTestTable :: Session.Session ()
createTestTable =
  Session.sql
    "CREATE TABLE processed_messages (\n\
    \  id serial primary key,\n\
    \  message text not null\n\
    \)"

-- | Memory store runner for tests
memoryStoreRunner :: EventStoreTestRunner MemoryStore
memoryStoreRunner =
  EventStoreTestRunner
    { withStore = \action -> do
        store <- newMemoryStore
        _ <- action store
        pure (),
      withStores = \_ _ ->
        error "Cannot create multiple instances of a memory store sharing the same storage."
    }
