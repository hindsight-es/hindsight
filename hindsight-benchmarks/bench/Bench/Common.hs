{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}

module Bench.Common where

import Control.DeepSeq (NFData)
import Control.Exception (bracket)
import Control.Monad (void)
import Data.Aeson (FromJSON, ToJSON)
import Data.Map.Strict qualified as Map
import Data.Proxy (Proxy (..))
import Data.Text (Text, pack)
import Data.UUID.V4 qualified as UUID
import Database.Postgres.Temp qualified as Temp
import GHC.Generics (Generic)
import Hasql.Pool qualified as Pool
import Hindsight.Core
import Hindsight.Store
import Hindsight.Store.Filesystem
import Hindsight.Store.Memory
import Hindsight.Store.PostgreSQL (SQLStore, SQLStoreHandle, getPool, newSQLStore)
import Hindsight.Store.PostgreSQL.Core.Schema qualified as SQLStore
import System.Directory (removeDirectoryRecursive)
import System.Posix.Temp

-- | Benchmark event type
type BenchEvent = "bench_event"

-- | Simple payload for benchmark events
data BenchPayload = BenchPayload
  { eventData :: Text,
    eventSize :: Int,
    benchTimestamp :: Text
  }
  deriving (Show, Eq, Generic, FromJSON, ToJSON, NFData)

-- | Version info for benchmark event (single version)
type instance MaxVersion BenchEvent = 0

-- | Payload definition for benchmark event
type instance Versions BenchEvent = FirstVersion BenchPayload

-- | Event instance
instance Event BenchEvent

-- | No upgrade needed for single version
instance UpgradableToLatest BenchEvent 0 where
  upgradeToLatest = id

-- | Generate benchmark events of varying sizes
makeBenchEvent :: Int -> Int -> SomeLatestEvent
makeBenchEvent eventId sizeBytes =
  SomeLatestEvent (Proxy @BenchEvent) $
    BenchPayload
      { eventData = pack $ replicate sizeBytes 'x',
        eventSize = sizeBytes,
        benchTimestamp = "bench-" <> pack (show eventId)
      }

-- | Generate a batch of benchmark events
makeBenchEventBatch :: Int -> Int -> [SomeLatestEvent]
makeBenchEventBatch count sizeBytes =
  [makeBenchEvent i sizeBytes | i <- [1 .. count]]

-- | Medium event size for benchmarks (in bytes)
mediumEventSize :: Int
mediumEventSize = 1000

-- | Backend setup runners for benchmarks
data BenchmarkRunner backend = BenchmarkRunner
  { withBackend :: forall a. (BackendHandle backend -> IO a) -> IO a,
    backendName :: String
  }

-- | Memory store benchmark runner
memoryBenchRunner :: BenchmarkRunner MemoryStore
memoryBenchRunner =
  BenchmarkRunner
    { withBackend = \action -> do
        store <- newMemoryStore
        action store,
      backendName = "Memory"
    }

-- | Filesystem store benchmark runner
filesystemBenchRunner :: BenchmarkRunner FilesystemStore
filesystemBenchRunner =
  BenchmarkRunner
    { withBackend = \action ->
        bracket
          ( do
              dir <- mkdtemp "/tmp/bench-store"
              newFilesystemStore $ mkDefaultConfig dir
          )
          (\store -> removeDirectoryRecursive $ (getStoreConfig store).storePath)
          action,
      backendName = "Filesystem"
    }

-- | PostgreSQL store benchmark runner
postgresqlBenchRunner :: BenchmarkRunner SQLStore
postgresqlBenchRunner =
  BenchmarkRunner
    { withBackend = \action -> do
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
          store <- newSQLStore connStr
          Pool.use (getPool store) SQLStore.createSchema >>= \case
            Left err -> error $ "Failed to initialize schema: " <> show err
            Right () -> do
              res <- action store
              -- Release the connection pool before shutting down PostgreSQL
              Pool.release (getPool store)
              pure res
        case result of
          Left err -> error $ "Failed to start temp database: " <> show err
          Right a -> pure a,
      backendName = "PostgreSQL"
    }






