{- |
Module      : Test.KurrentDB.Tmp.Pool
Description : Pool of KurrentDB instances for fast test execution
Copyright   : (c) 2025
License     : BSD3
Maintainer  : gael@hindsight.events

A pool of KurrentDB Docker containers that can be reused across tests.
When an instance is released, its KurrentDB process is restarted asynchronously
to clear in-memory state. The next test can immediately grab another instance
from the pool while the restart happens in the background.

Thread-safe using STM for concurrent test execution.
-}
module Test.KurrentDB.Tmp.Pool (
    -- * Types
    Pool,
    PoolConfig (..),
    defaultPoolConfig,

    -- * Pool Lifecycle
    createPool,
    destroyPool,
    withPool,

    -- * Instance Acquisition
    acquireInstance,
    releaseInstance,
    withInstance,

    -- * Re-exports
    Instance (..),
    KurrentDBConfig (..),
) where

import Control.Concurrent (forkIO)
import Control.Concurrent.Async (mapConcurrently, mapConcurrently_)
import Control.Concurrent.STM
import Control.Exception (bracket, mask, onException)
import System.IO (hPutStrLn, stderr)
import System.Random (randomRIO)
import Test.KurrentDB.Tmp.Instance

-- | Pool configuration
data PoolConfig = PoolConfig
    { poolSize :: Int
    -- ^ Number of instances to maintain (default: 4)
    , startupTimeout :: Int
    -- ^ Seconds to wait for initial startup (default: 60)
    , restartTimeout :: Int
    -- ^ Seconds to wait after restart (default: 30)
    , portRangeStart :: Int
    -- ^ Starting port for allocation (default: 20000)
    }
    deriving (Show, Eq)

-- | Default pool configuration
defaultPoolConfig :: PoolConfig
defaultPoolConfig =
    PoolConfig
        { poolSize = 4
        , startupTimeout = 60
        , restartTimeout = 30
        , portRangeStart = 20000
        }

-- | A pooled instance with ready signaling
data PooledInstance = PooledInstance
    { instance_ :: Instance
    , ready :: TMVar ()
    -- ^ Filled when instance is ready for use
    }

-- | Pool of KurrentDB instances
data Pool = Pool
    { config :: PoolConfig
    -- ^ Pool configuration
    , instances :: TVar [PooledInstance]
    -- ^ All instances in the pool
    , available :: TQueue PooledInstance
    -- ^ Queue of available instances (FIFO for fairness)
    }

-- | Create and start a pool of KurrentDB instances.
--
-- Starts all containers in parallel, waits for readiness.
-- Throws if any container fails to start within timeout.
createPool :: PoolConfig -> IO Pool
createPool cfg = do
    hPutStrLn stderr $ "Creating KurrentDB pool with " ++ show cfg.poolSize ++ " instances..."

    -- Generate random ports for each instance
    ports <- mapM (\i -> randomRIO (cfg.portRangeStart + i * 100, cfg.portRangeStart + i * 100 + 99)) [0 .. cfg.poolSize - 1]

    -- Start all instances in parallel
    insts <- mapConcurrently startInstance ports

    -- Wait for all to be ready (in parallel)
    mapConcurrently_ waitForReady insts

    hPutStrLn stderr $ "KurrentDB pool ready with " ++ show (length insts) ++ " instances"

    -- Wrap instances with ready signals (all start ready)
    pooledInsts <- mapM wrapInstance insts

    -- Create STM state
    instancesVar <- newTVarIO pooledInsts
    availableQueue <- newTQueueIO
    atomically $ mapM_ (writeTQueue availableQueue) pooledInsts

    pure
        Pool
            { config = cfg
            , instances = instancesVar
            , available = availableQueue
            }
  where
    wrapInstance inst = do
        readyVar <- newTMVarIO () -- Start ready
        pure PooledInstance{instance_ = inst, ready = readyVar}

-- | Gracefully shutdown the pool.
--
-- Stops all containers and cleans up resources.
destroyPool :: Pool -> IO ()
destroyPool pool = do
    hPutStrLn stderr "Destroying KurrentDB pool..."
    pooledInsts <- atomically $ readTVar pool.instances
    mapConcurrently_ (stopInstance . instance_) pooledInsts
    hPutStrLn stderr "KurrentDB pool destroyed"

-- | Bracket-style pool usage.
--
-- Creates pool, runs action, destroys pool (even on exception).
withPool :: PoolConfig -> (Pool -> IO a) -> IO a
withPool cfg = bracket (createPool cfg) destroyPool

-- | Acquire an instance from the pool.
--
-- Takes an instance from the queue and waits for it to be ready.
-- If a restart is in progress, blocks until complete.
acquireInstance :: Pool -> IO Instance
acquireInstance pool = do
    pooledInst <- atomically $ readTQueue pool.available
    -- Wait for instance to be ready (blocks if restart in progress)
    atomically $ takeTMVar pooledInst.ready
    pure pooledInst.instance_

-- | Release an instance back to the pool.
--
-- Kicks off async restart and immediately returns.
-- The restart happens in background; instance goes back to queue.
-- Next acquireInstance will wait if restart not yet complete.
releaseInstance :: Pool -> Instance -> IO ()
releaseInstance pool inst = do
    -- Find the PooledInstance wrapper
    pooledInsts <- atomically $ readTVar pool.instances
    case filter (\p -> p.instance_.containerId == inst.containerId) pooledInsts of
        (pooledInst : _) -> do
            -- Put back in queue immediately
            atomically $ writeTQueue pool.available pooledInst
            -- Restart async - fills ready signal when done
            _ <- forkIO $ do
                _ <- restartInstance inst pool.config.restartTimeout
                atomically $ putTMVar pooledInst.ready ()
            pure ()
        [] -> pure () -- Instance not found, ignore

-- | Bracket-style instance usage.
--
-- Acquires instance, runs action, releases instance.
-- Guarantees the instance is released even if action throws.
withInstance :: Pool -> (KurrentDBConfig -> IO a) -> IO a
withInstance pool action = mask $ \restore -> do
    inst <- acquireInstance pool
    result <- restore (action inst.config) `onException` releaseInstance pool inst
    releaseInstance pool inst
    pure result
