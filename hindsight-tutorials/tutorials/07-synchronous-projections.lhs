Synchronous Projections
========================

Tutorial 03 introduced PostgreSQL projections that run asynchronously - they subscribe to events
and update in a separate thread, leading to eventual consistency. **Synchronous projections** are
a PostgreSQL-specific feature that runs projections **within the event insert transaction**,
eliminating lag and providing immediate consistency.

Prerequisites
-------------

\begin{code}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE RequiredTypeArguments #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Main where

import Data.Aeson (FromJSON, ToJSON)
import Data.Functor.Contravariant ((>$<))
import Data.Int (Int32)
import Data.Map.Strict qualified as Map
import Data.Proxy (Proxy(..))
import Data.Text (Text)
import Data.Text.Encoding (decodeUtf8)
import Data.UUID.V4 qualified as UUID
import Database.Postgres.Temp qualified as Temp
import GHC.Generics (Generic)
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
import Hindsight.Projection (ProjectionId(..))
import Hindsight.Projection.Matching (ProjectionHandlers(..))
import Hindsight.Store.PostgreSQL (SQLStore, getPool, emptySyncProjectionRegistry, registerSyncProjection, newSQLStoreWithProjections, shutdownSQLStore, createSQLSchema)
\end{code}

Define Events
-------------

\begin{code}
type AccountCredited = "account_credited"

data CreditInfo = CreditInfo
  { accountId :: Text
  , amount :: Int32
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)

-- Event versioning
type instance MaxVersion AccountCredited = 0
type instance Versions AccountCredited = '[CreditInfo]
instance Event AccountCredited
instance MigrateVersion 0 AccountCredited
\end{code}

Synchronous Projection Handler
-------------------------------

Define a projection that updates account balances:

\begin{code}
-- Projection runs within insert transaction
balanceProjection :: ProjectionHandlers '[AccountCredited] SQLStore
balanceProjection =
  (Proxy @AccountCredited, handleCredit) :-> ProjectionEnd
  where
    handleCredit eventData = do
      let credit = eventData.payload :: CreditInfo
      Transaction.statement (credit.accountId, credit.amount) upsertBalanceStatement
      where
        upsertBalanceStatement :: Statement (Text, Int32) ()
        upsertBalanceStatement = Statement sql encoder decoder True
          where
            sql = "INSERT INTO balances (account_id, balance) \
                  \VALUES ($1, $2) \
                  \ON CONFLICT (account_id) DO UPDATE SET \
                  \  balance = balances.balance + EXCLUDED.balance"
            encoder = (fst >$< E.param (E.nonNullable E.text))
                   <> (snd >$< E.param (E.nonNullable E.int4))
            decoder = D.noResult
\end{code}

Demonstration
-------------

We'll demonstrate synchronous projections in three steps: create a projection registry,
pass it to a special store constructor, then insert events and query immediately without
any delay.

Start with database setup (boilerplate):

\begin{code}
demoSyncProjection :: IO ()
demoSyncProjection = do
  putStrLn "=== Synchronous Projection Demo ==="

  let dbConfig = Temp.defaultConfig
        <> mempty { Temp.postgresConfigFile = [("log_min_messages", "FATAL")] }

  result <- Temp.withConfig dbConfig $ \db -> do
    let connStr = Temp.toConnectionString db

    pool <- Pool.acquire $ Config.settings [
        Config.size 1,
        Config.staticConnectionSettings [
          ConnectionSetting.connection $ ConnectionSettingConnection.string (decodeUtf8 connStr)
        ]
      ]
    _ <- Pool.use pool createSQLSchema
    _ <- Pool.use pool $ Session.sql
      "CREATE TABLE balances (account_id TEXT PRIMARY KEY, balance INTEGER)"
    Pool.release pool
\end{code}

Now create a **synchronous projection registry**. Start with `emptySyncProjectionRegistry`
and add projections using `registerSyncProjection`. You can chain multiple registrations
together:

\begin{code}
    let registry = registerSyncProjection
                     (ProjectionId "balances")
                     balanceProjection
                     emptySyncProjectionRegistry
\end{code}

Pass the registry to `newSQLStoreWithProjections`. This is different from the regular
store constructor - it wires registered projections to run within event insert transactions:

\begin{code}
    store <- newSQLStoreWithProjections connStr registry
    putStrLn "✓ Created store with synchronous projection"
\end{code}

Insert events. The projection runs atomically in the same transaction:

\begin{code}
    streamId <- StreamId <$> UUID.nextRandom
    let events = [ mkEvent AccountCredited (CreditInfo "A1" 100)
                 , mkEvent AccountCredited (CreditInfo "A1" 50)
                 , mkEvent AccountCredited (CreditInfo "A2" 200)
                 ]

    _ <- insertEvents store Nothing $
      Transaction $ Map.singleton streamId (StreamWrite Any events)

    putStrLn "✓ Inserted events (projection ran immediately)"
\end{code}

Query immediately. Notice we don't need `threadDelay` - the projection already completed
as part of the insert transaction:

\begin{code}
    balance <- Pool.use (getPool store) $ Session.statement () $
      Statement
        "SELECT account_id, balance FROM balances ORDER BY account_id"
        mempty
        (D.rowList ((,) <$> D.column (D.nonNullable D.text)
                        <*> D.column (D.nonNullable D.int4)))
        True

    case balance of
      Left err -> putStrLn $ "✗ Query failed: " <> show err
      Right rows -> do
        putStrLn "\nBalances (immediately available):"
        mapM_ (\(acid, bal) -> putStrLn $ "  " <> show acid <> ": " <> show bal) rows

    shutdownSQLStore store
    Pool.release (getPool store)

  case result of
    Left err -> putStrLn $ "\n✗ Database error: " <> show err
    Right () -> putStrLn "\n✓ Demo complete"
\end{code}

Trade-offs
----------

**Synchronous projections**:

- ✅ Immediate consistency - no lag
- ✅ Query immediately after insert
- ❌ PostgreSQL-only
- ❌ Projection failures block inserts

**Asynchronous projections** (Tutorial 03):

- ✅ Backend-agnostic (works with Memory/Filesystem/PostgreSQL)
- ✅ Projection failures don't block inserts
- ❌ Eventually consistent - small lag
- ❌ Need to wait for projection updates

Running the Example
-------------------

\begin{code}
main :: IO ()
main = do
  putStrLn "=== Hindsight Tutorial 07: Synchronous Projections ==="
  putStrLn ""

  demoSyncProjection

  putStrLn "\nTutorial complete!"
\end{code}

Summary
-------

Key concepts:

- **Synchronous projections** run within the insert transaction, eliminating lag
- **Immediate consistency**: Query results available instantly after insert
- **PostgreSQL-only**: Trade backend flexibility for consistency guarantees
