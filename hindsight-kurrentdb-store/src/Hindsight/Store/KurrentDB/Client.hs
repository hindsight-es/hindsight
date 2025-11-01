{- |
Module      : Hindsight.Store.KurrentDB.Client
Description : gRPC client wrapper for KurrentDB
Copyright   : (c) 2025
License     : BSD3
Maintainer  : gael@hindsight.events
Stability   : experimental

Low-level gRPC client operations for KurrentDB.
-}
module Hindsight.Store.KurrentDB.Client (
    newKurrentStore,
    shutdownKurrentStore,
) where

import Data.ByteString (ByteString)
import Hindsight.Store.KurrentDB.Types (KurrentHandle (..))
-- import Network.GRPC.Client qualified as GRPC

{- | Create a new KurrentDB store handle.

Connection string format: esdb://host:port?tls=false

Parses connection string and establishes gRPC connection to KurrentDB.
-}
newKurrentStore :: ByteString -> IO KurrentHandle
newKurrentStore _connStr = do
    -- TODO: Initialize actual gRPC connection
    -- For now, this is a stub that will be implemented in Phase 1
    error "newKurrentStore: Not yet implemented. gRPC connection will be added in Phase 1."

{- | Shutdown the KurrentDB store and close connections.

Closes the gRPC connection to KurrentDB.
-}
shutdownKurrentStore :: KurrentHandle -> IO ()
shutdownKurrentStore _handle = do
    -- TODO: Close gRPC connection
    pure ()
