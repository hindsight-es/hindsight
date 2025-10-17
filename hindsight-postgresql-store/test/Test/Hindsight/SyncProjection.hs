{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}

module Test.Hindsight.SyncProjection where

import Control.Exception (bracket)
import Data.ByteString (ByteString)
import Data.ByteString.Char8 qualified as BS
import Data.Map qualified as Map
import Data.Proxy
import Database.Postgres.Temp qualified as Temp
import Hasql.Decoders qualified as D
import Hasql.Pool qualified as Pool
import Hasql.Session qualified as Session
import Hasql.Statement (Statement (..))
import Hasql.Transaction qualified as Transaction
import Hindsight.Events
import Test.Hindsight.Examples
import Hindsight.Projection
import Hindsight.Projection.Matching (ProjectionHandlers (..))
import Hindsight.Store

import Hindsight.Store.PostgreSQL
import Hindsight.Store.PostgreSQL.Core.Schema qualified as Schema
import System.Random (randomIO)
import Test.Tasty
import Test.Tasty.HUnit

syncProjectionTests :: TestTree
syncProjectionTests =
  testGroup
    "Synchronous Projections"
    [ testCase "Synchronous projections execute within insert transaction" $
        withTestDatabase $ \connStr -> do
          -- Create a synchronous projection that creates a test record
          let projectionHandlers =
                ( Proxy @UserCreated,
                  \EventWithMetadata {eventId = EventId eid} -> do
                    -- Create a record that we can verify later
                    Transaction.sql $
                      "INSERT INTO test_projections (event_id) VALUES ('"
                        <> BS.pack (show eid)
                        <> "')"
                )
                  :-> ProjectionEnd

          -- Register the projection
          let syncRegistry =
                registerSyncProjection
                  (ProjectionId "test-sync-projection")
                  projectionHandlers
                  emptySyncProjectionRegistry
          

          -- Create store and initialize
          withSQLStoreAndProjections connStr syncRegistry $ \store -> do
            _ <- Pool.use (getPool store) $ do
              Session.sql "CREATE TABLE test_projections (event_id TEXT)"

            -- Insert a UserCreated event with synchronous projection
            streamId <- StreamId <$> randomIO
            let event =
                  SomeLatestEvent (Proxy @UserCreated) $
                    UserInformation2
                      { userId = 123,
                        userName = "Test User",
                        userEmail = Just "test@example.com",
                        likeability = 5
                      }

                batch =
                  StreamWrite
                    { expectedVersion = Any,
                      events = [event]
                    }

            result <-
              insertEvents
                store
                Nothing
                (Transaction (Map.singleton streamId batch))

            -- Verify the event was inserted
            case result of
              SuccessfulInsertion _ -> pure ()
              FailedInsertion err -> assertFailure $ "Insertion failed: " ++ show err

            -- First check if events were actually inserted
            eventCountResult <-
              Pool.use (getPool store) $
                Session.statement () $
                  Statement
                    "SELECT COUNT(*) FROM events"
                    mempty
                    (D.singleRow (D.column (D.nonNullable D.int8)))
                    True

            case eventCountResult of
              Left err -> assertFailure $ "Failed to count events: " ++ show err
              Right eventCount -> assertEqual "Should have inserted one event" 1 eventCount

            -- Verify the projection was executed by checking the database
            countResult <-
              Pool.use (getPool store) $
                Session.statement () $
                  Statement
                    "SELECT COUNT(*) FROM test_projections"
                    mempty
                    (D.singleRow (D.column (D.nonNullable D.int8)))
                    True

            case countResult of
              Left err -> assertFailure $ "Failed to query: " ++ show err
              Right count -> assertEqual "Should have one projection record" 1 count,
      testCase "Multiple projections execute in order" $
        withTestDatabase $ \connStr -> do
          -- Create projections that insert records with ordering info
          let projection1 =
                ( Proxy @UserCreated,
                  \_ -> do
                    Transaction.sql "INSERT INTO test_projections (event_id) VALUES ('proj1')"
                )
                  :-> ProjectionEnd

              projection2 =
                ( Proxy @UserCreated,
                  \_ -> do
                    Transaction.sql "INSERT INTO test_projections (event_id) VALUES ('proj2')"
                )
                  :-> ProjectionEnd

          let syncRegistry =
                registerSyncProjection (ProjectionId "projection-1") projection1 $
                  registerSyncProjection (ProjectionId "projection-2") projection2 $
                    emptySyncProjectionRegistry

          -- Create store and initialize
          withSQLStoreAndProjections connStr syncRegistry $ \store -> do
            _ <- Pool.use (getPool store) $ do
              Session.sql "CREATE TABLE test_projections (event_id TEXT)"

            -- Insert event
            streamId <- StreamId <$> randomIO
            let event =
                  SomeLatestEvent (Proxy @UserCreated) $
                    UserInformation2
                      { userId = 789,
                        userName = "Test User Multi",
                        userEmail = Just "multi@example.com",
                        likeability = 8
                      }

                batch =
                  StreamWrite
                    { expectedVersion = Any,
                      events = [event]
                    }

            result <-
              insertEvents
                store
                Nothing
                (Transaction (Map.singleton streamId batch))

            -- Verify insertion succeeded
            case result of
              SuccessfulInsertion _ -> pure ()
              FailedInsertion err -> assertFailure $ "Insertion failed: " ++ show err

            -- Verify both projections executed
            recordsResult <-
              Pool.use (getPool store) $
                Session.statement () $
                  Statement
                    "SELECT event_id FROM test_projections ORDER BY event_id"
                    mempty
                    (D.rowList (D.column (D.nonNullable D.text)))
                    True

            case recordsResult of
              Left err -> assertFailure $ "Failed to query: " ++ show err
              Right records -> assertEqual "Should have both projection records" ["proj1", "proj2"] records,
      testCase "Projection error propagates and rolls back transaction" $
        withTestDatabase $ \connStr -> do
          -- Create a projection that throws an error
          let errorProjection =
                ( Proxy @UserCreated,
                  \_ -> do
                    -- This SQL will fail due to constraint violation
                    Transaction.sql "INSERT INTO test_projections (event_id) VALUES (NULL)"
                )
                  :-> ProjectionEnd

          let syncRegistry =
                registerSyncProjection
                  (ProjectionId "error-projection")
                  errorProjection
                  emptySyncProjectionRegistry

          -- Create store and initialize
          withSQLStoreAndProjections connStr syncRegistry $ \store -> do
            _ <- Pool.use (getPool store) $ do
              -- Create table with NOT NULL constraint
              Session.sql "CREATE TABLE test_projections (event_id TEXT NOT NULL)"

            -- Try to insert event
            streamId <- StreamId <$> randomIO
            let event =
                  SomeLatestEvent (Proxy @UserCreated) $
                    UserInformation2
                      { userId = 555,
                        userName = "Error Test",
                        userEmail = Just "error@example.com",
                        likeability = 1
                      }

                batch =
                  StreamWrite
                    { expectedVersion = Any,
                      events = [event]
                    }

            result <-
              insertEvents
                store
                Nothing
                (Transaction (Map.singleton streamId batch))

            -- Verify the insertion failed
            case result of
              SuccessfulInsertion _ ->
                assertFailure "Expected insertion to fail due to projection error"
              FailedInsertion _ ->
                pure () -- Expected

            -- Verify no events were inserted
            countResult <-
              Pool.use (getPool store) $
                Session.statement () $
                  Statement
                    "SELECT COUNT(*) FROM events"
                    mempty
                    (D.singleRow (D.column (D.nonNullable D.int8)))
                    True

            case countResult of
              Left err -> assertFailure $ "Failed to count events: " ++ show err
              Right count -> assertEqual "No events should have been inserted" 0 count,
      testCase "Empty projection registry doesn't affect insertion" $
        withTestDatabase $ \connStr -> do
          -- Create store and initialize
          withSQLStore connStr $ \store -> do
            _ <- Pool.use (getPool store) Schema.createSchema

            -- Insert event with empty registry
            streamId <- StreamId <$> randomIO
            let event =
                  SomeLatestEvent (Proxy @UserCreated) $
                    UserInformation2
                      { userId = 1000,
                        userName = "Empty Test",
                        userEmail = Just "empty@example.com",
                        likeability = 0
                      }

                batch =
                  StreamWrite
                    { expectedVersion = Any,
                      events = [event]
                    }

            result <-
              insertEvents
                store
                Nothing
                (Transaction (Map.singleton streamId batch))

            -- Should succeed
            case result of
              SuccessfulInsertion _ -> pure ()
              FailedInsertion err ->
                assertFailure $ "Insertion should succeed with empty registry: " ++ show err
    ]

-- Helper to run tests with a temporary database
withTestDatabase :: (ByteString -> IO a) -> IO a
withTestDatabase action = do
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
    action connStr
  case result of
    Left err -> error $ "Failed to start temporary database: " ++ show err
    Right val -> pure val

-- Helper to run tests with a SQL store that properly cleans up
withSQLStore :: ByteString -> (SQLStoreHandle -> IO a) -> IO a
withSQLStore connStr action = do
  bracket
    (newSQLStore connStr)
    (\store -> do
        shutdownSQLStore store
        Pool.release (getPool store))
    (\store -> action store)

-- Helper to run tests with a SQL store and sync projections
withSQLStoreAndProjections :: ByteString -> SyncProjectionRegistry -> (SQLStoreHandle -> IO a) -> IO a
withSQLStoreAndProjections connStr registry action = do
  -- First create a store without projections to set up the schema
  bracket
    (do
      -- Create a temporary store to initialize schema
      tempStore <- newSQLStore connStr
      _ <- Pool.use (getPool tempStore) Schema.createSchema
      shutdownSQLStore tempStore
      Pool.release (getPool tempStore)
      -- Now create the actual store with projections
      newSQLStoreWithProjections connStr registry)
    (\store -> do
        shutdownSQLStore store
        Pool.release (getPool store))
    action
