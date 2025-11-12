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
Copyright   : (c) 2025
License     : BSD3
Maintainer  : gael@hindsight.events
Stability   : experimental

Example event definitions used in test suites and store backend tests.
-}
module Test.Hindsight.Examples where

import Data.Aeson
import Data.Proxy (Proxy (..))
import Data.Text qualified as T
import GHC.Generics (Generic)
import Hindsight
import Test.Hindsight.Instances ()
import Test.QuickCheck (Arbitrary (..))

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

-- | Arbitrary instances use deterministic Text generation from Test.Hindsight.Instances
instance Arbitrary UserInformation0 where
    arbitrary = UserInformation0 <$> arbitrary <*> arbitrary

instance Arbitrary UserInformation1 where
    arbitrary = UserInformation1 <$> arbitrary <*> arbitrary <*> arbitrary

instance Arbitrary UserInformation2 where
    arbitrary = UserInformation2 <$> arbitrary <*> arbitrary <*> arbitrary <*> arbitrary

-- * Tombstone Event for Test Coordination

-- | Tombstone event used to signal end of test data
type Tombstone = "tombstone"

-- | Simple payload for tombstone event
data TombstonePayload = TombstonePayload
    {marker :: T.Text}
    deriving stock (Show, Eq, Generic)
    deriving anyclass (FromJSON, ToJSON)

instance Arbitrary TombstonePayload where
    arbitrary = TombstonePayload <$> arbitrary

-- | Event definition for tombstone event (single version)
type instance MaxVersion Tombstone = 0

type instance Versions Tombstone = '[TombstonePayload]

instance Event Tombstone

-- | No upgrade needed for single version (uses default identity)
instance MigrateVersion 0 Tombstone

-- * Helper Functions

-- | Helper to create a test user event
makeUserEvent :: Int -> SomeLatestEvent
makeUserEvent userId =
    SomeLatestEvent (Proxy @UserCreated) $
        UserInformation2
            { userId = userId
            , userName = T.pack "user" <> T.pack (show userId)
            , userEmail = Just $ T.pack "user" <> T.pack (show userId) <> T.pack "@test.com"
            , likeability = 10
            }

-- | Helper to create a tombstone event
makeTombstone :: SomeLatestEvent
makeTombstone =
    SomeLatestEvent
        (Proxy @Tombstone)
        TombstonePayload
            { marker = T.pack "end_of_test"
            }
