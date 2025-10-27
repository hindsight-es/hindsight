{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Test.Hindsight.Store.Common where

import Control.Concurrent (MVar, putMVar)
import Data.Aeson (FromJSON, ToJSON)
import Data.IORef (IORef, atomicModifyIORef')
import Data.Maybe (mapMaybe)
import Data.Proxy (Proxy (..))
import Data.Text (Text, pack)
import Data.Typeable (cast)
import GHC.Generics (Generic)
import Hindsight.Events
import Hindsight.Store (EventEnvelope (EventWithMetadata), EventHandler, SubscriptionResult (Continue, Stop))
import Test.Hindsight.Examples
import Test.QuickCheck (Arbitrary (..))
import Test.QuickCheck.Instances.Text ()

-- | Tombstone event used to signal end of test data
type Tombstone = "tombstone"

-- | Simple payload for tombstone event
data TombstonePayload = TombstonePayload
    {marker :: Text}
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

-- | Helper to create a test user event
makeUserEvent :: Int -> SomeLatestEvent
makeUserEvent userId =
    SomeLatestEvent (Proxy @UserCreated) $
        UserInformation2
            { userId = userId
            , userName = "user" <> pack (show userId)
            , userEmail = Just $ "user" <> pack (show userId) <> "@test.com"
            , likeability = 10
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
    deriving stock (Show, Eq, Generic)
    deriving anyclass (FromJSON, ToJSON)

instance Arbitrary CounterIncPayload where
    arbitrary = pure CounterIncPayload

type instance MaxVersion CounterInc = 0
type instance Versions CounterInc = '[CounterIncPayload]
instance Event CounterInc
instance MigrateVersion 0 CounterInc

-- | Counter stop event for testing subscription stop behavior
type CounterStop = "counter_stop"

data CounterStopPayload = CounterStopPayload
    deriving stock (Show, Eq, Generic)
    deriving anyclass (FromJSON, ToJSON)

instance Arbitrary CounterStopPayload where
    arbitrary = pure CounterStopPayload

type instance MaxVersion CounterStop = 0
type instance Versions CounterStop = '[CounterStopPayload]
instance Event CounterStop
instance MigrateVersion 0 CounterStop

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
    deriving stock (Show, Eq, Generic)
    deriving anyclass (FromJSON, ToJSON)

instance Arbitrary CounterFailPayload where
    arbitrary = pure CounterFailPayload

type instance MaxVersion CounterFail = 0
type instance Versions CounterFail = '[CounterFailPayload]
instance Event CounterFail
instance MigrateVersion 0 CounterFail

-- | Helper to create a counter fail event
makeCounterFail :: SomeLatestEvent
makeCounterFail =
    SomeLatestEvent
        (Proxy @CounterFail)
        CounterFailPayload

-- * Event Handler Helpers

-- | Collect events until tombstone is encountered
collectEventsUntilTombstone :: IORef [EventEnvelope UserCreated backend] -> EventHandler UserCreated IO backend
collectEventsUntilTombstone ref event = do
    atomicModifyIORef' ref (\events -> (event : events, ()))
    pure Continue

-- | Handle tombstone event by signaling completion
handleTombstone :: MVar () -> EventHandler Tombstone IO backend
handleTombstone completionVar _ = do
    putMVar completionVar ()
    pure Stop

-- | Extract UserInformation2 from event envelope
extractUserInfo :: EventEnvelope UserCreated backend -> Maybe UserInformation2
extractUserInfo (EventWithMetadata _ _ _ _ _ _ payload) = cast payload
