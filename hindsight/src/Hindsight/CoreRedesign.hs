{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE QuantifiedConstraints #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UndecidableInstances #-}

module Hindsight.CoreRedesign where

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
