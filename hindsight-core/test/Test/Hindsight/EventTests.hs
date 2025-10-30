{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE RequiredTypeArguments #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -Wno-orphans #-}

{- |
Module      : Test.Hindsight.EventTests
Description : Example event definitions and test utilities
Copyright   : (c) 2024
License     : BSD3
Maintainer  : gael.deest@franbec.org

Roundtrip and golden tests for example event definitions
-}
module Test.Hindsight.EventTests where

import Data.Aeson
import Data.Proxy
import Data.Text (Text)
import Data.Text qualified as T
import GHC.Generics (Generic)
import Hindsight
import System.FilePath ((</>))
import Test.Hindsight.Examples
import Test.Hindsight.Generate (
    GoldenTestConfig (..),
    createGoldenTests,
    createRoundtripTests,
    defaultGoldenTestConfig,
 )
import Test.Tasty

tree :: TestTree
tree =
    testGroup
        "Example Events"
        [ createRoundtripTests UserCreated
        , -- Running only golden tests with custom config
          createGoldenTests UserCreated goldenTestConfig
        ]
  where
    goldenTestConfig =
        defaultGoldenTestConfig
            { goldenPathFor = \(_ :: Proxy event) (_ :: Proxy ver) ->
                "golden" </> "events" </> getEventName event </> show (reifyPeanoNat @ver) <> ".json"
            , goldenTestCaseCount = 10
            , goldenTestSeed = 12345
            , goldenTestSizeParam = 30 -- QuickCheck size parameter
            }
