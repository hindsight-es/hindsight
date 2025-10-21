{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module Hindsight.Store.PostgreSQL.Core.Schema
  ( createSchema,
  )
where

import Data.FileEmbed (embedFileRelative)
import Hasql.Session (Session)
import Hasql.Session qualified as Session
import Hindsight.Projection.Schema qualified as ProjectionSchema

-- | Creates the event store schema and projection schema
--
-- This creates both the event store tables (events, transactions, stream_heads)
-- and the projection metadata table, since sync projections are part of the
-- PostgreSQL store functionality.
createSchema :: Session ()
createSchema = do
  Session.sql $(embedFileRelative "sql/sql-store-schema.sql")
  ProjectionSchema.createProjectionSchema

