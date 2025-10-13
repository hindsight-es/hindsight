{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Test.Hindsight.Store.Common where

import Data.Aeson (FromJSON, ToJSON)
import Data.Proxy (Proxy (..))
import Data.Text (Text, pack)
import GHC.Generics (Generic)
import Hindsight.Core
import Test.Hindsight.Examples
import Test.QuickCheck (Arbitrary (..))
import Test.QuickCheck.Instances.Text ()

-- | Tombstone event used to signal end of test data
type Tombstone = "tombstone"

-- | Simple payload for tombstone event
data TombstonePayload = TombstonePayload
  {marker :: Text}
  deriving (Show, Eq, Generic, FromJSON, ToJSON)

instance Arbitrary TombstonePayload where
  arbitrary = TombstonePayload <$> arbitrary

-- | Event definition for tombstone event (single version)
type instance MaxVersion Tombstone = 0

type instance Versions Tombstone = FirstVersion TombstonePayload

instance Event Tombstone

-- | No upgrade needed for single version
instance UpgradableToLatest Tombstone 0 where
  upgradeToLatest = id

-- | Helper to create a test user event
makeUserEvent :: Int -> SomeLatestEvent
makeUserEvent userId =
  SomeLatestEvent (Proxy @UserCreated) $
    UserInformation2
      { userId = userId,
        userName = "user" <> pack (show userId),
        userEmail = Just $ "user" <> pack (show userId) <> "@test.com",
        likeability = 10
      }

-- | Helper to create a tombstone event
makeTombstone :: SomeLatestEvent
makeTombstone =
  SomeLatestEvent
    (Proxy @Tombstone)
    TombstonePayload
      { marker = "end_of_test"
      }
