{-# LANGUAGE DataKinds #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

module Backends.Common
  ( BenchmarkRunner(..)
  , allBackends
  , memoryRunner
  , filesystemRunner  
  , postgresqlRunner
  , runForAllBackends
  ) where

import Control.Exception (bracket)
import Core.Types
import Database.Postgres.Temp qualified as Temp
import Hasql.Pool qualified as Pool
import Hindsight.Store
import Hindsight.Store.Filesystem qualified as FS
import Hindsight.Store.Memory
import Hindsight.Store.PostgreSQL (SQLStore, getPool, newSQLStore)
import Hindsight.Store.PostgreSQL.Core.Schema qualified as SQLStore
import System.Directory (removeDirectoryRecursive)
import System.Posix.Temp

-- | Backend runner abstraction
data BenchmarkRunner backend = BenchmarkRunner
  { withBackend :: forall a. (BackendHandle backend -> IO a) -> IO a
  , backendType :: Backend
  , backendName :: String
  }

-- | Memory store benchmark runner
memoryRunner :: BenchmarkRunner MemoryStore
memoryRunner = BenchmarkRunner
  { withBackend = \action -> do
      store <- newMemoryStore
      action store
  , backendType = Memory
  , backendName = "Memory"
  }

-- | Filesystem store benchmark runner
filesystemRunner :: BenchmarkRunner FS.FilesystemStore
filesystemRunner = BenchmarkRunner
  { withBackend = \action ->
      bracket
        ( do
            dir <- mkdtemp "/tmp/bench-v2-store"
            FS.newFilesystemStore $ FS.mkDefaultConfig dir
        )
        (\store -> removeDirectoryRecursive (FS.storePath $ FS.getStoreConfig store))
        action
  , backendType = Filesystem
  , backendName = "Filesystem"
  }

-- | PostgreSQL store benchmark runner
postgresqlRunner :: BenchmarkRunner SQLStore
postgresqlRunner = BenchmarkRunner
  { withBackend = \action -> do
      let config = Temp.defaultConfig
            <> mempty
              { Temp.postgresConfigFile =
                  [ ("log_min_messages", "FATAL")
                  , ("log_min_error_statement", "FATAL")
                  , ("client_min_messages", "ERROR")
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
        Right a -> pure a
  , backendType = PostgreSQL
  , backendName = "PostgreSQL"
  }

-- | All available backend runners
allBackends :: [BenchmarkRunner ()]
allBackends = 
  [ castRunner memoryRunner
  , castRunner filesystemRunner  
  , castRunner postgresqlRunner
  ]
  where
    -- Cast runner to eliminate type parameter for easier list handling
    castRunner :: BenchmarkRunner backend -> BenchmarkRunner ()
    castRunner (BenchmarkRunner withBackendFn backendType backendName) = BenchmarkRunner
      { withBackend = \action -> withBackendFn (\_ -> action (undefined :: BackendHandle ()))
      , backendType = backendType
      , backendName = backendName
      }

-- | Run a benchmark action for all backends
runForAllBackends :: (forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BenchmarkRunner backend -> IO a) -> IO [a]
runForAllBackends benchAction = do
  memResult <- benchAction memoryRunner
  fsResult <- benchAction filesystemRunner
  pgResult <- benchAction postgresqlRunner
  return [memResult, fsResult, pgResult]