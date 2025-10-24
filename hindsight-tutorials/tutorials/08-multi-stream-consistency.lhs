Cross-Stream Consistency
========================

Event sourcing with multiple streams creates challenges for invariants that span aggregates
(e.g., email uniqueness, capacity limits). Two patterns solve this: **SQL constraints** for
simple invariants, and **multi-stream transactions** for coordinated updates.

Prerequisites
-------------

\begin{code}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE RequiredTypeArguments #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Main where

import Control.Monad (void)
import Data.Aeson (FromJSON, ToJSON)
import Data.Map.Strict qualified as Map
import Data.Text (Text)
import Data.Text qualified as Text
import Data.Text.Encoding qualified as Text
import Data.UUID (UUID)
import Database.Postgres.Temp qualified as Temp
import GHC.Generics (Generic)
import Hasql.Connection.Setting qualified as ConnectionSetting
import Hasql.Connection.Setting.Connection qualified as ConnectionSettingConnection
import Hasql.Pool qualified as Pool
import Hasql.Pool.Config qualified as Config
import Hasql.Session qualified as Session
import Hasql.TH (resultlessStatement)
import Hasql.Transaction qualified as Transaction
import Hindsight
import Hindsight.Projection (ProjectionId(..))
import Hindsight.Projection.Matching (ProjectionHandlers (..))
import Hindsight.Store.PostgreSQL
  ( SQLStore,
    createSQLSchema,
    emptySyncProjectionRegistry,
    newSQLStoreWithProjections,
    registerSyncProjection,
    shutdownSQLStore,
  )
import Data.Int (Int32)
import Data.Proxy (Proxy (..))
\end{code}

Pattern 1: SQL Constraints for Uniqueness
------------------------------------------

Email uniqueness is a cross-stream invariant: no two users can share an email.
Use synchronous projections with SQL UNIQUE constraints.

Define Events
-------------

\begin{code}
type UserRegistered = "user_registered"

data UserInfo = UserInfo
  { userId :: UUID,
    email :: Text,
    name :: Text
  }
  deriving (Show, Eq, Generic, FromJSON, ToJSON)

type instance MaxVersion UserRegistered = 0
type instance Versions UserRegistered = '[UserInfo]
instance Event UserRegistered
instance MigrateVersion 0 UserRegistered

-- Helper
registerUser :: UUID -> Text -> Text -> SomeLatestEvent
registerUser uid email name =
  mkEvent UserRegistered (UserInfo uid email name)
\end{code}

Course Enrollment Example
-------------------------

We'll also use a course enrollment scenario to show multi-stream coordination:

\begin{code}
type CourseCreated = "course_created"
type StudentEnrolled = "student_enrolled"

data CourseInfo = CourseInfo
  { courseId :: UUID,
    courseName :: Text,
    maxCapacity :: Int32
  }
  deriving (Show, Eq, Generic, FromJSON, ToJSON)

data EnrollmentInfo = EnrollmentInfo
  { courseId :: UUID,
    studentId :: UUID
  }
  deriving (Show, Eq, Generic, FromJSON, ToJSON)

type instance MaxVersion CourseCreated = 0
type instance Versions CourseCreated = '[CourseInfo]
instance Event CourseCreated
instance MigrateVersion 0 CourseCreated

type instance MaxVersion StudentEnrolled = 0
type instance Versions StudentEnrolled = '[EnrollmentInfo]
instance Event StudentEnrolled
instance MigrateVersion 0 StudentEnrolled

-- Helpers
createCourse :: UUID -> Text -> Int32 -> SomeLatestEvent
createCourse cid name cap =
  mkEvent CourseCreated (CourseInfo cid name cap)

enrollStudent :: UUID -> UUID -> SomeLatestEvent
enrollStudent cid sid =
  mkEvent StudentEnrolled (EnrollmentInfo cid sid)
\end{code}

Synchronous Projection with UNIQUE Constraint
----------------------------------------------

The projection runs in the same transaction as event insertion. SQL constraints
reject events that violate business rules:

\begin{code}
-- Projection schema with UNIQUE constraint
createUserProjectionSchema :: Session.Session ()
createUserProjectionSchema = Session.sql $
  Text.encodeUtf8 $ Text.unlines
    [ "CREATE TABLE IF NOT EXISTS users (",
      "  user_id UUID PRIMARY KEY,",
      "  email TEXT NOT NULL UNIQUE,",  -- ← Enforces uniqueness!
      "  name TEXT NOT NULL",
      ");"
    ]

-- Projection handlers
userProjection :: ProjectionHandlers '[UserRegistered] SQLStore
userProjection =
  (Proxy @UserRegistered, userRegisteredHandler)
  :-> ProjectionEnd
  where
    userRegisteredHandler envelope =
      Transaction.statement
        ( envelope.payload.userId,
          envelope.payload.email,
          envelope.payload.name
        )
        [resultlessStatement|
          INSERT INTO users (user_id, email, name)
          VALUES ($1 :: uuid, $2 :: text, $3 :: text)
        |]
\end{code}

If the email already exists, the UNIQUE constraint causes a transaction rollback,
and the event is rejected.

Demonstration
-----------------------------------

\begin{code}
demoEmailUniqueness :: IO ()
demoEmailUniqueness = do
  putStrLn "\n=== Demo: Email Uniqueness via SQL Constraints ==="

  -- Create temporary PostgreSQL database
  result <- Temp.startConfig Temp.defaultConfig

  case result of
    Left err -> putStrLn $ "Failed to start temp DB: " <> show err
    Right db -> do
      let connStr = Temp.toConnectionString db
          connectionSettings = [ConnectionSetting.connection $ ConnectionSettingConnection.string (Text.decodeUtf8 connStr)]

      -- Create connection pool
      pool <-
        Pool.acquire $
          Config.settings
            [ Config.size 10,
              Config.staticConnectionSettings connectionSettings
            ]

      -- Create event store schema
      void $ Pool.use pool (createSQLSchema >> createUserProjectionSchema)

      -- Register synchronous projection
      let registry = registerSyncProjection
            (ProjectionId "user_projection")
            userProjection
            emptySyncProjectionRegistry

      -- Create store with synchronous projections
      store <- newSQLStoreWithProjections connStr registry

      -- Try to register first user
      let aliceId = read "00000000-0000-0000-0000-000000000001"
      let aliceStream = StreamId aliceId

      result1 <- insertEvents store Nothing $
        Transaction $ Map.singleton aliceStream
          (StreamWrite NoStream [registerUser aliceId "alice@example.com" "Alice"])

      case result1 of
        SuccessfulInsertion _ ->
          putStrLn "  ✓ Alice registered successfully"
        FailedInsertion err ->
          putStrLn $ "  ✗ Alice registration failed: " <> show err

      -- Try to register another user with SAME email
      let bobId = read "00000000-0000-0000-0000-000000000002"
      let bobStream = StreamId bobId

      result2 <- insertEvents store Nothing $
        Transaction $ Map.singleton bobStream
          (StreamWrite NoStream [registerUser bobId "alice@example.com" "Bob"])

      case result2 of
        SuccessfulInsertion _ ->
          putStrLn "  ✗ Bob registered (SHOULD HAVE FAILED!)"
        FailedInsertion (BackendError _) ->
          putStrLn "  ✓ Bob registration rejected (email conflict) ← Expected!"
        FailedInsertion err ->
          putStrLn $ "  ? Bob registration failed: " <> show err

      -- Try Bob with different email - should succeed
      result3 <- insertEvents store Nothing $
        Transaction $ Map.singleton bobStream
          (StreamWrite NoStream [registerUser bobId "bob@example.com" "Bob"])

      case result3 of
        SuccessfulInsertion _ ->
          putStrLn "  ✓ Bob registered with different email"
        FailedInsertion err ->
          putStrLn $ "  ✗ Bob registration failed: " <> show err

      -- Cleanup
      shutdownSQLStore store
      void $ Temp.stop db
\end{code}

Pattern 2: Multi-Stream Transactions
-------------------------------------

For complex invariants, combine SQL CHECK constraints with multi-stream atomic inserts.
Example: course enrollment with capacity limits.
------------------------------------------------

\begin{code}
-- Projection schemas
createCourseProjectionSchema :: Session.Session ()
createCourseProjectionSchema = Session.sql $
  Text.encodeUtf8 $ Text.unlines
    [ "CREATE TABLE IF NOT EXISTS courses (",
      "  course_id UUID PRIMARY KEY,",
      "  course_name TEXT NOT NULL,",
      "  max_capacity INT NOT NULL,",
      "  enrollment_count INT DEFAULT 0,",
      "  CHECK (enrollment_count <= max_capacity)",
      ");",
      "",
      "CREATE TABLE IF NOT EXISTS enrollments (",
      "  course_id UUID NOT NULL,",
      "  student_id UUID NOT NULL,",
      "  PRIMARY KEY (course_id, student_id)",
      ");"
    ]

-- Projection handlers
courseProjection :: ProjectionHandlers '[CourseCreated, StudentEnrolled] SQLStore
courseProjection =
  (Proxy @CourseCreated, courseCreatedHandler)
  :-> (Proxy @StudentEnrolled, studentEnrolledHandler)
  :-> ProjectionEnd
  where
    courseCreatedHandler envelope =
      Transaction.statement
        ( envelope.payload.courseId,
          envelope.payload.courseName,
          envelope.payload.maxCapacity
        )
        [resultlessStatement|
          INSERT INTO courses (course_id, course_name, max_capacity)
          VALUES ($1 :: uuid, $2 :: text, $3 :: int)
        |]

    studentEnrolledHandler envelope = do
      Transaction.statement
        ( envelope.payload.courseId,
          envelope.payload.studentId
        )
        [resultlessStatement|
          INSERT INTO enrollments (course_id, student_id)
          VALUES ($1 :: uuid, $2 :: uuid)
        |]

      Transaction.statement
        envelope.payload.courseId
        [resultlessStatement|
          UPDATE courses
          SET enrollment_count = enrollment_count + 1
          WHERE course_id = $1 :: uuid
        |]
\end{code}

Demo: Multi-Stream Coordination
--------------------------------

\begin{code}
demoMultiStreamEnrollment :: IO ()
demoMultiStreamEnrollment = do
  putStrLn "\n=== Demo: Multi-Stream Course Enrollment ==="

  result <- Temp.startConfig Temp.defaultConfig

  case result of
    Left err -> putStrLn $ "Failed to start temp DB: " <> show err
    Right db -> do
      let connStr = Temp.toConnectionString db
          connectionSettings = [ConnectionSetting.connection $ ConnectionSettingConnection.string (Text.decodeUtf8 connStr)]

      pool <-
        Pool.acquire $
          Config.settings
            [ Config.size 10,
              Config.staticConnectionSettings connectionSettings
            ]

      void $ Pool.use pool (createSQLSchema >> createCourseProjectionSchema)

      let registry =
            registerSyncProjection
              (ProjectionId "course_projection")
              courseProjection
              emptySyncProjectionRegistry

      store <- newSQLStoreWithProjections connStr registry

      -- Create course with capacity = 2
      let courseId = read "00000000-0000-0000-0000-000000000010"
      let courseStream = StreamId courseId

      result1 <- insertEvents store Nothing $
        Transaction $ Map.singleton courseStream
          (StreamWrite NoStream [createCourse courseId "Haskell 101" 2])

      case result1 of
        SuccessfulInsertion (InsertionSuccess{streamCursors = cursors1}) -> do
          let courseCursor = cursors1 Map.! courseStream
          putStrLn "  ✓ Course created (capacity: 2)"

          -- Enroll first student
          let student1Id = read "00000000-0000-0000-0000-000000000101"
          let student1Stream = StreamId student1Id

          result2 <- insertEvents store Nothing $
            Transaction $ Map.fromList
              [ (courseStream, StreamWrite (ExactVersion courseCursor) [enrollStudent courseId student1Id]),
                (student1Stream, StreamWrite NoStream [registerUser student1Id "s1@example.com" "Student 1"])
              ]

          case result2 of
            SuccessfulInsertion (InsertionSuccess{streamCursors = cursors2}) -> do
              let courseCursor2 = cursors2 Map.! courseStream
              putStrLn "  ✓ Student 1 enrolled (1/2 capacity)"

              -- Enroll second student
              let student2Id = read "00000000-0000-0000-0000-000000000102"
              let student2Stream = StreamId student2Id

              result3 <- insertEvents store Nothing $
                Transaction $ Map.fromList
                  [ (courseStream, StreamWrite (ExactVersion courseCursor2) [enrollStudent courseId student2Id]),
                    (student2Stream, StreamWrite NoStream [registerUser student2Id "s2@example.com" "Student 2"])
                  ]

              case result3 of
                SuccessfulInsertion (InsertionSuccess{streamCursors = cursors3}) -> do
                  let courseCursor3 = cursors3 Map.! courseStream
                  putStrLn "  ✓ Student 2 enrolled (2/2 capacity - FULL)"

                  -- Try to enroll third student
                  -- The CHECK constraint will reject this atomically, preventing race conditions
                  let student3Id = read "00000000-0000-0000-0000-000000000103"
                  let student3Stream = StreamId student3Id

                  result4 <- insertEvents store Nothing $
                    Transaction $ Map.fromList
                      [ (courseStream, StreamWrite (ExactVersion courseCursor3) [enrollStudent courseId student3Id]),
                        (student3Stream, StreamWrite NoStream [registerUser student3Id "s3@example.com" "Student 3"])
                      ]

                  case result4 of
                    SuccessfulInsertion _ ->
                      putStrLn "  ✗ Student 3 enrolled (SHOULD HAVE BEEN REJECTED)"
                    FailedInsertion err ->
                      putStrLn $ "  ✓ Student 3 rejected by CHECK constraint: " <> show err

                FailedInsertion err ->
                  putStrLn $ "  ✗ Student 2 enrollment failed: " <> show err

            FailedInsertion err ->
              putStrLn $ "  ✗ Student 1 enrollment failed: " <> show err

        FailedInsertion err ->
          putStrLn $ "  ✗ Course creation failed: " <> show err

      shutdownSQLStore store
      void $ Temp.stop db
\end{code}

Running the Examples
--------------------

\begin{code}
main :: IO ()
main = do
  putStrLn "=== Hindsight Tutorial 08: Cross-Stream Consistency ==="

  demoEmailUniqueness
  demoMultiStreamEnrollment

  putStrLn "\n✓ Tutorial complete!"
\end{code}

Summary
-------

Key concepts:

- **SQL constraints** enforce simple invariants (UNIQUE, CHECK) within sync projection transactions
- **Multi-stream transactions** coordinate events across multiple streams with version expectations
- **Combine both** for complex invariants that require multi-stream coordination