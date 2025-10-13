{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}

module Bench.PostgreSQLOptimized where

import Bench.Common
import Control.Exception (bracket)
import Control.Monad (void)
import Criterion
import Data.Map.Strict qualified as Map
import Data.UUID.V4 qualified as UUID
import Database.Postgres.Temp qualified as Temp
import Hasql.Pool qualified as Pool
import Hindsight.Store
import Hindsight.Store.PostgreSQL (SQLStore, SQLStoreHandle, getPool, newSQLStore)
import Hindsight.Store.PostgreSQL.Core.Schema qualified as SQLStore

-- | PostgreSQL benchmarks with optimized setup
optimizedPostgreSQLBenchmarks :: IO [Benchmark]
optimizedPostgreSQLBenchmarks = do
  putStrLn "Setting up persistent PostgreSQL for optimized benchmarks..."

  -- Setup one database for all benchmarks
  (db, backend) <- setupPersistentDB

  let cleanupAndReturn benchmarks = do
        putStrLn "Cleaning up PostgreSQL..."
        void $ Temp.stop db
        pure benchmarks

  -- Create benchmarks that reuse the same backend
  let benchmarks =
        [ bgroup "PostgreSQL Store (Optimized - No Setup)" $
            [ bench "Single Event Insert" $ whnfIO $ do
                streamId <- StreamId <$> UUID.nextRandom
                let event = makeBenchEvent 1 mediumEventSize
                result <-
                  insertEvents backend Nothing $
                    Map.singleton streamId (StreamEventBatch Any [event])
                case result of
                  SuccessfulInsertion _ -> pure ()
                  FailedInsertion err -> error $ "PostgreSQL insertion failed: " <> show err,
              bench "Batch Insert (10 events)" $ whnfIO $ do
                streamId <- StreamId <$> UUID.nextRandom
                let events = makeBenchEventBatch 10 mediumEventSize
                result <-
                  insertEvents backend Nothing $
                    Map.singleton streamId (StreamEventBatch Any events)
                case result of
                  SuccessfulInsertion _ -> pure ()
                  FailedInsertion err -> error $ "PostgreSQL batch insertion failed: " <> show err,
              bench "Large Batch Insert (100 events)" $ whnfIO $ do
                streamId <- StreamId <$> UUID.nextRandom
                let events = makeBenchEventBatch 100 mediumEventSize
                result <-
                  insertEvents backend Nothing $
                    Map.singleton streamId (StreamEventBatch Any events)
                case result of
                  SuccessfulInsertion _ -> pure ()
                  FailedInsertion err -> error $ "PostgreSQL batch insertion failed: " <> show err
            ]
        ]

  -- Return benchmarks that will clean up after running
  pure benchmarks

-- | Setup a persistent PostgreSQL database
setupPersistentDB :: IO (Temp.DB, SQLStoreHandle)
setupPersistentDB = do
  db <-
    Temp.start >>= \case
      Left err -> error $ "Failed to start temp database: " <> show err
      Right db -> pure db
  let connStr = Temp.toConnectionString db
  store <- newSQLStore connStr
  Pool.use ((getPool store) SQLStore.createSchema >>= \case
    Left err -> error $ "Failed to initialize schema: " <> show err
    Right () -> pure (db, store)
