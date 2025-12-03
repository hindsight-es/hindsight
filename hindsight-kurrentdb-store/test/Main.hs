{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}

module Main where

import Control.Monad (replicateM)
import Hindsight.Store.KurrentDB
import Test.Hindsight.Store (EventStoreTestRunner (..), genericEventStoreTests, multiInstanceTests, stressTests, propertyTests, orderingTests)
import Test.KurrentDB.Tmp (Pool, defaultPoolConfig, withInstance, withPool)
import Test.Tasty

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

tests :: EventStoreTestRunner KurrentStore -> TestTree
tests runner =
    testGroup
        "KurrentDB Store Tests"
        [ testGroup "Generic Event Store Tests" (genericEventStoreTests @KurrentStore runner)
        , testGroup "Multi-Instance Tests" (multiInstanceTests @KurrentStore runner)
        , testGroup "Stress Tests" (stressTests @KurrentStore runner)
        , propertyTests @KurrentStore runner
        , testGroup "Ordering Tests" (orderingTests @KurrentStore runner)
        ]
