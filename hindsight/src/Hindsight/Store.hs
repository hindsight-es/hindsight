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

This module defines the core event store interface and types used across
all storage backends.

= Overview

An event store is a append-only log of events organized into streams.
Each stream represents the lifecycle of a single aggregate or entity.

= Basic Usage

@
import Hindsight.Store
import Hindsight.Store.Memory (newMemoryStore)

-- Create a store
store <- newMemoryStore

-- Insert events
let batch = StreamWrite
      { expectedVersion = NoStream
      , events = [mkEvent \"user_created\" payload]
      }
result <- insertEvents store Nothing (Map.singleton streamId batch)

-- Subscribe to events
handle <- subscribe store matcher selector
@

= Key Concepts

* __Streams__: Ordered sequences of events for a single entity
* __Cursors__: Opaque positions in the global event log
* __Subscriptions__: Real-time notifications of new events
* __Version Expectations__: Optimistic concurrency control for writes
-}
module Hindsight.Store
  ( -- * Core Identifiers
    -- | Unique identifiers for streams, events, and correlations.
    StreamId (..),
    EventId (..),
    CorrelationId (..),
    StreamVersion (..),

    -- * Event Store Interface
    -- | The main type class implemented by all storage backends.
    --
    -- The 'EventStore' class includes the 'StoreConstraints' type family,
    -- which defines additional constraints required by each backend.
    EventStore (..),

    -- ** Backend Types
    -- | Backend-specific handle and cursor types.
    --
    -- Each backend defines its own 'Cursor' and 'BackendHandle' via type families.
    BackendHandle,
    Cursor,

    -- * Event Operations
    -- | Types for inserting and querying events.

    -- ** Insertion
    StreamWrite (..),
    Transaction (..),
    InsertionResult (..),
    InsertionSuccess (..),

    -- ** Transaction Helpers
    -- | Helper functions for constructing transactions.
    --
    -- The 'singleEvent' and 'multiEvent' functions are the primary API,
    -- requiring explicit version expectations. Convenience helpers like
    -- 'appendAfterAny' are provided for common patterns.
    singleEvent,
    multiEvent,
    appendAfterAny,
    appendToOrCreateStream,
    fromWrites,

    -- ** Version Control
    -- | Optimistic concurrency control for preventing conflicts.
    --
    -- When inserting events, you can specify version expectations to ensure
    -- the stream hasn't changed since you read it. This implements optimistic
    -- locking without holding database locks during business logic execution.
    --
    -- See: <https://en.wikipedia.org/wiki/Optimistic_concurrency_control>
    ExpectedVersion (..),

    -- ** Errors
    EventStoreError (..),
    ErrorInfo (..),
    ConsistencyErrorInfo (..),
    VersionMismatch (..),
    HandlerException (..),

    -- * Event Subscriptions
    -- | Real-time streaming of events as they're inserted.

    -- ** Subscription Configuration
    EventSelector (..),
    StreamSelector (..),
    StartupPosition (..),

    -- ** Subscription Control
    SubscriptionHandle (..),
    SubscriptionResult (..),

    -- * Event Handling
    -- | Processing events in subscriptions.

    -- ** Event Envelopes
    -- | Events with full metadata from the store.
    EventEnvelope (..),

    -- ** Event Matchers
    -- | Type-safe pattern matching on event types.
    --
    -- Build matchers using 'match' and the '(:?)' operator:
    --
    -- @
    -- matcher = match \"user_created\" handleUserCreated
    --        :? match \"user_updated\" handleUserUpdated
    --        :? MatchEnd
    -- @
    EventHandler,
    EventMatcher (..),
    match,
  )
where

import Control.Exception (Exception, SomeException, displayException)
import Data.Aeson (FromJSON, ToJSON)
import Data.Int (Int64)
import Data.Kind (Constraint, Type)
import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Proxy (Proxy (..))
import Data.Text (Text)
import qualified Data.Text as T
import Data.Time (UTCTime)
import Data.Typeable (Typeable)
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

-- | Exception thrown when an event handler fails during subscription processing.
--
-- This exception wraps the original exception with rich event context to aid debugging.
-- When a handler throws an exception, the subscription will die immediately (fail-fast),
-- and this enriched exception will be available via the Async handle.
--
-- The handler exception represents a bug in event processing code. Higher-level code
-- (such as projection managers) can implement retry logic if desired.
data HandlerException = HandlerException
  { originalException :: SomeException       -- ^ The actual exception that was thrown
  , failedEventPosition :: Text              -- ^ Cursor position where it failed (serialized)
  , failedEventId :: EventId                 -- ^ Unique identifier of the failed event
  , failedEventName :: Text                  -- ^ The name of the event that failed
  , failedEventStreamId :: StreamId          -- ^ Which stream the event came from
  , failedEventStreamVersion :: StreamVersion -- ^ Local version within the stream
  , failedEventCorrelationId :: Maybe CorrelationId -- ^ Correlation ID if present
  , failedEventCreatedAt :: UTCTime          -- ^ When the event was stored
  }
  deriving (Typeable)

instance Show HandlerException where
  show e =
    "Handler exception at position " <> T.unpack e.failedEventPosition
    <> " for event '" <> T.unpack e.failedEventName <> "'"
    <> " (eventId: " <> show e.failedEventId <> ")"
    <> " in stream " <> show e.failedEventStreamId
    <> " (stream version: " <> show e.failedEventStreamVersion <> ")"
    <> ": " <> displayException e.originalException

instance Exception HandlerException

-- | Success data from an event insertion operation.
--
-- Contains the global cursor position of the last event inserted
-- and the per-stream cursor positions.
data InsertionSuccess backend = InsertionSuccess
  { finalCursor :: Cursor backend                      -- ^ Global position of last inserted event
  , streamCursors :: Map StreamId (Cursor backend)     -- ^ Per-stream final cursors
  }

-- | Result of an event insertion operation.
data InsertionResult backend
  = SuccessfulInsertion (InsertionSuccess backend)  -- ^ Success with cursor information
  | FailedInsertion (EventStoreError backend)       -- ^ Failure with error details

-- | Control flow for event subscriptions.
data SubscriptionResult 
  = Stop      -- ^ Stop processing and cancel the subscription
  | Continue  -- ^ Continue processing subsequent events
  deriving (Eq, Show)

-- | Handle for managing a subscription lifecycle
data SubscriptionHandle backend = SubscriptionHandle
  { -- | Cancel the subscription
    cancel :: IO (),
    -- | Wait for the subscription to complete or fail.
    -- Re-throws any exception from the subscription thread.
    -- This is useful for both testing (to observe handler exceptions)
    -- and production (to monitor subscription health).
    wait :: IO ()
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
-- Constructed using the 'match' helper with '(:?)' to build a chain of handlers:
--
-- @
-- matcher = match \"user_created\" handleUserCreated
--        :? match \"user_updated\" handleUserUpdated
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
-- The type family is injective: knowing the cursor type determines the backend
-- which helps with type inference.
type family Cursor backend = result | result -> backend

-- | Handle to interact with a specific storage backend.
--
-- Contains backend-specific configuration like connection pools,
-- file handles, or in-memory storage references.
--
-- The type family is injective: knowing the handle type determines the backend,
-- which helps with type inference.
type family BackendHandle backend = result | result -> backend

-- | Version expectation for optimistic concurrency control.
--
-- Used to prevent concurrent modifications by specifying what version
-- a stream should be at before inserting new events.
--
-- This implements optimistic locking: instead of holding locks during
-- a read-modify-write cycle, we check at write time that the stream
-- hasn't changed since we read it.
--
-- See: <https://en.wikipedia.org/wiki/Optimistic_concurrency_control>
--
-- Common patterns:
--
-- * 'NoStream' - Creating a new aggregate (ensure stream doesn't exist)
-- * 'ExactStreamVersion' - Normal update (check we have latest version)
-- * 'Any' - Append-only scenarios (no conflict prevention)
data ExpectedVersion backend
  = NoStream                           -- ^ Stream must not exist (for creating new streams)
  | StreamExists                       -- ^ Stream must exist (any version)
  | ExactVersion (Cursor backend)      -- ^ Stream must be at this exact global position
  | ExactStreamVersion StreamVersion   -- ^ Stream must be at this exact local version
  | Any                                -- ^ No version check (always succeeds)

deriving instance (Show (Cursor backend)) => Show (ExpectedVersion backend)

deriving instance (Eq (Cursor backend)) => Eq (ExpectedVersion backend)

-- | Write operation for inserting events into a single stream.
--
-- Groups events with their version expectation for atomic insertion.
-- The event type 'e' can be 'SomeLatestEvent' for raw events or enriched with metadata.
data StreamWrite t e backend = StreamWrite
  { expectedVersion :: ExpectedVersion backend,  -- ^ Version check before insertion
    events :: t e                                -- ^ Events to insert (in order)
  }

deriving instance (Show (ExpectedVersion backend), Show (t e)) => Show (StreamWrite t e backend)

deriving instance (Eq (ExpectedVersion backend), Eq (t e)) => Eq (StreamWrite t e backend)

-- | A multi-stream transactional write operation.
--
-- Represents a set of writes to be inserted atomically across multiple streams.
-- All version checks must pass for the entire transaction to succeed.
--
-- = Ordering Guarantees
--
-- * Events within a single stream are __totally ordered__ - they appear in the
--   global event log in the order specified.
--
-- * Events across different streams within the same transaction have __no ordering
--   guarantee__ relative to each other. They are inserted atomically but may
--   appear in any interleaving in the global log.
--
-- = Composition
--
-- Transactions form a 'Monoid', allowing easy composition:
--
-- @
-- transaction1 <> transaction2 <> transaction3
-- @
--
-- When combining transactions:
--
-- * Events for the same stream are __concatenated__ (events from tx1, then tx2)
-- * Version expectations are __left-biased__ (tx1's expectation wins)
--
-- = Example
--
-- @
-- -- Simple single-event write
-- let tx = singleEvent streamId NoStream event
-- result <- insertEvents store Nothing tx
--
-- -- Multi-stream with composition
-- let tx = singleEvent userStreamId NoStream userCreated
--       <> appendAfterAny auditLogId auditEntry
-- result <- insertEvents store Nothing tx
-- @
newtype Transaction t backend = Transaction
  { transactionWrites :: Map StreamId (StreamWrite t SomeLatestEvent backend)
  }

deriving instance (Show (Cursor backend), Show (t SomeLatestEvent)) => Show (Transaction t backend)

deriving instance (Eq (Cursor backend), Eq (t SomeLatestEvent)) => Eq (Transaction t backend)

instance (Semigroup (t SomeLatestEvent)) => Semigroup (Transaction t backend) where
  Transaction m1 <> Transaction m2 =
    Transaction (Map.unionWith combineWrites m1 m2)
    where
      -- Left-biased for expectedVersion (first write wins)
      -- Concatenate events using Semigroup (e.g., list append)
      combineWrites (StreamWrite expectedVer events1) (StreamWrite _ignored events2) =
        StreamWrite expectedVer (events1 <> events2)

instance (Semigroup (t SomeLatestEvent)) => Monoid (Transaction t backend) where
  mempty = Transaction Map.empty

-- | Create a transaction with a single event to a single stream.
--
-- This is the primary API - it forces explicit choice of version expectation.
--
-- @
-- -- Creating a new aggregate
-- singleEvent accountId NoStream accountCreated
--
-- -- Updating with optimistic locking
-- singleEvent accountId (ExactStreamVersion v) balanceUpdated
--
-- -- Append-only log
-- singleEvent logId Any logEntry
-- @
singleEvent ::
  StreamId ->
  ExpectedVersion backend ->
  SomeLatestEvent ->
  Transaction [] backend
singleEvent streamId expectedVer event =
  Transaction $ Map.singleton streamId (StreamWrite expectedVer [event])

-- | Create a transaction with multiple events to a single stream.
--
-- @
-- multiEvent streamId NoStream [event1, event2, event3]
-- @
multiEvent ::
  StreamId ->
  ExpectedVersion backend ->
  t SomeLatestEvent ->
  Transaction t backend
multiEvent streamId expectedVer events =
  Transaction $ Map.singleton streamId (StreamWrite expectedVer events)

-- | Append an event to an existing stream without version checking.
--
-- Uses 'StreamExists' for the version expectation - the stream must already
-- exist, but any version is acceptable. Suitable for append-only scenarios
-- where multiple processes may be writing concurrently.
--
-- = Use Cases
--
-- * __Audit logs__ where the log stream is pre-created
-- * __Event logs__ with concurrent writers
-- * __Not suitable__ for aggregates with business invariants
--
-- @
-- -- Audit log entry (stream must exist)
-- appendAfterAny auditLogId auditEntry
--
-- -- Multiple concurrent writers OK
-- tx1 = appendAfterAny logId event1
-- tx2 = appendAfterAny logId event2  -- No conflict
-- @
appendAfterAny ::
  StreamId ->
  SomeLatestEvent ->
  Transaction [] backend
appendAfterAny streamId event =
  singleEvent streamId StreamExists event

-- | Append an event, creating the stream if it doesn't exist.
--
-- Uses 'Any' for the version expectation - no version checking at all.
-- This is the most permissive option.
--
-- __Warning__: This provides no concurrency control. Suitable for testing
-- or truly append-only scenarios, but dangerous for aggregates with invariants.
--
-- = Use Cases
--
-- * __Testing__ where you don't care about stream state
-- * __Idempotent appends__ where duplicates are handled elsewhere
-- * __Not suitable__ for production aggregates
--
-- @
-- -- Test code
-- appendToOrCreateStream testStreamId testEvent
--
-- -- For production, prefer explicit version expectations
-- singleEvent streamId NoStream event  -- Better: explicit create
-- @
appendToOrCreateStream ::
  StreamId ->
  SomeLatestEvent ->
  Transaction [] backend
appendToOrCreateStream streamId event =
  singleEvent streamId Any event

-- | Create a transaction from a list of stream writes.
--
-- @
-- fromWrites
--   [ (stream1, StreamWrite NoStream [e1])
--   , (stream2, StreamWrite NoStream [e2])
--   ]
-- @
fromWrites ::
  [(StreamId, StreamWrite t SomeLatestEvent backend)] ->
  Transaction t backend
fromWrites = Transaction . Map.fromList

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
    Transaction t backend ->
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

