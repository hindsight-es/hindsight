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
persisting events as JSON files on disk. Suitable for single-node deployments
where durability is needed without a database dependency.

= Storage Format

Events are stored in an append-only log file with accompanying index files
for efficient stream queries. All writes are atomic using file system primitives.

= Key Features

* Durable storage with automatic recovery
* Atomic writes using file locking
* Efficient stream indexing
* Multi-process subscription support via fsnotify
* No external database required

= Multi-Process Support

Multiple processes can safely access the same filesystem store:

* Writes are serialized using file locks to prevent corruption
* Subscriptions use fsnotify to detect changes written by other processes
* Event reloading is automatic and incremental
* Cross-platform support (macOS FSEvents, Linux inotify, Windows)

= Limitations

* Performance limited by disk I/O
* Not suitable for distributed systems across multiple nodes
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

import Control.Concurrent (forkIO, killThread, threadDelay)
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
import Control.Exception (Exception, bracket, throwIO)
import Control.Monad (forever, forM_, void, when)
import Control.Monad.IO.Class (liftIO)
import UnliftIO (MonadUnliftIO)
import Data.Aeson (FromJSON, ToJSON (..), decode, encode)
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
    StreamEventBatch (events),
    SubscriptionHandle (..),
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
import System.IO (Handle, SeekMode (..), hClose, hFlush, hPutChar, hSeek)
import System.Posix.IO (OpenFileFlags (..), OpenMode (..), defaultFileFlags, fdToHandle, openFd)
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
data Notifier = Notifier
  { notifierChannel :: TChan (),
    notifierThread :: Async ()
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
    writeCounter :: TVar Int,
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
      lockTimeout = 1000000 -- 1 second
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

-- | Helper to open file without implicit locking
openFileWithoutLocking :: FilePath -> IO Handle
openFileWithoutLocking path = do
  fd <- openFd path WriteOnly defaultFileFlags {creat = Just 0o644}
  fdToHandle fd

-- | Safely perform operations with global store lock
withStoreLock :: FilesystemStoreHandle -> IO a -> IO a
withStoreLock handle action = do
  let paths = getPaths handle.config.storePath
  -- Try to acquire lock with timeout
  result <-
    timeout handle.config.lockTimeout $
      bracket
        (FL.lockFile paths.storeLockPath FL.Exclusive)
        FL.unlockFile
        (const action)
  case result of
    Nothing -> throwIO $ LockTimeout paths.storeLockPath
    Just value -> pure value

-- | Write a log entry with proper locking and syncing
writeLogEntry :: FilesystemStoreHandle -> EventLogEntry -> IO ()
writeLogEntry handle entry =
  withStoreLock handle $ do
    let paths = getPaths handle.config.storePath
    bracket
      (openFileWithoutLocking paths.eventLogPath)
      hClose
      $ \eventHandle -> do
        -- Write entry followed by newline
        hSeek eventHandle SeekFromEnd 0
        BL.hPutStr eventHandle (encode entry)
        hPutChar eventHandle '\n'
        hFlush eventHandle

        -- Check if sync needed based on counter
        shouldSync <- atomically $ do
          count <- readTVar handle.writeCounter
          let newCount = count + 1
          writeTVar handle.writeCounter $
            if newCount >= handle.config.syncInterval
              then 0
              else newCount
          pure $ newCount >= handle.config.syncInterval

        when shouldSync $ hFlush eventHandle

-- | Initialize a new store
newFilesystemStore :: FilesystemStoreConfig -> IO FilesystemStoreHandle
newFilesystemStore config = do
  let paths = getPaths config.storePath

  -- Ensure directories exist
  ensureDirectories config.storePath

  -- Initialize event log if it doesn't exist
  bracket
    (openFileWithoutLocking paths.eventLogPath)
    hClose
    $ \_ -> pure ()

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
  writeCounter <- newTVarIO 0

  -- Start the file watcher notifier
  notifier <- startNotifier paths.eventLogPath

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
startNotifier :: FilePath -> IO Notifier
startNotifier eventLogPath = do
  chan <- newBroadcastTChanIO
  thread <- async $ notifierLoop eventLogPath chan
  pure $ Notifier chan thread

-- | Stop the notifier thread
shutdownNotifier :: Notifier -> IO ()
shutdownNotifier = cancel . notifierThread

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

-- | Reload new events from disk into memory
-- This is called when the file watcher detects changes
reloadEventsFromDisk :: FilesystemStoreHandle -> IO ()
reloadEventsFromDisk handle = do
  entries <- readLogEntries handle
  let completedEvents = Map.elems $ processLogEntries entries

  atomically $ do
    state <- readTVar handle.stateVar
    let currentMaxSeq = state.nextSequence - 1
        newEvents = [e | es <- completedEvents, e <- es, e.seqNo > currentMaxSeq]
        newMaxSeq = maximum $ currentMaxSeq : [e.seqNo | e <- newEvents]

    when (not $ null newEvents) $ do
      -- Update state with new events
      let newState = foldr updateState state newEvents
      writeTVar handle.stateVar newState {nextSequence = newMaxSeq + 1}

      -- Update global notification
      writeTVar newState.globalNotification newMaxSeq

-- | Custom subscription for filesystem that reloads events from disk
subscribeFilesystem ::
  forall m ts.
  (MonadUnliftIO m) =>
  FilesystemStoreHandle ->
  EventMatcher ts FilesystemStore m ->
  EventSelector FilesystemStore ->
  m (SubscriptionHandle FilesystemStore)
subscribeFilesystem handle matcher selector = do
  -- Get a personal channel from the notifier's broadcast
  tickChannel <- liftIO $ atomically $ dupTChan (notifierChannel handle.notifier)

  -- Fork a background thread that reloads events when notified
  reloadThread <- liftIO $ forkIO $ forever $ do
    -- Wait for file change notification
    atomically $ readTChan tickChannel
    -- Reload events from disk into memory
    reloadEventsFromDisk handle

  -- Use the common subscription logic (now it will see reloaded events)
  subscriptionHandle <- subscribeToEvents handle.stateVar matcher selector

  -- Return a handle that cancels both the reload thread and subscription
  pure $
    SubscriptionHandle
      { cancel = do
          killThread reloadThread
          subscriptionHandle.cancel
      }

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

  insertEvents handle corrId batches = liftIO $ do
    txId <- UUID.nextRandom
    now <- getCurrentTime

    -- Execute version check and state update atomically
    result <- atomically $ do
      state <- readTVar handle.stateVar
      case checkAllVersions state batches of
        Left err -> pure $ Left err
        Right () -> do
          let eventIds = replicate (sum $ map (length . (.events)) $ Map.elems batches) (EventId txId)
              (newState, finalCursor) = insertAllEvents state corrId now eventIds batches
              newEvents =
                [ event
                  | event <- Map.elems newState.events,
                    not $ Map.member event.seqNo state.events
                ]
          writeTVar handle.stateVar newState
          pure $ Right (newState, finalCursor, newEvents)

    case result of
      Left err -> pure $ FailedInsertion err
      Right (newState, finalCursor, newEvents) -> do
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

        pure $ SuccessfulInsertion finalCursor

  subscribe = subscribeFilesystem

instance StoreCursor FilesystemStore where
  makeCursor = FilesystemCursor
  makeSequenceNo = (.getSequenceNo)
