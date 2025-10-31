{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}

{- |
Module      : Hindsight.Store.PostgreSQL.Events.Concurrency
Description : Version validation for PostgreSQL event store
Copyright   : (c) 2025
License     : BSD3
Maintainer  : gael@hindsight.events
Stability   : internal

This module implements optimistic concurrency control for the PostgreSQL
backend by validating version expectations before event insertion.

Version checks use row-level locking to ensure consistency while minimizing
contention between concurrent writers to different streams.
-}
module Hindsight.Store.PostgreSQL.Events.Concurrency (
    checkVersions,
)
where

import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Profunctor (dimap)
import Data.UUID (UUID)
import Hasql.Decoders qualified as D
import Hasql.Decoders qualified as Decoders
import Hasql.Encoders qualified as E
import Hasql.Encoders qualified as Encoders
import Hasql.Statement qualified as Statement
import Hasql.TH (maybeStatement, singletonStatement)
import Hasql.Transaction qualified as HasqlTransaction
import Hindsight.Events (SomeLatestEvent)
import Hindsight.Store
import Hindsight.Store.PostgreSQL.Core.Types

-- | Get current version of a stream (global cursor)
getCurrentVersionStatement :: Statement.Statement UUID (Maybe (Cursor SQLStore))
getCurrentVersionStatement =
    dimap id (fmap (uncurry SQLCursor)) $
        [maybeStatement|
    select
      latest_transaction_xid8::text::bigint :: int8,
      latest_seq_no :: int4
    from stream_heads
    where stream_id = $1 :: uuid
  |]

-- | Get current stream version (local cursor)
getCurrentStreamVersionStatement :: Statement.Statement UUID (Maybe StreamVersion)
getCurrentStreamVersionStatement =
    dimap id (fmap StreamVersion) $
        [maybeStatement|
    select 
      stream_version :: int8
    from stream_heads
    where stream_id = $1 :: uuid
  |]

-- | Check if a stream exists
streamExistsStatement :: Statement.Statement UUID Bool
streamExistsStatement =
    [singletonStatement|
    select exists (
      select 1
      from stream_heads
      where stream_id = $1 :: uuid
    ) :: bool
  |]

{- | Acquire an advisory lock on a stream for the duration of the transaction.

Uses PostgreSQL's advisory locks to prevent concurrent modifications
to the same stream while allowing parallel writes to different streams.
-}
lockStreamStatement :: Statement.Statement UUID ()
lockStreamStatement = Statement.Statement sql encoder decoder True
  where
    -- Use the two paramemeters version namespaced by 2.
    -- We *might* have collisions, but that's not a big deal: it it happens,
    -- it will just end up in over-serialization of a few transactions.
    sql = "select pg_advisory_xact_lock(2, hashtext($1::text)::int), true"
    encoder = Encoders.param (Encoders.nonNullable Encoders.uuid)
    decoder = Decoders.noResult

{- | Validate version expectation for a single stream.

Acquires an advisory lock on the stream before checking to ensure
consistency with concurrent writers.
-}
checkStreamVersion :: UUID -> ExpectedVersion SQLStore -> HasqlTransaction.Transaction (Maybe (VersionMismatch SQLStore))
checkStreamVersion streamId expectation = do
    -- Acquire advisory lock to prevent concurrent modifications
    HasqlTransaction.statement streamId lockStreamStatement

    case expectation of
        NoStream -> do
            exists <- HasqlTransaction.statement streamId streamExistsStatement
            if exists
                then
                    pure $
                        Just $
                            VersionMismatch
                                { streamId = StreamId streamId
                                , expectedVersion = NoStream
                                , actualVersion = Nothing
                                }
                else pure Nothing
        StreamExists -> do
            exists <- HasqlTransaction.statement streamId streamExistsStatement
            if not exists
                then
                    pure $
                        Just $
                            VersionMismatch
                                { streamId = StreamId streamId
                                , expectedVersion = StreamExists
                                , actualVersion = Nothing
                                }
                else pure Nothing
        ExactVersion expectedCursor -> do
            mbVersion <- HasqlTransaction.statement streamId getCurrentVersionStatement
            case mbVersion of
                Nothing ->
                    pure $
                        Just $
                            VersionMismatch
                                { streamId = StreamId streamId
                                , expectedVersion = ExactVersion expectedCursor
                                , actualVersion = Nothing
                                }
                Just actualVersion ->
                    if expectedCursor == actualVersion
                        then pure Nothing
                        else
                            pure $
                                Just $
                                    VersionMismatch
                                        { streamId = StreamId streamId
                                        , expectedVersion = ExactVersion expectedCursor
                                        , actualVersion = Just actualVersion
                                        }
        ExactStreamVersion expectedStreamVersion -> do
            mbStreamVersion <- HasqlTransaction.statement streamId getCurrentStreamVersionStatement
            case mbStreamVersion of
                Nothing ->
                    pure $
                        Just $
                            VersionMismatch
                                { streamId = StreamId streamId
                                , expectedVersion = ExactStreamVersion expectedStreamVersion
                                , actualVersion = Nothing
                                }
                Just actualStreamVersion ->
                    if expectedStreamVersion == actualStreamVersion
                        then pure Nothing
                        else do
                            -- Get the actual cursor for the stream
                            mbCursor <- HasqlTransaction.statement streamId getStreamCursorStatement
                            pure $
                                Just $
                                    VersionMismatch
                                        { streamId = StreamId streamId
                                        , expectedVersion = ExactStreamVersion expectedStreamVersion
                                        , actualVersion = mbCursor
                                        }
        Any -> pure Nothing

{- | Validate version expectations for all event batches.

Acquires row-level locks on affected streams and checks that each
stream's current version matches the expected version. Returns
'Nothing' if all checks pass, or details of any mismatches.
-}
checkVersions :: forall t. Map StreamId (StreamWrite t SomeLatestEvent SQLStore) -> HasqlTransaction.Transaction (Maybe (ConsistencyErrorInfo SQLStore))
checkVersions batches = do
    let streamBatches = Map.toList batches
    mismatches <- validateAllBatches [] streamBatches
    pure $
        if null mismatches
            then Nothing
            else Just $ ConsistencyErrorInfo mismatches
  where
    validateAllBatches ::
        [VersionMismatch SQLStore] ->
        [(StreamId, StreamWrite t SomeLatestEvent SQLStore)] ->
        HasqlTransaction.Transaction [VersionMismatch SQLStore]
    validateAllBatches acc [] = pure acc
    validateAllBatches acc ((streamId, batch) : rest) = do
        mbMismatch <- checkStreamVersion streamId.toUUID batch.expectedVersion
        case mbMismatch of
            Nothing -> validateAllBatches acc rest
            Just mismatch -> validateAllBatches (mismatch : acc) rest

-- | Get current cursor position for a stream
getStreamCursorStatement :: Statement.Statement UUID (Maybe SQLCursor)
getStreamCursorStatement = Statement.Statement sql encoder decoder True
  where
    sql = "SELECT latest_transaction_xid8::text::bigint, latest_seq_no FROM stream_heads WHERE stream_id = $1"
    encoder = E.param (E.nonNullable E.uuid)
    decoder = D.rowMaybe $ do
        txNo <- D.column $ D.nonNullable D.int8
        seqNo <- D.column $ D.nonNullable D.int4
        pure $ SQLCursor txNo seqNo
