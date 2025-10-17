{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DefaultSignatures #-}
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
{-# LANGUAGE UndecidableSuperClasses #-}

{-|
Module      : Hindsight.Events
Description : Type-safe event system with versioning and automatic upgrades
Copyright   : (c) 2024
License     : BSD3
Maintainer  : maintainer@example.com
Stability   : experimental

This module provides the core API for Hindsight's event system.
It enables compile-time event versioning, automatic serialization, and safe
event evolution over time.

= Overview

Hindsight uses type-level programming to provide compile-time guarantees about
event versioning and upgrades. Events are identified by type-level strings
('Symbol's) and can have multiple payload versions that evolve over time.

= Quick Start

To define a single-version event:

@
type instance MaxVersion \"user_created\" = 0
type instance Versions \"user_created\" = '[UserCreated]

instance Event \"user_created\"
instance MigrateVersion 0 \"user_created\"  -- No method needed for single version!
@

Then use 'mkEvent' to create event values:

@
event = mkEvent \"user_created\" (UserCreated userId name)
@

= Advanced Usage: Multi-Version Events

For events with multiple versions, define consecutive upgrades using 'Upcast'
and the system automatically composes them:

@
-- V0 → V1 transition
instance Upcast 0 \"user_created\" where
  upcast v0 = V1 { newField = defaultValue, ... }

-- V1 → V2 transition
instance Upcast 1 \"user_created\" where
  upcast v1 = V2 { anotherField = defaultValue, ... }

-- Migration instances use automatic composition
instance MigrateVersion 0 \"user_created\"  -- Automatic: V0 → V1 → V2
instance MigrateVersion 1 \"user_created\"  -- Automatic: V1 → V2
instance MigrateVersion 2 \"user_created\"  -- Automatic: V2 → V2 (identity)
@

For detailed examples, see the tutorial documentation in the hindsight-tutorials package.

= Type Aliases for Clarity

This module provides several type aliases to make complex type signatures
more readable:

* 'EventVersionCount' - The number of versions for an event
* 'EventVersionVector' - The full version vector type
* 'FullVersionRange' - Evidence that all versions satisfy constraints

These are particularly useful when reading type errors or writing advanced code.
-}
module Hindsight.Events
  ( -- * Event Definition
    -- | Core types for defining and working with events.
    Event,
    EventConstraints,
    SomeLatestEvent (..),
    mkEvent,

    -- ** Event Names
    getEventName,

    -- * Event Versioning
    -- | Type families and aliases for declaring event versions.
    --
    -- Use 'MaxVersion' to declare the latest version number, and 'Versions'
    -- to specify the payload types for each version.
    MaxVersion,
    Versions,
    CurrentPayloadType,

    -- ** Clarity Aliases
    -- | These aliases make type signatures more readable.
    EventVersionCount,
    EventVersionVector,
    FullVersionRange,

    -- ** Internal Version Machinery
    -- | Low-level types for the version system.
    --
    -- Most users won't need these directly. The 'EventVersions' GADT and
    -- 'FromList' type family are used internally to convert the simple list
    -- syntax from 'Versions' into the indexed type structure.
    EventVersions (..),
    FromList,

    -- * Upgrade System
    -- | Types and classes for upgrading old event versions to the latest.
    FinalVersionType,
    PayloadVersion,
    PayloadAtVersion,

    -- ** Consecutive Upcast API
    -- | API for version migrations using consecutive upgrades.
    --
    -- Define one 'Upcast' instance per version transition, and 'MigrateVersion'
    -- instances are automatically composed.
    Upcast (..),
    MigrateVersion (..),
    MaxVersionPeano,

    -- * Serialization
    -- | Type constraints for JSON serialization.
    Serializable,

    -- * Parsing Utilities
    -- | Functions typically used by store implementations for deserializing
    -- events from storage.
    parseMap,
    parseMapFromProxy,
    getMaxVersion,

    -- * Advanced Type-Level Utilities
    -- | These are primarily for internal use or advanced scenarios.
    --
    -- Most users won't need to reference these directly. They're exported
    -- for documentation purposes and for library implementors.

    -- ** Peano Numbers
    PeanoNat (..),
    ReifiablePeanoNat (..),
    ToPeanoNat,
    FromPeanoNat,

    -- ** Constraint Evidence
    Dict (..),
    VersionConstraints (..),
    ValidPayloadForVersion (..),
    HasEvidenceList,
    HasFullEvidenceList,
    getPayloadEvidence,

    -- ** Type-Level Utilities
    VersionPayloadRequirements,
    PeanoEqual,
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
  ( ErrorMessage (..),
    KnownSymbol,
    Nat,
    Symbol,
    TypeError,
    symbolVal,
    type (+),
  )

-- Re-export from Internal modules
import Hindsight.Events.Internal.TypeLevel
  ( AssertPeanoEqual,
    Dict (..),
    FromPeanoNat,
    ListLength,
    PeanoEqual,
    PeanoNat (..),
    ReifiablePeanoNat (..),
    ToPeanoNat,
  )
import Hindsight.Events.Internal.Versioning
  ( EventVersions (..),
    FromList,
    FinalVersionType,
    HasEvidenceList (..),
    PayloadAtVersion,
    VersionConstraints (..),
  )

-- -----------------------------------------------------------------------------
-- Event Names
-- -----------------------------------------------------------------------------

-- | Get the event name as Text from a Symbol.
--
-- This converts a type-level event name to a runtime value, useful for
-- logging, debugging, and serialization.
--
-- @
-- getEventName (Proxy @\"user_created\") = \"user_created\"
-- @
getEventName ::
  forall (event :: Symbol).
  (KnownSymbol event) =>
  Proxy event -> -- ^ Proxy for the event type
  T.Text -- ^ Event name as Text
getEventName _ = T.pack $ symbolVal (Proxy @event)

-- -----------------------------------------------------------------------------
-- Event Versioning System
-- -----------------------------------------------------------------------------

-- | Declare the maximum version number for an event.
--
-- Version numbers start at 0. For a single-version event, use @MaxVersion = 0@.
-- For multi-version events, increment this as you add versions.
--
-- @
-- type instance MaxVersion \"user_created\" = 0  -- Single version
-- type instance MaxVersion \"order_placed\" = 2  -- Three versions (0, 1, 2)
-- @
type family MaxVersion (event :: Symbol) :: Nat

-- | Declare the payload types for each version of an event.
--
-- Use a type-level list to specify all payload versions in order:
--
-- @
-- -- Single version:
-- type instance Versions \"user_created\" = '[UserCreated]
--
-- -- Multiple versions:
-- type instance Versions \"order_placed\" = '[OrderPlacedV0, OrderPlacedV1, OrderPlacedV2]
-- @
--
-- The list length must match @MaxVersion + 1@. This constraint is enforced
-- at compile time through the version evidence system.
type family Versions (event :: Symbol) :: [Type]

-- -----------------------------------------------------------------------------
-- Clarity Type Aliases
-- -----------------------------------------------------------------------------

-- | The number of versions for an event (as a Peano number).
--
-- This is @MaxVersion + 1@ in Peano encoding. For an event with @MaxVersion = 2@,
-- this expands to @PeanoSucc (PeanoSucc (PeanoSucc PeanoZero))@.
--
-- This alias makes type signatures more readable when working with version
-- indices and constraints.
type EventVersionCount event = 'PeanoSucc (ToPeanoNat (MaxVersion event))

-- | The full version vector type for an event.
--
-- This type family represents the complete 'EventVersions' structure from version 0 to
-- 'MaxVersion'. This is computed from the 'Versions' list using 'FromList'.
--
-- Example expansion:
--
-- @
-- EventVersionVector \"user_created\"
--   = FromList (Versions \"user_created\")
--   = FromList '[UserCreated]
--   = EventVersions 'PeanoZero ('PeanoSucc 'PeanoZero)
-- @
--
-- __Note:__ This is an internal type family. Users should work with 'Versions'
-- which uses the simpler list syntax.
type family EventVersionVector (event :: Symbol) :: EventVersions 'PeanoZero (EventVersionCount event) where
  EventVersionVector event = FromList (Versions event)

-- | Evidence that all version payloads satisfy the required constraints.
--
-- This is the main "proof obligation" checked by 'EventConstraints'. It ensures
-- that every payload version can be serialized, deserialized, and upgraded to
-- the latest version.
--
-- Using this alias makes 'EventConstraints' much more readable:
--
-- @
-- type EventConstraints event =
--   ( ...
--   , FullVersionRange event  -- instead of massive HasEvidenceList expression
--   , ...
--   )
-- @
type FullVersionRange event =
  HasEvidenceList 'PeanoZero (EventVersionCount event) event ValidPayloadForVersion (EventVersionVector event)

-- | Error message for version count mismatches.
--
-- This type alias constructs a detailed error message when the number of
-- versions in 'Versions' doesn't match 'MaxVersion + 1'.
--
-- Example output:
--
-- @
-- Version count mismatch for event 'user_created'
--   MaxVersion declares 1 versions
--   But Versions list has 2 elements
--
-- Hint: Check that (MaxVersion event + 1) matches the length of your Versions list
-- @
type VersionCountMismatchError :: Symbol -> ErrorMessage
type VersionCountMismatchError event =
  'Text "Version count mismatch for event '"
    ':<>: 'Text event
    ':<>: 'Text "'"
    ':$$: 'Text "  MaxVersion declares "
    ':<>: 'ShowType (FromPeanoNat (EventVersionCount event))
    ':<>: 'Text " versions"
    ':$$: 'Text "  But Versions list has "
    ':<>: 'ShowType (FromPeanoNat (ListLength (Versions event)))
    ':<>: 'Text " elements"
    ':$$: 'Text ""
    ':$$: 'Text "Hint: Check that (MaxVersion event + 1) matches the length of your Versions list"

-- | Compile-time validation that version count matches.
--
-- This constraint ensures that the number of payloads in the 'Versions' list
-- matches the declared 'MaxVersion'. When they don't match, it produces a
-- clear compile error via 'VersionCountMismatchError'.
--
-- This is checked as part of 'EventConstraints', so you don't need to use it directly.
type AssertVersionCountMatches :: Symbol -> Constraint
type AssertVersionCountMatches event =
  AssertPeanoEqual
    (ListLength (Versions event))
    (EventVersionCount event)
    (VersionCountMismatchError event)

-- -----------------------------------------------------------------------------
-- Event Type Class and Constraints
-- -----------------------------------------------------------------------------

-- | Core type class for versioned events.
--
-- This is the main constraint you'll use when working with events. It automatically
-- includes all necessary constraints via 'EventConstraints'.
--
-- To define an event, create instances of 'MaxVersion', 'Versions', 'Event',
-- and 'MigrateVersion':
--
-- @
-- type instance MaxVersion \"user_created\" = 0
-- type instance Versions \"user_created\" = '[UserCreated]
--
-- instance Event \"user_created\"
-- instance MigrateVersion 0 \"user_created\"  -- Automatic migration (identity for v0)
-- @
class (EventConstraints event) => Event (event :: Symbol)

-- | Complete set of constraints required for an event type.
--
-- This type alias bundles all the low-level constraints needed for event processing:
--
-- * 'AssertVersionCountMatches' - Validate MaxVersion matches Versions list length
-- * 'KnownSymbol' - Access event name as runtime value
-- * 'Typeable' - Runtime type information
-- * 'ToJSON' - Serialize current version payloads
-- * 'FullVersionRange' - Compile-time evidence for all version constraints
-- * 'ReifiablePeanoNat' - Convert type-level version numbers to runtime values
--
-- You don't typically need to use this directly; just use the 'Event' constraint.
-- This is exported for documentation purposes so you can see what constraints
-- are actually required.
type EventConstraints (event :: Symbol) =
  ( AssertVersionCountMatches event,
    KnownSymbol event,
    Typeable event,
    ToJSON (CurrentPayloadType event),
    FullVersionRange event,
    ReifiablePeanoNat (ToPeanoNat (MaxVersion event))
  )

-- -----------------------------------------------------------------------------
-- Payload Type Extraction
-- -----------------------------------------------------------------------------

-- | Get the current (latest) payload type for an event.
--
-- This extracts the final type from the version vector:
--
-- @
-- CurrentPayloadType \"user_created\" = UserCreated
-- CurrentPayloadType \"order_placed\"  = OrderPlacedV2  -- if MaxVersion = 2
-- @
type CurrentPayloadType :: Symbol -> Type
type CurrentPayloadType event = FinalVersionType (EventVersionVector event)

-- | Get the payload type at a specific version number.
--
-- This allows you to reference older payload versions in upgrade logic:
--
-- @
-- instance Upcast 0 \"order_placed\" where
--   upcast :: PayloadVersion \"order_placed\" 0 -> PayloadVersion \"order_placed\" 1
--   upcast v0 = ... -- upgrade OrderPlacedV0 to OrderPlacedV1
-- @
type PayloadVersion event n = PayloadAtVersion n (EventVersionVector event)

-- -----------------------------------------------------------------------------
-- Upgrade System
-- -----------------------------------------------------------------------------

-- | Convert MaxVersion to Peano representation for type-level computation.
--
-- This is used internally by the consecutive upcast machinery to determine
-- when a version is the latest.
type family MaxVersionPeano (event :: Symbol) :: PeanoNat where
  MaxVersionPeano event = ToPeanoNat (MaxVersion event)

-- | Check if a version number is the latest version for an event.
--
-- Returns 'True if @ver ~ MaxVersionPeano event@, 'False otherwise.
-- Used to dispatch between identity and composition in 'ConsecutiveUpcast'.
type family IsLatest (ver :: PeanoNat) (event :: Symbol) :: Bool where
  IsLatest ver event = PeanoEqual ver (MaxVersionPeano event) 'True 'False

-- | Upgrade a payload from version @ver@ to version @ver + 1@.
--
-- This class represents a single consecutive upgrade step. You define
-- one instance for each version transition:
--
-- @
-- -- Upgrade from V0 to V1
-- instance Upcast 0 MyEvent where
--   upcast v0 = V1 { newField = defaultValue, ... }
--
-- -- Upgrade from V1 to V2
-- instance Upcast 1 MyEvent where
--   upcast v1 = V2 { anotherField = defaultValue, ... }
-- @
--
-- These consecutive upgrades are automatically composed to provide
-- migrations from any old version to the latest via 'MigrateVersion'.
class Upcast (ver :: Nat) (event :: Symbol) where
  -- | Upgrade from version @ver@ to version @ver + 1@
  upcast ::
    PayloadAtVersion (ToPeanoNat ver) (EventVersionVector event) ->
    PayloadAtVersion (ToPeanoNat (ver + 1)) (EventVersionVector event)

-- | Provide a helpful error message when an Upcast instance is missing.
--
-- This overlappable instance ensures that if you forget to define an Upcast
-- instance for a version, you get a clear error message instead of cryptic
-- constraint errors.
instance
  {-# OVERLAPPABLE #-}
  ( TypeError
      ( 'Text "Missing Upcast instance for version "
          ':<>: 'ShowType ver
          ':<>: 'Text " of event \""
          ':<>: 'Text event
          ':<>: 'Text "\""
          ':$$: 'Text ""
          ':$$: 'Text "You need to define:"
          ':$$: 'Text "  instance Upcast "
          ':<>: 'ShowType ver
          ':<>: 'Text " \""
          ':<>: 'Text event
          ':<>: 'Text "\" where"
          ':$$: 'Text "    upcast v" ':<>: 'ShowType ver ':<>: 'Text " = ..."
          ':$$: 'Text ""
          ':$$: 'Text "This upgrades from version "
          ':<>: 'ShowType ver
          ':<>: 'Text " to version "
          ':<>: 'ShowType (ver + 1)
      )
  ) =>
  Upcast ver event
  where
  upcast = error "unreachable: TypeError should prevent compilation"

-- | Migrate a payload from any version to the latest version.
--
-- You must declare an instance for each version, but the method body is
-- optional (uses automatic consecutive composition by default):
--
-- @
-- -- Automatic consecutive composition (V0 → V1 → V2)
-- instance MigrateVersion 0 MyEvent
--
-- -- Also automatic (V1 → V2)
-- instance MigrateVersion 1 MyEvent
--
-- -- Latest version (identity)
-- instance MigrateVersion 2 MyEvent
--
-- -- Override for direct upgrade (if needed)
-- instance MigrateVersion 0 MyEvent where
--   migrateVersion v0 = V2 { ... }  -- Skip V1 if it loses information
-- @
class MigrateVersion (ver :: Nat) (event :: Symbol) where
  -- | Migrate from version @ver@ to the latest version
  migrateVersion ::
    PayloadAtVersion (ToPeanoNat ver) (EventVersionVector event) ->
    CurrentPayloadType event

  -- | Default implementation: automatically compose consecutive upgrades
  --
  -- This delegates to 'ConsecutiveUpcast' which handles both the
  -- latest version (identity) and non-latest versions (composition) cases.
  default migrateVersion ::
    (ConsecutiveUpcast (IsLatest (ToPeanoNat ver) event) (ToPeanoNat ver) event) =>
    PayloadAtVersion (ToPeanoNat ver) (EventVersionVector event) ->
    CurrentPayloadType event
  migrateVersion = viaConsecutive @(IsLatest (ToPeanoNat ver) event) @(ToPeanoNat ver) @event

-- | Internal helper class for consecutive upgrade composition.
--
-- This class uses a 'Bool parameter to dispatch between two behaviors:
-- - 'True: Version is latest, use identity
-- - 'False: Version is not latest, compose with upcast
--
-- Users should not interact with this class directly; use 'MigrateVersion' instead.
class ConsecutiveUpcast (isLatest :: Bool) (ver :: PeanoNat) (event :: Symbol) where
  viaConsecutive ::
    PayloadAtVersion ver (EventVersionVector event) ->
    CurrentPayloadType event

-- | Non-latest version: compose consecutive upcast with further migration
instance
  ( Upcast (FromPeanoNat ver) event,
    ConsecutiveUpcast (IsLatest ('PeanoSucc ver) event) ('PeanoSucc ver) event,
    -- GHC can't prove bijectivity of PeanoNat <-> Nat, so we need these:
    PayloadAtVersion (ToPeanoNat (FromPeanoNat ver)) (EventVersionVector event)
      ~ PayloadAtVersion ver (EventVersionVector event),
    PayloadAtVersion (ToPeanoNat (FromPeanoNat ver + 1)) (EventVersionVector event)
      ~ PayloadAtVersion ('PeanoSucc ver) (EventVersionVector event)
  ) =>
  ConsecutiveUpcast 'False ver event
  where
  viaConsecutive = viaConsecutive @(IsLatest ('PeanoSucc ver) event) @('PeanoSucc ver) @event . upcast @(FromPeanoNat ver) @event

-- | Latest version: identity (no migration needed)
instance
  ( ver ~ MaxVersionPeano event,
    PayloadAtVersion ver (EventVersionVector event) ~ CurrentPayloadType event
  ) =>
  ConsecutiveUpcast 'True ver event
  where
  viaConsecutive = id

-- -----------------------------------------------------------------------------
-- Constraint Management (Internal)
-- -----------------------------------------------------------------------------

-- | Core constraints required for event payloads at a specific version.
--
-- This bundles together all the requirements for a payload type at a given
-- version index. You typically won't use this directly.
type VersionPayloadRequirements :: Symbol -> PeanoNat -> Type -> Constraint
type VersionPayloadRequirements event idx payload =
  ( Serializable payload,
    MigrateVersion (FromPeanoNat idx) event,
    -- Needed because GHC can't prove bijectivity of PeanoNat <-> Nat.
    PayloadVersion event (ToPeanoNat (FromPeanoNat idx)) ~ PayloadVersion event idx,
    KnownSymbol event,
    ReifiablePeanoNat idx,
    Typeable payload,
    Typeable event,
    Typeable idx,
    payload ~ PayloadVersion event idx
  )

-- | Evidence that a type is a valid payload for a version.
--
-- This class packages up 'VersionPayloadRequirements' into a 'Dict' that can
-- be passed around at runtime. Used internally by the parsing machinery.
class (VersionPayloadRequirements event idx payload) => ValidPayloadForVersion (event :: Symbol) (idx :: PeanoNat) (payload :: Type) where
  constraintEvidence :: Dict (VersionPayloadRequirements event idx payload)

instance (VersionPayloadRequirements event idx payload) => ValidPayloadForVersion event idx payload where
  constraintEvidence = Dict

-- | Convenience alias for full version range evidence.
--
-- This is used in 'EventConstraints' via the 'FullVersionRange' alias.
type HasFullEvidenceList event c = (HasEvidenceList 'PeanoZero (EventVersionCount event) event c (EventVersionVector event))

-- | Extract constraint evidence for all versions of an event.
--
-- Used internally by parsing and serialization machinery.
getPayloadEvidence :: forall event c. (HasFullEvidenceList event c) => VersionConstraints (EventVersionVector event) (c event)
getPayloadEvidence = getEvidenceList

-- -----------------------------------------------------------------------------
-- Serialization
-- -----------------------------------------------------------------------------

-- | Basic type constraints required for event payloads.
--
-- All payload types must be serializable to JSON for storage and transmission.
type Serializable a = (Show a, Eq a, FromJSON a, ToJSON a)

-- -----------------------------------------------------------------------------
-- Runtime Operations
-- -----------------------------------------------------------------------------

-- | Existential wrapper for an event at its latest version.
--
-- This packages up an event name (as a 'Proxy') with its current payload,
-- hiding the specific event type. Useful for heterogeneous collections of events.
--
-- Create values using 'mkEvent'.
data SomeLatestEvent = forall event. Event event => SomeLatestEvent {getEventProxy :: Proxy event, getPayload :: CurrentPayloadType event}

-- | Smart constructor for creating events using RequiredTypeArguments.
--
-- This provides a convenient syntax for creating events:
--
-- @
-- event = mkEvent \"user_created\" (UserCreated userId name)
-- @
--
-- This is equivalent to:
--
-- @
-- event = SomeLatestEvent (Proxy @\"user_created\") (UserCreated userId name)
-- @
mkEvent ::
  forall (event :: Symbol) -> -- ^ Event name (type-level string)
  Event event =>
  CurrentPayloadType event -> -- ^ Event payload at current version
  SomeLatestEvent -- ^ Wrapped event with type information
mkEvent event payload = SomeLatestEvent (Proxy @event) payload

-- -----------------------------------------------------------------------------
-- Parsing Utilities
-- -----------------------------------------------------------------------------

-- | Build a version-aware parser map for an event.
--
-- Creates a map from version numbers to parsers that can deserialize
-- event payloads at any version and automatically upgrade them to the latest.
--
-- This is used internally by store implementations when reading events from storage.
--
-- @
-- parseMap @\"order_placed\"
--   = Map.fromList
--       [ (0, parser that reads OrderPlacedV0 and upgrades to V2)
--       , (1, parser that reads OrderPlacedV1 and upgrades to V2)
--       , (2, parser that reads OrderPlacedV2 directly)
--       ]
-- @
parseMap ::
  forall event.
  (Event event) =>
  Map Int (Value -> Aeson.Parser (CurrentPayloadType event)) -- ^ Map from version to parser
parseMap = Map.fromList $ go [] (getPayloadEvidence @event @ValidPayloadForVersion)
  where
    go :: forall ts. [(Int, Value -> Aeson.Parser (CurrentPayloadType event))] -> VersionConstraints ts (ValidPayloadForVersion event) -> [(Int, Value -> Aeson.Parser (CurrentPayloadType event))]
    go acc (VersionConstraintsLast (_pVer :: Proxy ver, _pPayload :: Proxy payload)) =
      let ver = fromInteger $ reifyPeanoNat @ver
          parser = \v -> migrateVersion @(FromPeanoNat ver) @event <$> parseJSON @payload v
       in (ver, parser) : acc
    go acc (VersionConstraintsCons (_pVer :: Proxy ver, _pPayload :: Proxy payload) rest) =
      let ver = fromInteger $ reifyPeanoNat @ver
          parser = \v -> migrateVersion @(FromPeanoNat ver) @event <$> parseJSON @payload v
       in go ((ver, parser) : acc) rest

-- | Convenience wrapper around 'parseMap' that accepts a proxy argument.
--
-- Some contexts require explicit type application or proxy arguments.
-- This function provides compatibility with such APIs.
parseMapFromProxy ::
  forall event.
  (Event event) =>
  Proxy event -> -- ^ Proxy for the event type
  Map Int (Value -> Aeson.Parser (CurrentPayloadType event)) -- ^ Map from version to parser
parseMapFromProxy _ = parseMap @event

-- | Get the maximum version number for an event as a runtime integer.
--
-- Useful for debugging, logging, or runtime version checks:
--
-- @
-- getMaxVersion (Proxy @\"order_placed\") = 2  -- if MaxVersion \"order_placed\" = 2
-- @
getMaxVersion ::
  forall event.
  (Event event) =>
  Proxy event -> -- ^ Proxy for the event type
  Integer -- ^ Maximum version number
getMaxVersion _ = reifyPeanoNat @(ToPeanoNat (MaxVersion event))
