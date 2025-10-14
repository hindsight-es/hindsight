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

-- | Counter increment event for testing subscription stop behavior
type CounterInc = "counter_inc"

data CounterIncPayload = CounterIncPayload
  deriving (Show, Eq, Generic, FromJSON, ToJSON)

instance Arbitrary CounterIncPayload where
  arbitrary = pure CounterIncPayload

type instance MaxVersion CounterInc = 0
type instance Versions CounterInc = FirstVersion CounterIncPayload
instance Event CounterInc
instance UpgradableToLatest CounterInc 0 where
  upgradeToLatest = id

-- | Counter stop event for testing subscription stop behavior
type CounterStop = "counter_stop"

data CounterStopPayload = CounterStopPayload
  deriving (Show, Eq, Generic, FromJSON, ToJSON)

instance Arbitrary CounterStopPayload where
  arbitrary = pure CounterStopPayload

type instance MaxVersion CounterStop = 0
type instance Versions CounterStop = FirstVersion CounterStopPayload
instance Event CounterStop
instance UpgradableToLatest CounterStop 0 where
  upgradeToLatest = id

-- | Helper to create a counter increment event
makeCounterInc :: SomeLatestEvent
makeCounterInc =
  SomeLatestEvent
    (Proxy @CounterInc)
    CounterIncPayload

-- | Helper to create a counter stop event
makeCounterStop :: SomeLatestEvent
makeCounterStop =
  SomeLatestEvent
    (Proxy @CounterStop)
    CounterStopPayload

-- | Counter fail event for testing exception handling
type CounterFail = "counter_fail"

data CounterFailPayload = CounterFailPayload
  deriving (Show, Eq, Generic, FromJSON, ToJSON)

instance Arbitrary CounterFailPayload where
  arbitrary = pure CounterFailPayload

type instance MaxVersion CounterFail = 0
type instance Versions CounterFail = FirstVersion CounterFailPayload
instance Event CounterFail
instance UpgradableToLatest CounterFail 0 where
  upgradeToLatest = id

-- | Helper to create a counter fail event
makeCounterFail :: SomeLatestEvent
makeCounterFail =
  SomeLatestEvent
    (Proxy @CounterFail)
    CounterFailPayload
