{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE RequiredTypeArguments #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeFamilyDependencies #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE NoFieldSelectors #-}

{-|
Module      : Hindsight.Store
Description : Event store interface and common data types
Copyright   : (c) 2024
License     : BSD3
Maintainer  : maintainer@example.com
Stability   : experimental

Defines the core event store interface implemented by storage backends.
Provides types for events, streams, cursors, and version expectations.
-}
module Hindsight.Store where

import Control.Exception (SomeException)
import Data.Aeson (FromJSON, ToJSON)
import Data.Int (Int64)
import Data.Kind (Constraint, Type)
import Data.Map.Strict (Map)
import Data.Proxy (Proxy (..))
import Data.Text (Text)
import Data.Time (UTCTime)
import Data.UUID (UUID)
import GHC.Generics (Generic)
import GHC.TypeLits (Symbol)
import Hindsight.Core

-- | Unique identifier for an event stream.
--
-- Streams are logical groupings of related events, typically representing
-- the lifecycle of a single aggregate or entity.
newtype StreamId = StreamId {toUUID :: UUID}
  deriving (Eq, Ord, Show, FromJSON, ToJSON)

-- | Unique identifier for an individual event.
newtype EventId = EventId {toUUID :: UUID}
  deriving (Eq, Ord, Show, FromJSON, ToJSON)

-- | Correlation identifier for tracking related events across streams.
--
-- Used to trace causally-related events that span multiple streams
-- or external system boundaries.
newtype CorrelationId = CorrelationId {toUUID :: UUID}
  deriving (Eq, Ord, Show, FromJSON, ToJSON)

-- | Local stream version - simple incrementing number per stream (1, 2, 3, ...)
newtype StreamVersion = StreamVersion Int64
  deriving (Show, Eq, Ord, Generic, FromJSON, ToJSON, Num, Enum)

-- | General error information with optional exception details.
data ErrorInfo = ErrorInfo
  { errorMessage :: Text,
    exception :: Maybe SomeException
  }
  deriving (Show)

-- | Consistency violation details containing all version mismatches.
data ConsistencyErrorInfo backend = ConsistencyErrorInfo [VersionMismatch backend]

-- | Details of a version expectation failure.
data VersionMismatch backend = VersionMismatch
  { streamId :: StreamId,
    -- | The version expectation that was not met
    expectedVersion :: ExpectedVersion backend,
    -- | The actual version found (Nothing if stream doesn't exist)
    actualVersion :: Maybe (Cursor backend)
  }

-- | Possible errors when interacting with the event store.
data EventStoreError backend
  = ConsistencyError (ConsistencyErrorInfo backend)  -- ^ Version expectation failures
  | BackendError ErrorInfo                            -- ^ Storage backend errors
  | OtherError ErrorInfo                              -- ^ Other application errors

deriving instance (Show (Cursor backend)) => Show (VersionMismatch backend)

deriving instance (Show (Cursor backend)) => Show (ConsistencyErrorInfo backend)

deriving instance (Show (Cursor backend)) => Show (EventStoreError backend)

-- | Result of an event insertion operation.
data InsertionResult backend
  = SuccessfulInsertion (Cursor backend)      -- ^ Success with position of last inserted event
  | FailedInsertion (EventStoreError backend)  -- ^ Failure with error details

-- | Control flow for event subscriptions.
data SubscriptionResult 
  = Stop      -- ^ Stop processing and cancel the subscription
  | Continue  -- ^ Continue processing subsequent events
  deriving (Eq, Show)

-- | Handle for managing a subscription lifecycle
data SubscriptionHandle backend = SubscriptionHandle
  { -- | Cancel the subscription
    cancel :: IO ()
  }

-- | Event with full metadata as retrieved from the store.
data EventEnvelope event backend = EventWithMetadata
  { position :: Cursor backend,              -- ^ Global position in the event store
    eventId :: EventId,                      -- ^ Unique event identifier
    streamId :: StreamId,                    -- ^ Stream this event belongs to
    streamVersion :: StreamVersion,          -- ^ Local version within the stream (1, 2, 3, ...)
    correlationId :: Maybe CorrelationId,    -- ^ Optional correlation ID
    createdAt :: UTCTime,                    -- ^ Timestamp when event was stored
    payload :: CurrentPayloadType event      -- ^ The actual event data
  }

deriving instance (Show (FinalVersionType (Versions event)), Show (Cursor backend)) => Show (EventEnvelope event backend)

-- | Criteria for selecting events in a subscription.
data EventSelector backend = EventSelector
  { streamId :: StreamSelector,              -- ^ Which streams to subscribe to
    startupPosition :: StartupPosition backend  -- ^ Where to start reading from
  }

deriving instance (Show (StartupPosition backend)) => Show (EventSelector backend)

-- | Stream selection criteria for subscriptions.
data StreamSelector 
  = AllStreams           -- ^ Subscribe to all streams
  | SingleStream StreamId -- ^ Subscribe to a specific stream only
  deriving (Show)

-- | Starting position for event subscriptions.
data StartupPosition backend 
  = FromBeginning                    -- ^ Start from the first event
  | FromLastProcessed (Cursor backend) -- ^ Start after the specified position

deriving instance (Show (Cursor backend)) => Show (StartupPosition backend)

-- | Handler function for processing events in a subscription.
type EventHandler event m backend = EventEnvelope event backend -> m SubscriptionResult

-- | Type-safe event matcher for handling different event types in subscriptions.
--
-- Constructed using the '(:?)' operator to build a chain of handlers:
--
-- @
-- matcher = (Proxy @"user_created", handleUserCreated)
--        :? (Proxy @"user_updated", handleUserUpdated) 
--        :? MatchEnd
-- @
data EventMatcher (ts :: [Symbol]) backend m where
  (:?) :: (IsEvent event) => (Proxy event, EventHandler event m backend) -> EventMatcher ts backend m -> EventMatcher (event ': ts) backend m
  MatchEnd :: EventMatcher '[] backend m

infixr 5 :?

-- | Helper to construct event handler pairs for 'EventMatcher'.
--
-- Uses RequiredTypeArguments for better error messages when the type is omitted.
--
-- @
-- matcher = match "user_created" handleUser :? MatchEnd
-- @
match :: forall event -> forall a. a -> (Proxy event, a)
match event = \handler -> (Proxy @event, handler)


-- | Position marker within an event store, backend-specific.
--
-- For example, PostgreSQL uses a compound cursor of (transaction_no, seq_no),
-- while a simple implementation might use a single sequence number.
--
-- The type family is injective: knowing the cursor type determines the backend.
type family Cursor backend = result | result -> backend

-- | Handle to interact with a specific storage backend.
--
-- Contains backend-specific configuration like connection pools,
-- file handles, or in-memory storage references.
--
-- The type family is injective: knowing the handle type determines the backend.
type family BackendHandle backend = result | result -> backend

-- | Version expectation for optimistic concurrency control.
--
-- Used to prevent concurrent modifications by specifying what version
-- a stream should be at before inserting new events.
data ExpectedVersion backend
  = NoStream                           -- ^ Stream must not exist (for creating new streams)
  | StreamExists                       -- ^ Stream must exist (any version)
  | ExactVersion (Cursor backend)      -- ^ Stream must be at this exact global position
  | ExactStreamVersion StreamVersion   -- ^ Stream must be at this exact local version
  | Any                                -- ^ No version check (always succeeds)

deriving instance (Show (Cursor backend)) => Show (ExpectedVersion backend)

-- | Batch of events to insert into a single stream.
--
-- Groups events with their version expectation for atomic insertion.
-- The event type 'e' can be 'SomeLatestEvent' for raw events or enriched with metadata.
data StreamEventBatch t e backend = StreamEventBatch
  { expectedVersion :: ExpectedVersion backend,  -- ^ Version check before insertion
    events :: t e                                -- ^ Events to insert (in order)
  }

-- | Core interface for event store backends.
--
-- Provides methods for inserting events and subscribing to event streams.
-- Each backend defines its own constraints via 'StoreConstraints'.
class EventStore (backend :: Type) where
  -- | Additional constraints required by this backend.
  --
  -- For example, PostgreSQL requires MonadUnliftIO for async operations.
  type StoreConstraints backend (m :: Type -> Type) :: Constraint

  -- | Insert event batches atomically into the store.
  --
  -- All events in the batch are inserted as a single transaction.
  -- If any version check fails, the entire operation is rolled back.
  insertEvents ::
    (Traversable t, StoreConstraints backend m) =>
    BackendHandle backend ->
    Maybe CorrelationId ->
    Map StreamId (StreamEventBatch t SomeLatestEvent backend) ->
    m (InsertionResult backend)

  -- | Subscribe to events matching the given criteria.
  --
  -- The subscription will call the appropriate handler for each matching
  -- event until a handler returns 'Stop' or the subscription is cancelled.
  subscribe ::
    (StoreConstraints backend m) =>
    BackendHandle backend ->
    EventMatcher ts backend m ->
    EventSelector backend ->
    m (SubscriptionHandle backend)

