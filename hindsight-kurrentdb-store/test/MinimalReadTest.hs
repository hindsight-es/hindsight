{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}

{- | Minimal test for Streams.Read RPC call -}
module Main where

import Data.Default (def)
import Data.ProtoLens (defMessage)
import Data.Proxy (Proxy (..))
import Hindsight.Store.KurrentDB.RPC ()  -- Import metadata type instances
import Lens.Micro ((&), (.~))
import Network.GRPC.Client qualified as GRPC
import Network.GRPC.Common.Protobuf (Proto (..), Protobuf)
import Network.GRPC.Common.StreamElem (StreamElem (..))
import Proto.Streams (Streams)
import Proto.Streams qualified as Proto
import Proto.Streams_Fields qualified as Fields
import System.Exit (exitFailure, exitSuccess)
import System.IO (hFlush, stdout)

main :: IO ()
main = do
    putStrLn "=== Minimal KurrentDB Read RPC Test ==="
    putStrLn "Attempting to connect to localhost:2113..."

    -- Create server address for KurrentDB
    let server = GRPC.ServerInsecure $ GRPC.Address
            { GRPC.addressHost = "localhost"
            , GRPC.addressPort = 2113
            , GRPC.addressAuthority = Nothing
            }

    -- Test read subscription
    result <- GRPC.withConnection def server $ \conn -> do
        putStrLn "✓ Connection established"
        putStrLn "Making Streams.Read RPC call..."

        -- Build minimal ReadReq for $all stream from beginning
        let allOptions = defMessage
                & #maybe'allOption .~ Just (Proto.ReadReq'Options'AllOptions'Start defMessage)

        let uuidOption = defMessage
                & #maybe'content .~ Just (Proto.ReadReq'Options'UUIDOption'String defMessage)

        let options = defMessage
                & #maybe'streamOption .~ Just (Proto.ReadReq'Options'All allOptions)
                & #readDirection .~ Proto.ReadReq'Options'Forwards
                & #resolveLinks .~ False
                & #maybe'countOption .~ Just (Proto.ReadReq'Options'Subscription defMessage)
                & #maybe'filterOption .~ Just (Proto.ReadReq'Options'NoFilter defMessage)
                & #uuidOption .~ uuidOption

        let request = defMessage & #options .~ options

        GRPC.withRPC conn def (Proxy @(Protobuf Streams "read")) $ \call -> do
            putStrLn "✓ RPC call opened"

            -- Send the subscription request
            GRPC.sendFinalInput call (Proto request)
            putStrLn "✓ Sent subscription request"
            hFlush stdout

            -- Try to receive first response (should be Confirmation or similar)
            putStrLn "Waiting for first response..."
            hFlush stdout

            mbResp <- GRPC.recvOutput call
            case mbResp of
                StreamElem (Proto resp) -> do
                    putStrLn $ "✓ Received response: " ++ show resp
                    pure True
                FinalElem (Proto resp) _ -> do
                    putStrLn $ "✓ Received final response: " ++ show resp
                    pure True
                NoMoreElems _ -> do
                    putStrLn "✗ Stream ended with no messages"
                    pure False

    if result
        then do
            putStrLn "✓ Test passed!"
            exitSuccess
        else do
            putStrLn "✗ Test failed"
            exitFailure
