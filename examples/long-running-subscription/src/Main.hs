{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeFamilies #-}

module Main (main) where

import Control.Concurrent (threadDelay)
import Control.Monad (forever)
import Control.Monad.IO.Class (liftIO)
import Data.Aeson (FromJSON, ToJSON)
import Data.Functor.Contravariant ((>$<))
import Data.Text (Text)
import Data.Text qualified as T
import Data.Text.Encoding (encodeUtf8)
import Data.Time.Clock (UTCTime, getCurrentTime)
import Data.UUID (UUID)
import Data.UUID qualified as Data.UUID
import Data.UUID.V4 qualified as UUID
import GHC.Generics (Generic)
import Hasql.Connection.Setting qualified as ConnSetting
import Hasql.Connection.Setting.Connection qualified as ConnSettingConn
import Hasql.Decoders qualified as D
import Hasql.Encoders qualified as E
import Hasql.Pool (Pool, UsageError)
import Hasql.Pool qualified as Pool
import Hasql.Pool.Config qualified as PoolConfig
import Hasql.Session qualified as Session
import Hasql.Statement (Statement (..))
import Hasql.Transaction qualified as Tx
import Hasql.Transaction.Sessions qualified as TxSession
import Network.Wai.Handler.Warp (run)
import Servant
import Servant.Server.Generic (AsServerT)
import System.Environment (lookupEnv)
import Text.Read (readMaybe)
import UnliftIO (async, link, race_)

import Hindsight
import Hindsight.Events (Event (..), MaxVersion, MigrateVersion, Versions, mkEvent)
import Hindsight.Projection (ProjectionId (..), runProjection)
import Hindsight.Projection.Matching (ProjectionHandlers (..))
import Hindsight.Store qualified as Store
import Hindsight.Store.PostgreSQL qualified as PGStore

-- | Simple counter event for testing
data CounterIncremented = CounterIncremented {amount :: Int}
    deriving stock (Show, Eq, Generic)
    deriving anyclass (FromJSON, ToJSON)

-- Event versioning instances
type instance MaxVersion "CounterIncremented" = 0
type instance Versions "CounterIncremented" = '[CounterIncremented]
instance Event "CounterIncremented"
instance MigrateVersion 0 "CounterIncremented"

-- | Servant API using NamedRoutes (because NamedRoutes is your baby!)
data API mode = API
    { addEvent :: mode :- "events" :> ReqBody '[JSON] AddEventRequest :> Post '[JSON] AddEventResponse
    , queryProjection :: mode :- "projection" :> Get '[JSON] ProjectionResponse
    , health :: mode :- "health" :> Get '[JSON] HealthResponse
    }
    deriving stock (Generic)

-- Request/Response types
newtype AddEventRequest = AddEventRequest {amount :: Int}
    deriving stock (Generic)
    deriving anyclass (FromJSON, ToJSON)

data AddEventResponse = AddEventResponse
    { eventId :: Text
    , message :: Text
    }
    deriving stock (Generic)
    deriving anyclass (FromJSON, ToJSON)

data ProjectionResponse = ProjectionResponse
    { currentCount :: Int
    , lastUpdated :: Maybe UTCTime
    }
    deriving stock (Generic)
    deriving anyclass (FromJSON, ToJSON)

data HealthResponse = HealthResponse
    { status :: Text
    , timestamp :: Text
    }
    deriving stock (Generic)
    deriving anyclass (FromJSON, ToJSON)

-- | Application state
data AppState = AppState
    { storeHandle :: Store.BackendHandle PGStore.SQLStore
    , projectionPool :: Pool
    , testStreamId :: Store.StreamId
    }

main :: IO ()
main = do
    putStrLn "Starting long-running subscription example..."

    -- Get configuration from environment
    dbHost <- maybe "localhost" id <$> lookupEnv "DB_HOST"
    dbPort <- maybe "5432" id <$> lookupEnv "DB_PORT"
    dbUser <- maybe "postgres" id <$> lookupEnv "DB_USER"
    dbPass <- maybe "postgres" id <$> lookupEnv "DB_PASS"
    dbName <- maybe "hindsight" id <$> lookupEnv "DB_NAME"
    apiPort <- maybe 8080 (\s -> maybe 8080 id (readMaybe s)) <$> lookupEnv "API_PORT"

    let connString =
            mconcat
                [ "postgres://"
                , dbUser
                , ":"
                , dbPass
                , "@"
                , dbHost
                , ":"
                , dbPort
                , "/"
                , dbName
                ]

    putStrLn $ "Database: " ++ connString
    putStrLn $ "API Port: " ++ show apiPort

    -- Create connection pool
    putStrLn "Creating connection pool..."
    let connSettings = [ConnSetting.connection $ ConnSettingConn.string (T.pack connString)]
        poolConfig = PoolConfig.settings [PoolConfig.size 10, PoolConfig.staticConnectionSettings connSettings]
    pool <- Pool.acquire poolConfig

    -- Initialize schema
    putStrLn "Initializing database schema..."
    schemaResult <- Pool.use pool PGStore.createSQLSchema
    case schemaResult of
        Left err -> error $ "Failed to create schema: " ++ show err
        Right () -> putStrLn "Schema initialized"

    -- Create projection table for counter
    putStrLn "Creating projection tables..."
    counterTableResult <-
        Pool.use pool $
            Session.sql $
                mconcat
                    [ "CREATE TABLE IF NOT EXISTS counter_projection ("
                    , "  id TEXT PRIMARY KEY,"
                    , "  count BIGINT NOT NULL DEFAULT 0,"
                    , "  last_updated TIMESTAMPTZ NOT NULL DEFAULT NOW()"
                    , ");"
                    , "INSERT INTO counter_projection (id, count, last_updated) "
                    , "VALUES ('counter', 0, NOW()) "
                    , "ON CONFLICT (id) DO NOTHING;"
                    ]
    case counterTableResult of
        Left err -> error $ "Failed to create counter table: " ++ show err
        Right () -> putStrLn "Counter table ready"

    -- Create store handle
    putStrLn "Creating event store handle..."
    storeHandle <- PGStore.newSQLStore (encodeUtf8 $ T.pack connString)

    -- Generate a test stream ID (using nil UUID for simplicity)
    let testStreamId = Store.StreamId Data.UUID.nil

    let appState = AppState storeHandle pool testStreamId
        projectionId = ProjectionId "counter-projection"

    -- Start projection in background
    putStrLn $ "Starting projection: " ++ T.unpack (unProjectionId projectionId)
    projectionAsync <- async $ runProjection projectionId pool Nothing storeHandle counterProjectionHandlers
    link projectionAsync

    -- Start heartbeat logger in background
    heartbeatAsync <- async $ heartbeatLogger pool
    link heartbeatAsync

    -- Start API server
    putStrLn $ "API server starting on port " ++ show apiPort
    putStrLn "Endpoints:"
    putStrLn "  POST /events       - Add counter event"
    putStrLn "  GET  /projection   - Query projection state"
    putStrLn "  GET  /health       - Health check"
    putStrLn ""
    putStrLn "Test with:"
    putStrLn $ "  curl -X POST http://localhost:" ++ show apiPort ++ "/events -H 'Content-Type: application/json' -d '{\"amount\": 5}'"
    putStrLn $ "  curl http://localhost:" ++ show apiPort ++ "/projection"

    race_
        (run apiPort $ serve (Proxy @(NamedRoutes API)) (apiHandlers appState))
        (threadDelay maxBound) -- Keep alive forever

-- | API handlers
apiHandlers :: AppState -> API (AsServerT Handler)
apiHandlers appState =
    API
        { addEvent = addEventHandler appState
        , queryProjection = queryProjectionHandler appState
        , health = healthHandler
        }

-- | Handler: Add event
addEventHandler :: AppState -> AddEventRequest -> Handler AddEventResponse
addEventHandler AppState{..} AddEventRequest{..} = do
    eventId <- liftIO UUID.nextRandom
    let event = mkEvent "CounterIncremented" (CounterIncremented amount)
        tx = Store.appendToOrCreateStream testStreamId event

    result <- liftIO $ Store.insertEvents storeHandle Nothing tx
    case result of
        Store.FailedInsertion err -> do
            liftIO $ putStrLn $ "Failed to append event: " ++ show err
            throwError err500{errBody = "Failed to append event"}
        Store.SuccessfulInsertion _ -> do
            liftIO $ putStrLn $ "Event added: " ++ Data.UUID.toString eventId ++ " (amount: " ++ show amount ++ ")"
            pure $ AddEventResponse (T.pack $ Data.UUID.toString eventId) "Event added successfully"

-- | Handler: Query projection
queryProjectionHandler :: AppState -> Handler ProjectionResponse
queryProjectionHandler AppState{..} = do
    result <- liftIO $ Pool.use projectionPool $ Session.statement () queryCounterStmt
    case result of
        Left err -> do
            liftIO $ putStrLn $ "Failed to query projection: " ++ show err
            throwError err500{errBody = "Failed to query projection"}
        Right (count', lastUpdated') ->
            pure $ ProjectionResponse (fromIntegral count') (Just lastUpdated')

-- | Handler: Health check
healthHandler :: Handler HealthResponse
healthHandler = do
    now <- liftIO getCurrentTime
    pure $ HealthResponse "ok" (T.pack $ show now)

-- | Projection handlers for counter events
counterProjectionHandlers :: ProjectionHandlers '["CounterIncremented"] PGStore.SQLStore
counterProjectionHandlers =
    Store.match "CounterIncremented" handleCounterEvent :-> ProjectionEnd

-- | Handle counter increment events
handleCounterEvent :: Store.EventEnvelope "CounterIncremented" PGStore.SQLStore -> Tx.Transaction ()
handleCounterEvent envelope = do
    let amt = (envelope.payload :: CounterIncremented).amount
    Tx.statement amt incrementCounterStmt

-- | Statement to increment counter
incrementCounterStmt :: Statement Int ()
incrementCounterStmt = Statement sql encoder D.noResult True
  where
    sql = "UPDATE counter_projection SET count = count + $1, last_updated = NOW() WHERE id = 'counter'"
    encoder = E.param (E.nonNullable (fromIntegral >$< E.int8))

-- | Statement to query counter
queryCounterStmt :: Statement () (Int, UTCTime)
queryCounterStmt = Statement sql E.noParams decoder True
  where
    sql = "SELECT count, last_updated FROM counter_projection WHERE id = 'counter'"
    decoder = D.singleRow $ (,) <$> (fromIntegral <$> D.column (D.nonNullable D.int8)) <*> D.column (D.nonNullable D.timestamptz)

-- | Heartbeat logger to prove subscription is alive
heartbeatLogger :: Pool -> IO ()
heartbeatLogger pool = forever $ do
    threadDelay (30 * 1000000) -- 30 seconds
    result <- Pool.use pool $ Session.statement () queryCounterStmt
    case result of
        Left err -> putStrLn $ "Heartbeat error: " ++ show err
        Right (count', lastUpdated') -> do
            now <- getCurrentTime
            putStrLn $ "Heartbeat [" ++ show now ++ "] - Projection count: " ++ show count' ++ " (last updated: " ++ show lastUpdated' ++ ")"
