module Main where

import Control.Exception (bracket)
import Control.Monad (replicateM, void)
import Hindsight.Store.Filesystem
import System.Posix.Temp
import Test.Hindsight.Store.Filesystem (filesystemSpecificTests)
import Test.Hindsight.Store.TestRunner
import Test.Hindsight.Store.StressTests (stressTests)
import Test.Hindsight.Store.PropertyTests (propertyTests)
import Test.Hindsight.Store.OrderingTests (orderingTests)
import Test.Tasty

-- Filesystem store test runner
filesystemStoreRunner :: EventStoreTestRunner FilesystemStore
filesystemStoreRunner =
  EventStoreTestRunner
    { withStore = \action ->
        bracket
          ( do
              dir <- mkdtemp "/tmp/store-path"
              newFilesystemStore $ mkDefaultConfig dir
          )
          cleanupFilesystemStore
          (void . action),
      withStores = \n action -> do
        -- Create a temp directory and open N handles to it
        -- This simulates N processes accessing the same filesystem store
        dir <- mkdtemp "/tmp/store-path-multi"
        let config = mkDefaultConfig dir
        bracket
          (replicateM n (newFilesystemStore config))
          (\stores -> mapM_ cleanupFilesystemStore stores)
          (void . action)
    }

-- Test tree
filesystemStoreTests :: TestTree
filesystemStoreTests =
  testGroup
    "Filesystem Store Tests"
    [ testGroup "Generic Tests" (genericEventStoreTests filesystemStoreRunner),
      -- Multi-Instance Tests disabled temporarily (hangs on CI - suspected resource contention)
      -- testGroup "Multi-Instance Tests" (multiInstanceTests filesystemStoreRunner),
      testGroup "Stress Tests" (stressTests filesystemStoreRunner),
      propertyTests filesystemStoreRunner,
      testGroup "Ordering Tests" (orderingTests filesystemStoreRunner),
      testGroup "Store-Specific Tests" filesystemSpecificTests
    ]

main :: IO ()
main = defaultMain filesystemStoreTests
