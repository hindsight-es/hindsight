{-# LANGUAGE OverloadedStrings #-}

{- |
Simple gRPC connectivity test for KurrentDB.

This test verifies that we can establish a gRPC connection to KurrentDB.
-}
module Main where

import Network.GRPC.Client qualified as GRPC
import System.Exit (exitFailure, exitSuccess)
import Data.Default (def)

main :: IO ()
main = do
    putStrLn "=== KurrentDB gRPC Connectivity Test ==="
    putStrLn "Attempting to connect to localhost:2113..."

    -- Create server address for KurrentDB
    -- KurrentDB listens on port 2113 for gRPC (insecure in dev mode)
    let server = GRPC.ServerInsecure $ GRPC.Address
            { GRPC.addressHost = "localhost"
            , GRPC.addressPort = 2113
            , GRPC.addressAuthority = Nothing
            }

    -- Test connection with default connection parameters
    result <- GRPC.withConnection def server $ \conn -> do
        putStrLn "✓ Connection established successfully!"
        putStrLn "Connected to: localhost:2113"

        return True

    if result
        then do
            putStrLn "✓ All connectivity tests passed!"
            exitSuccess
        else do
            putStrLn "✗ Connectivity test failed"
            exitFailure
