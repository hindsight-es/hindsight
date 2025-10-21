{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE RequiredTypeArguments #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}

{- |
Module      : Hindsight.Projection.Matching
Description : PostgreSQL-based projection handlers
Copyright   : (c) 2024
License     : BSD3
Maintainer  : maintainer@example.com
Stability   : experimental

PostgreSQL-based projection handlers. Used by both sync and async projections
to update read models stored in PostgreSQL, regardless of event store backend.
-}
module Hindsight.Projection.Matching (
    -- * Projection Types
    ProjectionHandler,
    ProjectionHandlers (..),
    SomeProjectionHandler (..),

    -- * Handler Matching

    {- | Two different matching strategies for different use cases:

    * 'extractMatchingHandlers': Use when you have a typed envelope at compile time
    * 'handlersForEventName': Use when you only have an event name at runtime
    -}
    extractMatchingHandlers,
    handlersForEventName,
)
where

import Data.Proxy (Proxy (..))
import Data.Text (Text)
import Data.Typeable (Typeable, eqT, (:~:) (Refl))
import GHC.TypeLits (Symbol)
import Hasql.Transaction (Transaction)
import Hindsight.Events (Event, getEventName)
import Hindsight.Store (EventEnvelope)

-- | A projection handler for a specific event type
type ProjectionHandler event backend =
    EventEnvelope event backend -> Transaction ()

-- | A type-indexed list of projection handlers
data ProjectionHandlers (ts :: [Symbol]) backend where
    (:->) ::
        (Event event, Typeable (ProjectionHandler event backend)) =>
        (Proxy event, ProjectionHandler event backend) ->
        ProjectionHandlers ts backend ->
        ProjectionHandlers (event ': ts) backend
    ProjectionEnd :: ProjectionHandlers '[] backend

infixr 5 :->

{- | Extract handlers that match a specific event type (compile-time matching)

Use this when you have a typed 'EventEnvelope event backend' and need to find
handlers that can process it. Returns handlers with the correct type signature.

This function is needed for sync projections during real-time event insertion,
where the event type is known at compile time but the handler list is
existentially quantified (due to storage in 'SyncProjectionRegistry').

The type casting is safe because event names uniquely identify event types.
-}
extractMatchingHandlers ::
    forall event ts backend.
    (Event event) =>
    -- | All available handlers
    ProjectionHandlers ts backend ->
    -- | Event type to match
    Proxy event ->
    -- | Matching handlers with correct type
    [ProjectionHandler event backend]
extractMatchingHandlers handlers eventProxy = matchHandlers handlers
  where
    eventName = getEventName eventProxy

    matchHandlers :: ProjectionHandlers ts' backend -> [ProjectionHandler event backend]
    matchHandlers ProjectionEnd = []
    matchHandlers ((handlerProxy :: Proxy handlerEvent, handler) :-> rest) =
        let handlerName = getEventName handlerProxy
         in if eventName == handlerName
                then
                    -- Type cast: Since event names match, the types must be equal.
                    -- The Nothing branch should never happen (event names uniquely identify types),
                    -- but we handle it defensively.
                    case eqT @handlerEvent @event of
                        Just Refl -> handler : matchHandlers rest
                        Nothing -> matchHandlers rest -- Impossible if event name uniqueness holds (should we blow up here ?)
                else
                    matchHandlers rest

--------------------------------------------------------------------------------
-- Handler Filtering
--------------------------------------------------------------------------------

{- | Existential wrapper for projection handlers of unknown event types

Used when working with handlers but the event type is not known at compile time.
-}
data SomeProjectionHandler backend
    = forall event.
        (Event event) =>
      SomeProjectionHandler (Proxy event) (ProjectionHandler event backend)

{- | Find all handlers that match a specific event name (runtime matching)

Use this when you only have an event name from a stored event (as 'Text')
and need to find matching handlers. Returns existentially wrapped handlers
that preserve their original event types.

This function is needed for sync projection catch-up, where events are
read from the database and their types are not known at compile time.
Each handler remains wrapped with its specific event type, allowing
type-safe envelope construction via parsing.

No type casting is needed because handlers retain their existential wrappers.
-}
handlersForEventName ::
    -- | Event name from stored event
    Text ->
    -- | All available handlers
    ProjectionHandlers ts backend ->
    -- | Only handlers that match the event name
    [SomeProjectionHandler backend]
handlersForEventName targetEventName = go
  where
    go :: ProjectionHandlers ts' backend -> [SomeProjectionHandler backend]
    go ProjectionEnd = []
    go ((eventProxy, handler) :-> rest) =
        let handlerEventName = getEventName eventProxy
         in if targetEventName == handlerEventName
                then SomeProjectionHandler eventProxy handler : go rest
                else go rest
