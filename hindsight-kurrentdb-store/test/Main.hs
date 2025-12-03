{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}

module Main where

import Control.Monad (replicateM)
import Data.Map.Strict qualified as Map
import Data.UUID.V4 qualified as UUID
import Hindsight.Store
import Hindsight.Store.KurrentDB
import Test.Hindsight.Examples (makeUserEvent)
import Test.Hindsight.Store (EventStoreTestRunner (..), genericEventStoreTests, multiInstanceTests, stressTests, propertyTests, orderingTests)
import Test.KurrentDB.Tmp (KurrentDBConfig (..), Pool, defaultPoolConfig, withInstance, withPool, withTmpKurrentDB)
import Test.Tasty
import Test.Tasty.HUnit

main :: IO ()
main = withPool defaultPoolConfig $ \pool -> do
    let runner = pooledTestRunner pool
    defaultMain (tests runner)

-- | Test runner for KurrentDB backend using a pool for faster tests.
--
-- Instances are reused across tests. When released, the KurrentDB process
-- is restarted to clear in-memory state (~1-3s vs ~5-15s for full container).
pooledTestRunner :: Pool -> EventStoreTestRunner KurrentStore
pooledTestRunner pool =
    EventStoreTestRunner
        { withStore = \action -> do
            withInstance pool $ \tmpConfig -> do
                let config =
                        KurrentConfig
                            { host = tmpConfig.host
                            , port = tmpConfig.port
                            , secure = False
                            }
                handle <- newKurrentStore config
                _ <- action handle
                shutdownKurrentStore handle
        , withStores = \n action -> do
            -- Acquire ONE instance, create N handles to it
            -- Multi-instance tests need multiple handles to the SAME server
            withInstance pool $ \tmpConfig -> do
                let config =
                        KurrentConfig
                            { host = tmpConfig.host
                            , port = tmpConfig.port
                            , secure = False
                            }
                handles <- replicateM n (newKurrentStore config)
                _ <- action handles
                mapM_ shutdownKurrentStore handles
        }

-- | Legacy test runner using fresh containers per test (slower).
--
-- Kept for backward compatibility and debugging isolated issues.
legacyTestRunner :: EventStoreTestRunner KurrentStore
legacyTestRunner =
    EventStoreTestRunner
        { withStore = \action -> do
            withTmpKurrentDB $ \tmpConfig -> do
                let config =
                        KurrentConfig
                            { host = tmpConfig.host
                            , port = tmpConfig.port
                            , secure = False
                            }
                handle <- newKurrentStore config
                _ <- action handle
                shutdownKurrentStore handle
        , withStores = \n action -> do
            -- Each test gets its own isolated tmp-kurrentdb instance
            withTmpKurrentDB $ \tmpConfig -> do
                let config =
                        KurrentConfig
                            { host = tmpConfig.host
                            , port = tmpConfig.port
                            , secure = False
                            }
                handles <- mapM (const $ newKurrentStore config) [1 .. n]
                _ <- action handles
                mapM_ shutdownKurrentStore handles
        }

tests :: EventStoreTestRunner KurrentStore -> TestTree
tests runner =
    testGroup
        "KurrentDB Store Tests"
        [ testGroup "Generic Event Store Tests" (genericEventStoreTests @KurrentStore runner)
        , testGroup "Multi-Instance Tests" (multiInstanceTests @KurrentStore runner)
        , testGroup "Stress Tests" (stressTests @KurrentStore runner)
        , propertyTests @KurrentStore runner
        , testGroup "Ordering Tests" (orderingTests @KurrentStore runner)
        , testGroup "KurrentDB-Specific Tests" kurrentDbSpecificTests
        ]

-- | Tests specific to KurrentDB features (multi-stream atomic appends)
kurrentDbSpecificTests :: [TestTree]
kurrentDbSpecificTests =
    [ testCase "insertEvents - atomic append to multiple streams (success)" $ do
        withTmpKurrentDB $ \tmpConfig -> do
            let config =
                    KurrentConfig
                        { host = tmpConfig.host
                        , port = tmpConfig.port
                        , secure = False
                        }
            handle <- newKurrentStore config

            -- Generate two stream IDs
            streamUuid1 <- UUID.nextRandom
            streamUuid2 <- UUID.nextRandom
            let streamId1 = StreamId streamUuid1
            let streamId2 = StreamId streamUuid2

            -- Create events for both streams
            let events1 = [makeUserEvent 1, makeUserEvent 2]
            let events2 = [makeUserEvent 3, makeUserEvent 4]

            -- Create transaction with both streams
            let transaction =
                    Transaction $
                        Map.fromList
                            [ (streamId1, StreamWrite{expectedVersion = NoStream, events = events1})
                            , (streamId2, StreamWrite{expectedVersion = NoStream, events = events2})
                            ]

            -- Insert events atomically
            result <- insertEvents @KurrentStore handle Nothing transaction

            -- Verify successful insertion
            case result of
                SuccessfulInsertion _ -> pure ()
                FailedInsertion err ->
                    assertFailure $ "Multi-stream insertion failed: " ++ show err

            shutdownKurrentStore handle
    , testCase "insertEvents - atomic append all-or-nothing (version mismatch)" $ do
        withTmpKurrentDB $ \tmpConfig -> do
            let config =
                    KurrentConfig
                        { host = tmpConfig.host
                        , port = tmpConfig.port
                        , secure = False
                        }
            handle <- newKurrentStore config

            -- Generate two stream IDs
            streamUuid1 <- UUID.nextRandom
            streamUuid2 <- UUID.nextRandom
            let streamId1 = StreamId streamUuid1
            let streamId2 = StreamId streamUuid2

            -- Create first stream
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
                    assertFailure $ "streamId2 should not exist (all-or-nothing), but got error: " ++ show err

            shutdownKurrentStore handle
    , testCase "insertEvents - multi-stream with mixed version expectations" $ do
        withTmpKurrentDB $ \tmpConfig -> do
            let config =
                    KurrentConfig
                        { host = tmpConfig.host
                        , port = tmpConfig.port
                        , secure = False
                        }
            handle <- newKurrentStore config

            -- Generate three stream IDs
            streamUuid1 <- UUID.nextRandom
            streamUuid2 <- UUID.nextRandom
            streamUuid3 <- UUID.nextRandom
            let streamId1 = StreamId streamUuid1
            let streamId2 = StreamId streamUuid2
            let streamId3 = StreamId streamUuid3

            -- Create all three streams
            let initialTransaction =
                    Transaction $
                        Map.fromList
                            [ (streamId1, StreamWrite{expectedVersion = NoStream, events = [makeUserEvent 1]})
                            , (streamId2, StreamWrite{expectedVersion = NoStream, events = [makeUserEvent 2, makeUserEvent 3]})
                            , (streamId3, StreamWrite{expectedVersion = NoStream, events = [makeUserEvent 4, makeUserEvent 5, makeUserEvent 6]})
                            ]

            result1 <- insertEvents @KurrentStore handle Nothing initialTransaction

            case result1 of
                SuccessfulInsertion _ -> pure ()
                FailedInsertion err ->
                    assertFailure $ "Initial insertion should succeed but got error: " ++ show err

            -- Now append to all three streams with different expectations
            -- Stream versions after initial insert (0-indexed):
            -- streamId1: 1 event -> revision 0
            -- streamId2: 2 events -> revision 1
            -- streamId3: 3 events -> revision 2
            let mixedTransaction =
                    Transaction $
                        Map.fromList
                            [ (streamId1, StreamWrite{expectedVersion = StreamExists, events = [makeUserEvent 10]}) -- Any version OK
                            , (streamId2, StreamWrite{expectedVersion = ExactStreamVersion (StreamVersion 1), events = [makeUserEvent 11]}) -- Exact stream version
                            , (streamId3, StreamWrite{expectedVersion = StreamExists, events = [makeUserEvent 12]}) -- Any version OK
                            ]

            result2 <- insertEvents @KurrentStore handle Nothing mixedTransaction

            case result2 of
                SuccessfulInsertion _ -> pure ()
                FailedInsertion err ->
                    assertFailure $ "Mixed version expectations should succeed but got error: " ++ show err

            shutdownKurrentStore handle
    ]
