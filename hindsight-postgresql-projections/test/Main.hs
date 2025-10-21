module Main where

import Test.Hindsight.Projection (projectionTests)
import Test.Tasty

main :: IO ()
main = defaultMain projectionTests
