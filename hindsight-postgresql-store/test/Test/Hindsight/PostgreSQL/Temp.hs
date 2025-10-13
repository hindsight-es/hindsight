{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE RecordWildCards #-}

-- | Unified temporary PostgreSQL instance management for tests
-- 
-- This module provides a type-safe, configurable way to create temporary
-- PostgreSQL instances for testing, consolidating all the different patterns
-- used throughout the test suite.
module Test.Hindsight.PostgreSQL.Temp
  ( -- * Configuration Types
    TempPostgresConfig (..),
    TimeoutConfig (..),
    DebugConfig (..),
    SchemaConfig (..),
    
    -- * Core Function
    withTempPostgreSQL,
    
    -- * Convenience Configurations
    defaultConfig,
    debugMode,
  )
where

import Control.Exception (SomeException, try)
import Control.Concurrent (threadDelay)
import System.Timeout (timeout)
import Test.Tasty.HUnit (assertFailure)

import Hasql.Pool qualified as Pool
import Database.Postgres.Temp qualified as Temp
import Hindsight.Store.PostgreSQL (SQLStoreHandle, getPool, newSQLStore, newSQLStoreWithProjections, shutdownSQLStore)
import Hindsight.Store.PostgreSQL (createSQLSchema)
import Hindsight.Store.PostgreSQL (SyncProjectionRegistry)

-- | Configuration for timeout behavior
data TimeoutConfig
  = NoTimeout              -- ^ No timeout, test runs indefinitely
  | Timeout Int             -- ^ Timeout in microseconds
  deriving (Eq, Show)

-- | Configuration for debugging behavior on failures/timeouts
data DebugConfig
  = NoDebug                 -- ^ No debugging output
  | DebugOnFailure          -- ^ Debug only on exceptions
  | DebugOnTimeout          -- ^ Debug only on timeouts  
  | DebugOnAny              -- ^ Debug on any failure (exceptions or timeouts)
  deriving (Eq, Show)

-- | Configuration for schema initialization
data SchemaConfig
  = BasicSchema             -- ^ Just create basic schema
  | WithProjections SyncProjectionRegistry  -- ^ Schema + sync projections

-- | Complete configuration for temporary PostgreSQL instances
data TempPostgresConfig = TempPostgresConfig
  { timeoutConfig :: TimeoutConfig
  , debugConfig :: DebugConfig
  , schemaConfig :: SchemaConfig
  , debugPauseDuration :: Int  -- ^ How long to pause for debugging (microseconds)
  }

-- | Default configuration: 30s timeout, no debugging, basic schema
defaultConfig :: TempPostgresConfig
defaultConfig = TempPostgresConfig
  { timeoutConfig = Timeout 30_000_000  -- 30 seconds
  , debugConfig = NoDebug
  , schemaConfig = BasicSchema
  , debugPauseDuration = 3600_000_000   -- 60 minutes
  }

-- | Debug-enabled configuration: 30s timeout, debug on any failure
debugMode :: TempPostgresConfig
debugMode = defaultConfig
  { debugConfig = DebugOnAny
  }

-- | Create a temporary PostgreSQL instance with configurable timeout and debugging
withTempPostgreSQL :: TempPostgresConfig -> (SQLStoreHandle -> IO a) -> IO a
withTempPostgreSQL config action = do
  let postgresConfig =
        Temp.defaultConfig
          <> mempty
            { Temp.postgresConfigFile =
                [ ("log_min_messages", "FATAL"),
                  ("log_min_error_statement", "FATAL"),
                  ("client_min_messages", "ERROR")
                ]
            }

  result <- Temp.withConfig postgresConfig $ \db -> do
    let connStr = Temp.toConnectionString db
    
    -- Create store based on schema config
    store <- case config.schemaConfig of
      BasicSchema -> newSQLStore connStr
      WithProjections registry -> do
        -- First create a temporary store to initialize schema
        tempStore <- newSQLStore connStr
        _ <- Pool.use (getPool tempStore) createSQLSchema
        Pool.release (getPool tempStore)
        -- Now create the actual store with projections
        newSQLStoreWithProjections connStr registry
    
    -- Initialize schema for basic config (projections config handles its own)
    case config.schemaConfig of
      BasicSchema -> do
        Pool.use (getPool store) createSQLSchema >>= \case
          Left err -> assertFailure $ "Failed to initialize schema: " ++ show err
          Right () -> pure ()
      WithProjections _ -> pure () -- Already handled above

    -- Run the action with configured timeout
    result <- case config.timeoutConfig of
      NoTimeout -> try (Just <$> action store)
      Timeout timeoutMicros -> try (timeout timeoutMicros $ action store)

    -- Always cleanup the SQL store gracefully first, then the connection pool
    shutdownSQLStore store
    Pool.release (getPool store)
    
    -- Handle the result with configured debugging
    let debugAction = do
          putStrLn $ "Connection string: " <> show connStr
          putStrLn $ "Pausing for debugging for " <> show (config.debugPauseDuration `div` 1_000_000) <> " seconds. Press Ctrl+C to exit."
          threadDelay config.debugPauseDuration
    
    case result of
      Left (err :: SomeException) -> do
        putStrLn $ "Test failed: " <> show err
        case config.debugConfig of
          DebugOnFailure -> debugAction
          DebugOnAny -> debugAction
          _ -> pure ()
        error $ "Test failed: " <> show err
        
      Right Nothing -> do
        putStrLn "Test timed out."
        case config.debugConfig of
          DebugOnTimeout -> debugAction
          DebugOnAny -> debugAction
          _ -> pure ()
        assertFailure "Test timed out"
        
      Right (Just result') -> pure result'
  
  case result of
    Left err -> error $ "Failed to start temporary database: " ++ show err
    Right val -> pure val