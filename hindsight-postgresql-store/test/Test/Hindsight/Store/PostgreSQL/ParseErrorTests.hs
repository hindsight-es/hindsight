{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DisambiguateRecordFields #-}
{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}

{- |
Module      : Test.Hindsight.Store.PostgreSQL.ParseErrorTests
Description : Tests for proper error handling on event parse failures
Copyright   : (c) 2025
License     : BSD3
Maintainer  : gael@hindsight.events
Stability   : experimental

These tests verify that parse errors are properly surfaced as exceptions
rather than being silently swallowed. This is critical for correctness:
events that fail to parse should crash the subscription/projection with
full context, not be silently skipped.
-}
module Test.Hindsight.Store.PostgreSQL.ParseErrorTests (tests) where

import Data.Aeson qualified as Aeson
import Data.ByteString.Char8 qualified as BS
import Data.Functor.Contravariant ((>$<))
import Data.IORef (newIORef)
import Data.Int (Int32, Int64)
import Data.Proxy (Proxy (..))
import Data.Text (pack)
import Data.Text.Encoding qualified as Text.Encoding
import Data.UUID qualified as UUID
import Data.UUID.V4 qualified as UUID
import Hasql.Decoders qualified as Decoders
import Hasql.Encoders qualified as Encoders
import Hasql.Pool qualified as Pool
import Hasql.Session qualified as Session
import Hasql.Statement (Statement (..))
import Hasql.Transaction qualified as Transaction
import Hasql.Transaction.Sessions qualified as TransactionSession
import Hindsight.Projection (ProjectionId (..))
import Hindsight.Projection.Matching (ProjectionHandlers (..))
import Hindsight.Store
import Hindsight.Store.PostgreSQL (SQLStoreHandle, getConnectionString, getPool, newSQLStoreWithProjections)
import Hindsight.Store.PostgreSQL.Projections.Sync (emptySyncProjectionRegistry, registerSyncProjection)
import Test.Hindsight.Examples (UserCreated)
import Test.Hindsight.PostgreSQL.Temp (defaultConfig, withTempPostgreSQL)
import Test.Hindsight.Store.Common (collectEvents)
import Test.Tasty
import Test.Tasty.HUnit
import UnliftIO.Exception (fromException, tryAny)

-- | All parse error tests
tests :: TestTree
tests =
    testGroup
        "Parse Error Handling Tests"
        [ testCase "Subscription throws on malformed event payload" $
            withTempPostgreSQL defaultConfig testSubscriptionThrowsOnMalformedPayload
        , testCase "Subscription throws on unknown event version" $
            withTempPostgreSQL defaultConfig testSubscriptionThrowsOnUnknownVersion
        , testCase "Sync projection catch-up throws on malformed event" $
            withTempPostgreSQL defaultConfig testSyncProjectionCatchUpThrowsOnMalformedEvent
        ]

{- | Insert a malformed event directly into the database
This bypasses normal insertion to create a corrupt event
-}
insertMalformedEvent ::
    SQLStoreHandle ->
    StreamId ->
    -- | Event name
    BS.ByteString ->
    -- | Event version
    Int32 ->
    -- | Malformed JSON payload
    Aeson.Value ->
    IO ()
insertMalformedEvent store (StreamId streamUuid) eventName eventVersion payload = do
    result <-
        Pool.use (getPool store) $
            TransactionSession.transaction TransactionSession.Serializable TransactionSession.Write $ do
                -- Get a transaction xid8
                txXid8 <- Transaction.statement () getTxXid8Stmt
                -- Insert into event_transactions
                Transaction.statement txXid8 insertTxStmt
                -- Generate event ID
                eventUuid <- Transaction.statement () genUuidStmt
                -- Insert the malformed event
                Transaction.statement
                    (txXid8, 0 :: Int32, eventUuid, streamUuid, eventName, eventVersion, payload, 1 :: Int64)
                    insertEventStmt
                -- Insert stream head
                Transaction.statement
                    (streamUuid, txXid8, 0 :: Int32, eventUuid, 1 :: Int64)
                    insertStreamHeadStmt
    case result of
        Left err -> assertFailure $ "Failed to insert malformed event: " ++ show err
        Right () -> pure ()
  where
    getTxXid8Stmt :: Statement () Int64
    getTxXid8Stmt =
        Statement
            "SELECT pg_current_xact_id()::text::bigint"
            mempty
            (Decoders.singleRow $ Decoders.column $ Decoders.nonNullable Decoders.int8)
            True

    insertTxStmt :: Statement Int64 ()
    insertTxStmt =
        Statement
            "INSERT INTO event_transactions (transaction_xid8) VALUES ($1::text::xid8)"
            (Encoders.param $ Encoders.nonNullable Encoders.int8)
            Decoders.noResult
            True

    genUuidStmt :: Statement () UUID.UUID
    genUuidStmt =
        Statement
            "SELECT gen_random_uuid()"
            mempty
            (Decoders.singleRow $ Decoders.column $ Decoders.nonNullable Decoders.uuid)
            True

    insertEventStmt :: Statement (Int64, Int32, UUID.UUID, UUID.UUID, BS.ByteString, Int32, Aeson.Value, Int64) ()
    insertEventStmt =
        Statement
            "INSERT INTO events (transaction_xid8, seq_no, event_id, stream_id, event_name, event_version, payload, stream_version, created_at) \
            \VALUES ($1::text::xid8, $2, $3, $4, $5, $6, $7, $8, NOW())"
            encoder
            Decoders.noResult
            True
      where
        encoder =
            ((\(a, _, _, _, _, _, _, _) -> a) >$< Encoders.param (Encoders.nonNullable Encoders.int8))
                <> ((\(_, b, _, _, _, _, _, _) -> b) >$< Encoders.param (Encoders.nonNullable Encoders.int4))
                <> ((\(_, _, c, _, _, _, _, _) -> c) >$< Encoders.param (Encoders.nonNullable Encoders.uuid))
                <> ((\(_, _, _, d, _, _, _, _) -> d) >$< Encoders.param (Encoders.nonNullable Encoders.uuid))
                <> ((\(_, _, _, _, e, _, _, _) -> Text.Encoding.decodeUtf8 e) >$< Encoders.param (Encoders.nonNullable Encoders.text))
                <> ((\(_, _, _, _, _, f, _, _) -> f) >$< Encoders.param (Encoders.nonNullable Encoders.int4))
                <> ((\(_, _, _, _, _, _, g, _) -> g) >$< Encoders.param (Encoders.nonNullable Encoders.jsonb))
                <> ((\(_, _, _, _, _, _, _, h) -> h) >$< Encoders.param (Encoders.nonNullable Encoders.int8))

    insertStreamHeadStmt :: Statement (UUID.UUID, Int64, Int32, UUID.UUID, Int64) ()
    insertStreamHeadStmt =
        Statement
            "INSERT INTO stream_heads (stream_id, latest_transaction_xid8, latest_seq_no, last_event_id, stream_version) \
            \VALUES ($1, $2::text::xid8, $3, $4, $5) \
            \ON CONFLICT (stream_id) DO UPDATE SET \
            \latest_transaction_xid8 = excluded.latest_transaction_xid8, \
            \latest_seq_no = excluded.latest_seq_no, \
            \last_event_id = excluded.last_event_id, \
            \stream_version = excluded.stream_version"
            encoder
            Decoders.noResult
            True
      where
        encoder =
            ((\(a, _, _, _, _) -> a) >$< Encoders.param (Encoders.nonNullable Encoders.uuid))
                <> ((\(_, b, _, _, _) -> b) >$< Encoders.param (Encoders.nonNullable Encoders.int8))
                <> ((\(_, _, c, _, _) -> c) >$< Encoders.param (Encoders.nonNullable Encoders.int4))
                <> ((\(_, _, _, d, _) -> d) >$< Encoders.param (Encoders.nonNullable Encoders.uuid))
                <> ((\(_, _, _, _, e) -> e) >$< Encoders.param (Encoders.nonNullable Encoders.int8))

{- | Test that subscription throws exception on malformed event payload

When an event has a valid name and version but the JSON payload doesn't
match the expected schema, the subscription should throw a HandlerException
(or similar) rather than silently skipping the event.
-}
testSubscriptionThrowsOnMalformedPayload :: SQLStoreHandle -> IO ()
testSubscriptionThrowsOnMalformedPayload store = do
    streamId <- StreamId <$> UUID.nextRandom
    receivedEvents <- newIORef []

    -- Insert a malformed event: correct name/version, but wrong JSON structure
    -- UserCreated v2 expects {userId, userName, userEmail, likeability}
    -- We provide {garbage: true} instead
    insertMalformedEvent
        store
        streamId
        "user_created"
        2 -- Current version
        (Aeson.object ["garbage" Aeson..= True])

    -- Subscribe - should throw when encountering the malformed event
    handle <-
        subscribe
            store
            ( match UserCreated (collectEvents receivedEvents)
                :? MatchEnd
            )
            EventSelector{streamId = AllStreams, startupPosition = FromBeginning}

    -- Wait for subscription to complete or fail
    waitResult <- tryAny handle.wait

    -- Verify that an exception was thrown (not silently swallowed)
    case waitResult of
        Left exc -> case fromException exc of
            Just HandlerException{failedEventName = evtName} -> do
                -- Exception should reference the failed event
                evtName @?= "user_created"
            Nothing ->
                -- Any exception is acceptable for now - the important thing
                -- is that we DON'T silently skip
                pure ()
        Right () ->
            -- If subscription completed normally, that means it silently skipped
            -- the malformed event - this is the bug we're testing for!
            assertFailure
                "Subscription completed normally - malformed event was silently skipped! \
                \Expected an exception to be thrown."

{- | Test that subscription throws exception on unknown event version

When an event has a version that doesn't exist in the parser map (e.g.,
a future version the code doesn't know about), the subscription should
throw rather than silently skip.
-}
testSubscriptionThrowsOnUnknownVersion :: SQLStoreHandle -> IO ()
testSubscriptionThrowsOnUnknownVersion store = do
    streamId <- StreamId <$> UUID.nextRandom
    receivedEvents <- newIORef []

    -- Insert an event with a version that doesn't exist (version 99)
    -- The code only knows about versions 0, 1, 2 for UserCreated
    insertMalformedEvent
        store
        streamId
        "user_created"
        99 -- Unknown version
        (Aeson.object ["userId" Aeson..= (1 :: Int), "userName" Aeson..= ("test" :: String)])

    -- Subscribe - should throw when encountering the unknown version
    handle <-
        subscribe
            store
            ( match UserCreated (collectEvents receivedEvents)
                :? MatchEnd
            )
            EventSelector{streamId = AllStreams, startupPosition = FromBeginning}

    -- Wait for subscription to complete or fail
    waitResult <- tryAny handle.wait

    -- Verify that an exception was thrown
    case waitResult of
        Left _exc ->
            -- Good - an exception was thrown
            pure ()
        Right () ->
            assertFailure
                "Subscription completed normally - event with unknown version was silently skipped! \
                \Expected an exception to be thrown."

{- | Test that sync projection catch-up throws on malformed event

During sync projection catch-up (when starting a store with registered
projections that are behind), encountering a malformed event should
cause the catch-up to fail rather than skip the event.
-}
testSyncProjectionCatchUpThrowsOnMalformedEvent :: SQLStoreHandle -> IO ()
testSyncProjectionCatchUpThrowsOnMalformedEvent store = do
    streamId <- StreamId <$> UUID.nextRandom

    -- Create test table for tracking projections
    _ <- Pool.use (getPool store) $ do
        Session.sql "CREATE TABLE IF NOT EXISTS test_projections (event_id TEXT)"

    -- Insert a malformed event BEFORE starting the store with projections
    insertMalformedEvent
        store
        streamId
        "user_created"
        2 -- Current version
        (Aeson.object ["garbage" Aeson..= True]) -- Wrong structure

    -- Create a projection that would process UserCreated events
    let projectionHandlers =
            ( Proxy @UserCreated
            , \envelope -> do
                let EventId eid = envelope.eventId
                Transaction.sql $
                    "INSERT INTO test_projections (event_id) VALUES ('"
                        <> BS.pack (show eid)
                        <> "')"
            )
                :-> ProjectionEnd

    let registry = registerSyncProjection (ProjectionId $ pack "test") projectionHandlers emptySyncProjectionRegistry

    -- Try to create a new store with the registry - catch-up should fail
    -- because it will encounter the malformed event
    result <- tryAny $ newSQLStoreWithProjections (getConnectionString store) registry

    case result of
        Left _exc ->
            -- Good - catch-up failed as expected
            pure ()
        Right _newStore ->
            assertFailure
                "Store creation succeeded - sync projection catch-up silently skipped malformed event! \
                \Expected catch-up to fail."
