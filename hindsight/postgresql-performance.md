# Improving PostgreSQL subscriptions

## Problem: PostgreSQL subscriptions are HIGHLY inefficient

Loads of ~25-100 subscriptions almost entirely overload the system under constant event insertion pressure. The system ends up only being able to process a few dozens events per second. Profiling seems to prove that CPU load is mostly responsible for the slow down: subscriptions do a lot of work. As it happens, every subscription does its own JSON decoding.

This is currently unavoidable, because the interface between subscriptions and the event dispatcher is mostly untyped:

- Subscriptions register to the dispatcher by mereley passing the *names* of the events they are subscribe to:

```haskell
-- | Register a subscription with the dispatcher
-- Returns the current position for catch-up and a queue for real-time events
registerSubscription ::
  EventDispatcher ->
  [Text] ->                    -- ^ Event names to subscribe to
  EventSelector SQLStore ->   -- ^ Stream selector
  IO RegistrationResult
```

- The dispatcher appends untyped `EventData` to each subscription's queue, with the payload as JSON

```haskell
-- | Event data as fetched from database
data EventData = EventData
  { transactionNo :: Int64
  , seqNo :: Int32
  , eventId :: UUID
  , streamId :: UUID
  , correlationId :: Maybe UUID
  , createdAt :: UTCTime
  , eventName :: Text
  , eventVersion :: Int32
  , payload :: Value -- This, right here, is a problem.
  } deriving (Show)
```

## Solution: Typeable ?

We could have the `registerSubscription` pass a typelevel list of symbols instead of `[Text]`, while also requesting the appropriate constraints from ALL events (probably just the `IsEvent` constraints-bag).

We could then change `EventData` to:

```
import Type.Reflection (TypeRep) -- *Indexed* typerep.

data EventData = forall e. (Typeable e) => EventData
  { proxy :: Proxy e
  , typeRep :: TypeRep e
  , envelope :: EventEnvelope e 
  }
```

where, for reference,


```
data EventEnvelope event backend = EventWithMetadata
  { position :: Cursor backend,              -- ^ Global position in the event store
    eventId :: EventId,                      -- ^ Unique event identifier
    streamId :: StreamId,                    -- ^ Stream this event belongs to
    correlationId :: Maybe CorrelationId,    -- ^ Optional correlation ID
    createdAt :: UTCTime,                    -- ^ Timestamp when event was stored
    payload :: CurrentPayloadType event      -- ^ The actual event data
  }
```


Each subscription would simply build a map of typerep to handler, or just maintain a list and compare by typerep to make sure that event type matches what each individual event handler expects.

The dispatcher would have to do the parsing, NOT the subscriptions. It would have to avoid the fatal error, done by subscriptions, of *RECOMPUTING* parse maps:

```haskell
-- | Process a list of events efficiently
processEventList :: forall ts. EventMatcher ts SQLStore IO -> [Dispatcher.EventData] -> IO ()
processEventList _ [] = pure ()
processEventList MatchEnd _ = pure ()
processEventList matcher@((proxy, handler) :? rest) events = do
  let targetEvent = getEventName proxy
      parserMap = parseMapFromProxy proxy  -- Get parser map ONCE
      (matching, nonMatching) = partition (\e -> e.eventName == targetEvent) events
````

(EFFICIENTLY !?!?)
