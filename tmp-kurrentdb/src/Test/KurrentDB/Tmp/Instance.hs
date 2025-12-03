{- |
Module      : Test.KurrentDB.Tmp.Instance
Description : Single KurrentDB instance operations
Copyright   : (c) 2025
License     : BSD3
Maintainer  : gael@hindsight.events

Operations for managing a single KurrentDB Docker container instance.
Supports starting, stopping, restarting (to clear in-memory state), and health checking.
-}
module Test.KurrentDB.Tmp.Instance (
    -- * Types
    Instance (..),
    KurrentDBConfig (..),

    -- * Lifecycle
    startInstance,
    stopInstance,

    -- * State Management
    restartInstance,
    checkHealth,
    waitForReady,
) where

import Control.Concurrent (threadDelay)
import Control.Exception (SomeException, catch)
import Data.ByteString (ByteString)
import Data.ByteString.Char8 qualified as BS
import System.Process (readProcess)

-- | Configuration for connecting to a KurrentDB instance
data KurrentDBConfig = KurrentDBConfig
    { host :: ByteString
    , port :: Int
    }
    deriving (Show, Eq)

-- | A single KurrentDB Docker container instance
data Instance = Instance
    { containerId :: String
    -- ^ Docker container ID
    , config :: KurrentDBConfig
    -- ^ Connection configuration
    }
    deriving (Show, Eq)

-- | Docker image to use for KurrentDB
kurrentDbImage :: String
kurrentDbImage = "kurrentplatform/kurrentdb:25.1.0-experimental-arm64-8.0-jammy"

-- | Start a new KurrentDB Docker container on the specified port.
--
-- The container runs with in-memory database mode for fast testing.
-- Returns the Instance handle for managing the container.
startInstance :: Int -> IO Instance
startInstance grpcPort = do
    containerId <-
        fmap (filter (/= '\n')) $
            readProcess
                "docker"
                [ "run"
                , "-d"
                , "-p"
                , show grpcPort ++ ":2113"
                , "-e"
                , "EVENTSTORE_INSECURE=true"
                , "-e"
                , "EVENTSTORE_RUN_PROJECTIONS=All"
                , "-e"
                , "EVENTSTORE_CLUSTER_SIZE=1"
                , "-e"
                , "EVENTSTORE_MEM_DB=true"
                , kurrentDbImage
                ]
                ""

    let cfg =
            KurrentDBConfig
                { host = BS.pack "localhost"
                , port = grpcPort
                }

    pure Instance{containerId, config = cfg}

-- | Stop and remove a KurrentDB Docker container.
stopInstance :: Instance -> IO ()
stopInstance inst = do
    _ <- readProcess "docker" ["stop", inst.containerId] ""
    _ <- readProcess "docker" ["rm", inst.containerId] ""
    pure ()

-- | Restart the KurrentDB process inside the container.
--
-- This clears all in-memory state (since EVENTSTORE_MEM_DB=true) without
-- the overhead of destroying and recreating the Docker container.
-- Much faster than stop/start cycle (~1-3s vs ~5-15s).
--
-- Returns True if restart succeeded and instance is ready.
restartInstance :: Instance -> Int -> IO Bool
restartInstance inst timeout = do
    -- Use docker restart with 1 second grace period
    -- This sends SIGTERM, waits 1s, then SIGKILL if needed, then restarts
    _ <-
        catch
            (readProcess "docker" ["restart", "-t", "1", inst.containerId] "")
            (\(_ :: SomeException) -> pure "")

    -- Wait for the instance to become ready again
    waitForReadyWithTimeout inst timeout

-- | Check if the instance is healthy by probing the HTTP endpoint.
checkHealth :: Instance -> IO Bool
checkHealth inst = tryHttp inst.config.port

-- | Wait for instance to become ready, with default 60 second timeout.
waitForReady :: Instance -> IO ()
waitForReady inst = do
    success <- waitForReadyWithTimeout inst 60
    if success
        then pure ()
        else error $ "KurrentDB failed to start after 60 seconds on port " ++ show inst.config.port

-- | Wait for instance to become ready with specified timeout.
--
-- Returns True if instance became ready within timeout.
waitForReadyWithTimeout :: Instance -> Int -> IO Bool
waitForReadyWithTimeout inst maxAttempts = go 1
  where
    go attempt
        | attempt > maxAttempts = pure False
        | otherwise = do
            success <- tryHttp inst.config.port
            if success
                then pure True
                else do
                    threadDelay 1000000 -- 1 second
                    go (attempt + 1)

-- | Try to fetch from HTTP health endpoint.
--
-- Returns True if curl succeeds, False otherwise.
tryHttp :: Int -> IO Bool
tryHttp port = do
    catch attempt handler
  where
    attempt = do
        _ <- readProcess "curl" ["-s", "-f", "http://localhost:" ++ show port ++ "/health/live"] ""
        pure True

    handler :: SomeException -> IO Bool
    handler _ = pure False
