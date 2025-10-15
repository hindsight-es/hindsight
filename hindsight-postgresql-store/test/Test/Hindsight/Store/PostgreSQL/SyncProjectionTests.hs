{-# LANGUAGE DataKinds #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}

module Test.Hindsight.Store.PostgreSQL.SyncProjectionTests where


import Data.ByteString.Char8 qualified as BS
import Data.Map.Strict qualified as Map
import Data.Proxy (Proxy (..))
import Data.Text (pack)
import Data.UUID.V4 qualified as UUID
import Hasql.Decoders qualified as D
import Hasql.Pool qualified as Pool
import Hasql.Session qualified as Session
import Hasql.Statement (Statement (..))
import Hasql.Transaction qualified as Transaction
import Test.Hindsight.Examples (UserCreated)
import Hindsight.Projection (ProjectionId (..))
import Hindsight.Projection.Matching (ProjectionHandlers (..))
import Hindsight.Store
import Hindsight.Store.PostgreSQL (SQLStore, SQLStoreHandle, getPool, getConnectionString, newSQLStoreWithProjections)
import Hindsight.Store.PostgreSQL.Projections.Sync (emptySyncProjectionRegistry, registerSyncProjection)
import Test.Hindsight.Store.Common (makeUserEvent)
import Test.Hindsight.PostgreSQL.Temp (defaultConfig, withTempPostgreSQL)
import Test.Tasty
import Test.Tasty.HUnit

-- | Test synchronous projections work with all insertion strategies
testSyncProjections :: SQLStoreHandle -> IO ()
testSyncProjections store = do
  streamId <- StreamId <$> UUID.nextRandom

  -- Create test table for tracking projections
  _ <- Pool.use (getPool store) $ do
    Session.sql $ "CREATE TABLE IF NOT EXISTS test_projections (event_id TEXT)"

  -- Create a projection that records when it's called
  let projectionHandlers =
        ( Proxy @UserCreated,
          \EventWithMetadata {eventId = EventId eid} -> do
            -- Insert a record that we can verify later
            Transaction.sql $
              "INSERT INTO test_projections (event_id) VALUES ('"
                <> BS.pack (show eid)
                <> "')"
        )
          :-> ProjectionEnd

  let registry = registerSyncProjection (ProjectionId $ pack "test") projectionHandlers emptySyncProjectionRegistry

  -- Create a new store with the registry
  storeWithProjections <- newSQLStoreWithProjections (getConnectionString store) registry

  -- Insert event with sync projection (now using the generic insertEvents)
  result <-
    insertEvents storeWithProjections Nothing $
      Transaction (Map.singleton streamId (StreamWrite NoStream [makeUserEvent 1]))

  case result of
    FailedInsertion err -> assertFailure $ "Failed to insert: " ++ show err
    SuccessfulInsertion _ -> do
      -- Check that projection was executed by querying the database
      countResult <-
        Pool.use (getPool storeWithProjections) $
          Session.statement () $
            Statement
              "SELECT COUNT(*) FROM test_projections"
              mempty
              (D.singleRow (D.column (D.nonNullable D.int8)))
              True

      case countResult of
        Left err -> assertFailure $ "Failed to query: " ++ show err
        Right count -> assertEqual "Should have one projection record" 1 count


-- | Test suite for synchronous projections
syncProjectionTests :: TestTree
syncProjectionTests =
  testGroup
    "Synchronous Projection Tests"
    [ testCase "Supports sync projections" $
        withTempPostgreSQL defaultConfig testSyncProjections
    ]
