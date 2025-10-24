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

{- |
Module      : Hindsight.Store.Filesystem
Description : File-based persistent event store with multi-process support
Copyright   : (c) 2024
License     : BSD3
Maintainer  : maintainer@example.com
Stability   : experimental

= Overview

File-based event store persisting events as JSON on disk. Provides durability without
requiring a database. Suitable for single-node deployments with moderate event volumes.

Events stored in append-only @events.log@ file. Multi-process support via file locking
and fsnotify change detection.

= Quick Start

@
import Hindsight.Store.Filesystem

main :: IO ()
main = do
  -- Create store with default config
  config <- mkDefaultConfig "./events"
  store <- newFilesystemStore config

  -- Insert events (see Hindsight.Store for details)
  streamId <- StreamId \<$\> UUID.nextRandom
  let event = mkEvent MyEvent myData
  result <- insertEvents store Nothing $ singleEvent streamId NoStream event

  -- Subscribe to events
  handle <- subscribe store matcher (EventSelector AllStreams FromBeginning)
  -- ... process events ...

  -- Cleanup when done
  cleanupFilesystemStore store
@

= Configuration

'FilesystemStoreConfig' has three parameters:

* @storePath@ - Directory for event log and lock file
* @syncInterval@ - Disk sync frequency (microseconds, 0 = sync every write)
* @lockTimeout@ - Max time to wait for file lock (microseconds)

Use 'mkDefaultConfig' for sensible defaults or construct manually for custom settings.

= Use Cases

__When to use Filesystem store:__

* Single-node applications requiring durability
* Development/staging environments
* Embedded systems or edge deployments
* Apps that can't run PostgreSQL (resource constraints, deployment complexity)
* Multi-process applications on same host

__When NOT to use Filesystem store:__

* Distributed multi-node systems (use PostgreSQL)
* Very high event throughput (PostgreSQL performs better)
* Large event volumes (startup replay becomes slow)

= Trade-offs

__Advantages:__

* Events survive process restarts (durable)
* No database dependency
* Multi-process support on same host
* Simple deployment (just a directory)
* ACID guarantees via file locking

__Limitations:__

* Startup time grows with event count (linear log replay)
* All indices must fit in memory
* Single-node only (no distributed support)
* Performance limited by disk I/O
* Not suitable for very large datasets

= Implementation

Persistence layer over Memory store infrastructure. Events written to disk then loaded
into in-memory STM structures. File locking serializes writes. fsnotify detects changes
from other processes for incremental reloading.

Storage format: Append-only JSON log (@events.log@), one transaction per line.
Stream indices rebuilt on startup by replaying log.
-}
module Hindsight.Store.Filesystem (
    -- * Store Types
    FilesystemStore,
    FilesystemStoreHandle,
    FilesystemCursor (..),

    -- * Configuration
    FilesystemStoreConfig (..),
    mkDefaultConfig,
    getStoreConfig,

    -- * Store Operations
    newFilesystemStore,
    cleanupFilesystemStore,

    -- * Exceptions
    StoreException (..),

    -- * Testing Support
    EventLogEntry (..),
    StorePaths (..),
    getPaths,
)
where

import Control.Concurrent (threadDelay)
import Control.Concurrent.Async (Async, async, cancel)
import UnliftIO.Async (race_)
import Control.Concurrent.STM (
    TChan,
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
import Control.Exception (Exception, SomeException, bracket, displayException, throwIO, try)
import Control.Monad (forM_, forever, void, when)
import Control.Monad.IO.Class (liftIO)
import Data.Aeson (FromJSON, ToJSON (..), decode, encode)
import Data.ByteString qualified as BS -- Strict ByteString for file operations
import Data.ByteString.Char8 qualified as BS8
import Data.ByteString.Lazy qualified as BL
import Data.ByteString.Lazy.Char8 qualified as BL8
import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Maybe (catMaybes, listToMaybe)
import Data.Text (pack)
import Data.Time (UTCTime, getCurrentTime)
import Data.UUID (UUID)
import Data.UUID.V4 qualified as UUID
import UnliftIO (MonadUnliftIO)

-- (StoredEvent (..), StoreCursor (..), StoreState (..), updateState)

import GHC.Generics (Generic)
import Hindsight.Store (
    BackendHandle,
    Cursor,
    ErrorInfo (..),
    EventId (EventId),
    EventMatcher,
    EventSelector (..),
    EventStore (..),
    EventStoreError (BackendError),
    InsertionResult (FailedInsertion, SuccessfulInsertion),
    InsertionSuccess (..),
    StreamWrite (events),
    SubscriptionHandle (..),
    Transaction (..),
 )
import Hindsight.Store.Memory.Internal (
    StoreCursor (..),
    StoreState (..),
    StoredEvent (seqNo),
    checkAllVersions,
    insertAllEvents,
    subscribeToEvents,
    updateState,
 )
import System.Directory (canonicalizePath, createDirectoryIfMissing, doesFileExist, removeFile)
import System.FSNotify (Event (..), eventPath, watchDir, withManager)
import System.FileLock qualified as FL
import System.FilePath (takeDirectory, (</>))

-- No System.IO imports needed - using lazy ByteString operations instead
import System.Timeout (timeout)

-- | Configuration for filesystem store
data FilesystemStoreConfig = FilesystemStoreConfig
    { storePath :: FilePath
    -- ^ Base directory for store files
    , syncInterval :: Int
    -- ^ How often to sync to disk (number of writes)
    , lockTimeout :: Int
    -- ^ Timeout for acquiring locks (microseconds)
    }
    deriving (Show, Eq, Generic)
    deriving anyclass (FromJSON, ToJSON)

-- | An entry in our event log represents a transaction state change.
data EventLogEntry = EventLogEntry
    { transactionId :: UUID
    -- ^ Unique transaction identifier
    , events :: [StoredEvent]
    -- ^ Events written in this transaction
    , timestamp :: UTCTime
    -- ^ When the transaction was written
    }
    deriving stock (Show, Eq, Generic)
    deriving anyclass (FromJSON, ToJSON)

-- | Cursor for filesystem store.
newtype FilesystemCursor = FilesystemCursor
    { getSequenceNo :: Integer
    -- ^ Global sequence number for event ordering
    }
    deriving (Show, Eq, Ord, Generic)
    deriving anyclass (FromJSON, ToJSON)

{- | Notifier for cross-process event notifications.

Watches the event log file and broadcasts changes to subscribers.
The central reload thread updates the in-memory state when files change.
-}
data Notifier = Notifier
    { notifierThread :: Async ()
    -- ^ File watcher thread using fsnotify
    , reloadThread :: Async ()
    -- ^ Central reload thread (one per store) that updates in-memory state
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

-- | Handle for filesystem store operations.
data FilesystemStoreHandle = FilesystemStoreHandle
    { config :: FilesystemStoreConfig
    -- ^ Store configuration
    , stateVar :: TVar (StoreState FilesystemStore)
    -- ^ In-memory event store state
    , notifier :: Notifier
    -- ^ File watcher and reload threads
    }

-- | File paths used by the store.
data StorePaths = StorePaths
    { eventLogPath :: FilePath
    -- ^ Path to the append-only event log file
    , storeLockPath :: FilePath
    -- ^ Path to the lock file for write coordination
    }

-- | Compute file paths for store files within a base directory.
getPaths ::
    -- | Base directory for the store
    FilePath ->
    -- | Computed file paths
    StorePaths
getPaths base =
    StorePaths
        { eventLogPath = base </> "events.log"
        , storeLockPath = base </> "store.lock"
        }

{- | Create a default configuration for a filesystem store.

Defaults: sync every write, 5-second lock timeout.
-}
mkDefaultConfig ::
    -- | Base directory for store files
    FilePath ->
    -- | Configuration with defaults
    FilesystemStoreConfig
mkDefaultConfig path =
    FilesystemStoreConfig
        { storePath = path
        , syncInterval = 1 -- Sync every write by default
        , lockTimeout = 5000000 -- 5 seconds (only used for writes now)
        }

{- | Get the configuration from a store handle.

Useful for accessing the store path during cleanup or creating additional instances.
-}
getStoreConfig ::
    -- | Store handle
    FilesystemStoreHandle ->
    -- | Store configuration
    FilesystemStoreConfig
getStoreConfig = (.config)

-- | Creates required directories
ensureDirectories :: FilePath -> IO ()
ensureDirectories path = do
    let dir = takeDirectory path
    createDirectoryIfMissing True dir

{- | Safely perform operations with global store lock (direct config version)
Used by central reload thread which doesn't have access to handle
-}
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

{- | Initialize or open a filesystem store.

Creates the store directory and event log file if they don't exist.
If the event log exists and contains events, automatically reloads them
into memory. Starts file watchers for cross-process event notifications.

This function handles both fresh stores and reopening existing stores,
making it suitable for process restarts and multi-instance deployments.
-}
newFilesystemStore ::
    -- | Store configuration
    FilesystemStoreConfig ->
    -- | Initialized store handle
    IO FilesystemStoreHandle
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
                { nextSequence = 0
                , events = Map.empty
                , streamEvents = Map.empty
                , streamVersions = Map.empty
                , streamLocalVersions = Map.empty
                , streamNotifications = Map.empty
                , globalNotification = globalVar
                }

    -- CRITICAL: Initial load MUST happen BEFORE starting reload thread to avoid data race
    -- Use LOCKED read (strict mode) - corruption at startup is fatal, no concurrent access yet
    reloadResult <- try @StoreException $ do
        logExists <- doesFileExist paths.eventLogPath
        when logExists $ do
            -- Use withStoreLockDirect for locked, atomic snapshot
            entries <- withStoreLockDirect config $ do
                contents <- BL.readFile paths.eventLogPath
                decodeLogEntriesStrict paths.eventLogPath contents True  -- strict=True

            let completedEvents = Map.elems $ processLogEntries entries
                maxSeqNo = maximum $ 0 : [e.seqNo | es <- completedEvents, e <- es]

            when (not $ null completedEvents) $ atomically $ do
                -- Update store state with completed events
                modifyTVar' stateVar $ \state ->
                    foldr
                        (flip (foldr updateState))
                        state{nextSequence = maxSeqNo + 1}
                        completedEvents

                -- Get the state to access its globalNotification TVar
                state <- readTVar stateVar
                -- Update the global notification to match the last event
                writeTVar state.globalNotification maxSeqNo

    case reloadResult of
        Right () -> pure ()
        Left (LockTimeout _) -> pure () -- Should not happen during startup, but handle it
        Left (CorruptEventLog path reason) -> throwIO $ CorruptEventLog path reason -- Fatal error

    -- Start the file watcher notifier with central reload thread
    -- Now safe: initial load complete, stateVar populated, no data race
    notifier <- startNotifier paths.eventLogPath stateVar config

    let handle = FilesystemStoreHandle{..}
    pure handle

{- | Decode log entries with configurable strictness.

Empty lines are skipped (normal for newline-delimited JSON format).
Non-empty unparseable lines in the MIDDLE of the file are ALWAYS FATAL (CorruptEventLog).

Behavior for unparseable FINAL line depends on strictness:
- Strict mode (initial load): FATAL - corruption detected immediately
- Lenient mode (incremental reload): Skip gracefully - assumes partial write in progress

This enables lock-free concurrent reads while maintaining corruption detection at startup.
-}
decodeLogEntriesStrict :: FilePath -> BL.ByteString -> Bool -> IO [EventLogEntry]
decodeLogEntriesStrict path contents strictMode = do
    let lines' = BL8.split '\n' contents
        nonEmptyLines = filter (not . BL.null) lines'
        totalLines = length nonEmptyLines
    catMaybes <$> mapM (decodeOne totalLines) (zip [1 ..] nonEmptyLines)
  where
    decodeOne :: Int -> (Integer, BL.ByteString) -> IO (Maybe EventLogEntry)
    decodeOne totalLines (lineNum, line) =
        case decode line of
            Just entry -> pure (Just entry)
            Nothing
                | lineNum == fromIntegral totalLines && not strictMode ->
                    -- Last line unparseable in lenient mode - likely partial write, skip it
                    pure Nothing
                | otherwise ->
                    -- Corrupted line - fatal error
                    throwIO $
                        CorruptEventLog path $
                            "Failed to parse JSON at line "
                                ++ show lineNum
                                ++ " of "
                                ++ show totalLines
                                ++ ": "
                                ++ take 100 (BL8.unpack line)

-- | Process log entries and return completed transactions
processLogEntries :: [EventLogEntry] -> Map UUID [StoredEvent]
processLogEntries entries = Map.fromList [(e.transactionId, e.events) | e <- entries]

{- | Read and parse all entries from the event log

Throws CorruptEventLog if any entry fails to parse.
Uses STRICT mode - corruption is always fatal in this context.
-}
readLogEntries :: FilesystemStoreHandle -> IO [EventLogEntry]
readLogEntries handle =
    withStoreLock handle $ do
        let paths = getPaths handle.config.storePath
        contents <- BL.readFile paths.eventLogPath
        decodeLogEntriesStrict paths.eventLogPath contents True  -- strict=True

{- | Start the file watcher notifier thread
Watches the event log for modifications and broadcasts to subscribers
Also starts the central reload thread that updates in-memory state
-}
startNotifier :: FilePath -> TVar (StoreState FilesystemStore) -> FilesystemStoreConfig -> IO Notifier
startNotifier eventLogPath stateVar config = do
    chan <- newBroadcastTChanIO

    -- File watcher thread - broadcasts when file changes
    notifyThread <- async $ notifierLoop eventLogPath chan

    -- Central reload thread - responds to broadcasts OR periodic polling
    -- Lock-free reads mean contention is no longer an issue, but we keep
    -- periodic polling (10s) as a fallback in case fsnotify misses events
    reloadChan <- atomically $ dupTChan chan
    reloadThread <- async $ forever $ do
        race_
            (atomically $ readTChan reloadChan)  -- Wait for fsnotify
            (threadDelay 10000000)                -- OR 10-second timeout
        reloadEventsFromDiskCentralWithRetry stateVar config 0

    pure $ Notifier notifyThread reloadThread

-- | Stop the notifier threads
shutdownNotifier :: Notifier -> IO ()
shutdownNotifier notifier = do
    cancel notifier.notifierThread -- Stop file watcher
    cancel notifier.reloadThread -- Stop reload thread

{- | Main loop for the notifier
Uses fsnotify to watch for file modifications
-}
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

{- | Wrapper for reloadEventsFromDiskCentral that handles CorruptEventLog

Since reads are now lock-free, LockTimeout can't happen here.
Only CorruptEventLog needs handling (FATAL - terminates reload thread).
-}
reloadEventsFromDiskCentralWithRetry :: TVar (StoreState FilesystemStore) -> FilesystemStoreConfig -> Int -> IO ()
reloadEventsFromDiskCentralWithRetry stateVar config _retryCount = do
    result <- try @StoreException $ reloadEventsFromDiskCentral stateVar config
    case result of
        Right () -> pure ()
        Left (CorruptEventLog path reason) -> do
            -- FATAL ERROR: Event log corruption indicates either a serious bug or external tampering
            -- DO NOT retry, DO NOT swallow - this requires operator intervention
            putStrLn $ "FATAL: Event log corrupted at " ++ path
            putStrLn $ "Reason: " ++ reason
            putStrLn "This indicates either a serious bug in the event store or external process tampering."
            putStrLn "The reload thread will now terminate. Manual intervention is required."
            throwIO $ CorruptEventLog path reason
        Left (LockTimeout path) ->
            -- Should never happen since reads are lock-free now, but handle it anyway
            putStrLn $ "UNEXPECTED: LockTimeout during lock-free read on " ++ path

{- | Reload new events from disk into the in-memory store state
Called by the notifier's reload thread when file changes are detected

LOCK-FREE: Reads file without locking for zero contention.
Partial writes at EOF are gracefully skipped by decodeLogEntriesStrict.

Uses STRICT ByteString to ensure file handle is closed immediately.
Throws CorruptEventLog if middle-of-file corruption detected (FATAL).
-}
reloadEventsFromDiskCentral :: TVar (StoreState FilesystemStore) -> FilesystemStoreConfig -> IO ()
reloadEventsFromDiskCentral stateVar config = do
    -- LOCK-FREE READ: No withStoreLock here!
    -- Concurrent reads are safe on Unix. Partial writes handled by parser.
    let paths = getPaths config.storePath
    contents <- BS.readFile paths.eventLogPath
    entries <- decodeLogEntriesStrict paths.eventLogPath (BL.fromStrict contents) False  -- strict=False (lenient)

    let completedEvents = Map.elems $ processLogEntries entries

    atomically $ do
        state <- readTVar stateVar
        let currentMaxSeq = state.nextSequence - 1
            newEvents = [e | es <- completedEvents, e <- es, e.seqNo > currentMaxSeq]
            newMaxSeq = maximum $ currentMaxSeq : [e.seqNo | e <- newEvents]

        when (not $ null newEvents) $ do
            -- Update state with new events
            let newState = foldr updateState state newEvents
            writeTVar stateVar newState{nextSequence = newMaxSeq + 1}

            -- Update global notification
            writeTVar newState.globalNotification newMaxSeq

{- | Subscribe to events from the filesystem store
The notifier's reload thread keeps the in-memory state updated,
so subscriptions just read from the shared state variable
-}
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

{- | Cleanup store resources and shut down background threads.

Stops file watchers and removes the lock file. Call this before
application shutdown to ensure clean termination.
-}
cleanupFilesystemStore ::
    -- | Store handle to clean up
    FilesystemStoreHandle ->
    IO ()
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

        -- All critical operations happen inside the file lock to prevent cross-instance races
        result <- try $ withStoreLock handle $ do
            -- Phase 1: Read ONLY max sequence number from disk (source of truth for cross-instance)
            -- We just need the last transaction entry, which contains the highest seqNos
            -- ASSUMPTION: Each log entry is exactly one line (Aeson's encode produces compact JSON
            -- without newlines; any newlines in event data are escaped as \n per JSON spec)
            diskMaxSeq <- do
                let paths = getPaths handle.config.storePath
                diskContents <- BS.readFile paths.eventLogPath
                let lastLine = listToMaybe $ reverse $ filter (not . BS.null) $ BS8.split '\n' diskContents
                    lastEntry :: Maybe EventLogEntry
                    lastEntry = lastLine >>= decode . BL.fromStrict
                    lastSeqNos = maybe [] (\entry -> map seqNo entry.events) lastEntry
                pure $ maximum $ (-1) : lastSeqNos

            -- Phase 2: Check versions and generate sequence numbers based on DISK max
            versionCheckResult <- atomically $ do
                state <- readTVar handle.stateVar
                case checkAllVersions state batches of
                    Left err -> pure $ Left err
                    Right () -> do
                        -- Use max(STM nextSeq, disk maxSeq + 1) to handle both fresh state and stale STM
                        let actualNextSeq = max state.nextSequence (diskMaxSeq + 1)
                            stateWithCorrectSeq = state{nextSequence = actualNextSeq}
                            eventIds = replicate (sum $ map (length . (.events)) $ Map.elems batches) (EventId txId)
                            (newState, finalCursor, streamCursors) = insertAllEvents stateWithCorrectSeq corrId now eventIds batches
                            newEvents =
                                [ event
                                | event <- Map.elems newState.events
                                , not $ Map.member event.seqNo stateWithCorrectSeq.events
                                ]
                        pure $ Right (newState, finalCursor, streamCursors, newEvents)

            case versionCheckResult of
                Left err -> pure $ Left err
                Right (newState, finalCursor, streamCursors, newEvents) -> do
                    -- Phase 2: Write to disk
                    let paths = getPaths handle.config.storePath
                        jsonLine = BL.toStrict (encode $ EventLogEntry txId newEvents now) <> "\n"
                    BS.appendFile paths.eventLogPath jsonLine

                    -- Phase 3: Update STM state (still inside lock!)
                    liftIO $ atomically $ do
                        writeTVar handle.stateVar newState

                        -- Update notifications
                        forM_ (Map.keys batches) $ \streamId ->
                            forM_ (Map.lookup streamId newState.streamNotifications) $ \var ->
                                writeTVar var (getSequenceNo finalCursor)

                        writeTVar newState.globalNotification (getSequenceNo finalCursor)

                    pure $ Right (finalCursor, streamCursors)

        case result of
            Left (e :: SomeException) ->
                -- Lock timeout, disk write, or STM update failed
                pure $
                    FailedInsertion $
                        BackendError $
                            ErrorInfo
                                { errorMessage = pack $ "Failed to persist events: " <> displayException e
                                , exception = Just e
                                }
            Right (Left err) ->
                -- Version check failed
                pure $ FailedInsertion err
            Right (Right (finalCursor, streamCursors)) ->
                -- Success: both disk and STM updated atomically under lock
                pure $
                    SuccessfulInsertion $
                        InsertionSuccess
                            { finalCursor = finalCursor
                            , streamCursors = streamCursors
                            }

    subscribe = subscribeFilesystem

instance StoreCursor FilesystemStore where
    makeCursor = FilesystemCursor
    makeSequenceNo = (.getSequenceNo)
