{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UndecidableInstances #-}

{- |
Module      : Hindsight.Events.Internal.Versioning
Description : Generic version vector machinery
Copyright   : (c) 2024
License     : BSD3
Maintainer  : maintainer@example.com
Stability   : experimental

This module provides the generic machinery for managing versioned type vectors.
This is the foundation for event versioning but is completely generic - it
could be used for any versioned system.

= Version Vectors

An 'EventVersions' is a type-level list of types, indexed by Peano numbers
to track their positions. For example:

@
EventVersions PeanoZero (PeanoSucc (PeanoSucc PeanoZero))
  ≈ [PayloadV0, PayloadV1]
@

Use 'FromList' to build version vectors from type-level lists.

= Constraint Management

'VersionConstraints' allows us to track that each version in a vector
satisfies some constraint (like JSON serialization). 'HasEvidenceList'
builds up this evidence inductively.

= Payload Extraction

'PayloadAtVersion' extracts the type at a specific version index, with
compile-time bounds checking via 'ValidateVersionBound'.

__Note:__ This is an internal module. Use "Hindsight.Events" for the public API.
-}
module Hindsight.Events.Internal.Versioning (
    -- * Version Vectors
    EventVersions (..),
    FromList,

    -- * Version Vector Queries
    FinalVersionType,
    PayloadAtVersion,

    -- * Constraint Management
    VersionConstraints (..),
    HasEvidenceList (..),
)
where

import Data.Kind (Constraint, Type)
import Data.Typeable (Proxy (..))
import GHC.TypeLits (ErrorMessage (..), TypeError)
import Hindsight.Events.Internal.TypeLevel (
    PeanoEqual,
    PeanoNat (..),
 )

-- -----------------------------------------------------------------------------
-- Versioned Type Vectors
-- -----------------------------------------------------------------------------

{- | Type-level vector of versioned payload types.

This GADT represents a non-empty list of types, indexed by Peano numbers.
The indices track the "start" and "end" positions in the version sequence.

* @startsAt@ - The version number where this vector begins
* @finalCount@ - One past the last version (i.e., length when startsAt = 0)

Constructors:

* 'Final' - A single-element vector (the last/only version)
* 'Then' - Prepend a type to an existing vector (earlier versions)

Example: A vector of 3 versions (0, 1, 2):

@
Then PayloadV0 (Then PayloadV1 (Final PayloadV2))
  :: EventVersions PeanoZero (PeanoSucc (PeanoSucc (PeanoSucc PeanoZero)))
@
-}
data EventVersions (startsAt :: PeanoNat) (finalCount :: PeanoNat) where
    -- | Final version in the vector
    Final :: Type -> EventVersions startsAt ('PeanoSucc startsAt)
    -- | Prepend an earlier version
    Then :: Type -> EventVersions ('PeanoSucc startsAt) finalCount -> EventVersions startsAt finalCount

{- | Convert a type-level list to an EventVersions GADT

This has a polymorphic kind to allow recursive usage at different indices.
The result kind is constrained at usage sites via 'EventVersionVector'.
-}
type FromList :: [Type] -> k
type family FromList payloadList where
    FromList (a ': '[]) = 'Final a
    FromList (a ': rest) = 'Then a (FromList rest)

-- -----------------------------------------------------------------------------
-- Version Vector Queries
-- -----------------------------------------------------------------------------

{- | Extract the final (most recent) type from a version vector.

This traverses the vector structure to find the 'Final' constructor.
-}
type FinalVersionType :: EventVersions startsAt finalCount -> Type
type family FinalVersionType vec where
    FinalVersionType ('Final t) = t
    FinalVersionType ('Then t rest) = FinalVersionType rest

{- | Extract the type at a specific version index.

Returns a compile error if the index is out of bounds.
-}
type PayloadAtVersion ::
    forall (startsAt :: PeanoNat) (finalCount :: PeanoNat).
    PeanoNat ->
    EventVersions startsAt finalCount ->
    Type
type family PayloadAtVersion idx vec where
    PayloadAtVersion idx ('Final t :: EventVersions startsAt ('PeanoSucc startsAt)) =
        PeanoEqual idx startsAt t (TypeError ('Text "Version index out of bounds"))
    PayloadAtVersion idx ('Then t rest :: EventVersions startsAt finalCount) =
        PeanoEqual idx startsAt t (PayloadAtVersion idx rest)

-- -----------------------------------------------------------------------------
-- Constraint Management
-- -----------------------------------------------------------------------------

{- | Evidence that each version in a vector satisfies some constraint.

This GADT packages up constraint evidence for all elements in an
'EventVersions' vector. It's structurally similar to the vector itself:

* 'VersionConstraintsLast' - Evidence for a single-element vector
* 'VersionConstraintsCons' - Evidence for the head, plus recursive evidence

The constraint @c@ is indexed by version number and payload type:

@
c :: PeanoNat -> Type -> Constraint
@

Example: Prove all versions are serializable:

@
class (ToJSON payload, FromJSON payload) => Serializable (idx :: PeanoNat) payload
...
evidence :: VersionConstraints myVersions Serializable
@
-}
type VersionConstraints :: EventVersions m n -> (PeanoNat -> Type -> Constraint) -> Type
data VersionConstraints (ts :: EventVersions startsAt finalCount) (c :: PeanoNat -> Type -> Constraint) where
    -- | Evidence for a single-element vector
    VersionConstraintsLast ::
        (c startsAt t) =>
        (Proxy startsAt, Proxy t) ->
        VersionConstraints ('Final t :: EventVersions startsAt ('PeanoSucc startsAt)) c
    -- | Evidence for head + inductive evidence for tail
    VersionConstraintsCons ::
        (c startsAt t) =>
        (Proxy startsAt, Proxy t) ->
        VersionConstraints ts' c ->
        VersionConstraints ('Then t ts' :: EventVersions startsAt finalCount) c

{- | Build constraint evidence for all elements in a version vector.

This class provides a way to automatically derive 'VersionConstraints'
evidence given:

1. Evidence that each individual version satisfies the constraint @c@
2. The structure of the version vector

The instances mirror the structure of 'EventVersions':

* Base case: single-element vector ('Final')
* Inductive case: multi-element vector ('Then')

Usage:

@
getEvidenceList :: VersionConstraints myVersions MyConstraint
@
-}
class HasEvidenceList (startsAt :: PeanoNat) (finalCount :: PeanoNat) (event :: k) (c :: k -> PeanoNat -> Type -> Constraint) (vec :: EventVersions startsAt finalCount) where
    -- | Derive the constraint evidence
    getEvidenceList :: VersionConstraints vec (c event)

-- | Base case: Evidence for a single-version vector
instance
    (c event startsAt payload) =>
    HasEvidenceList startsAt (PeanoSucc startsAt) event c (Final payload :: EventVersions startsAt (PeanoSucc startsAt))
    where
    getEvidenceList = VersionConstraintsLast @(c event) @startsAt @payload (Proxy, Proxy)

-- | Inductive case: Evidence for multi-version vector
instance
    ( c event startsAt payload
    , HasEvidenceList (PeanoSucc startsAt) finalCount event c ts
    ) =>
    HasEvidenceList startsAt finalCount event c (Then payload ts)
    where
    getEvidenceList =
        VersionConstraintsCons @(c event) @startsAt @payload
            (Proxy, Proxy)
            getEvidenceList
