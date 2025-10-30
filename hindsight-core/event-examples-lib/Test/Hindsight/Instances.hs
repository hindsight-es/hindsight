{-# OPTIONS_GHC -Wno-orphans #-}

{- |
Module      : Test.Hindsight.Instances
Description : Orphan Arbitrary instances for testing
Copyright   : (c) 2025
License     : BSD3

Orphan 'Arbitrary' instances for common types used in event testing.

These instances generate deterministic, predictable values suitable for
property-based testing and golden tests.
-}
module Test.Hindsight.Instances () where

import Data.Text (Text)
import Data.Text qualified as T
import Test.QuickCheck (Arbitrary (..), elements, listOf)

{- | Deterministic Text generation for property tests.

Generates ASCII alphanumeric strings only for predictable test behavior.
Shrinks by removing characters from the end.

This is an orphan instance, but acceptable in test-only modules where
consistent, reproducible Text generation is needed.
-}
instance Arbitrary Text where
    arbitrary = T.pack <$> listOf (elements validChars)
      where
        validChars = ['a' .. 'z'] ++ ['A' .. 'Z'] ++ ['0' .. '9']

    shrink t = [T.take n t | n <- [0 .. T.length t - 1]]
