PostgreSQL Projections
=====================

PostgreSQL projections provide **durable, database-native** read models with ACID guarantees.
Unlike in-memory projections, these survive application restarts and leverage SQL's full power.

The key insight: **projections are backend-agnostic**. You can subscribe to events from ANY
backend (Memory, Filesystem, PostgreSQL) while storing projection state in PostgreSQL.

What Makes PostgreSQL Projections Different?
--------------------------------------------

**In-Memory Projections** (Tutorial 02):

- Fast but ephemeral (lost on restart)
- Good for transient state
- Use STM for concurrency

**PostgreSQL Projections** (this tutorial):

- Durable (survive restarts)
- Good for persistent read models
- Use SQL transactions for consistency
- Can query with full SQL power
- Work with ANY event store backend

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
import Data.ByteString.Char8 qualified as BS
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

Projection handlers execute SQL in PostgreSQL transactions. The handler logic is the same
regardless of which backend provides the events.

**IMPORTANT**: Always use parameterized queries to prevent SQL injection vulnerabilities.

\begin{code}
-- Projection handler logic - updates a PostgreSQL table
-- This same logic works whether events come from Memory, Filesystem, or PostgreSQL
handleUserRegistration :: EventEnvelope UserRegistered backend -> Transaction.Transaction ()
handleUserRegistration eventData = do
  let payload = eventData.payload :: UserInfo
  -- Use parameterized query for security (prevents SQL injection)
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

Key Concepts
-----------

**Backend-Agnostic Projections**:

- Projection handlers are generic: `ProjectionHandlers ts backend`
- Events can come from ANY backend (Memory, Filesystem, PostgreSQL)
- Projection state and execution always use PostgreSQL
- Same projection code works with different event stores

**Asynchronous Execution**:

- Projections run in a **separate thread**
- Subscribe to events and process them independently
- Use `waitForEvent` to synchronize when needed
- Eventually consistent (not synchronous with inserts)

**Transaction.sql**:

- Executes SQL within PostgreSQL transactions
- Can INSERT, UPDATE, DELETE
- Failures are handled by projection system
- Each event is processed in its own transaction

**Why This Matters**:

- Test with fast MemoryStore
- Deploy with durable PostgreSQL events
- Mix and match: Memory events + SQL projections for development
- Deployment: PostgreSQL events + SQL projections

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

PostgreSQL projections offer:

- **Durability**: Survive application restarts
- **Backend-agnostic**: Work with any event store
- **SQL power**: Full database features (joins, indexes, etc.)
- **Flexibility**: Test with Memory, deploy with PostgreSQL

Architecture:

- **Event storage**: ANY backend (Memory/Filesystem/PostgreSQL)
- **Projection state**: Always PostgreSQL
- **Projection execution**: Always PostgreSQL transactions
- **Consistency**: Eventually consistent (asynchronous)

When to use:

- **PostgreSQL projections**: Persistent read models
- **In-memory projections**: Transient state, caches, temporary aggregations

Next Steps
----------

In the next tutorial, we'll explore **event versioning** - how to evolve
your event schemas over time while maintaining backward compatibility.
