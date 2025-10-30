{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -Wno-orphans #-}

{- |
Module      : Test.Hindsight.Examples
Description : Example event definitions and test utilities
Copyright   : (c) 2024
License     : BSD3
Maintainer  : maintainer@example.com

Example event definitions used in test suites and store backend tests.
Includes utilities like 'DeterministicText' for reproducible testing.
-}
module Test.Hindsight.Examples where

import Data.Aeson
import Data.Proxy
import Data.Text (Text)
import Data.Text qualified as T
import GHC.Generics (Generic)
import Hindsight
import System.FilePath ((</>))
import Test.Hindsight.Generate
    ( createRoundtripTests,
      defaultTestConfig,
      createGoldenTests,
      TestConfig(goldenTestSizeParam, goldenPathFor, goldenTestCaseCount,
                 goldenTestSeed),
      showPeanoNat )
import Test.QuickCheck
import Test.Tasty

type UserCreated = "user_created"

type instance MaxVersion UserCreated = 2

type instance
    Versions UserCreated =
        '[UserInformation0, UserInformation1, UserInformation2]

instance Event UserCreated

-- Consecutive upcasts (define only version transitions)
instance Upcast 0 UserCreated where
    upcast UserInformation0{..} = UserInformation1{userEmail = Nothing, ..}

instance Upcast 1 UserCreated where
    upcast UserInformation1{..} = UserInformation2{likeability = 0, ..}

-- Automatic migration instances (using default consecutive composition)
instance MigrateVersion 0 UserCreated -- Automatic: V0 → V1 → V2
instance MigrateVersion 1 UserCreated -- Automatic: V1 → V2
instance MigrateVersion 2 UserCreated -- Automatic: V2 → V2 (identity)

-- | Version 0 of user information
data UserInformation0 = UserInformation0
    { userId :: Int
    , userName :: T.Text
    }
    deriving stock (Show, Eq, Generic)
    deriving anyclass (FromJSON, ToJSON)

-- | Version 1 of user information with optional email
data UserInformation1 = UserInformation1
    { userId :: Int
    , userName :: T.Text
    , userEmail :: Maybe T.Text
    }
    deriving stock (Show, Eq, Generic)
    deriving anyclass (FromJSON, ToJSON)

data UserInformation2 = UserInformation2
    { userId :: Int
    , userName :: T.Text
    , userEmail :: Maybe T.Text
    , likeability :: Int
    }
    deriving stock (Show, Eq, Generic)
    deriving anyclass (FromJSON, ToJSON)

{- | Newtype wrapper for deterministic Text generation in property tests.

TODO: Move this to a dedicated testing utilities module (e.g., Test.Hindsight.Util.Arbitrary)
once the test-lib structure is finalized. This is a general-purpose testing utility
that shouldn't be tied to the Examples module.
-}
newtype DeterministicText = DeterministicText Text
    deriving (Show, Eq)

instance Arbitrary DeterministicText where
    arbitrary = DeterministicText . T.pack <$> listOf (elements validChars)
      where
        -- Use only ASCII letters and numbers for deterministic generation
        validChars = ['a' .. 'z'] ++ ['A' .. 'Z'] ++ ['0' .. '9']

    -- Shrink by removing characters from the end
    shrink (DeterministicText t) =
        [DeterministicText (T.take n t) | n <- [0 .. T.length t - 1]]

-- Use deterministic text generation for UserInformation instances
instance Arbitrary UserInformation0 where
    arbitrary = do
        userId <- arbitrary
        DeterministicText userName <- arbitrary
        return $ UserInformation0 userId userName

    shrink (UserInformation0 uid uname) =
        [ UserInformation0 uid' uname'
        | (uid', DeterministicText uname') <- shrink (uid, DeterministicText uname)
        ]

instance Arbitrary UserInformation1 where
    arbitrary = do
        userId <- arbitrary
        DeterministicText userName <- arbitrary
        userEmail <- oneof [return Nothing, Just . (\(DeterministicText t) -> t) <$> arbitrary]
        return $ UserInformation1 userId userName userEmail

    shrink (UserInformation1 uid uname email) =
        [ UserInformation1 uid' uname' email''
        | (uid', DeterministicText uname', email') <-
            shrink (uid, DeterministicText uname, fmap DeterministicText email)
        , let email'' = fmap (\(DeterministicText t) -> t) email'
        ]

instance Arbitrary UserInformation2 where
    arbitrary = do
        userId <- arbitrary
        DeterministicText userName <- arbitrary
        userEmail <- oneof [return Nothing, Just . (\(DeterministicText t) -> t) <$> arbitrary]
        likeability <- arbitrary
        return $ UserInformation2 userId userName userEmail likeability

    shrink (UserInformation2 uid uname email lik) =
        [ UserInformation2 uid' uname' email'' lik'
        | (uid', DeterministicText uname', email', lik') <-
            shrink (uid, DeterministicText uname, fmap DeterministicText email, lik)
        , let email'' = fmap (\(DeterministicText t) -> t) email'
        ]

-- Example usage:
tree :: TestTree
tree =
    testGroup
        "Example Events"
        [ createRoundtripTests @UserCreated defaultTestConfig
        , -- Running only golden tests with custom config
          createGoldenTests @UserCreated customConfig
        ]
  where
    customConfig =
        defaultTestConfig
            { goldenPathFor = \(_ :: Proxy event) (_ :: Proxy ver) ->
                "golden" </> "events" </> getEventName event </> showPeanoNat @ver <> ".json"
            , goldenTestCaseCount = 10
            , goldenTestSeed = 12345
            , goldenTestSizeParam = 30 -- QuickCheck size parameter
            }
