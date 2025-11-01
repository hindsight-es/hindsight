{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}

module Main where

import Data.ByteString qualified as BS
import Data.Default (def)
import Data.Map.Strict qualified as Map
import Data.UUID.V4 qualified as UUID
import Hindsight.Store
import Hindsight.Store.KurrentDB
import Test.Hindsight.Store.Common (makeUserEvent)
import Test.Tasty
import Test.Tasty.HUnit

main :: IO ()
main = defaultMain tests

tests :: TestTree
tests =
    testGroup
        "KurrentDB Store Tests"
        [ testGroup
            "Unit Tests"
            [ testCase "KurrentCursor creation" $ do
                let cursor = KurrentCursor{commitPosition = 42, preparePosition = 43}
                commitPosition cursor @?= 42
                preparePosition cursor @?= 43
            ]
        , testGroup
            "Integration Tests"
            [ testCase "newKurrentStore and shutdown" $ do
                -- Create config for local KurrentDB
                let config =
                        KurrentConfig
                            { host = "localhost"
                            , port = 2113
                            , secure = False
                            }

                -- Create and shutdown store handle
                handle <- newKurrentStore config
                shutdownKurrentStore handle
            , testCase "insertEvents - single event to new stream" $ do
                -- Create config
                let config =
                        KurrentConfig
                            { host = "localhost"
                            , port = 2113
                            , secure = False
                            }

                -- Create store handle
                handle <- newKurrentStore config

                -- Generate stream ID
                streamUuid <- UUID.nextRandom
                let streamId = StreamId streamUuid

                -- Create test event
                let event = makeUserEvent 1

                -- Create transaction with single stream write
                let streamWrite =
                        StreamWrite
                            { expectedVersion = NoStream
                            , events = [event]
                            }
                let transaction = Transaction $ Map.singleton streamId streamWrite

                -- Insert events
                result <- insertEvents @KurrentStore handle Nothing transaction

                -- Verify successful insertion
                case result of
                    SuccessfulInsertion success -> do
                        -- Verify we got a cursor back with non-zero position
                        let cursor = success.finalCursor
                        -- KurrentDB maintains a global log, so position will be > 0
                        -- Just verify we got a reasonable position value
                        commitPosition cursor > 0 @?= True

                        -- Verify stream cursors contains our stream
                        Map.member streamId success.streamCursors @?= True
                    FailedInsertion err ->
                        assertFailure $ "Expected successful insertion but got error: " ++ show err

                -- Cleanup
                shutdownKurrentStore handle
            , testCase "insertEvents - multiple events to new stream" $ do
                -- Create config
                let config =
                        KurrentConfig
                            { host = "localhost"
                            , port = 2113
                            , secure = False
                            }

                -- Create store handle
                handle <- newKurrentStore config

                -- Generate stream ID
                streamUuid <- UUID.nextRandom
                let streamId = StreamId streamUuid

                -- Create multiple test events
                let events = [makeUserEvent 1, makeUserEvent 2, makeUserEvent 3]

                -- Create transaction with single stream write
                let streamWrite =
                        StreamWrite
                            { expectedVersion = NoStream
                            , events = events
                            }
                let transaction = Transaction $ Map.singleton streamId streamWrite

                -- Insert events
                result <- insertEvents @KurrentStore handle Nothing transaction

                -- Verify successful insertion
                case result of
                    SuccessfulInsertion success -> do
                        -- Verify we got a cursor back with non-zero position
                        let cursor = success.finalCursor
                        -- KurrentDB maintains a global log, so position will be > 0
                        commitPosition cursor > 0 @?= True

                        -- Verify stream cursors contains our stream
                        Map.member streamId success.streamCursors @?= True
                    FailedInsertion err ->
                        assertFailure $ "Expected successful insertion but got error: " ++ show err

                -- Cleanup
                shutdownKurrentStore handle
            , testCase "insertEvents - consistency check (NoStream on existing stream)" $ do
                -- Create config
                let config =
                        KurrentConfig
                            { host = "localhost"
                            , port = 2113
                            , secure = False
                            }

                -- Create store handle
                handle <- newKurrentStore config

                -- Generate stream ID
                streamUuid <- UUID.nextRandom
                let streamId = StreamId streamUuid

                -- Create first event
                let event1 = makeUserEvent 1

                -- Insert first event with NoStream expectation (should succeed)
                let streamWrite1 =
                        StreamWrite
                            { expectedVersion = NoStream
                            , events = [event1]
                            }
                let transaction1 = Transaction $ Map.singleton streamId streamWrite1

                result1 <- insertEvents @KurrentStore handle Nothing transaction1

                case result1 of
                    SuccessfulInsertion _ -> pure ()
                    FailedInsertion err ->
                        assertFailure $ "First insertion should succeed but got error: " ++ show err

                -- Try to insert second event with NoStream expectation (should fail)
                let event2 = makeUserEvent 2
                let streamWrite2 =
                        StreamWrite
                            { expectedVersion = NoStream
                            , events = [event2]
                            }
                let transaction2 = Transaction $ Map.singleton streamId streamWrite2

                result2 <- insertEvents @KurrentStore handle Nothing transaction2

                -- Verify we got a consistency error
                case result2 of
                    FailedInsertion (ConsistencyError (ConsistencyErrorInfo mismatches)) -> do
                        -- Verify the error contains a version mismatch for our stream
                        length mismatches @?= 1
                        case mismatches of
                            [VersionMismatch{streamId = errStreamId, expectedVersion = errExpected}] -> do
                                errStreamId @?= streamId
                                errExpected @?= NoStream
                            _ -> assertFailure "Expected single VersionMismatch in ConsistencyErrorInfo"
                    FailedInsertion err ->
                        assertFailure $ "Expected ConsistencyError but got: " ++ show err
                    SuccessfulInsertion _ ->
                        assertFailure "Second insertion with NoStream should have failed"

                -- Cleanup
                shutdownKurrentStore handle
            ]
        ]
