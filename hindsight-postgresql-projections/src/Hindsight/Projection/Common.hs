{-|
Module      : Hindsight.Projection.Common
Description : Re-export of core parsing utilities + projection-specific types
Copyright   : (c) 2024
License     : BSD3
Maintainer  : maintainer@example.com
Stability   : experimental

This module re-exports event parsing utilities from Hindsight.Store.Parsing (in core)
and projection-specific error types from Hindsight.Projection.Error.

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

    -- * Projection-Specific Types (re-exported from Hindsight.Projection.Error)
    ProjectionResult (..),
    ProjectionError (..),
  )
where

import Hindsight.Projection.Error (ProjectionError (..), ProjectionResult (..))
import Hindsight.Store.Parsing (createEventEnvelope, parseEventPayload, parseStoredEventToEnvelope)
