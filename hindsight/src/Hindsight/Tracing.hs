{-# LANGUAGE OverloadedStrings #-}

module Hindsight.Tracing
  ( module Reexports,

    -- * Context helpers
    ContextLinks (..),

    -- * Span helpers
    withSpanWithAttributes,

    -- * Attribute helpers
    mkAttrMap,
    
    -- * No-op types for compatibility
    Tracer,
    Span,
    PrimitiveAttribute,
    Attribute,
    TracerProvider,
    InstrumentationLibrary,
    TracerOptions,
    Key,
    Context,
    SpanContext,
    AttributeValue(..),
    NewEvent(..),
    NewLink,
    makeNewLink,
    
    -- * No-op functions
    getGlobalTracerProvider,
    makeTracer,
    detectInstrumentationLibrary,
    tracerOptions,
    getProjectionTracer,
    getPlutarchTracer,
    addAttributes,
    toAttribute,
    newKey,
    insert,
    lookup,
    getContext,
    attachContext,
    getSpanContext,
    addEvent,
    addLink,
  )
where

import Data.HashMap.Strict qualified as Map
import Data.Text (Text)
import Data.Int (Int64)
import Hindsight.Tracing.Location as Reexports
import UnliftIO (MonadUnliftIO (..))
import System.IO.Unsafe (unsafePerformIO)
import Prelude hiding (lookup)

-- No-op type definitions for compatibility
data Tracer = Tracer
data Span = Span
data PrimitiveAttribute = PrimitiveAttribute
data Attribute = Attribute
data NewLink = NewLink
  { linkContext :: SpanContext
  , linkAttributes :: [(Text, AttributeValue)]
  }
data TracerProvider = TracerProvider
data InstrumentationLibrary = InstrumentationLibrary
data TracerOptions = TracerOptions
data Key a = Key
data Context = Context
data SpanContext = SpanContext
data AttributeValue = IntAttribute Int64 | TextAttribute Text
data NewEvent = NewEvent 
  { newEventName :: Text
  , newEventTimestamp :: Maybe Timestamp  
  , newEventAttributes :: [(Text, AttributeValue)]
  }
type Timestamp = Int64

-- Set of links that will be added to the spans created by this module
-- within the current thread.
newtype ContextLinks = ContextLinks {getLinks :: [NewLink]}

-- | Create a span with a list of attributes (no-op implementation).
withSpanWithAttributes ::
  (MonadUnliftIO m) =>
  Tracer ->
  Text ->
  [(Text, PrimitiveAttribute)] ->
  (Span -> m a) ->
  m a
withSpanWithAttributes _ _ _ action = action Span

mkAttrMap :: [(Text, PrimitiveAttribute)] -> Map.HashMap Text Attribute
mkAttrMap _ = Map.empty

-- No-op function implementations
getGlobalTracerProvider :: IO TracerProvider
getGlobalTracerProvider = pure TracerProvider

makeTracer :: TracerProvider -> InstrumentationLibrary -> Tracer
makeTracer _ _ = Tracer

detectInstrumentationLibrary :: TracerOptions -> InstrumentationLibrary
detectInstrumentationLibrary _ = InstrumentationLibrary

tracerOptions :: TracerOptions
tracerOptions = TracerOptions

getProjectionTracer :: IO Tracer
getProjectionTracer = pure Tracer

getPlutarchTracer :: IO Tracer
getPlutarchTracer = pure Tracer

addAttributes :: Span -> Map.HashMap Text Attribute -> IO ()
addAttributes _ _ = pure ()

toAttribute :: PrimitiveAttribute -> Attribute
toAttribute _ = Attribute

-- Context-related no-op functions
newKey :: String -> Key a
newKey _ = Key

insert :: Key a -> a -> Context -> Context
insert _ _ _ = Context

lookup :: Key a -> Context -> Maybe a
lookup _ _ = Nothing

getContext :: IO Context
getContext = pure Context

attachContext :: Context -> IO ()
attachContext _ = pure ()

getSpanContext :: Span -> Maybe SpanContext
getSpanContext _ = Nothing

addEvent :: Span -> NewEvent -> IO ()
addEvent _ _ = pure ()

addLink :: Span -> NewLink -> IO ()
addLink _ _ = pure ()

-- Constructor function to avoid record syntax issues
makeNewLink :: SpanContext -> [(Text, AttributeValue)] -> NewLink
makeNewLink ctx attrs = NewLink { linkContext = ctx, linkAttributes = attrs }