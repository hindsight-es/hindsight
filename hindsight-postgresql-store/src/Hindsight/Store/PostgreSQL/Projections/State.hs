{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

module Hindsight.Store.PostgreSQL.Projections.State
  ( -- * State Management
    updateSyncProjectionState,
    registerSyncProjectionInDb,
    getActiveProjections,
    
    -- * Types
    SyncProjectionState (..),
  )
where

import Control.Category ((>>>))
import Data.Aeson qualified as Aeson
import Data.Aeson (FromJSON, ToJSON)
import Data.Functor ((<&>))
import Data.Int (Int32, Int64)
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import Data.Time (UTCTime)
import Data.Vector qualified as Vector
import Hasql.Statement (Statement)
import Hasql.TH
import Hasql.Transaction qualified as HasqlTransaction
import Hindsight.Projection (ProjectionId (..))
import Hindsight.Store.PostgreSQL.Core.Types (SQLCursor (..))

-- | State of a sync projection in the database
data SyncProjectionState = SyncProjectionState
  { projectionId :: ProjectionId,
    lastProcessedTransactionNo :: Int64,
    lastProcessedSeqNo :: Int32,
    lastUpdated :: UTCTime,
    isActive :: Bool,
    errorMessage :: Maybe Text,
    errorTimestamp :: Maybe UTCTime
  }
  deriving (Show, Eq)


-- | Update sync projection state after successful processing
updateSyncProjectionState :: ProjectionId -> SQLCursor -> HasqlTransaction.Transaction ()
updateSyncProjectionState (ProjectionId projId) cursor = do
  HasqlTransaction.statement
    (projId, Aeson.toJSON cursor)
    updateStateStmt
  where
    updateStateStmt :: Statement (Text, Aeson.Value) ()
    updateStateStmt =
      [resultlessStatement|
        UPDATE projections
        SET head_position = $2 :: jsonb,
            last_updated = NOW(),
            is_active = true,
            error_message = NULL,
            error_timestamp = NULL
        WHERE id = $1 :: text
      |]


-- | Register a sync projection in the database if it doesn't exist
registerSyncProjectionInDb :: ProjectionId -> HasqlTransaction.Transaction ()
registerSyncProjectionInDb (ProjectionId projId) = do
  HasqlTransaction.statement
    projId
    registerStmt
  where
    registerStmt :: Statement Text ()
    registerStmt =
      [resultlessStatement|
        INSERT INTO projections 
          (id, last_updated, is_active)
        VALUES 
          ($1 :: text, NOW(), true)
        ON CONFLICT (id) DO NOTHING
      |]

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
            Nothing -> (-1, -1)  -- Never processed
            Just cursorJson -> case Aeson.fromJSON cursorJson :: Aeson.Result SQLCursor of
              Aeson.Success (SQLCursor t s) -> (t, s)
              Aeson.Error _ -> (-1, -1)  -- Failed to parse, treat as never processed
      in SyncProjectionState
        { projectionId = ProjectionId projId,
          lastProcessedTransactionNo = txNo,
          lastProcessedSeqNo = seqNo,
          lastUpdated = updated,
          isActive = active,
          errorMessage = errMsg,
          errorTimestamp = errTs
        }

