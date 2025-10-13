module Test.Hindsight (tree) where

import Test.Hindsight.Examples qualified
import Test.Tasty

-- CLEANUP: PostgreSQL tests moved to hindsight-postgresql-store package
-- CLEANUP: Projection tests moved to hindsight-postgresql-store package

tree :: IO TestTree
tree = do
  return $
    testGroup
      "Core Event Tests"
      [ Test.Hindsight.Examples.tree
      ]
