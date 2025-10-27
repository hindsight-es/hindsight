{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

{- | Stream version tests

Tests stream version functionality:
- Stream versions start at 1
- Stream versions are contiguous (no gaps)
- Stream versions are exposed in subscription envelopes
- Multiple streams have independent version sequences
-}
module Test.Hindsight.Store.StreamVersionTests (streamVersionTests) where

import Control.Concurrent (MVar, newEmptyMVar, putMVar, takeMVar)
import Data.IORef
import Data.Map.Strict qualified as Map
import Data.UUID.V4 qualified as UUID
import Hindsight.Store
import Test.Hindsight.Examples (UserCreated)
import Test.Hindsight.Store.Common (Tombstone, handleTombstone, makeTombstone, makeUserEvent)
import Test.Hindsight.Store.TestRunner.Types (EventStoreTestRunner (..))
import Test.Tasty
import Test.Tasty.HUnit

-- | Stream version test suite for event store backends
streamVersionTests ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO) =>
    EventStoreTestRunner backend ->
    [TestTree]
streamVersionTests runner =
    [ testCase "Stream Versions Start At 1" $ withStore runner testStreamVersionsStartAt1
    , testCase "Stream Versions Are Contiguous" $ withStore runner testStreamVersionsContiguous
    , testCase "Stream Versions Exposed In Subscription" $ withStore runner testStreamVersionExposedInSubscription
    , testCase "Multiple Streams Have Independent Versions" $ withStore runner testIndependentStreamVersions
    ]

-- * Test Implementations

-- | Test that stream versions start at 1
testStreamVersionsStartAt1 :: forall backend. (EventStore backend, StoreConstraints backend IO) => BackendHandle backend -> IO ()
testStreamVersionsStartAt1 store = do
    streamId <- StreamId <$> UUID.nextRandom
    receivedVersions <- newIORef []
    completionVar <- newEmptyMVar

    let collectVersions ref event = do
            atomicModifyIORef' ref (\versions -> (event.streamVersion : versions, ()))
            pure Continue

    -- Insert first event
    _ <- insertEvents store Nothing (Transaction (Map.fromList [(streamId, StreamWrite NoStream [makeUserEvent 1, makeTombstone])]))

    handle <-
        subscribe
            store
            ( match UserCreated (collectVersions receivedVersions)
                :? match Tombstone (handleTombstone completionVar)
                :? MatchEnd
            )
            EventSelector{streamId = SingleStream streamId, startupPosition = FromBeginning}

    takeMVar completionVar
    handle.cancel

    versions <- reverse <$> readIORef receivedVersions
    versions @?= [StreamVersion 1]

-- | Test that stream versions are contiguous (no gaps)
testStreamVersionsContiguous :: forall backend. (EventStore backend, StoreConstraints backend IO) => BackendHandle backend -> IO ()
testStreamVersionsContiguous store = do
    streamId <- StreamId <$> UUID.nextRandom
    receivedVersions <- newIORef []
    completionVar <- newEmptyMVar

    let collectVersions ref event = do
            atomicModifyIORef' ref (\versions -> (event.streamVersion : versions, ()))
            pure Continue

    -- Insert 5 events in multiple batches
    _ <- insertEvents store Nothing (Transaction (Map.fromList [(streamId, StreamWrite NoStream [makeUserEvent 1, makeUserEvent 2])]))
    _ <- insertEvents store Nothing (Transaction (Map.fromList [(streamId, StreamWrite StreamExists [makeUserEvent 3])]))
    _ <- insertEvents store Nothing (Transaction (Map.fromList [(streamId, StreamWrite StreamExists [makeUserEvent 4, makeUserEvent 5, makeTombstone])]))

    handle <-
        subscribe
            store
            ( match UserCreated (collectVersions receivedVersions)
                :? match Tombstone (handleTombstone completionVar)
                :? MatchEnd
            )
            EventSelector{streamId = SingleStream streamId, startupPosition = FromBeginning}

    takeMVar completionVar
    handle.cancel

    versions <- reverse <$> readIORef receivedVersions
    -- Should be contiguous: 1, 2, 3, 4, 5
    versions @?= [StreamVersion 1, StreamVersion 2, StreamVersion 3, StreamVersion 4, StreamVersion 5]

-- | Test that stream versions are exposed in subscriptions
testStreamVersionExposedInSubscription :: forall backend. (EventStore backend, StoreConstraints backend IO) => BackendHandle backend -> IO ()
testStreamVersionExposedInSubscription store = do
    streamId <- StreamId <$> UUID.nextRandom
    receivedVersionRef <- newIORef Nothing
    completionVar <- newEmptyMVar

    let captureVersion ref event = do
            atomicModifyIORef' ref (\_ -> (Just event.streamVersion, ()))
            pure Continue

    _ <- insertEvents store Nothing (Transaction (Map.fromList [(streamId, StreamWrite NoStream [makeUserEvent 1, makeTombstone])]))

    handle <-
        subscribe
            store
            ( match UserCreated (captureVersion receivedVersionRef)
                :? match Tombstone (handleTombstone completionVar)
                :? MatchEnd
            )
            EventSelector{streamId = SingleStream streamId, startupPosition = FromBeginning}

    takeMVar completionVar
    handle.cancel

    mbVersion <- readIORef receivedVersionRef
    mbVersion @?= Just (StreamVersion 1)

-- | Test that multiple streams have independent version sequences
testIndependentStreamVersions :: forall backend. (EventStore backend, StoreConstraints backend IO) => BackendHandle backend -> IO ()
testIndependentStreamVersions store = do
    streamA <- StreamId <$> UUID.nextRandom
    streamB <- StreamId <$> UUID.nextRandom
    streamC <- StreamId <$> UUID.nextRandom

    versionsA <- newIORef []
    versionsB <- newIORef []
    versionsC <- newIORef []
    completionVar <- newEmptyMVar

    let collectVersionsFor ref event = do
            atomicModifyIORef' ref (\versions -> (event.streamVersion : versions, ()))
            pure Continue

    -- Insert events to all three streams in mixed order, in the SAME transaction
    _ <-
        insertEvents store Nothing $
            Transaction
                ( Map.fromList
                    [ (streamA, StreamWrite NoStream [makeUserEvent 1, makeUserEvent 2]) -- A: versions 1, 2
                    , (streamB, StreamWrite NoStream [makeUserEvent 10]) -- B: version 1
                    , (streamC, StreamWrite NoStream [makeUserEvent 100, makeUserEvent 101, makeUserEvent 102]) -- C: versions 1, 2, 3
                    ]
                )

    -- Insert more events to verify independent counting
    _ <-
        insertEvents store Nothing $
            Transaction
                ( Map.fromList
                    [ (streamA, StreamWrite StreamExists [makeUserEvent 3]) -- A: version 3
                    , (streamB, StreamWrite StreamExists [makeUserEvent 11, makeUserEvent 12]) -- B: versions 2, 3
                    ]
                )

    -- Add tombstones
    _ <-
        insertEvents store Nothing $
            Transaction
                ( Map.fromList
                    [ (streamA, StreamWrite StreamExists [makeTombstone])
                    , (streamB, StreamWrite StreamExists [makeTombstone])
                    , (streamC, StreamWrite StreamExists [makeTombstone])
                    ]
                )

    -- Subscribe to all streams
    remainingTombstones <- newIORef (3 :: Int)
    let handleTombstones :: EventHandler Tombstone IO backend
        handleTombstones _ = do
            remaining <- atomicModifyIORef' remainingTombstones (\n -> (n - 1, n - 1))
            if remaining == 0
                then putMVar completionVar () >> pure Stop
                else pure Continue

    handle <-
        subscribe
            store
            ( match
                UserCreated
                ( \event -> do
                    case event.streamId of
                        sid
                            | sid == streamA -> collectVersionsFor versionsA event
                            | sid == streamB -> collectVersionsFor versionsB event
                            | sid == streamC -> collectVersionsFor versionsC event
                            | otherwise -> pure Continue
                )
                :? match Tombstone handleTombstones
                :? MatchEnd
            )
            EventSelector{streamId = AllStreams, startupPosition = FromBeginning}

    takeMVar completionVar
    handle.cancel

    -- Verify each stream has independent version sequences
    vA <- reverse <$> readIORef versionsA
    vB <- reverse <$> readIORef versionsB
    vC <- reverse <$> readIORef versionsC

    vA @?= [StreamVersion 1, StreamVersion 2, StreamVersion 3]
    vB @?= [StreamVersion 1, StreamVersion 2, StreamVersion 3]
    vC @?= [StreamVersion 1, StreamVersion 2, StreamVersion 3]
