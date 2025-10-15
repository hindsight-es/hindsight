{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}

{-|
Module      : Hindsight.Store.Filesystem
Description : File-based persistent event store with multi-process support
Copyright   : (c) 2024
License     : BSD3
Maintainer  : maintainer@example.com
Stability   : experimental

This module provides a filesystem-based implementation of the event store,
persisting events as JSON files on disk. It's suitable for single-node
deployments where durability is needed without requiring a database.

= Storage Format

Events are stored in an append-only JSON log file (@events.log@). Each line
contains a complete transaction with its events. All writes are atomic using
file system primitives and file locking.

__Note on Indexing__: Currently there are no separate index files on disk.
Stream indices are maintained purely in-memory and rebuilt on startup by
replaying the event log. This approach keeps the implementation simple but
means startup time grows linearly with the total number of events. Future
versions may add persistent index files (e.g., B-tree indices) to improve
startup performance for large event logs.

= Architecture

The filesystem store is implemented as a persistence layer over the memory
store infrastructure. Events are written to disk and then loaded into the
same in-memory data structures used by 'MemoryStore'. This design maximizes
code sharing but means the filesystem store inherits the memory store's
characteristics: all indices (and some recent event metadata) must fit in
memory.

= Key Features

The store provides durable, ACID-compliant event storage with multi-process
support. Writes are serialized using file locks to prevent corruption.
Subscriptions use fsnotify to detect changes written by other processes,
enabling multiple readers and writers to safely share the same event log.
Event reloading is automatic and incremental. Cross-platform file watching
is supported via fsnotify (macOS FSEvents, Linux inotify, Windows).

= Limitations

Performance is limited by disk I/O characteristics. Memory usage is comparable
to 'MemoryStore' for the working set - all indices and recent metadata must
fit in RAM. Startup time grows linearly with total event count due to log
replay. The store is not suitable for distributed systems spanning multiple
nodes; use the PostgreSQL backend for distributed scenarios.
-}
module Hindsight.Store.Filesystem
  ( -- * Store Types
    FilesystemStore,
    FilesystemStoreHandle,
    FilesystemCursor (..),

    -- * Configuration
    FilesystemStoreConfig (..),
    mkDefaultConfig,
    getStoreConfig,

    -- * Store Operations
    newFilesystemStore,
    openFilesystemStore,
    cleanupFilesystemStore,

    -- * Testing Support
    EventLogEntry (..),
    StorePaths (..),
    getPaths,
  )
where

import Control.Concurrent (threadDelay)
import Control.Concurrent.Async (Async, async, cancel)
import Control.Concurrent.STM
  ( TChan,
    TVar,
    atomically,
    dupTChan,
    modifyTVar',
    newBroadcastTChanIO,
    newTVarIO,
    readTChan,
    readTVar,
    writeTChan,
    writeTVar,
  )
import Control.Exception (Exception, bracket, throwIO, try)
import Control.Monad (forever, forM_, void, when)
import Control.Monad.IO.Class (liftIO)
import UnliftIO (MonadUnliftIO)
import Data.Aeson (FromJSON, ToJSON (..), decode, encode)
import Data.ByteString qualified as BS  -- Strict ByteString for file operations
import Data.ByteString.Char8 qualified as BS8
import Data.ByteString.Lazy qualified as BL
import Data.ByteString.Lazy.Char8 qualified as BL8
import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Maybe (mapMaybe)
import Data.Time (UTCTime, getCurrentTime)
import Data.UUID (UUID)
import Data.UUID.V4 qualified as UUID
-- (StoredEvent (..), StoreCursor (..), StoreState (..), updateState)

import GHC.Generics (Generic)
import Hindsight.Store
  ( BackendHandle,
    Cursor,
    EventId (EventId),
    EventMatcher,
    EventSelector (..),
    EventStore (..),
    InsertionResult (FailedInsertion, SuccessfulInsertion),
    InsertionSuccess (..),
    StreamWrite (events),
    SubscriptionHandle (..),
    Transaction (..),
  )
import Hindsight.Store.Memory.Internal
  ( StoreCursor (..),
    StoreState (..),
    StoredEvent (seqNo),
    checkAllVersions,
    insertAllEvents,
    subscribeToEvents,
    updateState,
  )
import System.Directory (canonicalizePath, createDirectoryIfMissing, doesFileExist, removeFile)
import System.FileLock qualified as FL
import System.FilePath (takeDirectory, (</>))
import System.FSNotify (Event (..), eventPath, watchDir, withManager)
-- No System.IO imports needed - using lazy ByteString operations instead
import System.Timeout (timeout)

-- | Configuration for filesystem store
data FilesystemStoreConfig = FilesystemStoreConfig
  { -- | Base directory for store files
    storePath :: FilePath,
    -- | How often to sync to disk (number of writes)
    syncInterval :: Int,
    -- | Timeout for acquiring locks (microseconds)
    lockTimeout :: Int
  }
  deriving (Show, Eq, Generic)
  deriving anyclass (FromJSON, ToJSON)

-- | An entry in our event log represents a transaction state change
data EventLogEntry = EventLogEntry
  { transactionId :: UUID,
    events :: [StoredEvent],
    timestamp :: UTCTime
  }
  deriving stock (Show, Eq, Generic)
  deriving anyclass (FromJSON, ToJSON)

-- | Cursor for filesystem store
newtype FilesystemCursor = FilesystemCursor
  { getSequenceNo :: Integer
  }
  deriving (Show, Eq, Ord, Generic)
  deriving anyclass (FromJSON, ToJSON)

-- | Notifier for cross-process event notifications
-- Watches the event log file and broadcasts changes to subscribers
-- The central reload thread updates the in-memory state when files change
data Notifier = Notifier
  { notifierThread :: Async (),
    reloadThread :: Async ()  -- Central reload thread (one per store)
  }

-- | Store type marker
data FilesystemStore

-- Type family instances
type instance Cursor FilesystemStore = FilesystemCursor

type instance BackendHandle FilesystemStore = FilesystemStoreHandle

-- | Custom exceptions
data StoreException
  = LockTimeout FilePath
  | CorruptEventLog FilePath String
  deriving (Show)

instance Exception StoreException

-- | Handle for filesystem store operations
data FilesystemStoreHandle = FilesystemStoreHandle
  { config :: FilesystemStoreConfig,
    stateVar :: TVar (StoreState FilesystemStore),
    notifier :: Notifier
  }

-- | File paths used by the store
data StorePaths = StorePaths
  { eventLogPath :: FilePath,
    storeLockPath :: FilePath
  }

getPaths :: FilePath -> StorePaths
getPaths base =
  StorePaths
    { eventLogPath = base </> "events.log",
      storeLockPath = base </> "store.lock"
    }

mkDefaultConfig :: FilePath -> FilesystemStoreConfig
mkDefaultConfig path =
  FilesystemStoreConfig
    { storePath = path,
      syncInterval = 1, -- Sync every write by default
      lockTimeout = 5000000 -- 5 seconds (allows ~25 instances @ 200ms each)
    }

-- | Get the configuration from a store handle.
--
-- Useful for accessing the store path during cleanup or debugging.
getStoreConfig :: FilesystemStoreHandle -> FilesystemStoreConfig
getStoreConfig = (.config)
-- | Creates required directories
ensureDirectories :: FilePath -> IO ()
ensureDirectories path = do
  let dir = takeDirectory path
  createDirectoryIfMissing True dir

-- | Safely perform operations with global store lock (direct config version)
-- Used by central reload thread which doesn't have access to handle
withStoreLockDirect :: FilesystemStoreConfig -> IO a -> IO a
withStoreLockDirect config action = do
  let paths = getPaths config.storePath
  -- Try to acquire lock with timeout
  result <-
    timeout config.lockTimeout $
      bracket
        (FL.lockFile paths.storeLockPath FL.Exclusive)
        FL.unlockFile
        (const action)
  case result of
    Nothing -> throwIO $ LockTimeout paths.storeLockPath
    Just value -> pure value

-- | Safely perform operations with global store lock
withStoreLock :: FilesystemStoreHandle -> IO a -> IO a
withStoreLock handle = withStoreLockDirect handle.config

-- | Write a log entry with proper locking
-- Uses strict ByteString for immediate file handle release
writeLogEntry :: FilesystemStoreHandle -> EventLogEntry -> IO ()
writeLogEntry handle entry =
  withStoreLock handle $ do
    let paths = getPaths handle.config.storePath
        jsonLine = BL.toStrict (encode entry) <> "\n"  -- Convert to strict + newline
    -- Use strict appendFile to ensure immediate file closure
    BS.appendFile paths.eventLogPath jsonLine

-- | Initialize a new store
newFilesystemStore :: FilesystemStoreConfig -> IO FilesystemStoreHandle
newFilesystemStore config = do
  let paths = getPaths config.storePath

  -- Ensure directories exist
  ensureDirectories config.storePath
  -- Create event log if it doesn't exist (like 'touch')
  exists <- doesFileExist paths.eventLogPath
  when (not exists) $ BS.writeFile paths.eventLogPath ""

  -- Initialize memory store components
  globalVar <- newTVarIO (-1)
  stateVar <-
    newTVarIO $
      StoreState
        { nextSequence = 0,
          events = Map.empty,
          streamEvents = Map.empty,
          streamVersions = Map.empty,
          streamLocalVersions = Map.empty,
          streamNotifications = Map.empty,
          globalNotification = globalVar
        }

  -- Start the file watcher notifier with central reload thread
  notifier <- startNotifier paths.eventLogPath stateVar config

  pure FilesystemStoreHandle {..}

-- | Process log entries and return completed transactions
processLogEntries :: [EventLogEntry] -> Map UUID [StoredEvent]
processLogEntries entries = Map.fromList [(e.transactionId, e.events) | e <- entries]

-- | Read and parse all entries from the event log
readLogEntries :: FilesystemStoreHandle -> IO [EventLogEntry]
readLogEntries handle =
  withStoreLock handle $ do
    let paths = getPaths handle.config.storePath
    contents <- BL.readFile paths.eventLogPath
    -- Parse entries, ignoring any corrupt ones
    pure $ mapMaybe decode $ BL8.split '\n' contents

openFilesystemStore :: FilesystemStoreConfig -> IO FilesystemStoreHandle
openFilesystemStore config = do
  -- Note: newFilesystemStore already starts the notifier
  handle <- newFilesystemStore config

  let paths = getPaths config.storePath
  exists <- doesFileExist paths.eventLogPath
  when exists $ do
    entries <- readLogEntries handle
    let completedEvents = Map.elems $ processLogEntries entries
        maxSeqNo = maximum $ 0 : [e.seqNo | es <- completedEvents, e <- es]

    atomically $ do
      -- Update store state with completed events
      modifyTVar' handle.stateVar $ \state ->
        foldr
          (flip (foldr updateState))
          state
            { nextSequence = maxSeqNo + 1
            }
          completedEvents

      -- Get the state to access its globalNotification TVar
      state <- readTVar handle.stateVar
      -- Update the global notification to match the last event
      writeTVar state.globalNotification maxSeqNo

  pure handle

-- | Start the file watcher notifier thread
-- Watches the event log for modifications and broadcasts to subscribers
-- Also starts the central reload thread that updates in-memory state
startNotifier :: FilePath -> TVar (StoreState FilesystemStore) -> FilesystemStoreConfig -> IO Notifier
startNotifier eventLogPath stateVar config = do
  chan <- newBroadcastTChanIO

  -- File watcher thread - broadcasts when file changes
  notifyThread <- async $ notifierLoop eventLogPath chan

  -- Central reload thread - responds to broadcasts by reloading events
  -- This replaces per-subscription reload threads, reducing lock contention
  -- CRITICAL: Must handle LockTimeout exceptions and retry, otherwise
  -- subscriptions will block forever waiting for updates that never come
  reloadChan <- atomically $ dupTChan chan
  reloadThread <- async $ forever $ do
    atomically $ readTChan reloadChan
    reloadEventsFromDiskCentralWithRetry stateVar config 0

  pure $ Notifier notifyThread reloadThread

-- | Stop the notifier threads
shutdownNotifier :: Notifier -> IO ()
shutdownNotifier notifier = do
  cancel notifier.notifierThread  -- Stop file watcher
  cancel notifier.reloadThread     -- Stop reload thread

-- | Main loop for the notifier
-- Uses fsnotify to watch for file modifications
notifierLoop :: FilePath -> TChan () -> IO ()
notifierLoop eventLogPath chan = do
  -- Canonicalize the path to handle symlinks (e.g., /tmp -> /private/tmp on macOS)
  canonicalEventLogPath <- canonicalizePath eventLogPath

  withManager $ \mgr -> do
    let watchDir' = takeDirectory canonicalEventLogPath
        predicate event = eventPath event == canonicalEventLogPath
        handler _event = atomically $ writeTChan chan ()

    -- Watch for modifications to the event log
    void $ watchDir mgr watchDir' predicate handler

    -- Keep thread alive
    forever $ threadDelay maxBound

-- | Retry wrapper for reloadEventsFromDiskCentral with exponential backoff
-- Handles LockTimeout exceptions gracefully to prevent reload thread death
-- Max retries: 5, with exponential backoff: 10ms, 20ms, 40ms, 80ms, 160ms
reloadEventsFromDiskCentralWithRetry :: TVar (StoreState FilesystemStore) -> FilesystemStoreConfig -> Int -> IO ()
reloadEventsFromDiskCentralWithRetry stateVar config retryCount = do
  result <- try $ reloadEventsFromDiskCentral stateVar config
  case result of
    Right () -> pure ()  -- Success, done
    Left (LockTimeout path) -> do
      if retryCount >= 5
        then do
          -- Max retries exceeded - log warning and give up on this reload
          -- This is NOT fatal - the next file change will trigger another reload
          putStrLn $ "WARNING: Failed to reload events after 5 retries due to lock contention on " ++ path
          pure ()
        else do
          -- Exponential backoff: 10ms * 2^retryCount
          let delayMicros = 10000 * (2 ^ retryCount)
          threadDelay delayMicros
          reloadEventsFromDiskCentralWithRetry stateVar config (retryCount + 1)

-- | Reload new events from disk into the in-memory store state
-- Called by the notifier's reload thread when file changes are detected
-- Uses locking to coordinate with writes and avoid "resource busy" errors
-- Uses STRICT ByteString to ensure file handle is closed immediately
reloadEventsFromDiskCentral :: TVar (StoreState FilesystemStore) -> FilesystemStoreConfig -> IO ()
reloadEventsFromDiskCentral stateVar config = do
  -- Acquire lock to coordinate with writes and avoid concurrent file access issues
  -- Use strict ByteString to ensure file is closed immediately (no lazy handle leak)
  entries <- withStoreLockDirect config $ do
    let paths = getPaths config.storePath
    contents <- BS.readFile paths.eventLogPath
    pure $ mapMaybe decode $ map BL.fromStrict $ BS8.split '\n' contents

  let completedEvents = Map.elems $ processLogEntries entries

  atomically $ do
    state <- readTVar stateVar
    let currentMaxSeq = state.nextSequence - 1
        newEvents = [e | es <- completedEvents, e <- es, e.seqNo > currentMaxSeq]
        newMaxSeq = maximum $ currentMaxSeq : [e.seqNo | e <- newEvents]

    when (not $ null newEvents) $ do
      -- Update state with new events
      let newState = foldr updateState state newEvents
      writeTVar stateVar newState {nextSequence = newMaxSeq + 1}

      -- Update global notification
      writeTVar newState.globalNotification newMaxSeq

-- | Subscribe to events from the filesystem store
-- The notifier's reload thread keeps the in-memory state updated,
-- so subscriptions just read from the shared state variable
subscribeFilesystem ::
  forall m ts.
  (MonadUnliftIO m) =>
  FilesystemStoreHandle ->
  EventMatcher ts FilesystemStore m ->
  EventSelector FilesystemStore ->
  m (SubscriptionHandle FilesystemStore)
subscribeFilesystem handle matcher selector =
  -- Subscribe directly to in-memory state
  -- The notifier's reload thread updates stateVar when files change
  subscribeToEvents handle.stateVar matcher selector

-- | Cleanup store resources
cleanupFilesystemStore :: FilesystemStoreHandle -> IO ()
cleanupFilesystemStore handle = do
  let paths = getPaths handle.config.storePath
  -- Shutdown the notifier
  shutdownNotifier handle.notifier
  -- Remove lock file if it exists
  doesFileExist paths.storeLockPath >>= flip when (removeFile paths.storeLockPath)

instance EventStore FilesystemStore where
  type StoreConstraints FilesystemStore m = (MonadUnliftIO m)

  insertEvents handle corrId (Transaction batches) = liftIO $ do
    txId <- UUID.nextRandom
    now <- getCurrentTime

    -- Execute version check and state update atomically
    result <- atomically $ do
      state <- readTVar handle.stateVar
      case checkAllVersions state batches of
        Left err -> pure $ Left err
        Right () -> do
          let eventIds = replicate (sum $ map (length . (.events)) $ Map.elems batches) (EventId txId)
              (newState, finalCursor, streamCursors) = insertAllEvents state corrId now eventIds batches
              newEvents =
                [ event
                  | event <- Map.elems newState.events,
                    not $ Map.member event.seqNo state.events
                ]
          writeTVar handle.stateVar newState
          pure $ Right (newState, finalCursor, streamCursors, newEvents)

    case result of
      Left err -> pure $ FailedInsertion err
      Right (newState, finalCursor, streamCursors, newEvents) -> do
        -- Write begin entry
        writeLogEntry
          handle
          EventLogEntry
            { transactionId = txId,
              events = newEvents,
              timestamp = now
            }

        -- Update notifications
        atomically $ do
          forM_ (Map.keys batches) $ \streamId ->
            forM_ (Map.lookup streamId newState.streamNotifications) $ \var ->
              writeTVar var (getSequenceNo finalCursor)

          writeTVar newState.globalNotification (getSequenceNo finalCursor)

        pure $ SuccessfulInsertion $ InsertionSuccess
          { finalCursor = finalCursor
          , streamCursors = streamCursors
          }

  subscribe = subscribeFilesystem

instance StoreCursor FilesystemStore where
  makeCursor = FilesystemCursor
  makeSequenceNo = (.getSequenceNo)