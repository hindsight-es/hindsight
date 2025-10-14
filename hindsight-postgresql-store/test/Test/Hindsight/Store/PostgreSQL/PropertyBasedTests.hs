{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}

module Test.Hindsight.Store.PostgreSQL.PropertyBasedTests
  ( propertyBasedTests,
  )
where

import Control.Monad.IO.Class (liftIO)
import Data.Map.Strict qualified as Map
import Data.UUID.V4 qualified as UUID
import Hedgehog
import Hindsight.Store
import Hindsight.Store.PostgreSQL (SQLStore)
import Test.Hindsight.Store.Common (makeUserEvent)
import Test.Hindsight.PostgreSQL.Temp (defaultConfig, withTempPostgreSQL)
import Test.Tasty
import Test.Tasty.HUnit (assertFailure)
import Test.Tasty.Hedgehog


-- | Property-based tests for version expectations
propertyBasedTests :: IO TestTree
propertyBasedTests = do
  return $
    testGroup
      "Property-Based Version Tests"
      [testProperty "ExactVersion uniqueness" prop_exactVersionUniqueness]

-- | Property: No two operations with the same ExactVersion should succeed
prop_exactVersionUniqueness :: Property
prop_exactVersionUniqueness = property $ do
  test $ liftIO $ withTempPostgreSQL defaultConfig $ \store -> do
    streamId <- liftIO $ StreamId <$> UUID.nextRandom

    -- First, create the stream and get a cursor
    initResult <-
      insertEvents store Nothing $
        Transaction (Map.singleton streamId (StreamWrite NoStream [makeUserEvent 0]))

    cursor <- case initResult of
      SuccessfulInsertion{finalCursor = c} -> pure c
      FailedInsertion err -> assertFailure $ "Failed to initialize stream: " ++ show err

    -- Now try two operations with the same exact cursor
    let operation1 = Map.singleton streamId (StreamWrite (ExactVersion cursor) [makeUserEvent 1])
    let operation2 = Map.singleton streamId (StreamWrite (ExactVersion cursor) [makeUserEvent 2])

    result1 <- insertEvents store Nothing (Transaction operation1)
    result2 <- insertEvents store Nothing (Transaction operation2)

    let successes = length $ filter isSuccessfulInsertion [result1, result2]
    if successes == 1
      then pure ()
      else assertFailure $ "Expected exactly 1 success, got " ++ show successes

-- Helper functions
isSuccessfulInsertion :: InsertionResult backend -> Bool
isSuccessfulInsertion (SuccessfulInsertion{}) = True
isSuccessfulInsertion (FailedInsertion _) = False
