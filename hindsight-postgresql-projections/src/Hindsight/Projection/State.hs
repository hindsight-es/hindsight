{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}

{- |
Module      : Hindsight.Projection.State
Description : Shared projection state management operations
Copyright   : (c) 2025
License     : BSD3
Maintainer  : gael@hindsight.events
Stability   : experimental

This module provides shared database operations for managing projection state
in the 'projections' table. These operations work in both Session and Transaction
contexts, enabling reuse across sync and async projection implementations.

= Design Philosophy

The projections table tracks cursor positions and metadata for all projections
(both sync and async). This module provides the fundamental operations that both
projection types need, avoiding duplication while respecting their different
execution contexts.

= Usage

Both async and sync projections can use these operations:

@
-- In async projections (Session context)
Session.statement (projId, now, cursorJson) Projection.State.upsertProjectionCursor

-- In sync projections (Transaction context)
Transaction.statement (projId, now, cursorJson) Projection.State.upsertProjectionCursor
@
-}
module Hindsight.Projection.State (
    -- * State Update Operations
    upsertProjectionCursor,
    registerProjection,
)
where

import Data.Aeson qualified as Aeson
import Data.Text (Text)
import Hasql.Statement (Statement (..))
import Hasql.TH (resultlessStatement)

{- | Update or insert projection cursor position with error clearing.

This operation:
- Creates a new projection row if it doesn't exist
- Updates cursor position if row exists
- Marks projection as active
- Clears any error state
- Sets last_updated to current time (using SQL NOW())

Works in both Session and Transaction contexts via 'statement' functions.
-}
upsertProjectionCursor :: Statement (Text, Aeson.Value) ()
upsertProjectionCursor =
    [resultlessStatement|
    INSERT INTO projections (id, last_updated, head_position, is_active)
    VALUES ($1 :: text, NOW(), $2 :: jsonb, true)
    ON CONFLICT (id) DO UPDATE SET
      last_updated = NOW(),
      head_position = EXCLUDED.head_position,
      is_active = true,
      error_message = NULL,
      error_timestamp = NULL
  |]

{- | Register a projection without setting cursor position.

This is primarily used by sync projections during initialization to ensure
the projection row exists before catch-up begins.

Uses INSERT ... ON CONFLICT DO NOTHING to be idempotent.
-}
registerProjection :: Statement Text ()
registerProjection =
    [resultlessStatement|
    INSERT INTO projections (id, last_updated, is_active)
    VALUES ($1 :: text, NOW(), true)
    ON CONFLICT (id) DO NOTHING
  |]
