{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}

{- | Test runner infrastructure for event store backends

This module provides the test runner infrastructure and wires together
all test suites from specialized test modules.
-}
module Test.Hindsight.Store.TestRunner (
    -- * Test Infrastructure
    EventStoreTestRunner (..),
    runTest,
    runMultiInstanceTest,
    repeatTest,

    -- * Generic Test Suites
    genericEventStoreTests,
    multiInstanceTests,
)
where

import Hindsight.Store (BackendHandle, Cursor, EventStore, StoreConstraints)
import Test.Hindsight.Store.BasicTests (basicTests)
import Test.Hindsight.Store.ConsistencyTests (consistencyTests)
import Test.Hindsight.Store.CursorTests (cursorTests)
import Test.Hindsight.Store.MultiInstanceEventOrderingTests (multiInstanceEventOrderingTests)
import Test.Hindsight.Store.StreamVersionTests (streamVersionTests)
import Test.Hindsight.Store.TestRunner.Types (EventStoreTestRunner (..))
import Test.Tasty
import Test.Tasty.HUnit (Assertion, testCase)

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

-- * Test Infrastructure Helpers

-- | Repeat a test N times (useful for detecting flaky tests)
repeatTest :: Int -> TestName -> Assertion -> TestTree
repeatTest n name assertion =
    testGroup (name <> " x" <> show n) $
        replicate n $
            testCase name assertion

-- | Run a single-instance test with the test runner
runTest :: EventStoreTestRunner backend -> (BackendHandle backend -> IO ()) -> IO ()
runTest runner action = withStore runner action

-- | Run a multi-instance test with the test runner
runMultiInstanceTest :: EventStoreTestRunner backend -> Int -> ([BackendHandle backend] -> IO ()) -> IO ()
runMultiInstanceTest runner n action = withStores runner n action
