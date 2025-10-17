module Main (main) where

import Test.Hindsight qualified
import Test.Tasty (defaultMain, testGroup)

main :: IO ()
main = do
  hindsightTree <- Test.Hindsight.tree
  let tree = testGroup "All tests" [hindsightTree]
  defaultMain tree
