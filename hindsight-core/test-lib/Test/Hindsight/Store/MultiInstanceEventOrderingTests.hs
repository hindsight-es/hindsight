{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

{- | Multi-instance event ordering tests

Tests cross-instance subscription ordering guarantees:
- Multi-instance subscriptions (cross-process notifications)
- Event ordering consistency across multiple instances (AllStreams mode)
- Event ordering consistency for single stream across multiple instances
- Hash-chain verification to detect ordering violations
-}
module Test.Hindsight.Store.MultiInstanceEventOrderingTests (multiInstanceEventOrderingTests) where

import Control.Concurrent (MVar, newEmptyMVar, putMVar, takeMVar, threadDelay)
import Control.Monad (forM, forM_, replicateM, when)
import Crypto.Hash (Digest, SHA256, hash)
import Data.Bits (shiftR)
import Data.ByteArray qualified as BA
import Data.ByteString (ByteString)
import Data.ByteString qualified as BS
import Data.ByteString.Lazy qualified as BSL
import Data.IORef (IORef, newIORef, readIORef, writeIORef)
import Data.Int (Int64)
import Data.Map.Strict qualified as Map
import Data.Maybe (mapMaybe)
import Data.Text (Text)
import Data.UUID (toByteString)
import Data.UUID.V4 qualified as UUID
import Data.Word (Word8)
import Hindsight.Store
import System.Random (randomRIO)
import System.Timeout (timeout)
import Test.Hindsight.Examples (Tombstone, UserCreated, UserInformation2 (..), makeTombstone, makeUserEvent)
import Test.Hindsight.Store.Common (collectEvents, extractPayload, handleTombstone)
import Test.Hindsight.Store.TestRunner (EventStoreTestRunner (..))
import Test.Tasty
import Test.Tasty.HUnit
import UnliftIO.Async (async, forConcurrently, forConcurrently_)

-- | Multi-instance ordering test suite for event store backends
multiInstanceEventOrderingTests ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO, Show (Cursor backend), Ord (Cursor backend)) =>
    EventStoreTestRunner backend ->
    [TestTree]
multiInstanceEventOrderingTests runner =
    [ testGroup
        "Multi-Instance Tests"
        [ testCase "Multi-Instance Subscriptions (2 instances)" $ withStores runner 2 testMultiInstanceSubscription
        , testCase "Multi-Instance Subscriptions (5 instances)" $ withStores runner 5 testMultiInstanceSubscription
        , testCase "Multi-Instance Subscriptions (10 instances)" $ withStores runner 10 testMultiInstanceSubscription
        ]
    , testGroup
        "Multi-Instance Event Ordering Tests (AllStreams)"
        [ testCase "Event Ordering AllStreams (2 instances, 5 events each)" $
            withStores runner 2 (testMultiInstanceEventOrdering_AllStreams 5 2)
        , testCase "Event Ordering AllStreams (3 instances, 10 events each)" $
            withStores runner 3 (testMultiInstanceEventOrdering_AllStreams 10 3)
        , testCase "Event Ordering AllStreams (5 instances, 20 events each)" $
            withStores runner 5 (testMultiInstanceEventOrdering_AllStreams 20 5)
        ]
    , testGroup
        "Multi-Instance Event Ordering Tests (SingleStream)"
        [ testCase "Event Ordering SingleStream (2 instances, 5 events each)" $
            withStores runner 2 (testMultiInstanceEventOrdering_SingleStream 5 2)
        , testCase "Event Ordering SingleStream (3 instances, 10 events each)" $
            withStores runner 3 (testMultiInstanceEventOrdering_SingleStream 10 3)
        , testCase "Event Ordering SingleStream (5 instances, 20 events each)" $
            withStores runner 5 (testMultiInstanceEventOrdering_SingleStream 20 5)
        ]
    ]

-- * Test Implementations

{- | Test that multiple "processes" (separate handles) can subscribe to events
written by another "process". This validates cross-process notification works.
-}
testMultiInstanceSubscription ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO, Show (Cursor backend)) =>
    [BackendHandle backend] ->
    IO ()
testMultiInstanceSubscription stores = do
    case stores of
        [] -> assertFailure "Expected at least 1 store handle"
        (writerStore : subscriberStores) -> do
            streamId <- StreamId <$> UUID.nextRandom

            -- Create completion vars for each subscriber
            completionVars <- replicateM (length subscriberStores) newEmptyMVar
            receivedEventsRefs <- replicateM (length subscriberStores) (newIORef [])

            -- Start subscriptions on all subscriber stores (simulating separate processes)
            subscriptionHandles <- forM (zip3 subscriberStores completionVars receivedEventsRefs) $
                \(store, completionVar, eventsRef) -> do
                    subscribe
                        store
                        ( match UserCreated (collectEvents eventsRef)
                            :? match Tombstone (handleTombstone completionVar)
                            :? MatchEnd
                        )
                        EventSelector{streamId = AllStreams, startupPosition = FromBeginning}

            -- Write events from the writer store (simulating different process)
            let testEvents = map makeUserEvent [1 .. 5] ++ [makeTombstone]
            result <-
                insertEvents
                    writerStore
                    Nothing
                    (Transaction (Map.fromList [(streamId, StreamWrite Any testEvents)]))

            case result of
                FailedInsertion err -> do
                    -- Cancel all subscriptions on failure
                    mapM_ (.cancel) subscriptionHandles
                    assertFailure $ "Failed to insert events: " ++ show err
                SuccessfulInsertion _ -> do
                    -- Wait for all subscribers to complete
                    forM_ completionVars takeMVar

                    -- Cancel all subscriptions
                    mapM_ (.cancel) subscriptionHandles

                    -- Verify all subscribers received the same events
                    allReceivedEvents <- mapM (fmap reverse . readIORef) receivedEventsRefs
                    forM_ allReceivedEvents $ \events -> do
                        length events @?= 5
                        let userInfos = map extractPayload events
                        length userInfos @?= 5
                        let userNames :: [Text]
                            userNames = map (.userName) userInfos
                        userNames @?= ["user1", "user2", "user3", "user4", "user5"]

                    -- All subscribers should have received identical events
                    case allReceivedEvents of
                        [] -> pure ()
                        (firstEvents : restEvents) ->
                            forM_ restEvents $ \events ->
                                length events @?= length firstEvents

{- | Test that multiple instances observe events in the same total order (AllStreams mode).

This test validates a critical property for event sourcing: all subscribers,
regardless of when they start or which instance they're on, MUST see events
in the same global order.

Test design:
  - N instances (separate store handles to same backend)
  - Each instance writes M events total to its own stream (all CONCURRENT with jitter)
  - 6N total subscriptions testing all combinations of timing and startup mode:

    **FromBeginning (3N subscriptions):**
    1. FB-initial: Started BEFORE any writes
    2. FB-during: Started DURING writes (mid-stream)
    3. FB-after: Started AFTER all writes complete

    **FromPosition (3N subscriptions):**
    4. FLP-initial: Started right AFTER checkpoint acquisition
    5. FLP-during: Started DURING writes (mid-stream)
    6. FLP-after: Started AFTER all writes complete

  - Checkpoint: Captured after first M/2 concurrent writes (maximum cursor)
  - Each subscription computes a blockchain-style hash chain:
      hash_n = SHA256(hash_{n-1} || eventId || streamId || streamVersion)

  - Verification:
    * All FromBeginning groups (initial, during, after) → same hash H1
    * All FromPosition groups (initial, during, after) → same hash H2
    * H1 ≠ H2 (sanity check: they saw different event sets)

Why this is comprehensive:
  - Tests BOTH startup modes (FromBeginning and FromPosition)
  - Tests subscriptions started at ALL phases (before/during/after writes)
  - All writes fully concurrent with jitter (realistic stress test)
  - Hash chaining makes ordering violations detectable
  - Validates cursor-based resumption works correctly under load
-}
testMultiInstanceEventOrdering_AllStreams ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO, Show (Cursor backend), Ord (Cursor backend)) =>
    -- | Number of events each instance writes
    Int ->
    -- | Number of instances
    Int ->
    [BackendHandle backend] ->
    IO ()
testMultiInstanceEventOrdering_AllStreams numEventsPerInstance numInstances stores = do
    -- Validate inputs
    when (length stores /= numInstances) $
        assertFailure $
            "Expected " <> show numInstances <> " store handles, got " <> show (length stores)

    -- Split events into two phases (M/2 each)
    let halfEvents = numEventsPerInstance `div` 2

    -- Each instance gets a unique stream
    streamIds <- replicateM numInstances (StreamId <$> UUID.nextRandom)

    -- Shared tombstone stream (signals end of test)
    tombstoneStream <- StreamId <$> UUID.nextRandom

    -- 6 subscription groups: 6N total subscriptions
    hashRefs <- replicateM (6 * numInstances) (newIORef (initialHash :: Digest SHA256))
    completionVars <- replicateM (6 * numInstances) newEmptyMVar

    -- Phase 1: Write M/2 events CONCURRENTLY with jitter, capturing cursors
    allCursors <- forConcurrently (zip stores streamIds) $ \(store, streamId) -> do
        jitter <- randomRIO (0, 50_000)
        threadDelay jitter
        forM [1 .. halfEvents] $ \eventNum -> do
            eventJitter <- randomRIO (0, 25_000)
            threadDelay eventJitter
            let event = makeUserEvent eventNum
            result <- insertEvents store Nothing (singleEvent streamId Any event)
            case result of
                FailedInsertion err -> assertFailure $ "Phase 1 write failed: " ++ show err
                SuccessfulInsertion success -> pure success.finalCursor

    -- Capture checkpoint cursor (maximum across all Phase 1 writes)
    let checkpointCursor = case concat allCursors of
            [] -> error "No cursors captured from Phase 1"
            cs -> maximum cs

    -- Phase 2: Start FB-initial and FLP-initial subscriptions
    let fbInitialRefs = take numInstances hashRefs
        fbInitialVars = take numInstances completionVars
        flpInitialRefs = take numInstances (drop numInstances hashRefs)
        flpInitialVars = take numInstances (drop numInstances completionVars)

    fbInitialHandles <- forConcurrently (zip3 stores fbInitialRefs fbInitialVars) $
        \(store, hashRef, doneVar) -> do
            jitter <- randomRIO (0, 200_000)
            threadDelay jitter
            subscribe
                store
                ( match UserCreated (hashEventHandler hashRef)
                    :? match Tombstone (handleTombstone doneVar)
                    :? MatchEnd
                )
                EventSelector{streamId = AllStreams, startupPosition = FromBeginning}

    flpInitialHandles <- forConcurrently (zip3 stores flpInitialRefs flpInitialVars) $
        \(store, hashRef, doneVar) -> do
            jitter <- randomRIO (0, 200_000)
            threadDelay jitter
            subscribe
                store
                ( match UserCreated (hashEventHandler hashRef)
                    :? match Tombstone (handleTombstone doneVar)
                    :? MatchEnd
                )
                EventSelector{streamId = AllStreams, startupPosition = FromPosition checkpointCursor}

    -- Phase 3: Write remaining M/2 events CONCURRENTLY, spawn "during" subs mid-write
    let fbDuringRefs = take numInstances (drop (2 * numInstances) hashRefs)
        fbDuringVars = take numInstances (drop (2 * numInstances) completionVars)
        flpDuringRefs = take numInstances (drop (3 * numInstances) hashRefs)
        flpDuringVars = take numInstances (drop (3 * numInstances) completionVars)

    duringHandlesVar <- newEmptyMVar

    _ <- async $ do
        threadDelay 1_000_000

        fbDuringHandles <- forConcurrently (zip3 stores fbDuringRefs fbDuringVars) $
            \(store, hashRef, doneVar) -> do
                jitter <- randomRIO (0, 200_000)
                threadDelay jitter
                subscribe
                    store
                    ( match UserCreated (hashEventHandler hashRef)
                        :? match Tombstone (handleTombstone doneVar)
                        :? MatchEnd
                    )
                    EventSelector{streamId = AllStreams, startupPosition = FromBeginning}

        flpDuringHandles <- forConcurrently (zip3 stores flpDuringRefs flpDuringVars) $
            \(store, hashRef, doneVar) -> do
                jitter <- randomRIO (0, 200_000)
                threadDelay jitter
                subscribe
                    store
                    ( match UserCreated (hashEventHandler hashRef)
                        :? match Tombstone (handleTombstone doneVar)
                        :? MatchEnd
                    )
                    EventSelector{streamId = AllStreams, startupPosition = FromPosition checkpointCursor}

        putMVar duringHandlesVar (fbDuringHandles <> flpDuringHandles)

    -- Write remaining events concurrently
    forConcurrently_ (zip stores streamIds) $ \(store, streamId) -> do
        jitter <- randomRIO (0, 50_000)
        threadDelay jitter
        forM_ [(halfEvents + 1) .. numEventsPerInstance] $ \eventNum -> do
            eventJitter <- randomRIO (0, 25_000)
            threadDelay eventJitter
            let event = makeUserEvent eventNum
            result <- insertEvents store Nothing (singleEvent streamId Any event)
            case result of
                FailedInsertion err -> assertFailure $ "Phase 3 write failed: " ++ show err
                SuccessfulInsertion _ -> pure ()

    duringHandles <- takeMVar duringHandlesVar

    -- Phase 4: Start "after" subscriptions
    let fbAfterRefs = take numInstances (drop (4 * numInstances) hashRefs)
        fbAfterVars = take numInstances (drop (4 * numInstances) completionVars)
        flpAfterRefs = drop (5 * numInstances) hashRefs
        flpAfterVars = drop (5 * numInstances) completionVars

    fbAfterHandles <- forConcurrently (zip3 stores fbAfterRefs fbAfterVars) $
        \(store, hashRef, doneVar) -> do
            jitter <- randomRIO (0, 200_000)
            threadDelay jitter
            subscribe
                store
                ( match UserCreated (hashEventHandler hashRef)
                    :? match Tombstone (handleTombstone doneVar)
                    :? MatchEnd
                )
                EventSelector{streamId = AllStreams, startupPosition = FromBeginning}

    flpAfterHandles <- forConcurrently (zip3 stores flpAfterRefs flpAfterVars) $
        \(store, hashRef, doneVar) -> do
            jitter <- randomRIO (0, 200_000)
            threadDelay jitter
            subscribe
                store
                ( match UserCreated (hashEventHandler hashRef)
                    :? match Tombstone (handleTombstone doneVar)
                    :? MatchEnd
                )
                EventSelector{streamId = AllStreams, startupPosition = FromPosition checkpointCursor}

    -- Phase 5: Write tombstone to signal end of test
    result <- insertEvents (head stores) Nothing (singleEvent tombstoneStream Any makeTombstone)

    let allHandles = fbInitialHandles <> flpInitialHandles <> duringHandles <> fbAfterHandles <> flpAfterHandles

    case result of
        FailedInsertion err -> do
            mapM_ (.cancel) allHandles
            assertFailure $ "Failed to insert tombstone: " ++ show err
        SuccessfulInsertion _ -> do
            timeoutResult <- timeout 30_000_000 $ forM_ completionVars takeMVar
            mapM_ (.cancel) allHandles

            case timeoutResult of
                Nothing -> assertFailure "Test timed out waiting for subscriptions"
                Just _ -> do
                    fbInitialHashes <- mapM readIORef (take numInstances hashRefs)
                    flpInitialHashes <- mapM readIORef (take numInstances (drop numInstances hashRefs))
                    fbDuringHashes <- mapM readIORef (take numInstances (drop (2 * numInstances) hashRefs))
                    flpDuringHashes <- mapM readIORef (take numInstances (drop (3 * numInstances) hashRefs))
                    fbAfterHashes <- mapM readIORef (take numInstances (drop (4 * numInstances) hashRefs))
                    flpAfterHashes <- mapM readIORef (drop (5 * numInstances) hashRefs)

                    verifyGroupConsistency "FB-initial" fbInitialHashes
                    verifyGroupConsistency "FLP-initial" flpInitialHashes
                    verifyGroupConsistency "FB-during" fbDuringHashes
                    verifyGroupConsistency "FLP-during" flpDuringHashes
                    verifyGroupConsistency "FB-after" fbAfterHashes
                    verifyGroupConsistency "FLP-after" flpAfterHashes

                    case (fbInitialHashes, fbDuringHashes, fbAfterHashes) of
                        (h1 : _, h2 : _, h3 : _) -> do
                            when (h1 /= h2) $
                                assertFailure $
                                    "FB-initial and FB-during have different hashes:\n"
                                        <> "  FB-initial: "
                                        <> show h1
                                        <> "\n  FB-during:  "
                                        <> show h2
                            when (h1 /= h3) $
                                assertFailure $
                                    "FB-initial and FB-after have different hashes:\n"
                                        <> "  FB-initial: "
                                        <> show h1
                                        <> "\n  FB-after:   "
                                        <> show h3
                        _ -> pure ()

                    case (flpInitialHashes, flpDuringHashes, flpAfterHashes) of
                        (h1 : _, h2 : _, h3 : _) -> do
                            when (h1 /= h2) $
                                assertFailure $
                                    "FLP-initial and FLP-during have different hashes:\n"
                                        <> "  FLP-initial: "
                                        <> show h1
                                        <> "\n  FLP-during:  "
                                        <> show h2
                            when (h1 /= h3) $
                                assertFailure $
                                    "FLP-initial and FLP-after have different hashes:\n"
                                        <> "  FLP-initial: "
                                        <> show h1
                                        <> "\n  FLP-after:   "
                                        <> show h3
                        _ -> pure ()

                    case (fbInitialHashes, flpInitialHashes) of
                        (h1 : _, h2 : _) ->
                            when (h1 == h2) $
                                assertFailure
                                    "SANITY CHECK FAILED: FB and FLP groups have the same hash!\n\
                                    \This indicates FromPosition is not working correctly."
                        _ -> pure ()

{- | Test that multiple instances observe events in the same total order (SingleStream mode).

This test validates that single-stream subscriptions maintain ordering consistency
across multiple instances writing to the same stream concurrently.

Key differences from AllStreams test:
  - Write target: all instances → 1 shared stream (not N separate streams)
  - Subscription selector: SingleStream(sharedStream) (not AllStreams)
  - Tests concurrent writes to the same stream from multiple instances
-}
testMultiInstanceEventOrdering_SingleStream ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO, Show (Cursor backend), Ord (Cursor backend)) =>
    Int ->
    Int ->
    [BackendHandle backend] ->
    IO ()
testMultiInstanceEventOrdering_SingleStream numEventsPerInstance numInstances stores = do
    when (length stores /= numInstances) $
        assertFailure $
            "Expected " <> show numInstances <> " store handles, got " <> show (length stores)

    let halfEvents = numEventsPerInstance `div` 2

    sharedStream <- StreamId <$> UUID.nextRandom

    hashRefs <- replicateM (6 * numInstances) (newIORef (initialHash :: Digest SHA256))
    completionVars <- replicateM (6 * numInstances) newEmptyMVar

    allCursors <- forConcurrently stores $ \store -> do
        jitter <- randomRIO (0, 50_000)
        threadDelay jitter
        forM [1 .. halfEvents] $ \eventNum -> do
            eventJitter <- randomRIO (0, 25_000)
            threadDelay eventJitter
            let event = makeUserEvent eventNum
            result <- insertEvents store Nothing (singleEvent sharedStream Any event)
            case result of
                FailedInsertion err -> assertFailure $ "Phase 1 write failed: " ++ show err
                SuccessfulInsertion success -> pure success.finalCursor

    let checkpointCursor = case concat allCursors of
            [] -> error "No cursors captured from Phase 1"
            cs -> maximum cs

    let fbInitialRefs = take numInstances hashRefs
        fbInitialVars = take numInstances completionVars
        flpInitialRefs = take numInstances (drop numInstances hashRefs)
        flpInitialVars = take numInstances (drop numInstances completionVars)

    fbInitialHandles <- forConcurrently (zip3 stores fbInitialRefs fbInitialVars) $
        \(store, hashRef, doneVar) -> do
            jitter <- randomRIO (0, 200_000)
            threadDelay jitter
            subscribe
                store
                ( match UserCreated (hashEventHandler hashRef)
                    :? match Tombstone (handleTombstone doneVar)
                    :? MatchEnd
                )
                EventSelector{streamId = SingleStream sharedStream, startupPosition = FromBeginning}

    flpInitialHandles <- forConcurrently (zip3 stores flpInitialRefs flpInitialVars) $
        \(store, hashRef, doneVar) -> do
            jitter <- randomRIO (0, 200_000)
            threadDelay jitter
            subscribe
                store
                ( match UserCreated (hashEventHandler hashRef)
                    :? match Tombstone (handleTombstone doneVar)
                    :? MatchEnd
                )
                EventSelector{streamId = SingleStream sharedStream, startupPosition = FromPosition checkpointCursor}

    let fbDuringRefs = take numInstances (drop (2 * numInstances) hashRefs)
        fbDuringVars = take numInstances (drop (2 * numInstances) completionVars)
        flpDuringRefs = take numInstances (drop (3 * numInstances) hashRefs)
        flpDuringVars = take numInstances (drop (3 * numInstances) completionVars)

    duringHandlesVar <- newEmptyMVar

    _ <- async $ do
        threadDelay 1_000_000

        fbDuringHandles <- forConcurrently (zip3 stores fbDuringRefs fbDuringVars) $
            \(store, hashRef, doneVar) -> do
                jitter <- randomRIO (0, 200_000)
                threadDelay jitter
                subscribe
                    store
                    ( match UserCreated (hashEventHandler hashRef)
                        :? match Tombstone (handleTombstone doneVar)
                        :? MatchEnd
                    )
                    EventSelector{streamId = SingleStream sharedStream, startupPosition = FromBeginning}

        flpDuringHandles <- forConcurrently (zip3 stores flpDuringRefs flpDuringVars) $
            \(store, hashRef, doneVar) -> do
                jitter <- randomRIO (0, 200_000)
                threadDelay jitter
                subscribe
                    store
                    ( match UserCreated (hashEventHandler hashRef)
                        :? match Tombstone (handleTombstone doneVar)
                        :? MatchEnd
                    )
                    EventSelector{streamId = SingleStream sharedStream, startupPosition = FromPosition checkpointCursor}

        putMVar duringHandlesVar (fbDuringHandles <> flpDuringHandles)

    forConcurrently_ stores $ \store -> do
        jitter <- randomRIO (0, 50_000)
        threadDelay jitter
        forM_ [(halfEvents + 1) .. numEventsPerInstance] $ \eventNum -> do
            eventJitter <- randomRIO (0, 25_000)
            threadDelay eventJitter
            let event = makeUserEvent eventNum
            result <- insertEvents store Nothing (singleEvent sharedStream Any event)
            case result of
                FailedInsertion err -> assertFailure $ "Phase 3 write failed: " ++ show err
                SuccessfulInsertion _ -> pure ()

    duringHandles <- takeMVar duringHandlesVar

    let fbAfterRefs = take numInstances (drop (4 * numInstances) hashRefs)
        fbAfterVars = take numInstances (drop (4 * numInstances) completionVars)
        flpAfterRefs = drop (5 * numInstances) hashRefs
        flpAfterVars = drop (5 * numInstances) completionVars

    fbAfterHandles <- forConcurrently (zip3 stores fbAfterRefs fbAfterVars) $
        \(store, hashRef, doneVar) -> do
            jitter <- randomRIO (0, 200_000)
            threadDelay jitter
            subscribe
                store
                ( match UserCreated (hashEventHandler hashRef)
                    :? match Tombstone (handleTombstone doneVar)
                    :? MatchEnd
                )
                EventSelector{streamId = SingleStream sharedStream, startupPosition = FromBeginning}

    flpAfterHandles <- forConcurrently (zip3 stores flpAfterRefs flpAfterVars) $
        \(store, hashRef, doneVar) -> do
            jitter <- randomRIO (0, 200_000)
            threadDelay jitter
            subscribe
                store
                ( match UserCreated (hashEventHandler hashRef)
                    :? match Tombstone (handleTombstone doneVar)
                    :? MatchEnd
                )
                EventSelector{streamId = SingleStream sharedStream, startupPosition = FromPosition checkpointCursor}

    result <- insertEvents (head stores) Nothing (singleEvent sharedStream Any makeTombstone)

    let allHandles = fbInitialHandles <> flpInitialHandles <> duringHandles <> fbAfterHandles <> flpAfterHandles

    case result of
        FailedInsertion err -> do
            mapM_ (.cancel) allHandles
            assertFailure $ "Failed to insert tombstone: " ++ show err
        SuccessfulInsertion _ -> do
            timeoutResult <- timeout 30_000_000 $ forM_ completionVars takeMVar
            mapM_ (.cancel) allHandles

            case timeoutResult of
                Nothing -> assertFailure "Test timed out waiting for subscriptions"
                Just _ -> do
                    fbInitialHashes <- mapM readIORef (take numInstances hashRefs)
                    flpInitialHashes <- mapM readIORef (take numInstances (drop numInstances hashRefs))
                    fbDuringHashes <- mapM readIORef (take numInstances (drop (2 * numInstances) hashRefs))
                    flpDuringHashes <- mapM readIORef (take numInstances (drop (3 * numInstances) hashRefs))
                    fbAfterHashes <- mapM readIORef (take numInstances (drop (4 * numInstances) hashRefs))
                    flpAfterHashes <- mapM readIORef (drop (5 * numInstances) hashRefs)

                    verifyGroupConsistency "FB-initial" fbInitialHashes
                    verifyGroupConsistency "FLP-initial" flpInitialHashes
                    verifyGroupConsistency "FB-during" fbDuringHashes
                    verifyGroupConsistency "FLP-during" flpDuringHashes
                    verifyGroupConsistency "FB-after" fbAfterHashes
                    verifyGroupConsistency "FLP-after" flpAfterHashes

                    case (fbInitialHashes, fbDuringHashes, fbAfterHashes) of
                        (h1 : _, h2 : _, h3 : _) -> do
                            when (h1 /= h2) $
                                assertFailure $
                                    "FB-initial and FB-during have different hashes:\n"
                                        <> "  FB-initial: "
                                        <> show h1
                                        <> "\n  FB-during:  "
                                        <> show h2
                            when (h1 /= h3) $
                                assertFailure $
                                    "FB-initial and FB-after have different hashes:\n"
                                        <> "  FB-initial: "
                                        <> show h1
                                        <> "\n  FB-after:   "
                                        <> show h3
                        _ -> pure ()

                    case (flpInitialHashes, flpDuringHashes, flpAfterHashes) of
                        (h1 : _, h2 : _, h3 : _) -> do
                            when (h1 /= h2) $
                                assertFailure $
                                    "FLP-initial and FLP-during have different hashes:\n"
                                        <> "  FLP-initial: "
                                        <> show h1
                                        <> "\n  FLP-during:  "
                                        <> show h2
                            when (h1 /= h3) $
                                assertFailure $
                                    "FLP-initial and FLP-after have different hashes:\n"
                                        <> "  FLP-initial: "
                                        <> show h1
                                        <> "\n  FLP-after:   "
                                        <> show h3
                        _ -> pure ()

                    case (fbInitialHashes, flpInitialHashes) of
                        (h1 : _, h2 : _) ->
                            when (h1 == h2) $
                                assertFailure
                                    "SANITY CHECK FAILED: FB and FLP groups have the same hash!\n\
                                    \This indicates FromPosition is not working correctly."
                        _ -> pure ()

-- * Hash Chain Helpers

initialHash :: Digest SHA256
initialHash = hash (BS.empty :: ByteString)

hashEventHandler :: forall backend. IORef (Digest SHA256) -> EventHandler UserCreated IO backend
hashEventHandler hashRef envelope = do
    let eventIdBytes = BSL.toStrict $ toByteString (envelope.eventId.toUUID)
        streamIdBytes = BSL.toStrict $ toByteString (envelope.streamId.toUUID)
        streamVersionBytes = encodeStreamVersion envelope.streamVersion

    prevHash <- readIORef hashRef
    let prevHashBytes = hashToBytes prevHash
        combined = BS.concat [prevHashBytes, eventIdBytes, streamIdBytes, streamVersionBytes]
        newHash = hash combined

    writeIORef hashRef newHash
    pure Continue

hashToBytes :: Digest SHA256 -> ByteString
hashToBytes = BA.convert

encodeStreamVersion :: StreamVersion -> ByteString
encodeStreamVersion (StreamVersion n) = BS.pack $ encodeInt64 n

encodeInt64 :: Int64 -> [Word8]
encodeInt64 n =
    [ fromIntegral (n `shiftR` 56)
    , fromIntegral (n `shiftR` 48)
    , fromIntegral (n `shiftR` 40)
    , fromIntegral (n `shiftR` 32)
    , fromIntegral (n `shiftR` 24)
    , fromIntegral (n `shiftR` 16)
    , fromIntegral (n `shiftR` 8)
    , fromIntegral n
    ]

verifyGroupConsistency :: String -> [Digest SHA256] -> IO ()
verifyGroupConsistency groupName hashes =
    case hashes of
        [] -> assertFailure $ groupName <> ": No subscriptions completed"
        (expectedHash : rest) ->
            forM_ (zip [1 :: Int ..] rest) $ \(idx, actualHash) ->
                when (actualHash /= expectedHash) $
                    assertFailure $
                        groupName
                            <> " subscription "
                            <> show idx
                            <> " saw different event order.\n"
                            <> "Expected hash: "
                            <> show expectedHash
                            <> "\nActual hash:   "
                            <> show actualHash
