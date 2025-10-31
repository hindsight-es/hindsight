{-# LANGUAGE RankNTypes #-}

{- | Test runner infrastructure for event store backends

This module provides only the core test infrastructure type.
Test suite composition and convenience exports are in Test.Hindsight.Store.
-}
module Test.Hindsight.Store.TestRunner (
    EventStoreTestRunner (..),
)
where

import Hindsight.Store (BackendHandle)

-- | Test runner for event store tests
data EventStoreTestRunner backend = EventStoreTestRunner
    { withStore :: forall a. (BackendHandle backend -> IO a) -> IO ()
    -- ^ For single-instance tests: provides one handle to the backend
    , withStores :: forall a. Int -> ([BackendHandle backend] -> IO a) -> IO ()
    {- ^ For multi-instance tests: provides N handles to the same backend storage
    Simulates multiple processes accessing the same backend
    -}
    }
