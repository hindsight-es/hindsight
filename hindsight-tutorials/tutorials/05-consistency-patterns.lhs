Consistency Patterns
====================

In event sourcing, you typically query **projections** (read models) for fast reads, not scan
event streams. Projections are **eventually consistent** - they may lag behind the latest events.
This creates race conditions when making decisions based on potentially stale state.

The Problem: Stale Projections
-------------------------------

Consider a bank account:

1. Current balance projection shows $100 (based on stream version 5)
2. You query the projection, decide to withdraw $50
3. But a $80 withdrawal at version 6 hasn't been projected yet!
4. You write the withdrawal event, overdrawing the account

**Solution**: Track the stream version in your projection state, then use `ExactVersion`
when writing events to ensure your decision was based on current state.

Prerequisites
-------------

\begin{code}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RequiredTypeArguments #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Main where

import Control.Concurrent (threadDelay)
import Control.Concurrent.STM
import Data.Aeson (FromJSON, ToJSON)
import Data.Text (Text)
import Data.UUID.V4 qualified as UUID
import GHC.Generics (Generic)
import Hindsight
import Hindsight.Store.Memory (MemoryStore, newMemoryStore)
\end{code}

Define Bank Account Events
---------------------------

\begin{code}
type AccountOpened = "account_opened"
type MoneyDeposited = "money_deposited"
type MoneyWithdrawn = "money_withdrawn"

data OpenInfo = OpenInfo
  { accountId :: Text
  , initialBalance :: Int
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)

data DepositInfo = DepositInfo
  { accountId :: Text
  , amount :: Int
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)

data WithdrawInfo = WithdrawInfo
  { accountId :: Text
  , amount :: Int
  } deriving (Show, Eq, Generic, FromJSON, ToJSON)

-- Event versioning
type instance MaxVersion AccountOpened = 0
type instance Versions AccountOpened = '[OpenInfo]
instance Event AccountOpened
instance MigrateVersion 0 AccountOpened

type instance MaxVersion MoneyDeposited = 0
type instance Versions MoneyDeposited = '[DepositInfo]
instance Event MoneyDeposited
instance MigrateVersion 0 MoneyDeposited

type instance MaxVersion MoneyWithdrawn = 0
type instance Versions MoneyWithdrawn = '[WithdrawInfo]
instance Event MoneyWithdrawn
instance MigrateVersion 0 MoneyWithdrawn
\end{code}

Build a Version-Aware Projection
---------------------------------

The key: store the stream version alongside your projection state.

\begin{code}
-- Projection state: balance + last processed stream version
data AccountState = AccountState
  { balance :: Int
  , lastVersion :: Cursor MemoryStore
  } deriving (Show, Eq)

-- Our read model
type AccountProjection = TVar (Maybe AccountState)

-- Create empty projection
newAccountProjection :: IO AccountProjection
newAccountProjection = newTVarIO Nothing

-- Query current state (returns Nothing if account doesn't exist)
queryAccount :: AccountProjection -> IO (Maybe AccountState)
queryAccount = readTVarIO

-- Event handlers that update balance AND version
handleOpened :: AccountProjection -> EventHandler AccountOpened IO MemoryStore
handleOpened proj envelope = do
  let info = envelope.payload
      version = envelope.position
  atomically $ writeTVar proj $ Just (AccountState info.initialBalance version)
  putStrLn $ "  → Account opened: balance=" <> show info.initialBalance
  return Continue

handleDeposit :: AccountProjection -> EventHandler MoneyDeposited IO MemoryStore
handleDeposit proj envelope = do
  let info = envelope.payload
      version = envelope.position
  atomically $ modifyTVar' proj $ \case
    Just state -> Just (AccountState (state.balance + info.amount) version)
    Nothing -> Nothing  -- Shouldn't happen in correct event order
  putStrLn $ "  → Deposited: +" <> show info.amount
  return Continue

handleWithdraw :: AccountProjection -> EventHandler MoneyWithdrawn IO MemoryStore
handleWithdraw proj envelope = do
  let info = envelope.payload
      version = envelope.position
  atomically $ modifyTVar' proj $ \case
    Just state -> Just (AccountState (state.balance - info.amount) version)
    Nothing -> Nothing
  putStrLn $ "  → Withdrawn: -" <> show info.amount
  return Continue
\end{code}

Version-Aware Operations
-------------------------

Use the version from your projection when writing events.

\begin{code}
-- Create account (use NoStream to ensure it's new)
createAccount :: BackendHandle MemoryStore -> StreamId -> Text -> Int -> IO (Maybe (Cursor MemoryStore))
createAccount store streamId accId initialBalance = do
  let event = mkEvent AccountOpened (OpenInfo accId initialBalance)
  result <- insertEvents store Nothing $
    singleEvent streamId NoStream event

  case result of
    SuccessfulInsertion (InsertionSuccess{finalCursor}) -> do
      putStrLn "✓ Account created"
      return (Just finalCursor)
    FailedInsertion err -> do
      putStrLn $ "✗ Create failed: " <> show err
      return Nothing

-- Withdraw money using version from projection
withdrawMoney :: BackendHandle MemoryStore -> StreamId -> Text -> Int -> Cursor MemoryStore -> IO Bool
withdrawMoney store streamId accId amount expectedVersion = do
  let event = mkEvent MoneyWithdrawn (WithdrawInfo accId amount)
  result <- insertEvents store Nothing $
    singleEvent streamId (ExactVersion expectedVersion) event

  case result of
    SuccessfulInsertion _ -> do
      putStrLn $ "✓ Withdrawal succeeded (version was current)"
      return True
    FailedInsertion (ConsistencyError _) -> do
      putStrLn $ "✗ Withdrawal failed: version mismatch (projection was stale or concurrent write)"
      return False
    FailedInsertion err -> do
      putStrLn $ "✗ Withdrawal failed: " <> show err
      return False
\end{code}

Demonstration
-------------

\begin{code}
demoConsistency :: IO ()
demoConsistency = do
  putStrLn "=== Consistency Demo ==="

  store <- newMemoryStore
  streamId <- StreamId <$> UUID.nextRandom

  -- Create projection
  projection <- newAccountProjection

  -- Subscribe projection to events
  handle <- subscribe store
    ( match AccountOpened (handleOpened projection) :?
      match MoneyDeposited (handleDeposit projection) :?
      match MoneyWithdrawn (handleWithdraw projection) :?
      MatchEnd )
    (EventSelector AllStreams FromBeginning)

  -- Create account
  putStrLn "\n--- Creating account ACC001 ---"
  mbVersion <- createAccount store streamId "ACC001" 100
  threadDelay 100000  -- Wait for projection

  -- Try to create same account again - should fail
  putStrLn "\n--- Attempting duplicate account creation ---"
  _ <- createAccount store streamId "ACC001" 100
  threadDelay 100000

  case mbVersion of
    Nothing -> putStrLn "Account creation failed"
    Just _version -> do
      -- Query projection
      mbState1 <- queryAccount projection
      case mbState1 of
        Nothing -> putStrLn "Projection not ready"
        Just state1 -> do
          putStrLn $ "\nCurrent state: balance=" <> show state1.balance
                    <> ", version=" <> show state1.lastVersion

          -- Withdraw using correct version - should succeed
          putStrLn "\n--- Attempting withdrawal with correct version ---"
          success1 <- withdrawMoney store streamId "ACC001" 30 state1.lastVersion
          threadDelay 100000

          if success1
            then do
              -- Query updated state
              Just state2 <- queryAccount projection
              putStrLn $ "New state: balance=" <> show state2.balance
                        <> ", version=" <> show state2.lastVersion

              -- Try to withdraw using OLD version - should fail
              putStrLn "\n--- Attempting withdrawal with STALE version ---"
              _success2 <- withdrawMoney store streamId "ACC001" 20 state1.lastVersion  -- Using old version!
              putStrLn "   (This prevents overdraft based on stale projection)"

            else putStrLn "First withdrawal failed unexpectedly"

  handle.cancel
  threadDelay 10000
\end{code}

Reality Check
-------------

Version expectations prevent **most** race conditions, but not all:

- **Unavoidable races**: Two concurrent ATM withdrawals in different cities may both succeed
  before projections update, causing overdraft
- **Solution**: Use **remediation events** (e.g., `OverdraftDetected`) to detect and correct
  inconsistencies after the fact
- **Trade-off**: Version expectations catch staleness within your system, but can't prevent
  all real-world concurrency issues

For critical invariants (like account balance), consider additional safeguards beyond
optimistic locking.

Running the Example
-------------------

\begin{code}
main :: IO ()
main = do
  putStrLn "=== Hindsight Tutorial 05: Consistency Patterns ==="
  putStrLn ""

  demoConsistency

  putStrLn "\nTutorial complete!"
\end{code}

Summary
-------

Key concepts:

- **Store version in projections**: Track `lastVersion` alongside projection state
- **Use `ExactVersion` when writing**: Ensures your decision was based on current state
- **Prevents stale reads**: Version mismatch fails the write if projection was outdated
- **Not a silver bullet**: Some races unavoidable, may need remediation events

Next Steps
----------

In the next tutorial, we'll explore **backend-agnostic code** - writing
application logic that works with any storage backend.
