{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UndecidableInstances #-}

{-|
Module      : Hindsight.Events.Internal.TypeLevel
Description : Pure type-level utilities for event versioning
Copyright   : (c) 2024
License     : BSD3
Maintainer  : maintainer@example.com
Stability   : experimental

This module provides foundational type-level utilities used throughout the
Hindsight event system. These utilities are completely generic and not
specific to events.

= Peano Numbers

Peano natural numbers ('PeanoNat') are used for type-level arithmetic and
indexing. They're more amenable to pattern matching than GHC's built-in 'Nat'
kind, though we provide conversions between the two.

= Constraint Evidence

The 'Dict' type allows us to package up constraint evidence and pass it around
at runtime, enabling flexible constraint manipulation.

= Type-Level Comparisons

'PeanoEqual' provides compile-time conditionals based on type-level numbers.

__Note:__ This is an internal module. Use "Hindsight.Events" for the public API.
-}
module Hindsight.Events.Internal.TypeLevel
  ( -- * Peano Natural Numbers
    PeanoNat (..),
    ReifiablePeanoNat (..),

    -- ** Conversions
    ToPeanoNat,
    FromPeanoNat,

    -- * Constraint Evidence
    Dict (..),

    -- * Type-Level Comparisons
    PeanoEqual,

    -- * Type-Level List Utilities
    ListLength,
    AssertPeanoEqual,
  )
where

import Data.Kind (Constraint, Type)
import GHC.TypeLits
  ( ErrorMessage (..),
    Nat,
    Symbol,
    TypeError,
    type (+),
    type (-),
  )

-- -----------------------------------------------------------------------------
-- Peano Natural Numbers
-- -----------------------------------------------------------------------------

-- | Type-level Peano natural numbers.
--
-- These provide an alternative representation to GHC's 'Nat' that's more
-- suitable for structural recursion and pattern matching at the type level.
--
-- @
-- 0 = PeanoZero
-- 1 = PeanoSucc PeanoZero
-- 2 = PeanoSucc (PeanoSucc PeanoZero)
-- ...
-- @
data PeanoNat = PeanoZero | PeanoSucc PeanoNat

-- | Convert type-level Peano numbers to runtime integers.
--
-- This class allows us to "reify" type-level numbers into runtime values,
-- which is necessary for parsing version numbers from JSON and other
-- runtime operations.
class ReifiablePeanoNat (n :: PeanoNat) where
  -- | Get the runtime integer value of a Peano number
  reifyPeanoNat :: Integer

instance ReifiablePeanoNat 'PeanoZero where
  reifyPeanoNat = 0

instance (ReifiablePeanoNat n) => ReifiablePeanoNat ('PeanoSucc n) where
  reifyPeanoNat = 1 + reifyPeanoNat @n

-- | Convert GHC's 'Nat' to Peano representation.
--
-- This is needed because type families and data families use 'Nat',
-- but we need 'PeanoNat' for structural pattern matching.
type family ToPeanoNat (n :: Nat) :: PeanoNat where
  ToPeanoNat 0 = 'PeanoZero
  ToPeanoNat n = 'PeanoSucc (ToPeanoNat (n - 1))

-- | Convert Peano representation back to GHC's 'Nat'.
--
-- This is the inverse of 'ToPeanoNat' and is needed for some constraint
-- manipulations where GHC requires 'Nat'.
type family FromPeanoNat (n :: PeanoNat) :: Nat where
  FromPeanoNat 'PeanoZero = 0
  FromPeanoNat ('PeanoSucc n) = 1 + FromPeanoNat n

-- -----------------------------------------------------------------------------
-- Constraint Evidence
-- -----------------------------------------------------------------------------

-- | Dictionary carrying constraint evidence.
--
-- This allows us to package up constraints and manipulate them at runtime.
-- It's particularly useful for passing around evidence that certain
-- type-level properties hold.
--
-- Example use: storing evidence that a payload satisfies serialization
-- constraints so we can retrieve it later when needed.
data Dict (c :: Constraint) where
  Dict :: (c) => Dict c

-- -----------------------------------------------------------------------------
-- Type-Level Comparisons and Bounds Checking
-- -----------------------------------------------------------------------------

-- | Type-level equality check with conditional results.
--
-- Returns @thenResult@ if @a@ and @b@ are equal, @elseResult@ otherwise.
--
-- This is used for version number matching.
--
-- @
-- PeanoEqual PeanoZero PeanoZero "yes" "no" = "yes"
-- PeanoEqual (PeanoSucc PeanoZero) PeanoZero "yes" "no" = "no"
-- @
type PeanoEqual :: PeanoNat -> PeanoNat -> result -> result -> result
type family PeanoEqual a b thenResult elseResult where
  PeanoEqual n n thenResult _ = thenResult
  PeanoEqual n m _ elseResult = elseResult

-- -----------------------------------------------------------------------------
-- Type-Level List Utilities
-- -----------------------------------------------------------------------------

-- | Compute the length of a type-level list as a Peano number.
--
-- This is used to validate that the number of versions declared in a
-- 'Versions' list matches the 'MaxVersion' annotation.
--
-- @
-- ListLength '[] = PeanoZero
-- ListLength '[A] = PeanoSucc PeanoZero
-- ListLength '[A, B, C] = PeanoSucc (PeanoSucc (PeanoSucc PeanoZero))
-- @
type ListLength :: [Type] -> PeanoNat
type family ListLength xs where
  ListLength '[] = 'PeanoZero
  ListLength (_ ': xs) = 'PeanoSucc (ListLength xs)

-- | Assert that two Peano numbers are equal, producing a custom error if not.
--
-- This is a generic type-level equality check with custom error messages.
-- The error message is provided by the caller, allowing this utility to be
-- reused in different contexts.
--
-- Example usage:
--
-- @
-- type CheckListLength xs expectedLen =
--   AssertPeanoEqual
--     (ListLength xs)
--     expectedLen
--     ('Text "List length mismatch: expected " ':<>: 'ShowType expectedLen)
-- @
type AssertPeanoEqual :: PeanoNat -> PeanoNat -> ErrorMessage -> Constraint
type family AssertPeanoEqual actual expected errorMsg where
  AssertPeanoEqual n n _ = ()
  AssertPeanoEqual _ _ errorMsg = TypeError errorMsg
