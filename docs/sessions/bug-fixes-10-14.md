# Subscription System Bug Investigation & Fix Session

**Date**: 2025-10-14
**Session Type**: Bug Investigation & TDD Fixes
**Trigger**: TODO comment investigation (`TODO: Implement proper cancellation using async library`)

## Executive Summary

Investigation of a seemingly simple TODO comment about async cancellation revealed **4 production bugs** in the event subscription system across all storage backends. These bugs range from resource leaks to API inconsistencies and silent failures.

This session uses Test-Driven Development methodology with store-agnostic property tests to ensure consistent behavior across all backends (Memory, Filesystem, PostgreSQL).

---

## Bugs Discovered

### Bug #1: Resource Leak in Memory/Filesystem Stores - **CRITICAL**

**Location**:
- `hindsight/src/Hindsight/Store/Internal/Common.hs:384-390`
- `hindsight-memory-store/src/Hindsight/Store/Memory/Internal.hs:384-390`

**Code**:
```haskell
-- TODO: Implement proper cancellation using async library
withRunInIO $ \runInIO -> do
  void $ forkIO $ runInIO $ loop startSeq
  pure $
    SubscriptionHandle
      { cancel = pure () -- No-op for now
      }
```

**The Problem**:
1. Subscriptions create threads using raw `forkIO`
2. The `ThreadId` is immediately discarded with `void`
3. The returned `cancel` action is a complete no-op (`pure ()`)
4. **There is no way to stop these threads**

**Impact**:
- **Thread Leaks**: Every subscription creates an unkillable thread
- **Memory Leaks**: Matcher closures and loop state can't be GC'd
- **Test Pollution**: Test suites accumulate zombie threads
- **Shutdown Problems**: Applications can't shut down cleanly
- **Resource Exhaustion**: Long-running apps with subscription churn will accumulate threads

**Severity**: CRITICAL - This affects any code that creates and destroys subscriptions

**Expected Behavior**:
```haskell
import Control.Concurrent.Async (async, cancel)

withRunInIO $ \runInIO -> do
  workerThread <- async $ runInIO $ loop startSeq
  pure $
    SubscriptionHandle
      { cancel = cancel workerThread  -- Actually cancels!
      }
```

---

### Bug #2: Silent Failures in Memory/Filesystem Stores - **HIGH**

**Location**: Same as Bug #1 - the subscription loop in forked threads

**The Problem**:
When an event handler throws an exception inside the subscription loop:
1. The forked thread dies silently
2. No exception is propagated to the parent
3. No logging occurs
4. The subscription just stops processing events
5. **Nobody knows anything went wrong**

**Impact**:
- **Debugging Nightmare**: "Why did my projection stop updating?"
- **Data Inconsistency**: Projections silently stop, becoming stale
- **Production Incidents**: No alerts, no logs, just silent failure

**Severity**: HIGH - Makes debugging subscription failures nearly impossible

**Expected Behavior**:
- Use `async` with `link` for exception propagation, OR
- Catch exceptions and log them with context, OR
- Provide the `Async` handle so callers can `wait`/`waitCatch`

---

### Bug #3: PostgreSQL Backend Ignores `Stop` Result - **MEDIUM**

**Location**: `hindsight-postgresql-store/src/Hindsight/Store/PostgreSQL/Events/Subscription.hs:263`

**Code**:
```haskell
forM_ matching $ \eventData -> do
  case Map.lookup (fromIntegral eventData.eventVersion) (parseMapFromProxy proxy) of
    Just parser ->
      case Aeson.parseEither parser eventData.payload of
        Right parsedPayload -> do
          let envelope = EventWithMetadata { ... }
          _ <- handler envelope  -- DISCARDING THE RESULT!
          pure ()
```

**The Problem**:
The `handler` returns `SubscriptionResult` which can be:
- `Continue` - keep processing
- `Stop` - stop the subscription

PostgreSQL's `processEventBatch` **completely ignores** this return value by:
1. Discarding it with `_`
2. Never checking if `Stop` was returned
3. Continuing to process all remaining events in the batch
4. Fetching and processing more batches forever

**Comparison with Memory/Filesystem**:
```haskell
-- Memory/Filesystem DO check Stop:
result <- processEvents matcher events
case result of
  Stop -> pure ()      -- Exit the loop
  Continue -> loop maxSeq  -- Continue
```

**Impact**:
- **API Inconsistency**: `Stop` works in some backends but not others
- **Broken Contracts**: The `SubscriptionResult` type is meaningless in PostgreSQL
- **User Confusion**: Same code behaves differently depending on backend

**Severity**: MEDIUM - Violates the EventStore abstraction, but workaround exists (call `cancel`)

**Expected Behavior**:
PostgreSQL should check the handler result and exit the worker loop when `Stop` is returned, just like Memory/Filesystem stores do.

---

### Bug #4: Exception Visibility in PostgreSQL - **MEDIUM**

**Location**: `hindsight-postgresql-store/src/Hindsight/Store/PostgreSQL/Events/Subscription.hs`

**The Problem**:
PostgreSQL uses `async` properly for cancellation:
```haskell
workerThread <- async $ runInIO $ workerLoop ...
pure $ Store.SubscriptionHandle
  { cancel = cancel workerThread }
```

However:
1. The `Async` handle is not exposed to the caller
2. Exceptions in the worker thread are invisible unless you explicitly `wait` on the `Async`
3. The standard `subscribe` function doesn't give you access to the `Async`
4. There's a `subscribeWithRetryAndAsync` variant that returns the `Async`, but it's not the default

**Impact**:
- **Silent Crashes**: Subscription crashes are invisible
- **No Monitoring**: Can't detect subscription failures
- **Different from Memory/Filesystem**: Those backends have exception propagation issues too, but PostgreSQL is "better but still not good enough"

**Severity**: MEDIUM - Workaround exists (use `subscribeWithRetryAndAsync`), but not discoverable

**Expected Behavior**:
- Either: Expose the `Async` handle in the standard API
- Or: Use `link` to propagate exceptions to parent
- Or: Add comprehensive logging of subscription failures

---

## Test Strategy

We use **store-agnostic property tests** in the test-lib component to ensure consistent behavior across all backends.

### Property: Subscriptions Must Honor `Stop` Result

**Test Design**:
```haskell
-- Test events
data CounterInc = CounterInc deriving (...)
data CounterStop = CounterStop deriving (...)

-- Test sequence
events = [CounterInc, CounterInc, CounterStop, CounterInc, CounterInc]

-- Handler behavior
handler :: IORef Int -> EventEnvelope event backend -> IO SubscriptionResult
handler ref (CounterInc envelope) = do
  modifyIORef' ref (+1)
  pure Continue
handler ref (CounterStop envelope) = do
  pure Stop  -- Should stop subscription here

-- Assertion
finalCount <- readIORef ref
finalCount `shouldBe` 2  -- Stopped after 2 Incs, before additional Incs
```

**Expected Results**:
- Memory Store: ✅ PASS (respects Stop)
- Filesystem Store: ✅ PASS (respects Stop)
- PostgreSQL Store: ❌ FAIL (ignores Stop, processes all 4 Incs)

This demonstrates Bug #3 and provides a regression test.

### Property: Subscription Cancellation Must Work

**Test Design**:
```haskell
-- Create subscription
handle <- subscribe store matcher selector

-- Cancel it
cancel handle

-- Thread should terminate
-- (How to verify? Check that ThreadId is gone? That's tricky...)
```

**Current Status**:
- Memory/Filesystem: ❌ FAIL (cancel is no-op)
- PostgreSQL: ✅ PASS (cancel works via async)

### Property: Exception Handling Should Be Visible

**Test Design**:
```haskell
-- Handler that throws
handler event = do
  when (isErrorEvent event) $ throwIO MyException
  pure Continue

-- What happens?
-- Should: Log error, or propagate exception, or expose failure somehow
-- Currently: Silently dies (all backends)
```

This needs more investigation to determine desired behavior.

---

## Fix Implementation Plan

### Phase 1: Write Failing Test for Bug #3
1. Add test to test-lib component
2. Run against all backends
3. Confirm Memory/Filesystem pass, PostgreSQL fails

### Phase 2: Fix PostgreSQL to Honor Stop
1. Modify `processEventBatch` to check `SubscriptionResult`
2. Exit worker loop on `Stop`
3. Re-run test → all backends should pass

### Phase 3: Fix Memory/Filesystem Resource Leak
1. Import `Control.Concurrent.Async`
2. Replace `forkIO` with `async`
3. Wire `cancel` to `async`'s cancel
4. Run tests to ensure no regression

### Phase 4: Address Exception Handling
1. Add exception catching around loops
2. Log failures with context
3. Consider exposing `Async` handle or using `link`

### Phase 5: Comprehensive Testing
1. Run full test suite
2. Verify all store-agnostic tests pass
3. Manual testing of cancellation

---

## Success Criteria

- [ ] All store-agnostic property tests pass for all backends
- [ ] Memory/Filesystem subscriptions are properly cancellable
- [ ] PostgreSQL subscriptions honor `Stop` result
- [ ] Subscription failures are visible (logged or propagated)
- [ ] No thread leaks in test suite
- [ ] All TODO comments removed

---

## Lessons Learned

1. **TODO comments often hide bigger problems** - What looked like a simple async upgrade revealed architectural inconsistencies
2. **Backend consistency is crucial** - Store abstractions must work the same way everywhere
3. **Property tests catch abstraction violations** - Store-agnostic tests are essential for polymorphic interfaces
4. **Resource management requires structured concurrency** - `forkIO` is almost always the wrong choice
5. **Exception handling must be explicit** - Silent failures are production time bombs

---

## Test Results

### Phase 2 Complete: Store-Agnostic Stop Test

**Test Implementation**: `testSubscriptionStopBehavior` in `test-lib/Test/Hindsight/Store/TestRunner.hs`

**Test Design**:
- Events inserted: `[Inc, Inc, Stop, Inc, Inc]`
- Handler increments counter on `Inc`, returns `Stop` on `Stop` event
- Expected result: counter = 2 (stops before processing events after Stop)

**Results**:

| Backend    | Result | Counter Value | Status |
|-----------|--------|---------------|---------|
| Memory     | ✅ PASS | 2            | Correctly honors Stop |
| Filesystem | ✅ PASS | 2            | Correctly honors Stop |
| PostgreSQL | ❌ FAIL | 4            | **Processes events after Stop!** |

**Error from PostgreSQL test**:
```
expected: 2
but got: 4
```

This confirms Bug #3: PostgreSQL's subscription system completely ignores the `SubscriptionResult` returned by handlers.

---

---

### Phase 3 Complete: Bug #3 Fixed (PostgreSQL Stop Handling)

**Fix Applied**: Rewrote `processEventBatch` in `hindsight-postgresql-store/src/Hindsight/Store/PostgreSQL/Events/Subscription.hs`

**Problem**: The original implementation used `partition` to split events by type, which **lost event ordering**. Events were grouped as `[Inc, Inc, Inc, Inc]` and `[Stop]`, processing all Incs before checking Stop.

**Solution**: Process events **sequentially** in order, checking the Stop flag after each event:
- Try each event against all matchers in order
- Immediately check `SubscriptionResult` after each handler
- Exit loop when `Stop` is encountered
- Update worker loops to respect the `shouldContinue` flag

**Test Result After Fix**:
```
PostgreSQL Store + Projections Tests
  Generic Store Tests
    Basic Tests
      Subscription Honors Stop Result: ✅ OK (0.76s)

All 43 tests passed
```

---

### Phase 4 Complete: Bug #1 Fixed (Resource Leaks)

**Fix Applied**: Replace `forkIO` with `async` in Memory and Filesystem stores

**Files Modified**:
- `hindsight/src/Hindsight/Store/Internal/Common.hs`
- `hindsight-memory-store/src/Hindsight/Store/Memory/Internal.hs`
- `hindsight-memory-store/hindsight-memory-store.cabal` (added `async` dependency)

**Changes**:
```haskell
-- Before (BROKEN):
import Control.Concurrent (forkIO)
import Control.Monad (void, when)
...
withRunInIO $ \runInIO -> do
  void $ forkIO $ runInIO $ loop startSeq  -- ThreadId lost!
  pure $ SubscriptionHandle { cancel = pure () }  -- No-op!

-- After (FIXED):
import Control.Concurrent.Async (async, cancel)
import Control.Monad (when)
...
withRunInIO $ \runInIO -> do
  workerThread <- async $ runInIO $ loop startSeq
  pure $ SubscriptionHandle { cancel = cancel workerThread }  -- Actually cancels!
```

**Test Results**:
```
Memory Store: All 43 tests passed (0.11s)
Filesystem Store: All tests passed
PostgreSQL Store: All 43 generic tests passed (24.54s)
```

---

## Final Summary

### Bugs Fixed

| Bug | Description | Status | Backends Affected |
|-----|-------------|--------|-------------------|
| #1  | Resource leak (thread cancellation) | ✅ FIXED | Memory, Filesystem |
| #2  | Silent failures (exception handling) | ⏸️ DEFERRED | All backends |
| #3  | PostgreSQL ignores Stop result | ✅ FIXED | PostgreSQL |
| #4  | Exception visibility | ⏸️ DEFERRED | All backends |

**Bugs #2 and #4 Deferred**: Exception handling improvements require broader design decisions about error propagation strategy. Current behavior (silent death) is documented but needs future work.

### Files Changed

**Core Fixes**:
- `test-lib/Test/Hindsight/Store/Common.hs` - Added Counter events for testing
- `test-lib/Test/Hindsight/Store/TestRunner.hs` - Added `testSubscriptionStopBehavior`
- `hindsight/src/Hindsight/Store/Internal/Common.hs` - Async cancellation
- `hindsight-memory-store/src/Hindsight/Store/Memory/Internal.hs` - Async cancellation
- `hindsight-memory-store/hindsight-memory-store.cabal` - Added `async` dependency
- `hindsight-postgresql-store/src/Hindsight/Store/PostgreSQL/Events/Subscription.hs` - Fixed Stop handling

**Documentation**:
- `docs/sessions/bug-fixes-10-14.md` - This session report

### Test Results

**All Store-Agnostic Tests**: ✅ PASS

| Backend    | Generic Tests | Stop Test | Status |
|-----------|---------------|-----------|---------|
| Memory     | 43/43 ✅     | ✅ PASS   | All tests passed (0.11s) |
| Filesystem | 43/43 ✅     | ✅ PASS   | All tests passed |
| PostgreSQL | 43/43 ✅     | ✅ PASS   | All tests passed (24.54s) |

**Key Achievement**: The new `testSubscriptionStopBehavior` test now passes across ALL backends, proving consistent `SubscriptionResult` handling.

### Lessons Learned (Final)

1. **Event ordering matters** - `partition` loses causality; process sequentially
2. **Test first, fix second** - The failing test made the bug obvious
3. **Property tests find abstraction violations** - Stop behavior is a store contract
4. **Resource management requires structured concurrency** - `async` > `forkIO`
5. **TODOs hide technical debt** - One comment revealed 4 production bugs

---

---

## Phase 5: Exception Handling with Event Context (Bugs #2 and #4)

### Design Decision

**User Requirement**: "Kill the subscription and raise the error. This should NOT happen."

Handler exceptions represent bugs in the event processing code. When they occur:
1. The subscription should die immediately (fail-fast)
2. The error must include rich context: cursor, event name, stream ID
3. Higher-level code (projection managers) can implement retry logic on top
4. No silent failures - exceptions must be visible and debuggable

### Additional Requirements

From follow-up discussion:
- The cursor of the event that failed must be returned as part of the error
- The event name should be included as well

### Implementation Plan

#### 1. Define HandlerException Type

Add to `Hindsight.Store` module:

```haskell
-- | Exception thrown when an event handler fails during subscription processing
-- Wraps the original exception with event context for debugging
data HandlerException backend = HandlerException
  { originalException :: SomeException      -- The actual exception that was thrown
  , failedEventPosition :: Cursor backend   -- Where in the event log it failed
  , failedEventName :: Text                 -- The name of the event that failed
  , failedEventStreamId :: StreamId         -- Which stream the event came from
  } deriving (Typeable)

instance (Typeable backend, Show (Cursor backend)) => Show (HandlerException backend)
instance (Typeable backend, Show (Cursor backend)) => Exception (HandlerException backend)
```

#### 2. Enrich Exceptions in Event Processing

**Memory/Filesystem** (`Common.hs`):
- Wrap handler calls in `catch` that re-throws with event context
- Use `UnliftIO.Exception.catch` for MonadUnliftIO compatibility

**PostgreSQL** (`Subscription.hs`):
- Same approach in `processEventBatch` where handlers are invoked

#### 3. Exception Propagation

- The enriched exception propagates up the async worker thread
- Async handle captures the exception (already works with current `async` implementation)
- Users can access via `wait`/`waitCatch` on the Async handle

#### 4. Testing Strategy

Add test to `test-lib`:
- Handler that throws on a specific event type
- Verify subscription dies
- Verify exception includes correct cursor, event name, stream ID
- Store-agnostic property test (runs on all backends)

#### 5. Files to Modify

1. `hindsight/src/Hindsight/Store.hs` - Add `HandlerException` type and export it
2. `hindsight/src/Hindsight/Store/Internal/Common.hs` - Enrich exceptions in `processEventThroughMatchers`
3. `hindsight-postgresql-store/src/Hindsight/Store/PostgreSQL/Events/Subscription.hs` - Enrich exceptions in `processEventBatch`
4. `test-lib/Test/Hindsight/Store/TestRunner.hs` - Add exception handling property test
5. `test-lib/Test/Hindsight/Store/Common.hs` - Add test event type that triggers exceptions

### Status

**Current Phase**: 🚧 Implementation in progress

---

## Overall Status

**Bugs Fixed**:
- Bug #1: ✅ Resource leak (thread cancellation) - COMPLETE
- Bug #2: 🚧 Silent failures (exception handling) - IN PROGRESS
- Bug #3: ✅ PostgreSQL ignores Stop result - COMPLETE
- Bug #4: 🚧 Exception visibility - IN PROGRESS

**Remaining Work**: Implementing exception enrichment with event context
**Ready to Commit**: No (work in progress)
