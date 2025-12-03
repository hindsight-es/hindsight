{- This file was auto-generated from streams.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, DataKinds, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.Streams_Fields where
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
import qualified Proto.Google.Protobuf.Duration
import qualified Proto.Google.Protobuf.Empty
import qualified Proto.Google.Protobuf.Timestamp
import qualified Proto.Shared
import qualified Proto.Status
all ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "all" a) =>
  Lens.Family2.LensLike' f s a
all = Data.ProtoLens.Field.field @"all"
any ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "any" a) =>
  Lens.Family2.LensLike' f s a
any = Data.ProtoLens.Field.field @"any"
any2060 ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "any2060" a) =>
  Lens.Family2.LensLike' f s a
any2060 = Data.ProtoLens.Field.field @"any2060"
caughtUp ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "caughtUp" a) =>
  Lens.Family2.LensLike' f s a
caughtUp = Data.ProtoLens.Field.field @"caughtUp"
checkpoint ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "checkpoint" a) =>
  Lens.Family2.LensLike' f s a
checkpoint = Data.ProtoLens.Field.field @"checkpoint"
checkpointIntervalMultiplier ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "checkpointIntervalMultiplier" a) =>
  Lens.Family2.LensLike' f s a
checkpointIntervalMultiplier
  = Data.ProtoLens.Field.field @"checkpointIntervalMultiplier"
commitPosition ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "commitPosition" a) =>
  Lens.Family2.LensLike' f s a
commitPosition = Data.ProtoLens.Field.field @"commitPosition"
compatibility ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "compatibility" a) =>
  Lens.Family2.LensLike' f s a
compatibility = Data.ProtoLens.Field.field @"compatibility"
confirmation ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "confirmation" a) =>
  Lens.Family2.LensLike' f s a
confirmation = Data.ProtoLens.Field.field @"confirmation"
controlOption ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "controlOption" a) =>
  Lens.Family2.LensLike' f s a
controlOption = Data.ProtoLens.Field.field @"controlOption"
correlationId ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "correlationId" a) =>
  Lens.Family2.LensLike' f s a
correlationId = Data.ProtoLens.Field.field @"correlationId"
count ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "count" a) =>
  Lens.Family2.LensLike' f s a
count = Data.ProtoLens.Field.field @"count"
currentNoStream ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "currentNoStream" a) =>
  Lens.Family2.LensLike' f s a
currentNoStream = Data.ProtoLens.Field.field @"currentNoStream"
currentRevision ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "currentRevision" a) =>
  Lens.Family2.LensLike' f s a
currentRevision = Data.ProtoLens.Field.field @"currentRevision"
currentRevision2060 ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "currentRevision2060" a) =>
  Lens.Family2.LensLike' f s a
currentRevision2060
  = Data.ProtoLens.Field.field @"currentRevision2060"
customMetadata ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "customMetadata" a) =>
  Lens.Family2.LensLike' f s a
customMetadata = Data.ProtoLens.Field.field @"customMetadata"
data' ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "data'" a) =>
  Lens.Family2.LensLike' f s a
data' = Data.ProtoLens.Field.field @"data'"
deadline ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "deadline" a) =>
  Lens.Family2.LensLike' f s a
deadline = Data.ProtoLens.Field.field @"deadline"
deadline21100 ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "deadline21100" a) =>
  Lens.Family2.LensLike' f s a
deadline21100 = Data.ProtoLens.Field.field @"deadline21100"
end ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "end" a) =>
  Lens.Family2.LensLike' f s a
end = Data.ProtoLens.Field.field @"end"
error ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "error" a) =>
  Lens.Family2.LensLike' f s a
error = Data.ProtoLens.Field.field @"error"
event ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "event" a) =>
  Lens.Family2.LensLike' f s a
event = Data.ProtoLens.Field.field @"event"
eventType ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "eventType" a) =>
  Lens.Family2.LensLike' f s a
eventType = Data.ProtoLens.Field.field @"eventType"
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
expectedRevision ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "expectedRevision" a) =>
  Lens.Family2.LensLike' f s a
expectedRevision = Data.ProtoLens.Field.field @"expectedRevision"
expectedRevision2060 ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "expectedRevision2060" a) =>
  Lens.Family2.LensLike' f s a
expectedRevision2060
  = Data.ProtoLens.Field.field @"expectedRevision2060"
expectedStreamExists ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "expectedStreamExists" a) =>
  Lens.Family2.LensLike' f s a
expectedStreamExists
  = Data.ProtoLens.Field.field @"expectedStreamExists"
fellBehind ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "fellBehind" a) =>
  Lens.Family2.LensLike' f s a
fellBehind = Data.ProtoLens.Field.field @"fellBehind"
filter ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "filter" a) =>
  Lens.Family2.LensLike' f s a
filter = Data.ProtoLens.Field.field @"filter"
firstStreamPosition ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "firstStreamPosition" a) =>
  Lens.Family2.LensLike' f s a
firstStreamPosition
  = Data.ProtoLens.Field.field @"firstStreamPosition"
id ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "id" a) =>
  Lens.Family2.LensLike' f s a
id = Data.ProtoLens.Field.field @"id"
isFinal ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "isFinal" a) =>
  Lens.Family2.LensLike' f s a
isFinal = Data.ProtoLens.Field.field @"isFinal"
key ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "key" a) =>
  Lens.Family2.LensLike' f s a
key = Data.ProtoLens.Field.field @"key"
lastAllStreamPosition ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "lastAllStreamPosition" a) =>
  Lens.Family2.LensLike' f s a
lastAllStreamPosition
  = Data.ProtoLens.Field.field @"lastAllStreamPosition"
lastStreamPosition ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "lastStreamPosition" a) =>
  Lens.Family2.LensLike' f s a
lastStreamPosition
  = Data.ProtoLens.Field.field @"lastStreamPosition"
link ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "link" a) =>
  Lens.Family2.LensLike' f s a
link = Data.ProtoLens.Field.field @"link"
max ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "max" a) =>
  Lens.Family2.LensLike' f s a
max = Data.ProtoLens.Field.field @"max"
maybe'all ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'all" a) =>
  Lens.Family2.LensLike' f s a
maybe'all = Data.ProtoLens.Field.field @"maybe'all"
maybe'allOption ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'allOption" a) =>
  Lens.Family2.LensLike' f s a
maybe'allOption = Data.ProtoLens.Field.field @"maybe'allOption"
maybe'any ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'any" a) =>
  Lens.Family2.LensLike' f s a
maybe'any = Data.ProtoLens.Field.field @"maybe'any"
maybe'any2060 ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'any2060" a) =>
  Lens.Family2.LensLike' f s a
maybe'any2060 = Data.ProtoLens.Field.field @"maybe'any2060"
maybe'caughtUp ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'caughtUp" a) =>
  Lens.Family2.LensLike' f s a
maybe'caughtUp = Data.ProtoLens.Field.field @"maybe'caughtUp"
maybe'checkpoint ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'checkpoint" a) =>
  Lens.Family2.LensLike' f s a
maybe'checkpoint = Data.ProtoLens.Field.field @"maybe'checkpoint"
maybe'commitPosition ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'commitPosition" a) =>
  Lens.Family2.LensLike' f s a
maybe'commitPosition
  = Data.ProtoLens.Field.field @"maybe'commitPosition"
maybe'confirmation ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'confirmation" a) =>
  Lens.Family2.LensLike' f s a
maybe'confirmation
  = Data.ProtoLens.Field.field @"maybe'confirmation"
maybe'content ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'content" a) =>
  Lens.Family2.LensLike' f s a
maybe'content = Data.ProtoLens.Field.field @"maybe'content"
maybe'controlOption ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'controlOption" a) =>
  Lens.Family2.LensLike' f s a
maybe'controlOption
  = Data.ProtoLens.Field.field @"maybe'controlOption"
maybe'correlationId ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'correlationId" a) =>
  Lens.Family2.LensLike' f s a
maybe'correlationId
  = Data.ProtoLens.Field.field @"maybe'correlationId"
maybe'count ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'count" a) =>
  Lens.Family2.LensLike' f s a
maybe'count = Data.ProtoLens.Field.field @"maybe'count"
maybe'countOption ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'countOption" a) =>
  Lens.Family2.LensLike' f s a
maybe'countOption = Data.ProtoLens.Field.field @"maybe'countOption"
maybe'currentNoStream ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'currentNoStream" a) =>
  Lens.Family2.LensLike' f s a
maybe'currentNoStream
  = Data.ProtoLens.Field.field @"maybe'currentNoStream"
maybe'currentRevision ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'currentRevision" a) =>
  Lens.Family2.LensLike' f s a
maybe'currentRevision
  = Data.ProtoLens.Field.field @"maybe'currentRevision"
maybe'currentRevision2060 ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'currentRevision2060" a) =>
  Lens.Family2.LensLike' f s a
maybe'currentRevision2060
  = Data.ProtoLens.Field.field @"maybe'currentRevision2060"
maybe'currentRevisionOption ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'currentRevisionOption" a) =>
  Lens.Family2.LensLike' f s a
maybe'currentRevisionOption
  = Data.ProtoLens.Field.field @"maybe'currentRevisionOption"
maybe'currentRevisionOption2060 ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'currentRevisionOption2060" a) =>
  Lens.Family2.LensLike' f s a
maybe'currentRevisionOption2060
  = Data.ProtoLens.Field.field @"maybe'currentRevisionOption2060"
maybe'deadline ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'deadline" a) =>
  Lens.Family2.LensLike' f s a
maybe'deadline = Data.ProtoLens.Field.field @"maybe'deadline"
maybe'deadline21100 ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'deadline21100" a) =>
  Lens.Family2.LensLike' f s a
maybe'deadline21100
  = Data.ProtoLens.Field.field @"maybe'deadline21100"
maybe'deadlineOption ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'deadlineOption" a) =>
  Lens.Family2.LensLike' f s a
maybe'deadlineOption
  = Data.ProtoLens.Field.field @"maybe'deadlineOption"
maybe'end ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'end" a) =>
  Lens.Family2.LensLike' f s a
maybe'end = Data.ProtoLens.Field.field @"maybe'end"
maybe'error ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'error" a) =>
  Lens.Family2.LensLike' f s a
maybe'error = Data.ProtoLens.Field.field @"maybe'error"
maybe'event ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'event" a) =>
  Lens.Family2.LensLike' f s a
maybe'event = Data.ProtoLens.Field.field @"maybe'event"
maybe'eventType ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'eventType" a) =>
  Lens.Family2.LensLike' f s a
maybe'eventType = Data.ProtoLens.Field.field @"maybe'eventType"
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
maybe'expectedRevision ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'expectedRevision" a) =>
  Lens.Family2.LensLike' f s a
maybe'expectedRevision
  = Data.ProtoLens.Field.field @"maybe'expectedRevision"
maybe'expectedRevision2060 ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'expectedRevision2060" a) =>
  Lens.Family2.LensLike' f s a
maybe'expectedRevision2060
  = Data.ProtoLens.Field.field @"maybe'expectedRevision2060"
maybe'expectedRevisionOption ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'expectedRevisionOption" a) =>
  Lens.Family2.LensLike' f s a
maybe'expectedRevisionOption
  = Data.ProtoLens.Field.field @"maybe'expectedRevisionOption"
maybe'expectedRevisionOption2060 ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'expectedRevisionOption2060" a) =>
  Lens.Family2.LensLike' f s a
maybe'expectedRevisionOption2060
  = Data.ProtoLens.Field.field @"maybe'expectedRevisionOption2060"
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
maybe'expectedStreamRevision ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'expectedStreamRevision" a) =>
  Lens.Family2.LensLike' f s a
maybe'expectedStreamRevision
  = Data.ProtoLens.Field.field @"maybe'expectedStreamRevision"
maybe'fellBehind ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'fellBehind" a) =>
  Lens.Family2.LensLike' f s a
maybe'fellBehind = Data.ProtoLens.Field.field @"maybe'fellBehind"
maybe'filter ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'filter" a) =>
  Lens.Family2.LensLike' f s a
maybe'filter = Data.ProtoLens.Field.field @"maybe'filter"
maybe'filterOption ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'filterOption" a) =>
  Lens.Family2.LensLike' f s a
maybe'filterOption
  = Data.ProtoLens.Field.field @"maybe'filterOption"
maybe'firstStreamPosition ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'firstStreamPosition" a) =>
  Lens.Family2.LensLike' f s a
maybe'firstStreamPosition
  = Data.ProtoLens.Field.field @"maybe'firstStreamPosition"
maybe'id ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'id" a) =>
  Lens.Family2.LensLike' f s a
maybe'id = Data.ProtoLens.Field.field @"maybe'id"
maybe'lastAllStreamPosition ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'lastAllStreamPosition" a) =>
  Lens.Family2.LensLike' f s a
maybe'lastAllStreamPosition
  = Data.ProtoLens.Field.field @"maybe'lastAllStreamPosition"
maybe'lastStreamPosition ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'lastStreamPosition" a) =>
  Lens.Family2.LensLike' f s a
maybe'lastStreamPosition
  = Data.ProtoLens.Field.field @"maybe'lastStreamPosition"
maybe'link ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'link" a) =>
  Lens.Family2.LensLike' f s a
maybe'link = Data.ProtoLens.Field.field @"maybe'link"
maybe'max ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'max" a) =>
  Lens.Family2.LensLike' f s a
maybe'max = Data.ProtoLens.Field.field @"maybe'max"
maybe'noFilter ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'noFilter" a) =>
  Lens.Family2.LensLike' f s a
maybe'noFilter = Data.ProtoLens.Field.field @"maybe'noFilter"
maybe'noPosition ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'noPosition" a) =>
  Lens.Family2.LensLike' f s a
maybe'noPosition = Data.ProtoLens.Field.field @"maybe'noPosition"
maybe'noStream ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'noStream" a) =>
  Lens.Family2.LensLike' f s a
maybe'noStream = Data.ProtoLens.Field.field @"maybe'noStream"
maybe'noStream2060 ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'noStream2060" a) =>
  Lens.Family2.LensLike' f s a
maybe'noStream2060
  = Data.ProtoLens.Field.field @"maybe'noStream2060"
maybe'options ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'options" a) =>
  Lens.Family2.LensLike' f s a
maybe'options = Data.ProtoLens.Field.field @"maybe'options"
maybe'position ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'position" a) =>
  Lens.Family2.LensLike' f s a
maybe'position = Data.ProtoLens.Field.field @"maybe'position"
maybe'positionOption ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'positionOption" a) =>
  Lens.Family2.LensLike' f s a
maybe'positionOption
  = Data.ProtoLens.Field.field @"maybe'positionOption"
maybe'proposedMessage ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'proposedMessage" a) =>
  Lens.Family2.LensLike' f s a
maybe'proposedMessage
  = Data.ProtoLens.Field.field @"maybe'proposedMessage"
maybe'result ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'result" a) =>
  Lens.Family2.LensLike' f s a
maybe'result = Data.ProtoLens.Field.field @"maybe'result"
maybe'revision ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'revision" a) =>
  Lens.Family2.LensLike' f s a
maybe'revision = Data.ProtoLens.Field.field @"maybe'revision"
maybe'revisionOption ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'revisionOption" a) =>
  Lens.Family2.LensLike' f s a
maybe'revisionOption
  = Data.ProtoLens.Field.field @"maybe'revisionOption"
maybe'start ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'start" a) =>
  Lens.Family2.LensLike' f s a
maybe'start = Data.ProtoLens.Field.field @"maybe'start"
maybe'stream ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'stream" a) =>
  Lens.Family2.LensLike' f s a
maybe'stream = Data.ProtoLens.Field.field @"maybe'stream"
maybe'streamExists ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'streamExists" a) =>
  Lens.Family2.LensLike' f s a
maybe'streamExists
  = Data.ProtoLens.Field.field @"maybe'streamExists"
maybe'streamExists2060 ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'streamExists2060" a) =>
  Lens.Family2.LensLike' f s a
maybe'streamExists2060
  = Data.ProtoLens.Field.field @"maybe'streamExists2060"
maybe'streamIdentifier ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'streamIdentifier" a) =>
  Lens.Family2.LensLike' f s a
maybe'streamIdentifier
  = Data.ProtoLens.Field.field @"maybe'streamIdentifier"
maybe'streamNotFound ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'streamNotFound" a) =>
  Lens.Family2.LensLike' f s a
maybe'streamNotFound
  = Data.ProtoLens.Field.field @"maybe'streamNotFound"
maybe'streamOption ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'streamOption" a) =>
  Lens.Family2.LensLike' f s a
maybe'streamOption
  = Data.ProtoLens.Field.field @"maybe'streamOption"
maybe'streamPosition ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'streamPosition" a) =>
  Lens.Family2.LensLike' f s a
maybe'streamPosition
  = Data.ProtoLens.Field.field @"maybe'streamPosition"
maybe'streamRevision ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'streamRevision" a) =>
  Lens.Family2.LensLike' f s a
maybe'streamRevision
  = Data.ProtoLens.Field.field @"maybe'streamRevision"
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
maybe'subscription ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'subscription" a) =>
  Lens.Family2.LensLike' f s a
maybe'subscription
  = Data.ProtoLens.Field.field @"maybe'subscription"
maybe'success ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'success" a) =>
  Lens.Family2.LensLike' f s a
maybe'success = Data.ProtoLens.Field.field @"maybe'success"
maybe'timestamp ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'timestamp" a) =>
  Lens.Family2.LensLike' f s a
maybe'timestamp = Data.ProtoLens.Field.field @"maybe'timestamp"
maybe'uuidOption ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'uuidOption" a) =>
  Lens.Family2.LensLike' f s a
maybe'uuidOption = Data.ProtoLens.Field.field @"maybe'uuidOption"
maybe'window ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'window" a) =>
  Lens.Family2.LensLike' f s a
maybe'window = Data.ProtoLens.Field.field @"maybe'window"
maybe'wrongExpectedVersion ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'wrongExpectedVersion" a) =>
  Lens.Family2.LensLike' f s a
maybe'wrongExpectedVersion
  = Data.ProtoLens.Field.field @"maybe'wrongExpectedVersion"
metadata ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "metadata" a) =>
  Lens.Family2.LensLike' f s a
metadata = Data.ProtoLens.Field.field @"metadata"
noFilter ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "noFilter" a) =>
  Lens.Family2.LensLike' f s a
noFilter = Data.ProtoLens.Field.field @"noFilter"
noPosition ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "noPosition" a) =>
  Lens.Family2.LensLike' f s a
noPosition = Data.ProtoLens.Field.field @"noPosition"
noStream ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "noStream" a) =>
  Lens.Family2.LensLike' f s a
noStream = Data.ProtoLens.Field.field @"noStream"
noStream2060 ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "noStream2060" a) =>
  Lens.Family2.LensLike' f s a
noStream2060 = Data.ProtoLens.Field.field @"noStream2060"
options ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "options" a) =>
  Lens.Family2.LensLike' f s a
options = Data.ProtoLens.Field.field @"options"
position ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "position" a) =>
  Lens.Family2.LensLike' f s a
position = Data.ProtoLens.Field.field @"position"
prefix ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "prefix" a) =>
  Lens.Family2.LensLike' f s a
prefix = Data.ProtoLens.Field.field @"prefix"
preparePosition ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "preparePosition" a) =>
  Lens.Family2.LensLike' f s a
preparePosition = Data.ProtoLens.Field.field @"preparePosition"
proposedMessage ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "proposedMessage" a) =>
  Lens.Family2.LensLike' f s a
proposedMessage = Data.ProtoLens.Field.field @"proposedMessage"
proposedMessages ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "proposedMessages" a) =>
  Lens.Family2.LensLike' f s a
proposedMessages = Data.ProtoLens.Field.field @"proposedMessages"
readDirection ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "readDirection" a) =>
  Lens.Family2.LensLike' f s a
readDirection = Data.ProtoLens.Field.field @"readDirection"
regex ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "regex" a) =>
  Lens.Family2.LensLike' f s a
regex = Data.ProtoLens.Field.field @"regex"
resolveLinks ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "resolveLinks" a) =>
  Lens.Family2.LensLike' f s a
resolveLinks = Data.ProtoLens.Field.field @"resolveLinks"
revision ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "revision" a) =>
  Lens.Family2.LensLike' f s a
revision = Data.ProtoLens.Field.field @"revision"
start ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "start" a) =>
  Lens.Family2.LensLike' f s a
start = Data.ProtoLens.Field.field @"start"
stream ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "stream" a) =>
  Lens.Family2.LensLike' f s a
stream = Data.ProtoLens.Field.field @"stream"
streamExists ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "streamExists" a) =>
  Lens.Family2.LensLike' f s a
streamExists = Data.ProtoLens.Field.field @"streamExists"
streamExists2060 ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "streamExists2060" a) =>
  Lens.Family2.LensLike' f s a
streamExists2060 = Data.ProtoLens.Field.field @"streamExists2060"
streamIdentifier ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "streamIdentifier" a) =>
  Lens.Family2.LensLike' f s a
streamIdentifier = Data.ProtoLens.Field.field @"streamIdentifier"
streamNotFound ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "streamNotFound" a) =>
  Lens.Family2.LensLike' f s a
streamNotFound = Data.ProtoLens.Field.field @"streamNotFound"
streamPosition ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "streamPosition" a) =>
  Lens.Family2.LensLike' f s a
streamPosition = Data.ProtoLens.Field.field @"streamPosition"
streamRevision ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "streamRevision" a) =>
  Lens.Family2.LensLike' f s a
streamRevision = Data.ProtoLens.Field.field @"streamRevision"
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
subscription ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "subscription" a) =>
  Lens.Family2.LensLike' f s a
subscription = Data.ProtoLens.Field.field @"subscription"
subscriptionId ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "subscriptionId" a) =>
  Lens.Family2.LensLike' f s a
subscriptionId = Data.ProtoLens.Field.field @"subscriptionId"
success ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "success" a) =>
  Lens.Family2.LensLike' f s a
success = Data.ProtoLens.Field.field @"success"
timestamp ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "timestamp" a) =>
  Lens.Family2.LensLike' f s a
timestamp = Data.ProtoLens.Field.field @"timestamp"
uuidOption ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "uuidOption" a) =>
  Lens.Family2.LensLike' f s a
uuidOption = Data.ProtoLens.Field.field @"uuidOption"
value ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "value" a) =>
  Lens.Family2.LensLike' f s a
value = Data.ProtoLens.Field.field @"value"
vec'prefix ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'prefix" a) =>
  Lens.Family2.LensLike' f s a
vec'prefix = Data.ProtoLens.Field.field @"vec'prefix"
vec'proposedMessages ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'proposedMessages" a) =>
  Lens.Family2.LensLike' f s a
vec'proposedMessages
  = Data.ProtoLens.Field.field @"vec'proposedMessages"
wrongExpectedVersion ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "wrongExpectedVersion" a) =>
  Lens.Family2.LensLike' f s a
wrongExpectedVersion
  = Data.ProtoLens.Field.field @"wrongExpectedVersion"