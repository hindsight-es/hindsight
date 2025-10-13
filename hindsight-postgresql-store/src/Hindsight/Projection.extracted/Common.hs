{-|
Module      : Hindsight.Projection.Common
Description : Re-export of core parsing utilities + projection-specific types
Copyright   : (c) 2024
License     : BSD3
Maintainer  : maintainer@example.com
Stability   : experimental

This module re-exports event parsing utilities from Hindsight.Store.Parsing (in core)
and adds projection-specific types and results.

CLEANUP NOTE: During Phase 4 extraction, we discovered that parseStoredEventToEnvelope
and related functions are NOT projection-specific - they're core store infrastructure.
These functions were moved to Hindsight.Store.Parsing in the core package where they belong.

This module maintains backward compatibility by re-exporting those functions.
-}
module Hindsight.Projection.Common
  ( -- * Event Processing Utilities (re-exported from core)
    parseEventPayload,
    parseStoredEventToEnvelope,
    createEventEnvelope,

    -- * Projection-Specific Types
    ProjectionResult (..),
    ProjectionError (..),
  )
where

import Control.Exception (SomeException)
import Data.Text (Text)
import Hindsight.Store.Parsing (parseEventPayload, parseStoredEventToEnvelope, createEventEnvelope)

-- | Result of projection execution
data ProjectionResult
  = ProjectionSuccess
  | ProjectionSkipped  -- Handler didn't match the event
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
