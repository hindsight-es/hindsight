{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}

{- |
Test for Streams.Append RPC call.

This test demonstrates calling the KurrentDB Streams.Append RPC using grapesy.
-}
module Main where

import Data.ByteString qualified as BS
import Data.Default (Default (..), def)
import Data.Map.Strict qualified as Map
import Data.ProtoLens (defMessage)
import Data.Proxy (Proxy (..))
import Data.Text qualified as T
import Data.Text.Encoding qualified as Text
import Data.UUID qualified as UUID
import Data.UUID.V4 qualified as UUID
import Data.Word (Word64)
import Lens.Micro ((&), (.~))
import Network.GRPC.Client qualified as GRPC
import Network.GRPC.Common (BuildMetadata (..), CustomMetadata (..), NoMetadata, RequestMetadata, ResponseInitialMetadata, ResponseTrailingMetadata)
import Network.GRPC.Common.Protobuf (Protobuf)
import Proto.Streams (AppendReq, AppendResp, Streams)
import System.Exit (exitFailure, exitSuccess)

-- KurrentDB requires 'type' and 'content-type' metadata on all requests
-- Note: gRPC uses "content-type" as a reserved header, so we use "content-type" via ES-ContentType
data KurrentMetadata = KurrentMetadata
    { eventType :: BS.ByteString
    , contentType :: BS.ByteString
    }
    deriving (Show)

instance Default KurrentMetadata where
    def = KurrentMetadata
        { eventType = "TestEvent"
        , contentType = "application/json"
        }

instance BuildMetadata KurrentMetadata where
    buildMetadata KurrentMetadata{..} =
        [ CustomMetadata "type" eventType
        , CustomMetadata "es-content-type" contentType  -- Use EventStore-specific header name
        ]

-- Define metadata type instances for the Streams.Append RPC
type instance RequestMetadata (Protobuf Streams "append") = KurrentMetadata
type instance ResponseInitialMetadata (Protobuf Streams "append") = NoMetadata
type instance ResponseTrailingMetadata (Protobuf Streams "append") = NoMetadata

main :: IO ()
main = do
    putStrLn "=== KurrentDB Append RPC Test ==="
    putStrLn "Attempting to connect to localhost:2113..."

    -- Create server address for KurrentDB
    let server = GRPC.ServerInsecure $ GRPC.Address
            { GRPC.addressHost = "localhost"
            , GRPC.addressPort = 2113
            , GRPC.addressAuthority = Nothing
            }

    -- Test append
    result <- GRPC.withConnection def server $ \conn -> do
        putStrLn "✓ Connection established"
        putStrLn "Making Streams.Append RPC call..."

        -- Make the RPC call with metadata (uses Default instance for KurrentMetadata)
        GRPC.withRPC conn def (Proxy @(Protobuf Streams "append")) $ \call -> do
            putStrLn "✓ RPC call opened with metadata"

            -- First message: Options (stream identifier + expected revision)
            streamId <- UUID.nextRandom
            let streamName = "test-stream-" <> Text.encodeUtf8 (UUID.toText streamId)
            let options = defMessage
                    & #streamIdentifier .~ (defMessage & #streamName .~ streamName)
                    & #noStream .~ defMessage  -- Expect stream doesn't exist

            let optionsReq = defMessage & #options .~ options
            GRPC.sendNextInput call optionsReq
            putStrLn $ "✓ Sent stream options for: " <> show streamName

            -- Second message: ProposedMessage (the event data)
            eventId <- UUID.nextRandom
            let eventData = "{\"test\": \"data\"}"
            let eventMetadata = Map.fromList
                    [ ("content-type", "application/json")
                    , ("type", "TestEvent")
                    ]
            let proposedMsg = defMessage
                    & #id .~ (defMessage
                        & #string .~ UUID.toText eventId)
                    & #data' .~ Text.encodeUtf8 eventData
                    & #metadata .~ eventMetadata

            let proposedReq = defMessage & #proposedMessage .~ proposedMsg
            GRPC.sendFinalInput call proposedReq
            putStrLn $ "✓ Sent event with metadata: " <> UUID.toString eventId

            -- Receive the response
            resp <- GRPC.recvOutput call
            putStrLn "✓ Received response from KurrentDB!"
            putStrLn $ "Response: " <> show resp

            return True

    if result
        then do
            putStrLn "✓ All tests passed!"
            exitSuccess
        else do
            putStrLn "✗ Test failed"
            exitFailure
