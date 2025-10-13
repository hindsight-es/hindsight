{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module Hindsight.Store.PostgreSQL.Core.Schema
  ( createSchema,
  )
where

import Data.FileEmbed (embedFileRelative)
import Hasql.Session (Session)
import Hasql.Session qualified as Session

-- | Creates the event store schema
createSchema :: Session ()
createSchema =
  Session.sql $
    $(embedFileRelative "sql/sql-store-schema.sql")

