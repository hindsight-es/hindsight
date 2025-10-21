module Test.Hindsight (tree) where

import Test.Hindsight.Examples qualified
import Test.Tasty

tree :: IO TestTree
tree = do
    return $
        testGroup
            "Core Event Tests"
            [ Test.Hindsight.Examples.tree
            ]
