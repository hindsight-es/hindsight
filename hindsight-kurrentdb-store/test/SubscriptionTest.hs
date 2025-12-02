{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}

{- |
Manual test for event subscriptions.

This test:
1. Connects to KurrentDB
2. Inserts test events
3. Subscribes to those events
4. Verifies handlers are invoked correctly
-}
module Main where

import Control.Concurrent (threadDelay)
import Control.Concurrent.MVar
import Data.IORef
import Data.Map.Strict qualified as Map
import Data.UUID.V4 qualified as UUID
import Hindsight.Store
import Hindsight.Store.KurrentDB
import System.Exit (exitFailure, exitSuccess)
import System.IO (hFlush, stdout)
import Test.Hindsight.Store.Common (makeUserEvent)

main :: IO ()
main = do
    putStrLn "=== KurrentDB Subscription Test ==="
    putStrLn "This test requires a running KurrentDB instance on localhost:2113"
    putStrLn ""

    -- Create config for local KurrentDB
    let config =
            KurrentConfig
                { host = "localhost"
                , port = 2113
                , secure = False
                }

    -- Create store handle
    putStrLn "Connecting to KurrentDB..."
    handle <- newKurrentStore config
    putStrLn "✓ Connected"

    -- Generate unique stream ID
    streamUuid <- UUID.nextRandom
    let streamId = StreamId streamUuid
    putStrLn $ "Using stream: " ++ show streamUuid

    -- Create some test events
    putStrLn "\nInserting 3 test events..."
    let events = [makeUserEvent 1, makeUserEvent 2, makeUserEvent 3]
    let streamWrite =
            StreamWrite
                { expectedVersion = NoStream
                , events = events
                }
    let transaction = Transaction $ Map.singleton streamId streamWrite

    -- Insert events
    result <- insertEvents @KurrentStore handle Nothing transaction
    case result of
        SuccessfulInsertion success -> do
            putStrLn $ "✓ Events inserted at position: " ++ show (commitPosition success.finalCursor)
        FailedInsertion err -> do
            putStrLn $ "✗ Failed to insert events: " ++ show err
            shutdownKurrentStore handle
            exitFailure

    -- Wait a moment for events to be fully persisted
    threadDelay 100000  -- 100ms

    -- Track received events
    eventCounter <- newIORef (0 :: Int)
    receivedEvents <- newMVar []

    -- Create event handlers
    let handlers =
            (Proxy @"user_created", \envelope -> do
                count <- atomicModifyIORef' eventCounter (\n -> (n + 1, n + 1))
                modifyMVar_ receivedEvents $ \evts -> do
                    let evtInfo = (count, envelope.eventId, envelope.streamId)
                    putStrLn $ "  [" ++ show count ++ "] Received user_created: " ++ show envelope.eventId
                    hFlush stdout
                    pure (evtInfo : evts)

                -- Stop after receiving all 3 events
                if count >= 3
                    then do
                        putStrLn "  All events received, stopping subscription"
                        hFlush stdout
                        pure Stop
                    else pure Continue
            ) :? MatchEnd

    -- Subscribe to the specific stream
    putStrLn "\nSubscribing to stream..."
    let selector =
            EventSelector
                { streamId = SingleStream streamId
                , startupPosition = FromBeginning
                }

    subscription <- subscribe @KurrentStore handle handlers selector
    putStrLn "✓ Subscription started"

    -- Wait for subscription to process events (max 10 seconds)
    putStrLn "Waiting for events to be received..."
    let waitForEvents timeoutMs = do
            threadDelay 100000  -- Check every 100ms
            count <- readIORef eventCounter
            if count >= 3
                then do
                    putStrLn $ "\n✓ Received all " ++ show count ++ " events"
                    pure True
                else if timeoutMs <= 0
                    then do
                        putStrLn $ "\n✗ Timeout: only received " ++ show count ++ " events"
                        pure False
                    else waitForEvents (timeoutMs - 100)

    success <- waitForEvents 10000  -- 10 second timeout

    -- Verify results
    received <- readMVar receivedEvents
    putStrLn $ "\nReceived events: " ++ show (length received)

    -- Cleanup
    putStrLn "\nShutting down..."
    cancel subscription
    shutdownKurrentStore handle
    putStrLn "✓ Shutdown complete"

    if success
        then do
            putStrLn "\n✓ Subscription test passed!"
            exitSuccess
        else do
            putStrLn "\n✗ Subscription test failed"
            exitFailure
