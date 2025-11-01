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
        , testGroup
            "Multi-Stream Atomic Append Tests (Phase 2)"
            [ testCase "insertEvents - atomic append to multiple streams (success)" $ do
                -- Create config
                let config =
                        KurrentConfig
                            { host = "localhost"
                            , port = 2113
                            , secure = False
                            }

                -- Create store handle
                handle <- newKurrentStore config

                -- Generate stream IDs for 3 different streams
                streamUuid1 <- UUID.nextRandom
                streamUuid2 <- UUID.nextRandom
                streamUuid3 <- UUID.nextRandom
                let streamId1 = StreamId streamUuid1
                let streamId2 = StreamId streamUuid2
                let streamId3 = StreamId streamUuid3

                -- Create events for each stream
                let events1 = [makeUserEvent 1, makeUserEvent 2]
                let events2 = [makeUserEvent 3]
                let events3 = [makeUserEvent 4, makeUserEvent 5, makeUserEvent 6]

                -- Create transaction with multiple stream writes
                let transaction =
                        Transaction $
                            Map.fromList
                                [ (streamId1, StreamWrite{expectedVersion = NoStream, events = events1})
                                , (streamId2, StreamWrite{expectedVersion = NoStream, events = events2})
                                , (streamId3, StreamWrite{expectedVersion = NoStream, events = events3})
                                ]

                -- Insert events atomically
                result <- insertEvents @KurrentStore handle Nothing transaction

                -- Verify successful insertion
                case result of
                    SuccessfulInsertion success -> do
                        -- Verify we got a cursor back with non-zero position
                        let cursor = success.finalCursor
                        commitPosition cursor > 0 @?= True

                        -- Verify stream cursors contains all three streams
                        Map.member streamId1 success.streamCursors @?= True
                        Map.member streamId2 success.streamCursors @?= True
                        Map.member streamId3 success.streamCursors @?= True
                    FailedInsertion err ->
                        assertFailure $ "Expected successful insertion but got error: " ++ show err

                -- Cleanup
                shutdownKurrentStore handle
            -- BatchAppend DOES enforce version expectations! Re-enabled after investigation.
            -- KurrentDB returns ALREADY_EXISTS error with "WrongExpectedVersion" message.
            , testCase "insertEvents - atomic append all-or-nothing (version mismatch)" $ do
                -- Create config
                let config =
                        KurrentConfig
                            { host = "localhost"
                            , port = 2113
                            , secure = False
                            }

                -- Create store handle
                handle <- newKurrentStore config

                -- Generate stream IDs
                streamUuid1 <- UUID.nextRandom
                streamUuid2 <- UUID.nextRandom
                let streamId1 = StreamId streamUuid1
                let streamId2 = StreamId streamUuid2

                -- First, create streamId1 with some events
                let initialEvent = makeUserEvent 1
                let initialTransaction =
                        Transaction $
                            Map.singleton
                                streamId1
                                StreamWrite{expectedVersion = NoStream, events = [initialEvent]}

                result1 <- insertEvents @KurrentStore handle Nothing initialTransaction

                case result1 of
                    SuccessfulInsertion _ -> pure ()
                    FailedInsertion err ->
                        assertFailure $ "Initial insertion should succeed but got error: " ++ show err

                -- Now try to atomically append to both streams
                -- streamId1 exists (should use StreamExists), but we'll use NoStream (wrong!)
                -- streamId2 doesn't exist (NoStream is correct)
                let events1 = [makeUserEvent 2]
                let events2 = [makeUserEvent 3]

                let badTransaction =
                        Transaction $
                            Map.fromList
                                [ (streamId1, StreamWrite{expectedVersion = NoStream, events = events1}) -- Wrong! Stream exists
                                , (streamId2, StreamWrite{expectedVersion = NoStream, events = events2}) -- Correct
                                ]

                result2 <- insertEvents @KurrentStore handle Nothing badTransaction

                -- Verify we got a consistency error
                case result2 of
                    FailedInsertion (ConsistencyError (ConsistencyErrorInfo mismatches)) -> do
                        -- Should have at least one version mismatch for streamId1
                        length mismatches >= 1 @?= True
                        -- Verify streamId1 is in the mismatches
                        let streamIds = map (\vm -> vm.streamId) mismatches
                        (streamId1 `elem` streamIds) @?= True
                    FailedInsertion err ->
                        assertFailure $ "Expected ConsistencyError but got: " ++ show err
                    SuccessfulInsertion _ ->
                        assertFailure "Atomic append with version mismatch should have failed"

                -- Verify that streamId2 was NOT created (all-or-nothing)
                -- Try to insert to streamId2 with NoStream expectation
                let verifyTransaction =
                        Transaction $
                            Map.singleton
                                streamId2
                                StreamWrite{expectedVersion = NoStream, events = [makeUserEvent 10]}

                result3 <- insertEvents @KurrentStore handle Nothing verifyTransaction

                case result3 of
                    SuccessfulInsertion _ ->
                        pure () -- Good! streamId2 doesn't exist, so NoStream succeeds
                    FailedInsertion err ->
                        assertFailure $ "streamId2 should not exist (atomic rollback), but got error: " ++ show err

                -- Cleanup
                shutdownKurrentStore handle
            , testCase "insertEvents - multi-stream with mixed version expectations" $ do
                -- Create config
                let config =
                        KurrentConfig
                            { host = "localhost"
                            , port = 2113
                            , secure = False
                            }

                -- Create store handle
                handle <- newKurrentStore config

                -- Generate stream IDs
                streamUuid1 <- UUID.nextRandom
                streamUuid2 <- UUID.nextRandom
                let streamId1 = StreamId streamUuid1
                let streamId2 = StreamId streamUuid2

                -- Create streamId1 first
                let initialTransaction =
                        Transaction $
                            Map.singleton
                                streamId1
                                StreamWrite{expectedVersion = NoStream, events = [makeUserEvent 1]}

                result1 <- insertEvents @KurrentStore handle Nothing initialTransaction

                case result1 of
                    SuccessfulInsertion _ -> pure ()
                    FailedInsertion err ->
                        assertFailure $ "Initial insertion should succeed but got error: " ++ show err

                -- Now append to both streams with mixed expectations:
                -- streamId1: StreamExists (correct, it exists)
                -- streamId2: NoStream (correct, it doesn't exist)
                let mixedTransaction =
                        Transaction $
                            Map.fromList
                                [ (streamId1, StreamWrite{expectedVersion = StreamExists, events = [makeUserEvent 2]})
                                , (streamId2, StreamWrite{expectedVersion = NoStream, events = [makeUserEvent 3]})
                                ]

                result2 <- insertEvents @KurrentStore handle Nothing mixedTransaction

                -- Verify successful insertion
                case result2 of
                    SuccessfulInsertion success -> do
                        -- Verify we got cursors for both streams
                        Map.member streamId1 success.streamCursors @?= True
                        Map.member streamId2 success.streamCursors @?= True
                    FailedInsertion err ->
                        assertFailure $ "Expected successful insertion but got error: " ++ show err

                -- Cleanup
                shutdownKurrentStore handle
            ]
        ]
