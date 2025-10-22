PostgreSQL Projections
=====================

PostgreSQL projections provide **durable, database-native** read models with ACID guarantees.
Unlike in-memory projections, these survive application restarts and leverage SQL's full power.

Hindsight's PostgreSQL projections are backend-agnostic. For example, you can perfectly use
PostgreSQL read models while using the filesystem event store.

The SQL projection mechanism is based on Hasql.

Prerequisites
-------------

\begin{code}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE RequiredTypeArguments #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Main where

import Control.Concurrent (forkIO, killThread)
import Control.Exception (bracket)
import Data.Aeson (FromJSON, ToJSON)
import Data.Functor.Contravariant ((>$<))
import Data.Map.Strict qualified as Map
import Data.Text (Text)
import Data.Text.Encoding (decodeUtf8)
import Data.UUID.V4 qualified as UUID
import Database.Postgres.Temp qualified as Temp
import GHC.Generics (Generic)
import Hasql.Connection qualified as Connection
import Hasql.Connection.Setting qualified as ConnectionSetting
import Hasql.Connection.Setting.Connection qualified as ConnectionSettingConnection
import Hasql.Decoders qualified as D
import Hasql.Encoders qualified as E
import Hasql.Pool qualified as Pool
import Hasql.Pool.Config qualified as Config
import Hasql.Session qualified as Session
import Hasql.Statement (Statement(..))
import Hasql.Transaction qualified as Transaction
import Hindsight
import Hindsight.Projection (runProjection, waitForEvent, ProjectionId(..))
import Hindsight.Projection.Matching (ProjectionHandlers(..))
import Hindsight.Store.Memory (newMemoryStore)
import Hindsight.Store.PostgreSQL.Core.Schema qualified as Schema
\end{code}

Define Events
-------------

As usual, let us start by defining our events:

\begin{code}
type UserRegistered = "user_registered"

data UserInfo = UserInfo
  { userId :: Text
  , userName :: Text
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)

-- Event versioning
type instance MaxVersion UserRegistered = 0
type instance Versions UserRegistered = '[UserInfo]
instance Event UserRegistered
instance MigrateVersion 0 UserRegistered

-- Event helper
registerUser :: Text -> Text -> SomeLatestEvent
registerUser uid name =
  mkEvent UserRegistered (UserInfo uid name)
\end{code}

Create a Projection Handler
----------------------------

Similar to subscription handlers, projection handlers take an event envelope (payload + metadata)
as their first argument. However, they must return a Hasql transaction object to be run by the projection
engine.

\begin{code}
-- Projection handler logic - updates a PostgreSQL table
-- This same logic works whether events come from Memory, Filesystem, or PostgreSQL
handleUserRegistration :: EventEnvelope UserRegistered backend -> Transaction.Transaction ()
handleUserRegistration eventData = do
  let payload = eventData.payload :: UserInfo
  -- Use parameterized Hasql query
  -- Encoder: (userId, userName) -> SQL parameters
  -- Decoder: () (no result expected)
  Transaction.statement (payload.userId, payload.userName) insertUserStatement
  where
    insertUserStatement :: Statement (Text, Text) ()
    insertUserStatement = Statement sql encoder decoder True
      where
        sql = "INSERT INTO users (user_id, user_name) VALUES ($1, $2)"
        encoder = (fst >$< E.param (E.nonNullable E.text))
               <> (snd >$< E.param (E.nonNullable E.text))
        decoder = D.noResult
\end{code}

Demo: Backend-Agnostic PostgreSQL Projections
----------------------------------------------

This demo shows the power of backend-agnostic projections:
- Events are stored in **MemoryStore** (fast, ephemeral)
- Projections execute and persist in **PostgreSQL** (durable, queryable)

\begin{code}
demoPostgreSQLProjection :: IO ()
demoPostgreSQLProjection = do
  putStrLn "=== PostgreSQL Projection Demo ==="

  -- Create a temporary PostgreSQL database for projections
  let dbConfig = Temp.defaultConfig
        <> mempty
          { Temp.postgresConfigFile =
              [ ("log_min_messages", "FATAL")
              , ("client_min_messages", "ERROR")
              ]
          }

  result <- Temp.withConfig dbConfig $ \db -> do
    let connStr = Temp.toConnectionString db
        connectionSettings = [ConnectionSetting.connection $ ConnectionSettingConnection.string (decodeUtf8 connStr)]
    putStrLn "✓ Created temporary PostgreSQL database"

    -- Initialize PostgreSQL schema for projections
    pool <- Pool.acquire $ Config.settings [Config.size 1, Config.staticConnectionSettings connectionSettings]
    _ <- Pool.use pool Schema.createSchema

    -- Create our projection table
    _ <- Pool.use pool $ Session.sql
      "CREATE TABLE users (user_id TEXT PRIMARY KEY, user_name TEXT)"

    putStrLn "✓ Initialized projection schema"

    -- Create a MemoryStore for events (not PostgreSQL!)
    store <- newMemoryStore
    putStrLn "✓ Created MemoryStore for events"

    -- Insert events into MemoryStore
    streamId <- StreamId <$> UUID.nextRandom
    let events = [ registerUser "U001" "Alice"
                 , registerUser "U002" "Bob"
                 ]

    insertionResult <- insertEvents store Nothing $
      Transaction $ Map.singleton streamId (StreamWrite Any events)

    case insertionResult of
      FailedInsertion err -> do
        putStrLn $ "✗ Insert failed: " <> show err

      SuccessfulInsertion (InsertionSuccess{finalCursor = cursor}) -> do
        putStrLn "✓ Inserted events into MemoryStore"

        -- Start projection in background thread
        -- Events come from MemoryStore, but projection runs in PostgreSQL!
        let projId = ProjectionId "user-directory"
        projectionThread <- forkIO $
          runProjection 
            projId
            pool
            Nothing
            store
            -- Define the handler list inline with concrete backend
            (match UserRegistered handleUserRegistration :-> ProjectionEnd)

        putStrLn "✓ Started projection (subscribing to MemoryStore)"

        -- Wait for projection to catch up
        bracket
          (do Right conn <- Connection.acquire connectionSettings; pure conn)
          Connection.release
          $ \conn -> do
            waitForEvent  projId cursor conn
            putStrLn "✓ Projection caught up"

        killThread projectionThread

        -- Query the projection table in PostgreSQL
        userCount <- Pool.use pool $ Session.statement () $
          Statement
            "SELECT COUNT(*) FROM users"
            mempty
            (D.singleRow (D.column (D.nonNullable D.int8)))
            True

        case userCount of
          Left err -> putStrLn $ "✗ Query failed: " <> show err
          Right count -> putStrLn $ "✓ Users in projection: " <> show count

        -- Query actual user data
        users <- Pool.use pool $ Session.statement () $
          Statement
            "SELECT user_id, user_name FROM users ORDER BY user_id"
            mempty
            (D.rowList ((,) <$> D.column (D.nonNullable D.text)
                            <*> D.column (D.nonNullable D.text)))
            True

        case users of
          Left err -> putStrLn $ "✗ Query failed: " <> show err
          Right rows -> do
            putStrLn "\n📋 Users in directory:"
            mapM_ (\(uid, name) -> putStrLn $ "  " <> show uid <> ": " <> show name) rows

    -- Cleanup
    Pool.release pool

  case result of
    Left err -> putStrLn $ "\n✗ Database error: " <> show err
    Right () -> putStrLn "\n✓ Demo complete (database cleaned up)"
\end{code}


Running the Example
-------------------

\begin{code}
main :: IO ()
main = do
  putStrLn "=== Hindsight Tutorial 03: PostgreSQL Projections ==="
  putStrLn ""

  demoPostgreSQLProjection

  putStrLn ""
  putStrLn "Tutorial complete!"
\end{code}

Summary
-------

Key concepts:

- **Backend-agnostic projections**: events can come from any store (Memory, Filesystem, PostgreSQL), while projections always run in PostgreSQL
- **Hasql transactions** provide ACID guarantees for projection state updates
- **Durable projections** survive application restarts, unlike in-memory models

Next Steps
----------

In the next tutorial, we'll explore **event versioning** - how to evolve
your event schemas over time while maintaining backward compatibility.
