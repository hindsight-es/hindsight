{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

{- | Per-stream cursor tests

Tests per-stream cursor functionality for multi-stream transactions:
- Cursor extraction from multi-stream transactions
- Cursor independence across streams
- Stale cursor detection in multi-stream transactions
- Cursor completeness (all streams get cursors)
- Empty stream cursor handling (edge case)
-}
module Test.Hindsight.Store.CursorTests (cursorTests) where

import Control.Monad (forM_)
import Data.Map.Strict qualified as Map
import Data.UUID.V4 qualified as UUID
import Hindsight.Store
import Test.Hindsight.Examples (makeUserEvent)
import Test.Hindsight.Store.TestRunner (EventStoreTestRunner (..))
import Test.Tasty
import Test.Tasty.HUnit

-- | Per-stream cursor test suite for event store backends
cursorTests ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO, Show (Cursor backend), Ord (Cursor backend)) =>
    EventStoreTestRunner backend ->
    [TestTree]
cursorTests runner =
    [ testCase "Per-Stream Cursor Extraction" $ withStore runner testPerStreamCursorExtraction
    , testCase "Cursor Independence" $ withStore runner testCursorIndependence
    , testCase "Stale Cursor Per Stream" $ withStore runner testStaleCursorPerStream
    , testCase "Cursor Completeness" $ withStore runner testCursorCompleteness
    , testCase "Empty Stream Cursor Handling" $ withStore runner testEmptyStreamCursorHandling
    ]

-- * Test Implementations

{- | Test that per-stream cursors can be extracted from multi-stream transactions
and used for optimistic locking on specific streams.

This is the core use case from Tutorial 08: when inserting events to multiple
streams in a single transaction, we need to get back individual cursors for
each stream to use in subsequent optimistic locking operations.
-}
testPerStreamCursorExtraction :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BackendHandle backend -> IO ()
testPerStreamCursorExtraction store = do
    streamA <- StreamId <$> UUID.nextRandom
    streamB <- StreamId <$> UUID.nextRandom
    streamC <- StreamId <$> UUID.nextRandom

    -- Multi-stream transaction
    result1 <-
        insertEvents store Nothing $
            Transaction
                ( Map.fromList
                    [ (streamA, StreamWrite NoStream [makeUserEvent 1])
                    , (streamB, StreamWrite NoStream [makeUserEvent 10])
                    , (streamC, StreamWrite NoStream [makeUserEvent 100])
                    ]
                )

    case result1 of
        FailedInsertion err -> assertFailure $ "Initial multi-stream write failed: " ++ show err
        SuccessfulInsertion (InsertionSuccess{streamCursors}) -> do
            -- Extract cursor for stream A
            case Map.lookup streamA streamCursors of
                Nothing -> assertFailure "Stream A cursor missing from streamCursors"
                Just cursorA -> do
                    -- Use cursor A to append to stream A with optimistic locking
                    result2 <-
                        insertEvents store Nothing $
                            singleEvent streamA (ExactVersion cursorA) (makeUserEvent 2)

                    case result2 of
                        FailedInsertion err -> assertFailure $ "Append with stream A cursor failed: " ++ show err
                        SuccessfulInsertion _ -> do
                            -- Try to use the same cursor again - should fail (stale)
                            result3 <-
                                insertEvents store Nothing $
                                    singleEvent streamA (ExactVersion cursorA) (makeUserEvent 3)

                            case result3 of
                                FailedInsertion (ConsistencyError _) -> pure () -- Expected!
                                _ -> assertFailure "Should not be able to reuse stale cursor"

{- | Test that cursors for different streams are independent.

Updating stream A should not invalidate stream B's cursor. This is critical
for concurrent multi-stream operations where different processes may be
updating different streams.
-}
testCursorIndependence :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BackendHandle backend -> IO ()
testCursorIndependence store = do
    streamA <- StreamId <$> UUID.nextRandom
    streamB <- StreamId <$> UUID.nextRandom

    -- Tx1: Initialize both streams
    result1 <-
        insertEvents store Nothing $
            Transaction
                ( Map.fromList
                    [ (streamA, StreamWrite NoStream [makeUserEvent 1])
                    , (streamB, StreamWrite NoStream [makeUserEvent 10])
                    ]
                )

    case result1 of
        FailedInsertion err -> assertFailure $ "Initial write failed: " ++ show err
        SuccessfulInsertion (InsertionSuccess{streamCursors}) -> do
            case (Map.lookup streamA streamCursors, Map.lookup streamB streamCursors) of
                (Just cursorA, Just cursorB) -> do
                    -- Tx2: Update stream A (should NOT affect cursorB)
                    result2 <-
                        insertEvents store Nothing $
                            singleEvent streamA (ExactVersion cursorA) (makeUserEvent 2)

                    case result2 of
                        FailedInsertion err -> assertFailure $ "Stream A update failed: " ++ show err
                        SuccessfulInsertion _ -> do
                            -- Tx3: Use cursorB to append to stream B
                            -- This should succeed because stream B hasn't been modified
                            result3 <-
                                insertEvents store Nothing $
                                    singleEvent streamB (ExactVersion cursorB) (makeUserEvent 11)

                            case result3 of
                                FailedInsertion err ->
                                    assertFailure $ "Stream B cursor should still be valid after stream A update: " ++ show err
                                SuccessfulInsertion _ -> pure () -- Success! Independence verified
                _ -> assertFailure "Missing cursors from initial transaction"

{- | Test that using a stale cursor for one stream in a multi-stream transaction
causes the entire transaction to fail atomically.
-}
testStaleCursorPerStream :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BackendHandle backend -> IO ()
testStaleCursorPerStream store = do
    streamA <- StreamId <$> UUID.nextRandom
    streamB <- StreamId <$> UUID.nextRandom

    -- Initialize streams
    result1 <-
        insertEvents store Nothing $
            Transaction
                ( Map.fromList
                    [ (streamA, StreamWrite NoStream [makeUserEvent 1])
                    , (streamB, StreamWrite NoStream [makeUserEvent 10])
                    ]
                )

    case result1 of
        FailedInsertion err -> assertFailure $ "Initial write failed: " ++ show err
        SuccessfulInsertion (InsertionSuccess{streamCursors}) -> do
            case (Map.lookup streamA streamCursors, Map.lookup streamB streamCursors) of
                (Just cursorA, Just cursorB) -> do
                    -- Update stream A separately (makes cursorA stale)
                    result2 <-
                        insertEvents store Nothing $
                            singleEvent streamA (ExactVersion cursorA) (makeUserEvent 2)

                    case result2 of
                        FailedInsertion err -> assertFailure $ "Stream A update failed: " ++ show err
                        SuccessfulInsertion _ -> do
                            -- Try multi-stream transaction with stale cursorA
                            -- Even though cursorB is still valid, the transaction should fail
                            result3 <-
                                insertEvents store Nothing $
                                    Transaction
                                        ( Map.fromList
                                            [ (streamA, StreamWrite (ExactVersion cursorA) [makeUserEvent 3]) -- stale!
                                            , (streamB, StreamWrite (ExactVersion cursorB) [makeUserEvent 11]) -- valid
                                            ]
                                        )

                            case result3 of
                                FailedInsertion (ConsistencyError _) -> pure () -- Expected! Atomic failure
                                _ -> assertFailure "Transaction with stale cursor should fail atomically"
                _ -> assertFailure "Missing cursors from initial transaction"

{- | Test that all streams in a multi-stream transaction get cursors,
and that the cursors map is complete.
-}
testCursorCompleteness :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend), Ord (Cursor backend)) => BackendHandle backend -> IO ()
testCursorCompleteness store = do
    streamA <- StreamId <$> UUID.nextRandom
    streamB <- StreamId <$> UUID.nextRandom
    streamC <- StreamId <$> UUID.nextRandom

    -- Multi-stream transaction to 3 streams
    result <-
        insertEvents store Nothing $
            Transaction
                ( Map.fromList
                    [ (streamA, StreamWrite NoStream [makeUserEvent 1, makeUserEvent 2])
                    , (streamB, StreamWrite NoStream [makeUserEvent 10])
                    , (streamC, StreamWrite NoStream [makeUserEvent 100, makeUserEvent 101, makeUserEvent 102])
                    ]
                )

    case result of
        FailedInsertion err -> assertFailure $ "Multi-stream write failed: " ++ show err
        SuccessfulInsertion (InsertionSuccess{finalCursor, streamCursors}) -> do
            -- Verify all 3 streams have cursors
            Map.size streamCursors @?= 3

            -- Verify all stream IDs are present
            assertBool "Stream A missing from cursors" (Map.member streamA streamCursors)
            assertBool "Stream B missing from cursors" (Map.member streamB streamCursors)
            assertBool "Stream C missing from cursors" (Map.member streamC streamCursors)

            -- Verify ordering invariant: all stream cursors <= finalCursor
            forM_ (Map.toList streamCursors) $ \(sid, cursor) ->
                assertBool
                    ("Cursor for " ++ show sid ++ " violates ordering invariant")
                    (cursor <= finalCursor)

            -- Verify we can actually use each cursor
            case (Map.lookup streamA streamCursors, Map.lookup streamB streamCursors, Map.lookup streamC streamCursors) of
                (Just cursorA, Just cursorB, Just cursorC) -> do
                    -- Try using each cursor
                    resultA <- insertEvents store Nothing $ singleEvent streamA (ExactVersion cursorA) (makeUserEvent 3)
                    resultB <- insertEvents store Nothing $ singleEvent streamB (ExactVersion cursorB) (makeUserEvent 11)
                    resultC <- insertEvents store Nothing $ singleEvent streamC (ExactVersion cursorC) (makeUserEvent 103)

                    case (resultA, resultB, resultC) of
                        (SuccessfulInsertion _, SuccessfulInsertion _, SuccessfulInsertion _) -> pure ()
                        _ -> assertFailure $ "One or more stream cursors were not usable\n"
                            ++ "  cursorA: " ++ show cursorA ++ "\n"
                            ++ "  cursorB: " ++ show cursorB ++ "\n"
                            ++ "  cursorC: " ++ show cursorC ++ "\n"
                            ++ "  resultA success: " ++ showSuccess resultA ++ "\n"
                            ++ "  resultB success: " ++ showSuccess resultB ++ "\n"
                            ++ "  resultC success: " ++ showSuccess resultC
                  where
                    showSuccess :: InsertionResult backend -> String
                    showSuccess (SuccessfulInsertion _) = "True"
                    showSuccess (FailedInsertion _) = "False"
                _ -> assertFailure "Failed to extract all cursors from map"

{- | Test that streams with EMPTY event lists still get proper cursor handling
in multi-stream transactions. This is a critical edge case - implementations
might fail to track cursors for streams that have no events written.

The user specifically flagged this: "Check that we get the proper cursor event
for EMPTY stream writes - that's the kind of places where nasty stupid bugs may lie."
-}
testEmptyStreamCursorHandling :: forall backend. (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) => BackendHandle backend -> IO ()
testEmptyStreamCursorHandling store = do
    streamA <- StreamId <$> UUID.nextRandom
    streamB <- StreamId <$> UUID.nextRandom
    streamC <- StreamId <$> UUID.nextRandom

    -- Multi-stream transaction with one EMPTY stream (streamB has no events)
    result <-
        insertEvents store Nothing $
            Transaction
                ( Map.fromList
                    [ (streamA, StreamWrite NoStream [makeUserEvent 1])
                    , (streamB, StreamWrite NoStream []) -- EMPTY! This is the edge case
                    , (streamC, StreamWrite NoStream [makeUserEvent 100])
                    ]
                )

    case result of
        FailedInsertion err -> assertFailure $ "Multi-stream with empty stream failed: " ++ show err
        SuccessfulInsertion (InsertionSuccess{streamCursors}) -> do
            -- Critical question: Does streamB get a cursor even though it has no events?
            -- Behavior expectation: streamB should NOT appear in streamCursors because
            -- it didn't actually write any events. Only streams with events get cursors.

            -- Verify streams A and C have cursors (they have events)
            assertBool "Stream A should have cursor (has events)" (Map.member streamA streamCursors)
            assertBool "Stream C should have cursor (has events)" (Map.member streamC streamCursors)

            -- Verify streamB does NOT have cursor (no events written)
            -- An empty stream write is effectively a no-op
            case Map.lookup streamB streamCursors of
                Nothing -> do
                    -- Expected: streamB shouldn't get a cursor for empty write
                    -- Verify streamB stream doesn't exist (empty write is a no-op)
                    resultB <-
                        insertEvents store Nothing $
                            singleEvent streamB NoStream (makeUserEvent 10)

                    case resultB of
                        FailedInsertion err -> assertFailure $ "Stream B should not exist after empty write: " ++ show err
                        SuccessfulInsertion _ -> pure () -- Good! StreamB was never created
                Just cursorB -> do
                    -- Alternative behavior: backend gave cursor for empty stream
                    -- In this case, verify the cursor is still usable and stream was created
                    resultB <-
                        insertEvents store Nothing $
                            singleEvent streamB (ExactVersion cursorB) (makeUserEvent 10)

                    case resultB of
                        FailedInsertion err ->
                            assertFailure $ "If empty stream gets cursor, it should be usable: " ++ show err
                        SuccessfulInsertion _ -> pure () -- Alternative behavior is OK if consistent
