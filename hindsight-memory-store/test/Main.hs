module Main where

import Control.Monad (void)
import Hindsight.Store.Memory
import Test.Hindsight.Store.OrderingTests (orderingTests)
import Test.Hindsight.Store.PropertyTests (propertyTests)
import Test.Hindsight.Store.StressTests (stressTests)
import Test.Hindsight.Store.TestRunner
import Test.Tasty

-- Memory store test runner
memoryStoreRunner :: EventStoreTestRunner MemoryStore
memoryStoreRunner =
    EventStoreTestRunner
        { withStore = \action -> do
            store <- newMemoryStore
            void $ action store
        , withStores = \_ _ ->
            error "Cannot create multiple instances of a memory store sharing the same storage."
        }

-- Test tree
memoryStoreTests :: TestTree
memoryStoreTests =
    testGroup
        "Memory Store Tests"
        [ testGroup "Generic Tests" (genericEventStoreTests memoryStoreRunner)
        , testGroup "Stress Tests" (stressTests memoryStoreRunner)
        , propertyTests memoryStoreRunner
        , testGroup "Ordering Tests" (orderingTests memoryStoreRunner)
        -- Note: Multi-instance tests excluded for Memory store - not designed for multi-process
        ]

main :: IO ()
main = defaultMain memoryStoreTests
