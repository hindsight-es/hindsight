{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE QuantifiedConstraints #-}
{-# LANGUAGE RequiredTypeArguments #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UndecidableInstances #-}

{-|
Module      : Hindsight.Core
Description : Type-safe event system with versioning and automatic upgrades
Copyright   : (c) 2024
License     : BSD3
Maintainer  : maintainer@example.com
Stability   : experimental

This module provides the core type-level machinery for Hindsight's event system.
It enables compile-time event versioning, automatic serialization, and safe
event evolution over time.

= Overview

Hindsight uses type-level programming to provide compile-time guarantees about
event versioning and upgrades. Events are identified by type-level strings
('Symbol's) and can have multiple payload versions that evolve over time.

= Quick Start

To define an event:

@
type instance MaxVersion \"user_created\" = 0
type instance Versions \"user_created\" = FirstVersion UserCreated

instance Event \"user_created\"
instance UpgradableToLatest \"user_created\" 0 where
  upgradeToLatest = id
@

Then use 'mkEvent' to create event values:

@
event = mkEvent \"user_created\" (UserCreated userId name)
@

= Advanced Usage

For multi-version events with migrations, see the tutorial documentation
and examples in the hindsight-tutorials package.
-}
module Hindsight.Core
  ( -- * Event Definition
    -- | Core types and constraints for defining events.
    Event,
    IsEvent,
    SomeLatestEvent (..),
    mkEvent,

    -- ** Event Names
    getEventName,

    -- * Event Versioning
    -- | Type families for specifying event versions.
    --
    -- Use 'MaxVersion' to declare the latest version number, and 'Versions'
    -- to specify the payload types for each version.
    MaxVersion,
    Versions,
    CurrentPayloadType,

    -- ** Version Vector Construction
    -- | Operators and helpers for building version type vectors.
    --
    -- For single-version events, use 'FirstVersion'. For multi-version events,
    -- combine types with '(:>>)' and '(:>|)'.
    EventVersions (..),
    FirstVersion,
    (:>|),
    (:>>),

    -- * Upgrade System
    -- | Types and classes for upgrading old event versions to the latest.
    UpgradableToLatest (..),
    FinalVersionType,
    PayloadVersion,
    PayloadAtVersion,

    -- * Serialization Constraints
    -- | Type constraints for JSON serialization.
    Serializable,

    -- * Advanced Type-Level Utilities
    -- | These are primarily for internal use or advanced scenarios.
    --
    -- Most users won't need to reference these directly.

    -- ** Peano Numbers
    PeanoNat (..),
    ReifiablePeanoNat (..),
    ToPeanoNat,
    FromPeanoNat,

    -- ** Version Constraints
    Dict (..),
    VersionConstraints (..),
    ValidPayloadForVersion (..),
    HasEvidenceList,
    HasFullEvidenceList,
    getPayloadEvidence,

    -- ** Type-Level Utilities
    VersionPayloadRequirements,
    ValidateVersionBound,
    AssertVersionInRange,
    PeanoEqual,

    -- * Parsing Utilities
    -- | Internal parsing functions - typically used by store implementations.
    parseMap,
    parseMapFromProxy,
    getMaxVersion,
  )
where

import Data.Aeson (FromJSON (parseJSON), ToJSON, Value)
import Data.Aeson.Types qualified as Aeson
import Data.Kind (Constraint, Type)
import Data.Map (Map)
import Data.Map qualified as Map
import Data.Text qualified as T
import Data.Typeable (Proxy (..), Typeable)
import GHC.TypeLits
  ( ErrorMessage (Text),
    KnownSymbol,
    Nat,
    Symbol,
    TypeError,
    symbolVal,
    type (+),
    type (-),
  )

-- | Basic type constraints required for event payloads
type Serializable a = (Show a, Eq a, FromJSON a, ToJSON a)

-- | Dictionary of constraints, used for constraint evidence
data Dict (c :: Constraint) where
  Dict :: (c) => Dict c

-- -----------------------------------------------------------------------------
-- Event Names
-- -----------------------------------------------------------------------------

-- | Get the event name as Text from a Symbol.
getEventName ::
  forall (event :: Symbol).
  (KnownSymbol event) =>
  Proxy event ->  -- ^ Proxy for the event type
  T.Text          -- ^ Event name as Text
getEventName _ = T.pack $ symbolVal (Proxy @event)


-- -----------------------------------------------------------------------------
-- Peano Numbers
-- -----------------------------------------------------------------------------

-- | Type-level Peano natural numbers
data PeanoNat = PeanoZero | PeanoSucc PeanoNat

class ReifiablePeanoNat (n :: PeanoNat) where
  reifyPeanoNat :: Integer

instance ReifiablePeanoNat PeanoZero where
  reifyPeanoNat = 0

instance (ReifiablePeanoNat n) => ReifiablePeanoNat (PeanoSucc n) where
  reifyPeanoNat = 1 + reifyPeanoNat @n

type family ToPeanoNat (n :: Nat) :: PeanoNat where
  ToPeanoNat 0 = PeanoZero
  ToPeanoNat n = PeanoSucc (ToPeanoNat (n - 1))

type family FromPeanoNat (n :: PeanoNat) :: Nat where
  FromPeanoNat PeanoZero = 0
  FromPeanoNat (PeanoSucc n) = 1 + FromPeanoNat n

-- -----------------------------------------------------------------------------
-- Versioned Type Vectors
-- -----------------------------------------------------------------------------

-- | Type-level vector of event versions
data EventVersions (startsAt :: PeanoNat) (finalCount :: PeanoNat) where
  Final :: Type -> EventVersions startsAt (PeanoSucc startsAt)
  Then :: Type -> EventVersions (PeanoSucc startsAt) finalCount -> EventVersions startsAt finalCount

-- | Alias for specifying the first payload version of an event
type FirstVersion :: Type -> EventVersions PeanoZero (PeanoSucc PeanoZero)
type FirstVersion t = Final t

-- | Operator for combining the last two versions
-- Precedence: 7 (binds most tightly)
infixr 7 :>|

type (:>|) :: Type -> Type -> EventVersions n (PeanoSucc (PeanoSucc n))
type t1 :>| t2 = Then t1 (Final t2)

-- | Operator for consing earlier versions
-- Precedence: 6
infixr 6 :>>

type (:>>) :: Type -> EventVersions (PeanoSucc s) f -> EventVersions s f
type t :>> v = Then t v

-- | Constraints indexed by version numbers
type VersionConstraints :: EventVersions m n -> (PeanoNat -> Type -> Constraint) -> Type
-- The type signature above is necessary for the code to build.
data VersionConstraints (ts :: EventVersions startsAt finalCount) (c :: PeanoNat -> Type -> Constraint) where
  VersionConstraintsLast ::
    (c startsAt t) =>
    (Proxy startsAt, Proxy t) ->
    VersionConstraints ('Final t :: EventVersions startsAt (PeanoSucc startsAt)) c
  VersionConstraintsCons ::
    (c startsAt t) =>
    (Proxy startsAt, Proxy t) ->
    VersionConstraints ts' c ->
    VersionConstraints ('Then t ts' :: EventVersions startsAt finalCount) c

-- -----------------------------------------------------------------------------
-- Event Versioning System
-- -----------------------------------------------------------------------------

-- | Core type family for event versions
type family MaxVersion (event :: Symbol) :: Nat

-- | Core type family for event version vectors
type family Versions (event :: Symbol) :: EventVersions PeanoZero (PeanoSucc (ToPeanoNat (MaxVersion event)))


-- | Core type class for versioned events using Symbol directly
class (KnownSymbol event) => Event (event :: Symbol)

-- | Type constraint for events using Symbol directly
type IsEvent (event :: Symbol) =
  ( Event event,
    KnownSymbol event,
    Typeable event,
    ToJSON (CurrentPayloadType event),
    HasEvidenceList PeanoZero (PeanoSucc (ToPeanoNat (MaxVersion event))) event ValidPayloadForVersion (Versions event),
    ReifiablePeanoNat (ToPeanoNat (MaxVersion event)) -- For version number reification
  )


-- | Type-level version bounds checking
type ValidateVersionBound :: PeanoNat -> PeanoNat -> Type -> Type
type family ValidateVersionBound idx maxVer result where
  ValidateVersionBound idx maxVer result =
    AssertVersionInRange (PeanoSucc idx) maxVer result (TypeError ('Text "Version index out of bounds"))

-- | Type-level less-than-or-equal comparison for version numbers
type AssertVersionInRange :: PeanoNat -> PeanoNat -> Type -> Type -> Type
type family AssertVersionInRange a b success failure where
  AssertVersionInRange PeanoZero _ success _ = success
  AssertVersionInRange (PeanoSucc _) PeanoZero _ failure = failure
  AssertVersionInRange (PeanoSucc a) (PeanoSucc b) success failure = AssertVersionInRange a b success failure

-- | Type-level Peano number equality comparison
type PeanoEqual :: PeanoNat -> PeanoNat -> Type -> Type -> Type
type family PeanoEqual a b thenResult elseResult where
  PeanoEqual n n thenResult _ = thenResult
  PeanoEqual n m _ elseResult = elseResult

-- | Gets payload type at specific version
-- PayloadAtVersion type family with proper kind signatures
type PayloadAtVersion ::
  forall (startsAt :: PeanoNat) (finalCount :: PeanoNat).
  PeanoNat ->
  EventVersions startsAt finalCount ->
  Type
type family PayloadAtVersion idx vec where
  PayloadAtVersion idx (Final t :: EventVersions startsAt (PeanoSucc startsAt)) =
    PeanoEqual idx startsAt t (TypeError ('Text "Version index out of bounds"))
  PayloadAtVersion idx (Then t rest :: EventVersions startsAt finalCount) =
    ValidateVersionBound
      idx
      finalCount
      ( PeanoEqual idx startsAt t (PayloadAtVersion idx rest)
      )

-- | Alias for payload at specific version
type PayloadVersion event n = PayloadAtVersion n (Versions event)


-- | Core constraints required for event payloads
type VersionPayloadRequirements :: Symbol -> PeanoNat -> Type -> Constraint
type VersionPayloadRequirements event idx payload =
  ( Serializable payload,
    UpgradableToLatest event (FromPeanoNat idx),
    -- Needed because GHC can't prove bijectivity of PeanoNat <-> Nat.
    PayloadVersion event (ToPeanoNat (FromPeanoNat idx)) ~ PayloadVersion event idx,
    KnownSymbol event,
    ReifiablePeanoNat idx,
    Typeable payload,
    Typeable event,
    Typeable idx,
    payload ~ PayloadVersion event idx
  )

-- | Evidence that a type is a valid payload for a version
class (VersionPayloadRequirements event idx payload) => ValidPayloadForVersion (event :: Symbol) (idx :: PeanoNat) (payload :: Type) where
  constraintEvidence :: Dict (VersionPayloadRequirements event idx payload)

instance (VersionPayloadRequirements event idx payload) => ValidPayloadForVersion event idx payload where
  constraintEvidence = Dict


-- | Gets the final version's payload type
type CurrentPayloadType :: Symbol -> Type
type CurrentPayloadType event = FinalVersionType (Versions event)

-- | Gets the last type in a versioned vector
type FinalVersionType :: EventVersions startsAt finalCount -> Type
type family FinalVersionType vec where
  FinalVersionType (Final t) = t
  FinalVersionType (Then t rest) = FinalVersionType rest

-- | Capability to upgrade a payload to the latest version
class UpgradableToLatest (event :: Symbol) (ver :: Nat) where
  upgradeToLatest :: PayloadAtVersion (ToPeanoNat ver) (Versions event) -> CurrentPayloadType event


-- | Helper class for generating version constraints
class HasEvidenceList (startsAt :: PeanoNat) (finalCount :: PeanoNat) (event :: Symbol) (c :: Symbol -> PeanoNat -> Type -> Constraint) (vec :: EventVersions startsAt finalCount) where
  getEvidenceList :: VersionConstraints vec (c event)

-- | Base case: last version
instance
  (c event startsAt payload) =>
  HasEvidenceList startsAt ('PeanoSucc startsAt) event c ('Final payload :: EventVersions startsAt (PeanoSucc startsAt))
  where
  getEvidenceList = VersionConstraintsLast @(c event) @startsAt @payload (Proxy, Proxy)

-- | Inductive case: multiple versions
instance
  ( c event startsAt payload,
    HasEvidenceList (PeanoSucc startsAt) finalCount event c ts
  ) =>
  HasEvidenceList startsAt finalCount event c ('Then payload ts)
  where
  getEvidenceList =
    VersionConstraintsCons @(c event) @startsAt @payload
      (Proxy, Proxy)
      (getEvidenceList @_ @_ @event @c @ts)


-- | Symbol-based evidence types
type HasFullEvidenceList event c = (HasEvidenceList PeanoZero (PeanoSucc (ToPeanoNat (MaxVersion event))) event c (Versions event))

getPayloadEvidence :: forall event c. (HasFullEvidenceList event c) => VersionConstraints (Versions event) (c event)
getPayloadEvidence = getEvidenceList @_ @_ @event @c @(Versions event)


-- -----------------------------------------------------------------------------
-- Parsing and Version Management
-- -----------------------------------------------------------------------------

-- | Some latest version of some event.
data SomeLatestEvent = forall event. (IsEvent event, Typeable event) => SomeLatestEvent {getEventProxy :: Proxy event, getPayload :: CurrentPayloadType event}

-- | Smart constructor for creating events using RequiredTypeArguments.
--
-- Example:
-- >>> mkEvent UserRegistered (UserInfo "U001" "Alice")
--
-- This is equivalent to:
-- >>> SomeLatestEvent (Proxy @UserRegistered) (UserInfo "U001" "Alice")
mkEvent ::
  forall (event :: Symbol) ->  -- ^ Event name (type-level string)
  IsEvent event =>
  CurrentPayloadType event ->  -- ^ Event payload at current version
  SomeLatestEvent              -- ^ Wrapped event with type information
mkEvent event payload = SomeLatestEvent (Proxy @event) payload

-- | Parse map for Symbol-based events.
--
-- Creates a map from version numbers to parsers that can deserialize
-- event payloads at any version and upgrade them to the latest version.
parseMap ::
  forall event.
  (IsEvent event) =>
  Map Int (Value -> Aeson.Parser (CurrentPayloadType event))  -- ^ Map from version to parser
parseMap = Map.fromList $ go [] (getPayloadEvidence @event @ValidPayloadForVersion)
  where
    go :: forall ts. [(Int, Value -> Aeson.Parser (CurrentPayloadType event))] -> VersionConstraints ts (ValidPayloadForVersion event) -> [(Int, Value -> Aeson.Parser (CurrentPayloadType event))]
    go acc (VersionConstraintsLast (_pVer :: Proxy ver, _pPayload :: Proxy payload)) =
      let ver = fromInteger $ reifyPeanoNat @ver
          parser = \v -> upgradeToLatest @event @(FromPeanoNat ver) <$> parseJSON @payload v
       in (ver, parser) : acc
    go acc (VersionConstraintsCons (_pVer :: Proxy ver, _pPayload :: Proxy payload) rest) =
      let ver = fromInteger $ reifyPeanoNat @ver
          parser = \v -> upgradeToLatest @event @(FromPeanoNat ver) <$> parseJSON @payload v
       in go ((ver, parser) : acc) rest

-- | Get the parse map from a proxy.
--
-- Convenience wrapper around 'parseMap' that accepts a proxy argument.
parseMapFromProxy ::
  forall event.
  (IsEvent event) =>
  Proxy event ->  -- ^ Proxy for the event type
  Map Int (Value -> Aeson.Parser (CurrentPayloadType event))  -- ^ Map from version to parser
parseMapFromProxy _ = parseMap @event

-- | Get the maximum version number for an event.
getMaxVersion ::
  forall event.
  (IsEvent event) =>
  Proxy event ->  -- ^ Proxy for the event type
  Integer         -- ^ Maximum version number
getMaxVersion _ = reifyPeanoNat @(ToPeanoNat (MaxVersion event))

