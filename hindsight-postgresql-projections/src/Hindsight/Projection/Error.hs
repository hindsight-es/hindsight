{-|
Module      : Hindsight.Projection.Error
Description : Error types for projection execution
Copyright   : (c) 2024
License     : BSD3
Maintainer  : maintainer@example.com
Stability   : experimental

Error types and results for projection handlers.
-}
module Hindsight.Projection.Error
  ( ProjectionResult (..),
    ProjectionError (..),
  )
where

import Control.Exception (SomeException)
import Data.Text (Text)

-- | Result of projection execution
data ProjectionResult
  = ProjectionSuccess
  | ProjectionSkipped  -- ^ Handler didn't match the event
  | ProjectionError ProjectionError
  deriving (Show, Eq)

-- | Types of projection errors
data ProjectionError
  = ParseError Text
  | HandlerError SomeException
  | BackendError Text
  deriving (Show)

-- | Manual Eq instance for ProjectionError
--
-- SomeException doesn't have an Eq instance, so we compare based on the string representation
instance Eq ProjectionError where
  (ParseError t1) == (ParseError t2) = t1 == t2
  (HandlerError e1) == (HandlerError e2) = show e1 == show e2
  (BackendError t1) == (BackendError t2) = t1 == t2
  _ == _ = False
