{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE RequiredTypeArguments #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}

{- |
Module      : Test.Hindsight.Generate
Description : Automated test generation for versioned events
Copyright   : (c) 2025
License     : BSD3

= Problem

Events need tests to verify JSON serialization works correctly (roundtrip tests)
and to catch unintended format changes (golden tests). When events have multiple
versions, you need these tests for every version.

Writing these tests manually is repetitive. With an event having versions v0, v1, v2,
you write essentially the same test three times. Across many events, this becomes
tedious and error-prone.

= Solution

This module automatically generates test suites for all versions of an event.
The type system ensures exhaustiveness—if you add version v3 but forget its
instances, compilation fails.

= Usage

First, define your event with all required instances:

@
type UserCreated = \"user_created\"

-- Payload versions
data UserInfo0 = UserInfo0 { userId :: Int, userName :: Text }
    deriving (Show, Eq, Generic, FromJSON, ToJSON)

data UserInfo1 = UserInfo1 { userId :: Int, userName :: Text, email :: Maybe Text }
    deriving (Show, Eq, Generic, FromJSON, ToJSON)

data UserInfo2 = UserInfo2 { userId :: Int, userName :: Text, email :: Maybe Text, isActive :: Bool }
    deriving (Show, Eq, Generic, FromJSON, ToJSON)

-- Version declarations
type instance MaxVersion UserCreated = 2
type instance Versions UserCreated = '[UserInfo0, UserInfo1, UserInfo2]

instance Event UserCreated

-- Upcast chain
instance Upcast 0 UserCreated where
    upcast (UserInfo0 uid name) = UserInfo1 uid name Nothing

instance Upcast 1 UserCreated where
    upcast (UserInfo1 uid name email) = UserInfo2 uid name email True

-- Migration instances
instance MigrateVersion 0 UserCreated  -- v0 → v1 → v2
instance MigrateVersion 1 UserCreated  -- v1 → v2
instance MigrateVersion 2 UserCreated  -- v2 → v2 (identity)

-- Arbitrary instances for testing
instance Arbitrary UserInfo0 where arbitrary = UserInfo0 \<$\> arbitrary \<*\> arbitrary
instance Arbitrary UserInfo1 where arbitrary = UserInfo1 \<$\> arbitrary \<*\> arbitrary \<*\> arbitrary
instance Arbitrary UserInfo2 where arbitrary = UserInfo2 \<$\> arbitrary \<*\> arbitrary \<*\> arbitrary \<*\> arbitrary
@

Then generate tests:

@
import Test.Hindsight.Generate

tests :: TestTree
tests = testGroup "Events"
    [ createRoundtripTests UserCreated
    , createGoldenTests UserCreated defaultGoldenTestConfig
    ]
@

This generates 6 tests total: roundtrip tests for v0, v1, v2 and golden tests for v0, v1, v2.

= Type-Level Machinery

Both functions require the constraint @HasFullEvidenceList event ValidTestPayloadForVersion@,
which the type system automatically satisfies when:

1. The event has @instance Event event@
2. All payload versions have @Arbitrary@ and JSON instances
3. All version migrations are properly defined

If any version lacks required instances, you get a compile error pointing to the missing constraint.

= When to Use What

* __Roundtrip tests__: Always. These verify basic serialization correctness.
* __Golden tests__: For stable APIs or when JSON format matters to external systems.
  Changes to golden files are explicit in diffs, making unintended format changes visible in code review.
-}
module Test.Hindsight.Generate (
    -- * Roundtrip Tests
    createRoundtripTests,

    -- * Golden Tests
    createGoldenTests,
    GoldenTestConfig (..),
    defaultGoldenTestConfig,

    -- * Technical Details

    {- | Internal constraint machinery. You typically don't need to use this
    directly—it's automatically satisfied when your payload types have the
    required instances ('FromJSON', 'ToJSON', 'Eq', 'Show', 'Typeable', 'Arbitrary').

    This is exported primarily for:

    * Understanding compiler error messages that mention 'ValidTestPayloadForVersion'
    * Advanced use cases requiring explicit constraint manipulation

    If you see a compiler error mentioning this constraint, it means one of
    your payload versions is missing a required instance.
    -}
    ValidTestPayloadForVersion,
)
where

import Data.Aeson (ToJSON, decode, encode)
import Data.Aeson.Encode.Pretty qualified as AE
import Data.ByteString.Lazy qualified as BL
import Data.Kind (Type)
import Data.Text qualified as T
import Data.Typeable (Proxy (..), Typeable)
import GHC.TypeLits
import Hindsight.Events
import System.FilePath ((</>))
import Test.QuickCheck
import Test.QuickCheck.Gen (unGen)
import Test.QuickCheck.Random (mkQCGen)
import Test.Tasty
import Test.Tasty.Golden (goldenVsString)
import Test.Tasty.QuickCheck (testProperty)

{- | Configuration for golden test generation.

Golden tests compare generated JSON output against committed files.
This config controls generation parameters and file paths.

= Fields

* 'goldenPathFor': Maps event type and version to golden file path.
  Default: @\"test\/golden\/events\/\<event-name\>\/\<version\>.json\"@

* 'goldenTestCaseCount': Number of sample values to generate per version.
  More samples = better coverage but larger golden files.
  Default: 10

* 'goldenTestSeed': Random seed for reproducible generation.
  Same seed always produces same test cases.
  Default: 42

* 'goldenTestSizeParam': QuickCheck's size parameter controlling complexity.
  Higher values generate larger/deeper structures.
  Default: 30

= Example Customization

@
myConfig = defaultGoldenTestConfig
    { goldenPathFor = \\(_ :: Proxy event) (_ :: Proxy ver) ->
        "test" </> "snapshots" </> getEventName event </> show (reifyPeanoNat \@ver) <> ".json"
    , goldenTestCaseCount = 5   -- Fewer samples for faster tests
    , goldenTestSeed = 99999    -- Different seed for variation
    }
@
-}
data GoldenTestConfig = GoldenTestConfig
    { goldenPathFor :: forall event ver. (Event event, ReifiablePeanoNat ver) => Proxy event -> Proxy ver -> FilePath
    -- ^ Generate golden file path for an event version
    , goldenTestCaseCount :: forall a. (Num a) => a
    -- ^ Number of test cases to generate per version
    , goldenTestSeed :: forall a. (Num a) => a
    -- ^ Random seed for reproducible test case generation
    , goldenTestSizeParam :: forall a. (Num a) => a
    -- ^ QuickCheck size parameter (affects structural complexity)
    }

{- | Combined requirements for a payload to be testable.

A payload must satisfy both:

1. 'VersionPayloadRequirements' - FromJSON, ToJSON, Eq, Show, Typeable
2. 'Arbitrary' - QuickCheck can generate random instances

This alias simplifies type signatures throughout the module.
-}
type TestPayloadRequirements event idx payload = (VersionPayloadRequirements event idx payload, Arbitrary payload)

{- | Type class providing evidence that a payload is valid for testing a specific event version.

This class uses a blanket instance - any type satisfying 'TestPayloadRequirements'
automatically gets this evidence. The class exists to participate in the constraint
machinery that walks through all event versions.

Users don't need to write instances manually; they're derived automatically when
payloads have the required JSON and Arbitrary instances.
-}
class (TestPayloadRequirements event idx payload) => ValidTestPayloadForVersion (event :: Symbol) (idx :: PeanoNat) (payload :: Type)

instance (TestPayloadRequirements event idx payload) => ValidTestPayloadForVersion event idx payload

{- | Default golden test configuration.

Provides sensible defaults for most projects:

* Golden files in @test\/golden\/events\/\<event-name\>\/\<version\>.json@
* 10 test cases per version
* Seed 42 for reproducibility
* Size parameter 30 (moderate structural complexity)

Customize by overriding specific fields:

@
createGoldenTests \@UserCreated $ defaultGoldenTestConfig
    { goldenTestCaseCount = 5  -- Override just the count
    }
@
-}
defaultGoldenTestConfig :: GoldenTestConfig
defaultGoldenTestConfig =
    GoldenTestConfig
        { goldenPathFor = \(_pEvent :: Proxy event) (_ :: Proxy ver) ->
            let name = getEventName event
                version = show $ reifyPeanoNat @ver
             in "test/golden/events" </> T.unpack name </> (version <> ".json")
        , goldenTestCaseCount = 10
        , goldenTestSeed = 42
        , goldenTestSizeParam = 30
        }

{- | Generic test generator that walks through all versions of an event.

This is the core mechanism for automatic test generation. Given:

1. A test group name
2. A function that creates a test for a single version
3. Version constraints (automatically derived from the event definition)

It produces a TestTree containing tests for all versions.

The magic happens through 'VersionConstraints', which encodes the list of
all event versions at the type level. We pattern match on this structure
to recursively build tests for each version.
-}
generateTest ::
    forall event.
    String ->
    ( forall ver payload.
      ( ValidTestPayloadForVersion event ver payload
      , Typeable ver
      , ReifiablePeanoNat ver
      ) =>
      Proxy event ->
      Proxy ver ->
      Proxy payload ->
      TestTree
    ) ->
    VersionConstraints (EventVersionVector event) (ValidTestPayloadForVersion event) ->
    TestTree
generateTest desc makeTest constraints =
    testGroup desc $ go [] constraints
  where
    go :: [TestTree] -> VersionConstraints ts (ValidTestPayloadForVersion event) -> [TestTree]
    go acc (VersionConstraintsLast (pVer :: Proxy ver, pPayload :: Proxy payload)) =
        makeTest (Proxy @event) pVer pPayload : acc
    go acc (VersionConstraintsCons (pVer :: Proxy ver, pPayload :: Proxy payload) rest) =
        go (makeTest (Proxy @event) pVer pPayload : acc) rest

{- | Create a roundtrip property test for a specific event version.

Tests the fundamental property: @decode . encode = Just@

For a payload of version N, generates random instances using QuickCheck's
'Arbitrary', encodes them to JSON, decodes back, and verifies identity.
-}
makeRoundtripTest ::
    forall event ver payload.
    (ValidTestPayloadForVersion event ver payload) =>
    Proxy event ->
    Proxy ver ->
    Proxy payload ->
    TestTree
makeRoundtripTest _ _ _ =
    testProperty
        ("Version " <> show (reifyPeanoNat @ver) <> " roundtrip")
        $ \(payload :: payload) ->
            decode (encode payload) === Just payload

{- | Pretty-print JSON with indentation.

Used for golden files to make them human-readable and diff-friendly.
Produces consistently formatted JSON regardless of input structure.
-}
encodePretty :: (ToJSON a) => a -> BL.ByteString
encodePretty = AE.encodePretty

{- | Create a golden test for a specific event version.

Generates a deterministic set of sample values, serializes them to
pretty-printed JSON, and compares against the committed golden file.

When the golden file doesn't exist or differs, the test fails and
shows the diff. Accept changes by updating the golden file.
-}
makeGoldenTest ::
    forall event ver payload.
    (Event event, ValidTestPayloadForVersion event ver payload) =>
    GoldenTestConfig ->
    Proxy event ->
    Proxy ver ->
    Proxy payload ->
    TestTree
makeGoldenTest config pEvent pVer (_ :: Proxy payload) =
    goldenVsString
        ("Version " <> show (reifyPeanoNat @ver) <> " golden")
        (goldenPathFor config pEvent pVer)
        (generateGoldenContent payload config)

{- | Generate deterministic JSON content for golden testing.

Uses QuickCheck's generator machinery with a fixed seed to produce
reproducible test cases. The same config always generates identical output,
making golden tests stable across runs.

Process:
1. Create a generator for N samples using 'Arbitrary'
2. Run it with the configured seed and size
3. Pretty-print the results as JSON
-}
generateGoldenContent ::
    forall a ->
    (Arbitrary a, ToJSON a) =>
    GoldenTestConfig ->
    IO BL.ByteString
generateGoldenContent a config = do
    let gen = vectorOf (goldenTestCaseCount config) (arbitrary @a)
        qcGen = mkQCGen (goldenTestSeed config)
        samples = unGen gen qcGen (goldenTestSizeParam config)
    pure $ encodePretty samples

{- | Generate roundtrip tests for all versions of an event.

Creates a test group containing property-based roundtrip tests for every
version of the specified event. Each test verifies that JSON serialization
is reversible: @decode (encode x) ≡ Just x@.

= Type Requirements

The event type must satisfy:

* @'Event' event@ - Proper event definition with version information
* @'HasFullEvidenceList' event ValidTestPayloadForVersion@ - All payload
  versions have 'Arbitrary' and JSON instances (automatically derived)

= Example

@
-- In your test suite
import Test.Hindsight.Generate
import Test.Hindsight.Examples (UserCreated)

tests :: TestTree
tests = testGroup "Event Tests"
    [ createRoundtripTests UserCreated
    ]
@

This generates tests like:

* @UserCreated Roundtrip Tests / Version 0 roundtrip@
* @UserCreated Roundtrip Tests / Version 1 roundtrip@
* @UserCreated Roundtrip Tests / Version 2 roundtrip@

= When to Use

Always include these tests. They catch basic serialization bugs and verify
that your JSON instances work correctly for all versions.
-}
createRoundtripTests ::
    forall event ->
    ( Event event
    , HasFullEvidenceList event ValidTestPayloadForVersion
    ) =>
    TestTree
createRoundtripTests event =
    generateTest
        (eventName <> " Roundtrip Tests")
        makeRoundtripTest
        (getPayloadEvidence event ValidTestPayloadForVersion)
  where
    name = getEventName event
    eventName = T.unpack name

{- | Generate golden tests for all versions of an event.

Creates snapshot tests that compare generated JSON output against committed
golden files. When the output changes (intentionally or not), the test fails
with a diff, making format changes explicit in code review.

= Type Requirements

Same as 'createRoundtripTests':

* @'Event' event@ - Proper event definition
* @'HasFullEvidenceList' event ValidTestPayloadForVersion@ - All versions testable

= Example

@
import Test.Hindsight.Generate
import Test.Hindsight.Examples (UserCreated)

tests :: TestTree
tests = testGroup "Event Tests"
    [ createRoundtripTests UserCreated
    , createGoldenTests UserCreated config
    ]
  where
    config = defaultGoldenTestConfig
        { goldenPathFor = \\(_ :: Proxy event) (_ :: Proxy ver) ->
            "golden" </> "events" </> getEventName event </> show (reifyPeanoNat \@ver) <> ".json"
        , goldenTestCaseCount = 10
        , goldenTestSeed = 12345
        , goldenTestSizeParam = 30
        }
@

This generates tests like:

* @UserCreated Golden Tests / Version 0 golden@
* @UserCreated Golden Tests / Version 1 golden@
* @UserCreated Golden Tests / Version 2 golden@

Each test compares generated JSON against its golden file (e.g., @golden\/events\/user_created\/0.json@).

= When to Use

Use golden tests when:

* JSON format stability matters (external APIs, stored events)
* You want to catch unintended format changes in code review
* The event structure is relatively stable

Skip them for rapidly evolving internal events where format changes are frequent.

= Workflow

1. Initial setup: Run tests, they fail with "golden file missing"
2. Review generated output, commit golden files if correct
3. Future changes: If JSON format changes, test fails with diff
4. Review diff: If change is intentional, update golden file
-}
createGoldenTests ::
    forall event ->
    ( Event event
    , HasFullEvidenceList event ValidTestPayloadForVersion
    ) =>
    GoldenTestConfig ->
    TestTree
createGoldenTests event config =
    generateTest
        (eventName <> " Golden Tests")
        (makeGoldenTest config)
        (getPayloadEvidence event ValidTestPayloadForVersion)
  where
    name = getEventName event
    eventName = T.unpack name
