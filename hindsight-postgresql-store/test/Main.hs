{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Control.Concurrent (threadDelay)
import Control.Exception (SomeException, bracket, throwIO, try)
import Control.Monad (forM_, replicateM, void)
import Data.Map.Strict qualified as Map
import Database.Postgres.Temp qualified as Temp
import Hasql.Pool qualified as Pool
import Hindsight.Store
import Hindsight.Store.PostgreSQL (SQLStore, getPool, newSQLStore, shutdownSQLStore)
import Hindsight.Store.PostgreSQL.Core.Schema qualified as SQLStore
import System.Timeout (timeout)
import Test.Hindsight.Store.Common
import Test.Hindsight.Store.PostgreSQL.PropertyBasedTests (propertyBasedTests)
import Test.Hindsight.Store.PostgreSQL.LiveSubscriptionOrderingTest qualified
import Test.Hindsight.Store.PostgreSQL.PathologicalTests qualified
import Test.Hindsight.Store.PostgreSQL.StreamHeadCorrectnessTest qualified
import Test.Hindsight.Store.PostgreSQL.SyncProjectionTests qualified
import Test.Hindsight.Store.PostgreSQL.SyncProjectionStateTests qualified
import Test.Hindsight.Store.PostgreSQL.VersionStress qualified
import Test.Hindsight.SyncProjection qualified
import Test.Hindsight.Store.TestRunner
import Test.Tasty
import Test.Tasty.HUnit

-- SQL store test runner
sqlStoreRunner :: EventStoreTestRunner SQLStore
sqlStoreRunner =
  EventStoreTestRunner
    { withStore = \action ->
        void $
          let config =
                Temp.defaultConfig
                  <> mempty
                    { Temp.postgresConfigFile =
                        [ ("log_min_messages", "FATAL"),
                          ("log_min_error_statement", "FATAL"),
                          ("client_min_messages", "ERROR")
                        ]
                    }
           in Temp.withConfig config $ \db -> do
                let connStr = Temp.toConnectionString db
                store <- newSQLStore connStr
                Pool.use (getPool store) SQLStore.createSchema >>= \case
                  Left err -> assertFailure $ "Failed to initialize schema: " <> show err
                  Right () -> pure ()
                result <- try $ do
                  threadDelay 10000
                  timeout 10_000_000 $ action store
                -- Shutdown the SQL store gracefully before releasing the pool
                shutdownSQLStore store
                Pool.release (getPool store)
                let debugTest = do
                      putStrLn $ "Connection string: " <> show connStr
                      putStrLn "Pausing for debugging. Press Ctrl+C to exit."
                      threadDelay (3600 * 1000000) -- Sleep for 60 seconds
                case result of
                  Left (err :: SomeException) -> do
                    putStrLn $ "Test failed: " <> show err
                    debugTest
                    throwIO err
                  Right Nothing -> do
                    putStrLn "Test timed out."
                    debugTest
                    error "Test timed out."
                  Right (Just _) -> pure (), -- No need to cleanup, the database will be dropped automatically.
      withStores = \n action ->
        void $
          let config =
                Temp.defaultConfig
                  <> mempty
                    { Temp.postgresConfigFile =
                        [ ("log_min_messages", "FATAL"),
                          ("log_min_error_statement", "FATAL"),
                          ("client_min_messages", "ERROR")
                        ]
                    }
           in Temp.withConfig config $ \db -> do
                let connStr = Temp.toConnectionString db
                -- Create N separate store handles to the same database
                -- Each gets its own connection pool and notifier thread
                stores <- replicateM n (newSQLStore connStr)

                -- Initialize schema once with first store
                case stores of
                  (firstStore:_) ->
                    Pool.use (getPool firstStore) SQLStore.createSchema >>= \case
                      Left err -> assertFailure $ "Failed to initialize schema: " <> show err
                      Right () -> pure ()
                  [] -> assertFailure "No stores created"

                result <- try $ do
                  threadDelay 10000
                  timeout 10_000_000 $ action stores

                -- Shutdown all stores gracefully
                forM_ stores $ \store -> do
                  shutdownSQLStore store
                  Pool.release (getPool store)

                case result of
                  Left (err :: SomeException) -> throwIO err
                  Right Nothing -> error "Test timed out."
                  Right (Just _) -> pure ()
    }

sqlStoreTests :: IO TestTree
sqlStoreTests = do
  propertyTests <- propertyBasedTests
  return $
    testGroup
      "PostgreSQL Store + Projections Tests"
      [ testGroup "Generic Store Tests" (genericEventStoreTests sqlStoreRunner),
        testGroup "Multi-Instance Tests" (multiInstanceTests sqlStoreRunner),
        testGroup "PostgreSQL-Specific Tests"
          [ propertyTests,
            Test.Hindsight.Store.PostgreSQL.LiveSubscriptionOrderingTest.tests,
            Test.Hindsight.Store.PostgreSQL.PathologicalTests.pathologicalTests,
            Test.Hindsight.Store.PostgreSQL.StreamHeadCorrectnessTest.tests,
            Test.Hindsight.Store.PostgreSQL.VersionStress.versionStressTests
          ],
        testGroup "Projection Tests"
          [ Test.Hindsight.Store.PostgreSQL.SyncProjectionTests.syncProjectionTests,
            Test.Hindsight.Store.PostgreSQL.SyncProjectionStateTests.tests,
            Test.Hindsight.SyncProjection.syncProjectionTests
          ]
      ]

main :: IO ()
main = do
  tests <- sqlStoreTests
  defaultMain tests
