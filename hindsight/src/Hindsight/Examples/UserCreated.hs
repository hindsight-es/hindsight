{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DefaultSignatures #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE QuantifiedConstraints #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UndecidableInstances #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Hindsight.Examples.UserCreated where

-- import Data.Aeson
-- import Data.Text qualified as T
-- import GHC.Generics (Generic)
-- import Hindsight.Core

-- type UserCreated = 'Event "user_created"

-- instance EventVersionInfo UserCreated where
--   type MaxVersion UserCreated = 2

-- instance EventVersionPayloads UserCreated where
--   type
--     VersionedPayloads UserCreated =
--       UserInformation0
--         :>> UserInformation1
--         :>| UserInformation2

-- instance UpgradableToLatest UserCreated 2 where
--   upgradeToLatest = id

-- instance UpgradableToLatest UserCreated 1 where
--   upgradeToLatest UserInformation1 {..} = UserInformation2 {likeability = 0, ..}

-- instance UpgradableToLatest UserCreated 0 where
--   upgradeToLatest UserInformation0 {..} = upgradeToLatest @UserCreated @1 UserInformation1 {userEmail = Nothing, ..}

-- -- | Version 0 of user information
-- data UserInformation0 = UserInformation0
--   { userId :: Int,
--     userName :: T.Text
--   }
--   deriving stock (Show, Eq, Generic)
--   deriving anyclass (FromJSON, ToJSON)

-- -- | Version 1 of user information with optional email
-- data UserInformation1 = UserInformation1
--   { userId :: Int,
--     userName :: T.Text,
--     userEmail :: Maybe T.Text
--   }
--   deriving stock (Show, Eq, Generic)
--   deriving anyclass (FromJSON, ToJSON)

-- data UserInformation2 = UserInformation2
--   { userId :: Int,
--     userName :: T.Text,
--     userEmail :: Maybe T.Text,
--     likeability :: Int
--   }
--   deriving stock (Show, Eq, Generic)
--   deriving anyclass (FromJSON, ToJSON)
