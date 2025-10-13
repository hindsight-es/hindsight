{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}

module Hindsight.Store.Internal.Common
  ( -- * Core Types
    StoreState (..),
    StoredEvent (..),

    -- * Cursor that can be rebuilt from sequence numbers
    StoreCursor (..),

    -- * Version Control
    checkVersionConstraint,
    getCurrentVersion,
    getCurrentStreamVersion,

    -- * Event Processing
    processEvents,
    processEventThroughMatchers,

    -- * State Management
    updateState,

    -- * Common Operations
    makeStoredEvents,
    checkAllVersions,
    insertAllEvents,
    subscribeToEvents,
  )
where

import Control.Concurrent (forkIO)
import Control.Concurrent.STM
  ( TVar,
    atomically,
    newTVar,
    readTVar,
    retry,
    writeTVar,
  )
import Control.Monad (void, when)
import Control.Monad.IO.Class (MonadIO (..))
import UnliftIO (MonadUnliftIO, withRunInIO)
import Data.Aeson (FromJSON (..), ToJSON (..), Value (..))
import Data.Foldable (toList)
import Data.List (sortOn, zip4)
import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Proxy (Proxy)
import Data.Text (Text)
import Data.Time (UTCTime)
import GHC.Generics (Generic)
import Hindsight.Core
import Hindsight.Store
import Hindsight.Store.Parsing (parseStoredEventToEnvelope)

-- | Raw stored event with minimal type information
data StoredEvent = StoredEvent
  { seqNo :: Integer,
    eventId :: EventId,
    streamId :: StreamId,
    correlationId :: Maybe CorrelationId,
    createdAt :: UTCTime,
    eventName :: Text,
    eventVersion :: Integer,
    payload :: Value,
    streamVersion :: StreamVersion -- Local stream version
  }
  deriving (Show, Eq, Generic, FromJSON, ToJSON)

-- | Internal state maintained by the store
data StoreState backend = StoreState
  { nextSequence :: Integer,
    events :: Map Integer StoredEvent,
    streamEvents :: Map StreamId [Integer],
    streamVersions :: Map StreamId (Cursor backend),
    streamLocalVersions :: Map StreamId StreamVersion, -- Local stream versions
    streamNotifications :: Map StreamId (TVar Integer),
    globalNotification :: TVar Integer
  }

deriving instance (Eq (Cursor backend)) => Eq (StoreState backend)

-- | Capability for creating cursors from sequence numbers
class StoreCursor backend where
  -- | Create a cursor from a sequence number
  makeCursor :: Integer -> Cursor backend

  -- | Get the current sequence number
  makeSequenceNo :: Cursor backend -> Integer

-- | Check version constraints for a stream
checkVersionConstraint ::
  (Eq (Cursor backend)) =>
  StoreState backend ->
  StreamId ->
  ExpectedVersion backend ->
  Either (VersionMismatch backend) ()
checkVersionConstraint state streamId verExpectation = case verExpectation of
  Any -> Right ()
  NoStream
    | Map.member streamId state.streamVersions ->
        Left $ VersionMismatch streamId verExpectation (getCurrentVersion state streamId)
    | otherwise -> Right ()
  StreamExists
    | Map.member streamId state.streamVersions -> Right ()
    | otherwise ->
        Left $ VersionMismatch streamId verExpectation Nothing
  ExactVersion expected ->
    let actual = getCurrentVersion state streamId
     in if Just expected == actual
          then Right ()
          else Left $ VersionMismatch streamId verExpectation actual
  ExactStreamVersion expectedStreamVersion ->
    let actualStreamVersion = getCurrentStreamVersion state streamId
        actualCursor = getCurrentVersion state streamId
     in if Just expectedStreamVersion == actualStreamVersion
          then Right ()
          else Left $ VersionMismatch streamId verExpectation actualCursor

-- | Get current version of a stream (global cursor)
getCurrentVersion :: StoreState backend -> StreamId -> Maybe (Cursor backend)
getCurrentVersion state streamId =
  Map.lookup streamId state.streamVersions

-- | Get current stream version of a stream (local cursor)
getCurrentStreamVersion :: StoreState backend -> StreamId -> Maybe StreamVersion
getCurrentStreamVersion state streamId =
  Map.lookup streamId state.streamLocalVersions

-- | Process events through matcher chain
processEvents ::
  forall ts m backend.
  (MonadIO m, StoreCursor backend) =>
  EventMatcher ts backend m ->
  [StoredEvent] ->
  m SubscriptionResult
processEvents MatchEnd _ = pure Continue
processEvents (matcher :? rest) events = do
  let processAllEvents [] = pure Continue
      processAllEvents (event : remaining) = do
        result <- processEventThroughMatchers matcher rest event
        case result of
          Stop -> pure Stop
          Continue -> processAllEvents remaining
   in processAllEvents events

-- | Process a single event through matchers
processEventThroughMatchers ::
  forall m backend event ts.
  (MonadIO m, IsEvent event, StoreCursor backend) =>
  (Proxy event, EventHandler event m backend) ->
  EventMatcher ts backend m ->
  StoredEvent ->
  m SubscriptionResult
processEventThroughMatchers (proxy, handler) rest event = do
  let targetEvent = getEventName proxy
  if event.eventName == targetEvent
    then case parseStoredEventToEnvelope
                proxy
                event.eventId
                event.streamId
                (makeCursor  event.seqNo)
                event.streamVersion
                event.correlationId
                event.createdAt
                event.payload
                event.eventVersion of
      Just envelope -> handler envelope
      Nothing -> processEvents rest [event]
    else processEvents rest [event]

-- | Update store state with new events
updateState :: forall backend. (StoreCursor backend) => StoredEvent -> StoreState backend -> StoreState backend
updateState event state =
  state
    { events = Map.insert event.seqNo event state.events,
      streamEvents = Map.alter (Just . maybe [event.seqNo] (event.seqNo :)) event.streamId state.streamEvents,
      streamVersions = Map.insert event.streamId (makeCursor  event.seqNo) state.streamVersions,
      streamLocalVersions = Map.insert event.streamId event.streamVersion state.streamLocalVersions,
      globalNotification = state.globalNotification
    }

-- | Make stored events from raw data
makeStoredEvents ::
  forall t backend.
  (Foldable t) =>
  StoreState backend ->
  Maybe CorrelationId ->
  UTCTime ->
  [EventId] ->
  StreamId ->
  StreamEventBatch t SomeLatestEvent backend ->
  ([StoredEvent], [Integer])
makeStoredEvents state mbCorrId now eventIds streamId batch =
  let baseSeq = state.nextSequence
      seqNos = [baseSeq .. baseSeq + fromIntegral (length batch.events) - 1]
      currentStreamVersion = Map.findWithDefault (StreamVersion 0) streamId state.streamLocalVersions
      streamVersions = [currentStreamVersion + 1 .. currentStreamVersion + fromIntegral (length batch.events)]
      mkEvent (sn, (eid, SomeLatestEvent proxy payload), streamVer) =
        let name = getEventName proxy
            version = fromInteger $ getMaxVersion proxy
         in ( StoredEvent
                { seqNo = sn,
                  eventId = eid,
                  streamId = streamId,
                  correlationId = mbCorrId,
                  createdAt = now,
                  eventName = name,
                  eventVersion = version,
                  payload = toJSON payload,
                  streamVersion = streamVer
                },
              sn
            )
   in unzip $ map mkEvent $ zip3 seqNos (zip eventIds $ toList batch.events) streamVersions

-- | Check version constraints for all streams
checkAllVersions ::
  forall t backend.
  (Eq (Cursor backend)) =>
  StoreState backend ->
  Map StreamId (StreamEventBatch t SomeLatestEvent backend) ->
  Either (EventStoreError backend) ()
checkAllVersions state batches = do
  case sequence_
    [ checkVersionConstraint state streamId batch.expectedVersion
      | (streamId, batch) <- Map.toList batches
    ] of
    Left mismatch -> Left $ ConsistencyError $ ConsistencyErrorInfo [mismatch]
    Right () -> Right ()

-- | Insert all events into state
insertAllEvents ::
  forall backend t.
  (StoreCursor backend, Foldable t) =>
  StoreState backend ->
  Maybe CorrelationId ->
  UTCTime ->
  [EventId] ->
  Map StreamId (StreamEventBatch t SomeLatestEvent backend) ->
  (StoreState backend, Cursor backend)
insertAllEvents state mbCorrId now eventIds batches =
  let -- Calculate batch sizes and starting sequence numbers for each batch
      batchSizes = map (length . (.events)) $ Map.elems batches
      batchStartSeqs = scanl (+) state.nextSequence $ map fromIntegral $ init batchSizes

      -- Generate events with proper sequence numbers for each batch
      (allEvents, seqNos) =
        unzip $
          concat
            [ (uncurry zip) $ makeStoredEvents (state {nextSequence = startSeq} :: StoreState backend) mbCorrId now eventIdsForBatch streamId batch
              | (streamId, batch, eventIdsForBatch, startSeq) <-
                  zip4
                    (Map.keys batches)
                    (Map.elems batches)
                    (chunksOf batchSizes eventIds)
                    batchStartSeqs
            ]

      -- Update state with new events and metadata
      finalState =
        state
          { nextSequence = state.nextSequence + fromIntegral (length allEvents),
            events = Map.union state.events (Map.fromList $ zip seqNos allEvents),
            streamEvents = foldr updateStreamEvents state.streamEvents allEvents,
            streamVersions = foldl' updateStreamVersions state.streamVersions allEvents,
            streamLocalVersions = foldl' updateStreamLocalVersions state.streamLocalVersions allEvents
          }

      -- Return cursor pointing to last inserted event, or previous position if no events
      finalCursor = case seqNos of
        [] -> makeCursor  (state.nextSequence - 1)  -- No events inserted
        _ -> makeCursor  $ last seqNos  -- Last inserted event
   in (finalState, finalCursor)
  where
    -- Helper function to update stream events mapping
    updateStreamEvents e =
      Map.alter
        (Just . maybe [e.seqNo] (e.seqNo :))
        e.streamId

    -- Helper function to update stream versions (left fold: acc first, event second)
    updateStreamVersions acc e =
      Map.insert
        e.streamId
        (makeCursor  e.seqNo)
        acc

    -- Helper function to update stream local versions (left fold: acc first, event second)
    updateStreamLocalVersions acc e =
      Map.insert
        e.streamId
        e.streamVersion
        acc

    -- Helper function to chunk list based on sizes
    chunksOf :: [Int] -> [a] -> [[a]]
    chunksOf [] _ = []
    chunksOf (n : ns) xs = take n xs : chunksOf ns (drop n xs)

-- Add new function:

-- | Common implementation of event subscription
subscribeToEvents ::
  forall m backend ts.
  (MonadUnliftIO m, StoreCursor backend) =>
  TVar (StoreState backend) -> -- State variable
  EventMatcher ts backend m -> -- Event matcher
  EventSelector backend -> -- Event selector
  m (SubscriptionHandle backend)
subscribeToEvents stateVar matcher selector = do
  -- Calculate initial sequence number
  startSeq <- case selector.startupPosition of
    FromBeginning -> pure (-1)
    FromLastProcessed cursor -> pure $ makeSequenceNo  cursor

  -- Get or create notification channel
  notifyVar <- liftIO $ atomically $ do
    state <- readTVar stateVar
    case selector.streamId of
      AllStreams -> do
        pure state.globalNotification
      SingleStream sid -> do
        case Map.lookup sid state.streamNotifications of
          Just var -> pure var
          Nothing -> do
            var <- newTVar startSeq
            let newState =
                  state {streamNotifications = Map.insert sid var state.streamNotifications}
            writeTVar stateVar newState
            pure var

  -- Main subscription loop
  let loop :: Integer -> m ()
      loop position = do
        eventResult <- liftIO $ atomically $ do
          relevantEvents <- case selector.streamId of
            AllStreams -> do
              state <- readTVar stateVar
              pure $ sortOn seqNo [ev | (seqNo, ev) <- Map.toList state.events, seqNo > position]
            SingleStream sid -> do
              state <- readTVar stateVar
              pure $
                sortOn
                  seqNo
                  [ ev
                    | seqNos <- toList $ Map.lookup sid state.streamEvents,
                      seqNo <- seqNos,
                      seqNo > position,
                      ev <- toList $ Map.lookup seqNo state.events
                  ]

          pure relevantEvents

        case eventResult of
          [] -> do
            liftIO $ atomically $ do
              curr <- readTVar notifyVar
              when (curr <= position) $ do
                retry
            loop position
          events -> do
            let maxSeq = maximum $ map seqNo events
            result <- processEvents matcher events
            case result of
              Stop -> pure ()
              Continue ->
                loop maxSeq

  -- Start subscription in a forked thread using MonadUnliftIO
  -- TODO: Implement proper cancellation using async library
  withRunInIO $ \runInIO -> do
    void $ forkIO $ runInIO $ loop startSeq
    pure $
      SubscriptionHandle
        { cancel = pure () -- No-op for now
        }
