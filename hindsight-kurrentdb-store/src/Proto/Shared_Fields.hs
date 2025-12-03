{- This file was auto-generated from shared.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, DataKinds, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.Shared_Fields where
import qualified Data.ProtoLens.Runtime.Prelude as Prelude
import qualified Data.ProtoLens.Runtime.Data.Int as Data.Int
import qualified Data.ProtoLens.Runtime.Data.Monoid as Data.Monoid
import qualified Data.ProtoLens.Runtime.Data.Word as Data.Word
import qualified Data.ProtoLens.Runtime.Data.ProtoLens as Data.ProtoLens
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Encoding.Bytes as Data.ProtoLens.Encoding.Bytes
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Encoding.Growing as Data.ProtoLens.Encoding.Growing
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Encoding.Parser.Unsafe as Data.ProtoLens.Encoding.Parser.Unsafe
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Encoding.Wire as Data.ProtoLens.Encoding.Wire
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Field as Data.ProtoLens.Field
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Message.Enum as Data.ProtoLens.Message.Enum
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Service.Types as Data.ProtoLens.Service.Types
import qualified Data.ProtoLens.Runtime.Lens.Family2 as Lens.Family2
import qualified Data.ProtoLens.Runtime.Lens.Family2.Unchecked as Lens.Family2.Unchecked
import qualified Data.ProtoLens.Runtime.Data.Text as Data.Text
import qualified Data.ProtoLens.Runtime.Data.Map as Data.Map
import qualified Data.ProtoLens.Runtime.Data.ByteString as Data.ByteString
import qualified Data.ProtoLens.Runtime.Data.ByteString.Char8 as Data.ByteString.Char8
import qualified Data.ProtoLens.Runtime.Data.Text.Encoding as Data.Text.Encoding
import qualified Data.ProtoLens.Runtime.Data.Vector as Data.Vector
import qualified Data.ProtoLens.Runtime.Data.Vector.Generic as Data.Vector.Generic
import qualified Data.ProtoLens.Runtime.Data.Vector.Unboxed as Data.Vector.Unboxed
import qualified Data.ProtoLens.Runtime.Text.Read as Text.Read
import qualified Proto.Google.Protobuf.Empty
commitPosition ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "commitPosition" a) =>
  Lens.Family2.LensLike' f s a
commitPosition = Data.ProtoLens.Field.field @"commitPosition"
currentNoStream ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "currentNoStream" a) =>
  Lens.Family2.LensLike' f s a
currentNoStream = Data.ProtoLens.Field.field @"currentNoStream"
currentStreamRevision ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "currentStreamRevision" a) =>
  Lens.Family2.LensLike' f s a
currentStreamRevision
  = Data.ProtoLens.Field.field @"currentStreamRevision"
eventId ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "eventId" a) =>
  Lens.Family2.LensLike' f s a
eventId = Data.ProtoLens.Field.field @"eventId"
expectedAny ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "expectedAny" a) =>
  Lens.Family2.LensLike' f s a
expectedAny = Data.ProtoLens.Field.field @"expectedAny"
expectedNoStream ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "expectedNoStream" a) =>
  Lens.Family2.LensLike' f s a
expectedNoStream = Data.ProtoLens.Field.field @"expectedNoStream"
expectedStreamExists ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "expectedStreamExists" a) =>
  Lens.Family2.LensLike' f s a
expectedStreamExists
  = Data.ProtoLens.Field.field @"expectedStreamExists"
expectedStreamPosition ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "expectedStreamPosition" a) =>
  Lens.Family2.LensLike' f s a
expectedStreamPosition
  = Data.ProtoLens.Field.field @"expectedStreamPosition"
leastSignificantBits ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "leastSignificantBits" a) =>
  Lens.Family2.LensLike' f s a
leastSignificantBits
  = Data.ProtoLens.Field.field @"leastSignificantBits"
maxAppendEventSize ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maxAppendEventSize" a) =>
  Lens.Family2.LensLike' f s a
maxAppendEventSize
  = Data.ProtoLens.Field.field @"maxAppendEventSize"
maxAppendSize ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maxAppendSize" a) =>
  Lens.Family2.LensLike' f s a
maxAppendSize = Data.ProtoLens.Field.field @"maxAppendSize"
maybe'currentNoStream ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'currentNoStream" a) =>
  Lens.Family2.LensLike' f s a
maybe'currentNoStream
  = Data.ProtoLens.Field.field @"maybe'currentNoStream"
maybe'currentStreamRevision ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'currentStreamRevision" a) =>
  Lens.Family2.LensLike' f s a
maybe'currentStreamRevision
  = Data.ProtoLens.Field.field @"maybe'currentStreamRevision"
maybe'currentStreamRevisionOption ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'currentStreamRevisionOption" a) =>
  Lens.Family2.LensLike' f s a
maybe'currentStreamRevisionOption
  = Data.ProtoLens.Field.field @"maybe'currentStreamRevisionOption"
maybe'expectedAny ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'expectedAny" a) =>
  Lens.Family2.LensLike' f s a
maybe'expectedAny = Data.ProtoLens.Field.field @"maybe'expectedAny"
maybe'expectedNoStream ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'expectedNoStream" a) =>
  Lens.Family2.LensLike' f s a
maybe'expectedNoStream
  = Data.ProtoLens.Field.field @"maybe'expectedNoStream"
maybe'expectedStreamExists ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'expectedStreamExists" a) =>
  Lens.Family2.LensLike' f s a
maybe'expectedStreamExists
  = Data.ProtoLens.Field.field @"maybe'expectedStreamExists"
maybe'expectedStreamPosition ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'expectedStreamPosition" a) =>
  Lens.Family2.LensLike' f s a
maybe'expectedStreamPosition
  = Data.ProtoLens.Field.field @"maybe'expectedStreamPosition"
maybe'expectedStreamPositionOption ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'expectedStreamPositionOption" a) =>
  Lens.Family2.LensLike' f s a
maybe'expectedStreamPositionOption
  = Data.ProtoLens.Field.field @"maybe'expectedStreamPositionOption"
maybe'streamIdentifier ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'streamIdentifier" a) =>
  Lens.Family2.LensLike' f s a
maybe'streamIdentifier
  = Data.ProtoLens.Field.field @"maybe'streamIdentifier"
maybe'string ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'string" a) =>
  Lens.Family2.LensLike' f s a
maybe'string = Data.ProtoLens.Field.field @"maybe'string"
maybe'structured ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'structured" a) =>
  Lens.Family2.LensLike' f s a
maybe'structured = Data.ProtoLens.Field.field @"maybe'structured"
maybe'value ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'value" a) =>
  Lens.Family2.LensLike' f s a
maybe'value = Data.ProtoLens.Field.field @"maybe'value"
message ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "message" a) =>
  Lens.Family2.LensLike' f s a
message = Data.ProtoLens.Field.field @"message"
mostSignificantBits ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "mostSignificantBits" a) =>
  Lens.Family2.LensLike' f s a
mostSignificantBits
  = Data.ProtoLens.Field.field @"mostSignificantBits"
preparePosition ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "preparePosition" a) =>
  Lens.Family2.LensLike' f s a
preparePosition = Data.ProtoLens.Field.field @"preparePosition"
proposedEventSize ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "proposedEventSize" a) =>
  Lens.Family2.LensLike' f s a
proposedEventSize = Data.ProtoLens.Field.field @"proposedEventSize"
streamIdentifier ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "streamIdentifier" a) =>
  Lens.Family2.LensLike' f s a
streamIdentifier = Data.ProtoLens.Field.field @"streamIdentifier"
streamName ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "streamName" a) =>
  Lens.Family2.LensLike' f s a
streamName = Data.ProtoLens.Field.field @"streamName"
string ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "string" a) =>
  Lens.Family2.LensLike' f s a
string = Data.ProtoLens.Field.field @"string"
structured ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "structured" a) =>
  Lens.Family2.LensLike' f s a
structured = Data.ProtoLens.Field.field @"structured"