{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

module Test.Hindsight.Store.Filesystem where

import Control.Concurrent (threadDelay)
import Control.Exception (bracket)
import Control.Monad (replicateM, void)
import Data.Aeson (decode)
import Data.ByteString.Lazy qualified as BL
import Data.ByteString.Lazy.Char8 qualified as BL8
import Data.List (nub)
import Data.Map.Strict qualified as Map
import Data.Maybe (catMaybes)
import Data.UUID.V4 qualified as UUID
import Hindsight.Store
import Hindsight.Store.Filesystem
import Hindsight.Store.Memory.Internal (StoredEvent(seqNo))
import System.Directory
import System.FileLock qualified as FL
import System.IO.Temp (createTempDirectory)
import Test.Hindsight.Store.Common
import Test.Tasty
import Test.Tasty.HUnit
import UnliftIO.Async (concurrently, pooledMapConcurrently)

-- | Helper to create a temporary store
withTempStore :: (FilesystemStoreHandle -> IO a) -> IO a
withTempStore = bracket createTemp cleanup
  where
    createTemp = do
      tmpDir <- getTemporaryDirectory
      testDir <- createTempDirectory tmpDir "event-store-test"
      newFilesystemStore $ mkDefaultConfig testDir
    cleanup handle = do
      cleanupFilesystemStore handle
      removePathForcibly (getStoreConfig handle).storePath


-- | Helper to read log file contents
readLogFile :: FilePath -> IO [EventLogEntry]
readLogFile path = do
  contents <- BL.readFile path
  -- Split by newlines and parse each entry
  pure $ catMaybes $ map decode $ filter (not . BL8.null) $ BL8.split '\n' contents

-- | Test group for filesystem specific tests
-- Note: testSequentialVersioning was a duplicate of generic testConcurrentWrites
-- and has been removed. testMultiStreamConcurrency remains as it tests a specific
-- success case not explicitly covered by generic tests.
filesystemSpecificTests :: [TestTree]
filesystemSpecificTests =
  [ testLogFileStructure,
    testStoreReload,
    testLogFileCorruption,
    testMultiStreamConcurrency,
    testLockTimeoutReturnsBackendError,
    testDiskFullReturnsBackendError,
    testStateDivergenceOnIOFailure,
    testCrossInstanceSequenceNumbering
  ]

-- | Test that verifies the structure of the events.log file
testLogFileStructure :: TestTree
testLogFileStructure = testCase "Log File Structure" $ do
  withTempStore $ \store -> do
    let paths = getPaths (getStoreConfig store).storePath

    -- Verify log file is created
    exists <- doesFileExist paths.eventLogPath
    assertBool "Log file should exist" exists

    -- Write some events
    streamId <- StreamId <$> UUID.nextRandom
    let events = map makeUserEvent [1 .. 3]

    result <-
      insertEvents store Nothing $
        Transaction (Map.singleton streamId (StreamWrite NoStream events))

    case result of
      FailedInsertion err -> assertFailure $ "Failed to insert events: " ++ show err
      SuccessfulInsertion _ -> do
        -- Read and verify log structure
        entries <- readLogFile paths.eventLogPath

        -- Should have 1 transaction
        length entries @?= 1

        -- Verify structure of Begin entry
        case entries of
          [] -> assertFailure "Expected at least one entry"
          beginEntry : _ ->
            length beginEntry.events @?= length events

-- | Test that verifies store can be reloaded from log file
testStoreReload :: TestTree
testStoreReload = testCase "Store Reload" $ do
  withTempStore $ \store -> do
    streamId <- StreamId <$> UUID.nextRandom
    let events = map makeUserEvent [1 .. 3]

    -- Write events to store
    result1 <-
      insertEvents store Nothing $
        Transaction (Map.singleton streamId (StreamWrite NoStream events))

    case result1 of
      FailedInsertion err -> assertFailure $ "Failed to insert events: " ++ show err
      SuccessfulInsertion _ -> do
        -- Create new store instance pointing to same directory
        store2 <- openFilesystemStore (getStoreConfig store)

        -- Try to write with NoStream - should fail if state was properly reloaded
        result2 <-
          insertEvents store2 Nothing $
            Transaction (Map.singleton streamId (StreamWrite NoStream [makeUserEvent 4]))

        case result2 of
          FailedInsertion (ConsistencyError _) -> pure () -- Expected
          _ -> assertFailure "Second write should have failed due to NoStream constraint"

-- | Test handling of corrupted log files
testLogFileCorruption :: TestTree
testLogFileCorruption = testCase "Log File Corruption" $ do
  withTempStore $ \store -> do
    let paths = getPaths (getStoreConfig store).storePath

    -- Write some valid events
    streamId <- StreamId <$> UUID.nextRandom
    let events = map makeUserEvent [1 .. 3]

    void $
      insertEvents store Nothing $
        Transaction (Map.singleton streamId (StreamWrite NoStream events))

    -- Corrupt the log file by appending invalid JSON
    BL.appendFile paths.eventLogPath "invalid json\n"

    -- Try to open new store instance
    store2 <- openFilesystemStore (getStoreConfig store)

    -- Should still be able to write new events
    streamId2 <- StreamId <$> UUID.nextRandom
    result <-
      insertEvents store2 Nothing $
        Transaction (Map.singleton streamId2 (StreamWrite NoStream [makeUserEvent 4]))

    case result of
      FailedInsertion err -> assertFailure $ "Failed to write after corruption: " ++ show err
      SuccessfulInsertion _ -> pure ()

-- | Run concurrent stream updates in parallel and check that all succeed
-- This tests the success case for concurrent writes to independent streams
testMultiStreamConcurrency :: TestTree
testMultiStreamConcurrency = testCase "Multi-stream Concurrency" $ withTempStore $ \store -> do
  let numStreams = 5
  streamIds <- replicateM numStreams (StreamId <$> UUID.nextRandom)

  -- Initialize all streams
  let initWrites =
        Transaction (Map.fromList $
          zip streamIds $
            map
              (\i -> StreamWrite NoStream [makeUserEvent i])
              [1 ..])

  result1 <- insertEvents store Nothing initWrites
  case result1 of
    FailedInsertion err -> assertFailure $ "Initial writes failed: " ++ show err
    SuccessfulInsertion _ -> do
      -- Perform concurrent writes to different streams
      let writeToStream sid =
            insertEvents store Nothing $
              Transaction (Map.singleton sid (StreamWrite StreamExists [makeUserEvent 100]))

      results <- pooledMapConcurrently writeToStream streamIds

      -- All writes should succeed since they're to different streams
      let successCount = length . filter isSuccess $ results
          isSuccess = \case
            SuccessfulInsertion _ -> True
            _ -> False

      assertBool
        ("Expected all writes to succeed, got " ++ show successCount ++ " successes")
        (successCount == numStreams)

-- | Test that lock timeout during insertion returns BackendError
testLockTimeoutReturnsBackendError :: TestTree
testLockTimeoutReturnsBackendError = testCase "Lock Timeout Returns BackendError" $ do
  withTempStore $ \store -> do
    let paths = getPaths (getStoreConfig store).storePath

    lock <- FL.lockFile paths.storeLockPath FL.Exclusive

    let configShortTimeout = (getStoreConfig store) { lockTimeout = 100000 }
    store2 <- newFilesystemStore configShortTimeout

    streamId <- StreamId <$> UUID.nextRandom
    result <- insertEvents store2 Nothing $
      Transaction (Map.singleton streamId (StreamWrite NoStream [makeUserEvent 1]))

    FL.unlockFile lock
    cleanupFilesystemStore store2

    case result of
      FailedInsertion (BackendError _) -> pure ()
      _ -> assertFailure "Expected FailedInsertion with BackendError for lock timeout"

-- | Test that disk full (simulated via read-only) returns BackendError
testDiskFullReturnsBackendError :: TestTree
testDiskFullReturnsBackendError = testCase "Disk Full Returns BackendError" $ do
  withTempStore $ \store -> do
    let storePath = (getStoreConfig store).storePath
        paths = getPaths storePath

    streamId <- StreamId <$> UUID.nextRandom
    result1 <- insertEvents store Nothing $
      Transaction (Map.singleton streamId (StreamWrite NoStream [makeUserEvent 1]))

    case result1 of
      FailedInsertion err -> assertFailure $ "Initial insert failed: " ++ show err
      SuccessfulInsertion _ -> do
        permissions <- getPermissions paths.eventLogPath
        setPermissions paths.eventLogPath (setOwnerWritable False permissions)

        result2 <- insertEvents store Nothing $
          Transaction (Map.singleton streamId (StreamWrite StreamExists [makeUserEvent 2]))

        setPermissions paths.eventLogPath (setOwnerWritable True permissions)

        case result2 of
          FailedInsertion (BackendError _) -> pure ()
          _ -> assertFailure "Expected FailedInsertion with BackendError for I/O error"

-- | Test that I/O failures don't cause state divergence
testStateDivergenceOnIOFailure :: TestTree
testStateDivergenceOnIOFailure = testCase "No State Divergence on I/O Failure" $ do
  withTempStore $ \store -> do
    let storePath = (getStoreConfig store).storePath
        paths = getPaths storePath

    streamId <- StreamId <$> UUID.nextRandom

    permissions <- getPermissions paths.eventLogPath
    setPermissions paths.eventLogPath (setOwnerWritable False permissions)

    result <- insertEvents store Nothing $
      Transaction (Map.singleton streamId (StreamWrite NoStream [makeUserEvent 1]))

    setPermissions paths.eventLogPath (setOwnerWritable True permissions)

    case result of
      FailedInsertion _ -> do
        entries <- readLogFile paths.eventLogPath
        assertBool "Disk should have no events after failed write" (null entries)
      SuccessfulInsertion _ -> assertFailure "Insert should have failed with read-only file"

-- | Test that concurrent insertions don't create duplicate sequence numbers
testCrossInstanceSequenceNumbering :: TestTree
testCrossInstanceSequenceNumbering = testCase "Cross-Instance Sequence Numbering" $ do
  tmpDir <- getTemporaryDirectory
  testDir <- createTempDirectory tmpDir "event-store-seq-test"
  let config = mkDefaultConfig testDir

  store1 <- openFilesystemStore config
  store2 <- openFilesystemStore config

  streamId1 <- StreamId <$> UUID.nextRandom
  streamId2 <- StreamId <$> UUID.nextRandom

  (_, _) <- concurrently
    (insertEvents store1 Nothing $
      Transaction (Map.singleton streamId1 (StreamWrite NoStream [makeUserEvent 1, makeUserEvent 2, makeUserEvent 3])))
    (insertEvents store2 Nothing $
      Transaction (Map.singleton streamId2 (StreamWrite NoStream [makeUserEvent 10, makeUserEvent 11])))

  threadDelay 200000

  let paths = getPaths testDir
  entries <- readLogFile paths.eventLogPath
  let allEvents = concatMap (\entry -> entry.events) entries
      seqNos = map seqNo allEvents :: [Integer]
      uniqueSeqNos = length $ nub seqNos
      totalSeqNos = length seqNos

  cleanupFilesystemStore store1
  cleanupFilesystemStore store2
  removePathForcibly testDir

  assertBool "All sequence numbers should be unique (no duplicates)" (uniqueSeqNos == totalSeqNos)
