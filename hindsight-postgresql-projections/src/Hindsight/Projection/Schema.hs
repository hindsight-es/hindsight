{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

{- |
Module      : Hindsight.Projection.Schema
Description : PostgreSQL schema for async projections
Copyright   : (c) 2025
License     : BSD3
Maintainer  : gael@hindsight.events
Stability   : experimental

This module provides the schema initialization for async projections.

The schema is compatible with (and can coexist with) the sync projection
schema from hindsight-postgresql-store. Both use the same 'projections' table,
but async projections additionally create a NOTIFY trigger for efficient
event waiting.

= Idempotency

All schema operations use 'CREATE IF NOT EXISTS' and 'CREATE OR REPLACE',
making them safe to run multiple times and alongside other projection systems.

= Migration Path

- Sync → Async: NOTIFY trigger gets added automatically
- Async → Sync: Trigger remains (harmless), or can be dropped manually
- Both: They share the table harmoniously
-}
module Hindsight.Projection.Schema (
    createProjectionSchema,
)
where

import Data.FileEmbed (embedFileRelative)
import Hasql.Session (Session)
import Hasql.Session qualified as Session

{- | Creates the projection state schema

This creates the 'projections' table and the LISTEN/NOTIFY trigger for
async projection progress notifications.

Safe to call multiple times (idempotent).
Safe to call alongside hindsight-postgresql-store schema (compatible).
-}
createProjectionSchema :: Session ()
createProjectionSchema =
    Session.sql $
        $(embedFileRelative "sql/projection-schema.sql")
