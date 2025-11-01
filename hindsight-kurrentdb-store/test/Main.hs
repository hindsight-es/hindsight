{-# LANGUAGE OverloadedStrings #-}

module Main where

import Hindsight.Store.KurrentDB
import Test.Tasty
import Test.Tasty.HUnit

main :: IO ()
main = defaultMain tests

tests :: TestTree
tests =
    testGroup
        "KurrentDB Store Tests"
        [ testGroup
            "Setup Tests"
            [ testCase "Package imports work" $ do
                -- Just verify the package compiles and imports work
                let cursor = KurrentCursor{commitPosition = 0, preparePosition = 0}
                commitPosition cursor @?= 0
                preparePosition cursor @?= 0
            , testCase "Store handle creation (stub)" $ do
                -- Basic store handle creation test (no actual connection yet)
                handle <- newKurrentStore "esdb://localhost:2113?tls=false"
                connectionString handle @?= "esdb://localhost:2113?tls=false"
                shutdownKurrentStore handle
            ]
        ]
