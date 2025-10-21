{-# LANGUAGE DataKinds #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}

module Test.Hindsight.Store.PostgreSQL.StreamHeadCorrectnessTest where

import Control.Monad (forM_)
import Data.Int (Int32, Int64)
import Data.Map.Strict qualified as Map
import Data.UUID (UUID)
import Data.UUID.V4 qualified as UUID
import Hasql.Decoders qualified as D
import Hasql.Encoders qualified as E
import Hasql.Pool qualified as Pool
import Hasql.Session qualified as Session
import Hasql.Statement (Statement (..))
import Hindsight.Store
import Hindsight.Store.PostgreSQL (SQLStoreHandle, getPool)
import Test.Hindsight.PostgreSQL.Temp (debugMode, withTempPostgreSQL)
import Test.Hindsight.Store.Common (makeUserEvent)
import Test.Tasty
import Test.Tasty.HUnit

-- | Row from stream_heads table
data StreamHead = StreamHead
    { streamId :: UUID
    , lastEventId :: UUID
    , latestTxNo :: Int64
    , latestSeqNo :: Int32
    , streamVersion :: Int64
    }
    deriving (Show, Eq)

-- | Row from events table
data EventRow = EventRow
    { eventStreamId :: UUID
    , eventId :: UUID
    , eventTxNo :: Int64
    , eventSeqNo :: Int32
    }
    deriving (Show, Eq)

-- | Statement to get stream heads for specific streams
getStreamHeadsStmt :: Statement [UUID] [StreamHead]
getStreamHeadsStmt =
    Statement
        "SELECT stream_id, last_event_id, latest_transaction_no, latest_seq_no, stream_version \
        \FROM stream_heads \
        \WHERE stream_id = ANY($1)"
        (E.param (E.nonNullable (E.foldableArray (E.nonNullable E.uuid))))
        (D.rowList streamHeadDecoder)
        True
  where
    streamHeadDecoder =
        StreamHead
            <$> D.column (D.nonNullable D.uuid) -- stream_id
            <*> D.column (D.nonNullable D.uuid) -- last_event_id
            <*> D.column (D.nonNullable D.int8) -- latest_transaction_no
            <*> D.column (D.nonNullable D.int4) -- latest_seq_no
            <*> D.column (D.nonNullable D.int8) -- stream_version

-- | Statement to get actual last events for each stream
getActualLastEventsStmt :: Statement [UUID] [EventRow]
getActualLastEventsStmt =
    Statement
        "SELECT DISTINCT ON (stream_id) stream_id, event_id, transaction_no, seq_no \
        \FROM events \
        \WHERE stream_id = ANY($1) \
        \ORDER BY stream_id, transaction_no DESC, seq_no DESC"
        (E.param (E.nonNullable (E.foldableArray (E.nonNullable E.uuid))))
        (D.rowList eventRowDecoder)
        True
  where
    eventRowDecoder =
        EventRow
            <$> D.column (D.nonNullable D.uuid) -- stream_id
            <*> D.column (D.nonNullable D.uuid) -- event_id
            <*> D.column (D.nonNullable D.int8) -- transaction_no
            <*> D.column (D.nonNullable D.int4) -- seq_no

{- | Test that stream heads correctly point to the last event in each stream
when multiple streams are inserted in a single transaction
-}
testMultiStreamHeadCorrectness :: SQLStoreHandle -> IO ()
testMultiStreamHeadCorrectness store = do
    -- Create three distinct streams
    streamA <- StreamId <$> UUID.nextRandom
    streamB <- StreamId <$> UUID.nextRandom
    streamC <- StreamId <$> UUID.nextRandom

    -- Insert multiple events for each stream in a SINGLE transaction
    -- Stream A: 2 events, Stream B: 3 events, Stream C: 1 event
    result <-
        insertEvents store Nothing $
            Transaction
                ( Map.fromList
                    [ (streamA, StreamWrite NoStream [makeUserEvent 1, makeUserEvent 2])
                    , (streamB, StreamWrite NoStream [makeUserEvent 10, makeUserEvent 20, makeUserEvent 30])
                    , (streamC, StreamWrite NoStream [makeUserEvent 100])
                    ]
                )

    case result of
        FailedInsertion err -> assertFailure $ "Failed to insert events: " ++ show err
        SuccessfulInsertion _ -> pure ()

    -- Now query the database directly to verify stream_heads correctness
    let pool = getPool store
    let streamIds = [streamA.toUUID, streamB.toUUID, streamC.toUUID]

    -- Get stream heads for all three streams
    streamHeadsResult <- Pool.use pool $ Session.statement streamIds getStreamHeadsStmt

    streamHeads <- case streamHeadsResult of
        Left err -> assertFailure $ "Failed to query stream heads: " ++ show err
        Right heads -> pure heads

    -- Get actual last events for each stream from events table
    actualLastEventsResult <- Pool.use pool $ Session.statement streamIds getActualLastEventsStmt

    actualLastEvents <- case actualLastEventsResult of
        Left err -> assertFailure $ "Failed to query actual events: " ++ show err
        Right events -> pure events

    -- Build a map of stream -> actual last event ID
    let actualLastEventMap = Map.fromList [(e.eventStreamId, e.eventId) | e <- actualLastEvents]

    -- Verify each stream head
    forM_ streamHeads $ \streamHead -> do
        case Map.lookup streamHead.streamId actualLastEventMap of
            Nothing -> assertFailure $ "No events found for stream " ++ show streamHead.streamId
            Just actualLastEventId ->
                assertEqual
                    ("Stream head for " ++ show streamHead.streamId ++ " should point to its actual last event")
                    actualLastEventId
                    streamHead.lastEventId

    -- Also verify we got all three streams
    assertEqual "Should have 3 stream heads" 3 (length streamHeads)
    assertEqual "Should have 3 actual last events" 3 (length actualLastEvents)

-- | Test suite
tests :: TestTree
tests =
    testGroup
        "Stream Head Correctness Tests"
        [ testCase
            "Multi-stream insertion has correct stream heads"
            $ withTempPostgreSQL debugMode testMultiStreamHeadCorrectness
        ]
