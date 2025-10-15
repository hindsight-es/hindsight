{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

module Test.Hindsight.Store.Filesystem where

import Control.Exception (bracket)
import Control.Monad (replicateM, void)
import Data.Aeson (decode)
import Data.ByteString.Lazy qualified as BL
import Data.ByteString.Lazy.Char8 qualified as BL8
import Data.Map.Strict qualified as Map
import Data.Maybe (catMaybes)
import Data.UUID.V4 qualified as UUID
import Hindsight.Store
import Hindsight.Store.Filesystem
import System.Directory
import System.IO.Temp (createTempDirectory)
import Test.Hindsight.Store.Common
import Test.Tasty
import Test.Tasty.HUnit
import UnliftIO.Async (pooledMapConcurrently)

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
    testMultiStreamConcurrency
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
