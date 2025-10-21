{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

module Hindsight.Store.PostgreSQL.Projections.State (
    -- * State Management
    updateSyncProjectionState,
    registerSyncProjectionInDb,
    getActiveProjections,

    -- * Types
    SyncProjectionState (..),
)
where

import Control.Category ((>>>))
import Data.Aeson qualified as Aeson
import Data.Functor ((<&>))
import Data.Int (Int32, Int64)
import Data.Text (Text)
import Data.Time (UTCTime)
import Data.Vector qualified as Vector
import Hasql.Statement (Statement)
import Hasql.TH
import Hasql.Transaction qualified as HasqlTransaction
import Hindsight.Projection (ProjectionId (..))
import Hindsight.Projection.State qualified as ProjectionState
import Hindsight.Store.PostgreSQL.Core.Types (SQLCursor (..))

-- | State of a sync projection in the database
data SyncProjectionState = SyncProjectionState
    { projectionId :: ProjectionId
    , lastProcessedTransactionNo :: Int64
    , lastProcessedSeqNo :: Int32
    , lastUpdated :: UTCTime
    , isActive :: Bool
    , errorMessage :: Maybe Text
    , errorTimestamp :: Maybe UTCTime
    }
    deriving (Show, Eq)

{- | Update sync projection state after successful processing

Uses the shared upsert operation from Hindsight.Projection.State
which handles cursor updates and error clearing.
-}
updateSyncProjectionState :: ProjectionId -> SQLCursor -> HasqlTransaction.Transaction ()
updateSyncProjectionState (ProjectionId projId) cursor = do
    HasqlTransaction.statement
        (projId, Aeson.toJSON cursor)
        ProjectionState.upsertProjectionCursor

{- | Register a sync projection in the database if it doesn't exist

Uses the shared registration operation from Hindsight.Projection.State.
-}
registerSyncProjectionInDb :: ProjectionId -> HasqlTransaction.Transaction ()
registerSyncProjectionInDb (ProjectionId projId) = do
    HasqlTransaction.statement
        projId
        ProjectionState.registerProjection

-- | Get all active sync projections from the database
getActiveProjections :: HasqlTransaction.Transaction [SyncProjectionState]
getActiveProjections = do
    HasqlTransaction.statement () getActiveStmt
  where
    getActiveStmt :: Statement () [SyncProjectionState]
    getActiveStmt =
        [vectorStatement|
        SELECT 
          id :: text,
          head_position :: jsonb?,
          last_updated :: timestamptz,
          is_active :: bool,
          error_message :: text?,
          error_timestamp :: timestamptz?
        FROM projections
        WHERE is_active = true
        ORDER BY id
      |]
            <&> (Vector.toList >>> map toSyncProjectionState)

    toSyncProjectionState (projId, mbCursorJson, updated, active, errMsg, errTs) =
        let (txNo, seqNo) = case mbCursorJson of
                Nothing -> (-1, -1) -- Never processed
                Just cursorJson -> case Aeson.fromJSON cursorJson :: Aeson.Result SQLCursor of
                    Aeson.Success (SQLCursor t s) -> (t, s)
                    Aeson.Error _ -> (-1, -1) -- Failed to parse, treat as never processed
         in SyncProjectionState
                { projectionId = ProjectionId projId
                , lastProcessedTransactionNo = txNo
                , lastProcessedSeqNo = seqNo
                , lastUpdated = updated
                , isActive = active
                , errorMessage = errMsg
                , errorTimestamp = errTs
                }
