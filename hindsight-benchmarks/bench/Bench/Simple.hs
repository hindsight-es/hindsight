{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}

module Bench.Simple where

import Bench.Common
import Control.Monad (void)
import Criterion
import Data.Map.Strict qualified as Map
import Data.UUID.V4 qualified as UUID
import Database.Postgres.Temp qualified as Temp
import Hasql.Pool qualified as Pool
import Hindsight.Store
import Hindsight.Store.Filesystem (FilesystemStore, FilesystemStoreHandle)
import Hindsight.Store.Memory (MemoryStore, MemoryStoreHandle)
import Hindsight.Store.PostgreSQL (SQLStore, SQLStoreHandle, newSQLStore)
import Hindsight.Store.PostgreSQL.Core.Schema qualified as SQLStore

-- Simple benchmarks that work with concrete backend types
simpleBenchmarks :: [Benchmark]
simpleBenchmarks =
  [ bgroup "Simple Event Store Benchmarks" $
      [ memoryBenchmarks,
        filesystemBenchmarks,
        postgresqlBenchmarks
      ]
  ]

-- Memory store benchmarks
memoryBenchmarks :: Benchmark
memoryBenchmarks =
  bgroup "Memory Store" $
    [ bench "Single Event Insert" $
        whnfIO $
          withBackend memoryBenchRunner $
            \(backend :: MemoryStoreHandle) -> do
              streamId <- StreamId <$> UUID.nextRandom
              let event = makeBenchEvent 1 mediumEventSize
              result <-
                insertEvents backend Nothing $
                  Transaction $ Map.singleton streamId (StreamWrite Any [event])
              case result of
                SuccessfulInsertion _ -> pure ()
                FailedInsertion err -> error $ "Memory insertion failed: " <> show err,
      bench "Batch Insert (10 events)" $
        whnfIO $
          withBackend memoryBenchRunner $
            \(backend :: MemoryStoreHandle) -> do
              streamId <- StreamId <$> UUID.nextRandom
              let events = makeBenchEventBatch 10 mediumEventSize
              result <-
                insertEvents backend Nothing $
                  Transaction $ Map.singleton streamId (StreamWrite Any events)
              case result of
                SuccessfulInsertion _ -> pure ()
                FailedInsertion err -> error $ "Memory batch insertion failed: " <> show err
    ]

-- Filesystem store benchmarks
filesystemBenchmarks :: Benchmark
filesystemBenchmarks =
  bgroup "Filesystem Store" $
    [ bench "Single Event Insert" $
        whnfIO $
          withBackend filesystemBenchRunner $
            \(backend :: FilesystemStoreHandle) -> do
              streamId <- StreamId <$> UUID.nextRandom
              let event = makeBenchEvent 1 mediumEventSize
              result <-
                insertEvents backend Nothing $
                  Transaction $ Map.singleton streamId (StreamWrite Any [event])
              case result of
                SuccessfulInsertion _ -> pure ()
                FailedInsertion err -> error $ "Filesystem insertion failed: " <> show err,
      bench "Batch Insert (10 events)" $
        whnfIO $
          withBackend filesystemBenchRunner $
            \(backend :: FilesystemStoreHandle) -> do
              streamId <- StreamId <$> UUID.nextRandom
              let events = makeBenchEventBatch 10 mediumEventSize
              result <-
                insertEvents backend Nothing $
                  Transaction $ Map.singleton streamId (StreamWrite Any events)
              case result of
                SuccessfulInsertion _ -> pure ()
                FailedInsertion err -> error $ "Filesystem batch insertion failed: " <> show err
    ]

-- PostgreSQL store benchmarks
postgresqlBenchmarks :: Benchmark
postgresqlBenchmarks =
  bgroup "PostgreSQL Store" $
    [ bench "Single Event Insert (with setup)" $
        whnfIO $
          withBackend postgresqlBenchRunner $
            \(backend :: SQLStoreHandle) -> do
              streamId <- StreamId <$> UUID.nextRandom
              let event = makeBenchEvent 1 mediumEventSize
              result <-
                insertEvents backend Nothing $
                  Transaction $ Map.singleton streamId (StreamWrite Any [event])
              case result of
                SuccessfulInsertion _ -> pure ()
                FailedInsertion err -> error $ "PostgreSQL insertion failed: " <> show err,
      bgroup "Multiple operations (shared setup)" $
        [ bench "Single Event Insert" $
            whnfIO $
              withBackend postgresqlBenchRunner $
                \(backend :: SQLStoreHandle) -> do
                  streamId <- StreamId <$> UUID.nextRandom
                  let event = makeBenchEvent 1 mediumEventSize
                  result <-
                    insertEvents backend Nothing $
                      Transaction $ Map.singleton streamId (StreamWrite Any [event])
                  case result of
                    SuccessfulInsertion _ -> pure ()
                    FailedInsertion err -> error $ "PostgreSQL insertion failed: " <> show err,
          bench "Batch Insert (10 events)" $
            whnfIO $
              withBackend postgresqlBenchRunner $
                \(backend :: SQLStoreHandle) -> do
                  streamId <- StreamId <$> UUID.nextRandom
                  let events = makeBenchEventBatch 10 mediumEventSize
                  result <-
                    insertEvents backend Nothing $
                      Transaction $ Map.singleton streamId (StreamWrite Any events)
                  case result of
                    SuccessfulInsertion _ -> pure ()
                    FailedInsertion err -> error $ "PostgreSQL batch insertion failed: " <> show err
        ]
    ]
