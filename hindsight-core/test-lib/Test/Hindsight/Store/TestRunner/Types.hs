{-# LANGUAGE RankNTypes #-}

{- | Core types for event store test infrastructure

This module contains only type definitions to avoid circular dependencies.
-}
module Test.Hindsight.Store.TestRunner.Types (
    EventStoreTestRunner (..),
) where

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
