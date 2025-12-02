{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

{- |
Module      : Hindsight.Store.PostgreSQL.Events.Subscription
Description : Unified subscription system for PostgreSQL event store
Copyright   : (c) 2025
License     : BSD3
Maintainer  : gael@hindsight.events
Stability   : experimental

This module provides a decentralized, pull-based subscription system where each subscriber
is a self-contained agent.

= Design

The architecture consists of two main components:

1.  __The Notifier__: A single, lightweight process that listens for a generic
    "new event" notification from PostgreSQL and broadcasts a simple "tick" to all
    active subscribers.

2.  __The Subscriber Worker__: Each subscription runs in its own thread. The worker
    pulls data from the database in a unified loop, naturally handling both
    catch-up and real-time processing. It is responsible for its own state
    management and data fetching.

This design eliminates the complexity and bottlenecks of a centralized manager, provides
inherent backpressure, and leverages the database for efficient filtering.
-}
module Hindsight.Store.PostgreSQL.Events.Subscription (
    startNotifier,
    shutdownNotifier,
    subscribe,
    RetryPolicy (..),
    RetryConfig (..),
) where

import Control.Concurrent (threadDelay)
import Control.Concurrent.Async (async, cancel, wait)
import Control.Concurrent.STM (
    TChan,
    atomically,
    dupTChan,
    newBroadcastTChanIO,
    readTChan,
    writeTChan,
 )
import Control.Exception (AsyncException, Exception, SomeException, finally, try)
import Control.Monad (forever)
import Data.Aeson (Value)
import Data.Aeson.Types qualified as Aeson
import Data.Functor.Contravariant (contramap)
import Data.Int (Int32, Int64)
import Data.Map.Strict qualified as Map
import Data.Maybe (listToMaybe)
import Data.Proxy (Proxy (..))
import Data.Text (Text, isInfixOf, pack)
import Data.Text qualified as T
import Data.Text.Encoding (decodeUtf8)
import Data.Time (UTCTime)
import Data.UUID (UUID)
import GHC.Generics (Generic)
import Hasql.Connection qualified as Connection
import Hasql.Connection.Setting qualified as ConnectionSetting
import Hasql.Connection.Setting.Connection qualified as ConnectionSettingConnection
import Hasql.Decoders qualified as D
import Hasql.Encoders qualified as E
import Hasql.Notifications qualified as Notifications
import Hasql.Pool (UsageError (..))
import Hasql.Pool qualified as Pool
import Hasql.Session qualified as Session
import Hasql.Statement (Statement (..))
import Hindsight.Events
import Hindsight.Store hiding (subscribe)
import Hindsight.Store qualified as Store
import Hindsight.Store.PostgreSQL.Core.Types
import UnliftIO (
    MonadIO,
    MonadUnliftIO (..),
    askRunInIO,
    liftIO,
    newIORef,
    readIORef,
    writeIORef,
 )
import UnliftIO.Exception (catch, throwIO)

-- | Exception thrown when a subscription fails and should crash
data SubscriptionFailure = SubscriptionFailure
    { failureReason :: Text
    , underlyingError :: UsageError
    }
    deriving (Show, Generic)

instance Exception SubscriptionFailure

-- | Retry policy for different error types
data RetryPolicy = RetryPolicy
    { maxRetries :: Int -- Maximum number of retry attempts
    , baseDelayMs :: Int -- Base delay in milliseconds
    , maxDelayMs :: Int -- Maximum delay cap in milliseconds
    , backoffMultiplier :: Double -- Exponential backoff multiplier (e.g., 2.0)
    , jitterPercent :: Double -- Jitter percentage (0.0 - 1.0)
    }
    deriving (Show, Eq, Generic)

-- | Default retry policies for different error scenarios
data RetryConfig = RetryConfig
    { connectionRetryPolicy :: Maybe RetryPolicy -- For connection errors (transient)
    , sessionRetryPolicy :: Maybe RetryPolicy -- For session/query errors
    , timeoutRetryPolicy :: Maybe RetryPolicy -- For timeout errors
    }
    deriving (Show, Eq, Generic)

-- | Determines if a Pool usage error should cause immediate crash (no retry)
shouldCrashImmediately :: UsageError -> Bool
shouldCrashImmediately err = case err of
    -- Pool exhaustion - crash immediately, no point in retrying
    ConnectionUsageError connErr | "too many clients already" `isInfixOf` (pack $ show connErr) -> True
    -- Other errors might be retriable depending on configuration
    _ -> False

-- | Creates a SubscriptionFailure with appropriate reason
createSubscriptionFailure :: UsageError -> SubscriptionFailure
createSubscriptionFailure err = SubscriptionFailure reason err
  where
    reason = case err of
        ConnectionUsageError connErr
            | "too many clients already" `isInfixOf` (pack $ show connErr) ->
                "Connection pool exhausted - too many concurrent subscriptions"
        ConnectionUsageError _ ->
            "Database connection failed"
        SessionUsageError _ ->
            "Database query or session error"
        AcquisitionTimeoutUsageError ->
            "Failed to acquire database connection within timeout"

{- | Starts the notifier thread.
This should be created once per application and shared.
-}
startNotifier :: (MonadIO m) => ByteString -> m Notifier
startNotifier connectionString = liftIO $ do
    chan <- newBroadcastTChanIO
    thread <- async $ notifierLoop connectionString chan
    pure $ Notifier chan thread

{- | Stops the notifier thread and waits for it to terminate.

This ensures the notifier is fully stopped before returning,
preventing connection attempts after database shutdown.
-}
shutdownNotifier :: Notifier -> IO ()
shutdownNotifier notifier = do
    cancel (notifierThread notifier)
    -- Wait for the thread to actually terminate to avoid race conditions
    -- The wait will catch the async exception (ThreadKilled) that we sent via cancel
    _ <- try @SomeException $ wait (notifierThread notifier)
    pure ()

{- | The main loop for the notifier.
Connects to Postgres, listens for notifications, and broadcasts a tick.
Implements reconnect logic on connection failure.

Handles async exceptions (like ThreadKilled from shutdown) gracefully
by exiting immediately without attempting reconnection.
-}
notifierLoop :: ByteString -> TChan () -> IO ()
notifierLoop connectionString chan =
    ( forever $ do
        eConn <- Connection.acquire [ConnectionSetting.connection $ ConnectionSettingConnection.string (decodeUtf8 connectionString)]
        case eConn of
            Left _err -> do
                -- On connection error, wait and retry
                threadDelay 1000000
            Right conn -> do
                let cleanup = Connection.release conn
                    listen = Notifications.listen conn (Notifications.toPgIdentifier "event_store_transaction")
                    handler = \_ _ -> atomically $ writeTChan chan ()
                    waitForNotification = Notifications.waitForNotifications handler conn

                -- Run the listener, ensuring cleanup happens on any exception
                (listen >> waitForNotification) `finally` cleanup
    )
        `catch` \(_e :: AsyncException) -> do
            -- On async exception (shutdown/cancel), exit cleanly without reconnecting
            pure ()

{- | The main subscription function.
It replaces the old, complex manager-based subscription.
-}
subscribe ::
    forall m ts.
    (MonadUnliftIO m) =>
    SQLStoreHandle ->
    EventMatcher ts SQLStore m ->
    EventSelector SQLStore ->
    m (Store.SubscriptionHandle SQLStore)
subscribe handle matcher selector = do
    runInIO <- askRunInIO
    liftIO $ do
        -- Get a personal channel from the notifier's broadcast
        tickChannel <- atomically $ dupTChan (notifierChannel (notifier handle))

        let initialCursor = case selector.startupPosition of
                FromBeginning -> SQLCursor (-1) (-1)
                FromPosition cursor -> cursor

        -- Spawn an independent worker thread for this subscription
        workerThread <- async $ runInIO $ workerLoop (pool handle) tickChannel initialCursor matcher selector

        -- Return a handle that allows the user to cancel the subscription
        pure $
            Store.SubscriptionHandle
                { cancel = cancel workerThread
                , wait = wait workerThread
                }

-- | The main loop for an individual subscriber worker.
workerLoop ::
    (MonadUnliftIO m) =>
    Pool ->
    TChan () ->
    SQLCursor ->
    EventMatcher ts SQLStore m ->
    EventSelector SQLStore ->
    m ()
workerLoop pool tickChannel initialCursor matcher selector = do
    cursorRef <- newIORef initialCursor
    let batchSize = 1000 -- A configurable batch size would be better
    let loop = do
            cursor <- readIORef cursorRef
            batch <- fetchEventBatch pool cursor batchSize selector

            if null batch
                then do
                    -- No events available, wait for notification
                    liftIO $ atomically $ readTChan tickChannel
                    loop -- Continue loop
                else do
                    -- Process the batch of events
                    (newCursor, shouldContinue) <- processEventBatch matcher batch
                    writeIORef cursorRef newCursor
                    -- Only continue if handler didn't return Stop
                    if shouldContinue
                        then loop
                        else pure () -- Exit loop on Stop
    loop

-- | The raw event data structure fetched from the database.
data EventData = EventData
    { transactionXid8 :: Int64
    -- ^ PostgreSQL's native transaction ID (xid8)
    , seqNo :: Int32
    , eventId :: UUID
    , streamId :: UUID
    , correlationId :: Maybe UUID
    , createdAt :: UTCTime
    , eventName :: Text
    , eventVersion :: Int32
    , payload :: Value
    , streamVersion :: Int64
    }
    deriving (Show)

-- | Fetches a batch of events from the database using the given selector.
fetchEventBatch ::
    (MonadIO m) =>
    Pool ->
    SQLCursor ->
    Int ->
    EventSelector SQLStore ->
    m [EventData]
fetchEventBatch pool cursor limit selector = liftIO $ do
    let (sql, params) = case selector.streamId of
            AllStreams -> (allStreamsSql, allStreamsEncoder)
            SingleStream _ -> (singleStreamSql, singleStreamEncoder)

        statement = Statement sql params decoder True
        runSession = Session.statement (cursor, limit, selector) statement

    Pool.use pool runSession >>= \case
        Right events -> pure events
        Left err -> do
            putStrLn $ "Failed to fetch event batch: " <> show err
            if shouldCrashImmediately err
                then throwIO (createSubscriptionFailure err)
                else pure [] -- Could add retry logic here for recoverable errors
  where
    decoder =
        D.rowList $
            EventData
                <$> D.column (D.nonNullable D.int8)
                <*> D.column (D.nonNullable D.int4)
                <*> D.column (D.nonNullable D.uuid)
                <*> D.column (D.nonNullable D.uuid)
                <*> D.column (D.nullable D.uuid)
                <*> D.column (D.nonNullable D.timestamptz)
                <*> D.column (D.nonNullable D.text)
                <*> D.column (D.nonNullable D.int4)
                <*> D.column (D.nonNullable D.jsonb)
                <*> D.column (D.nonNullable D.int8)

-- SQL statements and encoders

baseSql :: ByteString
baseSql =
    "SELECT transaction_xid8::text::bigint, seq_no, event_id, stream_id, correlation_id, created_at, event_name, event_version, payload, stream_version "
        <> "FROM events "
        <> "WHERE (transaction_xid8::text::bigint, seq_no) > ($1, $2) "
        <> "AND transaction_xid8 < get_safe_transaction_xid8() "

allStreamsSql :: ByteString
allStreamsSql = baseSql <> "ORDER BY transaction_xid8, seq_no LIMIT $3"

singleStreamSql :: ByteString
singleStreamSql = baseSql <> "AND stream_id = $4 ORDER BY transaction_xid8, seq_no LIMIT $3"

allStreamsEncoder :: E.Params (SQLCursor, Int, EventSelector SQLStore)
allStreamsEncoder =
    contramap (\(c, _, _) -> c.transactionXid8) (E.param (E.nonNullable E.int8))
        <> contramap (\(c, _, _) -> c.sequenceNo) (E.param (E.nonNullable E.int4))
        <> contramap (\(_, l, _) -> fromIntegral l) (E.param (E.nonNullable E.int4))

singleStreamEncoder :: E.Params (SQLCursor, Int, EventSelector SQLStore)
singleStreamEncoder =
    contramap (\(c, _, _) -> c.transactionXid8) (E.param (E.nonNullable E.int8))
        <> contramap (\(c, _, _) -> c.sequenceNo) (E.param (E.nonNullable E.int4))
        <> contramap (\(_, l, _) -> fromIntegral l) (E.param (E.nonNullable E.int4))
        <> contramap (\(_, _, s) -> case s.streamId of SingleStream (StreamId sid) -> sid; _ -> error "impossible") (E.param (E.nonNullable E.uuid))

{- | Processes a batch of events, calling the appropriate handlers.
Returns (cursor, shouldContinue) where shouldContinue = False means handler returned Stop
IMPORTANT: Events are processed in the order they appear in the batch to respect causality
-}
processEventBatch ::
    forall m ts.
    (MonadUnliftIO m) =>
    EventMatcher ts SQLStore m ->
    [EventData] ->
    m (SQLCursor, Bool)
processEventBatch matcher batch = do
    stopRef <- newIORef False
    lastCursorRef <- newIORef Nothing

    -- Try to match a single event against all matchers
    let tryMatchers :: forall ts'. EventMatcher ts' SQLStore m -> EventData -> m ()
        tryMatchers MatchEnd eventData = do
            -- No matcher matched this event, just update cursor
            let cursor = SQLCursor eventData.transactionXid8 eventData.seqNo
            writeIORef lastCursorRef (Just cursor)
        tryMatchers ((proxy :: Proxy event, handler) :? rest) eventData = do
            let cursor = SQLCursor eventData.transactionXid8 eventData.seqNo
            if eventData.eventName == getEventName event
                then do
                    -- This matcher matches the event
                    case Map.lookup (fromIntegral eventData.eventVersion) (parseMapFromProxy proxy) of
                        Just parser ->
                            case Aeson.parseEither parser eventData.payload of
                                Right parsedPayload -> do
                                    let envelope =
                                            EventWithMetadata
                                                { position = cursor
                                                , eventId = EventId eventData.eventId
                                                , streamId = StreamId eventData.streamId
                                                , streamVersion = StreamVersion eventData.streamVersion
                                                , correlationId = CorrelationId <$> eventData.correlationId
                                                , createdAt = eventData.createdAt
                                                , payload = parsedPayload
                                                }
                                    -- Catch exceptions and enrich with event context
                                    result <-
                                        (handler envelope) `catch` \(e :: SomeException) ->
                                            throwIO $
                                                Store.HandlerException
                                                    { Store.originalException = e
                                                    , Store.failedEventPosition = T.pack $ show cursor
                                                    , Store.failedEventId = EventId eventData.eventId
                                                    , Store.failedEventName = eventData.eventName
                                                    , Store.failedEventStreamId = StreamId eventData.streamId
                                                    , Store.failedEventStreamVersion = StreamVersion eventData.streamVersion
                                                    , Store.failedEventCorrelationId = CorrelationId <$> eventData.correlationId
                                                    , Store.failedEventCreatedAt = eventData.createdAt
                                                    }
                                    -- Update last processed cursor
                                    writeIORef lastCursorRef (Just cursor)
                                    -- Check if handler wants to stop
                                    case result of
                                        Store.Stop -> writeIORef stopRef True
                                        Store.Continue -> pure ()
                                Left err ->
                                    throwIO $
                                        Store.EventParseException
                                            { Store.parseErrorMessage = "JSON parse error: " <> T.pack err
                                            , Store.failedEventPosition = T.pack $ show cursor
                                            , Store.failedEventId = EventId eventData.eventId
                                            , Store.failedEventName = eventData.eventName
                                            , Store.failedEventVersion = fromIntegral eventData.eventVersion
                                            , Store.failedEventStreamId = StreamId eventData.streamId
                                            , Store.failedEventStreamVersion = StreamVersion eventData.streamVersion
                                            , Store.failedEventCorrelationId = CorrelationId <$> eventData.correlationId
                                            , Store.failedEventCreatedAt = eventData.createdAt
                                            }
                        Nothing ->
                            throwIO $
                                Store.EventParseException
                                    { Store.parseErrorMessage = "Unknown event version: " <> T.pack (show eventData.eventVersion)
                                    , Store.failedEventPosition = T.pack $ show cursor
                                    , Store.failedEventId = EventId eventData.eventId
                                    , Store.failedEventName = eventData.eventName
                                    , Store.failedEventVersion = fromIntegral eventData.eventVersion
                                    , Store.failedEventStreamId = StreamId eventData.streamId
                                    , Store.failedEventStreamVersion = StreamVersion eventData.streamVersion
                                    , Store.failedEventCorrelationId = CorrelationId <$> eventData.correlationId
                                    , Store.failedEventCreatedAt = eventData.createdAt
                                    }
                else do
                    -- This matcher doesn't match, try next matcher
                    tryMatchers rest eventData

    -- Process all events in order, stopping if Stop is encountered
    let processAllEvents [] = pure ()
        processAllEvents (event : remaining) = do
            shouldStop <- readIORef stopRef
            if shouldStop
                then pure ()
                else do
                    tryMatchers matcher event
                    processAllEvents remaining

    processAllEvents batch

    -- Return the cursor and stop flag
    stopped <- readIORef stopRef
    lastCursor <- readIORef lastCursorRef

    -- Use last processed cursor, or fall back to last event in batch
    let finalCursor = case lastCursor of
            Just cursor -> cursor
            Nothing -> case listToMaybe (reverse batch) of
                Just lastEvent -> SQLCursor lastEvent.transactionXid8 lastEvent.seqNo
                Nothing -> error "processEventBatch called with an empty batch"

    pure (finalCursor, not stopped)
