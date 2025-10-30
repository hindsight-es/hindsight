{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}

module Test.Hindsight.Generate
    ( createRoundtripTests,
      createGoldenTests,
      GoldenTestConfig(goldenTestSizeParam, goldenPathFor, goldenTestCaseCount,
                 goldenTestSeed),
      defaultGoldenTestConfig )
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

-- | Configuration for test generation
data GoldenTestConfig = GoldenTestConfig
    { goldenPathFor :: forall event ver. (Event event, ReifiablePeanoNat ver) => Proxy event -> Proxy ver -> FilePath
    -- ^ Function to generate golden file path for a version
    , goldenTestCaseCount :: forall a. (Num a) => a
    -- ^ Number of test cases to generate for golden tests
    , goldenTestSeed :: forall a. (Num a) => a
    -- ^ Seed for reproducible random generation
    , goldenTestSizeParam :: forall a. (Num a) => a
    -- ^ Size parameter for QuickCheck's generation (affects complexity of generated values)
    }

type TestPayloadRequirements event idx payload = (VersionPayloadRequirements event idx payload, Arbitrary payload)

-- | Evidence that a type is a valid payload for a version
class (TestPayloadRequirements event idx payload) => ValidTestPayloadForVersion (event :: Symbol) (idx :: PeanoNat) (payload :: Type) where

instance (TestPayloadRequirements event idx payload) => ValidTestPayloadForVersion event idx payload where

-- | Default test configuration
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

-- | Generate roundtrip property test for a specific version
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

-- | Helper function to pretty print JSON
encodePretty :: (ToJSON a) => a -> BL.ByteString
encodePretty = AE.encodePretty

-- | Generate golden test for a specific version
makeGoldenTest ::
    forall event ver payload.
    (Event event, ValidTestPayloadForVersion event ver payload) =>
    GoldenTestConfig ->
    Proxy event ->
    Proxy ver ->
    Proxy payload ->
    TestTree
makeGoldenTest config pEvent pVer _ =
    goldenVsString
        ("Version " <> show (reifyPeanoNat @ver) <> " golden")
        (goldenPathFor config pEvent pVer)
        (generateGoldenContent @payload config)

-- | Generate content for golden tests
generateGoldenContent ::
    forall a.
    (Arbitrary a, ToJSON a) =>
    GoldenTestConfig ->
    IO BL.ByteString
generateGoldenContent config = do
    let gen = vectorOf (goldenTestCaseCount config) (arbitrary @a)
        qcGen = mkQCGen (goldenTestSeed config)
        samples = unGen gen qcGen (goldenTestSizeParam config)
    pure $ encodePretty samples

-- | Create selective test suites
createRoundtripTests ::
    forall event.
    ( Event event
    , HasFullEvidenceList event ValidTestPayloadForVersion
    ) =>
    TestTree
createRoundtripTests =
    generateTest
        (eventName <> " Roundtrip Tests")
        makeRoundtripTest
        (getPayloadEvidence @event @ValidTestPayloadForVersion)
  where
    name = getEventName event
    eventName = T.unpack name

createGoldenTests ::
    forall event.
    ( Event event
    , HasFullEvidenceList event ValidTestPayloadForVersion
    ) =>
    GoldenTestConfig ->
    TestTree
createGoldenTests config =
    generateTest
        (eventName <> " Golden Tests")
        (makeGoldenTest config)
        (getPayloadEvidence @event @ValidTestPayloadForVersion)
  where
    name = getEventName event
    eventName = T.unpack name
