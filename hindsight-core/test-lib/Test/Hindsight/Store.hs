{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}

{- | Unified test suite API for event store backends

This module provides a single import point for backend test writers.
It re-exports all test infrastructure, test suites, and utilities.

= Typical Usage

> import Test.Hindsight.Store
>
> myStoreRunner :: EventStoreTestRunner MyBackend
> myStoreRunner = EventStoreTestRunner { ... }
>
> tests = testGroup "My Backend Tests"
>   [ testGroup "Generic Tests" (genericEventStoreTests myStoreRunner)
>   , testGroup "Multi-Instance Tests" (multiInstanceTests myStoreRunner)
>   , testGroup "Stress Tests" (stressTests myStoreRunner)
>   , propertyTests myStoreRunner
>   , testGroup "Ordering Tests" (orderingTests myStoreRunner)
>   ]
-}
module Test.Hindsight.Store (
    -- * Test Infrastructure
    EventStoreTestRunner (..),

    -- * Test Suite Composition
    genericEventStoreTests,
    multiInstanceTests,

    -- * Individual Test Suites
    basicTests,
    consistencyTests,
    cursorTests,
    streamVersionTests,
    multiInstanceEventOrderingTests,
    orderingTests,
    propertyTests,
    stressTests,

    -- * Test Utilities
    module Test.Hindsight.Store.Common,
)
where

import Hindsight.Store (Cursor, EventStore, StoreConstraints)
import Test.Hindsight.Store.BasicTests (basicTests)
import Test.Hindsight.Store.Common
import Test.Hindsight.Store.ConsistencyTests (consistencyTests)
import Test.Hindsight.Store.CursorTests (cursorTests)
import Test.Hindsight.Store.MultiInstanceEventOrderingTests (multiInstanceEventOrderingTests)
import Test.Hindsight.Store.OrderingTests (orderingTests)
import Test.Hindsight.Store.PropertyTests (propertyTests)
import Test.Hindsight.Store.StreamVersionTests (streamVersionTests)
import Test.Hindsight.Store.StressTests (stressTests)
import Test.Hindsight.Store.TestRunner (EventStoreTestRunner (..))
import Test.Tasty

-- * Test Suite Composition

-- | Common event store test cases split into focused test groups
genericEventStoreTests ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO, Show (Cursor backend), Ord (Cursor backend)) =>
    EventStoreTestRunner backend ->
    [TestTree]
genericEventStoreTests runner =
    [ testGroup "Basic Tests" (basicTests runner)
    , testGroup "Stream Version Tests" (streamVersionTests runner)
    , testGroup "Consistency Tests" (consistencyTests runner)
    , testGroup "Per-Stream Cursor Tests" (cursorTests runner)
    ]

-- | Multi-instance test cases (for backends that support cross-process subscriptions)
multiInstanceTests ::
    forall backend.
    (EventStore backend, StoreConstraints backend IO, Show (Cursor backend), Ord (Cursor backend)) =>
    EventStoreTestRunner backend ->
    [TestTree]
multiInstanceTests runner = multiInstanceEventOrderingTests runner
