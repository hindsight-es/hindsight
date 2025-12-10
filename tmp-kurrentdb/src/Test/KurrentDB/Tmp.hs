{- |
Module      : Test.KurrentDB.Tmp
Description : Temporary KurrentDB Docker containers for testing
Copyright   : (c) 2025
License     : BSD3
Maintainer  : gael@hindsight.events

Spin up isolated KurrentDB Docker containers for testing.
As dumb as possible - just starts a container, waits for readiness, and cleans up.

For faster test execution, see 'Test.KurrentDB.Tmp.Pool' which maintains a pool
of reusable instances.
-}
module Test.KurrentDB.Tmp (
    -- * Single Instance (Original API)
    withTmpKurrentDB,
    KurrentDBConfig (..),

    -- * Pooled Instances (Faster)
    Pool,
    PoolConfig (..),
    defaultPoolConfig,
    withPool,
    withInstance,
) where

import Control.Exception (bracket)
import System.Random (randomRIO)
import Test.KurrentDB.Tmp.Instance (Instance (..), KurrentDBConfig (..))
import Test.KurrentDB.Tmp.Instance qualified as Instance
import Test.KurrentDB.Tmp.Pool (Pool, PoolConfig (..), defaultPoolConfig, withInstance, withPool)

{- | Run action with a temporary KurrentDB Docker container.

The container is started, we wait for it to be ready, run the action, then clean up.
Uses a random port to avoid conflicts.

For faster tests, consider using 'withPool' and 'withInstance' instead.
-}
withTmpKurrentDB :: (KurrentDBConfig -> IO a) -> IO a
withTmpKurrentDB action = do
    -- Pick random port between 20000-30000
    grpcPort <- randomRIO (20000, 30000) :: IO Int
    bracket (Instance.startInstance grpcPort) Instance.stopInstance $ \inst -> do
        Instance.waitForReady inst
        action inst.config
