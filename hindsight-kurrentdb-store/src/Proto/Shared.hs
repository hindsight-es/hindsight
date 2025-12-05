{- This file was auto-generated from shared.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, DataKinds, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.Shared (
        AccessDenied(), AllStreamPosition(), BadRequest(), Empty(),
        InvalidTransaction(), MaximumAppendEventSizeExceeded(),
        MaximumAppendSizeExceeded(), StreamDeleted(), StreamIdentifier(),
        Timeout(), UUID(), UUID'Value(..), _UUID'Structured', _UUID'String,
        UUID'Structured(), Unknown(), WrongExpectedVersion(),
        WrongExpectedVersion'CurrentStreamRevisionOption(..),
        WrongExpectedVersion'ExpectedStreamPositionOption(..),
        _WrongExpectedVersion'CurrentStreamRevision,
        _WrongExpectedVersion'CurrentNoStream,
        _WrongExpectedVersion'ExpectedStreamPosition,
        _WrongExpectedVersion'ExpectedAny,
        _WrongExpectedVersion'ExpectedStreamExists,
        _WrongExpectedVersion'ExpectedNoStream
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
import qualified Proto.Google.Protobuf.Empty
{- | Fields :
      -}
data AccessDenied
  = AccessDenied'_constructor {_AccessDenied'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show AccessDenied where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Message AccessDenied where
  messageName _ = Data.Text.pack "event_store.client.AccessDenied"
  packedMessageDescriptor _
    = "\n\
      \\fAccessDenied"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag = let in Data.Map.fromList []
  unknownFields
    = Lens.Family2.Unchecked.lens
        _AccessDenied'_unknownFields
        (\ x__ y__ -> x__ {_AccessDenied'_unknownFields = y__})
  defMessage
    = AccessDenied'_constructor {_AccessDenied'_unknownFields = []}
  parseMessage
    = let
        loop ::
          AccessDenied -> Data.ProtoLens.Encoding.Bytes.Parser AccessDenied
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "AccessDenied"
  buildMessage
    = \ _x
        -> Data.ProtoLens.Encoding.Wire.buildFieldSet
             (Lens.Family2.view Data.ProtoLens.unknownFields _x)
instance Control.DeepSeq.NFData AccessDenied where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq (_AccessDenied'_unknownFields x__) ()
{- | Fields :
     
         * 'Proto.Shared_Fields.commitPosition' @:: Lens' AllStreamPosition Data.Word.Word64@
         * 'Proto.Shared_Fields.preparePosition' @:: Lens' AllStreamPosition Data.Word.Word64@ -}
data AllStreamPosition
  = AllStreamPosition'_constructor {_AllStreamPosition'commitPosition :: !Data.Word.Word64,
                                    _AllStreamPosition'preparePosition :: !Data.Word.Word64,
                                    _AllStreamPosition'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show AllStreamPosition where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField AllStreamPosition "commitPosition" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AllStreamPosition'commitPosition
           (\ x__ y__ -> x__ {_AllStreamPosition'commitPosition = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AllStreamPosition "preparePosition" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AllStreamPosition'preparePosition
           (\ x__ y__ -> x__ {_AllStreamPosition'preparePosition = y__}))
        Prelude.id
instance Data.ProtoLens.Message AllStreamPosition where
  messageName _
    = Data.Text.pack "event_store.client.AllStreamPosition"
  packedMessageDescriptor _
    = "\n\
      \\DC1AllStreamPosition\DC2'\n\
      \\SIcommit_position\CAN\SOH \SOH(\EOTR\SOcommitPosition\DC2)\n\
      \\DLEprepare_position\CAN\STX \SOH(\EOTR\SIpreparePosition"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        commitPosition__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "commit_position"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"commitPosition")) ::
              Data.ProtoLens.FieldDescriptor AllStreamPosition
        preparePosition__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "prepare_position"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"preparePosition")) ::
              Data.ProtoLens.FieldDescriptor AllStreamPosition
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, commitPosition__field_descriptor),
           (Data.ProtoLens.Tag 2, preparePosition__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _AllStreamPosition'_unknownFields
        (\ x__ y__ -> x__ {_AllStreamPosition'_unknownFields = y__})
  defMessage
    = AllStreamPosition'_constructor
        {_AllStreamPosition'commitPosition = Data.ProtoLens.fieldDefault,
         _AllStreamPosition'preparePosition = Data.ProtoLens.fieldDefault,
         _AllStreamPosition'_unknownFields = []}
  parseMessage
    = let
        loop ::
          AllStreamPosition
          -> Data.ProtoLens.Encoding.Bytes.Parser AllStreamPosition
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "commit_position"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"commitPosition") y x)
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "prepare_position"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"preparePosition") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "AllStreamPosition"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view
                      (Data.ProtoLens.Field.field @"commitPosition") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
             ((Data.Monoid.<>)
                (let
                   _v
                     = Lens.Family2.view
                         (Data.ProtoLens.Field.field @"preparePosition") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData AllStreamPosition where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_AllStreamPosition'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_AllStreamPosition'commitPosition x__)
                (Control.DeepSeq.deepseq
                   (_AllStreamPosition'preparePosition x__) ()))
{- | Fields :
     
         * 'Proto.Shared_Fields.message' @:: Lens' BadRequest Data.Text.Text@ -}
data BadRequest
  = BadRequest'_constructor {_BadRequest'message :: !Data.Text.Text,
                             _BadRequest'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show BadRequest where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField BadRequest "message" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BadRequest'message (\ x__ y__ -> x__ {_BadRequest'message = y__}))
        Prelude.id
instance Data.ProtoLens.Message BadRequest where
  messageName _ = Data.Text.pack "event_store.client.BadRequest"
  packedMessageDescriptor _
    = "\n\
      \\n\
      \BadRequest\DC2\CAN\n\
      \\amessage\CAN\SOH \SOH(\tR\amessage"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        message__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "message"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"message")) ::
              Data.ProtoLens.FieldDescriptor BadRequest
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, message__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _BadRequest'_unknownFields
        (\ x__ y__ -> x__ {_BadRequest'_unknownFields = y__})
  defMessage
    = BadRequest'_constructor
        {_BadRequest'message = Data.ProtoLens.fieldDefault,
         _BadRequest'_unknownFields = []}
  parseMessage
    = let
        loop ::
          BadRequest -> Data.ProtoLens.Encoding.Bytes.Parser BadRequest
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getText
                                             (Prelude.fromIntegral len))
                                       "message"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"message") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "BadRequest"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v = Lens.Family2.view (Data.ProtoLens.Field.field @"message") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                      ((Prelude..)
                         (\ bs
                            -> (Data.Monoid.<>)
                                 (Data.ProtoLens.Encoding.Bytes.putVarInt
                                    (Prelude.fromIntegral (Data.ByteString.length bs)))
                                 (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                         Data.Text.Encoding.encodeUtf8 _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData BadRequest where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_BadRequest'_unknownFields x__)
             (Control.DeepSeq.deepseq (_BadRequest'message x__) ())
{- | Fields :
      -}
data Empty
  = Empty'_constructor {_Empty'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Empty where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Message Empty where
  messageName _ = Data.Text.pack "event_store.client.Empty"
  packedMessageDescriptor _
    = "\n\
      \\ENQEmpty"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag = let in Data.Map.fromList []
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Empty'_unknownFields
        (\ x__ y__ -> x__ {_Empty'_unknownFields = y__})
  defMessage = Empty'_constructor {_Empty'_unknownFields = []}
  parseMessage
    = let
        loop :: Empty -> Data.ProtoLens.Encoding.Bytes.Parser Empty
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Empty"
  buildMessage
    = \ _x
        -> Data.ProtoLens.Encoding.Wire.buildFieldSet
             (Lens.Family2.view Data.ProtoLens.unknownFields _x)
instance Control.DeepSeq.NFData Empty where
  rnf
    = \ x__ -> Control.DeepSeq.deepseq (_Empty'_unknownFields x__) ()
{- | Fields :
      -}
data InvalidTransaction
  = InvalidTransaction'_constructor {_InvalidTransaction'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show InvalidTransaction where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Message InvalidTransaction where
  messageName _
    = Data.Text.pack "event_store.client.InvalidTransaction"
  packedMessageDescriptor _
    = "\n\
      \\DC2InvalidTransaction"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag = let in Data.Map.fromList []
  unknownFields
    = Lens.Family2.Unchecked.lens
        _InvalidTransaction'_unknownFields
        (\ x__ y__ -> x__ {_InvalidTransaction'_unknownFields = y__})
  defMessage
    = InvalidTransaction'_constructor
        {_InvalidTransaction'_unknownFields = []}
  parseMessage
    = let
        loop ::
          InvalidTransaction
          -> Data.ProtoLens.Encoding.Bytes.Parser InvalidTransaction
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "InvalidTransaction"
  buildMessage
    = \ _x
        -> Data.ProtoLens.Encoding.Wire.buildFieldSet
             (Lens.Family2.view Data.ProtoLens.unknownFields _x)
instance Control.DeepSeq.NFData InvalidTransaction where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_InvalidTransaction'_unknownFields x__) ()
{- | Fields :
     
         * 'Proto.Shared_Fields.eventId' @:: Lens' MaximumAppendEventSizeExceeded Data.Text.Text@
         * 'Proto.Shared_Fields.proposedEventSize' @:: Lens' MaximumAppendEventSizeExceeded Data.Word.Word32@
         * 'Proto.Shared_Fields.maxAppendEventSize' @:: Lens' MaximumAppendEventSizeExceeded Data.Word.Word32@ -}
data MaximumAppendEventSizeExceeded
  = MaximumAppendEventSizeExceeded'_constructor {_MaximumAppendEventSizeExceeded'eventId :: !Data.Text.Text,
                                                 _MaximumAppendEventSizeExceeded'proposedEventSize :: !Data.Word.Word32,
                                                 _MaximumAppendEventSizeExceeded'maxAppendEventSize :: !Data.Word.Word32,
                                                 _MaximumAppendEventSizeExceeded'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show MaximumAppendEventSizeExceeded where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField MaximumAppendEventSizeExceeded "eventId" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _MaximumAppendEventSizeExceeded'eventId
           (\ x__ y__ -> x__ {_MaximumAppendEventSizeExceeded'eventId = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField MaximumAppendEventSizeExceeded "proposedEventSize" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _MaximumAppendEventSizeExceeded'proposedEventSize
           (\ x__ y__
              -> x__ {_MaximumAppendEventSizeExceeded'proposedEventSize = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField MaximumAppendEventSizeExceeded "maxAppendEventSize" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _MaximumAppendEventSizeExceeded'maxAppendEventSize
           (\ x__ y__
              -> x__ {_MaximumAppendEventSizeExceeded'maxAppendEventSize = y__}))
        Prelude.id
instance Data.ProtoLens.Message MaximumAppendEventSizeExceeded where
  messageName _
    = Data.Text.pack
        "event_store.client.MaximumAppendEventSizeExceeded"
  packedMessageDescriptor _
    = "\n\
      \\RSMaximumAppendEventSizeExceeded\DC2\CAN\n\
      \\aeventId\CAN\SOH \SOH(\tR\aeventId\DC2,\n\
      \\DC1proposedEventSize\CAN\STX \SOH(\rR\DC1proposedEventSize\DC2.\n\
      \\DC2maxAppendEventSize\CAN\ETX \SOH(\rR\DC2maxAppendEventSize"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        eventId__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "eventId"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"eventId")) ::
              Data.ProtoLens.FieldDescriptor MaximumAppendEventSizeExceeded
        proposedEventSize__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "proposedEventSize"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"proposedEventSize")) ::
              Data.ProtoLens.FieldDescriptor MaximumAppendEventSizeExceeded
        maxAppendEventSize__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "maxAppendEventSize"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"maxAppendEventSize")) ::
              Data.ProtoLens.FieldDescriptor MaximumAppendEventSizeExceeded
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, eventId__field_descriptor),
           (Data.ProtoLens.Tag 2, proposedEventSize__field_descriptor),
           (Data.ProtoLens.Tag 3, maxAppendEventSize__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _MaximumAppendEventSizeExceeded'_unknownFields
        (\ x__ y__
           -> x__ {_MaximumAppendEventSizeExceeded'_unknownFields = y__})
  defMessage
    = MaximumAppendEventSizeExceeded'_constructor
        {_MaximumAppendEventSizeExceeded'eventId = Data.ProtoLens.fieldDefault,
         _MaximumAppendEventSizeExceeded'proposedEventSize = Data.ProtoLens.fieldDefault,
         _MaximumAppendEventSizeExceeded'maxAppendEventSize = Data.ProtoLens.fieldDefault,
         _MaximumAppendEventSizeExceeded'_unknownFields = []}
  parseMessage
    = let
        loop ::
          MaximumAppendEventSizeExceeded
          -> Data.ProtoLens.Encoding.Bytes.Parser MaximumAppendEventSizeExceeded
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getText
                                             (Prelude.fromIntegral len))
                                       "eventId"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"eventId") y x)
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "proposedEventSize"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"proposedEventSize") y x)
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "maxAppendEventSize"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"maxAppendEventSize") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage)
          "MaximumAppendEventSizeExceeded"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v = Lens.Family2.view (Data.ProtoLens.Field.field @"eventId") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                      ((Prelude..)
                         (\ bs
                            -> (Data.Monoid.<>)
                                 (Data.ProtoLens.Encoding.Bytes.putVarInt
                                    (Prelude.fromIntegral (Data.ByteString.length bs)))
                                 (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                         Data.Text.Encoding.encodeUtf8 _v))
             ((Data.Monoid.<>)
                (let
                   _v
                     = Lens.Family2.view
                         (Data.ProtoLens.Field.field @"proposedEventSize") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         ((Prelude..)
                            Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                ((Data.Monoid.<>)
                   (let
                      _v
                        = Lens.Family2.view
                            (Data.ProtoLens.Field.field @"maxAppendEventSize") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                            ((Prelude..)
                               Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                   (Data.ProtoLens.Encoding.Wire.buildFieldSet
                      (Lens.Family2.view Data.ProtoLens.unknownFields _x))))
instance Control.DeepSeq.NFData MaximumAppendEventSizeExceeded where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_MaximumAppendEventSizeExceeded'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_MaximumAppendEventSizeExceeded'eventId x__)
                (Control.DeepSeq.deepseq
                   (_MaximumAppendEventSizeExceeded'proposedEventSize x__)
                   (Control.DeepSeq.deepseq
                      (_MaximumAppendEventSizeExceeded'maxAppendEventSize x__) ())))
{- | Fields :
     
         * 'Proto.Shared_Fields.maxAppendSize' @:: Lens' MaximumAppendSizeExceeded Data.Word.Word32@ -}
data MaximumAppendSizeExceeded
  = MaximumAppendSizeExceeded'_constructor {_MaximumAppendSizeExceeded'maxAppendSize :: !Data.Word.Word32,
                                            _MaximumAppendSizeExceeded'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show MaximumAppendSizeExceeded where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField MaximumAppendSizeExceeded "maxAppendSize" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _MaximumAppendSizeExceeded'maxAppendSize
           (\ x__ y__
              -> x__ {_MaximumAppendSizeExceeded'maxAppendSize = y__}))
        Prelude.id
instance Data.ProtoLens.Message MaximumAppendSizeExceeded where
  messageName _
    = Data.Text.pack "event_store.client.MaximumAppendSizeExceeded"
  packedMessageDescriptor _
    = "\n\
      \\EMMaximumAppendSizeExceeded\DC2$\n\
      \\rmaxAppendSize\CAN\SOH \SOH(\rR\rmaxAppendSize"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        maxAppendSize__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "maxAppendSize"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"maxAppendSize")) ::
              Data.ProtoLens.FieldDescriptor MaximumAppendSizeExceeded
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, maxAppendSize__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _MaximumAppendSizeExceeded'_unknownFields
        (\ x__ y__
           -> x__ {_MaximumAppendSizeExceeded'_unknownFields = y__})
  defMessage
    = MaximumAppendSizeExceeded'_constructor
        {_MaximumAppendSizeExceeded'maxAppendSize = Data.ProtoLens.fieldDefault,
         _MaximumAppendSizeExceeded'_unknownFields = []}
  parseMessage
    = let
        loop ::
          MaximumAppendSizeExceeded
          -> Data.ProtoLens.Encoding.Bytes.Parser MaximumAppendSizeExceeded
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "maxAppendSize"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"maxAppendSize") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "MaximumAppendSizeExceeded"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view
                      (Data.ProtoLens.Field.field @"maxAppendSize") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData MaximumAppendSizeExceeded where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_MaximumAppendSizeExceeded'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_MaximumAppendSizeExceeded'maxAppendSize x__) ())
{- | Fields :
     
         * 'Proto.Shared_Fields.streamIdentifier' @:: Lens' StreamDeleted StreamIdentifier@
         * 'Proto.Shared_Fields.maybe'streamIdentifier' @:: Lens' StreamDeleted (Prelude.Maybe StreamIdentifier)@ -}
data StreamDeleted
  = StreamDeleted'_constructor {_StreamDeleted'streamIdentifier :: !(Prelude.Maybe StreamIdentifier),
                                _StreamDeleted'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show StreamDeleted where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField StreamDeleted "streamIdentifier" StreamIdentifier where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _StreamDeleted'streamIdentifier
           (\ x__ y__ -> x__ {_StreamDeleted'streamIdentifier = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField StreamDeleted "maybe'streamIdentifier" (Prelude.Maybe StreamIdentifier) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _StreamDeleted'streamIdentifier
           (\ x__ y__ -> x__ {_StreamDeleted'streamIdentifier = y__}))
        Prelude.id
instance Data.ProtoLens.Message StreamDeleted where
  messageName _ = Data.Text.pack "event_store.client.StreamDeleted"
  packedMessageDescriptor _
    = "\n\
      \\rStreamDeleted\DC2Q\n\
      \\DC1stream_identifier\CAN\SOH \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        streamIdentifier__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stream_identifier"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor StreamIdentifier)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'streamIdentifier")) ::
              Data.ProtoLens.FieldDescriptor StreamDeleted
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, streamIdentifier__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _StreamDeleted'_unknownFields
        (\ x__ y__ -> x__ {_StreamDeleted'_unknownFields = y__})
  defMessage
    = StreamDeleted'_constructor
        {_StreamDeleted'streamIdentifier = Prelude.Nothing,
         _StreamDeleted'_unknownFields = []}
  parseMessage
    = let
        loop ::
          StreamDeleted -> Data.ProtoLens.Encoding.Bytes.Parser StreamDeleted
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "stream_identifier"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"streamIdentifier") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "StreamDeleted"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view
                    (Data.ProtoLens.Field.field @"maybe'streamIdentifier") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData StreamDeleted where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_StreamDeleted'_unknownFields x__)
             (Control.DeepSeq.deepseq (_StreamDeleted'streamIdentifier x__) ())
{- | Fields :
     
         * 'Proto.Shared_Fields.streamName' @:: Lens' StreamIdentifier Data.ByteString.ByteString@ -}
data StreamIdentifier
  = StreamIdentifier'_constructor {_StreamIdentifier'streamName :: !Data.ByteString.ByteString,
                                   _StreamIdentifier'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show StreamIdentifier where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField StreamIdentifier "streamName" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _StreamIdentifier'streamName
           (\ x__ y__ -> x__ {_StreamIdentifier'streamName = y__}))
        Prelude.id
instance Data.ProtoLens.Message StreamIdentifier where
  messageName _
    = Data.Text.pack "event_store.client.StreamIdentifier"
  packedMessageDescriptor _
    = "\n\
      \\DLEStreamIdentifier\DC2\US\n\
      \\vstream_name\CAN\ETX \SOH(\fR\n\
      \streamNameJ\EOT\b\SOH\DLE\ETX"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        streamName__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stream_name"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"streamName")) ::
              Data.ProtoLens.FieldDescriptor StreamIdentifier
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 3, streamName__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _StreamIdentifier'_unknownFields
        (\ x__ y__ -> x__ {_StreamIdentifier'_unknownFields = y__})
  defMessage
    = StreamIdentifier'_constructor
        {_StreamIdentifier'streamName = Data.ProtoLens.fieldDefault,
         _StreamIdentifier'_unknownFields = []}
  parseMessage
    = let
        loop ::
          StreamIdentifier
          -> Data.ProtoLens.Encoding.Bytes.Parser StreamIdentifier
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "stream_name"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"streamName") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "StreamIdentifier"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view (Data.ProtoLens.Field.field @"streamName") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                      ((\ bs
                          -> (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt
                                  (Prelude.fromIntegral (Data.ByteString.length bs)))
                               (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                         _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData StreamIdentifier where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_StreamIdentifier'_unknownFields x__)
             (Control.DeepSeq.deepseq (_StreamIdentifier'streamName x__) ())
{- | Fields :
      -}
data Timeout
  = Timeout'_constructor {_Timeout'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Timeout where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Message Timeout where
  messageName _ = Data.Text.pack "event_store.client.Timeout"
  packedMessageDescriptor _
    = "\n\
      \\aTimeout"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag = let in Data.Map.fromList []
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Timeout'_unknownFields
        (\ x__ y__ -> x__ {_Timeout'_unknownFields = y__})
  defMessage = Timeout'_constructor {_Timeout'_unknownFields = []}
  parseMessage
    = let
        loop :: Timeout -> Data.ProtoLens.Encoding.Bytes.Parser Timeout
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Timeout"
  buildMessage
    = \ _x
        -> Data.ProtoLens.Encoding.Wire.buildFieldSet
             (Lens.Family2.view Data.ProtoLens.unknownFields _x)
instance Control.DeepSeq.NFData Timeout where
  rnf
    = \ x__ -> Control.DeepSeq.deepseq (_Timeout'_unknownFields x__) ()
{- | Fields :
     
         * 'Proto.Shared_Fields.maybe'value' @:: Lens' UUID (Prelude.Maybe UUID'Value)@
         * 'Proto.Shared_Fields.maybe'structured' @:: Lens' UUID (Prelude.Maybe UUID'Structured)@
         * 'Proto.Shared_Fields.structured' @:: Lens' UUID UUID'Structured@
         * 'Proto.Shared_Fields.maybe'string' @:: Lens' UUID (Prelude.Maybe Data.Text.Text)@
         * 'Proto.Shared_Fields.string' @:: Lens' UUID Data.Text.Text@ -}
data UUID
  = UUID'_constructor {_UUID'value :: !(Prelude.Maybe UUID'Value),
                       _UUID'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show UUID where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data UUID'Value
  = UUID'Structured' !UUID'Structured | UUID'String !Data.Text.Text
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField UUID "maybe'value" (Prelude.Maybe UUID'Value) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _UUID'value (\ x__ y__ -> x__ {_UUID'value = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField UUID "maybe'structured" (Prelude.Maybe UUID'Structured) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _UUID'value (\ x__ y__ -> x__ {_UUID'value = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (UUID'Structured' x__val)) -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap UUID'Structured' y__))
instance Data.ProtoLens.Field.HasField UUID "structured" UUID'Structured where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _UUID'value (\ x__ y__ -> x__ {_UUID'value = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (UUID'Structured' x__val)) -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap UUID'Structured' y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField UUID "maybe'string" (Prelude.Maybe Data.Text.Text) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _UUID'value (\ x__ y__ -> x__ {_UUID'value = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (UUID'String x__val)) -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap UUID'String y__))
instance Data.ProtoLens.Field.HasField UUID "string" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _UUID'value (\ x__ y__ -> x__ {_UUID'value = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (UUID'String x__val)) -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap UUID'String y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Message UUID where
  messageName _ = Data.Text.pack "event_store.client.UUID"
  packedMessageDescriptor _
    = "\n\
      \\EOTUUID\DC2E\n\
      \\n\
      \structured\CAN\SOH \SOH(\v2#.event_store.client.UUID.StructuredH\NULR\n\
      \structured\DC2\CAN\n\
      \\ACKstring\CAN\STX \SOH(\tH\NULR\ACKstring\SUBv\n\
      \\n\
      \Structured\DC22\n\
      \\NAKmost_significant_bits\CAN\SOH \SOH(\ETXR\DC3mostSignificantBits\DC24\n\
      \\SYNleast_significant_bits\CAN\STX \SOH(\ETXR\DC4leastSignificantBitsB\a\n\
      \\ENQvalue"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        structured__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "structured"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor UUID'Structured)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'structured")) ::
              Data.ProtoLens.FieldDescriptor UUID
        string__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "string"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'string")) ::
              Data.ProtoLens.FieldDescriptor UUID
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, structured__field_descriptor),
           (Data.ProtoLens.Tag 2, string__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _UUID'_unknownFields
        (\ x__ y__ -> x__ {_UUID'_unknownFields = y__})
  defMessage
    = UUID'_constructor
        {_UUID'value = Prelude.Nothing, _UUID'_unknownFields = []}
  parseMessage
    = let
        loop :: UUID -> Data.ProtoLens.Encoding.Bytes.Parser UUID
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "structured"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"structured") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getText
                                             (Prelude.fromIntegral len))
                                       "string"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"string") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "UUID"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'value") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just (UUID'Structured' v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage v)
                (Prelude.Just (UUID'String v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.Text.Encoding.encodeUtf8 v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData UUID where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_UUID'_unknownFields x__)
             (Control.DeepSeq.deepseq (_UUID'value x__) ())
instance Control.DeepSeq.NFData UUID'Value where
  rnf (UUID'Structured' x__) = Control.DeepSeq.rnf x__
  rnf (UUID'String x__) = Control.DeepSeq.rnf x__
_UUID'Structured' ::
  Data.ProtoLens.Prism.Prism' UUID'Value UUID'Structured
_UUID'Structured'
  = Data.ProtoLens.Prism.prism'
      UUID'Structured'
      (\ p__
         -> case p__ of
              (UUID'Structured' p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_UUID'String ::
  Data.ProtoLens.Prism.Prism' UUID'Value Data.Text.Text
_UUID'String
  = Data.ProtoLens.Prism.prism'
      UUID'String
      (\ p__
         -> case p__ of
              (UUID'String p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.Shared_Fields.mostSignificantBits' @:: Lens' UUID'Structured Data.Int.Int64@
         * 'Proto.Shared_Fields.leastSignificantBits' @:: Lens' UUID'Structured Data.Int.Int64@ -}
data UUID'Structured
  = UUID'Structured'_constructor {_UUID'Structured'mostSignificantBits :: !Data.Int.Int64,
                                  _UUID'Structured'leastSignificantBits :: !Data.Int.Int64,
                                  _UUID'Structured'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show UUID'Structured where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField UUID'Structured "mostSignificantBits" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _UUID'Structured'mostSignificantBits
           (\ x__ y__ -> x__ {_UUID'Structured'mostSignificantBits = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField UUID'Structured "leastSignificantBits" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _UUID'Structured'leastSignificantBits
           (\ x__ y__ -> x__ {_UUID'Structured'leastSignificantBits = y__}))
        Prelude.id
instance Data.ProtoLens.Message UUID'Structured where
  messageName _ = Data.Text.pack "event_store.client.UUID.Structured"
  packedMessageDescriptor _
    = "\n\
      \\n\
      \Structured\DC22\n\
      \\NAKmost_significant_bits\CAN\SOH \SOH(\ETXR\DC3mostSignificantBits\DC24\n\
      \\SYNleast_significant_bits\CAN\STX \SOH(\ETXR\DC4leastSignificantBits"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        mostSignificantBits__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "most_significant_bits"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"mostSignificantBits")) ::
              Data.ProtoLens.FieldDescriptor UUID'Structured
        leastSignificantBits__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "least_significant_bits"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"leastSignificantBits")) ::
              Data.ProtoLens.FieldDescriptor UUID'Structured
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, mostSignificantBits__field_descriptor),
           (Data.ProtoLens.Tag 2, leastSignificantBits__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _UUID'Structured'_unknownFields
        (\ x__ y__ -> x__ {_UUID'Structured'_unknownFields = y__})
  defMessage
    = UUID'Structured'_constructor
        {_UUID'Structured'mostSignificantBits = Data.ProtoLens.fieldDefault,
         _UUID'Structured'leastSignificantBits = Data.ProtoLens.fieldDefault,
         _UUID'Structured'_unknownFields = []}
  parseMessage
    = let
        loop ::
          UUID'Structured
          -> Data.ProtoLens.Encoding.Bytes.Parser UUID'Structured
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "most_significant_bits"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"mostSignificantBits") y x)
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "least_significant_bits"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"leastSignificantBits") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Structured"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view
                      (Data.ProtoLens.Field.field @"mostSignificantBits") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
             ((Data.Monoid.<>)
                (let
                   _v
                     = Lens.Family2.view
                         (Data.ProtoLens.Field.field @"leastSignificantBits") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         ((Prelude..)
                            Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData UUID'Structured where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_UUID'Structured'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_UUID'Structured'mostSignificantBits x__)
                (Control.DeepSeq.deepseq
                   (_UUID'Structured'leastSignificantBits x__) ()))
{- | Fields :
      -}
data Unknown
  = Unknown'_constructor {_Unknown'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Unknown where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Message Unknown where
  messageName _ = Data.Text.pack "event_store.client.Unknown"
  packedMessageDescriptor _
    = "\n\
      \\aUnknown"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag = let in Data.Map.fromList []
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Unknown'_unknownFields
        (\ x__ y__ -> x__ {_Unknown'_unknownFields = y__})
  defMessage = Unknown'_constructor {_Unknown'_unknownFields = []}
  parseMessage
    = let
        loop :: Unknown -> Data.ProtoLens.Encoding.Bytes.Parser Unknown
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Unknown"
  buildMessage
    = \ _x
        -> Data.ProtoLens.Encoding.Wire.buildFieldSet
             (Lens.Family2.view Data.ProtoLens.unknownFields _x)
instance Control.DeepSeq.NFData Unknown where
  rnf
    = \ x__ -> Control.DeepSeq.deepseq (_Unknown'_unknownFields x__) ()
{- | Fields :
     
         * 'Proto.Shared_Fields.maybe'currentStreamRevisionOption' @:: Lens' WrongExpectedVersion (Prelude.Maybe WrongExpectedVersion'CurrentStreamRevisionOption)@
         * 'Proto.Shared_Fields.maybe'currentStreamRevision' @:: Lens' WrongExpectedVersion (Prelude.Maybe Data.Word.Word64)@
         * 'Proto.Shared_Fields.currentStreamRevision' @:: Lens' WrongExpectedVersion Data.Word.Word64@
         * 'Proto.Shared_Fields.maybe'currentNoStream' @:: Lens' WrongExpectedVersion (Prelude.Maybe Proto.Google.Protobuf.Empty.Empty)@
         * 'Proto.Shared_Fields.currentNoStream' @:: Lens' WrongExpectedVersion Proto.Google.Protobuf.Empty.Empty@
         * 'Proto.Shared_Fields.maybe'expectedStreamPositionOption' @:: Lens' WrongExpectedVersion (Prelude.Maybe WrongExpectedVersion'ExpectedStreamPositionOption)@
         * 'Proto.Shared_Fields.maybe'expectedStreamPosition' @:: Lens' WrongExpectedVersion (Prelude.Maybe Data.Word.Word64)@
         * 'Proto.Shared_Fields.expectedStreamPosition' @:: Lens' WrongExpectedVersion Data.Word.Word64@
         * 'Proto.Shared_Fields.maybe'expectedAny' @:: Lens' WrongExpectedVersion (Prelude.Maybe Proto.Google.Protobuf.Empty.Empty)@
         * 'Proto.Shared_Fields.expectedAny' @:: Lens' WrongExpectedVersion Proto.Google.Protobuf.Empty.Empty@
         * 'Proto.Shared_Fields.maybe'expectedStreamExists' @:: Lens' WrongExpectedVersion (Prelude.Maybe Proto.Google.Protobuf.Empty.Empty)@
         * 'Proto.Shared_Fields.expectedStreamExists' @:: Lens' WrongExpectedVersion Proto.Google.Protobuf.Empty.Empty@
         * 'Proto.Shared_Fields.maybe'expectedNoStream' @:: Lens' WrongExpectedVersion (Prelude.Maybe Proto.Google.Protobuf.Empty.Empty)@
         * 'Proto.Shared_Fields.expectedNoStream' @:: Lens' WrongExpectedVersion Proto.Google.Protobuf.Empty.Empty@ -}
data WrongExpectedVersion
  = WrongExpectedVersion'_constructor {_WrongExpectedVersion'currentStreamRevisionOption :: !(Prelude.Maybe WrongExpectedVersion'CurrentStreamRevisionOption),
                                       _WrongExpectedVersion'expectedStreamPositionOption :: !(Prelude.Maybe WrongExpectedVersion'ExpectedStreamPositionOption),
                                       _WrongExpectedVersion'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show WrongExpectedVersion where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data WrongExpectedVersion'CurrentStreamRevisionOption
  = WrongExpectedVersion'CurrentStreamRevision !Data.Word.Word64 |
    WrongExpectedVersion'CurrentNoStream !Proto.Google.Protobuf.Empty.Empty
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
data WrongExpectedVersion'ExpectedStreamPositionOption
  = WrongExpectedVersion'ExpectedStreamPosition !Data.Word.Word64 |
    WrongExpectedVersion'ExpectedAny !Proto.Google.Protobuf.Empty.Empty |
    WrongExpectedVersion'ExpectedStreamExists !Proto.Google.Protobuf.Empty.Empty |
    WrongExpectedVersion'ExpectedNoStream !Proto.Google.Protobuf.Empty.Empty
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField WrongExpectedVersion "maybe'currentStreamRevisionOption" (Prelude.Maybe WrongExpectedVersion'CurrentStreamRevisionOption) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _WrongExpectedVersion'currentStreamRevisionOption
           (\ x__ y__
              -> x__ {_WrongExpectedVersion'currentStreamRevisionOption = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField WrongExpectedVersion "maybe'currentStreamRevision" (Prelude.Maybe Data.Word.Word64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _WrongExpectedVersion'currentStreamRevisionOption
           (\ x__ y__
              -> x__ {_WrongExpectedVersion'currentStreamRevisionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (WrongExpectedVersion'CurrentStreamRevision x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__
              -> Prelude.fmap WrongExpectedVersion'CurrentStreamRevision y__))
instance Data.ProtoLens.Field.HasField WrongExpectedVersion "currentStreamRevision" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _WrongExpectedVersion'currentStreamRevisionOption
           (\ x__ y__
              -> x__ {_WrongExpectedVersion'currentStreamRevisionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (WrongExpectedVersion'CurrentStreamRevision x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__
                 -> Prelude.fmap WrongExpectedVersion'CurrentStreamRevision y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Field.HasField WrongExpectedVersion "maybe'currentNoStream" (Prelude.Maybe Proto.Google.Protobuf.Empty.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _WrongExpectedVersion'currentStreamRevisionOption
           (\ x__ y__
              -> x__ {_WrongExpectedVersion'currentStreamRevisionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (WrongExpectedVersion'CurrentNoStream x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap WrongExpectedVersion'CurrentNoStream y__))
instance Data.ProtoLens.Field.HasField WrongExpectedVersion "currentNoStream" Proto.Google.Protobuf.Empty.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _WrongExpectedVersion'currentStreamRevisionOption
           (\ x__ y__
              -> x__ {_WrongExpectedVersion'currentStreamRevisionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (WrongExpectedVersion'CurrentNoStream x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap WrongExpectedVersion'CurrentNoStream y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField WrongExpectedVersion "maybe'expectedStreamPositionOption" (Prelude.Maybe WrongExpectedVersion'ExpectedStreamPositionOption) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _WrongExpectedVersion'expectedStreamPositionOption
           (\ x__ y__
              -> x__ {_WrongExpectedVersion'expectedStreamPositionOption = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField WrongExpectedVersion "maybe'expectedStreamPosition" (Prelude.Maybe Data.Word.Word64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _WrongExpectedVersion'expectedStreamPositionOption
           (\ x__ y__
              -> x__ {_WrongExpectedVersion'expectedStreamPositionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (WrongExpectedVersion'ExpectedStreamPosition x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__
              -> Prelude.fmap WrongExpectedVersion'ExpectedStreamPosition y__))
instance Data.ProtoLens.Field.HasField WrongExpectedVersion "expectedStreamPosition" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _WrongExpectedVersion'expectedStreamPositionOption
           (\ x__ y__
              -> x__ {_WrongExpectedVersion'expectedStreamPositionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (WrongExpectedVersion'ExpectedStreamPosition x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__
                 -> Prelude.fmap WrongExpectedVersion'ExpectedStreamPosition y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Field.HasField WrongExpectedVersion "maybe'expectedAny" (Prelude.Maybe Proto.Google.Protobuf.Empty.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _WrongExpectedVersion'expectedStreamPositionOption
           (\ x__ y__
              -> x__ {_WrongExpectedVersion'expectedStreamPositionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (WrongExpectedVersion'ExpectedAny x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap WrongExpectedVersion'ExpectedAny y__))
instance Data.ProtoLens.Field.HasField WrongExpectedVersion "expectedAny" Proto.Google.Protobuf.Empty.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _WrongExpectedVersion'expectedStreamPositionOption
           (\ x__ y__
              -> x__ {_WrongExpectedVersion'expectedStreamPositionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (WrongExpectedVersion'ExpectedAny x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap WrongExpectedVersion'ExpectedAny y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField WrongExpectedVersion "maybe'expectedStreamExists" (Prelude.Maybe Proto.Google.Protobuf.Empty.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _WrongExpectedVersion'expectedStreamPositionOption
           (\ x__ y__
              -> x__ {_WrongExpectedVersion'expectedStreamPositionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (WrongExpectedVersion'ExpectedStreamExists x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__
              -> Prelude.fmap WrongExpectedVersion'ExpectedStreamExists y__))
instance Data.ProtoLens.Field.HasField WrongExpectedVersion "expectedStreamExists" Proto.Google.Protobuf.Empty.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _WrongExpectedVersion'expectedStreamPositionOption
           (\ x__ y__
              -> x__ {_WrongExpectedVersion'expectedStreamPositionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (WrongExpectedVersion'ExpectedStreamExists x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__
                 -> Prelude.fmap WrongExpectedVersion'ExpectedStreamExists y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField WrongExpectedVersion "maybe'expectedNoStream" (Prelude.Maybe Proto.Google.Protobuf.Empty.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _WrongExpectedVersion'expectedStreamPositionOption
           (\ x__ y__
              -> x__ {_WrongExpectedVersion'expectedStreamPositionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (WrongExpectedVersion'ExpectedNoStream x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__
              -> Prelude.fmap WrongExpectedVersion'ExpectedNoStream y__))
instance Data.ProtoLens.Field.HasField WrongExpectedVersion "expectedNoStream" Proto.Google.Protobuf.Empty.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _WrongExpectedVersion'expectedStreamPositionOption
           (\ x__ y__
              -> x__ {_WrongExpectedVersion'expectedStreamPositionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (WrongExpectedVersion'ExpectedNoStream x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__
                 -> Prelude.fmap WrongExpectedVersion'ExpectedNoStream y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message WrongExpectedVersion where
  messageName _
    = Data.Text.pack "event_store.client.WrongExpectedVersion"
  packedMessageDescriptor _
    = "\n\
      \\DC4WrongExpectedVersion\DC28\n\
      \\ETBcurrent_stream_revision\CAN\SOH \SOH(\EOTH\NULR\NAKcurrentStreamRevision\DC2D\n\
      \\DC1current_no_stream\CAN\STX \SOH(\v2\SYN.google.protobuf.EmptyH\NULR\SIcurrentNoStream\DC2:\n\
      \\CANexpected_stream_position\CAN\ETX \SOH(\EOTH\SOHR\SYNexpectedStreamPosition\DC2;\n\
      \\fexpected_any\CAN\EOT \SOH(\v2\SYN.google.protobuf.EmptyH\SOHR\vexpectedAny\DC2N\n\
      \\SYNexpected_stream_exists\CAN\ENQ \SOH(\v2\SYN.google.protobuf.EmptyH\SOHR\DC4expectedStreamExists\DC2F\n\
      \\DC2expected_no_stream\CAN\ACK \SOH(\v2\SYN.google.protobuf.EmptyH\SOHR\DLEexpectedNoStreamB \n\
      \\RScurrent_stream_revision_optionB!\n\
      \\USexpected_stream_position_option"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        currentStreamRevision__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "current_stream_revision"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'currentStreamRevision")) ::
              Data.ProtoLens.FieldDescriptor WrongExpectedVersion
        currentNoStream__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "current_no_stream"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Google.Protobuf.Empty.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'currentNoStream")) ::
              Data.ProtoLens.FieldDescriptor WrongExpectedVersion
        expectedStreamPosition__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "expected_stream_position"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'expectedStreamPosition")) ::
              Data.ProtoLens.FieldDescriptor WrongExpectedVersion
        expectedAny__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "expected_any"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Google.Protobuf.Empty.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'expectedAny")) ::
              Data.ProtoLens.FieldDescriptor WrongExpectedVersion
        expectedStreamExists__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "expected_stream_exists"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Google.Protobuf.Empty.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'expectedStreamExists")) ::
              Data.ProtoLens.FieldDescriptor WrongExpectedVersion
        expectedNoStream__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "expected_no_stream"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Google.Protobuf.Empty.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'expectedNoStream")) ::
              Data.ProtoLens.FieldDescriptor WrongExpectedVersion
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, currentStreamRevision__field_descriptor),
           (Data.ProtoLens.Tag 2, currentNoStream__field_descriptor),
           (Data.ProtoLens.Tag 3, expectedStreamPosition__field_descriptor),
           (Data.ProtoLens.Tag 4, expectedAny__field_descriptor),
           (Data.ProtoLens.Tag 5, expectedStreamExists__field_descriptor),
           (Data.ProtoLens.Tag 6, expectedNoStream__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _WrongExpectedVersion'_unknownFields
        (\ x__ y__ -> x__ {_WrongExpectedVersion'_unknownFields = y__})
  defMessage
    = WrongExpectedVersion'_constructor
        {_WrongExpectedVersion'currentStreamRevisionOption = Prelude.Nothing,
         _WrongExpectedVersion'expectedStreamPositionOption = Prelude.Nothing,
         _WrongExpectedVersion'_unknownFields = []}
  parseMessage
    = let
        loop ::
          WrongExpectedVersion
          -> Data.ProtoLens.Encoding.Bytes.Parser WrongExpectedVersion
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt
                                       "current_stream_revision"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"currentStreamRevision") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "current_no_stream"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"currentNoStream") y x)
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt
                                       "expected_stream_position"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"expectedStreamPosition") y x)
                        34
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "expected_any"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"expectedAny") y x)
                        42
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "expected_stream_exists"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"expectedStreamExists") y x)
                        50
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "expected_no_stream"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"expectedNoStream") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "WrongExpectedVersion"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view
                    (Data.ProtoLens.Field.field @"maybe'currentStreamRevisionOption")
                    _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just (WrongExpectedVersion'CurrentStreamRevision v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt v)
                (Prelude.Just (WrongExpectedVersion'CurrentNoStream v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage v))
             ((Data.Monoid.<>)
                (case
                     Lens.Family2.view
                       (Data.ProtoLens.Field.field @"maybe'expectedStreamPositionOption")
                       _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just (WrongExpectedVersion'ExpectedStreamPosition v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt v)
                   (Prelude.Just (WrongExpectedVersion'ExpectedAny v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 34)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage v)
                   (Prelude.Just (WrongExpectedVersion'ExpectedStreamExists v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 42)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage v)
                   (Prelude.Just (WrongExpectedVersion'ExpectedNoStream v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 50)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData WrongExpectedVersion where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_WrongExpectedVersion'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_WrongExpectedVersion'currentStreamRevisionOption x__)
                (Control.DeepSeq.deepseq
                   (_WrongExpectedVersion'expectedStreamPositionOption x__) ()))
instance Control.DeepSeq.NFData WrongExpectedVersion'CurrentStreamRevisionOption where
  rnf (WrongExpectedVersion'CurrentStreamRevision x__)
    = Control.DeepSeq.rnf x__
  rnf (WrongExpectedVersion'CurrentNoStream x__)
    = Control.DeepSeq.rnf x__
instance Control.DeepSeq.NFData WrongExpectedVersion'ExpectedStreamPositionOption where
  rnf (WrongExpectedVersion'ExpectedStreamPosition x__)
    = Control.DeepSeq.rnf x__
  rnf (WrongExpectedVersion'ExpectedAny x__)
    = Control.DeepSeq.rnf x__
  rnf (WrongExpectedVersion'ExpectedStreamExists x__)
    = Control.DeepSeq.rnf x__
  rnf (WrongExpectedVersion'ExpectedNoStream x__)
    = Control.DeepSeq.rnf x__
_WrongExpectedVersion'CurrentStreamRevision ::
  Data.ProtoLens.Prism.Prism' WrongExpectedVersion'CurrentStreamRevisionOption Data.Word.Word64
_WrongExpectedVersion'CurrentStreamRevision
  = Data.ProtoLens.Prism.prism'
      WrongExpectedVersion'CurrentStreamRevision
      (\ p__
         -> case p__ of
              (WrongExpectedVersion'CurrentStreamRevision p__val)
                -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_WrongExpectedVersion'CurrentNoStream ::
  Data.ProtoLens.Prism.Prism' WrongExpectedVersion'CurrentStreamRevisionOption Proto.Google.Protobuf.Empty.Empty
_WrongExpectedVersion'CurrentNoStream
  = Data.ProtoLens.Prism.prism'
      WrongExpectedVersion'CurrentNoStream
      (\ p__
         -> case p__ of
              (WrongExpectedVersion'CurrentNoStream p__val)
                -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_WrongExpectedVersion'ExpectedStreamPosition ::
  Data.ProtoLens.Prism.Prism' WrongExpectedVersion'ExpectedStreamPositionOption Data.Word.Word64
_WrongExpectedVersion'ExpectedStreamPosition
  = Data.ProtoLens.Prism.prism'
      WrongExpectedVersion'ExpectedStreamPosition
      (\ p__
         -> case p__ of
              (WrongExpectedVersion'ExpectedStreamPosition p__val)
                -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_WrongExpectedVersion'ExpectedAny ::
  Data.ProtoLens.Prism.Prism' WrongExpectedVersion'ExpectedStreamPositionOption Proto.Google.Protobuf.Empty.Empty
_WrongExpectedVersion'ExpectedAny
  = Data.ProtoLens.Prism.prism'
      WrongExpectedVersion'ExpectedAny
      (\ p__
         -> case p__ of
              (WrongExpectedVersion'ExpectedAny p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_WrongExpectedVersion'ExpectedStreamExists ::
  Data.ProtoLens.Prism.Prism' WrongExpectedVersion'ExpectedStreamPositionOption Proto.Google.Protobuf.Empty.Empty
_WrongExpectedVersion'ExpectedStreamExists
  = Data.ProtoLens.Prism.prism'
      WrongExpectedVersion'ExpectedStreamExists
      (\ p__
         -> case p__ of
              (WrongExpectedVersion'ExpectedStreamExists p__val)
                -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_WrongExpectedVersion'ExpectedNoStream ::
  Data.ProtoLens.Prism.Prism' WrongExpectedVersion'ExpectedStreamPositionOption Proto.Google.Protobuf.Empty.Empty
_WrongExpectedVersion'ExpectedNoStream
  = Data.ProtoLens.Prism.prism'
      WrongExpectedVersion'ExpectedNoStream
      (\ p__
         -> case p__ of
              (WrongExpectedVersion'ExpectedNoStream p__val)
                -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
packedFileDescriptor :: Data.ByteString.ByteString
packedFileDescriptor
  = "\n\
    \\fshared.proto\DC2\DC2event_store.client\SUB\ESCgoogle/protobuf/empty.proto\"\232\SOH\n\
    \\EOTUUID\DC2E\n\
    \\n\
    \structured\CAN\SOH \SOH(\v2#.event_store.client.UUID.StructuredH\NULR\n\
    \structured\DC2\CAN\n\
    \\ACKstring\CAN\STX \SOH(\tH\NULR\ACKstring\SUBv\n\
    \\n\
    \Structured\DC22\n\
    \\NAKmost_significant_bits\CAN\SOH \SOH(\ETXR\DC3mostSignificantBits\DC24\n\
    \\SYNleast_significant_bits\CAN\STX \SOH(\ETXR\DC4leastSignificantBitsB\a\n\
    \\ENQvalue\"\a\n\
    \\ENQEmpty\"9\n\
    \\DLEStreamIdentifier\DC2\US\n\
    \\vstream_name\CAN\ETX \SOH(\fR\n\
    \streamNameJ\EOT\b\SOH\DLE\ETX\"g\n\
    \\DC1AllStreamPosition\DC2'\n\
    \\SIcommit_position\CAN\SOH \SOH(\EOTR\SOcommitPosition\DC2)\n\
    \\DLEprepare_position\CAN\STX \SOH(\EOTR\SIpreparePosition\"\236\ETX\n\
    \\DC4WrongExpectedVersion\DC28\n\
    \\ETBcurrent_stream_revision\CAN\SOH \SOH(\EOTH\NULR\NAKcurrentStreamRevision\DC2D\n\
    \\DC1current_no_stream\CAN\STX \SOH(\v2\SYN.google.protobuf.EmptyH\NULR\SIcurrentNoStream\DC2:\n\
    \\CANexpected_stream_position\CAN\ETX \SOH(\EOTH\SOHR\SYNexpectedStreamPosition\DC2;\n\
    \\fexpected_any\CAN\EOT \SOH(\v2\SYN.google.protobuf.EmptyH\SOHR\vexpectedAny\DC2N\n\
    \\SYNexpected_stream_exists\CAN\ENQ \SOH(\v2\SYN.google.protobuf.EmptyH\SOHR\DC4expectedStreamExists\DC2F\n\
    \\DC2expected_no_stream\CAN\ACK \SOH(\v2\SYN.google.protobuf.EmptyH\SOHR\DLEexpectedNoStreamB \n\
    \\RScurrent_stream_revision_optionB!\n\
    \\USexpected_stream_position_option\"\SO\n\
    \\fAccessDenied\"b\n\
    \\rStreamDeleted\DC2Q\n\
    \\DC1stream_identifier\CAN\SOH \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier\"\t\n\
    \\aTimeout\"\t\n\
    \\aUnknown\"\DC4\n\
    \\DC2InvalidTransaction\"A\n\
    \\EMMaximumAppendSizeExceeded\DC2$\n\
    \\rmaxAppendSize\CAN\SOH \SOH(\rR\rmaxAppendSize\"\152\SOH\n\
    \\RSMaximumAppendEventSizeExceeded\DC2\CAN\n\
    \\aeventId\CAN\SOH \SOH(\tR\aeventId\DC2,\n\
    \\DC1proposedEventSize\CAN\STX \SOH(\rR\DC1proposedEventSize\DC2.\n\
    \\DC2maxAppendEventSize\CAN\ETX \SOH(\rR\DC2maxAppendEventSize\"&\n\
    \\n\
    \BadRequest\DC2\CAN\n\
    \\amessage\CAN\SOH \SOH(\tR\amessageB&\n\
    \$com.eventstore.dbclient.proto.sharedJ\186\f\n\
    \\ACK\DC2\EOT\NUL\NULB\SOH\n\
    \\b\n\
    \\SOH\f\DC2\ETX\NUL\NUL\DC2\n\
    \\b\n\
    \\SOH\STX\DC2\ETX\SOH\NUL\ESC\n\
    \\b\n\
    \\SOH\b\DC2\ETX\STX\NUL=\n\
    \\t\n\
    \\STX\b\SOH\DC2\ETX\STX\NUL=\n\
    \\t\n\
    \\STX\ETX\NUL\DC2\ETX\ETX\NUL%\n\
    \\n\
    \\n\
    \\STX\EOT\NUL\DC2\EOT\ENQ\NUL\SI\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\NUL\SOH\DC2\ETX\ENQ\b\f\n\
    \\f\n\
    \\EOT\EOT\NUL\b\NUL\DC2\EOT\ACK\b\t\t\n\
    \\f\n\
    \\ENQ\EOT\NUL\b\NUL\SOH\DC2\ETX\ACK\SO\DC3\n\
    \\v\n\
    \\EOT\EOT\NUL\STX\NUL\DC2\ETX\a\DLE*\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ACK\DC2\ETX\a\DLE\SUB\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\SOH\DC2\ETX\a\ESC%\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ETX\DC2\ETX\a()\n\
    \\v\n\
    \\EOT\EOT\NUL\STX\SOH\DC2\ETX\b\DLE\"\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\ENQ\DC2\ETX\b\DLE\SYN\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\SOH\DC2\ETX\b\ETB\GS\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\ETX\DC2\ETX\b !\n\
    \\f\n\
    \\EOT\EOT\NUL\ETX\NUL\DC2\EOT\v\b\SO\t\n\
    \\f\n\
    \\ENQ\EOT\NUL\ETX\NUL\SOH\DC2\ETX\v\DLE\SUB\n\
    \\r\n\
    \\ACK\EOT\NUL\ETX\NUL\STX\NUL\DC2\ETX\f\DLE0\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\NUL\ENQ\DC2\ETX\f\DLE\NAK\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\NUL\SOH\DC2\ETX\f\SYN+\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\NUL\ETX\DC2\ETX\f./\n\
    \\r\n\
    \\ACK\EOT\NUL\ETX\NUL\STX\SOH\DC2\ETX\r\DLE1\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\SOH\ENQ\DC2\ETX\r\DLE\NAK\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\SOH\SOH\DC2\ETX\r\SYN,\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\SOH\ETX\DC2\ETX\r/0\n\
    \\n\
    \\n\
    \\STX\EOT\SOH\DC2\EOT\DLE\NUL\DC1\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\SOH\SOH\DC2\ETX\DLE\b\r\n\
    \\n\
    \\n\
    \\STX\EOT\STX\DC2\EOT\DC3\NUL\SYN\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\STX\SOH\DC2\ETX\DC3\b\CAN\n\
    \\n\
    \\n\
    \\ETX\EOT\STX\t\DC2\ETX\DC4\b\CAN\n\
    \\v\n\
    \\EOT\EOT\STX\t\NUL\DC2\ETX\DC4\DC1\ETB\n\
    \\f\n\
    \\ENQ\EOT\STX\t\NUL\SOH\DC2\ETX\DC4\DC1\DC2\n\
    \\f\n\
    \\ENQ\EOT\STX\t\NUL\STX\DC2\ETX\DC4\SYN\ETB\n\
    \\v\n\
    \\EOT\EOT\STX\STX\NUL\DC2\ETX\NAK\b\RS\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\ENQ\DC2\ETX\NAK\b\r\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\SOH\DC2\ETX\NAK\SO\EM\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\ETX\DC2\ETX\NAK\FS\GS\n\
    \\n\
    \\n\
    \\STX\EOT\ETX\DC2\EOT\CAN\NUL\ESC\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\ETX\SOH\DC2\ETX\CAN\b\EM\n\
    \\v\n\
    \\EOT\EOT\ETX\STX\NUL\DC2\ETX\EM\b#\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\NUL\ENQ\DC2\ETX\EM\b\SO\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\NUL\SOH\DC2\ETX\EM\SI\RS\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\NUL\ETX\DC2\ETX\EM!\"\n\
    \\v\n\
    \\EOT\EOT\ETX\STX\SOH\DC2\ETX\SUB\b$\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\SOH\ENQ\DC2\ETX\SUB\b\SO\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\SOH\SOH\DC2\ETX\SUB\SI\US\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\SOH\ETX\DC2\ETX\SUB\"#\n\
    \\n\
    \\n\
    \\STX\EOT\EOT\DC2\EOT\GS\NUL(\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\EOT\SOH\DC2\ETX\GS\b\FS\n\
    \\f\n\
    \\EOT\EOT\EOT\b\NUL\DC2\EOT\RS\b!\t\n\
    \\f\n\
    \\ENQ\EOT\EOT\b\NUL\SOH\DC2\ETX\RS\SO,\n\
    \\v\n\
    \\EOT\EOT\EOT\STX\NUL\DC2\ETX\US\DLE3\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\NUL\ENQ\DC2\ETX\US\DLE\SYN\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\NUL\SOH\DC2\ETX\US\ETB.\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\NUL\ETX\DC2\ETX\US12\n\
    \\v\n\
    \\EOT\EOT\EOT\STX\SOH\DC2\ETX \DLE<\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\SOH\ACK\DC2\ETX \DLE%\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\SOH\SOH\DC2\ETX &7\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\SOH\ETX\DC2\ETX :;\n\
    \\f\n\
    \\EOT\EOT\EOT\b\SOH\DC2\EOT\"\b'\t\n\
    \\f\n\
    \\ENQ\EOT\EOT\b\SOH\SOH\DC2\ETX\"\SO-\n\
    \\v\n\
    \\EOT\EOT\EOT\STX\STX\DC2\ETX#\DLE4\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\STX\ENQ\DC2\ETX#\DLE\SYN\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\STX\SOH\DC2\ETX#\ETB/\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\STX\ETX\DC2\ETX#23\n\
    \\v\n\
    \\EOT\EOT\EOT\STX\ETX\DC2\ETX$\DLE7\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\ETX\ACK\DC2\ETX$\DLE%\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\ETX\SOH\DC2\ETX$&2\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\ETX\ETX\DC2\ETX$56\n\
    \\v\n\
    \\EOT\EOT\EOT\STX\EOT\DC2\ETX%\DLEA\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\EOT\ACK\DC2\ETX%\DLE%\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\EOT\SOH\DC2\ETX%&<\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\EOT\ETX\DC2\ETX%?@\n\
    \\v\n\
    \\EOT\EOT\EOT\STX\ENQ\DC2\ETX&\DLE=\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\ENQ\ACK\DC2\ETX&\DLE%\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\ENQ\SOH\DC2\ETX&&8\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\ENQ\ETX\DC2\ETX&;<\n\
    \\t\n\
    \\STX\EOT\ENQ\DC2\ETX*\NUL\ETB\n\
    \\n\
    \\n\
    \\ETX\EOT\ENQ\SOH\DC2\ETX*\b\DC4\n\
    \\n\
    \\n\
    \\STX\EOT\ACK\DC2\EOT,\NUL.\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\ACK\SOH\DC2\ETX,\b\NAK\n\
    \\v\n\
    \\EOT\EOT\ACK\STX\NUL\DC2\ETX-\b/\n\
    \\f\n\
    \\ENQ\EOT\ACK\STX\NUL\ACK\DC2\ETX-\b\CAN\n\
    \\f\n\
    \\ENQ\EOT\ACK\STX\NUL\SOH\DC2\ETX-\EM*\n\
    \\f\n\
    \\ENQ\EOT\ACK\STX\NUL\ETX\DC2\ETX--.\n\
    \\t\n\
    \\STX\EOT\a\DC2\ETX0\NUL\DC2\n\
    \\n\
    \\n\
    \\ETX\EOT\a\SOH\DC2\ETX0\b\SI\n\
    \\t\n\
    \\STX\EOT\b\DC2\ETX2\NUL\DC2\n\
    \\n\
    \\n\
    \\ETX\EOT\b\SOH\DC2\ETX2\b\SI\n\
    \\t\n\
    \\STX\EOT\t\DC2\ETX4\NUL\GS\n\
    \\n\
    \\n\
    \\ETX\EOT\t\SOH\DC2\ETX4\b\SUB\n\
    \\n\
    \\n\
    \\STX\EOT\n\
    \\DC2\EOT6\NUL8\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\n\
    \\SOH\DC2\ETX6\b!\n\
    \\v\n\
    \\EOT\EOT\n\
    \\STX\NUL\DC2\ETX7\b!\n\
    \\f\n\
    \\ENQ\EOT\n\
    \\STX\NUL\ENQ\DC2\ETX7\b\SO\n\
    \\f\n\
    \\ENQ\EOT\n\
    \\STX\NUL\SOH\DC2\ETX7\SI\FS\n\
    \\f\n\
    \\ENQ\EOT\n\
    \\STX\NUL\ETX\DC2\ETX7\US \n\
    \\n\
    \\n\
    \\STX\EOT\v\DC2\EOT:\NUL>\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\v\SOH\DC2\ETX:\b&\n\
    \\v\n\
    \\EOT\EOT\v\STX\NUL\DC2\ETX;\b\ESC\n\
    \\f\n\
    \\ENQ\EOT\v\STX\NUL\ENQ\DC2\ETX;\b\SO\n\
    \\f\n\
    \\ENQ\EOT\v\STX\NUL\SOH\DC2\ETX;\SI\SYN\n\
    \\f\n\
    \\ENQ\EOT\v\STX\NUL\ETX\DC2\ETX;\EM\SUB\n\
    \\v\n\
    \\EOT\EOT\v\STX\SOH\DC2\ETX<\b%\n\
    \\f\n\
    \\ENQ\EOT\v\STX\SOH\ENQ\DC2\ETX<\b\SO\n\
    \\f\n\
    \\ENQ\EOT\v\STX\SOH\SOH\DC2\ETX<\SI \n\
    \\f\n\
    \\ENQ\EOT\v\STX\SOH\ETX\DC2\ETX<#$\n\
    \\v\n\
    \\EOT\EOT\v\STX\STX\DC2\ETX=\b&\n\
    \\f\n\
    \\ENQ\EOT\v\STX\STX\ENQ\DC2\ETX=\b\SO\n\
    \\f\n\
    \\ENQ\EOT\v\STX\STX\SOH\DC2\ETX=\SI!\n\
    \\f\n\
    \\ENQ\EOT\v\STX\STX\ETX\DC2\ETX=$%\n\
    \\n\
    \\n\
    \\STX\EOT\f\DC2\EOT@\NULB\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\f\SOH\DC2\ETX@\b\DC2\n\
    \\v\n\
    \\EOT\EOT\f\STX\NUL\DC2\ETXA\b\ESC\n\
    \\f\n\
    \\ENQ\EOT\f\STX\NUL\ENQ\DC2\ETXA\b\SO\n\
    \\f\n\
    \\ENQ\EOT\f\STX\NUL\SOH\DC2\ETXA\SI\SYN\n\
    \\f\n\
    \\ENQ\EOT\f\STX\NUL\ETX\DC2\ETXA\EM\SUBb\ACKproto3"