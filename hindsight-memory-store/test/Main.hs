module Main where

import Control.Monad (replicateM, void)
import Hindsight.Store.Memory
import Test.Hindsight.Store.TestRunner
import Test.Tasty

-- Memory store test runner
memoryStoreRunner :: EventStoreTestRunner MemoryStore
memoryStoreRunner =
  EventStoreTestRunner
    { withStore = \action -> do
        store <- newMemoryStore
        void $ action store,
      withStores = \n action -> do
        -- Memory store: each handle = separate backend (different in-memory state)
        -- This doesn't truly simulate multi-process sharing same storage,
        -- but we create N separate stores for API compatibility
        stores <- replicateM n newMemoryStore
        void $ action stores
    }

-- Test tree
memoryStoreTests :: TestTree
memoryStoreTests =
  testGroup
    "Memory Store Tests"
    [ testGroup "Generic Tests" (genericEventStoreTests memoryStoreRunner)
      -- Note: Multi-instance tests excluded for Memory store - not designed for multi-process
    ]

main :: IO ()
main = defaultMain memoryStoreTests
