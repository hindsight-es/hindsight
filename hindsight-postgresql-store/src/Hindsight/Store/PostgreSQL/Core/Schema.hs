{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

{- |
Module      : Hindsight.Store.PostgreSQL.Core.Schema
Description : PostgreSQL schema initialization for event store
Copyright   : (c) 2025
License     : BSD3
Maintainer  : gael@hindsight.events
Stability   : internal

Schema initialization for PostgreSQL event store, including event tables,
transaction tracking, and projection metadata.
-}
module Hindsight.Store.PostgreSQL.Core.Schema (
    createSchema,
)
where

import Data.FileEmbed (embedFileRelative)
import Hasql.Session (Session)
import Hasql.Session qualified as Session
import Hindsight.Projection.Schema qualified as ProjectionSchema

{- | Creates the event store schema and projection schema

This creates both the event store tables (events, transactions, stream_heads)
and the projection metadata table, since sync projections are part of the
PostgreSQL store functionality.
-}
createSchema :: Session ()
createSchema = do
    Session.sql $(embedFileRelative "sql/sql-store-schema.sql")
    ProjectionSchema.createProjectionSchema
