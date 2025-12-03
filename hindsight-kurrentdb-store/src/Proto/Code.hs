{- This file was auto-generated from code.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, DataKinds, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.Code (
        Code(..), Code(), Code'UnrecognizedValue
    ) where
import qualified Data.ProtoLens.Runtime.Control.DeepSeq as Control.DeepSeq
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Prism as Data.ProtoLens.Prism
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
newtype Code'UnrecognizedValue
  = Code'UnrecognizedValue Data.Int.Int32
  deriving stock (Prelude.Eq, Prelude.Ord, Prelude.Show)
data Code
  = OK |
    CANCELLED |
    UNKNOWN |
    INVALID_ARGUMENT |
    DEADLINE_EXCEEDED |
    NOT_FOUND |
    ALREADY_EXISTS |
    PERMISSION_DENIED |
    RESOURCE_EXHAUSTED |
    FAILED_PRECONDITION |
    ABORTED |
    OUT_OF_RANGE |
    UNIMPLEMENTED |
    INTERNAL |
    UNAVAILABLE |
    DATA_LOSS |
    UNAUTHENTICATED |
    Code'Unrecognized !Code'UnrecognizedValue
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.MessageEnum Code where
  maybeToEnum 0 = Prelude.Just OK
  maybeToEnum 1 = Prelude.Just CANCELLED
  maybeToEnum 2 = Prelude.Just UNKNOWN
  maybeToEnum 3 = Prelude.Just INVALID_ARGUMENT
  maybeToEnum 4 = Prelude.Just DEADLINE_EXCEEDED
  maybeToEnum 5 = Prelude.Just NOT_FOUND
  maybeToEnum 6 = Prelude.Just ALREADY_EXISTS
  maybeToEnum 7 = Prelude.Just PERMISSION_DENIED
  maybeToEnum 8 = Prelude.Just RESOURCE_EXHAUSTED
  maybeToEnum 9 = Prelude.Just FAILED_PRECONDITION
  maybeToEnum 10 = Prelude.Just ABORTED
  maybeToEnum 11 = Prelude.Just OUT_OF_RANGE
  maybeToEnum 12 = Prelude.Just UNIMPLEMENTED
  maybeToEnum 13 = Prelude.Just INTERNAL
  maybeToEnum 14 = Prelude.Just UNAVAILABLE
  maybeToEnum 15 = Prelude.Just DATA_LOSS
  maybeToEnum 16 = Prelude.Just UNAUTHENTICATED
  maybeToEnum k
    = Prelude.Just
        (Code'Unrecognized
           (Code'UnrecognizedValue (Prelude.fromIntegral k)))
  showEnum OK = "OK"
  showEnum CANCELLED = "CANCELLED"
  showEnum UNKNOWN = "UNKNOWN"
  showEnum INVALID_ARGUMENT = "INVALID_ARGUMENT"
  showEnum DEADLINE_EXCEEDED = "DEADLINE_EXCEEDED"
  showEnum NOT_FOUND = "NOT_FOUND"
  showEnum ALREADY_EXISTS = "ALREADY_EXISTS"
  showEnum PERMISSION_DENIED = "PERMISSION_DENIED"
  showEnum UNAUTHENTICATED = "UNAUTHENTICATED"
  showEnum RESOURCE_EXHAUSTED = "RESOURCE_EXHAUSTED"
  showEnum FAILED_PRECONDITION = "FAILED_PRECONDITION"
  showEnum ABORTED = "ABORTED"
  showEnum OUT_OF_RANGE = "OUT_OF_RANGE"
  showEnum UNIMPLEMENTED = "UNIMPLEMENTED"
  showEnum INTERNAL = "INTERNAL"
  showEnum UNAVAILABLE = "UNAVAILABLE"
  showEnum DATA_LOSS = "DATA_LOSS"
  showEnum (Code'Unrecognized (Code'UnrecognizedValue k))
    = Prelude.show k
  readEnum k
    | (Prelude.==) k "OK" = Prelude.Just OK
    | (Prelude.==) k "CANCELLED" = Prelude.Just CANCELLED
    | (Prelude.==) k "UNKNOWN" = Prelude.Just UNKNOWN
    | (Prelude.==) k "INVALID_ARGUMENT" = Prelude.Just INVALID_ARGUMENT
    | (Prelude.==) k "DEADLINE_EXCEEDED"
    = Prelude.Just DEADLINE_EXCEEDED
    | (Prelude.==) k "NOT_FOUND" = Prelude.Just NOT_FOUND
    | (Prelude.==) k "ALREADY_EXISTS" = Prelude.Just ALREADY_EXISTS
    | (Prelude.==) k "PERMISSION_DENIED"
    = Prelude.Just PERMISSION_DENIED
    | (Prelude.==) k "UNAUTHENTICATED" = Prelude.Just UNAUTHENTICATED
    | (Prelude.==) k "RESOURCE_EXHAUSTED"
    = Prelude.Just RESOURCE_EXHAUSTED
    | (Prelude.==) k "FAILED_PRECONDITION"
    = Prelude.Just FAILED_PRECONDITION
    | (Prelude.==) k "ABORTED" = Prelude.Just ABORTED
    | (Prelude.==) k "OUT_OF_RANGE" = Prelude.Just OUT_OF_RANGE
    | (Prelude.==) k "UNIMPLEMENTED" = Prelude.Just UNIMPLEMENTED
    | (Prelude.==) k "INTERNAL" = Prelude.Just INTERNAL
    | (Prelude.==) k "UNAVAILABLE" = Prelude.Just UNAVAILABLE
    | (Prelude.==) k "DATA_LOSS" = Prelude.Just DATA_LOSS
    | Prelude.otherwise
    = (Prelude.>>=) (Text.Read.readMaybe k) Data.ProtoLens.maybeToEnum
instance Prelude.Bounded Code where
  minBound = OK
  maxBound = UNAUTHENTICATED
instance Prelude.Enum Code where
  toEnum k__
    = Prelude.maybe
        (Prelude.error
           ((Prelude.++)
              "toEnum: unknown value for enum Code: " (Prelude.show k__)))
        Prelude.id (Data.ProtoLens.maybeToEnum k__)
  fromEnum OK = 0
  fromEnum CANCELLED = 1
  fromEnum UNKNOWN = 2
  fromEnum INVALID_ARGUMENT = 3
  fromEnum DEADLINE_EXCEEDED = 4
  fromEnum NOT_FOUND = 5
  fromEnum ALREADY_EXISTS = 6
  fromEnum PERMISSION_DENIED = 7
  fromEnum RESOURCE_EXHAUSTED = 8
  fromEnum FAILED_PRECONDITION = 9
  fromEnum ABORTED = 10
  fromEnum OUT_OF_RANGE = 11
  fromEnum UNIMPLEMENTED = 12
  fromEnum INTERNAL = 13
  fromEnum UNAVAILABLE = 14
  fromEnum DATA_LOSS = 15
  fromEnum UNAUTHENTICATED = 16
  fromEnum (Code'Unrecognized (Code'UnrecognizedValue k))
    = Prelude.fromIntegral k
  succ UNAUTHENTICATED
    = Prelude.error
        "Code.succ: bad argument UNAUTHENTICATED. This value would be out of bounds."
  succ OK = CANCELLED
  succ CANCELLED = UNKNOWN
  succ UNKNOWN = INVALID_ARGUMENT
  succ INVALID_ARGUMENT = DEADLINE_EXCEEDED
  succ DEADLINE_EXCEEDED = NOT_FOUND
  succ NOT_FOUND = ALREADY_EXISTS
  succ ALREADY_EXISTS = PERMISSION_DENIED
  succ PERMISSION_DENIED = RESOURCE_EXHAUSTED
  succ RESOURCE_EXHAUSTED = FAILED_PRECONDITION
  succ FAILED_PRECONDITION = ABORTED
  succ ABORTED = OUT_OF_RANGE
  succ OUT_OF_RANGE = UNIMPLEMENTED
  succ UNIMPLEMENTED = INTERNAL
  succ INTERNAL = UNAVAILABLE
  succ UNAVAILABLE = DATA_LOSS
  succ DATA_LOSS = UNAUTHENTICATED
  succ (Code'Unrecognized _)
    = Prelude.error "Code.succ: bad argument: unrecognized value"
  pred OK
    = Prelude.error
        "Code.pred: bad argument OK. This value would be out of bounds."
  pred CANCELLED = OK
  pred UNKNOWN = CANCELLED
  pred INVALID_ARGUMENT = UNKNOWN
  pred DEADLINE_EXCEEDED = INVALID_ARGUMENT
  pred NOT_FOUND = DEADLINE_EXCEEDED
  pred ALREADY_EXISTS = NOT_FOUND
  pred PERMISSION_DENIED = ALREADY_EXISTS
  pred RESOURCE_EXHAUSTED = PERMISSION_DENIED
  pred FAILED_PRECONDITION = RESOURCE_EXHAUSTED
  pred ABORTED = FAILED_PRECONDITION
  pred OUT_OF_RANGE = ABORTED
  pred UNIMPLEMENTED = OUT_OF_RANGE
  pred INTERNAL = UNIMPLEMENTED
  pred UNAVAILABLE = INTERNAL
  pred DATA_LOSS = UNAVAILABLE
  pred UNAUTHENTICATED = DATA_LOSS
  pred (Code'Unrecognized _)
    = Prelude.error "Code.pred: bad argument: unrecognized value"
  enumFrom = Data.ProtoLens.Message.Enum.messageEnumFrom
  enumFromTo = Data.ProtoLens.Message.Enum.messageEnumFromTo
  enumFromThen = Data.ProtoLens.Message.Enum.messageEnumFromThen
  enumFromThenTo = Data.ProtoLens.Message.Enum.messageEnumFromThenTo
instance Data.ProtoLens.FieldDefault Code where
  fieldDefault = OK
instance Control.DeepSeq.NFData Code where
  rnf x__ = Prelude.seq x__ ()