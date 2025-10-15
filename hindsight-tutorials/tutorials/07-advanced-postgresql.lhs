Advanced PostgreSQL Features
============================

PostgreSQL projections can leverage the full power of SQL: joins, aggregations,
window functions, and complex queries. This tutorial shows advanced patterns,
including **synchronous projections** - a PostgreSQL-specific optimization.

Why PostgreSQL?
---------------

**Memory/Filesystem backends**:

- Simple projections
- In-process state
- Limited query capabilities

**PostgreSQL backend**:

- Complex SQL queries
- Joins across multiple event types
- Aggregations and analytics
- Database indexes for performance
- Synchronous projection support (strong consistency)

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
import Data.ByteString.Char8 qualified as BS
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

Define Multiple Event Types
----------------------------

\begin{code}
type OrderPlaced = "order_placed"
type OrderPaid = "order_paid"

data OrderInfo = OrderInfo
  { orderId :: Text
  , customerId :: Text
  , amount :: Double
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)

data PaymentInfo = PaymentInfo
  { orderId :: Text
  , paymentMethod :: Text
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)

-- Event versioning
type instance MaxVersion OrderPlaced = 0
type instance Versions OrderPlaced = FirstVersion OrderInfo
instance Event OrderPlaced
instance UpgradableToLatest OrderPlaced 0 where
  upgradeToLatest = id

type instance MaxVersion OrderPaid = 0
type instance Versions OrderPaid = FirstVersion PaymentInfo
instance Event OrderPaid
instance UpgradableToLatest OrderPaid 0 where
  upgradeToLatest = id

-- Helpers
placeOrder :: Text -> Text -> Double -> SomeLatestEvent
placeOrder oid cid amt =
  mkEvent OrderPlaced (OrderInfo oid cid amt)

payOrder :: Text -> Text -> SomeLatestEvent
payOrder oid method =
  mkEvent OrderPaid (PaymentInfo oid method)
\end{code}

Pattern 1: Aggregation Projection
----------------------------------

Calculate customer totals using SQL SUM:

\begin{code}
-- Projection that maintains customer spending totals
customerTotalsProjection :: ProjectionHandlers '[OrderPlaced] SQLStore
customerTotalsProjection =
  (Proxy @OrderPlaced, handleOrderForTotal) :-> ProjectionEnd
  where
    handleOrderForTotal eventData = do
      let order = eventData.payload :: OrderInfo
      -- Use UPSERT to maintain running totals
      Transaction.sql $
        "INSERT INTO customer_totals (customer_id, total_spent, order_count) \
        \VALUES ('" <> BS.pack (show order.customerId) <> "', "
                    <> BS.pack (show order.amount) <> ", 1) \
        \ON CONFLICT (customer_id) DO UPDATE SET \
        \  total_spent = customer_totals.total_spent + EXCLUDED.total_spent, \
        \  order_count = customer_totals.order_count + 1"
\end{code}

Pattern 2: JOIN Projection
---------------------------

Combine order and payment data:

\begin{code}
-- Track orders in one table
orderTrackingProjection :: ProjectionHandlers '[OrderPlaced, OrderPaid] SQLStore
orderTrackingProjection =
  (Proxy @OrderPlaced, handleOrderPlacement)
  :-> (Proxy @OrderPaid, handleOrderPayment)
  :-> ProjectionEnd
  where
    handleOrderPlacement eventData = do
      let order = eventData.payload :: OrderInfo
      Transaction.sql $
        "INSERT INTO orders (order_id, customer_id, amount, paid) \
        \VALUES ('" <> BS.pack (show order.orderId) <> "', '"
                    <> BS.pack (show order.customerId) <> "', "
                    <> BS.pack (show order.amount) <> ", FALSE)"

    handleOrderPayment eventData = do
      let payment = eventData.payload :: PaymentInfo
      -- Update the order to mark it as paid
      Transaction.sql $
        "UPDATE orders SET paid = TRUE, payment_method = '"
          <> BS.pack (show payment.paymentMethod)
          <> "' WHERE order_id = '"
          <> BS.pack (show payment.orderId) <> "'"
\end{code}

Demo: Advanced Queries
----------------------

\begin{code}
demoAdvancedPostgreSQL :: IO ()
demoAdvancedPostgreSQL = do
  putStrLn "=== Advanced PostgreSQL Projection Demo ==="

  let dbConfig = Temp.defaultConfig
        <> mempty { Temp.postgresConfigFile = [("log_min_messages", "FATAL")] }

  result <- Temp.withConfig dbConfig $ \db -> do
    let connStr = Temp.toConnectionString db
        connectionSettings = [ConnectionSetting.connection $ ConnectionSettingConnection.string (decodeUtf8 connStr)]

    -- First, initialize the database schema
    pool <- Pool.acquire $ Config.settings [Config.size 1, Config.staticConnectionSettings connectionSettings]
    _ <- Pool.use pool createSQLSchema

    -- Create projection tables
    _ <- Pool.use pool $ Session.sql
      "CREATE TABLE customer_totals (\
      \  customer_id TEXT PRIMARY KEY, \
      \  total_spent NUMERIC, \
      \  order_count INTEGER)"

    _ <- Pool.use pool $ Session.sql
      "CREATE TABLE orders (\
      \  order_id TEXT PRIMARY KEY, \
      \  customer_id TEXT, \
      \  amount NUMERIC, \
      \  paid BOOLEAN, \
      \  payment_method TEXT)"

    Pool.release pool

    -- Register projections
    let registry =
          registerSyncProjection
            (ProjectionId "customer-totals")
            customerTotalsProjection $
          registerSyncProjection
            (ProjectionId "order-tracking")
            orderTrackingProjection
            emptySyncProjectionRegistry

    -- Now create the store with projections (schema already exists)
    store <- newSQLStoreWithProjections connStr registry

    putStrLn "✓ Created tables and projections"

    -- Insert events
    streamId <- StreamId <$> UUID.nextRandom
    let events = [ placeOrder "O1" "C1" 100.0
                 , placeOrder "O2" "C1" 50.0
                 , payOrder "O1" "credit_card"
                 , placeOrder "O3" "C2" 200.0
                 , payOrder "O3" "paypal"
                 ]

    result <- insertEvents store Nothing $
      Transaction $ Map.singleton streamId (StreamWrite Any events)

    case result of
      SuccessfulInsertion _ -> do
        putStrLn "✓ Inserted events and ran projections"

        -- Query 1: Customer totals
        totals <- Pool.use (getPool store) $ Session.statement () $
          Statement
            "SELECT customer_id, total_spent, order_count FROM customer_totals \
            \ORDER BY total_spent DESC"
            mempty
            (D.rowList ((,,) <$> D.column (D.nonNullable D.text)
                             <*> D.column (D.nonNullable D.numeric)
                             <*> D.column (D.nonNullable D.int4)))
            True

        case totals of
          Left err -> putStrLn $ "✗ Query failed: " <> show err
          Right rows -> do
            putStrLn "\n📊 Customer Spending:"
            mapM_ (\(cid, spent, count) ->
              putStrLn $ "  " <> show cid <> ": $" <> show spent
                      <> " (" <> show count <> " orders)") rows

        -- Query 2: Paid vs unpaid orders
        orderStatus <- Pool.use (getPool store) $ Session.statement () $
          Statement
            "SELECT COUNT(*) FILTER (WHERE paid = TRUE) as paid_count, \
            \       COUNT(*) FILTER (WHERE paid = FALSE) as unpaid_count \
            \FROM orders"
            mempty
            (D.singleRow ((,) <$> D.column (D.nonNullable D.int8)
                              <*> D.column (D.nonNullable D.int8)))
            True

        case orderStatus of
          Left err -> putStrLn $ "\n✗ Query failed: " <> show err
          Right (paid, unpaid) ->
            putStrLn $ "\n📦 Orders: " <> show paid <> " paid, "
                    <> show unpaid <> " unpaid"

      FailedInsertion err ->
        putStrLn $ "✗ Insert failed: " <> show err

    shutdownSQLStore store
    Pool.release (getPool store)

  case result of
    Left err -> putStrLn $ "\n✗ Database error: " <> show err
    Right () -> putStrLn "\n✓ Demo complete (database cleaned up)"
\end{code}

Understanding Synchronous Projections
--------------------------------------

The demo above uses **synchronous projections** - a PostgreSQL-specific optimization.
Let's understand what makes them special.

**Asynchronous Projections** (Tutorial 03):

- Run in a separate thread using `runProjection`
- Subscribe to events and process independently
- **Eventually consistent** - small delay between insert and projection update
- Work with ANY backend (Memory/Filesystem/PostgreSQL)
- More flexible but less consistent

**Synchronous Projections** (this tutorial):

- Run **within** the event insert transaction
- Registered with `registerSyncProjection` and `newSQLStoreWithProjections`
- **Strongly consistent** - projection updates atomically with insert
- Only work with PostgreSQL backend
- ACID guarantees: if projection fails, entire insert rolls back

**Trade-offs:**

```haskell
-- Async (backend-agnostic):
runProjection  projId pool Nothing store handlers
-- ✅ Works with any backend
-- ✅ Flexible
-- ❌ Eventually consistent

-- Sync (PostgreSQL-only):
let registry = registerSyncProjection projId handlers emptySyncProjectionRegistry
store <- newSQLStoreWithProjections connStr registry
-- ✅ Strongly consistent (ACID)
-- ✅ No lag between insert and projection
-- ❌ Only works with SQLStore
-- ❌ Projection failures block inserts
```

**When to Use Synchronous Projections:**

- Critical read models that must be immediately consistent
- When you need ACID guarantees across events and projections
- When projection failures should prevent event persistence
- When you're already using PostgreSQL for event storage

**When to Use Asynchronous Projections:**

- Testing with MemoryStore or FilesystemStore
- When you need backend flexibility
- When eventual consistency is acceptable
- When projection failures shouldn't block event inserts

The examples in this tutorial use synchronous projections because they demonstrate
PostgreSQL-specific features and require strong consistency for the demo queries.

Running the Example
-------------------

\begin{code}
main :: IO ()
main = do
  putStrLn "=== Hindsight Tutorial 07: Advanced PostgreSQL ==="
  putStrLn ""

  demoAdvancedPostgreSQL

  putStrLn "\n✓ Tutorial complete!"
\end{code}

Advanced Patterns
-----------------

**Aggregations**:

- Use `SUM`, `COUNT`, `AVG` in projections
- Maintain running totals with UPSERT
- Calculate metrics in real-time

**Joins**:

- Combine data from multiple event types
- Build denormalized read models
- Optimize for query patterns

**Filters and Conditions**:

- Use `WHERE` clauses to filter events
- Apply business logic in SQL
- Handle NULL values with COALESCE

**Indexes**:
```sql
CREATE INDEX idx_customer ON orders(customer_id);
CREATE INDEX idx_paid ON orders(paid) WHERE paid = FALSE;
```

Summary
-------

PostgreSQL projections enable:

- **Complex queries**: Joins, aggregations, window functions
- **Performance**: Database indexes and query optimization
- **Durability**: Persistent read models
- **SQL power**: Full database feature set
- **Synchronous execution**: Strong consistency with ACID guarantees

Use PostgreSQL projections for:

- Production read models
- Complex analytics
- Multi-event joins
- High-performance queries
- Critical read models requiring strong consistency (use synchronous projections)

Congratulations!
----------------

You've completed all Hindsight tutorials:
1. Getting Started
2. In-Memory Projections
3. PostgreSQL Projections
4. Event Versioning
5. Consistency Patterns
6. Backend-Agnostic Code
7. Advanced PostgreSQL

You're now ready to build production event-sourced applications!
