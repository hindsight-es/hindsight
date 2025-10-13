{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}

{-|
Module      : Hindsight.TH
Description : Template Haskell helpers for event definition
Copyright   : (c) 2024
License     : BSD3
Maintainer  : maintainer@example.com
Stability   : experimental

This module provides Template Haskell helpers to reduce boilerplate when
defining events and upgrade chains.

= Basic Usage

@
-- Single event, version 0
defineEvent "user_created" [''UserInfo]

-- Multi-version event with identity upgrades
defineEvent "user_updated" [''UserV0, ''UserV1, ''UserV2]
@

= Bulk Event Definitions

@
defineEvents
  [ ("user_created", [''UserInfo])
  , ("user_updated", [''UserV0, ''UserV1])
  , ("user_deleted", [''UserDeletion])  
  ]
@

= Custom Upgrade Chains

@
-- Version numbers inferred from list position (0, 1, 2...)
defineEventWithUpgrades "order_placed"
  [ ''OrderV0, ''OrderV1, ''OrderV2 ]  -- Versions 0, 1, 2
  [ [| \\(OrderV0 a) -> OrderV2 a Nothing [] |]     -- 0 -> 2 (latest)
  , [| \\(OrderV1 a b) -> OrderV2 a b [] |]         -- 1 -> 2 (latest)
  ]

@

This generates all necessary Event and UpgradableToLatest instances.
-}
module Hindsight.TH 
  ( defineEvent
  , defineEventSimple
  , defineEvents
  , defineEventWithUpgrades
  -- Convenience functions for single-type events
  , defineEventSingle
  , defineEventSimpleSingle
  -- Split declaration functions to work around GHC limitations
  , defineMaxVersion
  , defineEventMaxVersion  -- DEPRECATED
  , defineEventVersions
  , defineEventVersionsOnly
  , defineEventVersionsWithUpgrades
  ) where

import Language.Haskell.TH
import Control.Monad (when)
import Hindsight.Core (Event, UpgradableToLatest, upgradeToLatest, MaxVersion, Versions, (:>>), (:>|), V1, V2, V3, V4, V5)

-- | Generate Event instance and UpgradableToLatest instances from payload types
--
-- @defineEvent "user_created" [''UserInfo0, ''UserInfo1, ''UserInfo2]@
--
-- Generates all necessary instances with identity upgrade functions.
-- You can override specific UpgradableToLatest instances afterward for custom logic.
-- 
-- IMPORTANT: Due to GHC's type family dependency resolution, you may need to use
-- this in multiple splices if you get kind errors:
-- @
-- defineEvent "user_created" [''UserInfo]
-- -- or split like:
-- $(defineEventMaxVersion "user_created" [''UserInfo])
-- $(defineEventVersions "user_created" [''UserInfo])
-- @
defineEvent :: String -> [Name] -> DecsQ
defineEvent eventName payloadTypeNames = do
  let payloadTypes = map conT payloadTypeNames
  eventInstance <- generateEventInstance eventName payloadTypes
  upgradeInstances <- generateUpgradeInstances eventName payloadTypes
  return (eventInstance ++ upgradeInstances)

-- | Generate only the Event instance (no UpgradableToLatest instances)
--
-- Useful when you want to define all upgrade logic manually.
defineEventSimple :: String -> [Name] -> DecsQ  
defineEventSimple eventName payloadTypeNames = do
  let payloadTypes = map conT payloadTypeNames
  generateEventInstance eventName payloadTypes

-- | Generate the main Event instance
generateEventInstance :: String -> [TypeQ] -> DecsQ
generateEventInstance eventName payloadTypes = do
  let eventNameType = LitT (StrTyLit eventName)
  let maxVer = fromIntegral (length payloadTypes - 1)
  versionsType <- buildVersionsType payloadTypes
  
  -- Try the original approach but with all declarations in proper order
  [d| type instance MaxVersion $(return eventNameType) = $(litT (numTyLit maxVer))
      type instance Versions $(return eventNameType) = $(return versionsType)
      instance Event $(return eventNameType)
    |]

-- | Build the Versions type from a list of payload types
buildVersionsType :: [TypeQ] -> TypeQ
buildVersionsType [] = error "defineEvent: Empty payload list"
buildVersionsType [t] = [t| V1 $t |]
buildVersionsType [t1, t2] = [t| V2 $t1 $t2 |]
buildVersionsType [t1, t2, t3] = [t| V3 $t1 $t2 $t3 |]
buildVersionsType [t1, t2, t3, t4] = [t| V4 $t1 $t2 $t3 $t4 |]
buildVersionsType [t1, t2, t3, t4, t5] = [t| V5 $t1 $t2 $t3 $t4 $t5 |]
buildVersionsType (t:ts) = [t| $t :>> $(buildVersionsType ts) |]

-- | Generate UpgradableToLatest instances (with identity upgrades)
generateUpgradeInstances :: String -> [TypeQ] -> DecsQ
generateUpgradeInstances eventName payloadTypes = do
  let eventNameType = LitT (StrTyLit eventName)
  let maxVer = length payloadTypes - 1
  
  -- Generate instances for each version
  concat <$> mapM (generateUpgradeInstance eventNameType) [0..maxVer]

-- | Generate a single UpgradeToLatest instance for a specific version
generateUpgradeInstance :: Type -> Int -> DecsQ
generateUpgradeInstance eventNameType version = do
  let versionLit = LitT (NumTyLit (fromIntegral version))
  
  [d| instance UpgradableToLatest $(return eventNameType) $(return versionLit) where
        upgradeToLatest = id
    |]

-- | Define multiple simple events at once
--
-- @defineEvents [("user_created", [''UserInfo]), ("user_deleted", [''UserDeletion])]@
--
-- Each event gets its own Event instance with identity upgrades.
defineEvents :: [(String, [Name])] -> DecsQ
defineEvents eventSpecs = do
  allDecs <- mapM (uncurry defineEvent) eventSpecs
  return (concat allDecs)

-- | Define event with custom upgrade functions to latest version
--
-- Version numbers are inferred from list position (0, 1, 2...).
-- Upgrade functions map each version directly to the latest version.
--
-- NOTE: Due to GHC limitations, you need to use this in two splices:
-- @
-- $(defineEventMaxVersion "order_placed" [''OrderV0, ''OrderV1, ''OrderV2])
-- $(defineEventVersionsWithUpgrades "order_placed" 
--   [''OrderV0, ''OrderV1, ''OrderV2]
--   [[| upgradeV0 |], [| upgradeV1 |]])
-- @
defineEventWithUpgrades :: String -> [Name] -> [ExpQ] -> DecsQ  
defineEventWithUpgrades eventName payloadTypeNames upgradeFunctions = do
  error $ unlines
    [ "defineEventWithUpgrades cannot be used in a single splice due to GHC limitations."
    , "Please use:"
    , "  $(defineEventMaxVersion \"" ++ eventName ++ "\" " ++ show payloadTypeNames ++ ")"
    , "  $(defineEventVersionsWithUpgrades \"" ++ eventName ++ "\" "
    , "    " ++ show payloadTypeNames
    , "    [upgrade functions])"
    ]

-- | Define event versions with custom upgrade functions
--
-- Use this with defineEventMaxVersion for events with custom upgrades.
--
-- @
-- $(defineEventMaxVersion "order_placed" [''OrderV0, ''OrderV1, ''OrderV2])
-- $(defineEventVersionsWithUpgrades "order_placed" 
--   [''OrderV0, ''OrderV1, ''OrderV2]
--   [[| upgradeV0ToV2 |], [| upgradeV1ToV2 |]])
-- @
defineEventVersionsWithUpgrades :: String -> [Name] -> [ExpQ] -> DecsQ
defineEventVersionsWithUpgrades eventName payloadTypeNames upgradeFunctions = do
  let eventNameType = LitT (StrTyLit eventName)
  let payloadTypes = map conT payloadTypeNames
  let numVersions = length payloadTypes
  let numUpgrades = length upgradeFunctions
  
  -- Validation
  when (numVersions == 0) $
    error "defineEventVersionsWithUpgrades: Empty payload list"
  when (numUpgrades /= numVersions - 1) $
    error $ "defineEventVersionsWithUpgrades: Expected " ++ show (numVersions - 1) 
         ++ " upgrade functions for " ++ show numVersions ++ " versions, got " ++ show numUpgrades
  
  versionsType <- buildVersionsType payloadTypes
  
  versionsDec <- [d| type instance Versions $(return eventNameType) = $(return versionsType) |]
  eventDec <- [d| instance Event $(return eventNameType) |]
  
  -- Generate custom upgrade instances
  upgradeInstances <- generateCustomUpgradeInstances eventName payloadTypes upgradeFunctions
  
  return $ versionsDec ++ eventDec ++ upgradeInstances

-- | Generate custom upgrade instances (direct to latest)
generateCustomUpgradeInstances :: String -> [TypeQ] -> [ExpQ] -> DecsQ
generateCustomUpgradeInstances eventName payloadTypes upgradeFunctions = do
  let eventNameType = LitT (StrTyLit eventName)
  let maxVersion = length payloadTypes - 1
  
  -- Generate upgrade instances for each non-latest version
  customInstances <- sequence $ zipWith (generateCustomUpgradeInstance eventNameType) [0..] upgradeFunctions
  
  -- Generate identity instance for latest version
  latestInstance <- generateUpgradeInstance eventNameType maxVersion
  
  return (concat customInstances ++ latestInstance)

-- | Generate a custom upgrade instance for a specific version
generateCustomUpgradeInstance :: Type -> Int -> ExpQ -> DecsQ
generateCustomUpgradeInstance eventNameType version upgradeFunc = do
  let versionLit = LitT (NumTyLit (fromIntegral version))
  
  [d| instance UpgradableToLatest $(return eventNameType) $(return versionLit) where
        upgradeToLatest = $(upgradeFunc)
    |]

-- | Convenience function for single-type events with identity upgrade
--
-- @defineEventSingle "user_created" ''UserInfo@
--
-- Equivalent to @defineEvent "user_created" [''UserInfo]@
defineEventSingle :: String -> Name -> DecsQ
defineEventSingle eventName payloadTypeName = 
  defineEvent eventName [payloadTypeName]

-- | Convenience function for single-type events with no upgrade instances  
--
-- @defineEventSimpleSingle "user_created" ''UserInfo@
--
-- Equivalent to @defineEventSimple "user_created" [''UserInfo]@
defineEventSimpleSingle :: String -> Name -> DecsQ
defineEventSimpleSingle eventName payloadTypeName = 
  defineEventSimple eventName [payloadTypeName]

-- | Generate only the MaxVersion type instance
--
-- Use this with defineEventVersions when you need to split the declarations
-- to work around GHC's type family dependency resolution issues.
--
-- @
-- $(defineMaxVersion "user_created" 0)  -- Single version (version 0)
-- $(defineEventVersions "user_created" [''UserInfo])
-- @
defineMaxVersion :: String -> Int -> DecsQ
defineMaxVersion eventName maxVer = do
  let eventNameType = LitT (StrTyLit eventName)
  [d| type instance MaxVersion $(return eventNameType) = $(litT (numTyLit (fromIntegral maxVer))) |]

-- | DEPRECATED: Use defineMaxVersion instead
defineEventMaxVersion :: String -> [Name] -> DecsQ
defineEventMaxVersion eventName payloadTypeNames = do
  let maxVer = length payloadTypeNames - 1
  defineMaxVersion eventName maxVer

-- | Generate the Versions type instance and Event instance
--
-- Use this with defineEventMaxVersion when you need to split the declarations
-- to work around GHC's type family dependency resolution issues.
--
-- @
-- $(defineEventMaxVersion "user_created" [''UserInfo])
-- $(defineEventVersions "user_created" [''UserInfo])
-- @
defineEventVersions :: String -> [Name] -> DecsQ
defineEventVersions eventName payloadTypeNames = do
  let eventNameType = LitT (StrTyLit eventName)
  let payloadTypes = map conT payloadTypeNames
  versionsType <- buildVersionsType payloadTypes
  
  versionsDec <- [d| type instance Versions $(return eventNameType) = $(return versionsType) |]
  eventDec <- [d| instance Event $(return eventNameType) |]
  upgradeInstances <- generateUpgradeInstances eventName payloadTypes
  
  return $ versionsDec ++ eventDec ++ upgradeInstances

-- | Generate only the Versions type instance and Event instance (no upgrades)
--
-- Use this when you want to define upgrade instances manually.
--
-- @
-- $(defineEventMaxVersion "order_placed" [''OrderV0, ''OrderV1, ''OrderV2])
-- $(defineEventVersionsOnly "order_placed" [''OrderV0, ''OrderV1, ''OrderV2])
-- 
-- instance UpgradableToLatest "order_placed" 0 where
--   upgradeToLatest = customUpgrade0To2
-- @
defineEventVersionsOnly :: String -> [Name] -> DecsQ
defineEventVersionsOnly eventName payloadTypeNames = do
  let eventNameType = LitT (StrTyLit eventName)
  let payloadTypes = map conT payloadTypeNames
  versionsType <- buildVersionsType payloadTypes
  
  versionsDec <- [d| type instance Versions $(return eventNameType) = $(return versionsType) |]
  eventDec <- [d| instance Event $(return eventNameType) |]
  
  return $ versionsDec ++ eventDec