Multi-Stream Consistency
========================

Cross-aggregate invariants present a real challenge in event sourcing.

Traditional aggregate-based event sourcing excels at enforcing consistency
*within* a single entity (one stream = one aggregate). But real applications
need invariants that span multiple entities:

**Common Cross-Aggregate Invariants:**

1. **Uniqueness constraints**: No two users can have the same email address
2. **Resource limits**: Course enrollment can't exceed capacity
3. **Foreign key-like rules**: Can't enroll a student in a deleted course
4. **Multi-entity transactions**: Transfer funds between two accounts atomically

**The Problem:**

```
Thread 1: Check email not taken → Insert UserCreated
Thread 2:                          Check email not taken → Insert UserCreated

Result: Two users with same email (race condition!)
```

**Hindsight's Solution:**

Two complementary mechanisms working together:

1. **SQL constraints** (UNIQUE, CHECK, etc.) - Enforced atomically by PostgreSQL
2. **Multi-stream atomic transactions** - Insert to multiple streams with version expectations

Synchronous projections run within the event insertion transaction, allowing
SQL constraints to protect against invariant violations. Multi-stream version
expectations prevent concurrent modifications to coordinated entities.

This pattern is sometimes called "Dynamic Consistency Boundaries" in other
frameworks. In Hindsight, it's implemented using ACID transactions
across multiple event streams with database constraint enforcement.

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
    getPool,
    newSQLStoreWithProjections,
    registerSyncProjection,
    shutdownSQLStore,
  )
import Data.Int (Int32)
import Data.Proxy (Proxy (..))
\end{code}

The Classic Problem: Unique Email Addresses
--------------------------------------------

Let's start with a canonical example: user registration with unique emails.

**The Aggregate Trap**:

In traditional aggregate-based event sourcing, each User is a separate aggregate
with its own stream. But email uniqueness is a **cross-aggregate invariant**:

```
UserStream-123: [UserCreated "alice@example.com"]
UserStream-456: [UserCreated "alice@example.com"]  ← CONFLICT!
```

How do we prevent this?

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
type instance Versions UserRegistered = FirstVersion UserInfo
instance Event UserRegistered
instance UpgradableToLatest UserRegistered 0 where
  upgradeToLatest = id

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
type instance Versions CourseCreated = FirstVersion CourseInfo
instance Event CourseCreated
instance UpgradableToLatest CourseCreated 0 where
  upgradeToLatest = id

type instance MaxVersion StudentEnrolled = 0
type instance Versions StudentEnrolled = FirstVersion EnrollmentInfo
instance Event StudentEnrolled
instance UpgradableToLatest StudentEnrolled 0 where
  upgradeToLatest = id

-- Helpers
createCourse :: UUID -> Text -> Int32 -> SomeLatestEvent
createCourse cid name cap =
  mkEvent CourseCreated (CourseInfo cid name cap)

enrollStudent :: UUID -> UUID -> SomeLatestEvent
enrollStudent cid sid =
  mkEvent StudentEnrolled (EnrollmentInfo cid sid)
\end{code}

Solution 1: Synchronous Projections with SQL Constraints
---------------------------------------------------------

The most elegant solution: let PostgreSQL enforce uniqueness.

**Key Insight**: With synchronous projections, event insertion and projection
updates happen in the **same transaction**. This means SQL constraints can
reject events that violate business rules.

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
        -- If email exists → constraint violation → transaction rollback → event rejected
\end{code}

**What Just Happened?**

1. User tries to register with email "alice@example.com"
2. Event `UserRegistered` is created
3. `insertEvents` begins PostgreSQL transaction
4. Synchronous projection handler executes (in same TX)
5. `INSERT` attempts to add user
6. If email exists: **UNIQUE constraint violation**
7. Transaction **rolls back**
8. `insertEvents` returns `FailedInsertion (BackendError ...)`

**The event never makes it to the store** if the invariant is violated.

Demo: Email Uniqueness Enforcement
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
        SuccessfulInsertion{} ->
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
        SuccessfulInsertion{} ->
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
        SuccessfulInsertion{} ->
          putStrLn "  ✓ Bob registered with different email"
        FailedInsertion err ->
          putStrLn $ "  ✗ Bob registration failed: " <> show err

      -- Cleanup
      shutdownSQLStore store
      void $ Temp.stop db
\end{code}

**Key Takeaway**: SQL constraints give you **zero-overhead** invariant checking.
No queries, no version expectations, just pure database guarantees.

Solution 2: Multi-Stream Version Expectations
----------------------------------------------

For more complex invariants that can't be expressed as SQL constraints, use
**multi-stream atomic transactions** with version expectations.

**The Pattern**:

1. Read current state from projections
2. Check business invariants
3. Insert events to **multiple streams** with version expectations
4. If any stream changed → entire transaction fails

Example: Course Enrollment with Capacity Limits
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
        SuccessfulInsertion{streamCursors = cursors1} -> do
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
            SuccessfulInsertion{streamCursors = cursors2} -> do
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
                SuccessfulInsertion{streamCursors = cursors3} -> do
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
                    SuccessfulInsertion{} ->
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

**The Pattern**:

```haskell
-- Multi-stream atomic insert with version expectations
result <- insertEvents store Nothing $
  Map.fromList
    [ (courseStream, StreamWrite (ExactVersion lastCourseCursor) [enrollment])
    , (studentStream, StreamWrite NoStream [studentData])
    ]

-- If capacity exceeded, synchronous projection fails → entire transaction rolls back
-- If course stream changed concurrently, ExactVersion check fails → retry
```

**What Happens Inside the Transaction**:

1. Event inserted to course stream (with version check)
2. Event inserted to student stream
3. Synchronous projection runs: `UPDATE courses SET enrollment_count = enrollment_count + 1`
4. CHECK constraint validates: `enrollment_count <= max_capacity`
5. If constraint fails → entire transaction rolls back, no events persisted
6. If version expectation fails → entire transaction rolls back, retry with new cursor

Concurrency Protection: Why CHECK Constraints Matter
-----------------------------------------------------

**Without CHECK constraint** (race condition):

```
Thread 1                          Thread 2
--------                          --------
Query capacity: 1 slot free
                                  Query capacity: 1 slot free
Insert enrollment (slot 2/2)
                                  Insert enrollment (slot 3/2) ← OVERBOOKING!
```

Both threads see available capacity, both insert, exceeding limit.

**With CHECK constraint** (atomic enforcement):

```
Thread 1                          Thread 2
--------                          --------
Query capacity: 1 slot free
                                  Query capacity: 1 slot free
BEGIN TRANSACTION                 BEGIN TRANSACTION
  Update count to 2
  CHECK passes (2 <= 2)
COMMIT
                                    Update count to 3
                                    CHECK FAILS (3 > 2) ← REJECTED
                                  ROLLBACK
```

The CHECK constraint enforces the invariant **atomically within the transaction**.
Even if both threads see available capacity, only one can commit.

**Two Distinct Responsibilities**:

In our course enrollment demo, we use **both mechanisms together** for different purposes:

1. **Version expectations** → **Concurrency control**: Serializes access to course stream
   - Prevents lost updates when two threads modify the same stream concurrently
   - Does NOT know anything about capacity - just prevents stale cursor writes

2. **CHECK constraint** → **Invariant enforcement**: Actually enforces capacity rule
   - Validates business rule: `enrollment_count <= max_capacity`
   - Protects against ALL violations: bugs, manual inserts, missing version checks

**They are NOT redundant**:

- Version expectations prevent race conditions (serialization)
- CHECK constraint enforces business rule (capacity limit)

Without CHECK: Could insert with `Any` version expectation and violate capacity
Without version expectations: Could have concurrent inserts that both pass CHECK but create race

**When to Use What**:

- **SQL constraints alone**: Simple invariants (uniqueness, value ranges) - Example 1
- **Version expectations alone**: Coordinating multiple streams without invariants
- **Both together**: Critical invariants + multi-stream coordination - Example 2

Hindsight's Approach to Cross-Aggregate Invariants
----------------------------------------------------

Different event sourcing frameworks handle cross-aggregate invariants differently. Hindsight uses database capabilities directly:

**For Simple Invariants** (uniqueness, value ranges, foreign keys):
- SQL constraints (UNIQUE, CHECK, FOREIGN KEY)
- Enforced atomically within synchronous projection transactions
- Zero additional query overhead

**For Complex Invariants** (capacity limits, multi-entity rules):
- Multi-stream atomic transactions with version expectations
- Read current state from projections
- Insert events to multiple streams with version checks
- Entire transaction fails if any stream changed concurrently

**Hindsight's Design Principles**:

- Leverage PostgreSQL's transactional guarantees rather than rebuilding them
- Use SQL constraints for invariants when possible (fastest, simplest)
- Use version expectations for coordination between streams
- Combine both mechanisms when you need strong guarantees with multi-stream coordination

Running the Examples
--------------------

\begin{code}
main :: IO ()
main = do
  putStrLn "=== Hindsight Tutorial 08: Multi-Stream Consistency ==="

  demoEmailUniqueness
  demoMultiStreamEnrollment

  putStrLn "\n✓ Tutorial complete!"
  putStrLn "\nKey Insights:"
  putStrLn "  • Use SQL constraints for simple invariants (best performance)"
  putStrLn "  • Use multi-stream version expectations for complex coordination"
  putStrLn "  • Combine both for maximum flexibility"
  putStrLn "  • Synchronous projections = consistency + simplicity"
\end{code}

Summary
-------

**Two mechanisms for cross-aggregate consistency**:

1. **SQL constraints** (UNIQUE, CHECK, FOREIGN KEY) - Simple, fast, reliable
2. **Multi-stream atomic transactions** - Coordinate multiple streams with version expectations

**Use SQL constraints when**:
- Enforcing simple invariants (uniqueness, value ranges, foreign keys)
- You want maximum performance
- The invariant maps directly to a database constraint

**Use multi-stream transactions when**:
- Coordinating events across multiple aggregates
- Building sagas or process managers
- You need to track causality across streams

**Use both when**:
- You need strong consistency guarantees for critical invariants
- Defense in depth is required
- Combining stream coordination with invariant enforcement

Hindsight handles cross-aggregate consistency using ACID transactions with synchronous projections.