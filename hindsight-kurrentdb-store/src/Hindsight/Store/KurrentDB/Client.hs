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
    serverFromConfig,
) where

import Data.ByteString (ByteString)
import Data.ByteString.Char8 qualified as BS
import Data.Default (def)
import Data.Pool (Pool, destroyAllResources, newPool, setNumStripes)
import Data.Pool qualified as Pool
import Hindsight.Store.KurrentDB.Types (KurrentConfig (..), KurrentHandle (..))
import Network.GRPC.Client (Connection)
import Network.GRPC.Client qualified as GRPC
import Network.Socket (PortNumber)

{- | Create a new KurrentDB store handle with connection pooling.

Creates a resource pool of gRPC connections for fault tolerance and
proper lifecycle management.

Pool configuration:
- Size: 10 connections (similar to PostgreSQL backend)
- Timeout: 60 seconds
- Stripe count: 1 (connection creation is serialized)
-}
newKurrentStore :: KurrentConfig -> IO KurrentHandle
newKurrentStore config = do
    -- Create server address
    let server =
            if config.secure
                then error "TLS not yet implemented"
                else
                    GRPC.ServerInsecure $
                        GRPC.Address
                            { GRPC.addressHost = BS.unpack config.host  -- Convert ByteString to String
                            , GRPC.addressPort = fromIntegral config.port  -- Convert Int to PortNumber
                            , GRPC.addressAuthority = Nothing
                            }

    -- Create connection pool using modern resource-pool API
    -- Pool parameters: create function, destroy function, idle timeout, max resources
    pool <-
        newPool $
            setNumStripes (Just 1) $  -- 1 stripe is fine for gRPC
                Pool.defaultPoolConfig
                    (GRPC.openConnection def server)  -- Create connection
                    GRPC.closeConnection  -- Destroy connection
                    60  -- Idle timeout in seconds
                    10  -- Max connections in pool

    pure $ KurrentHandle{config, connectionPool = pool}

{- | Shutdown the KurrentDB store and close all connections.

Destroys the connection pool, closing all active connections.
-}
shutdownKurrentStore :: KurrentHandle -> IO ()
shutdownKurrentStore handle = do
    destroyAllResources handle.connectionPool

{- | Create server address from config.

Exposed for subscriptions which need dedicated connections (not from pool).
gRPC streaming subscriptions hold connections for their lifetime, so they
should not borrow from the shared pool to avoid exhausting it.
-}
serverFromConfig :: KurrentConfig -> GRPC.Server
serverFromConfig config =
    if config.secure
        then error "TLS not yet implemented"
        else
            GRPC.ServerInsecure $
                GRPC.Address
                    { GRPC.addressHost = BS.unpack config.host
                    , GRPC.addressPort = fromIntegral config.port
                    , GRPC.addressAuthority = Nothing
                    }
