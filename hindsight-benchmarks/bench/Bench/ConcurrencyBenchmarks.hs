{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}

module Bench.ConcurrencyBenchmarks (concurrencyBenchmarks) where

import Bench.Common (makeBenchEvent)
import Control.Concurrent.Async (async, forConcurrently_, wait)
import Control.Exception (Exception, throwIO)
import Control.Monad (replicateM, void)
import Criterion (Benchmark, bench, bgroup, nfIO)
import Data.Kind (Type)
import Data.Map.Strict qualified as Map
import Data.UUID.V4 qualified as UUID
import Database.Postgres.Temp qualified as Temp
import Hasql.Pool qualified as Pool
import Hasql.Session qualified as Session
import Hasql.Transaction.Sessions qualified as Sessions
import Hindsight.Store (ExpectedVersion (..), InsertionResult (..), StreamEventBatch (..), StreamId (..), insertEvents)
import Hindsight.Store.PostgreSQL (SQLStore, SQLStoreHandle (..), newSQLStore)
import Hindsight.Store.PostgreSQL.Core.Schema qualified as SQLStore

data BenchmarkError = BenchmarkError String
  deriving (Show)

instance Exception BenchmarkError

-- | Setup persistent PostgreSQL database for benchmarks
setupPersistentDB :: IO (Temp.DB, SQLStoreHandle)
setupPersistentDB = do
  db <-
    Temp.start >>= \case
      Left err -> throwIO $ BenchmarkError $ "Failed to start postgres: " <> show err
      Right db -> pure db

  let connStr = Temp.toConnectionString db
  store <- newSQLStore connStr
  Pool.use (pool store) SQLStore.createSchema >>= \case
    Left err -> throwIO $ BenchmarkError $ "Failed to initialize schema: " <> show err
    Right () -> pure (db, store)

-- | Run concurrent insertions and measure total time
concurrentInsertionBenchmark :: Int -> IO ()
concurrentInsertionBenchmark numConcurrent = do
  (db, backend) <- setupPersistentDB

  -- Create concurrent insertions that might conflict
  let createInsertion i = do
        streamId <- StreamId <$> UUID.nextRandom
        let events = Map.singleton streamId (StreamEventBatch Any [makeBenchEvent i 100])
        result <- insertEvents backend Nothing events
        case result of
          FailedInsertion err -> throwIO $ BenchmarkError $ "Insertion failed: " <> show err
          SuccessfulInsertion _ -> pure ()

  -- Run insertions concurrently
  forConcurrently_ [1 .. numConcurrent] createInsertion

  -- Cleanup
  void $ Temp.stop db

-- | Test concurrent insertions to the same stream (high contention)
highContentionBenchmark :: Int -> IO ()
highContentionBenchmark numConcurrent = do
  (db, backend) <- setupPersistentDB

  -- Use the same stream ID for all concurrent insertions (maximum contention)
  sharedStreamId <- StreamId <$> UUID.nextRandom

  let createInsertion i = do
        let events = Map.singleton sharedStreamId (StreamEventBatch Any [makeBenchEvent i 100])
        result <- insertEvents backend Nothing events
        case result of
          FailedInsertion err -> throwIO $ BenchmarkError $ "High contention insertion failed: " <> show err
          SuccessfulInsertion _ -> pure ()

  -- Run insertions concurrently to same stream
  forConcurrently_ [1 .. numConcurrent] createInsertion

  -- Cleanup
  void $ Temp.stop db

-- | Test mixed workload with some contention
mixedContentionBenchmark :: Int -> IO ()
mixedContentionBenchmark numConcurrent = do
  (db, backend) <- setupPersistentDB

  -- Create a few shared streams (moderate contention)
  sharedStreams <- replicateM 3 (StreamId <$> UUID.nextRandom)

  let createInsertion i = do
        -- Pick a stream (some contention but not maximum)
        let streamId = sharedStreams !! (i `mod` length sharedStreams)
        let events = Map.singleton streamId (StreamEventBatch Any [makeBenchEvent i 100])
        result <- insertEvents backend Nothing events
        case result of
          FailedInsertion err -> throwIO $ BenchmarkError $ "Mixed contention insertion failed: " <> show err
          SuccessfulInsertion _ -> pure ()

  -- Run insertions concurrently with moderate contention
  forConcurrently_ [1 .. numConcurrent] createInsertion

  -- Cleanup
  void $ Temp.stop db

-- | Create concurrency benchmarks
concurrencyBenchmarks :: IO [Benchmark]
concurrencyBenchmarks = do
  putStrLn "Setting up concurrency benchmarks..."

  let concurrencyLevels = [2, 4, 8, 16, 32]

  pure $
    [ bgroup
        "Concurrency Benchmarks"
        [ bgroup
            "No Contention (Different Streams)"
            [ bench (show n <> " concurrent insertions") $
                nfIO $
                  concurrentInsertionBenchmark n
              | n <- concurrencyLevels
            ],
          bgroup
            "High Contention (Same Stream)"
            [ bench (show n <> " concurrent insertions") $
                nfIO $
                  highContentionBenchmark n
              | n <- concurrencyLevels
            ],
          bgroup
            "Mixed Contention (3 Shared Streams)"
            [ bench (show n <> " concurrent insertions") $
                nfIO $
                  mixedContentionBenchmark n
              | n <- concurrencyLevels
            ]
        ]
    ]
