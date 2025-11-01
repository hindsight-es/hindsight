# KurrentDB gRPC Integration Design

**Project**: Hindsight KurrentDB Backend
**Date**: 2025-11-01
**Status**: Phase 1 Complete ✅ | Phase 2 Complete ✅

---

## Table of Contents

1. [Overview](#overview)
2. [Phase 1: Single-Stream Appends](#phase-1-single-stream-appends)
3. [Phase 2: Multi-Stream Atomic Appends](#phase-2-multi-stream-atomic-appends)
4. [API Analysis](#api-analysis)
5. [Implementation Details](#implementation-details)
6. [Testing Strategy](#testing-strategy)
7. [Error Handling](#error-handling)
8. [Future Work](#future-work)

---

## Overview

### Goal
Implement a KurrentDB backend for the Hindsight event sourcing framework, providing:
- Single-stream event insertion (Phase 1 ✅)
- Multi-stream atomic event insertion (Phase 2 🚧)
- Optimistic concurrency control
- Real-time event subscriptions (Future)

### Technology Stack
- **KurrentDB**: 25.1.0 (gRPC API)
- **grapesy**: 1.1.1 (Pure Haskell gRPC client)
- **proto-lens**: 0.7 (Protobuf code generation)
- **resource-pool**: 0.5.0 (Connection pooling)

### Key Design Decisions
1. **Connection Pooling**: Use `resource-pool` for fault tolerance and lifecycle management
2. **Type Safety**: Leverage Haskell's type system for compile-time guarantees
3. **Proto Wrappers**: Handle grapesy's `Proto` newtype wrapper explicitly
4. **Pattern Matching**: Use explicit pattern matching instead of record dot syntax for polymorphic types

---

## Phase 1: Single-Stream Appends

### Status: ✅ Complete

### Implementation

#### EventStore Instance
```haskell
instance EventStore KurrentStore where
    type StoreConstraints KurrentStore m = MonadIO m

    insertEvents handle _correlationId (Transaction streams) = liftIO $ do
        case Map.toList streams of
            [] -> -- Return empty success
            [(streamId, streamWrite)] -> insertSingleStream handle streamId streamWrite
            multipleStreams -> -- Error: Phase 2 not yet implemented
```

**Key Features**:
- Stream count validation
- Informative error for multi-stream attempts
- Graceful handling of empty transactions

#### Single-Stream Append (Streams.Append RPC)

**Protocol**: Client-streaming (unary response)

**Flow**:
```
Client → Options (stream_identifier, expected_revision)
Client → ProposedMessage (event 1)
Client → ProposedMessage (event 2)
Client → ...
Client → ProposedMessage (event N) [FINAL]
       ← Server responds with AppendResp
```

**Implementation**:
```haskell
insertSingleStream ::
    (Traversable t) =>
    KurrentHandle ->
    StreamId ->
    StreamWrite t SomeLatestEvent KurrentStore ->
    IO (InsertionResult KurrentStore)
```

**Steps**:
1. Open gRPC connection from pool
2. Send stream options (identifier + expected version)
3. Send all events using `sendNextInput` / `sendFinalInput`
4. Receive response with `recvOutput`
5. Parse response (StreamElem unwrapping)
6. Return InsertionResult

#### Event Serialization
```haskell
sendEvent :: Call -> Bool -> SomeLatestEvent -> IO ()
```

**Process**:
1. Generate UUID for event
2. Extract event name from type-level info (`getEventName`)
3. Extract event version (`getMaxVersion`)
4. Serialize payload to JSON (`encode`)
5. Build metadata map: `("type", eventName)`, `("content-type", "application/json")`
6. Create ProposedMessage with all fields
7. Send via `sendNextInput` (or `sendFinalInput` if last)

#### Version Expectations
```haskell
setExpectedRevision :: ExpectedVersion KurrentStore -> Proto.AppendReq'Options -> Proto.AppendReq'Options
```

**Supported**:
- `NoStream` → `#maybe'expectedStreamRevision .~ Just (Proto.AppendReq'Options'NoStream defMessage)`
- `StreamExists` → `#maybe'expectedStreamRevision .~ Just (Proto.AppendReq'Options'StreamExists defMessage)`
- `ExactStreamVersion rev` → `#maybe'expectedStreamRevision .~ Just (Proto.AppendReq'Options'Revision rev)`

**Not Supported**:
- `ExactVersion cursor` → Errors with guidance to use `ExactStreamVersion`

**Rationale**: KurrentDB Append uses stream revision, not global cursor position.

#### Response Parsing
```haskell
parseAppendResponse :: StreamId -> Proto.AppendResp -> IO (InsertionResult KurrentStore)
```

**Success Path**:
1. Extract `AppendResp.success`
2. Extract position: `{ commitPosition, preparePosition }`
3. Extract stream revision: `current_revision`
4. Build `KurrentCursor` from position
5. Return `SuccessfulInsertion` with cursor and streamCursors map

**Error Path**:
1. Extract `AppendResp.wrong_expected_version`
2. Parse current revision from error
3. Parse expected revision from error
4. Build `VersionMismatch` record
5. Return `FailedInsertion (ConsistencyError (ConsistencyErrorInfo [versionMismatch]))`

#### StreamElem Unwrapping

**Challenge**: grapesy wraps responses in `StreamElem` type

**Solution**: Pattern match on all constructors
```haskell
respElem <- GRPC.recvOutput call
case respElem of
    StreamElem (Proto resp) -> parseAppendResponse streamId resp
    FinalElem (Proto resp) _trailing -> parseAppendResponse streamId resp
    NoMoreElems _trailing -> pure $ FailedInsertion $ OtherError (...)
```

**Imports Required**:
```haskell
import Network.GRPC.Common.Protobuf (Protobuf, Proto (..))
import Network.GRPC.Common.StreamElem (StreamElem (..))
```

### Test Coverage (5/5 ✅)

1. **KurrentCursor creation**: Unit test for cursor type
2. **newKurrentStore and shutdown**: Connection lifecycle test
3. **Single event insertion**: End-to-end with one event
4. **Multiple events insertion**: Verifies event loop
5. **Consistency check (NoStream on existing stream)**: Optimistic concurrency control

**All tests pass against live KurrentDB instance.**

---

## Phase 2: Multi-Stream Atomic Appends

### Status: ✅ Complete

### Objective
Implement multi-stream atomic event insertion using KurrentDB's `BatchAppend` RPC, ensuring **all-or-nothing ACID semantics** across multiple event streams.

### Critical Discovery: Single-Response Pattern

**Initial Design Assumption**: BatchAppend would return one response per stream (N requests → N responses)

**Actual Behavior**: BatchAppend returns **ONE response for the entire batch** (N requests → 1 response)

**What We Learned**:
- Client sends N `BatchAppendReq` messages (one per stream)
- Last request has `is_final=true` to signal completion
- Server processes the entire batch atomically
- Server returns a **SINGLE** `BatchAppendResp` with:
  - `correlation_id` matching the final request
  - Either `success` (all streams succeeded) OR `error` (batch failed)
- This is true atomic behavior: one result applies to ALL streams

**Implementation Impact**:
- Simplified response collection (no need to track N responses)
- Single validation step (not per-stream)
- Error applies to all streams (true atomicity)

---

## API Analysis

### Comparison: Append vs BatchAppend

#### Single-Stream Append (Phase 1)
- **Pattern**: Client-streaming → Unary response
- **Flow**: `Options → Event₁ → Event₂ → ... → Eventₙ → Response`
- **Semantics**: One stream, one response
- **Atomicity**: Single stream is trivially atomic

#### Multi-Stream BatchAppend (Phase 2)
- **Pattern**: **Bidirectional streaming**
- **Flow**:
  ```
  Client → BatchAppendReq(stream1, corr_id1, events[], is_final=false)
  Client → BatchAppendReq(stream2, corr_id2, events[], is_final=false)
  Client → BatchAppendReq(stream3, corr_id3, events[], is_final=true)

  Server → BatchAppendResp(corr_id1, result)  ← May arrive out of order
  Server → BatchAppendResp(corr_id2, result)
  Server → BatchAppendResp(corr_id3, result)
  ```
- **Semantics**: Multiple streams, one response per stream, **atomicity guarantee**
- **Atomicity**: KurrentDB ensures all streams succeed or all fail

### BatchAppend Protocol Details

#### Request Message (`BatchAppendReq`)
```protobuf
message BatchAppendReq {
  event_store.client.UUID correlation_id = 1;    // Unique per stream
  Options options = 2;                            // Stream + version expectation
  repeated ProposedMessage proposed_messages = 3; // All events for this stream
  bool is_final = 4;                              // True only for last stream

  message Options {
    event_store.client.StreamIdentifier stream_identifier = 1;
    oneof expected_stream_position {
      uint64 stream_position = 2;       // ExactStreamVersion
      google.protobuf.Empty no_stream = 3;        // NoStream
      google.protobuf.Empty any = 4;              // Any
      google.protobuf.Empty stream_exists = 5;    // StreamExists
    }
    oneof deadline_option {
      google.protobuf.Timestamp deadline_21_10_0 = 6;
      google.protobuf.Duration deadline = 7;
    }
  }
}
```

#### Response Message (`BatchAppendResp`)
```protobuf
message BatchAppendResp {
  event_store.client.UUID correlation_id = 1;  // Matches request
  oneof result {
    google.rpc.Status error = 2;               // Failure case
    Success success = 3;                       // Success case
  }

  event_store.client.StreamIdentifier stream_identifier = 4;

  oneof expected_stream_position {
    uint64 stream_position = 5;
    google.protobuf.Empty no_stream = 6;
    google.protobuf.Empty any = 7;
    google.protobuf.Empty stream_exists = 8;
  }

  message Success {
    oneof current_revision_option {
      uint64 current_revision = 1;
      google.protobuf.Empty no_stream = 2;
    }
    oneof position_option {
      event_store.client.AllStreamPosition position = 3;
      google.protobuf.Empty no_position = 4;
    }
  }
}
```

---

## Implementation Details

### Architecture Components

#### 1. Correlation ID Strategy

**Purpose**: Match responses to original streams in bidirectional streaming

**Data Structures**:
```haskell
type CorrelationMap = Map UUID StreamId
type ExpectedSet = Set UUID
```

**Functions**:
```haskell
-- Generate unique correlation ID per stream
assignCorrelations ::
    Map StreamId (StreamWrite [] SomeLatestEvent KurrentStore) ->
    IO (Map UUID (StreamId, StreamWrite [] SomeLatestEvent KurrentStore))
assignCorrelations streams = do
    forM (Map.toList streams) $ \(streamId, streamWrite) -> do
        correlationId <- UUID.nextRandom
        pure (correlationId, (streamId, streamWrite))
```

**Bidirectional Mapping**:
- Forward: `UUID → StreamId` (for response matching)
- Reverse: `StreamId → UUID` (for verification)

---

#### 2. Send Phase

**Function Signature**:
```haskell
sendBatchRequests ::
    Call (Protobuf Streams "batchAppend") ->
    [(UUID, StreamId, StreamWrite [] SomeLatestEvent KurrentStore)] ->
    IO ()
```

**Algorithm**:
```haskell
sendBatchRequests call streamList = do
    let totalStreams = length streamList
    forM_ (zip [1..] streamList) $ \(idx, (corrId, streamId, streamWrite)) -> do
        let isFinal = (idx == totalStreams)
        let request = buildBatchRequest corrId streamId streamWrite isFinal
        if isFinal
            then GRPC.sendFinalInput call request
            else GRPC.sendNextInput call request
```

**Request Building**:
```haskell
buildBatchRequest ::
    UUID ->
    StreamId ->
    StreamWrite [] SomeLatestEvent KurrentStore ->
    Bool ->
    Proto.BatchAppendReq
buildBatchRequest corrId (StreamId streamUUID) (StreamWrite expectedVer events) isFinal = do
    let streamName = Text.encodeUtf8 $ UUID.toText streamUUID

    -- Build options
    let options = defMessage
            & #streamIdentifier .~ (defMessage & #streamName .~ streamName)
            & setBatchExpectedPosition expectedVer

    -- Serialize all events
    proposedMessages <- mapM serializeEvent events

    -- Build request
    defMessage
        & #correlationId .~ (defMessage & #string .~ UUID.toText corrId)
        & #options .~ options
        & #proposedMessages .~ Vector.fromList proposedMessages
        & #isFinal .~ isFinal
```

**Critical**: `is_final=true` **only** for the last stream!

---

#### 3. Receive Phase

**Function Signature**:
```haskell
collectBatchResponses ::
    Set UUID ->                          -- Expected correlation IDs
    Map UUID StreamId ->                 -- Correlation mapping
    Call (Protobuf Streams "batchAppend") ->
    IO (Map StreamId BatchAppendResult)

data BatchAppendResult
    = BatchSuccess
        { position :: KurrentCursor
        , streamRevision :: Maybe StreamVersion
        }
    | BatchError
        { statusCode :: Int32
        , statusMessage :: T.Text
        }
```

**Algorithm**:
```haskell
collectBatchResponses expectedCorrelations correlationMap call = go Map.empty
  where
    go results
        | Map.size results == Set.size expectedCorrelations = pure results
        | otherwise = do
            respElem <- GRPC.recvOutput call
            case respElem of
                StreamElem (Proto resp) -> processResponse resp
                FinalElem (Proto resp) _trailing -> processResponse resp
                NoMoreElems _trailing ->
                    throwIO $ userError "Server closed stream before all responses received"

    processResponse resp = do
        let corrId = extractCorrelationId resp
        unless (corrId `Set.member` expectedCorrelations) $
            throwIO $ userError $ "Unexpected correlation ID: " ++ show corrId

        case Map.lookup corrId correlationMap of
            Nothing -> throwIO $ userError "Correlation ID not in map"
            Just streamId -> do
                result <- parseResult resp
                go (Map.insert streamId result results)
```

**Key Features**:
- Handles responses in **any order**
- Validates correlation IDs
- Collects until all expected responses received
- Proper StreamElem unwrapping

---

#### 4. Response Validation & Error Aggregation

**Function Signature**:
```haskell
validateBatchResults ::
    Map StreamId BatchAppendResult ->
    Either (ConsistencyErrorInfo KurrentStore) (InsertionSuccess KurrentStore)
```

**Algorithm**:
```haskell
validateBatchResults results = do
    let (successes, errors) = partitionResults results

    if null errors
        then Right $ InsertionSuccess
            { finalCursor = maxCursor successes
            , streamCursors = Map.map extractCursor successes
            }
        else Left $ ConsistencyErrorInfo $ map toVersionMismatch errors
  where
    partitionResults = Map.partition isBatchSuccess

    maxCursor successes =
        maximumBy (comparing commitPosition) $
            map (\(BatchSuccess pos _) -> pos) $ Map.elems successes

    toVersionMismatch (streamId, BatchError code msg) =
        VersionMismatch
            { streamId = streamId
            , expectedVersion = parseExpectedFromError msg
            , actualVersion = parseActualFromError msg
            }
```

**Atomicity Guarantee**: If **any** stream fails, return `FailedInsertion` with **all** conflicts.

---

#### 5. Main Multi-Stream Function

**Function Signature**:
```haskell
insertMultiStream ::
    Map StreamId (StreamWrite [] SomeLatestEvent KurrentStore) ->
    IO (InsertionResult KurrentStore)
```

**Algorithm**:
```haskell
insertMultiStream streams = do
    -- 1. Assign correlation IDs
    correlatedStreams <- assignCorrelations streams
    let correlationMap = Map.map fst correlatedStreams
        streamList = Map.toList correlatedStreams
        expectedCorrelations = Set.fromList $ Map.keys correlatedStreams

    -- 2. Open RPC connection
    withResource handle.connectionPool $ \conn ->
        GRPC.withRPC conn def (Proxy @(Protobuf Streams "batchAppend")) $ \call -> do

            -- 3. Send all batch requests
            sendBatchRequests call streamList

            -- 4. Collect all responses (bidirectional)
            results <- collectBatchResponses expectedCorrelations correlationMap call

            -- 5. Validate and aggregate
            case validateBatchResults results of
                Left errorInfo -> pure $ FailedInsertion $ ConsistencyError errorInfo
                Right success -> pure $ SuccessfulInsertion success
```

---

#### 6. Update insertEvents Dispatcher

**Updated Implementation**:
```haskell
instance EventStore KurrentStore where
    type StoreConstraints KurrentStore m = MonadIO m

    insertEvents handle _correlationId (Transaction streams) = liftIO $ do
        case Map.toList streams of
            [] ->
                pure $ SuccessfulInsertion $ InsertionSuccess
                    { finalCursor = KurrentCursor{commitPosition = 0, preparePosition = 0}
                    , streamCursors = Map.empty
                    }
            [(streamId, streamWrite)] ->
                insertSingleStream handle streamId streamWrite
            _multipleStreams ->
                insertMultiStream handle streams  -- ← NEW!
```

**Change**: Replace error message with call to `insertMultiStream`.

---

### RPC Metadata Configuration

**File**: `src/Hindsight/Store/KurrentDB/RPC.hs`

**Add**:
```haskell
-- Metadata type instances for Streams.BatchAppend RPC
type instance RequestMetadata (Protobuf Streams "batchAppend") = NoMetadata
type instance ResponseInitialMetadata (Protobuf Streams "batchAppend") = NoMetadata
type instance ResponseTrailingMetadata (Protobuf Streams "batchAppend") = NoMetadata
```

**Rationale**: KurrentDB uses event-level metadata (in ProposedMessage), not gRPC-level metadata.

---

## Testing Strategy

### Test Cases

#### Test 1: Two-Stream Atomic Success
```haskell
testCase "Multi-stream atomic insert - two new streams" $ do
    handle <- newKurrentStore config

    -- Generate two stream IDs
    stream1 <- StreamId <$> UUID.nextRandom
    stream2 <- StreamId <$> UUID.nextRandom

    -- Create events
    let event1 = makeUserEvent 1
        event2 = makeUserEvent 2
        event3 = makeUserEvent 3

    -- Build transaction
    let transaction = Transaction $ Map.fromList
            [ (stream1, StreamWrite NoStream [event1, event2])
            , (stream2, StreamWrite NoStream [event3])
            ]

    -- Insert
    result <- insertEvents @KurrentStore handle Nothing transaction

    -- Assert: Both streams succeeded
    case result of
        SuccessfulInsertion success -> do
            Map.size success.streamCursors @?= 2
            Map.member stream1 success.streamCursors @?= True
            Map.member stream2 success.streamCursors @?= True
            commitPosition success.finalCursor > 0 @?= True
        FailedInsertion err ->
            assertFailure $ "Expected success but got: " ++ show err

    shutdownKurrentStore handle
```

#### Test 2: Version Conflict on One Stream
```haskell
testCase "Multi-stream with version conflict - atomicity check" $ do
    handle <- newKurrentStore config

    stream1 <- StreamId <$> UUID.nextRandom
    stream2 <- StreamId <$> UUID.nextRandom

    -- Pre-insert to stream1
    let preInsert = Transaction $ Map.singleton stream1
            (StreamWrite NoStream [makeUserEvent 0])
    result1 <- insertEvents @KurrentStore handle Nothing preInsert

    case result1 of
        SuccessfulInsertion _ -> pure ()
        _ -> assertFailure "Pre-insertion failed"

    -- Try to insert with NoStream to stream1 (will fail) and stream2 (new)
    let transaction = Transaction $ Map.fromList
            [ (stream1, StreamWrite NoStream [makeUserEvent 1])  -- ← Conflict!
            , (stream2, StreamWrite NoStream [makeUserEvent 2])
            ]

    result2 <- insertEvents @KurrentStore handle Nothing transaction

    -- Assert: Entire transaction failed
    case result2 of
        FailedInsertion (ConsistencyError (ConsistencyErrorInfo mismatches)) -> do
            -- Verify stream1 is in error list
            any (\vm -> streamId vm == stream1) mismatches @?= True

            -- Verify expected version is NoStream
            case find (\vm -> streamId vm == stream1) mismatches of
                Just vm -> expectedVersion vm @?= NoStream
                Nothing -> assertFailure "stream1 not in mismatches"
        FailedInsertion err ->
            assertFailure $ "Expected ConsistencyError but got: " ++ show err
        SuccessfulInsertion _ ->
            assertFailure "Transaction should have failed atomically"

    -- Verify stream2 was NOT created (atomicity)
    -- (Would need a separate read test to verify)

    shutdownKurrentStore handle
```

#### Test 3: Three Streams with Mixed Versions
```haskell
testCase "Multi-stream with different version expectations" $ do
    handle <- newKurrentStore config

    stream1 <- StreamId <$> UUID.nextRandom  -- New stream
    stream2 <- StreamId <$> UUID.nextRandom  -- Pre-created
    stream3 <- StreamId <$> UUID.nextRandom  -- Pre-created with events

    -- Setup stream2 (empty)
    _ <- insertEvents @KurrentStore handle Nothing $
        Transaction $ Map.singleton stream2
            (StreamWrite NoStream [])

    -- Setup stream3 (with 2 events, revision 1)
    _ <- insertEvents @KurrentStore handle Nothing $
        Transaction $ Map.singleton stream3
            (StreamWrite NoStream [makeUserEvent 10, makeUserEvent 11])

    -- Multi-stream insert with different expectations
    let transaction = Transaction $ Map.fromList
            [ (stream1, StreamWrite NoStream [makeUserEvent 1])
            , (stream2, StreamWrite StreamExists [makeUserEvent 2])
            , (stream3, StreamWrite (ExactStreamVersion (StreamVersion 1)) [makeUserEvent 3])
            ]

    result <- insertEvents @KurrentStore handle Nothing transaction

    -- Assert: All succeeded
    case result of
        SuccessfulInsertion success ->
            Map.size success.streamCursors @?= 3
        FailedInsertion err ->
            assertFailure $ "Expected success but got: " ++ show err

    shutdownKurrentStore handle
```

#### Test 4: Empty Multi-Stream (Edge Case)
```haskell
testCase "Multi-stream with empty event lists" $ do
    -- Should succeed but do nothing
    let transaction = Transaction $ Map.fromList
            [ (stream1, StreamWrite NoStream [])
            , (stream2, StreamWrite NoStream [])
            ]

    result <- insertEvents @KurrentStore handle Nothing transaction

    case result of
        SuccessfulInsertion success ->
            Map.size success.streamCursors @?= 2
        FailedInsertion err ->
            assertFailure $ "Empty streams should succeed: " ++ show err
```

---

## Error Handling

### Error Scenarios & Responses

| Scenario | Server Behavior | Client Handling |
|----------|-----------------|-----------------|
| **All streams succeed** | All `BatchAppendResp.success` | Return `SuccessfulInsertion` with cursors |
| **Version conflict (one stream)** | One `BatchAppendResp.error` with `FAILED_PRECONDITION` | Return `ConsistencyError` with all conflicts |
| **Version conflict (multiple streams)** | Multiple `BatchAppendResp.error` | Aggregate all into `ConsistencyErrorInfo` |
| **Network error mid-stream** | Connection drop during send/receive | Wrap in `OtherError` with exception info |
| **Missing response** | Fewer responses than expected | Return `OtherError` ("Missing responses for streams: ...") |
| **Unexpected correlation ID** | Response with unknown correlation_id | Return `OtherError` ("Unexpected correlation ID") |
| **Server abort** | `google.rpc.Status` with `ABORTED` | Parse status code/message into appropriate error |
| **Timeout** | No response within deadline | Return `OtherError` ("BatchAppend timeout") |

### Status Code Mapping

```haskell
parseGrpcStatus :: google.rpc.Status -> EventStoreError KurrentStore
parseGrpcStatus status = case status.code of
    9  -> -- FAILED_PRECONDITION: Version conflict
        ConsistencyError (parseVersionConflict status.message)
    14 -> -- UNAVAILABLE: Server unavailable
        OtherError $ ErrorInfo
            { errorMessage = "KurrentDB unavailable: " <> status.message
            , exception = Nothing
            }
    _ -> -- Other codes
        OtherError $ ErrorInfo
            { errorMessage = "gRPC error (code " <> show status.code <> "): " <> status.message
            , exception = Nothing
            }
```

### Error Aggregation Logic

**Principle**: **Any failure → entire transaction fails**

```haskell
aggregateErrors :: Map StreamId BatchAppendResult -> EventStoreError KurrentStore
aggregateErrors results =
    let failures = Map.filter isBatchError results
    in if Map.null failures
        then error "aggregateErrors called with no failures"
        else ConsistencyError $ ConsistencyErrorInfo $ map toVersionMismatch $ Map.toList failures
  where
    toVersionMismatch (streamId, BatchError code msg) =
        VersionMismatch
            { streamId = streamId
            , expectedVersion = extractExpectedFromError msg
            , actualVersion = extractActualFromError msg
            }
```

---

## Future Work

### Phase 3: Event Subscriptions

**Goal**: Implement `subscribe` function for real-time event streams

**API**: `Streams.Read` RPC with subscription options

**Challenges**:
- Long-lived bidirectional streams
- Checkpoint management
- Reconnection logic
- Backpressure handling

### Phase 4: Projections Integration

**Goal**: Integrate with Hindsight projection system

**Features**:
- Subscribe to KurrentDB event stream
- Feed events to projection handlers
- Persist projection state to PostgreSQL
- Handle subscription failures gracefully

### Phase 5: Performance Optimization

**Potential Improvements**:
- Batch event serialization
- Connection pool tuning
- Parallel stream processing
- Event caching

### Phase 6: Advanced Features

**Possible Additions**:
- Stream deletion support
- Tombstone handling
- Scavenging integration
- Custom metadata support
- TLS/authentication configuration

---

## References

### Documentation
- [KurrentDB gRPC API](https://docs.kurrent.io/clients/grpc/)
- [grapesy Documentation](https://hackage.haskell.org/package/grapesy)
- [proto-lens User Guide](https://hackage.haskell.org/package/proto-lens)

### Protobuf Specifications
- `proto/streams.proto` - Streams service definition
- `proto/shared.proto` - Common types (UUID, StreamIdentifier, etc.)
- `proto/status.proto` - Status codes and error types

### Related Code
- `hindsight-core/src/Hindsight/Store.hs` - EventStore type class
- `hindsight-postgresql-store/` - Reference PostgreSQL implementation
- `hindsight-memory-store/` - Reference in-memory implementation

---

## Changelog

### 2025-11-01

#### Phase 1: Single-Stream Appends ✅
- Full EventStore instance implementation
- All 5 tests passing
- Proper error handling and consistency checks
- Connection pooling with resource-pool
- Proto wrapper handling for grapesy

#### Phase 2: Multi-Stream Atomic Appends ✅
- **Implemented**: `insertMultiStream` with BatchAppend RPC
- **Discovered**: Single-response pattern (not multi-response as originally designed)
- **Implemented**: All helper functions:
  - `assignCorrelations` - UUID generation per stream
  - `buildBatchRequest` - Request message construction
  - `sendBatchRequests` - Send phase with is_final flag
  - `collectBatchResponse` - Single response collection
  - `convertBatchResponse` - Atomic result application
- **Updated**: `insertEvents` dispatcher to route multi-stream transactions
- **Tests**: All 8 tests passing (3 multi-stream tests added)
- **Re-enabled**: Version mismatch test after investigation confirmed BatchAppend enforces expectations
- **Commits**:
  - `4cd714e` - Phase 2 implementation
  - `5f6712c` - Re-enabled version mismatch test

#### Investigation: BatchAppend Version Mismatch Handling
- **Question**: Was the disabled test bogus or is there a bug?
- **Method**: Added debug tracing to inspect raw KurrentDB responses
- **Discovery**: KurrentDB BatchAppend DOES enforce version expectations correctly
  - Returns `ALREADY_EXISTS` error with "WrongExpectedVersion" message
  - Does NOT populate `expected_stream_position` field (unlike single Append)
  - Error conveyed through standard gRPC `error { code, message }` status
- **Result**: Re-enabled test, all 8 tests passing

### Key Achievements
- ✅ Complete EventStore implementation (single + multi-stream)
- ✅ All 8 tests passing (5 Phase 1 + 3 Phase 2)
- ✅ Atomic multi-stream appends with version enforcement
- ✅ Proper error handling for consistency violations
- ✅ Production-ready connection pooling
- ✅ Comprehensive test coverage

### Next Steps: Phase 3
1. Event subscriptions (`Streams.Read` RPC)
2. Projection integration
3. Catchup subscriptions
4. Stream metadata queries

---

**End of Design Document**
