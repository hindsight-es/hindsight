{- This file was auto-generated from streams.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, DataKinds, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.Streams (
        Streams(..), AppendReq(), AppendReq'Content(..),
        _AppendReq'Options', _AppendReq'ProposedMessage',
        AppendReq'Options(), AppendReq'Options'ExpectedStreamRevision(..),
        _AppendReq'Options'Revision, _AppendReq'Options'NoStream,
        _AppendReq'Options'Any, _AppendReq'Options'StreamExists,
        AppendReq'ProposedMessage(),
        AppendReq'ProposedMessage'MetadataEntry(), AppendResp(),
        AppendResp'Result(..), _AppendResp'Success',
        _AppendResp'WrongExpectedVersion', AppendResp'Position(),
        AppendResp'Success(), AppendResp'Success'CurrentRevisionOption(..),
        AppendResp'Success'PositionOption(..),
        _AppendResp'Success'CurrentRevision, _AppendResp'Success'NoStream,
        _AppendResp'Success'Position, _AppendResp'Success'NoPosition,
        AppendResp'WrongExpectedVersion(),
        AppendResp'WrongExpectedVersion'CurrentRevisionOption2060(..),
        AppendResp'WrongExpectedVersion'ExpectedRevisionOption2060(..),
        AppendResp'WrongExpectedVersion'CurrentRevisionOption(..),
        AppendResp'WrongExpectedVersion'ExpectedRevisionOption(..),
        _AppendResp'WrongExpectedVersion'CurrentRevision2060,
        _AppendResp'WrongExpectedVersion'NoStream2060,
        _AppendResp'WrongExpectedVersion'ExpectedRevision2060,
        _AppendResp'WrongExpectedVersion'Any2060,
        _AppendResp'WrongExpectedVersion'StreamExists2060,
        _AppendResp'WrongExpectedVersion'CurrentRevision,
        _AppendResp'WrongExpectedVersion'CurrentNoStream,
        _AppendResp'WrongExpectedVersion'ExpectedRevision,
        _AppendResp'WrongExpectedVersion'ExpectedAny,
        _AppendResp'WrongExpectedVersion'ExpectedStreamExists,
        _AppendResp'WrongExpectedVersion'ExpectedNoStream,
        BatchAppendReq(), BatchAppendReq'Options(),
        BatchAppendReq'Options'ExpectedStreamPosition(..),
        BatchAppendReq'Options'DeadlineOption(..),
        _BatchAppendReq'Options'StreamPosition,
        _BatchAppendReq'Options'NoStream, _BatchAppendReq'Options'Any,
        _BatchAppendReq'Options'StreamExists,
        _BatchAppendReq'Options'Deadline21100,
        _BatchAppendReq'Options'Deadline, BatchAppendReq'ProposedMessage(),
        BatchAppendReq'ProposedMessage'MetadataEntry(), BatchAppendResp(),
        BatchAppendResp'Result(..),
        BatchAppendResp'ExpectedStreamPosition(..), _BatchAppendResp'Error,
        _BatchAppendResp'Success', _BatchAppendResp'StreamPosition,
        _BatchAppendResp'NoStream, _BatchAppendResp'Any,
        _BatchAppendResp'StreamExists, BatchAppendResp'Success(),
        BatchAppendResp'Success'CurrentRevisionOption(..),
        BatchAppendResp'Success'PositionOption(..),
        _BatchAppendResp'Success'CurrentRevision,
        _BatchAppendResp'Success'NoStream,
        _BatchAppendResp'Success'Position,
        _BatchAppendResp'Success'NoPosition, DeleteReq(),
        DeleteReq'Options(), DeleteReq'Options'ExpectedStreamRevision(..),
        _DeleteReq'Options'Revision, _DeleteReq'Options'NoStream,
        _DeleteReq'Options'Any, _DeleteReq'Options'StreamExists,
        DeleteResp(), DeleteResp'PositionOption(..), _DeleteResp'Position',
        _DeleteResp'NoPosition, DeleteResp'Position(), ReadReq(),
        ReadReq'Options(), ReadReq'Options'StreamOption(..),
        ReadReq'Options'CountOption(..), ReadReq'Options'FilterOption(..),
        _ReadReq'Options'Stream, _ReadReq'Options'All,
        _ReadReq'Options'Count, _ReadReq'Options'Subscription,
        _ReadReq'Options'Filter, _ReadReq'Options'NoFilter,
        ReadReq'Options'AllOptions(),
        ReadReq'Options'AllOptions'AllOption(..),
        _ReadReq'Options'AllOptions'Position,
        _ReadReq'Options'AllOptions'Start, _ReadReq'Options'AllOptions'End,
        ReadReq'Options'ControlOption(), ReadReq'Options'FilterOptions(),
        ReadReq'Options'FilterOptions'Filter(..),
        ReadReq'Options'FilterOptions'Window(..),
        _ReadReq'Options'FilterOptions'StreamIdentifier,
        _ReadReq'Options'FilterOptions'EventType,
        _ReadReq'Options'FilterOptions'Max,
        _ReadReq'Options'FilterOptions'Count,
        ReadReq'Options'FilterOptions'Expression(),
        ReadReq'Options'Position(), ReadReq'Options'ReadDirection(..),
        ReadReq'Options'ReadDirection(),
        ReadReq'Options'ReadDirection'UnrecognizedValue,
        ReadReq'Options'StreamOptions(),
        ReadReq'Options'StreamOptions'RevisionOption(..),
        _ReadReq'Options'StreamOptions'Revision,
        _ReadReq'Options'StreamOptions'Start,
        _ReadReq'Options'StreamOptions'End,
        ReadReq'Options'SubscriptionOptions(),
        ReadReq'Options'UUIDOption(),
        ReadReq'Options'UUIDOption'Content(..),
        _ReadReq'Options'UUIDOption'Structured,
        _ReadReq'Options'UUIDOption'String, ReadResp(),
        ReadResp'Content(..), _ReadResp'Event, _ReadResp'Confirmation,
        _ReadResp'Checkpoint', _ReadResp'StreamNotFound',
        _ReadResp'FirstStreamPosition, _ReadResp'LastStreamPosition,
        _ReadResp'LastAllStreamPosition, _ReadResp'CaughtUp',
        _ReadResp'FellBehind', ReadResp'CaughtUp(), ReadResp'Checkpoint(),
        ReadResp'FellBehind(), ReadResp'Position(), ReadResp'ReadEvent(),
        ReadResp'ReadEvent'Position(..),
        _ReadResp'ReadEvent'CommitPosition, _ReadResp'ReadEvent'NoPosition,
        ReadResp'ReadEvent'RecordedEvent(),
        ReadResp'ReadEvent'RecordedEvent'MetadataEntry(),
        ReadResp'StreamNotFound(), ReadResp'SubscriptionConfirmation(),
        TombstoneReq(), TombstoneReq'Options(),
        TombstoneReq'Options'ExpectedStreamRevision(..),
        _TombstoneReq'Options'Revision, _TombstoneReq'Options'NoStream,
        _TombstoneReq'Options'Any, _TombstoneReq'Options'StreamExists,
        TombstoneResp(), TombstoneResp'PositionOption(..),
        _TombstoneResp'Position', _TombstoneResp'NoPosition,
        TombstoneResp'Position()
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
import qualified Proto.Google.Protobuf.Duration
import qualified Proto.Google.Protobuf.Empty
import qualified Proto.Google.Protobuf.Timestamp
import qualified Proto.Shared
import qualified Proto.Status
{- | Fields :
     
         * 'Proto.Streams_Fields.maybe'content' @:: Lens' AppendReq (Prelude.Maybe AppendReq'Content)@
         * 'Proto.Streams_Fields.maybe'options' @:: Lens' AppendReq (Prelude.Maybe AppendReq'Options)@
         * 'Proto.Streams_Fields.options' @:: Lens' AppendReq AppendReq'Options@
         * 'Proto.Streams_Fields.maybe'proposedMessage' @:: Lens' AppendReq (Prelude.Maybe AppendReq'ProposedMessage)@
         * 'Proto.Streams_Fields.proposedMessage' @:: Lens' AppendReq AppendReq'ProposedMessage@ -}
data AppendReq
  = AppendReq'_constructor {_AppendReq'content :: !(Prelude.Maybe AppendReq'Content),
                            _AppendReq'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show AppendReq where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data AppendReq'Content
  = AppendReq'Options' !AppendReq'Options |
    AppendReq'ProposedMessage' !AppendReq'ProposedMessage
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField AppendReq "maybe'content" (Prelude.Maybe AppendReq'Content) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendReq'content (\ x__ y__ -> x__ {_AppendReq'content = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AppendReq "maybe'options" (Prelude.Maybe AppendReq'Options) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendReq'content (\ x__ y__ -> x__ {_AppendReq'content = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (AppendReq'Options' x__val)) -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap AppendReq'Options' y__))
instance Data.ProtoLens.Field.HasField AppendReq "options" AppendReq'Options where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendReq'content (\ x__ y__ -> x__ {_AppendReq'content = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (AppendReq'Options' x__val)) -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap AppendReq'Options' y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField AppendReq "maybe'proposedMessage" (Prelude.Maybe AppendReq'ProposedMessage) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendReq'content (\ x__ y__ -> x__ {_AppendReq'content = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (AppendReq'ProposedMessage' x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap AppendReq'ProposedMessage' y__))
instance Data.ProtoLens.Field.HasField AppendReq "proposedMessage" AppendReq'ProposedMessage where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendReq'content (\ x__ y__ -> x__ {_AppendReq'content = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (AppendReq'ProposedMessage' x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap AppendReq'ProposedMessage' y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message AppendReq where
  messageName _
    = Data.Text.pack "event_store.client.streams.AppendReq"
  packedMessageDescriptor _
    = "\n\
      \\tAppendReq\DC2I\n\
      \\aoptions\CAN\SOH \SOH(\v2-.event_store.client.streams.AppendReq.OptionsH\NULR\aoptions\DC2b\n\
      \\DLEproposed_message\CAN\STX \SOH(\v25.event_store.client.streams.AppendReq.ProposedMessageH\NULR\SIproposedMessage\SUB\193\STX\n\
      \\aOptions\DC2Q\n\
      \\DC1stream_identifier\CAN\SOH \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier\DC2\FS\n\
      \\brevision\CAN\STX \SOH(\EOTH\NULR\brevision\DC28\n\
      \\tno_stream\CAN\ETX \SOH(\v2\EM.event_store.client.EmptyH\NULR\bnoStream\DC2-\n\
      \\ETXany\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\NULR\ETXany\DC2@\n\
      \\rstream_exists\CAN\ENQ \SOH(\v2\EM.event_store.client.EmptyH\NULR\fstreamExistsB\SUB\n\
      \\CANexpected_stream_revision\SUB\150\STX\n\
      \\SIProposedMessage\DC2(\n\
      \\STXid\CAN\SOH \SOH(\v2\CAN.event_store.client.UUIDR\STXid\DC2_\n\
      \\bmetadata\CAN\STX \ETX(\v2C.event_store.client.streams.AppendReq.ProposedMessage.MetadataEntryR\bmetadata\DC2'\n\
      \\SIcustom_metadata\CAN\ETX \SOH(\fR\SOcustomMetadata\DC2\DC2\n\
      \\EOTdata\CAN\EOT \SOH(\fR\EOTdata\SUB;\n\
      \\rMetadataEntry\DC2\DLE\n\
      \\ETXkey\CAN\SOH \SOH(\tR\ETXkey\DC2\DC4\n\
      \\ENQvalue\CAN\STX \SOH(\tR\ENQvalue:\STX8\SOHB\t\n\
      \\acontent"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        options__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "options"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor AppendReq'Options)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'options")) ::
              Data.ProtoLens.FieldDescriptor AppendReq
        proposedMessage__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "proposed_message"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor AppendReq'ProposedMessage)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'proposedMessage")) ::
              Data.ProtoLens.FieldDescriptor AppendReq
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, options__field_descriptor),
           (Data.ProtoLens.Tag 2, proposedMessage__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _AppendReq'_unknownFields
        (\ x__ y__ -> x__ {_AppendReq'_unknownFields = y__})
  defMessage
    = AppendReq'_constructor
        {_AppendReq'content = Prelude.Nothing,
         _AppendReq'_unknownFields = []}
  parseMessage
    = let
        loop :: AppendReq -> Data.ProtoLens.Encoding.Bytes.Parser AppendReq
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
                                       "options"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"options") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "proposed_message"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"proposedMessage") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "AppendReq"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'content") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just (AppendReq'Options' v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage v)
                (Prelude.Just (AppendReq'ProposedMessage' v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData AppendReq where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_AppendReq'_unknownFields x__)
             (Control.DeepSeq.deepseq (_AppendReq'content x__) ())
instance Control.DeepSeq.NFData AppendReq'Content where
  rnf (AppendReq'Options' x__) = Control.DeepSeq.rnf x__
  rnf (AppendReq'ProposedMessage' x__) = Control.DeepSeq.rnf x__
_AppendReq'Options' ::
  Data.ProtoLens.Prism.Prism' AppendReq'Content AppendReq'Options
_AppendReq'Options'
  = Data.ProtoLens.Prism.prism'
      AppendReq'Options'
      (\ p__
         -> case p__ of
              (AppendReq'Options' p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_AppendReq'ProposedMessage' ::
  Data.ProtoLens.Prism.Prism' AppendReq'Content AppendReq'ProposedMessage
_AppendReq'ProposedMessage'
  = Data.ProtoLens.Prism.prism'
      AppendReq'ProposedMessage'
      (\ p__
         -> case p__ of
              (AppendReq'ProposedMessage' p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.Streams_Fields.streamIdentifier' @:: Lens' AppendReq'Options Proto.Shared.StreamIdentifier@
         * 'Proto.Streams_Fields.maybe'streamIdentifier' @:: Lens' AppendReq'Options (Prelude.Maybe Proto.Shared.StreamIdentifier)@
         * 'Proto.Streams_Fields.maybe'expectedStreamRevision' @:: Lens' AppendReq'Options (Prelude.Maybe AppendReq'Options'ExpectedStreamRevision)@
         * 'Proto.Streams_Fields.maybe'revision' @:: Lens' AppendReq'Options (Prelude.Maybe Data.Word.Word64)@
         * 'Proto.Streams_Fields.revision' @:: Lens' AppendReq'Options Data.Word.Word64@
         * 'Proto.Streams_Fields.maybe'noStream' @:: Lens' AppendReq'Options (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.noStream' @:: Lens' AppendReq'Options Proto.Shared.Empty@
         * 'Proto.Streams_Fields.maybe'any' @:: Lens' AppendReq'Options (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.any' @:: Lens' AppendReq'Options Proto.Shared.Empty@
         * 'Proto.Streams_Fields.maybe'streamExists' @:: Lens' AppendReq'Options (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.streamExists' @:: Lens' AppendReq'Options Proto.Shared.Empty@ -}
data AppendReq'Options
  = AppendReq'Options'_constructor {_AppendReq'Options'streamIdentifier :: !(Prelude.Maybe Proto.Shared.StreamIdentifier),
                                    _AppendReq'Options'expectedStreamRevision :: !(Prelude.Maybe AppendReq'Options'ExpectedStreamRevision),
                                    _AppendReq'Options'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show AppendReq'Options where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data AppendReq'Options'ExpectedStreamRevision
  = AppendReq'Options'Revision !Data.Word.Word64 |
    AppendReq'Options'NoStream !Proto.Shared.Empty |
    AppendReq'Options'Any !Proto.Shared.Empty |
    AppendReq'Options'StreamExists !Proto.Shared.Empty
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField AppendReq'Options "streamIdentifier" Proto.Shared.StreamIdentifier where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendReq'Options'streamIdentifier
           (\ x__ y__ -> x__ {_AppendReq'Options'streamIdentifier = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField AppendReq'Options "maybe'streamIdentifier" (Prelude.Maybe Proto.Shared.StreamIdentifier) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendReq'Options'streamIdentifier
           (\ x__ y__ -> x__ {_AppendReq'Options'streamIdentifier = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AppendReq'Options "maybe'expectedStreamRevision" (Prelude.Maybe AppendReq'Options'ExpectedStreamRevision) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_AppendReq'Options'expectedStreamRevision = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AppendReq'Options "maybe'revision" (Prelude.Maybe Data.Word.Word64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_AppendReq'Options'expectedStreamRevision = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (AppendReq'Options'Revision x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap AppendReq'Options'Revision y__))
instance Data.ProtoLens.Field.HasField AppendReq'Options "revision" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_AppendReq'Options'expectedStreamRevision = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (AppendReq'Options'Revision x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap AppendReq'Options'Revision y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Field.HasField AppendReq'Options "maybe'noStream" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_AppendReq'Options'expectedStreamRevision = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (AppendReq'Options'NoStream x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap AppendReq'Options'NoStream y__))
instance Data.ProtoLens.Field.HasField AppendReq'Options "noStream" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_AppendReq'Options'expectedStreamRevision = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (AppendReq'Options'NoStream x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap AppendReq'Options'NoStream y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField AppendReq'Options "maybe'any" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_AppendReq'Options'expectedStreamRevision = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (AppendReq'Options'Any x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap AppendReq'Options'Any y__))
instance Data.ProtoLens.Field.HasField AppendReq'Options "any" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_AppendReq'Options'expectedStreamRevision = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (AppendReq'Options'Any x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap AppendReq'Options'Any y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField AppendReq'Options "maybe'streamExists" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_AppendReq'Options'expectedStreamRevision = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (AppendReq'Options'StreamExists x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap AppendReq'Options'StreamExists y__))
instance Data.ProtoLens.Field.HasField AppendReq'Options "streamExists" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_AppendReq'Options'expectedStreamRevision = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (AppendReq'Options'StreamExists x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap AppendReq'Options'StreamExists y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message AppendReq'Options where
  messageName _
    = Data.Text.pack "event_store.client.streams.AppendReq.Options"
  packedMessageDescriptor _
    = "\n\
      \\aOptions\DC2Q\n\
      \\DC1stream_identifier\CAN\SOH \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier\DC2\FS\n\
      \\brevision\CAN\STX \SOH(\EOTH\NULR\brevision\DC28\n\
      \\tno_stream\CAN\ETX \SOH(\v2\EM.event_store.client.EmptyH\NULR\bnoStream\DC2-\n\
      \\ETXany\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\NULR\ETXany\DC2@\n\
      \\rstream_exists\CAN\ENQ \SOH(\v2\EM.event_store.client.EmptyH\NULR\fstreamExistsB\SUB\n\
      \\CANexpected_stream_revision"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        streamIdentifier__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stream_identifier"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.StreamIdentifier)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'streamIdentifier")) ::
              Data.ProtoLens.FieldDescriptor AppendReq'Options
        revision__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "revision"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'revision")) ::
              Data.ProtoLens.FieldDescriptor AppendReq'Options
        noStream__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "no_stream"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'noStream")) ::
              Data.ProtoLens.FieldDescriptor AppendReq'Options
        any__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "any"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'any")) ::
              Data.ProtoLens.FieldDescriptor AppendReq'Options
        streamExists__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stream_exists"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'streamExists")) ::
              Data.ProtoLens.FieldDescriptor AppendReq'Options
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, streamIdentifier__field_descriptor),
           (Data.ProtoLens.Tag 2, revision__field_descriptor),
           (Data.ProtoLens.Tag 3, noStream__field_descriptor),
           (Data.ProtoLens.Tag 4, any__field_descriptor),
           (Data.ProtoLens.Tag 5, streamExists__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _AppendReq'Options'_unknownFields
        (\ x__ y__ -> x__ {_AppendReq'Options'_unknownFields = y__})
  defMessage
    = AppendReq'Options'_constructor
        {_AppendReq'Options'streamIdentifier = Prelude.Nothing,
         _AppendReq'Options'expectedStreamRevision = Prelude.Nothing,
         _AppendReq'Options'_unknownFields = []}
  parseMessage
    = let
        loop ::
          AppendReq'Options
          -> Data.ProtoLens.Encoding.Bytes.Parser AppendReq'Options
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
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "revision"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"revision") y x)
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "no_stream"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"noStream") y x)
                        34
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "any"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"any") y x)
                        42
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "stream_exists"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"streamExists") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Options"
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
             ((Data.Monoid.<>)
                (case
                     Lens.Family2.view
                       (Data.ProtoLens.Field.field @"maybe'expectedStreamRevision") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just (AppendReq'Options'Revision v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt v)
                   (Prelude.Just (AppendReq'Options'NoStream v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage v)
                   (Prelude.Just (AppendReq'Options'Any v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 34)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage v)
                   (Prelude.Just (AppendReq'Options'StreamExists v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 42)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData AppendReq'Options where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_AppendReq'Options'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_AppendReq'Options'streamIdentifier x__)
                (Control.DeepSeq.deepseq
                   (_AppendReq'Options'expectedStreamRevision x__) ()))
instance Control.DeepSeq.NFData AppendReq'Options'ExpectedStreamRevision where
  rnf (AppendReq'Options'Revision x__) = Control.DeepSeq.rnf x__
  rnf (AppendReq'Options'NoStream x__) = Control.DeepSeq.rnf x__
  rnf (AppendReq'Options'Any x__) = Control.DeepSeq.rnf x__
  rnf (AppendReq'Options'StreamExists x__) = Control.DeepSeq.rnf x__
_AppendReq'Options'Revision ::
  Data.ProtoLens.Prism.Prism' AppendReq'Options'ExpectedStreamRevision Data.Word.Word64
_AppendReq'Options'Revision
  = Data.ProtoLens.Prism.prism'
      AppendReq'Options'Revision
      (\ p__
         -> case p__ of
              (AppendReq'Options'Revision p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_AppendReq'Options'NoStream ::
  Data.ProtoLens.Prism.Prism' AppendReq'Options'ExpectedStreamRevision Proto.Shared.Empty
_AppendReq'Options'NoStream
  = Data.ProtoLens.Prism.prism'
      AppendReq'Options'NoStream
      (\ p__
         -> case p__ of
              (AppendReq'Options'NoStream p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_AppendReq'Options'Any ::
  Data.ProtoLens.Prism.Prism' AppendReq'Options'ExpectedStreamRevision Proto.Shared.Empty
_AppendReq'Options'Any
  = Data.ProtoLens.Prism.prism'
      AppendReq'Options'Any
      (\ p__
         -> case p__ of
              (AppendReq'Options'Any p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_AppendReq'Options'StreamExists ::
  Data.ProtoLens.Prism.Prism' AppendReq'Options'ExpectedStreamRevision Proto.Shared.Empty
_AppendReq'Options'StreamExists
  = Data.ProtoLens.Prism.prism'
      AppendReq'Options'StreamExists
      (\ p__
         -> case p__ of
              (AppendReq'Options'StreamExists p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.Streams_Fields.id' @:: Lens' AppendReq'ProposedMessage Proto.Shared.UUID@
         * 'Proto.Streams_Fields.maybe'id' @:: Lens' AppendReq'ProposedMessage (Prelude.Maybe Proto.Shared.UUID)@
         * 'Proto.Streams_Fields.metadata' @:: Lens' AppendReq'ProposedMessage (Data.Map.Map Data.Text.Text Data.Text.Text)@
         * 'Proto.Streams_Fields.customMetadata' @:: Lens' AppendReq'ProposedMessage Data.ByteString.ByteString@
         * 'Proto.Streams_Fields.data'' @:: Lens' AppendReq'ProposedMessage Data.ByteString.ByteString@ -}
data AppendReq'ProposedMessage
  = AppendReq'ProposedMessage'_constructor {_AppendReq'ProposedMessage'id :: !(Prelude.Maybe Proto.Shared.UUID),
                                            _AppendReq'ProposedMessage'metadata :: !(Data.Map.Map Data.Text.Text Data.Text.Text),
                                            _AppendReq'ProposedMessage'customMetadata :: !Data.ByteString.ByteString,
                                            _AppendReq'ProposedMessage'data' :: !Data.ByteString.ByteString,
                                            _AppendReq'ProposedMessage'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show AppendReq'ProposedMessage where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField AppendReq'ProposedMessage "id" Proto.Shared.UUID where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendReq'ProposedMessage'id
           (\ x__ y__ -> x__ {_AppendReq'ProposedMessage'id = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField AppendReq'ProposedMessage "maybe'id" (Prelude.Maybe Proto.Shared.UUID) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendReq'ProposedMessage'id
           (\ x__ y__ -> x__ {_AppendReq'ProposedMessage'id = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AppendReq'ProposedMessage "metadata" (Data.Map.Map Data.Text.Text Data.Text.Text) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendReq'ProposedMessage'metadata
           (\ x__ y__ -> x__ {_AppendReq'ProposedMessage'metadata = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AppendReq'ProposedMessage "customMetadata" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendReq'ProposedMessage'customMetadata
           (\ x__ y__
              -> x__ {_AppendReq'ProposedMessage'customMetadata = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AppendReq'ProposedMessage "data'" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendReq'ProposedMessage'data'
           (\ x__ y__ -> x__ {_AppendReq'ProposedMessage'data' = y__}))
        Prelude.id
instance Data.ProtoLens.Message AppendReq'ProposedMessage where
  messageName _
    = Data.Text.pack
        "event_store.client.streams.AppendReq.ProposedMessage"
  packedMessageDescriptor _
    = "\n\
      \\SIProposedMessage\DC2(\n\
      \\STXid\CAN\SOH \SOH(\v2\CAN.event_store.client.UUIDR\STXid\DC2_\n\
      \\bmetadata\CAN\STX \ETX(\v2C.event_store.client.streams.AppendReq.ProposedMessage.MetadataEntryR\bmetadata\DC2'\n\
      \\SIcustom_metadata\CAN\ETX \SOH(\fR\SOcustomMetadata\DC2\DC2\n\
      \\EOTdata\CAN\EOT \SOH(\fR\EOTdata\SUB;\n\
      \\rMetadataEntry\DC2\DLE\n\
      \\ETXkey\CAN\SOH \SOH(\tR\ETXkey\DC2\DC4\n\
      \\ENQvalue\CAN\STX \SOH(\tR\ENQvalue:\STX8\SOH"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        id__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "id"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.UUID)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'id")) ::
              Data.ProtoLens.FieldDescriptor AppendReq'ProposedMessage
        metadata__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "metadata"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor AppendReq'ProposedMessage'MetadataEntry)
              (Data.ProtoLens.MapField
                 (Data.ProtoLens.Field.field @"key")
                 (Data.ProtoLens.Field.field @"value")
                 (Data.ProtoLens.Field.field @"metadata")) ::
              Data.ProtoLens.FieldDescriptor AppendReq'ProposedMessage
        customMetadata__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "custom_metadata"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"customMetadata")) ::
              Data.ProtoLens.FieldDescriptor AppendReq'ProposedMessage
        data'__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "data"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"data'")) ::
              Data.ProtoLens.FieldDescriptor AppendReq'ProposedMessage
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, id__field_descriptor),
           (Data.ProtoLens.Tag 2, metadata__field_descriptor),
           (Data.ProtoLens.Tag 3, customMetadata__field_descriptor),
           (Data.ProtoLens.Tag 4, data'__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _AppendReq'ProposedMessage'_unknownFields
        (\ x__ y__
           -> x__ {_AppendReq'ProposedMessage'_unknownFields = y__})
  defMessage
    = AppendReq'ProposedMessage'_constructor
        {_AppendReq'ProposedMessage'id = Prelude.Nothing,
         _AppendReq'ProposedMessage'metadata = Data.Map.empty,
         _AppendReq'ProposedMessage'customMetadata = Data.ProtoLens.fieldDefault,
         _AppendReq'ProposedMessage'data' = Data.ProtoLens.fieldDefault,
         _AppendReq'ProposedMessage'_unknownFields = []}
  parseMessage
    = let
        loop ::
          AppendReq'ProposedMessage
          -> Data.ProtoLens.Encoding.Bytes.Parser AppendReq'ProposedMessage
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
                                       "id"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"id") y x)
                        18
                          -> do !(entry :: AppendReq'ProposedMessage'MetadataEntry) <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                                                                         (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                                                                             Data.ProtoLens.Encoding.Bytes.isolate
                                                                                               (Prelude.fromIntegral
                                                                                                  len)
                                                                                               Data.ProtoLens.parseMessage)
                                                                                         "metadata"
                                (let
                                   key = Lens.Family2.view (Data.ProtoLens.Field.field @"key") entry
                                   value
                                     = Lens.Family2.view (Data.ProtoLens.Field.field @"value") entry
                                 in
                                   loop
                                     (Lens.Family2.over
                                        (Data.ProtoLens.Field.field @"metadata")
                                        (\ !t -> Data.Map.insert key value t) x))
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "custom_metadata"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"customMetadata") y x)
                        34
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "data"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"data'") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "ProposedMessage"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'id") _x
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
             ((Data.Monoid.<>)
                (Data.Monoid.mconcat
                   (Prelude.map
                      (\ _v
                         -> (Data.Monoid.<>)
                              (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                              ((Prelude..)
                                 (\ bs
                                    -> (Data.Monoid.<>)
                                         (Data.ProtoLens.Encoding.Bytes.putVarInt
                                            (Prelude.fromIntegral (Data.ByteString.length bs)))
                                         (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                 Data.ProtoLens.encodeMessage
                                 (Lens.Family2.set
                                    (Data.ProtoLens.Field.field @"key") (Prelude.fst _v)
                                    (Lens.Family2.set
                                       (Data.ProtoLens.Field.field @"value") (Prelude.snd _v)
                                       (Data.ProtoLens.defMessage ::
                                          AppendReq'ProposedMessage'MetadataEntry)))))
                      (Data.Map.toList
                         (Lens.Family2.view (Data.ProtoLens.Field.field @"metadata") _x))))
                ((Data.Monoid.<>)
                   (let
                      _v
                        = Lens.Family2.view
                            (Data.ProtoLens.Field.field @"customMetadata") _x
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
                   ((Data.Monoid.<>)
                      (let
                         _v = Lens.Family2.view (Data.ProtoLens.Field.field @"data'") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 34)
                               ((\ bs
                                   -> (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt
                                           (Prelude.fromIntegral (Data.ByteString.length bs)))
                                        (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                  _v))
                      (Data.ProtoLens.Encoding.Wire.buildFieldSet
                         (Lens.Family2.view Data.ProtoLens.unknownFields _x)))))
instance Control.DeepSeq.NFData AppendReq'ProposedMessage where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_AppendReq'ProposedMessage'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_AppendReq'ProposedMessage'id x__)
                (Control.DeepSeq.deepseq
                   (_AppendReq'ProposedMessage'metadata x__)
                   (Control.DeepSeq.deepseq
                      (_AppendReq'ProposedMessage'customMetadata x__)
                      (Control.DeepSeq.deepseq
                         (_AppendReq'ProposedMessage'data' x__) ()))))
{- | Fields :
     
         * 'Proto.Streams_Fields.key' @:: Lens' AppendReq'ProposedMessage'MetadataEntry Data.Text.Text@
         * 'Proto.Streams_Fields.value' @:: Lens' AppendReq'ProposedMessage'MetadataEntry Data.Text.Text@ -}
data AppendReq'ProposedMessage'MetadataEntry
  = AppendReq'ProposedMessage'MetadataEntry'_constructor {_AppendReq'ProposedMessage'MetadataEntry'key :: !Data.Text.Text,
                                                          _AppendReq'ProposedMessage'MetadataEntry'value :: !Data.Text.Text,
                                                          _AppendReq'ProposedMessage'MetadataEntry'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show AppendReq'ProposedMessage'MetadataEntry where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField AppendReq'ProposedMessage'MetadataEntry "key" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendReq'ProposedMessage'MetadataEntry'key
           (\ x__ y__
              -> x__ {_AppendReq'ProposedMessage'MetadataEntry'key = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AppendReq'ProposedMessage'MetadataEntry "value" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendReq'ProposedMessage'MetadataEntry'value
           (\ x__ y__
              -> x__ {_AppendReq'ProposedMessage'MetadataEntry'value = y__}))
        Prelude.id
instance Data.ProtoLens.Message AppendReq'ProposedMessage'MetadataEntry where
  messageName _
    = Data.Text.pack
        "event_store.client.streams.AppendReq.ProposedMessage.MetadataEntry"
  packedMessageDescriptor _
    = "\n\
      \\rMetadataEntry\DC2\DLE\n\
      \\ETXkey\CAN\SOH \SOH(\tR\ETXkey\DC2\DC4\n\
      \\ENQvalue\CAN\STX \SOH(\tR\ENQvalue:\STX8\SOH"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        key__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "key"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"key")) ::
              Data.ProtoLens.FieldDescriptor AppendReq'ProposedMessage'MetadataEntry
        value__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "value"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"value")) ::
              Data.ProtoLens.FieldDescriptor AppendReq'ProposedMessage'MetadataEntry
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, key__field_descriptor),
           (Data.ProtoLens.Tag 2, value__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _AppendReq'ProposedMessage'MetadataEntry'_unknownFields
        (\ x__ y__
           -> x__
                {_AppendReq'ProposedMessage'MetadataEntry'_unknownFields = y__})
  defMessage
    = AppendReq'ProposedMessage'MetadataEntry'_constructor
        {_AppendReq'ProposedMessage'MetadataEntry'key = Data.ProtoLens.fieldDefault,
         _AppendReq'ProposedMessage'MetadataEntry'value = Data.ProtoLens.fieldDefault,
         _AppendReq'ProposedMessage'MetadataEntry'_unknownFields = []}
  parseMessage
    = let
        loop ::
          AppendReq'ProposedMessage'MetadataEntry
          -> Data.ProtoLens.Encoding.Bytes.Parser AppendReq'ProposedMessage'MetadataEntry
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
                                       "key"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"key") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getText
                                             (Prelude.fromIntegral len))
                                       "value"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"value") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "MetadataEntry"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"key") _x
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
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"value") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                         ((Prelude..)
                            (\ bs
                               -> (Data.Monoid.<>)
                                    (Data.ProtoLens.Encoding.Bytes.putVarInt
                                       (Prelude.fromIntegral (Data.ByteString.length bs)))
                                    (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                            Data.Text.Encoding.encodeUtf8 _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData AppendReq'ProposedMessage'MetadataEntry where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_AppendReq'ProposedMessage'MetadataEntry'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_AppendReq'ProposedMessage'MetadataEntry'key x__)
                (Control.DeepSeq.deepseq
                   (_AppendReq'ProposedMessage'MetadataEntry'value x__) ()))
{- | Fields :
     
         * 'Proto.Streams_Fields.maybe'result' @:: Lens' AppendResp (Prelude.Maybe AppendResp'Result)@
         * 'Proto.Streams_Fields.maybe'success' @:: Lens' AppendResp (Prelude.Maybe AppendResp'Success)@
         * 'Proto.Streams_Fields.success' @:: Lens' AppendResp AppendResp'Success@
         * 'Proto.Streams_Fields.maybe'wrongExpectedVersion' @:: Lens' AppendResp (Prelude.Maybe AppendResp'WrongExpectedVersion)@
         * 'Proto.Streams_Fields.wrongExpectedVersion' @:: Lens' AppendResp AppendResp'WrongExpectedVersion@ -}
data AppendResp
  = AppendResp'_constructor {_AppendResp'result :: !(Prelude.Maybe AppendResp'Result),
                             _AppendResp'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show AppendResp where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data AppendResp'Result
  = AppendResp'Success' !AppendResp'Success |
    AppendResp'WrongExpectedVersion' !AppendResp'WrongExpectedVersion
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField AppendResp "maybe'result" (Prelude.Maybe AppendResp'Result) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'result (\ x__ y__ -> x__ {_AppendResp'result = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AppendResp "maybe'success" (Prelude.Maybe AppendResp'Success) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'result (\ x__ y__ -> x__ {_AppendResp'result = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (AppendResp'Success' x__val)) -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap AppendResp'Success' y__))
instance Data.ProtoLens.Field.HasField AppendResp "success" AppendResp'Success where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'result (\ x__ y__ -> x__ {_AppendResp'result = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (AppendResp'Success' x__val)) -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap AppendResp'Success' y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField AppendResp "maybe'wrongExpectedVersion" (Prelude.Maybe AppendResp'WrongExpectedVersion) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'result (\ x__ y__ -> x__ {_AppendResp'result = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (AppendResp'WrongExpectedVersion' x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap AppendResp'WrongExpectedVersion' y__))
instance Data.ProtoLens.Field.HasField AppendResp "wrongExpectedVersion" AppendResp'WrongExpectedVersion where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'result (\ x__ y__ -> x__ {_AppendResp'result = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (AppendResp'WrongExpectedVersion' x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap AppendResp'WrongExpectedVersion' y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message AppendResp where
  messageName _
    = Data.Text.pack "event_store.client.streams.AppendResp"
  packedMessageDescriptor _
    = "\n\
      \\n\
      \AppendResp\DC2J\n\
      \\asuccess\CAN\SOH \SOH(\v2..event_store.client.streams.AppendResp.SuccessH\NULR\asuccess\DC2s\n\
      \\SYNwrong_expected_version\CAN\STX \SOH(\v2;.event_store.client.streams.AppendResp.WrongExpectedVersionH\NULR\DC4wrongExpectedVersion\SUB^\n\
      \\bPosition\DC2'\n\
      \\SIcommit_position\CAN\SOH \SOH(\EOTR\SOcommitPosition\DC2)\n\
      \\DLEprepare_position\CAN\STX \SOH(\EOTR\SIpreparePosition\SUB\171\STX\n\
      \\aSuccess\DC2+\n\
      \\DLEcurrent_revision\CAN\SOH \SOH(\EOTH\NULR\SIcurrentRevision\DC28\n\
      \\tno_stream\CAN\STX \SOH(\v2\EM.event_store.client.EmptyH\NULR\bnoStream\DC2M\n\
      \\bposition\CAN\ETX \SOH(\v2/.event_store.client.streams.AppendResp.PositionH\SOHR\bposition\DC2<\n\
      \\vno_position\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\SOHR\n\
      \noPositionB\EM\n\
      \\ETBcurrent_revision_optionB\DC1\n\
      \\SIposition_option\SUB\211\ACK\n\
      \\DC4WrongExpectedVersion\DC26\n\
      \\ETBcurrent_revision_20_6_0\CAN\SOH \SOH(\EOTH\NULR\DC3currentRevision2060\DC2C\n\
      \\DLEno_stream_20_6_0\CAN\STX \SOH(\v2\EM.event_store.client.EmptyH\NULR\fnoStream2060\DC28\n\
      \\CANexpected_revision_20_6_0\CAN\ETX \SOH(\EOTH\SOHR\DC4expectedRevision2060\DC28\n\
      \\n\
      \any_20_6_0\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\SOHR\aany2060\DC2K\n\
      \\DC4stream_exists_20_6_0\CAN\ENQ \SOH(\v2\EM.event_store.client.EmptyH\SOHR\DLEstreamExists2060\DC2+\n\
      \\DLEcurrent_revision\CAN\ACK \SOH(\EOTH\STXR\SIcurrentRevision\DC2G\n\
      \\DC1current_no_stream\CAN\a \SOH(\v2\EM.event_store.client.EmptyH\STXR\SIcurrentNoStream\DC2-\n\
      \\DC1expected_revision\CAN\b \SOH(\EOTH\ETXR\DLEexpectedRevision\DC2>\n\
      \\fexpected_any\CAN\t \SOH(\v2\EM.event_store.client.EmptyH\ETXR\vexpectedAny\DC2Q\n\
      \\SYNexpected_stream_exists\CAN\n\
      \ \SOH(\v2\EM.event_store.client.EmptyH\ETXR\DC4expectedStreamExists\DC2I\n\
      \\DC2expected_no_stream\CAN\v \SOH(\v2\EM.event_store.client.EmptyH\ETXR\DLEexpectedNoStreamB \n\
      \\RScurrent_revision_option_20_6_0B!\n\
      \\USexpected_revision_option_20_6_0B\EM\n\
      \\ETBcurrent_revision_optionB\SUB\n\
      \\CANexpected_revision_optionB\b\n\
      \\ACKresult"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        success__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "success"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor AppendResp'Success)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'success")) ::
              Data.ProtoLens.FieldDescriptor AppendResp
        wrongExpectedVersion__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "wrong_expected_version"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor AppendResp'WrongExpectedVersion)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'wrongExpectedVersion")) ::
              Data.ProtoLens.FieldDescriptor AppendResp
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, success__field_descriptor),
           (Data.ProtoLens.Tag 2, wrongExpectedVersion__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _AppendResp'_unknownFields
        (\ x__ y__ -> x__ {_AppendResp'_unknownFields = y__})
  defMessage
    = AppendResp'_constructor
        {_AppendResp'result = Prelude.Nothing,
         _AppendResp'_unknownFields = []}
  parseMessage
    = let
        loop ::
          AppendResp -> Data.ProtoLens.Encoding.Bytes.Parser AppendResp
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
                                       "success"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"success") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "wrong_expected_version"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"wrongExpectedVersion") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "AppendResp"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'result") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just (AppendResp'Success' v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage v)
                (Prelude.Just (AppendResp'WrongExpectedVersion' v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData AppendResp where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_AppendResp'_unknownFields x__)
             (Control.DeepSeq.deepseq (_AppendResp'result x__) ())
instance Control.DeepSeq.NFData AppendResp'Result where
  rnf (AppendResp'Success' x__) = Control.DeepSeq.rnf x__
  rnf (AppendResp'WrongExpectedVersion' x__)
    = Control.DeepSeq.rnf x__
_AppendResp'Success' ::
  Data.ProtoLens.Prism.Prism' AppendResp'Result AppendResp'Success
_AppendResp'Success'
  = Data.ProtoLens.Prism.prism'
      AppendResp'Success'
      (\ p__
         -> case p__ of
              (AppendResp'Success' p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_AppendResp'WrongExpectedVersion' ::
  Data.ProtoLens.Prism.Prism' AppendResp'Result AppendResp'WrongExpectedVersion
_AppendResp'WrongExpectedVersion'
  = Data.ProtoLens.Prism.prism'
      AppendResp'WrongExpectedVersion'
      (\ p__
         -> case p__ of
              (AppendResp'WrongExpectedVersion' p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.Streams_Fields.commitPosition' @:: Lens' AppendResp'Position Data.Word.Word64@
         * 'Proto.Streams_Fields.preparePosition' @:: Lens' AppendResp'Position Data.Word.Word64@ -}
data AppendResp'Position
  = AppendResp'Position'_constructor {_AppendResp'Position'commitPosition :: !Data.Word.Word64,
                                      _AppendResp'Position'preparePosition :: !Data.Word.Word64,
                                      _AppendResp'Position'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show AppendResp'Position where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField AppendResp'Position "commitPosition" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'Position'commitPosition
           (\ x__ y__ -> x__ {_AppendResp'Position'commitPosition = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AppendResp'Position "preparePosition" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'Position'preparePosition
           (\ x__ y__ -> x__ {_AppendResp'Position'preparePosition = y__}))
        Prelude.id
instance Data.ProtoLens.Message AppendResp'Position where
  messageName _
    = Data.Text.pack "event_store.client.streams.AppendResp.Position"
  packedMessageDescriptor _
    = "\n\
      \\bPosition\DC2'\n\
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
              Data.ProtoLens.FieldDescriptor AppendResp'Position
        preparePosition__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "prepare_position"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"preparePosition")) ::
              Data.ProtoLens.FieldDescriptor AppendResp'Position
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, commitPosition__field_descriptor),
           (Data.ProtoLens.Tag 2, preparePosition__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _AppendResp'Position'_unknownFields
        (\ x__ y__ -> x__ {_AppendResp'Position'_unknownFields = y__})
  defMessage
    = AppendResp'Position'_constructor
        {_AppendResp'Position'commitPosition = Data.ProtoLens.fieldDefault,
         _AppendResp'Position'preparePosition = Data.ProtoLens.fieldDefault,
         _AppendResp'Position'_unknownFields = []}
  parseMessage
    = let
        loop ::
          AppendResp'Position
          -> Data.ProtoLens.Encoding.Bytes.Parser AppendResp'Position
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
          (do loop Data.ProtoLens.defMessage) "Position"
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
instance Control.DeepSeq.NFData AppendResp'Position where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_AppendResp'Position'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_AppendResp'Position'commitPosition x__)
                (Control.DeepSeq.deepseq
                   (_AppendResp'Position'preparePosition x__) ()))
{- | Fields :
     
         * 'Proto.Streams_Fields.maybe'currentRevisionOption' @:: Lens' AppendResp'Success (Prelude.Maybe AppendResp'Success'CurrentRevisionOption)@
         * 'Proto.Streams_Fields.maybe'currentRevision' @:: Lens' AppendResp'Success (Prelude.Maybe Data.Word.Word64)@
         * 'Proto.Streams_Fields.currentRevision' @:: Lens' AppendResp'Success Data.Word.Word64@
         * 'Proto.Streams_Fields.maybe'noStream' @:: Lens' AppendResp'Success (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.noStream' @:: Lens' AppendResp'Success Proto.Shared.Empty@
         * 'Proto.Streams_Fields.maybe'positionOption' @:: Lens' AppendResp'Success (Prelude.Maybe AppendResp'Success'PositionOption)@
         * 'Proto.Streams_Fields.maybe'position' @:: Lens' AppendResp'Success (Prelude.Maybe AppendResp'Position)@
         * 'Proto.Streams_Fields.position' @:: Lens' AppendResp'Success AppendResp'Position@
         * 'Proto.Streams_Fields.maybe'noPosition' @:: Lens' AppendResp'Success (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.noPosition' @:: Lens' AppendResp'Success Proto.Shared.Empty@ -}
data AppendResp'Success
  = AppendResp'Success'_constructor {_AppendResp'Success'currentRevisionOption :: !(Prelude.Maybe AppendResp'Success'CurrentRevisionOption),
                                     _AppendResp'Success'positionOption :: !(Prelude.Maybe AppendResp'Success'PositionOption),
                                     _AppendResp'Success'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show AppendResp'Success where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data AppendResp'Success'CurrentRevisionOption
  = AppendResp'Success'CurrentRevision !Data.Word.Word64 |
    AppendResp'Success'NoStream !Proto.Shared.Empty
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
data AppendResp'Success'PositionOption
  = AppendResp'Success'Position !AppendResp'Position |
    AppendResp'Success'NoPosition !Proto.Shared.Empty
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField AppendResp'Success "maybe'currentRevisionOption" (Prelude.Maybe AppendResp'Success'CurrentRevisionOption) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'Success'currentRevisionOption
           (\ x__ y__
              -> x__ {_AppendResp'Success'currentRevisionOption = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AppendResp'Success "maybe'currentRevision" (Prelude.Maybe Data.Word.Word64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'Success'currentRevisionOption
           (\ x__ y__
              -> x__ {_AppendResp'Success'currentRevisionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (AppendResp'Success'CurrentRevision x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap AppendResp'Success'CurrentRevision y__))
instance Data.ProtoLens.Field.HasField AppendResp'Success "currentRevision" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'Success'currentRevisionOption
           (\ x__ y__
              -> x__ {_AppendResp'Success'currentRevisionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (AppendResp'Success'CurrentRevision x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap AppendResp'Success'CurrentRevision y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Field.HasField AppendResp'Success "maybe'noStream" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'Success'currentRevisionOption
           (\ x__ y__
              -> x__ {_AppendResp'Success'currentRevisionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (AppendResp'Success'NoStream x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap AppendResp'Success'NoStream y__))
instance Data.ProtoLens.Field.HasField AppendResp'Success "noStream" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'Success'currentRevisionOption
           (\ x__ y__
              -> x__ {_AppendResp'Success'currentRevisionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (AppendResp'Success'NoStream x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap AppendResp'Success'NoStream y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField AppendResp'Success "maybe'positionOption" (Prelude.Maybe AppendResp'Success'PositionOption) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'Success'positionOption
           (\ x__ y__ -> x__ {_AppendResp'Success'positionOption = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AppendResp'Success "maybe'position" (Prelude.Maybe AppendResp'Position) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'Success'positionOption
           (\ x__ y__ -> x__ {_AppendResp'Success'positionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (AppendResp'Success'Position x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap AppendResp'Success'Position y__))
instance Data.ProtoLens.Field.HasField AppendResp'Success "position" AppendResp'Position where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'Success'positionOption
           (\ x__ y__ -> x__ {_AppendResp'Success'positionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (AppendResp'Success'Position x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap AppendResp'Success'Position y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField AppendResp'Success "maybe'noPosition" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'Success'positionOption
           (\ x__ y__ -> x__ {_AppendResp'Success'positionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (AppendResp'Success'NoPosition x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap AppendResp'Success'NoPosition y__))
instance Data.ProtoLens.Field.HasField AppendResp'Success "noPosition" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'Success'positionOption
           (\ x__ y__ -> x__ {_AppendResp'Success'positionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (AppendResp'Success'NoPosition x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap AppendResp'Success'NoPosition y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message AppendResp'Success where
  messageName _
    = Data.Text.pack "event_store.client.streams.AppendResp.Success"
  packedMessageDescriptor _
    = "\n\
      \\aSuccess\DC2+\n\
      \\DLEcurrent_revision\CAN\SOH \SOH(\EOTH\NULR\SIcurrentRevision\DC28\n\
      \\tno_stream\CAN\STX \SOH(\v2\EM.event_store.client.EmptyH\NULR\bnoStream\DC2M\n\
      \\bposition\CAN\ETX \SOH(\v2/.event_store.client.streams.AppendResp.PositionH\SOHR\bposition\DC2<\n\
      \\vno_position\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\SOHR\n\
      \noPositionB\EM\n\
      \\ETBcurrent_revision_optionB\DC1\n\
      \\SIposition_option"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        currentRevision__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "current_revision"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'currentRevision")) ::
              Data.ProtoLens.FieldDescriptor AppendResp'Success
        noStream__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "no_stream"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'noStream")) ::
              Data.ProtoLens.FieldDescriptor AppendResp'Success
        position__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "position"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor AppendResp'Position)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'position")) ::
              Data.ProtoLens.FieldDescriptor AppendResp'Success
        noPosition__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "no_position"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'noPosition")) ::
              Data.ProtoLens.FieldDescriptor AppendResp'Success
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, currentRevision__field_descriptor),
           (Data.ProtoLens.Tag 2, noStream__field_descriptor),
           (Data.ProtoLens.Tag 3, position__field_descriptor),
           (Data.ProtoLens.Tag 4, noPosition__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _AppendResp'Success'_unknownFields
        (\ x__ y__ -> x__ {_AppendResp'Success'_unknownFields = y__})
  defMessage
    = AppendResp'Success'_constructor
        {_AppendResp'Success'currentRevisionOption = Prelude.Nothing,
         _AppendResp'Success'positionOption = Prelude.Nothing,
         _AppendResp'Success'_unknownFields = []}
  parseMessage
    = let
        loop ::
          AppendResp'Success
          -> Data.ProtoLens.Encoding.Bytes.Parser AppendResp'Success
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
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "current_revision"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"currentRevision") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "no_stream"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"noStream") y x)
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "position"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"position") y x)
                        34
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "no_position"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"noPosition") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Success"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view
                    (Data.ProtoLens.Field.field @"maybe'currentRevisionOption") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just (AppendResp'Success'CurrentRevision v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt v)
                (Prelude.Just (AppendResp'Success'NoStream v))
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
                       (Data.ProtoLens.Field.field @"maybe'positionOption") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just (AppendResp'Success'Position v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage v)
                   (Prelude.Just (AppendResp'Success'NoPosition v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 34)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData AppendResp'Success where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_AppendResp'Success'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_AppendResp'Success'currentRevisionOption x__)
                (Control.DeepSeq.deepseq
                   (_AppendResp'Success'positionOption x__) ()))
instance Control.DeepSeq.NFData AppendResp'Success'CurrentRevisionOption where
  rnf (AppendResp'Success'CurrentRevision x__)
    = Control.DeepSeq.rnf x__
  rnf (AppendResp'Success'NoStream x__) = Control.DeepSeq.rnf x__
instance Control.DeepSeq.NFData AppendResp'Success'PositionOption where
  rnf (AppendResp'Success'Position x__) = Control.DeepSeq.rnf x__
  rnf (AppendResp'Success'NoPosition x__) = Control.DeepSeq.rnf x__
_AppendResp'Success'CurrentRevision ::
  Data.ProtoLens.Prism.Prism' AppendResp'Success'CurrentRevisionOption Data.Word.Word64
_AppendResp'Success'CurrentRevision
  = Data.ProtoLens.Prism.prism'
      AppendResp'Success'CurrentRevision
      (\ p__
         -> case p__ of
              (AppendResp'Success'CurrentRevision p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_AppendResp'Success'NoStream ::
  Data.ProtoLens.Prism.Prism' AppendResp'Success'CurrentRevisionOption Proto.Shared.Empty
_AppendResp'Success'NoStream
  = Data.ProtoLens.Prism.prism'
      AppendResp'Success'NoStream
      (\ p__
         -> case p__ of
              (AppendResp'Success'NoStream p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_AppendResp'Success'Position ::
  Data.ProtoLens.Prism.Prism' AppendResp'Success'PositionOption AppendResp'Position
_AppendResp'Success'Position
  = Data.ProtoLens.Prism.prism'
      AppendResp'Success'Position
      (\ p__
         -> case p__ of
              (AppendResp'Success'Position p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_AppendResp'Success'NoPosition ::
  Data.ProtoLens.Prism.Prism' AppendResp'Success'PositionOption Proto.Shared.Empty
_AppendResp'Success'NoPosition
  = Data.ProtoLens.Prism.prism'
      AppendResp'Success'NoPosition
      (\ p__
         -> case p__ of
              (AppendResp'Success'NoPosition p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.Streams_Fields.maybe'currentRevisionOption2060' @:: Lens' AppendResp'WrongExpectedVersion (Prelude.Maybe AppendResp'WrongExpectedVersion'CurrentRevisionOption2060)@
         * 'Proto.Streams_Fields.maybe'currentRevision2060' @:: Lens' AppendResp'WrongExpectedVersion (Prelude.Maybe Data.Word.Word64)@
         * 'Proto.Streams_Fields.currentRevision2060' @:: Lens' AppendResp'WrongExpectedVersion Data.Word.Word64@
         * 'Proto.Streams_Fields.maybe'noStream2060' @:: Lens' AppendResp'WrongExpectedVersion (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.noStream2060' @:: Lens' AppendResp'WrongExpectedVersion Proto.Shared.Empty@
         * 'Proto.Streams_Fields.maybe'expectedRevisionOption2060' @:: Lens' AppendResp'WrongExpectedVersion (Prelude.Maybe AppendResp'WrongExpectedVersion'ExpectedRevisionOption2060)@
         * 'Proto.Streams_Fields.maybe'expectedRevision2060' @:: Lens' AppendResp'WrongExpectedVersion (Prelude.Maybe Data.Word.Word64)@
         * 'Proto.Streams_Fields.expectedRevision2060' @:: Lens' AppendResp'WrongExpectedVersion Data.Word.Word64@
         * 'Proto.Streams_Fields.maybe'any2060' @:: Lens' AppendResp'WrongExpectedVersion (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.any2060' @:: Lens' AppendResp'WrongExpectedVersion Proto.Shared.Empty@
         * 'Proto.Streams_Fields.maybe'streamExists2060' @:: Lens' AppendResp'WrongExpectedVersion (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.streamExists2060' @:: Lens' AppendResp'WrongExpectedVersion Proto.Shared.Empty@
         * 'Proto.Streams_Fields.maybe'currentRevisionOption' @:: Lens' AppendResp'WrongExpectedVersion (Prelude.Maybe AppendResp'WrongExpectedVersion'CurrentRevisionOption)@
         * 'Proto.Streams_Fields.maybe'currentRevision' @:: Lens' AppendResp'WrongExpectedVersion (Prelude.Maybe Data.Word.Word64)@
         * 'Proto.Streams_Fields.currentRevision' @:: Lens' AppendResp'WrongExpectedVersion Data.Word.Word64@
         * 'Proto.Streams_Fields.maybe'currentNoStream' @:: Lens' AppendResp'WrongExpectedVersion (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.currentNoStream' @:: Lens' AppendResp'WrongExpectedVersion Proto.Shared.Empty@
         * 'Proto.Streams_Fields.maybe'expectedRevisionOption' @:: Lens' AppendResp'WrongExpectedVersion (Prelude.Maybe AppendResp'WrongExpectedVersion'ExpectedRevisionOption)@
         * 'Proto.Streams_Fields.maybe'expectedRevision' @:: Lens' AppendResp'WrongExpectedVersion (Prelude.Maybe Data.Word.Word64)@
         * 'Proto.Streams_Fields.expectedRevision' @:: Lens' AppendResp'WrongExpectedVersion Data.Word.Word64@
         * 'Proto.Streams_Fields.maybe'expectedAny' @:: Lens' AppendResp'WrongExpectedVersion (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.expectedAny' @:: Lens' AppendResp'WrongExpectedVersion Proto.Shared.Empty@
         * 'Proto.Streams_Fields.maybe'expectedStreamExists' @:: Lens' AppendResp'WrongExpectedVersion (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.expectedStreamExists' @:: Lens' AppendResp'WrongExpectedVersion Proto.Shared.Empty@
         * 'Proto.Streams_Fields.maybe'expectedNoStream' @:: Lens' AppendResp'WrongExpectedVersion (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.expectedNoStream' @:: Lens' AppendResp'WrongExpectedVersion Proto.Shared.Empty@ -}
data AppendResp'WrongExpectedVersion
  = AppendResp'WrongExpectedVersion'_constructor {_AppendResp'WrongExpectedVersion'currentRevisionOption2060 :: !(Prelude.Maybe AppendResp'WrongExpectedVersion'CurrentRevisionOption2060),
                                                  _AppendResp'WrongExpectedVersion'expectedRevisionOption2060 :: !(Prelude.Maybe AppendResp'WrongExpectedVersion'ExpectedRevisionOption2060),
                                                  _AppendResp'WrongExpectedVersion'currentRevisionOption :: !(Prelude.Maybe AppendResp'WrongExpectedVersion'CurrentRevisionOption),
                                                  _AppendResp'WrongExpectedVersion'expectedRevisionOption :: !(Prelude.Maybe AppendResp'WrongExpectedVersion'ExpectedRevisionOption),
                                                  _AppendResp'WrongExpectedVersion'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show AppendResp'WrongExpectedVersion where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data AppendResp'WrongExpectedVersion'CurrentRevisionOption2060
  = AppendResp'WrongExpectedVersion'CurrentRevision2060 !Data.Word.Word64 |
    AppendResp'WrongExpectedVersion'NoStream2060 !Proto.Shared.Empty
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
data AppendResp'WrongExpectedVersion'ExpectedRevisionOption2060
  = AppendResp'WrongExpectedVersion'ExpectedRevision2060 !Data.Word.Word64 |
    AppendResp'WrongExpectedVersion'Any2060 !Proto.Shared.Empty |
    AppendResp'WrongExpectedVersion'StreamExists2060 !Proto.Shared.Empty
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
data AppendResp'WrongExpectedVersion'CurrentRevisionOption
  = AppendResp'WrongExpectedVersion'CurrentRevision !Data.Word.Word64 |
    AppendResp'WrongExpectedVersion'CurrentNoStream !Proto.Shared.Empty
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
data AppendResp'WrongExpectedVersion'ExpectedRevisionOption
  = AppendResp'WrongExpectedVersion'ExpectedRevision !Data.Word.Word64 |
    AppendResp'WrongExpectedVersion'ExpectedAny !Proto.Shared.Empty |
    AppendResp'WrongExpectedVersion'ExpectedStreamExists !Proto.Shared.Empty |
    AppendResp'WrongExpectedVersion'ExpectedNoStream !Proto.Shared.Empty
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "maybe'currentRevisionOption2060" (Prelude.Maybe AppendResp'WrongExpectedVersion'CurrentRevisionOption2060) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'currentRevisionOption2060
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'currentRevisionOption2060 = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "maybe'currentRevision2060" (Prelude.Maybe Data.Word.Word64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'currentRevisionOption2060
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'currentRevisionOption2060 = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (AppendResp'WrongExpectedVersion'CurrentRevision2060 x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__
              -> Prelude.fmap
                   AppendResp'WrongExpectedVersion'CurrentRevision2060 y__))
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "currentRevision2060" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'currentRevisionOption2060
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'currentRevisionOption2060 = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (AppendResp'WrongExpectedVersion'CurrentRevision2060 x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__
                 -> Prelude.fmap
                      AppendResp'WrongExpectedVersion'CurrentRevision2060 y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "maybe'noStream2060" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'currentRevisionOption2060
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'currentRevisionOption2060 = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (AppendResp'WrongExpectedVersion'NoStream2060 x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__
              -> Prelude.fmap AppendResp'WrongExpectedVersion'NoStream2060 y__))
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "noStream2060" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'currentRevisionOption2060
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'currentRevisionOption2060 = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (AppendResp'WrongExpectedVersion'NoStream2060 x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__
                 -> Prelude.fmap AppendResp'WrongExpectedVersion'NoStream2060 y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "maybe'expectedRevisionOption2060" (Prelude.Maybe AppendResp'WrongExpectedVersion'ExpectedRevisionOption2060) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'expectedRevisionOption2060
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'expectedRevisionOption2060 = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "maybe'expectedRevision2060" (Prelude.Maybe Data.Word.Word64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'expectedRevisionOption2060
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'expectedRevisionOption2060 = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (AppendResp'WrongExpectedVersion'ExpectedRevision2060 x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__
              -> Prelude.fmap
                   AppendResp'WrongExpectedVersion'ExpectedRevision2060 y__))
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "expectedRevision2060" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'expectedRevisionOption2060
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'expectedRevisionOption2060 = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (AppendResp'WrongExpectedVersion'ExpectedRevision2060 x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__
                 -> Prelude.fmap
                      AppendResp'WrongExpectedVersion'ExpectedRevision2060 y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "maybe'any2060" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'expectedRevisionOption2060
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'expectedRevisionOption2060 = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (AppendResp'WrongExpectedVersion'Any2060 x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__
              -> Prelude.fmap AppendResp'WrongExpectedVersion'Any2060 y__))
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "any2060" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'expectedRevisionOption2060
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'expectedRevisionOption2060 = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (AppendResp'WrongExpectedVersion'Any2060 x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__
                 -> Prelude.fmap AppendResp'WrongExpectedVersion'Any2060 y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "maybe'streamExists2060" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'expectedRevisionOption2060
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'expectedRevisionOption2060 = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (AppendResp'WrongExpectedVersion'StreamExists2060 x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__
              -> Prelude.fmap
                   AppendResp'WrongExpectedVersion'StreamExists2060 y__))
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "streamExists2060" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'expectedRevisionOption2060
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'expectedRevisionOption2060 = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (AppendResp'WrongExpectedVersion'StreamExists2060 x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__
                 -> Prelude.fmap
                      AppendResp'WrongExpectedVersion'StreamExists2060 y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "maybe'currentRevisionOption" (Prelude.Maybe AppendResp'WrongExpectedVersion'CurrentRevisionOption) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'currentRevisionOption
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'currentRevisionOption = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "maybe'currentRevision" (Prelude.Maybe Data.Word.Word64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'currentRevisionOption
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'currentRevisionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (AppendResp'WrongExpectedVersion'CurrentRevision x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__
              -> Prelude.fmap
                   AppendResp'WrongExpectedVersion'CurrentRevision y__))
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "currentRevision" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'currentRevisionOption
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'currentRevisionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (AppendResp'WrongExpectedVersion'CurrentRevision x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__
                 -> Prelude.fmap
                      AppendResp'WrongExpectedVersion'CurrentRevision y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "maybe'currentNoStream" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'currentRevisionOption
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'currentRevisionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (AppendResp'WrongExpectedVersion'CurrentNoStream x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__
              -> Prelude.fmap
                   AppendResp'WrongExpectedVersion'CurrentNoStream y__))
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "currentNoStream" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'currentRevisionOption
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'currentRevisionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (AppendResp'WrongExpectedVersion'CurrentNoStream x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__
                 -> Prelude.fmap
                      AppendResp'WrongExpectedVersion'CurrentNoStream y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "maybe'expectedRevisionOption" (Prelude.Maybe AppendResp'WrongExpectedVersion'ExpectedRevisionOption) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'expectedRevisionOption
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'expectedRevisionOption = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "maybe'expectedRevision" (Prelude.Maybe Data.Word.Word64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'expectedRevisionOption
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'expectedRevisionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (AppendResp'WrongExpectedVersion'ExpectedRevision x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__
              -> Prelude.fmap
                   AppendResp'WrongExpectedVersion'ExpectedRevision y__))
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "expectedRevision" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'expectedRevisionOption
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'expectedRevisionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (AppendResp'WrongExpectedVersion'ExpectedRevision x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__
                 -> Prelude.fmap
                      AppendResp'WrongExpectedVersion'ExpectedRevision y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "maybe'expectedAny" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'expectedRevisionOption
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'expectedRevisionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (AppendResp'WrongExpectedVersion'ExpectedAny x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__
              -> Prelude.fmap AppendResp'WrongExpectedVersion'ExpectedAny y__))
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "expectedAny" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'expectedRevisionOption
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'expectedRevisionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (AppendResp'WrongExpectedVersion'ExpectedAny x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__
                 -> Prelude.fmap AppendResp'WrongExpectedVersion'ExpectedAny y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "maybe'expectedStreamExists" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'expectedRevisionOption
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'expectedRevisionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (AppendResp'WrongExpectedVersion'ExpectedStreamExists x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__
              -> Prelude.fmap
                   AppendResp'WrongExpectedVersion'ExpectedStreamExists y__))
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "expectedStreamExists" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'expectedRevisionOption
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'expectedRevisionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (AppendResp'WrongExpectedVersion'ExpectedStreamExists x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__
                 -> Prelude.fmap
                      AppendResp'WrongExpectedVersion'ExpectedStreamExists y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "maybe'expectedNoStream" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'expectedRevisionOption
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'expectedRevisionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (AppendResp'WrongExpectedVersion'ExpectedNoStream x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__
              -> Prelude.fmap
                   AppendResp'WrongExpectedVersion'ExpectedNoStream y__))
instance Data.ProtoLens.Field.HasField AppendResp'WrongExpectedVersion "expectedNoStream" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AppendResp'WrongExpectedVersion'expectedRevisionOption
           (\ x__ y__
              -> x__
                   {_AppendResp'WrongExpectedVersion'expectedRevisionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (AppendResp'WrongExpectedVersion'ExpectedNoStream x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__
                 -> Prelude.fmap
                      AppendResp'WrongExpectedVersion'ExpectedNoStream y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message AppendResp'WrongExpectedVersion where
  messageName _
    = Data.Text.pack
        "event_store.client.streams.AppendResp.WrongExpectedVersion"
  packedMessageDescriptor _
    = "\n\
      \\DC4WrongExpectedVersion\DC26\n\
      \\ETBcurrent_revision_20_6_0\CAN\SOH \SOH(\EOTH\NULR\DC3currentRevision2060\DC2C\n\
      \\DLEno_stream_20_6_0\CAN\STX \SOH(\v2\EM.event_store.client.EmptyH\NULR\fnoStream2060\DC28\n\
      \\CANexpected_revision_20_6_0\CAN\ETX \SOH(\EOTH\SOHR\DC4expectedRevision2060\DC28\n\
      \\n\
      \any_20_6_0\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\SOHR\aany2060\DC2K\n\
      \\DC4stream_exists_20_6_0\CAN\ENQ \SOH(\v2\EM.event_store.client.EmptyH\SOHR\DLEstreamExists2060\DC2+\n\
      \\DLEcurrent_revision\CAN\ACK \SOH(\EOTH\STXR\SIcurrentRevision\DC2G\n\
      \\DC1current_no_stream\CAN\a \SOH(\v2\EM.event_store.client.EmptyH\STXR\SIcurrentNoStream\DC2-\n\
      \\DC1expected_revision\CAN\b \SOH(\EOTH\ETXR\DLEexpectedRevision\DC2>\n\
      \\fexpected_any\CAN\t \SOH(\v2\EM.event_store.client.EmptyH\ETXR\vexpectedAny\DC2Q\n\
      \\SYNexpected_stream_exists\CAN\n\
      \ \SOH(\v2\EM.event_store.client.EmptyH\ETXR\DC4expectedStreamExists\DC2I\n\
      \\DC2expected_no_stream\CAN\v \SOH(\v2\EM.event_store.client.EmptyH\ETXR\DLEexpectedNoStreamB \n\
      \\RScurrent_revision_option_20_6_0B!\n\
      \\USexpected_revision_option_20_6_0B\EM\n\
      \\ETBcurrent_revision_optionB\SUB\n\
      \\CANexpected_revision_option"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        currentRevision2060__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "current_revision_20_6_0"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'currentRevision2060")) ::
              Data.ProtoLens.FieldDescriptor AppendResp'WrongExpectedVersion
        noStream2060__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "no_stream_20_6_0"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'noStream2060")) ::
              Data.ProtoLens.FieldDescriptor AppendResp'WrongExpectedVersion
        expectedRevision2060__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "expected_revision_20_6_0"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'expectedRevision2060")) ::
              Data.ProtoLens.FieldDescriptor AppendResp'WrongExpectedVersion
        any2060__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "any_20_6_0"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'any2060")) ::
              Data.ProtoLens.FieldDescriptor AppendResp'WrongExpectedVersion
        streamExists2060__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stream_exists_20_6_0"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'streamExists2060")) ::
              Data.ProtoLens.FieldDescriptor AppendResp'WrongExpectedVersion
        currentRevision__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "current_revision"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'currentRevision")) ::
              Data.ProtoLens.FieldDescriptor AppendResp'WrongExpectedVersion
        currentNoStream__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "current_no_stream"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'currentNoStream")) ::
              Data.ProtoLens.FieldDescriptor AppendResp'WrongExpectedVersion
        expectedRevision__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "expected_revision"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'expectedRevision")) ::
              Data.ProtoLens.FieldDescriptor AppendResp'WrongExpectedVersion
        expectedAny__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "expected_any"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'expectedAny")) ::
              Data.ProtoLens.FieldDescriptor AppendResp'WrongExpectedVersion
        expectedStreamExists__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "expected_stream_exists"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'expectedStreamExists")) ::
              Data.ProtoLens.FieldDescriptor AppendResp'WrongExpectedVersion
        expectedNoStream__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "expected_no_stream"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'expectedNoStream")) ::
              Data.ProtoLens.FieldDescriptor AppendResp'WrongExpectedVersion
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, currentRevision2060__field_descriptor),
           (Data.ProtoLens.Tag 2, noStream2060__field_descriptor),
           (Data.ProtoLens.Tag 3, expectedRevision2060__field_descriptor),
           (Data.ProtoLens.Tag 4, any2060__field_descriptor),
           (Data.ProtoLens.Tag 5, streamExists2060__field_descriptor),
           (Data.ProtoLens.Tag 6, currentRevision__field_descriptor),
           (Data.ProtoLens.Tag 7, currentNoStream__field_descriptor),
           (Data.ProtoLens.Tag 8, expectedRevision__field_descriptor),
           (Data.ProtoLens.Tag 9, expectedAny__field_descriptor),
           (Data.ProtoLens.Tag 10, expectedStreamExists__field_descriptor),
           (Data.ProtoLens.Tag 11, expectedNoStream__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _AppendResp'WrongExpectedVersion'_unknownFields
        (\ x__ y__
           -> x__ {_AppendResp'WrongExpectedVersion'_unknownFields = y__})
  defMessage
    = AppendResp'WrongExpectedVersion'_constructor
        {_AppendResp'WrongExpectedVersion'currentRevisionOption2060 = Prelude.Nothing,
         _AppendResp'WrongExpectedVersion'expectedRevisionOption2060 = Prelude.Nothing,
         _AppendResp'WrongExpectedVersion'currentRevisionOption = Prelude.Nothing,
         _AppendResp'WrongExpectedVersion'expectedRevisionOption = Prelude.Nothing,
         _AppendResp'WrongExpectedVersion'_unknownFields = []}
  parseMessage
    = let
        loop ::
          AppendResp'WrongExpectedVersion
          -> Data.ProtoLens.Encoding.Bytes.Parser AppendResp'WrongExpectedVersion
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
                                       "current_revision_20_6_0"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"currentRevision2060") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "no_stream_20_6_0"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"noStream2060") y x)
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt
                                       "expected_revision_20_6_0"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"expectedRevision2060") y x)
                        34
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "any_20_6_0"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"any2060") y x)
                        42
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "stream_exists_20_6_0"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"streamExists2060") y x)
                        48
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "current_revision"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"currentRevision") y x)
                        58
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "current_no_stream"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"currentNoStream") y x)
                        64
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "expected_revision"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"expectedRevision") y x)
                        74
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "expected_any"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"expectedAny") y x)
                        82
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "expected_stream_exists"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"expectedStreamExists") y x)
                        90
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
                    (Data.ProtoLens.Field.field @"maybe'currentRevisionOption2060") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just (AppendResp'WrongExpectedVersion'CurrentRevision2060 v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt v)
                (Prelude.Just (AppendResp'WrongExpectedVersion'NoStream2060 v))
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
                       (Data.ProtoLens.Field.field @"maybe'expectedRevisionOption2060") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just (AppendResp'WrongExpectedVersion'ExpectedRevision2060 v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt v)
                   (Prelude.Just (AppendResp'WrongExpectedVersion'Any2060 v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 34)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage v)
                   (Prelude.Just (AppendResp'WrongExpectedVersion'StreamExists2060 v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 42)
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
                          (Data.ProtoLens.Field.field @"maybe'currentRevisionOption") _x
                    of
                      Prelude.Nothing -> Data.Monoid.mempty
                      (Prelude.Just (AppendResp'WrongExpectedVersion'CurrentRevision v))
                        -> (Data.Monoid.<>)
                             (Data.ProtoLens.Encoding.Bytes.putVarInt 48)
                             (Data.ProtoLens.Encoding.Bytes.putVarInt v)
                      (Prelude.Just (AppendResp'WrongExpectedVersion'CurrentNoStream v))
                        -> (Data.Monoid.<>)
                             (Data.ProtoLens.Encoding.Bytes.putVarInt 58)
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
                             (Data.ProtoLens.Field.field @"maybe'expectedRevisionOption") _x
                       of
                         Prelude.Nothing -> Data.Monoid.mempty
                         (Prelude.Just (AppendResp'WrongExpectedVersion'ExpectedRevision v))
                           -> (Data.Monoid.<>)
                                (Data.ProtoLens.Encoding.Bytes.putVarInt 64)
                                (Data.ProtoLens.Encoding.Bytes.putVarInt v)
                         (Prelude.Just (AppendResp'WrongExpectedVersion'ExpectedAny v))
                           -> (Data.Monoid.<>)
                                (Data.ProtoLens.Encoding.Bytes.putVarInt 74)
                                ((Prelude..)
                                   (\ bs
                                      -> (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt
                                              (Prelude.fromIntegral (Data.ByteString.length bs)))
                                           (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                   Data.ProtoLens.encodeMessage v)
                         (Prelude.Just (AppendResp'WrongExpectedVersion'ExpectedStreamExists v))
                           -> (Data.Monoid.<>)
                                (Data.ProtoLens.Encoding.Bytes.putVarInt 82)
                                ((Prelude..)
                                   (\ bs
                                      -> (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt
                                              (Prelude.fromIntegral (Data.ByteString.length bs)))
                                           (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                   Data.ProtoLens.encodeMessage v)
                         (Prelude.Just (AppendResp'WrongExpectedVersion'ExpectedNoStream v))
                           -> (Data.Monoid.<>)
                                (Data.ProtoLens.Encoding.Bytes.putVarInt 90)
                                ((Prelude..)
                                   (\ bs
                                      -> (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt
                                              (Prelude.fromIntegral (Data.ByteString.length bs)))
                                           (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                   Data.ProtoLens.encodeMessage v))
                      (Data.ProtoLens.Encoding.Wire.buildFieldSet
                         (Lens.Family2.view Data.ProtoLens.unknownFields _x)))))
instance Control.DeepSeq.NFData AppendResp'WrongExpectedVersion where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_AppendResp'WrongExpectedVersion'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_AppendResp'WrongExpectedVersion'currentRevisionOption2060 x__)
                (Control.DeepSeq.deepseq
                   (_AppendResp'WrongExpectedVersion'expectedRevisionOption2060 x__)
                   (Control.DeepSeq.deepseq
                      (_AppendResp'WrongExpectedVersion'currentRevisionOption x__)
                      (Control.DeepSeq.deepseq
                         (_AppendResp'WrongExpectedVersion'expectedRevisionOption x__)
                         ()))))
instance Control.DeepSeq.NFData AppendResp'WrongExpectedVersion'CurrentRevisionOption2060 where
  rnf (AppendResp'WrongExpectedVersion'CurrentRevision2060 x__)
    = Control.DeepSeq.rnf x__
  rnf (AppendResp'WrongExpectedVersion'NoStream2060 x__)
    = Control.DeepSeq.rnf x__
instance Control.DeepSeq.NFData AppendResp'WrongExpectedVersion'ExpectedRevisionOption2060 where
  rnf (AppendResp'WrongExpectedVersion'ExpectedRevision2060 x__)
    = Control.DeepSeq.rnf x__
  rnf (AppendResp'WrongExpectedVersion'Any2060 x__)
    = Control.DeepSeq.rnf x__
  rnf (AppendResp'WrongExpectedVersion'StreamExists2060 x__)
    = Control.DeepSeq.rnf x__
instance Control.DeepSeq.NFData AppendResp'WrongExpectedVersion'CurrentRevisionOption where
  rnf (AppendResp'WrongExpectedVersion'CurrentRevision x__)
    = Control.DeepSeq.rnf x__
  rnf (AppendResp'WrongExpectedVersion'CurrentNoStream x__)
    = Control.DeepSeq.rnf x__
instance Control.DeepSeq.NFData AppendResp'WrongExpectedVersion'ExpectedRevisionOption where
  rnf (AppendResp'WrongExpectedVersion'ExpectedRevision x__)
    = Control.DeepSeq.rnf x__
  rnf (AppendResp'WrongExpectedVersion'ExpectedAny x__)
    = Control.DeepSeq.rnf x__
  rnf (AppendResp'WrongExpectedVersion'ExpectedStreamExists x__)
    = Control.DeepSeq.rnf x__
  rnf (AppendResp'WrongExpectedVersion'ExpectedNoStream x__)
    = Control.DeepSeq.rnf x__
_AppendResp'WrongExpectedVersion'CurrentRevision2060 ::
  Data.ProtoLens.Prism.Prism' AppendResp'WrongExpectedVersion'CurrentRevisionOption2060 Data.Word.Word64
_AppendResp'WrongExpectedVersion'CurrentRevision2060
  = Data.ProtoLens.Prism.prism'
      AppendResp'WrongExpectedVersion'CurrentRevision2060
      (\ p__
         -> case p__ of
              (AppendResp'WrongExpectedVersion'CurrentRevision2060 p__val)
                -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_AppendResp'WrongExpectedVersion'NoStream2060 ::
  Data.ProtoLens.Prism.Prism' AppendResp'WrongExpectedVersion'CurrentRevisionOption2060 Proto.Shared.Empty
_AppendResp'WrongExpectedVersion'NoStream2060
  = Data.ProtoLens.Prism.prism'
      AppendResp'WrongExpectedVersion'NoStream2060
      (\ p__
         -> case p__ of
              (AppendResp'WrongExpectedVersion'NoStream2060 p__val)
                -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_AppendResp'WrongExpectedVersion'ExpectedRevision2060 ::
  Data.ProtoLens.Prism.Prism' AppendResp'WrongExpectedVersion'ExpectedRevisionOption2060 Data.Word.Word64
_AppendResp'WrongExpectedVersion'ExpectedRevision2060
  = Data.ProtoLens.Prism.prism'
      AppendResp'WrongExpectedVersion'ExpectedRevision2060
      (\ p__
         -> case p__ of
              (AppendResp'WrongExpectedVersion'ExpectedRevision2060 p__val)
                -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_AppendResp'WrongExpectedVersion'Any2060 ::
  Data.ProtoLens.Prism.Prism' AppendResp'WrongExpectedVersion'ExpectedRevisionOption2060 Proto.Shared.Empty
_AppendResp'WrongExpectedVersion'Any2060
  = Data.ProtoLens.Prism.prism'
      AppendResp'WrongExpectedVersion'Any2060
      (\ p__
         -> case p__ of
              (AppendResp'WrongExpectedVersion'Any2060 p__val)
                -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_AppendResp'WrongExpectedVersion'StreamExists2060 ::
  Data.ProtoLens.Prism.Prism' AppendResp'WrongExpectedVersion'ExpectedRevisionOption2060 Proto.Shared.Empty
_AppendResp'WrongExpectedVersion'StreamExists2060
  = Data.ProtoLens.Prism.prism'
      AppendResp'WrongExpectedVersion'StreamExists2060
      (\ p__
         -> case p__ of
              (AppendResp'WrongExpectedVersion'StreamExists2060 p__val)
                -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_AppendResp'WrongExpectedVersion'CurrentRevision ::
  Data.ProtoLens.Prism.Prism' AppendResp'WrongExpectedVersion'CurrentRevisionOption Data.Word.Word64
_AppendResp'WrongExpectedVersion'CurrentRevision
  = Data.ProtoLens.Prism.prism'
      AppendResp'WrongExpectedVersion'CurrentRevision
      (\ p__
         -> case p__ of
              (AppendResp'WrongExpectedVersion'CurrentRevision p__val)
                -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_AppendResp'WrongExpectedVersion'CurrentNoStream ::
  Data.ProtoLens.Prism.Prism' AppendResp'WrongExpectedVersion'CurrentRevisionOption Proto.Shared.Empty
_AppendResp'WrongExpectedVersion'CurrentNoStream
  = Data.ProtoLens.Prism.prism'
      AppendResp'WrongExpectedVersion'CurrentNoStream
      (\ p__
         -> case p__ of
              (AppendResp'WrongExpectedVersion'CurrentNoStream p__val)
                -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_AppendResp'WrongExpectedVersion'ExpectedRevision ::
  Data.ProtoLens.Prism.Prism' AppendResp'WrongExpectedVersion'ExpectedRevisionOption Data.Word.Word64
_AppendResp'WrongExpectedVersion'ExpectedRevision
  = Data.ProtoLens.Prism.prism'
      AppendResp'WrongExpectedVersion'ExpectedRevision
      (\ p__
         -> case p__ of
              (AppendResp'WrongExpectedVersion'ExpectedRevision p__val)
                -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_AppendResp'WrongExpectedVersion'ExpectedAny ::
  Data.ProtoLens.Prism.Prism' AppendResp'WrongExpectedVersion'ExpectedRevisionOption Proto.Shared.Empty
_AppendResp'WrongExpectedVersion'ExpectedAny
  = Data.ProtoLens.Prism.prism'
      AppendResp'WrongExpectedVersion'ExpectedAny
      (\ p__
         -> case p__ of
              (AppendResp'WrongExpectedVersion'ExpectedAny p__val)
                -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_AppendResp'WrongExpectedVersion'ExpectedStreamExists ::
  Data.ProtoLens.Prism.Prism' AppendResp'WrongExpectedVersion'ExpectedRevisionOption Proto.Shared.Empty
_AppendResp'WrongExpectedVersion'ExpectedStreamExists
  = Data.ProtoLens.Prism.prism'
      AppendResp'WrongExpectedVersion'ExpectedStreamExists
      (\ p__
         -> case p__ of
              (AppendResp'WrongExpectedVersion'ExpectedStreamExists p__val)
                -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_AppendResp'WrongExpectedVersion'ExpectedNoStream ::
  Data.ProtoLens.Prism.Prism' AppendResp'WrongExpectedVersion'ExpectedRevisionOption Proto.Shared.Empty
_AppendResp'WrongExpectedVersion'ExpectedNoStream
  = Data.ProtoLens.Prism.prism'
      AppendResp'WrongExpectedVersion'ExpectedNoStream
      (\ p__
         -> case p__ of
              (AppendResp'WrongExpectedVersion'ExpectedNoStream p__val)
                -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.Streams_Fields.correlationId' @:: Lens' BatchAppendReq Proto.Shared.UUID@
         * 'Proto.Streams_Fields.maybe'correlationId' @:: Lens' BatchAppendReq (Prelude.Maybe Proto.Shared.UUID)@
         * 'Proto.Streams_Fields.options' @:: Lens' BatchAppendReq BatchAppendReq'Options@
         * 'Proto.Streams_Fields.maybe'options' @:: Lens' BatchAppendReq (Prelude.Maybe BatchAppendReq'Options)@
         * 'Proto.Streams_Fields.proposedMessages' @:: Lens' BatchAppendReq [BatchAppendReq'ProposedMessage]@
         * 'Proto.Streams_Fields.vec'proposedMessages' @:: Lens' BatchAppendReq (Data.Vector.Vector BatchAppendReq'ProposedMessage)@
         * 'Proto.Streams_Fields.isFinal' @:: Lens' BatchAppendReq Prelude.Bool@ -}
data BatchAppendReq
  = BatchAppendReq'_constructor {_BatchAppendReq'correlationId :: !(Prelude.Maybe Proto.Shared.UUID),
                                 _BatchAppendReq'options :: !(Prelude.Maybe BatchAppendReq'Options),
                                 _BatchAppendReq'proposedMessages :: !(Data.Vector.Vector BatchAppendReq'ProposedMessage),
                                 _BatchAppendReq'isFinal :: !Prelude.Bool,
                                 _BatchAppendReq'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show BatchAppendReq where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField BatchAppendReq "correlationId" Proto.Shared.UUID where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'correlationId
           (\ x__ y__ -> x__ {_BatchAppendReq'correlationId = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField BatchAppendReq "maybe'correlationId" (Prelude.Maybe Proto.Shared.UUID) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'correlationId
           (\ x__ y__ -> x__ {_BatchAppendReq'correlationId = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField BatchAppendReq "options" BatchAppendReq'Options where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'options
           (\ x__ y__ -> x__ {_BatchAppendReq'options = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField BatchAppendReq "maybe'options" (Prelude.Maybe BatchAppendReq'Options) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'options
           (\ x__ y__ -> x__ {_BatchAppendReq'options = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField BatchAppendReq "proposedMessages" [BatchAppendReq'ProposedMessage] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'proposedMessages
           (\ x__ y__ -> x__ {_BatchAppendReq'proposedMessages = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField BatchAppendReq "vec'proposedMessages" (Data.Vector.Vector BatchAppendReq'ProposedMessage) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'proposedMessages
           (\ x__ y__ -> x__ {_BatchAppendReq'proposedMessages = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField BatchAppendReq "isFinal" Prelude.Bool where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'isFinal
           (\ x__ y__ -> x__ {_BatchAppendReq'isFinal = y__}))
        Prelude.id
instance Data.ProtoLens.Message BatchAppendReq where
  messageName _
    = Data.Text.pack "event_store.client.streams.BatchAppendReq"
  packedMessageDescriptor _
    = "\n\
      \\SOBatchAppendReq\DC2?\n\
      \\SOcorrelation_id\CAN\SOH \SOH(\v2\CAN.event_store.client.UUIDR\rcorrelationId\DC2L\n\
      \\aoptions\CAN\STX \SOH(\v22.event_store.client.streams.BatchAppendReq.OptionsR\aoptions\DC2g\n\
      \\DC1proposed_messages\CAN\ETX \ETX(\v2:.event_store.client.streams.BatchAppendReq.ProposedMessageR\DLEproposedMessages\DC2\EM\n\
      \\bis_final\CAN\EOT \SOH(\bR\aisFinal\SUB\216\ETX\n\
      \\aOptions\DC2Q\n\
      \\DC1stream_identifier\CAN\SOH \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier\DC2)\n\
      \\SIstream_position\CAN\STX \SOH(\EOTH\NULR\SOstreamPosition\DC25\n\
      \\tno_stream\CAN\ETX \SOH(\v2\SYN.google.protobuf.EmptyH\NULR\bnoStream\DC2*\n\
      \\ETXany\CAN\EOT \SOH(\v2\SYN.google.protobuf.EmptyH\NULR\ETXany\DC2=\n\
      \\rstream_exists\CAN\ENQ \SOH(\v2\SYN.google.protobuf.EmptyH\NULR\fstreamExists\DC2E\n\
      \\DLEdeadline_21_10_0\CAN\ACK \SOH(\v2\SUB.google.protobuf.TimestampH\SOHR\rdeadline21100\DC27\n\
      \\bdeadline\CAN\a \SOH(\v2\EM.google.protobuf.DurationH\SOHR\bdeadlineB\SUB\n\
      \\CANexpected_stream_positionB\DC1\n\
      \\SIdeadline_option\SUB\155\STX\n\
      \\SIProposedMessage\DC2(\n\
      \\STXid\CAN\SOH \SOH(\v2\CAN.event_store.client.UUIDR\STXid\DC2d\n\
      \\bmetadata\CAN\STX \ETX(\v2H.event_store.client.streams.BatchAppendReq.ProposedMessage.MetadataEntryR\bmetadata\DC2'\n\
      \\SIcustom_metadata\CAN\ETX \SOH(\fR\SOcustomMetadata\DC2\DC2\n\
      \\EOTdata\CAN\EOT \SOH(\fR\EOTdata\SUB;\n\
      \\rMetadataEntry\DC2\DLE\n\
      \\ETXkey\CAN\SOH \SOH(\tR\ETXkey\DC2\DC4\n\
      \\ENQvalue\CAN\STX \SOH(\tR\ENQvalue:\STX8\SOH"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        correlationId__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "correlation_id"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.UUID)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'correlationId")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendReq
        options__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "options"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor BatchAppendReq'Options)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'options")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendReq
        proposedMessages__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "proposed_messages"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor BatchAppendReq'ProposedMessage)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"proposedMessages")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendReq
        isFinal__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "is_final"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BoolField ::
                 Data.ProtoLens.FieldTypeDescriptor Prelude.Bool)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"isFinal")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendReq
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, correlationId__field_descriptor),
           (Data.ProtoLens.Tag 2, options__field_descriptor),
           (Data.ProtoLens.Tag 3, proposedMessages__field_descriptor),
           (Data.ProtoLens.Tag 4, isFinal__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _BatchAppendReq'_unknownFields
        (\ x__ y__ -> x__ {_BatchAppendReq'_unknownFields = y__})
  defMessage
    = BatchAppendReq'_constructor
        {_BatchAppendReq'correlationId = Prelude.Nothing,
         _BatchAppendReq'options = Prelude.Nothing,
         _BatchAppendReq'proposedMessages = Data.Vector.Generic.empty,
         _BatchAppendReq'isFinal = Data.ProtoLens.fieldDefault,
         _BatchAppendReq'_unknownFields = []}
  parseMessage
    = let
        loop ::
          BatchAppendReq
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld BatchAppendReq'ProposedMessage
             -> Data.ProtoLens.Encoding.Bytes.Parser BatchAppendReq
        loop x mutable'proposedMessages
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'proposedMessages <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                   (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                      mutable'proposedMessages)
                      (let missing = []
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
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t)
                           (Lens.Family2.set
                              (Data.ProtoLens.Field.field @"vec'proposedMessages")
                              frozen'proposedMessages x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "correlation_id"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"correlationId") y x)
                                  mutable'proposedMessages
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "options"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"options") y x)
                                  mutable'proposedMessages
                        26
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "proposed_messages"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'proposedMessages y)
                                loop x v
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          ((Prelude./=) 0) Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "is_final"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"isFinal") y x)
                                  mutable'proposedMessages
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'proposedMessages
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'proposedMessages <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                            Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'proposedMessages)
          "BatchAppendReq"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view
                    (Data.ProtoLens.Field.field @"maybe'correlationId") _x
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
             ((Data.Monoid.<>)
                (case
                     Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'options") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just _v)
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage _v))
                ((Data.Monoid.<>)
                   (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                      (\ _v
                         -> (Data.Monoid.<>)
                              (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                              ((Prelude..)
                                 (\ bs
                                    -> (Data.Monoid.<>)
                                         (Data.ProtoLens.Encoding.Bytes.putVarInt
                                            (Prelude.fromIntegral (Data.ByteString.length bs)))
                                         (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                 Data.ProtoLens.encodeMessage _v))
                      (Lens.Family2.view
                         (Data.ProtoLens.Field.field @"vec'proposedMessages") _x))
                   ((Data.Monoid.<>)
                      (let
                         _v = Lens.Family2.view (Data.ProtoLens.Field.field @"isFinal") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                               ((Prelude..)
                                  Data.ProtoLens.Encoding.Bytes.putVarInt
                                  (\ b -> if b then 1 else 0) _v))
                      (Data.ProtoLens.Encoding.Wire.buildFieldSet
                         (Lens.Family2.view Data.ProtoLens.unknownFields _x)))))
instance Control.DeepSeq.NFData BatchAppendReq where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_BatchAppendReq'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_BatchAppendReq'correlationId x__)
                (Control.DeepSeq.deepseq
                   (_BatchAppendReq'options x__)
                   (Control.DeepSeq.deepseq
                      (_BatchAppendReq'proposedMessages x__)
                      (Control.DeepSeq.deepseq (_BatchAppendReq'isFinal x__) ()))))
{- | Fields :
     
         * 'Proto.Streams_Fields.streamIdentifier' @:: Lens' BatchAppendReq'Options Proto.Shared.StreamIdentifier@
         * 'Proto.Streams_Fields.maybe'streamIdentifier' @:: Lens' BatchAppendReq'Options (Prelude.Maybe Proto.Shared.StreamIdentifier)@
         * 'Proto.Streams_Fields.maybe'expectedStreamPosition' @:: Lens' BatchAppendReq'Options (Prelude.Maybe BatchAppendReq'Options'ExpectedStreamPosition)@
         * 'Proto.Streams_Fields.maybe'streamPosition' @:: Lens' BatchAppendReq'Options (Prelude.Maybe Data.Word.Word64)@
         * 'Proto.Streams_Fields.streamPosition' @:: Lens' BatchAppendReq'Options Data.Word.Word64@
         * 'Proto.Streams_Fields.maybe'noStream' @:: Lens' BatchAppendReq'Options (Prelude.Maybe Proto.Google.Protobuf.Empty.Empty)@
         * 'Proto.Streams_Fields.noStream' @:: Lens' BatchAppendReq'Options Proto.Google.Protobuf.Empty.Empty@
         * 'Proto.Streams_Fields.maybe'any' @:: Lens' BatchAppendReq'Options (Prelude.Maybe Proto.Google.Protobuf.Empty.Empty)@
         * 'Proto.Streams_Fields.any' @:: Lens' BatchAppendReq'Options Proto.Google.Protobuf.Empty.Empty@
         * 'Proto.Streams_Fields.maybe'streamExists' @:: Lens' BatchAppendReq'Options (Prelude.Maybe Proto.Google.Protobuf.Empty.Empty)@
         * 'Proto.Streams_Fields.streamExists' @:: Lens' BatchAppendReq'Options Proto.Google.Protobuf.Empty.Empty@
         * 'Proto.Streams_Fields.maybe'deadlineOption' @:: Lens' BatchAppendReq'Options (Prelude.Maybe BatchAppendReq'Options'DeadlineOption)@
         * 'Proto.Streams_Fields.maybe'deadline21100' @:: Lens' BatchAppendReq'Options (Prelude.Maybe Proto.Google.Protobuf.Timestamp.Timestamp)@
         * 'Proto.Streams_Fields.deadline21100' @:: Lens' BatchAppendReq'Options Proto.Google.Protobuf.Timestamp.Timestamp@
         * 'Proto.Streams_Fields.maybe'deadline' @:: Lens' BatchAppendReq'Options (Prelude.Maybe Proto.Google.Protobuf.Duration.Duration)@
         * 'Proto.Streams_Fields.deadline' @:: Lens' BatchAppendReq'Options Proto.Google.Protobuf.Duration.Duration@ -}
data BatchAppendReq'Options
  = BatchAppendReq'Options'_constructor {_BatchAppendReq'Options'streamIdentifier :: !(Prelude.Maybe Proto.Shared.StreamIdentifier),
                                         _BatchAppendReq'Options'expectedStreamPosition :: !(Prelude.Maybe BatchAppendReq'Options'ExpectedStreamPosition),
                                         _BatchAppendReq'Options'deadlineOption :: !(Prelude.Maybe BatchAppendReq'Options'DeadlineOption),
                                         _BatchAppendReq'Options'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show BatchAppendReq'Options where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data BatchAppendReq'Options'ExpectedStreamPosition
  = BatchAppendReq'Options'StreamPosition !Data.Word.Word64 |
    BatchAppendReq'Options'NoStream !Proto.Google.Protobuf.Empty.Empty |
    BatchAppendReq'Options'Any !Proto.Google.Protobuf.Empty.Empty |
    BatchAppendReq'Options'StreamExists !Proto.Google.Protobuf.Empty.Empty
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
data BatchAppendReq'Options'DeadlineOption
  = BatchAppendReq'Options'Deadline21100 !Proto.Google.Protobuf.Timestamp.Timestamp |
    BatchAppendReq'Options'Deadline !Proto.Google.Protobuf.Duration.Duration
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField BatchAppendReq'Options "streamIdentifier" Proto.Shared.StreamIdentifier where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'Options'streamIdentifier
           (\ x__ y__
              -> x__ {_BatchAppendReq'Options'streamIdentifier = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField BatchAppendReq'Options "maybe'streamIdentifier" (Prelude.Maybe Proto.Shared.StreamIdentifier) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'Options'streamIdentifier
           (\ x__ y__
              -> x__ {_BatchAppendReq'Options'streamIdentifier = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField BatchAppendReq'Options "maybe'expectedStreamPosition" (Prelude.Maybe BatchAppendReq'Options'ExpectedStreamPosition) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'Options'expectedStreamPosition
           (\ x__ y__
              -> x__ {_BatchAppendReq'Options'expectedStreamPosition = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField BatchAppendReq'Options "maybe'streamPosition" (Prelude.Maybe Data.Word.Word64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'Options'expectedStreamPosition
           (\ x__ y__
              -> x__ {_BatchAppendReq'Options'expectedStreamPosition = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (BatchAppendReq'Options'StreamPosition x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__
              -> Prelude.fmap BatchAppendReq'Options'StreamPosition y__))
instance Data.ProtoLens.Field.HasField BatchAppendReq'Options "streamPosition" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'Options'expectedStreamPosition
           (\ x__ y__
              -> x__ {_BatchAppendReq'Options'expectedStreamPosition = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (BatchAppendReq'Options'StreamPosition x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__
                 -> Prelude.fmap BatchAppendReq'Options'StreamPosition y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Field.HasField BatchAppendReq'Options "maybe'noStream" (Prelude.Maybe Proto.Google.Protobuf.Empty.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'Options'expectedStreamPosition
           (\ x__ y__
              -> x__ {_BatchAppendReq'Options'expectedStreamPosition = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (BatchAppendReq'Options'NoStream x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap BatchAppendReq'Options'NoStream y__))
instance Data.ProtoLens.Field.HasField BatchAppendReq'Options "noStream" Proto.Google.Protobuf.Empty.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'Options'expectedStreamPosition
           (\ x__ y__
              -> x__ {_BatchAppendReq'Options'expectedStreamPosition = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (BatchAppendReq'Options'NoStream x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap BatchAppendReq'Options'NoStream y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField BatchAppendReq'Options "maybe'any" (Prelude.Maybe Proto.Google.Protobuf.Empty.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'Options'expectedStreamPosition
           (\ x__ y__
              -> x__ {_BatchAppendReq'Options'expectedStreamPosition = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (BatchAppendReq'Options'Any x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap BatchAppendReq'Options'Any y__))
instance Data.ProtoLens.Field.HasField BatchAppendReq'Options "any" Proto.Google.Protobuf.Empty.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'Options'expectedStreamPosition
           (\ x__ y__
              -> x__ {_BatchAppendReq'Options'expectedStreamPosition = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (BatchAppendReq'Options'Any x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap BatchAppendReq'Options'Any y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField BatchAppendReq'Options "maybe'streamExists" (Prelude.Maybe Proto.Google.Protobuf.Empty.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'Options'expectedStreamPosition
           (\ x__ y__
              -> x__ {_BatchAppendReq'Options'expectedStreamPosition = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (BatchAppendReq'Options'StreamExists x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap BatchAppendReq'Options'StreamExists y__))
instance Data.ProtoLens.Field.HasField BatchAppendReq'Options "streamExists" Proto.Google.Protobuf.Empty.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'Options'expectedStreamPosition
           (\ x__ y__
              -> x__ {_BatchAppendReq'Options'expectedStreamPosition = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (BatchAppendReq'Options'StreamExists x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap BatchAppendReq'Options'StreamExists y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField BatchAppendReq'Options "maybe'deadlineOption" (Prelude.Maybe BatchAppendReq'Options'DeadlineOption) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'Options'deadlineOption
           (\ x__ y__ -> x__ {_BatchAppendReq'Options'deadlineOption = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField BatchAppendReq'Options "maybe'deadline21100" (Prelude.Maybe Proto.Google.Protobuf.Timestamp.Timestamp) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'Options'deadlineOption
           (\ x__ y__ -> x__ {_BatchAppendReq'Options'deadlineOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (BatchAppendReq'Options'Deadline21100 x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap BatchAppendReq'Options'Deadline21100 y__))
instance Data.ProtoLens.Field.HasField BatchAppendReq'Options "deadline21100" Proto.Google.Protobuf.Timestamp.Timestamp where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'Options'deadlineOption
           (\ x__ y__ -> x__ {_BatchAppendReq'Options'deadlineOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (BatchAppendReq'Options'Deadline21100 x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap BatchAppendReq'Options'Deadline21100 y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField BatchAppendReq'Options "maybe'deadline" (Prelude.Maybe Proto.Google.Protobuf.Duration.Duration) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'Options'deadlineOption
           (\ x__ y__ -> x__ {_BatchAppendReq'Options'deadlineOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (BatchAppendReq'Options'Deadline x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap BatchAppendReq'Options'Deadline y__))
instance Data.ProtoLens.Field.HasField BatchAppendReq'Options "deadline" Proto.Google.Protobuf.Duration.Duration where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'Options'deadlineOption
           (\ x__ y__ -> x__ {_BatchAppendReq'Options'deadlineOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (BatchAppendReq'Options'Deadline x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap BatchAppendReq'Options'Deadline y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message BatchAppendReq'Options where
  messageName _
    = Data.Text.pack
        "event_store.client.streams.BatchAppendReq.Options"
  packedMessageDescriptor _
    = "\n\
      \\aOptions\DC2Q\n\
      \\DC1stream_identifier\CAN\SOH \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier\DC2)\n\
      \\SIstream_position\CAN\STX \SOH(\EOTH\NULR\SOstreamPosition\DC25\n\
      \\tno_stream\CAN\ETX \SOH(\v2\SYN.google.protobuf.EmptyH\NULR\bnoStream\DC2*\n\
      \\ETXany\CAN\EOT \SOH(\v2\SYN.google.protobuf.EmptyH\NULR\ETXany\DC2=\n\
      \\rstream_exists\CAN\ENQ \SOH(\v2\SYN.google.protobuf.EmptyH\NULR\fstreamExists\DC2E\n\
      \\DLEdeadline_21_10_0\CAN\ACK \SOH(\v2\SUB.google.protobuf.TimestampH\SOHR\rdeadline21100\DC27\n\
      \\bdeadline\CAN\a \SOH(\v2\EM.google.protobuf.DurationH\SOHR\bdeadlineB\SUB\n\
      \\CANexpected_stream_positionB\DC1\n\
      \\SIdeadline_option"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        streamIdentifier__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stream_identifier"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.StreamIdentifier)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'streamIdentifier")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendReq'Options
        streamPosition__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stream_position"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'streamPosition")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendReq'Options
        noStream__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "no_stream"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Google.Protobuf.Empty.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'noStream")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendReq'Options
        any__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "any"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Google.Protobuf.Empty.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'any")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendReq'Options
        streamExists__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stream_exists"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Google.Protobuf.Empty.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'streamExists")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendReq'Options
        deadline21100__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "deadline_21_10_0"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Google.Protobuf.Timestamp.Timestamp)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'deadline21100")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendReq'Options
        deadline__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "deadline"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Google.Protobuf.Duration.Duration)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'deadline")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendReq'Options
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, streamIdentifier__field_descriptor),
           (Data.ProtoLens.Tag 2, streamPosition__field_descriptor),
           (Data.ProtoLens.Tag 3, noStream__field_descriptor),
           (Data.ProtoLens.Tag 4, any__field_descriptor),
           (Data.ProtoLens.Tag 5, streamExists__field_descriptor),
           (Data.ProtoLens.Tag 6, deadline21100__field_descriptor),
           (Data.ProtoLens.Tag 7, deadline__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _BatchAppendReq'Options'_unknownFields
        (\ x__ y__ -> x__ {_BatchAppendReq'Options'_unknownFields = y__})
  defMessage
    = BatchAppendReq'Options'_constructor
        {_BatchAppendReq'Options'streamIdentifier = Prelude.Nothing,
         _BatchAppendReq'Options'expectedStreamPosition = Prelude.Nothing,
         _BatchAppendReq'Options'deadlineOption = Prelude.Nothing,
         _BatchAppendReq'Options'_unknownFields = []}
  parseMessage
    = let
        loop ::
          BatchAppendReq'Options
          -> Data.ProtoLens.Encoding.Bytes.Parser BatchAppendReq'Options
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
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "stream_position"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"streamPosition") y x)
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "no_stream"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"noStream") y x)
                        34
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "any"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"any") y x)
                        42
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "stream_exists"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"streamExists") y x)
                        50
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "deadline_21_10_0"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"deadline21100") y x)
                        58
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "deadline"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"deadline") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Options"
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
             ((Data.Monoid.<>)
                (case
                     Lens.Family2.view
                       (Data.ProtoLens.Field.field @"maybe'expectedStreamPosition") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just (BatchAppendReq'Options'StreamPosition v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt v)
                   (Prelude.Just (BatchAppendReq'Options'NoStream v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage v)
                   (Prelude.Just (BatchAppendReq'Options'Any v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 34)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage v)
                   (Prelude.Just (BatchAppendReq'Options'StreamExists v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 42)
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
                          (Data.ProtoLens.Field.field @"maybe'deadlineOption") _x
                    of
                      Prelude.Nothing -> Data.Monoid.mempty
                      (Prelude.Just (BatchAppendReq'Options'Deadline21100 v))
                        -> (Data.Monoid.<>)
                             (Data.ProtoLens.Encoding.Bytes.putVarInt 50)
                             ((Prelude..)
                                (\ bs
                                   -> (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt
                                           (Prelude.fromIntegral (Data.ByteString.length bs)))
                                        (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                Data.ProtoLens.encodeMessage v)
                      (Prelude.Just (BatchAppendReq'Options'Deadline v))
                        -> (Data.Monoid.<>)
                             (Data.ProtoLens.Encoding.Bytes.putVarInt 58)
                             ((Prelude..)
                                (\ bs
                                   -> (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt
                                           (Prelude.fromIntegral (Data.ByteString.length bs)))
                                        (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                Data.ProtoLens.encodeMessage v))
                   (Data.ProtoLens.Encoding.Wire.buildFieldSet
                      (Lens.Family2.view Data.ProtoLens.unknownFields _x))))
instance Control.DeepSeq.NFData BatchAppendReq'Options where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_BatchAppendReq'Options'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_BatchAppendReq'Options'streamIdentifier x__)
                (Control.DeepSeq.deepseq
                   (_BatchAppendReq'Options'expectedStreamPosition x__)
                   (Control.DeepSeq.deepseq
                      (_BatchAppendReq'Options'deadlineOption x__) ())))
instance Control.DeepSeq.NFData BatchAppendReq'Options'ExpectedStreamPosition where
  rnf (BatchAppendReq'Options'StreamPosition x__)
    = Control.DeepSeq.rnf x__
  rnf (BatchAppendReq'Options'NoStream x__) = Control.DeepSeq.rnf x__
  rnf (BatchAppendReq'Options'Any x__) = Control.DeepSeq.rnf x__
  rnf (BatchAppendReq'Options'StreamExists x__)
    = Control.DeepSeq.rnf x__
instance Control.DeepSeq.NFData BatchAppendReq'Options'DeadlineOption where
  rnf (BatchAppendReq'Options'Deadline21100 x__)
    = Control.DeepSeq.rnf x__
  rnf (BatchAppendReq'Options'Deadline x__) = Control.DeepSeq.rnf x__
_BatchAppendReq'Options'StreamPosition ::
  Data.ProtoLens.Prism.Prism' BatchAppendReq'Options'ExpectedStreamPosition Data.Word.Word64
_BatchAppendReq'Options'StreamPosition
  = Data.ProtoLens.Prism.prism'
      BatchAppendReq'Options'StreamPosition
      (\ p__
         -> case p__ of
              (BatchAppendReq'Options'StreamPosition p__val)
                -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_BatchAppendReq'Options'NoStream ::
  Data.ProtoLens.Prism.Prism' BatchAppendReq'Options'ExpectedStreamPosition Proto.Google.Protobuf.Empty.Empty
_BatchAppendReq'Options'NoStream
  = Data.ProtoLens.Prism.prism'
      BatchAppendReq'Options'NoStream
      (\ p__
         -> case p__ of
              (BatchAppendReq'Options'NoStream p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_BatchAppendReq'Options'Any ::
  Data.ProtoLens.Prism.Prism' BatchAppendReq'Options'ExpectedStreamPosition Proto.Google.Protobuf.Empty.Empty
_BatchAppendReq'Options'Any
  = Data.ProtoLens.Prism.prism'
      BatchAppendReq'Options'Any
      (\ p__
         -> case p__ of
              (BatchAppendReq'Options'Any p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_BatchAppendReq'Options'StreamExists ::
  Data.ProtoLens.Prism.Prism' BatchAppendReq'Options'ExpectedStreamPosition Proto.Google.Protobuf.Empty.Empty
_BatchAppendReq'Options'StreamExists
  = Data.ProtoLens.Prism.prism'
      BatchAppendReq'Options'StreamExists
      (\ p__
         -> case p__ of
              (BatchAppendReq'Options'StreamExists p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_BatchAppendReq'Options'Deadline21100 ::
  Data.ProtoLens.Prism.Prism' BatchAppendReq'Options'DeadlineOption Proto.Google.Protobuf.Timestamp.Timestamp
_BatchAppendReq'Options'Deadline21100
  = Data.ProtoLens.Prism.prism'
      BatchAppendReq'Options'Deadline21100
      (\ p__
         -> case p__ of
              (BatchAppendReq'Options'Deadline21100 p__val)
                -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_BatchAppendReq'Options'Deadline ::
  Data.ProtoLens.Prism.Prism' BatchAppendReq'Options'DeadlineOption Proto.Google.Protobuf.Duration.Duration
_BatchAppendReq'Options'Deadline
  = Data.ProtoLens.Prism.prism'
      BatchAppendReq'Options'Deadline
      (\ p__
         -> case p__ of
              (BatchAppendReq'Options'Deadline p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.Streams_Fields.id' @:: Lens' BatchAppendReq'ProposedMessage Proto.Shared.UUID@
         * 'Proto.Streams_Fields.maybe'id' @:: Lens' BatchAppendReq'ProposedMessage (Prelude.Maybe Proto.Shared.UUID)@
         * 'Proto.Streams_Fields.metadata' @:: Lens' BatchAppendReq'ProposedMessage (Data.Map.Map Data.Text.Text Data.Text.Text)@
         * 'Proto.Streams_Fields.customMetadata' @:: Lens' BatchAppendReq'ProposedMessage Data.ByteString.ByteString@
         * 'Proto.Streams_Fields.data'' @:: Lens' BatchAppendReq'ProposedMessage Data.ByteString.ByteString@ -}
data BatchAppendReq'ProposedMessage
  = BatchAppendReq'ProposedMessage'_constructor {_BatchAppendReq'ProposedMessage'id :: !(Prelude.Maybe Proto.Shared.UUID),
                                                 _BatchAppendReq'ProposedMessage'metadata :: !(Data.Map.Map Data.Text.Text Data.Text.Text),
                                                 _BatchAppendReq'ProposedMessage'customMetadata :: !Data.ByteString.ByteString,
                                                 _BatchAppendReq'ProposedMessage'data' :: !Data.ByteString.ByteString,
                                                 _BatchAppendReq'ProposedMessage'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show BatchAppendReq'ProposedMessage where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField BatchAppendReq'ProposedMessage "id" Proto.Shared.UUID where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'ProposedMessage'id
           (\ x__ y__ -> x__ {_BatchAppendReq'ProposedMessage'id = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField BatchAppendReq'ProposedMessage "maybe'id" (Prelude.Maybe Proto.Shared.UUID) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'ProposedMessage'id
           (\ x__ y__ -> x__ {_BatchAppendReq'ProposedMessage'id = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField BatchAppendReq'ProposedMessage "metadata" (Data.Map.Map Data.Text.Text Data.Text.Text) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'ProposedMessage'metadata
           (\ x__ y__
              -> x__ {_BatchAppendReq'ProposedMessage'metadata = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField BatchAppendReq'ProposedMessage "customMetadata" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'ProposedMessage'customMetadata
           (\ x__ y__
              -> x__ {_BatchAppendReq'ProposedMessage'customMetadata = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField BatchAppendReq'ProposedMessage "data'" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'ProposedMessage'data'
           (\ x__ y__ -> x__ {_BatchAppendReq'ProposedMessage'data' = y__}))
        Prelude.id
instance Data.ProtoLens.Message BatchAppendReq'ProposedMessage where
  messageName _
    = Data.Text.pack
        "event_store.client.streams.BatchAppendReq.ProposedMessage"
  packedMessageDescriptor _
    = "\n\
      \\SIProposedMessage\DC2(\n\
      \\STXid\CAN\SOH \SOH(\v2\CAN.event_store.client.UUIDR\STXid\DC2d\n\
      \\bmetadata\CAN\STX \ETX(\v2H.event_store.client.streams.BatchAppendReq.ProposedMessage.MetadataEntryR\bmetadata\DC2'\n\
      \\SIcustom_metadata\CAN\ETX \SOH(\fR\SOcustomMetadata\DC2\DC2\n\
      \\EOTdata\CAN\EOT \SOH(\fR\EOTdata\SUB;\n\
      \\rMetadataEntry\DC2\DLE\n\
      \\ETXkey\CAN\SOH \SOH(\tR\ETXkey\DC2\DC4\n\
      \\ENQvalue\CAN\STX \SOH(\tR\ENQvalue:\STX8\SOH"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        id__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "id"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.UUID)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'id")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendReq'ProposedMessage
        metadata__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "metadata"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor BatchAppendReq'ProposedMessage'MetadataEntry)
              (Data.ProtoLens.MapField
                 (Data.ProtoLens.Field.field @"key")
                 (Data.ProtoLens.Field.field @"value")
                 (Data.ProtoLens.Field.field @"metadata")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendReq'ProposedMessage
        customMetadata__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "custom_metadata"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"customMetadata")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendReq'ProposedMessage
        data'__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "data"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"data'")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendReq'ProposedMessage
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, id__field_descriptor),
           (Data.ProtoLens.Tag 2, metadata__field_descriptor),
           (Data.ProtoLens.Tag 3, customMetadata__field_descriptor),
           (Data.ProtoLens.Tag 4, data'__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _BatchAppendReq'ProposedMessage'_unknownFields
        (\ x__ y__
           -> x__ {_BatchAppendReq'ProposedMessage'_unknownFields = y__})
  defMessage
    = BatchAppendReq'ProposedMessage'_constructor
        {_BatchAppendReq'ProposedMessage'id = Prelude.Nothing,
         _BatchAppendReq'ProposedMessage'metadata = Data.Map.empty,
         _BatchAppendReq'ProposedMessage'customMetadata = Data.ProtoLens.fieldDefault,
         _BatchAppendReq'ProposedMessage'data' = Data.ProtoLens.fieldDefault,
         _BatchAppendReq'ProposedMessage'_unknownFields = []}
  parseMessage
    = let
        loop ::
          BatchAppendReq'ProposedMessage
          -> Data.ProtoLens.Encoding.Bytes.Parser BatchAppendReq'ProposedMessage
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
                                       "id"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"id") y x)
                        18
                          -> do !(entry :: BatchAppendReq'ProposedMessage'MetadataEntry) <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                                                                              (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                                                                                  Data.ProtoLens.Encoding.Bytes.isolate
                                                                                                    (Prelude.fromIntegral
                                                                                                       len)
                                                                                                    Data.ProtoLens.parseMessage)
                                                                                              "metadata"
                                (let
                                   key = Lens.Family2.view (Data.ProtoLens.Field.field @"key") entry
                                   value
                                     = Lens.Family2.view (Data.ProtoLens.Field.field @"value") entry
                                 in
                                   loop
                                     (Lens.Family2.over
                                        (Data.ProtoLens.Field.field @"metadata")
                                        (\ !t -> Data.Map.insert key value t) x))
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "custom_metadata"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"customMetadata") y x)
                        34
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "data"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"data'") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "ProposedMessage"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'id") _x
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
             ((Data.Monoid.<>)
                (Data.Monoid.mconcat
                   (Prelude.map
                      (\ _v
                         -> (Data.Monoid.<>)
                              (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                              ((Prelude..)
                                 (\ bs
                                    -> (Data.Monoid.<>)
                                         (Data.ProtoLens.Encoding.Bytes.putVarInt
                                            (Prelude.fromIntegral (Data.ByteString.length bs)))
                                         (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                 Data.ProtoLens.encodeMessage
                                 (Lens.Family2.set
                                    (Data.ProtoLens.Field.field @"key") (Prelude.fst _v)
                                    (Lens.Family2.set
                                       (Data.ProtoLens.Field.field @"value") (Prelude.snd _v)
                                       (Data.ProtoLens.defMessage ::
                                          BatchAppendReq'ProposedMessage'MetadataEntry)))))
                      (Data.Map.toList
                         (Lens.Family2.view (Data.ProtoLens.Field.field @"metadata") _x))))
                ((Data.Monoid.<>)
                   (let
                      _v
                        = Lens.Family2.view
                            (Data.ProtoLens.Field.field @"customMetadata") _x
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
                   ((Data.Monoid.<>)
                      (let
                         _v = Lens.Family2.view (Data.ProtoLens.Field.field @"data'") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 34)
                               ((\ bs
                                   -> (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt
                                           (Prelude.fromIntegral (Data.ByteString.length bs)))
                                        (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                  _v))
                      (Data.ProtoLens.Encoding.Wire.buildFieldSet
                         (Lens.Family2.view Data.ProtoLens.unknownFields _x)))))
instance Control.DeepSeq.NFData BatchAppendReq'ProposedMessage where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_BatchAppendReq'ProposedMessage'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_BatchAppendReq'ProposedMessage'id x__)
                (Control.DeepSeq.deepseq
                   (_BatchAppendReq'ProposedMessage'metadata x__)
                   (Control.DeepSeq.deepseq
                      (_BatchAppendReq'ProposedMessage'customMetadata x__)
                      (Control.DeepSeq.deepseq
                         (_BatchAppendReq'ProposedMessage'data' x__) ()))))
{- | Fields :
     
         * 'Proto.Streams_Fields.key' @:: Lens' BatchAppendReq'ProposedMessage'MetadataEntry Data.Text.Text@
         * 'Proto.Streams_Fields.value' @:: Lens' BatchAppendReq'ProposedMessage'MetadataEntry Data.Text.Text@ -}
data BatchAppendReq'ProposedMessage'MetadataEntry
  = BatchAppendReq'ProposedMessage'MetadataEntry'_constructor {_BatchAppendReq'ProposedMessage'MetadataEntry'key :: !Data.Text.Text,
                                                               _BatchAppendReq'ProposedMessage'MetadataEntry'value :: !Data.Text.Text,
                                                               _BatchAppendReq'ProposedMessage'MetadataEntry'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show BatchAppendReq'ProposedMessage'MetadataEntry where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField BatchAppendReq'ProposedMessage'MetadataEntry "key" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'ProposedMessage'MetadataEntry'key
           (\ x__ y__
              -> x__ {_BatchAppendReq'ProposedMessage'MetadataEntry'key = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField BatchAppendReq'ProposedMessage'MetadataEntry "value" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendReq'ProposedMessage'MetadataEntry'value
           (\ x__ y__
              -> x__
                   {_BatchAppendReq'ProposedMessage'MetadataEntry'value = y__}))
        Prelude.id
instance Data.ProtoLens.Message BatchAppendReq'ProposedMessage'MetadataEntry where
  messageName _
    = Data.Text.pack
        "event_store.client.streams.BatchAppendReq.ProposedMessage.MetadataEntry"
  packedMessageDescriptor _
    = "\n\
      \\rMetadataEntry\DC2\DLE\n\
      \\ETXkey\CAN\SOH \SOH(\tR\ETXkey\DC2\DC4\n\
      \\ENQvalue\CAN\STX \SOH(\tR\ENQvalue:\STX8\SOH"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        key__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "key"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"key")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendReq'ProposedMessage'MetadataEntry
        value__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "value"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"value")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendReq'ProposedMessage'MetadataEntry
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, key__field_descriptor),
           (Data.ProtoLens.Tag 2, value__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _BatchAppendReq'ProposedMessage'MetadataEntry'_unknownFields
        (\ x__ y__
           -> x__
                {_BatchAppendReq'ProposedMessage'MetadataEntry'_unknownFields = y__})
  defMessage
    = BatchAppendReq'ProposedMessage'MetadataEntry'_constructor
        {_BatchAppendReq'ProposedMessage'MetadataEntry'key = Data.ProtoLens.fieldDefault,
         _BatchAppendReq'ProposedMessage'MetadataEntry'value = Data.ProtoLens.fieldDefault,
         _BatchAppendReq'ProposedMessage'MetadataEntry'_unknownFields = []}
  parseMessage
    = let
        loop ::
          BatchAppendReq'ProposedMessage'MetadataEntry
          -> Data.ProtoLens.Encoding.Bytes.Parser BatchAppendReq'ProposedMessage'MetadataEntry
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
                                       "key"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"key") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getText
                                             (Prelude.fromIntegral len))
                                       "value"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"value") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "MetadataEntry"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"key") _x
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
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"value") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                         ((Prelude..)
                            (\ bs
                               -> (Data.Monoid.<>)
                                    (Data.ProtoLens.Encoding.Bytes.putVarInt
                                       (Prelude.fromIntegral (Data.ByteString.length bs)))
                                    (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                            Data.Text.Encoding.encodeUtf8 _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData BatchAppendReq'ProposedMessage'MetadataEntry where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_BatchAppendReq'ProposedMessage'MetadataEntry'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_BatchAppendReq'ProposedMessage'MetadataEntry'key x__)
                (Control.DeepSeq.deepseq
                   (_BatchAppendReq'ProposedMessage'MetadataEntry'value x__) ()))
{- | Fields :
     
         * 'Proto.Streams_Fields.correlationId' @:: Lens' BatchAppendResp Proto.Shared.UUID@
         * 'Proto.Streams_Fields.maybe'correlationId' @:: Lens' BatchAppendResp (Prelude.Maybe Proto.Shared.UUID)@
         * 'Proto.Streams_Fields.streamIdentifier' @:: Lens' BatchAppendResp Proto.Shared.StreamIdentifier@
         * 'Proto.Streams_Fields.maybe'streamIdentifier' @:: Lens' BatchAppendResp (Prelude.Maybe Proto.Shared.StreamIdentifier)@
         * 'Proto.Streams_Fields.maybe'result' @:: Lens' BatchAppendResp (Prelude.Maybe BatchAppendResp'Result)@
         * 'Proto.Streams_Fields.maybe'error' @:: Lens' BatchAppendResp (Prelude.Maybe Proto.Status.Status)@
         * 'Proto.Streams_Fields.error' @:: Lens' BatchAppendResp Proto.Status.Status@
         * 'Proto.Streams_Fields.maybe'success' @:: Lens' BatchAppendResp (Prelude.Maybe BatchAppendResp'Success)@
         * 'Proto.Streams_Fields.success' @:: Lens' BatchAppendResp BatchAppendResp'Success@
         * 'Proto.Streams_Fields.maybe'expectedStreamPosition' @:: Lens' BatchAppendResp (Prelude.Maybe BatchAppendResp'ExpectedStreamPosition)@
         * 'Proto.Streams_Fields.maybe'streamPosition' @:: Lens' BatchAppendResp (Prelude.Maybe Data.Word.Word64)@
         * 'Proto.Streams_Fields.streamPosition' @:: Lens' BatchAppendResp Data.Word.Word64@
         * 'Proto.Streams_Fields.maybe'noStream' @:: Lens' BatchAppendResp (Prelude.Maybe Proto.Google.Protobuf.Empty.Empty)@
         * 'Proto.Streams_Fields.noStream' @:: Lens' BatchAppendResp Proto.Google.Protobuf.Empty.Empty@
         * 'Proto.Streams_Fields.maybe'any' @:: Lens' BatchAppendResp (Prelude.Maybe Proto.Google.Protobuf.Empty.Empty)@
         * 'Proto.Streams_Fields.any' @:: Lens' BatchAppendResp Proto.Google.Protobuf.Empty.Empty@
         * 'Proto.Streams_Fields.maybe'streamExists' @:: Lens' BatchAppendResp (Prelude.Maybe Proto.Google.Protobuf.Empty.Empty)@
         * 'Proto.Streams_Fields.streamExists' @:: Lens' BatchAppendResp Proto.Google.Protobuf.Empty.Empty@ -}
data BatchAppendResp
  = BatchAppendResp'_constructor {_BatchAppendResp'correlationId :: !(Prelude.Maybe Proto.Shared.UUID),
                                  _BatchAppendResp'streamIdentifier :: !(Prelude.Maybe Proto.Shared.StreamIdentifier),
                                  _BatchAppendResp'result :: !(Prelude.Maybe BatchAppendResp'Result),
                                  _BatchAppendResp'expectedStreamPosition :: !(Prelude.Maybe BatchAppendResp'ExpectedStreamPosition),
                                  _BatchAppendResp'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show BatchAppendResp where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data BatchAppendResp'Result
  = BatchAppendResp'Error !Proto.Status.Status |
    BatchAppendResp'Success' !BatchAppendResp'Success
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
data BatchAppendResp'ExpectedStreamPosition
  = BatchAppendResp'StreamPosition !Data.Word.Word64 |
    BatchAppendResp'NoStream !Proto.Google.Protobuf.Empty.Empty |
    BatchAppendResp'Any !Proto.Google.Protobuf.Empty.Empty |
    BatchAppendResp'StreamExists !Proto.Google.Protobuf.Empty.Empty
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField BatchAppendResp "correlationId" Proto.Shared.UUID where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'correlationId
           (\ x__ y__ -> x__ {_BatchAppendResp'correlationId = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField BatchAppendResp "maybe'correlationId" (Prelude.Maybe Proto.Shared.UUID) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'correlationId
           (\ x__ y__ -> x__ {_BatchAppendResp'correlationId = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField BatchAppendResp "streamIdentifier" Proto.Shared.StreamIdentifier where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'streamIdentifier
           (\ x__ y__ -> x__ {_BatchAppendResp'streamIdentifier = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField BatchAppendResp "maybe'streamIdentifier" (Prelude.Maybe Proto.Shared.StreamIdentifier) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'streamIdentifier
           (\ x__ y__ -> x__ {_BatchAppendResp'streamIdentifier = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField BatchAppendResp "maybe'result" (Prelude.Maybe BatchAppendResp'Result) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'result
           (\ x__ y__ -> x__ {_BatchAppendResp'result = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField BatchAppendResp "maybe'error" (Prelude.Maybe Proto.Status.Status) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'result
           (\ x__ y__ -> x__ {_BatchAppendResp'result = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (BatchAppendResp'Error x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap BatchAppendResp'Error y__))
instance Data.ProtoLens.Field.HasField BatchAppendResp "error" Proto.Status.Status where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'result
           (\ x__ y__ -> x__ {_BatchAppendResp'result = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (BatchAppendResp'Error x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap BatchAppendResp'Error y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField BatchAppendResp "maybe'success" (Prelude.Maybe BatchAppendResp'Success) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'result
           (\ x__ y__ -> x__ {_BatchAppendResp'result = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (BatchAppendResp'Success' x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap BatchAppendResp'Success' y__))
instance Data.ProtoLens.Field.HasField BatchAppendResp "success" BatchAppendResp'Success where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'result
           (\ x__ y__ -> x__ {_BatchAppendResp'result = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (BatchAppendResp'Success' x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap BatchAppendResp'Success' y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField BatchAppendResp "maybe'expectedStreamPosition" (Prelude.Maybe BatchAppendResp'ExpectedStreamPosition) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'expectedStreamPosition
           (\ x__ y__ -> x__ {_BatchAppendResp'expectedStreamPosition = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField BatchAppendResp "maybe'streamPosition" (Prelude.Maybe Data.Word.Word64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'expectedStreamPosition
           (\ x__ y__ -> x__ {_BatchAppendResp'expectedStreamPosition = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (BatchAppendResp'StreamPosition x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap BatchAppendResp'StreamPosition y__))
instance Data.ProtoLens.Field.HasField BatchAppendResp "streamPosition" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'expectedStreamPosition
           (\ x__ y__ -> x__ {_BatchAppendResp'expectedStreamPosition = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (BatchAppendResp'StreamPosition x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap BatchAppendResp'StreamPosition y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Field.HasField BatchAppendResp "maybe'noStream" (Prelude.Maybe Proto.Google.Protobuf.Empty.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'expectedStreamPosition
           (\ x__ y__ -> x__ {_BatchAppendResp'expectedStreamPosition = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (BatchAppendResp'NoStream x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap BatchAppendResp'NoStream y__))
instance Data.ProtoLens.Field.HasField BatchAppendResp "noStream" Proto.Google.Protobuf.Empty.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'expectedStreamPosition
           (\ x__ y__ -> x__ {_BatchAppendResp'expectedStreamPosition = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (BatchAppendResp'NoStream x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap BatchAppendResp'NoStream y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField BatchAppendResp "maybe'any" (Prelude.Maybe Proto.Google.Protobuf.Empty.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'expectedStreamPosition
           (\ x__ y__ -> x__ {_BatchAppendResp'expectedStreamPosition = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (BatchAppendResp'Any x__val)) -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap BatchAppendResp'Any y__))
instance Data.ProtoLens.Field.HasField BatchAppendResp "any" Proto.Google.Protobuf.Empty.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'expectedStreamPosition
           (\ x__ y__ -> x__ {_BatchAppendResp'expectedStreamPosition = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (BatchAppendResp'Any x__val)) -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap BatchAppendResp'Any y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField BatchAppendResp "maybe'streamExists" (Prelude.Maybe Proto.Google.Protobuf.Empty.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'expectedStreamPosition
           (\ x__ y__ -> x__ {_BatchAppendResp'expectedStreamPosition = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (BatchAppendResp'StreamExists x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap BatchAppendResp'StreamExists y__))
instance Data.ProtoLens.Field.HasField BatchAppendResp "streamExists" Proto.Google.Protobuf.Empty.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'expectedStreamPosition
           (\ x__ y__ -> x__ {_BatchAppendResp'expectedStreamPosition = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (BatchAppendResp'StreamExists x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap BatchAppendResp'StreamExists y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message BatchAppendResp where
  messageName _
    = Data.Text.pack "event_store.client.streams.BatchAppendResp"
  packedMessageDescriptor _
    = "\n\
      \\SIBatchAppendResp\DC2?\n\
      \\SOcorrelation_id\CAN\SOH \SOH(\v2\CAN.event_store.client.UUIDR\rcorrelationId\DC2*\n\
      \\ENQerror\CAN\STX \SOH(\v2\DC2.google.rpc.StatusH\NULR\ENQerror\DC2O\n\
      \\asuccess\CAN\ETX \SOH(\v23.event_store.client.streams.BatchAppendResp.SuccessH\NULR\asuccess\DC2Q\n\
      \\DC1stream_identifier\CAN\EOT \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier\DC2)\n\
      \\SIstream_position\CAN\ENQ \SOH(\EOTH\SOHR\SOstreamPosition\DC25\n\
      \\tno_stream\CAN\ACK \SOH(\v2\SYN.google.protobuf.EmptyH\SOHR\bnoStream\DC2*\n\
      \\ETXany\CAN\a \SOH(\v2\SYN.google.protobuf.EmptyH\SOHR\ETXany\DC2=\n\
      \\rstream_exists\CAN\b \SOH(\v2\SYN.google.protobuf.EmptyH\SOHR\fstreamExists\SUB\155\STX\n\
      \\aSuccess\DC2+\n\
      \\DLEcurrent_revision\CAN\SOH \SOH(\EOTH\NULR\SIcurrentRevision\DC25\n\
      \\tno_stream\CAN\STX \SOH(\v2\SYN.google.protobuf.EmptyH\NULR\bnoStream\DC2C\n\
      \\bposition\CAN\ETX \SOH(\v2%.event_store.client.AllStreamPositionH\SOHR\bposition\DC29\n\
      \\vno_position\CAN\EOT \SOH(\v2\SYN.google.protobuf.EmptyH\SOHR\n\
      \noPositionB\EM\n\
      \\ETBcurrent_revision_optionB\DC1\n\
      \\SIposition_optionB\b\n\
      \\ACKresultB\SUB\n\
      \\CANexpected_stream_position"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        correlationId__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "correlation_id"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.UUID)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'correlationId")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendResp
        streamIdentifier__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stream_identifier"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.StreamIdentifier)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'streamIdentifier")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendResp
        error__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "error"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Status.Status)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'error")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendResp
        success__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "success"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor BatchAppendResp'Success)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'success")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendResp
        streamPosition__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stream_position"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'streamPosition")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendResp
        noStream__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "no_stream"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Google.Protobuf.Empty.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'noStream")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendResp
        any__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "any"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Google.Protobuf.Empty.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'any")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendResp
        streamExists__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stream_exists"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Google.Protobuf.Empty.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'streamExists")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendResp
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, correlationId__field_descriptor),
           (Data.ProtoLens.Tag 4, streamIdentifier__field_descriptor),
           (Data.ProtoLens.Tag 2, error__field_descriptor),
           (Data.ProtoLens.Tag 3, success__field_descriptor),
           (Data.ProtoLens.Tag 5, streamPosition__field_descriptor),
           (Data.ProtoLens.Tag 6, noStream__field_descriptor),
           (Data.ProtoLens.Tag 7, any__field_descriptor),
           (Data.ProtoLens.Tag 8, streamExists__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _BatchAppendResp'_unknownFields
        (\ x__ y__ -> x__ {_BatchAppendResp'_unknownFields = y__})
  defMessage
    = BatchAppendResp'_constructor
        {_BatchAppendResp'correlationId = Prelude.Nothing,
         _BatchAppendResp'streamIdentifier = Prelude.Nothing,
         _BatchAppendResp'result = Prelude.Nothing,
         _BatchAppendResp'expectedStreamPosition = Prelude.Nothing,
         _BatchAppendResp'_unknownFields = []}
  parseMessage
    = let
        loop ::
          BatchAppendResp
          -> Data.ProtoLens.Encoding.Bytes.Parser BatchAppendResp
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
                                       "correlation_id"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"correlationId") y x)
                        34
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "stream_identifier"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"streamIdentifier") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "error"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"error") y x)
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "success"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"success") y x)
                        40
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "stream_position"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"streamPosition") y x)
                        50
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "no_stream"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"noStream") y x)
                        58
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "any"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"any") y x)
                        66
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "stream_exists"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"streamExists") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "BatchAppendResp"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view
                    (Data.ProtoLens.Field.field @"maybe'correlationId") _x
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
             ((Data.Monoid.<>)
                (case
                     Lens.Family2.view
                       (Data.ProtoLens.Field.field @"maybe'streamIdentifier") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just _v)
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 34)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage _v))
                ((Data.Monoid.<>)
                   (case
                        Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'result") _x
                    of
                      Prelude.Nothing -> Data.Monoid.mempty
                      (Prelude.Just (BatchAppendResp'Error v))
                        -> (Data.Monoid.<>)
                             (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                             ((Prelude..)
                                (\ bs
                                   -> (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt
                                           (Prelude.fromIntegral (Data.ByteString.length bs)))
                                        (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                Data.ProtoLens.encodeMessage v)
                      (Prelude.Just (BatchAppendResp'Success' v))
                        -> (Data.Monoid.<>)
                             (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
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
                             (Data.ProtoLens.Field.field @"maybe'expectedStreamPosition") _x
                       of
                         Prelude.Nothing -> Data.Monoid.mempty
                         (Prelude.Just (BatchAppendResp'StreamPosition v))
                           -> (Data.Monoid.<>)
                                (Data.ProtoLens.Encoding.Bytes.putVarInt 40)
                                (Data.ProtoLens.Encoding.Bytes.putVarInt v)
                         (Prelude.Just (BatchAppendResp'NoStream v))
                           -> (Data.Monoid.<>)
                                (Data.ProtoLens.Encoding.Bytes.putVarInt 50)
                                ((Prelude..)
                                   (\ bs
                                      -> (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt
                                              (Prelude.fromIntegral (Data.ByteString.length bs)))
                                           (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                   Data.ProtoLens.encodeMessage v)
                         (Prelude.Just (BatchAppendResp'Any v))
                           -> (Data.Monoid.<>)
                                (Data.ProtoLens.Encoding.Bytes.putVarInt 58)
                                ((Prelude..)
                                   (\ bs
                                      -> (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt
                                              (Prelude.fromIntegral (Data.ByteString.length bs)))
                                           (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                   Data.ProtoLens.encodeMessage v)
                         (Prelude.Just (BatchAppendResp'StreamExists v))
                           -> (Data.Monoid.<>)
                                (Data.ProtoLens.Encoding.Bytes.putVarInt 66)
                                ((Prelude..)
                                   (\ bs
                                      -> (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt
                                              (Prelude.fromIntegral (Data.ByteString.length bs)))
                                           (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                   Data.ProtoLens.encodeMessage v))
                      (Data.ProtoLens.Encoding.Wire.buildFieldSet
                         (Lens.Family2.view Data.ProtoLens.unknownFields _x)))))
instance Control.DeepSeq.NFData BatchAppendResp where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_BatchAppendResp'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_BatchAppendResp'correlationId x__)
                (Control.DeepSeq.deepseq
                   (_BatchAppendResp'streamIdentifier x__)
                   (Control.DeepSeq.deepseq
                      (_BatchAppendResp'result x__)
                      (Control.DeepSeq.deepseq
                         (_BatchAppendResp'expectedStreamPosition x__) ()))))
instance Control.DeepSeq.NFData BatchAppendResp'Result where
  rnf (BatchAppendResp'Error x__) = Control.DeepSeq.rnf x__
  rnf (BatchAppendResp'Success' x__) = Control.DeepSeq.rnf x__
instance Control.DeepSeq.NFData BatchAppendResp'ExpectedStreamPosition where
  rnf (BatchAppendResp'StreamPosition x__) = Control.DeepSeq.rnf x__
  rnf (BatchAppendResp'NoStream x__) = Control.DeepSeq.rnf x__
  rnf (BatchAppendResp'Any x__) = Control.DeepSeq.rnf x__
  rnf (BatchAppendResp'StreamExists x__) = Control.DeepSeq.rnf x__
_BatchAppendResp'Error ::
  Data.ProtoLens.Prism.Prism' BatchAppendResp'Result Proto.Status.Status
_BatchAppendResp'Error
  = Data.ProtoLens.Prism.prism'
      BatchAppendResp'Error
      (\ p__
         -> case p__ of
              (BatchAppendResp'Error p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_BatchAppendResp'Success' ::
  Data.ProtoLens.Prism.Prism' BatchAppendResp'Result BatchAppendResp'Success
_BatchAppendResp'Success'
  = Data.ProtoLens.Prism.prism'
      BatchAppendResp'Success'
      (\ p__
         -> case p__ of
              (BatchAppendResp'Success' p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_BatchAppendResp'StreamPosition ::
  Data.ProtoLens.Prism.Prism' BatchAppendResp'ExpectedStreamPosition Data.Word.Word64
_BatchAppendResp'StreamPosition
  = Data.ProtoLens.Prism.prism'
      BatchAppendResp'StreamPosition
      (\ p__
         -> case p__ of
              (BatchAppendResp'StreamPosition p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_BatchAppendResp'NoStream ::
  Data.ProtoLens.Prism.Prism' BatchAppendResp'ExpectedStreamPosition Proto.Google.Protobuf.Empty.Empty
_BatchAppendResp'NoStream
  = Data.ProtoLens.Prism.prism'
      BatchAppendResp'NoStream
      (\ p__
         -> case p__ of
              (BatchAppendResp'NoStream p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_BatchAppendResp'Any ::
  Data.ProtoLens.Prism.Prism' BatchAppendResp'ExpectedStreamPosition Proto.Google.Protobuf.Empty.Empty
_BatchAppendResp'Any
  = Data.ProtoLens.Prism.prism'
      BatchAppendResp'Any
      (\ p__
         -> case p__ of
              (BatchAppendResp'Any p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_BatchAppendResp'StreamExists ::
  Data.ProtoLens.Prism.Prism' BatchAppendResp'ExpectedStreamPosition Proto.Google.Protobuf.Empty.Empty
_BatchAppendResp'StreamExists
  = Data.ProtoLens.Prism.prism'
      BatchAppendResp'StreamExists
      (\ p__
         -> case p__ of
              (BatchAppendResp'StreamExists p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.Streams_Fields.maybe'currentRevisionOption' @:: Lens' BatchAppendResp'Success (Prelude.Maybe BatchAppendResp'Success'CurrentRevisionOption)@
         * 'Proto.Streams_Fields.maybe'currentRevision' @:: Lens' BatchAppendResp'Success (Prelude.Maybe Data.Word.Word64)@
         * 'Proto.Streams_Fields.currentRevision' @:: Lens' BatchAppendResp'Success Data.Word.Word64@
         * 'Proto.Streams_Fields.maybe'noStream' @:: Lens' BatchAppendResp'Success (Prelude.Maybe Proto.Google.Protobuf.Empty.Empty)@
         * 'Proto.Streams_Fields.noStream' @:: Lens' BatchAppendResp'Success Proto.Google.Protobuf.Empty.Empty@
         * 'Proto.Streams_Fields.maybe'positionOption' @:: Lens' BatchAppendResp'Success (Prelude.Maybe BatchAppendResp'Success'PositionOption)@
         * 'Proto.Streams_Fields.maybe'position' @:: Lens' BatchAppendResp'Success (Prelude.Maybe Proto.Shared.AllStreamPosition)@
         * 'Proto.Streams_Fields.position' @:: Lens' BatchAppendResp'Success Proto.Shared.AllStreamPosition@
         * 'Proto.Streams_Fields.maybe'noPosition' @:: Lens' BatchAppendResp'Success (Prelude.Maybe Proto.Google.Protobuf.Empty.Empty)@
         * 'Proto.Streams_Fields.noPosition' @:: Lens' BatchAppendResp'Success Proto.Google.Protobuf.Empty.Empty@ -}
data BatchAppendResp'Success
  = BatchAppendResp'Success'_constructor {_BatchAppendResp'Success'currentRevisionOption :: !(Prelude.Maybe BatchAppendResp'Success'CurrentRevisionOption),
                                          _BatchAppendResp'Success'positionOption :: !(Prelude.Maybe BatchAppendResp'Success'PositionOption),
                                          _BatchAppendResp'Success'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show BatchAppendResp'Success where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data BatchAppendResp'Success'CurrentRevisionOption
  = BatchAppendResp'Success'CurrentRevision !Data.Word.Word64 |
    BatchAppendResp'Success'NoStream !Proto.Google.Protobuf.Empty.Empty
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
data BatchAppendResp'Success'PositionOption
  = BatchAppendResp'Success'Position !Proto.Shared.AllStreamPosition |
    BatchAppendResp'Success'NoPosition !Proto.Google.Protobuf.Empty.Empty
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField BatchAppendResp'Success "maybe'currentRevisionOption" (Prelude.Maybe BatchAppendResp'Success'CurrentRevisionOption) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'Success'currentRevisionOption
           (\ x__ y__
              -> x__ {_BatchAppendResp'Success'currentRevisionOption = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField BatchAppendResp'Success "maybe'currentRevision" (Prelude.Maybe Data.Word.Word64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'Success'currentRevisionOption
           (\ x__ y__
              -> x__ {_BatchAppendResp'Success'currentRevisionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (BatchAppendResp'Success'CurrentRevision x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__
              -> Prelude.fmap BatchAppendResp'Success'CurrentRevision y__))
instance Data.ProtoLens.Field.HasField BatchAppendResp'Success "currentRevision" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'Success'currentRevisionOption
           (\ x__ y__
              -> x__ {_BatchAppendResp'Success'currentRevisionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (BatchAppendResp'Success'CurrentRevision x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__
                 -> Prelude.fmap BatchAppendResp'Success'CurrentRevision y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Field.HasField BatchAppendResp'Success "maybe'noStream" (Prelude.Maybe Proto.Google.Protobuf.Empty.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'Success'currentRevisionOption
           (\ x__ y__
              -> x__ {_BatchAppendResp'Success'currentRevisionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (BatchAppendResp'Success'NoStream x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap BatchAppendResp'Success'NoStream y__))
instance Data.ProtoLens.Field.HasField BatchAppendResp'Success "noStream" Proto.Google.Protobuf.Empty.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'Success'currentRevisionOption
           (\ x__ y__
              -> x__ {_BatchAppendResp'Success'currentRevisionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (BatchAppendResp'Success'NoStream x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap BatchAppendResp'Success'NoStream y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField BatchAppendResp'Success "maybe'positionOption" (Prelude.Maybe BatchAppendResp'Success'PositionOption) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'Success'positionOption
           (\ x__ y__ -> x__ {_BatchAppendResp'Success'positionOption = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField BatchAppendResp'Success "maybe'position" (Prelude.Maybe Proto.Shared.AllStreamPosition) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'Success'positionOption
           (\ x__ y__ -> x__ {_BatchAppendResp'Success'positionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (BatchAppendResp'Success'Position x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap BatchAppendResp'Success'Position y__))
instance Data.ProtoLens.Field.HasField BatchAppendResp'Success "position" Proto.Shared.AllStreamPosition where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'Success'positionOption
           (\ x__ y__ -> x__ {_BatchAppendResp'Success'positionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (BatchAppendResp'Success'Position x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap BatchAppendResp'Success'Position y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField BatchAppendResp'Success "maybe'noPosition" (Prelude.Maybe Proto.Google.Protobuf.Empty.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'Success'positionOption
           (\ x__ y__ -> x__ {_BatchAppendResp'Success'positionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (BatchAppendResp'Success'NoPosition x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap BatchAppendResp'Success'NoPosition y__))
instance Data.ProtoLens.Field.HasField BatchAppendResp'Success "noPosition" Proto.Google.Protobuf.Empty.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BatchAppendResp'Success'positionOption
           (\ x__ y__ -> x__ {_BatchAppendResp'Success'positionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (BatchAppendResp'Success'NoPosition x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap BatchAppendResp'Success'NoPosition y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message BatchAppendResp'Success where
  messageName _
    = Data.Text.pack
        "event_store.client.streams.BatchAppendResp.Success"
  packedMessageDescriptor _
    = "\n\
      \\aSuccess\DC2+\n\
      \\DLEcurrent_revision\CAN\SOH \SOH(\EOTH\NULR\SIcurrentRevision\DC25\n\
      \\tno_stream\CAN\STX \SOH(\v2\SYN.google.protobuf.EmptyH\NULR\bnoStream\DC2C\n\
      \\bposition\CAN\ETX \SOH(\v2%.event_store.client.AllStreamPositionH\SOHR\bposition\DC29\n\
      \\vno_position\CAN\EOT \SOH(\v2\SYN.google.protobuf.EmptyH\SOHR\n\
      \noPositionB\EM\n\
      \\ETBcurrent_revision_optionB\DC1\n\
      \\SIposition_option"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        currentRevision__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "current_revision"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'currentRevision")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendResp'Success
        noStream__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "no_stream"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Google.Protobuf.Empty.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'noStream")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendResp'Success
        position__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "position"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.AllStreamPosition)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'position")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendResp'Success
        noPosition__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "no_position"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Google.Protobuf.Empty.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'noPosition")) ::
              Data.ProtoLens.FieldDescriptor BatchAppendResp'Success
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, currentRevision__field_descriptor),
           (Data.ProtoLens.Tag 2, noStream__field_descriptor),
           (Data.ProtoLens.Tag 3, position__field_descriptor),
           (Data.ProtoLens.Tag 4, noPosition__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _BatchAppendResp'Success'_unknownFields
        (\ x__ y__ -> x__ {_BatchAppendResp'Success'_unknownFields = y__})
  defMessage
    = BatchAppendResp'Success'_constructor
        {_BatchAppendResp'Success'currentRevisionOption = Prelude.Nothing,
         _BatchAppendResp'Success'positionOption = Prelude.Nothing,
         _BatchAppendResp'Success'_unknownFields = []}
  parseMessage
    = let
        loop ::
          BatchAppendResp'Success
          -> Data.ProtoLens.Encoding.Bytes.Parser BatchAppendResp'Success
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
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "current_revision"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"currentRevision") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "no_stream"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"noStream") y x)
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "position"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"position") y x)
                        34
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "no_position"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"noPosition") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Success"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view
                    (Data.ProtoLens.Field.field @"maybe'currentRevisionOption") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just (BatchAppendResp'Success'CurrentRevision v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt v)
                (Prelude.Just (BatchAppendResp'Success'NoStream v))
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
                       (Data.ProtoLens.Field.field @"maybe'positionOption") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just (BatchAppendResp'Success'Position v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage v)
                   (Prelude.Just (BatchAppendResp'Success'NoPosition v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 34)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData BatchAppendResp'Success where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_BatchAppendResp'Success'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_BatchAppendResp'Success'currentRevisionOption x__)
                (Control.DeepSeq.deepseq
                   (_BatchAppendResp'Success'positionOption x__) ()))
instance Control.DeepSeq.NFData BatchAppendResp'Success'CurrentRevisionOption where
  rnf (BatchAppendResp'Success'CurrentRevision x__)
    = Control.DeepSeq.rnf x__
  rnf (BatchAppendResp'Success'NoStream x__)
    = Control.DeepSeq.rnf x__
instance Control.DeepSeq.NFData BatchAppendResp'Success'PositionOption where
  rnf (BatchAppendResp'Success'Position x__)
    = Control.DeepSeq.rnf x__
  rnf (BatchAppendResp'Success'NoPosition x__)
    = Control.DeepSeq.rnf x__
_BatchAppendResp'Success'CurrentRevision ::
  Data.ProtoLens.Prism.Prism' BatchAppendResp'Success'CurrentRevisionOption Data.Word.Word64
_BatchAppendResp'Success'CurrentRevision
  = Data.ProtoLens.Prism.prism'
      BatchAppendResp'Success'CurrentRevision
      (\ p__
         -> case p__ of
              (BatchAppendResp'Success'CurrentRevision p__val)
                -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_BatchAppendResp'Success'NoStream ::
  Data.ProtoLens.Prism.Prism' BatchAppendResp'Success'CurrentRevisionOption Proto.Google.Protobuf.Empty.Empty
_BatchAppendResp'Success'NoStream
  = Data.ProtoLens.Prism.prism'
      BatchAppendResp'Success'NoStream
      (\ p__
         -> case p__ of
              (BatchAppendResp'Success'NoStream p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_BatchAppendResp'Success'Position ::
  Data.ProtoLens.Prism.Prism' BatchAppendResp'Success'PositionOption Proto.Shared.AllStreamPosition
_BatchAppendResp'Success'Position
  = Data.ProtoLens.Prism.prism'
      BatchAppendResp'Success'Position
      (\ p__
         -> case p__ of
              (BatchAppendResp'Success'Position p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_BatchAppendResp'Success'NoPosition ::
  Data.ProtoLens.Prism.Prism' BatchAppendResp'Success'PositionOption Proto.Google.Protobuf.Empty.Empty
_BatchAppendResp'Success'NoPosition
  = Data.ProtoLens.Prism.prism'
      BatchAppendResp'Success'NoPosition
      (\ p__
         -> case p__ of
              (BatchAppendResp'Success'NoPosition p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.Streams_Fields.options' @:: Lens' DeleteReq DeleteReq'Options@
         * 'Proto.Streams_Fields.maybe'options' @:: Lens' DeleteReq (Prelude.Maybe DeleteReq'Options)@ -}
data DeleteReq
  = DeleteReq'_constructor {_DeleteReq'options :: !(Prelude.Maybe DeleteReq'Options),
                            _DeleteReq'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show DeleteReq where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField DeleteReq "options" DeleteReq'Options where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeleteReq'options (\ x__ y__ -> x__ {_DeleteReq'options = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField DeleteReq "maybe'options" (Prelude.Maybe DeleteReq'Options) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeleteReq'options (\ x__ y__ -> x__ {_DeleteReq'options = y__}))
        Prelude.id
instance Data.ProtoLens.Message DeleteReq where
  messageName _
    = Data.Text.pack "event_store.client.streams.DeleteReq"
  packedMessageDescriptor _
    = "\n\
      \\tDeleteReq\DC2G\n\
      \\aoptions\CAN\SOH \SOH(\v2-.event_store.client.streams.DeleteReq.OptionsR\aoptions\SUB\193\STX\n\
      \\aOptions\DC2Q\n\
      \\DC1stream_identifier\CAN\SOH \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier\DC2\FS\n\
      \\brevision\CAN\STX \SOH(\EOTH\NULR\brevision\DC28\n\
      \\tno_stream\CAN\ETX \SOH(\v2\EM.event_store.client.EmptyH\NULR\bnoStream\DC2-\n\
      \\ETXany\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\NULR\ETXany\DC2@\n\
      \\rstream_exists\CAN\ENQ \SOH(\v2\EM.event_store.client.EmptyH\NULR\fstreamExistsB\SUB\n\
      \\CANexpected_stream_revision"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        options__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "options"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor DeleteReq'Options)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'options")) ::
              Data.ProtoLens.FieldDescriptor DeleteReq
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, options__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _DeleteReq'_unknownFields
        (\ x__ y__ -> x__ {_DeleteReq'_unknownFields = y__})
  defMessage
    = DeleteReq'_constructor
        {_DeleteReq'options = Prelude.Nothing,
         _DeleteReq'_unknownFields = []}
  parseMessage
    = let
        loop :: DeleteReq -> Data.ProtoLens.Encoding.Bytes.Parser DeleteReq
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
                                       "options"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"options") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "DeleteReq"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'options") _x
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
instance Control.DeepSeq.NFData DeleteReq where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_DeleteReq'_unknownFields x__)
             (Control.DeepSeq.deepseq (_DeleteReq'options x__) ())
{- | Fields :
     
         * 'Proto.Streams_Fields.streamIdentifier' @:: Lens' DeleteReq'Options Proto.Shared.StreamIdentifier@
         * 'Proto.Streams_Fields.maybe'streamIdentifier' @:: Lens' DeleteReq'Options (Prelude.Maybe Proto.Shared.StreamIdentifier)@
         * 'Proto.Streams_Fields.maybe'expectedStreamRevision' @:: Lens' DeleteReq'Options (Prelude.Maybe DeleteReq'Options'ExpectedStreamRevision)@
         * 'Proto.Streams_Fields.maybe'revision' @:: Lens' DeleteReq'Options (Prelude.Maybe Data.Word.Word64)@
         * 'Proto.Streams_Fields.revision' @:: Lens' DeleteReq'Options Data.Word.Word64@
         * 'Proto.Streams_Fields.maybe'noStream' @:: Lens' DeleteReq'Options (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.noStream' @:: Lens' DeleteReq'Options Proto.Shared.Empty@
         * 'Proto.Streams_Fields.maybe'any' @:: Lens' DeleteReq'Options (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.any' @:: Lens' DeleteReq'Options Proto.Shared.Empty@
         * 'Proto.Streams_Fields.maybe'streamExists' @:: Lens' DeleteReq'Options (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.streamExists' @:: Lens' DeleteReq'Options Proto.Shared.Empty@ -}
data DeleteReq'Options
  = DeleteReq'Options'_constructor {_DeleteReq'Options'streamIdentifier :: !(Prelude.Maybe Proto.Shared.StreamIdentifier),
                                    _DeleteReq'Options'expectedStreamRevision :: !(Prelude.Maybe DeleteReq'Options'ExpectedStreamRevision),
                                    _DeleteReq'Options'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show DeleteReq'Options where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data DeleteReq'Options'ExpectedStreamRevision
  = DeleteReq'Options'Revision !Data.Word.Word64 |
    DeleteReq'Options'NoStream !Proto.Shared.Empty |
    DeleteReq'Options'Any !Proto.Shared.Empty |
    DeleteReq'Options'StreamExists !Proto.Shared.Empty
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField DeleteReq'Options "streamIdentifier" Proto.Shared.StreamIdentifier where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeleteReq'Options'streamIdentifier
           (\ x__ y__ -> x__ {_DeleteReq'Options'streamIdentifier = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField DeleteReq'Options "maybe'streamIdentifier" (Prelude.Maybe Proto.Shared.StreamIdentifier) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeleteReq'Options'streamIdentifier
           (\ x__ y__ -> x__ {_DeleteReq'Options'streamIdentifier = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField DeleteReq'Options "maybe'expectedStreamRevision" (Prelude.Maybe DeleteReq'Options'ExpectedStreamRevision) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeleteReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_DeleteReq'Options'expectedStreamRevision = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField DeleteReq'Options "maybe'revision" (Prelude.Maybe Data.Word.Word64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeleteReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_DeleteReq'Options'expectedStreamRevision = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (DeleteReq'Options'Revision x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap DeleteReq'Options'Revision y__))
instance Data.ProtoLens.Field.HasField DeleteReq'Options "revision" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeleteReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_DeleteReq'Options'expectedStreamRevision = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (DeleteReq'Options'Revision x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap DeleteReq'Options'Revision y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Field.HasField DeleteReq'Options "maybe'noStream" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeleteReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_DeleteReq'Options'expectedStreamRevision = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (DeleteReq'Options'NoStream x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap DeleteReq'Options'NoStream y__))
instance Data.ProtoLens.Field.HasField DeleteReq'Options "noStream" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeleteReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_DeleteReq'Options'expectedStreamRevision = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (DeleteReq'Options'NoStream x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap DeleteReq'Options'NoStream y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField DeleteReq'Options "maybe'any" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeleteReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_DeleteReq'Options'expectedStreamRevision = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (DeleteReq'Options'Any x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap DeleteReq'Options'Any y__))
instance Data.ProtoLens.Field.HasField DeleteReq'Options "any" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeleteReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_DeleteReq'Options'expectedStreamRevision = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (DeleteReq'Options'Any x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap DeleteReq'Options'Any y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField DeleteReq'Options "maybe'streamExists" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeleteReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_DeleteReq'Options'expectedStreamRevision = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (DeleteReq'Options'StreamExists x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap DeleteReq'Options'StreamExists y__))
instance Data.ProtoLens.Field.HasField DeleteReq'Options "streamExists" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeleteReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_DeleteReq'Options'expectedStreamRevision = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (DeleteReq'Options'StreamExists x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap DeleteReq'Options'StreamExists y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message DeleteReq'Options where
  messageName _
    = Data.Text.pack "event_store.client.streams.DeleteReq.Options"
  packedMessageDescriptor _
    = "\n\
      \\aOptions\DC2Q\n\
      \\DC1stream_identifier\CAN\SOH \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier\DC2\FS\n\
      \\brevision\CAN\STX \SOH(\EOTH\NULR\brevision\DC28\n\
      \\tno_stream\CAN\ETX \SOH(\v2\EM.event_store.client.EmptyH\NULR\bnoStream\DC2-\n\
      \\ETXany\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\NULR\ETXany\DC2@\n\
      \\rstream_exists\CAN\ENQ \SOH(\v2\EM.event_store.client.EmptyH\NULR\fstreamExistsB\SUB\n\
      \\CANexpected_stream_revision"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        streamIdentifier__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stream_identifier"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.StreamIdentifier)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'streamIdentifier")) ::
              Data.ProtoLens.FieldDescriptor DeleteReq'Options
        revision__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "revision"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'revision")) ::
              Data.ProtoLens.FieldDescriptor DeleteReq'Options
        noStream__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "no_stream"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'noStream")) ::
              Data.ProtoLens.FieldDescriptor DeleteReq'Options
        any__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "any"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'any")) ::
              Data.ProtoLens.FieldDescriptor DeleteReq'Options
        streamExists__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stream_exists"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'streamExists")) ::
              Data.ProtoLens.FieldDescriptor DeleteReq'Options
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, streamIdentifier__field_descriptor),
           (Data.ProtoLens.Tag 2, revision__field_descriptor),
           (Data.ProtoLens.Tag 3, noStream__field_descriptor),
           (Data.ProtoLens.Tag 4, any__field_descriptor),
           (Data.ProtoLens.Tag 5, streamExists__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _DeleteReq'Options'_unknownFields
        (\ x__ y__ -> x__ {_DeleteReq'Options'_unknownFields = y__})
  defMessage
    = DeleteReq'Options'_constructor
        {_DeleteReq'Options'streamIdentifier = Prelude.Nothing,
         _DeleteReq'Options'expectedStreamRevision = Prelude.Nothing,
         _DeleteReq'Options'_unknownFields = []}
  parseMessage
    = let
        loop ::
          DeleteReq'Options
          -> Data.ProtoLens.Encoding.Bytes.Parser DeleteReq'Options
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
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "revision"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"revision") y x)
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "no_stream"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"noStream") y x)
                        34
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "any"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"any") y x)
                        42
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "stream_exists"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"streamExists") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Options"
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
             ((Data.Monoid.<>)
                (case
                     Lens.Family2.view
                       (Data.ProtoLens.Field.field @"maybe'expectedStreamRevision") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just (DeleteReq'Options'Revision v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt v)
                   (Prelude.Just (DeleteReq'Options'NoStream v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage v)
                   (Prelude.Just (DeleteReq'Options'Any v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 34)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage v)
                   (Prelude.Just (DeleteReq'Options'StreamExists v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 42)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData DeleteReq'Options where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_DeleteReq'Options'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_DeleteReq'Options'streamIdentifier x__)
                (Control.DeepSeq.deepseq
                   (_DeleteReq'Options'expectedStreamRevision x__) ()))
instance Control.DeepSeq.NFData DeleteReq'Options'ExpectedStreamRevision where
  rnf (DeleteReq'Options'Revision x__) = Control.DeepSeq.rnf x__
  rnf (DeleteReq'Options'NoStream x__) = Control.DeepSeq.rnf x__
  rnf (DeleteReq'Options'Any x__) = Control.DeepSeq.rnf x__
  rnf (DeleteReq'Options'StreamExists x__) = Control.DeepSeq.rnf x__
_DeleteReq'Options'Revision ::
  Data.ProtoLens.Prism.Prism' DeleteReq'Options'ExpectedStreamRevision Data.Word.Word64
_DeleteReq'Options'Revision
  = Data.ProtoLens.Prism.prism'
      DeleteReq'Options'Revision
      (\ p__
         -> case p__ of
              (DeleteReq'Options'Revision p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_DeleteReq'Options'NoStream ::
  Data.ProtoLens.Prism.Prism' DeleteReq'Options'ExpectedStreamRevision Proto.Shared.Empty
_DeleteReq'Options'NoStream
  = Data.ProtoLens.Prism.prism'
      DeleteReq'Options'NoStream
      (\ p__
         -> case p__ of
              (DeleteReq'Options'NoStream p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_DeleteReq'Options'Any ::
  Data.ProtoLens.Prism.Prism' DeleteReq'Options'ExpectedStreamRevision Proto.Shared.Empty
_DeleteReq'Options'Any
  = Data.ProtoLens.Prism.prism'
      DeleteReq'Options'Any
      (\ p__
         -> case p__ of
              (DeleteReq'Options'Any p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_DeleteReq'Options'StreamExists ::
  Data.ProtoLens.Prism.Prism' DeleteReq'Options'ExpectedStreamRevision Proto.Shared.Empty
_DeleteReq'Options'StreamExists
  = Data.ProtoLens.Prism.prism'
      DeleteReq'Options'StreamExists
      (\ p__
         -> case p__ of
              (DeleteReq'Options'StreamExists p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.Streams_Fields.maybe'positionOption' @:: Lens' DeleteResp (Prelude.Maybe DeleteResp'PositionOption)@
         * 'Proto.Streams_Fields.maybe'position' @:: Lens' DeleteResp (Prelude.Maybe DeleteResp'Position)@
         * 'Proto.Streams_Fields.position' @:: Lens' DeleteResp DeleteResp'Position@
         * 'Proto.Streams_Fields.maybe'noPosition' @:: Lens' DeleteResp (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.noPosition' @:: Lens' DeleteResp Proto.Shared.Empty@ -}
data DeleteResp
  = DeleteResp'_constructor {_DeleteResp'positionOption :: !(Prelude.Maybe DeleteResp'PositionOption),
                             _DeleteResp'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show DeleteResp where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data DeleteResp'PositionOption
  = DeleteResp'Position' !DeleteResp'Position |
    DeleteResp'NoPosition !Proto.Shared.Empty
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField DeleteResp "maybe'positionOption" (Prelude.Maybe DeleteResp'PositionOption) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeleteResp'positionOption
           (\ x__ y__ -> x__ {_DeleteResp'positionOption = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField DeleteResp "maybe'position" (Prelude.Maybe DeleteResp'Position) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeleteResp'positionOption
           (\ x__ y__ -> x__ {_DeleteResp'positionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (DeleteResp'Position' x__val)) -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap DeleteResp'Position' y__))
instance Data.ProtoLens.Field.HasField DeleteResp "position" DeleteResp'Position where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeleteResp'positionOption
           (\ x__ y__ -> x__ {_DeleteResp'positionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (DeleteResp'Position' x__val)) -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap DeleteResp'Position' y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField DeleteResp "maybe'noPosition" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeleteResp'positionOption
           (\ x__ y__ -> x__ {_DeleteResp'positionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (DeleteResp'NoPosition x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap DeleteResp'NoPosition y__))
instance Data.ProtoLens.Field.HasField DeleteResp "noPosition" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeleteResp'positionOption
           (\ x__ y__ -> x__ {_DeleteResp'positionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (DeleteResp'NoPosition x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap DeleteResp'NoPosition y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message DeleteResp where
  messageName _
    = Data.Text.pack "event_store.client.streams.DeleteResp"
  packedMessageDescriptor _
    = "\n\
      \\n\
      \DeleteResp\DC2M\n\
      \\bposition\CAN\SOH \SOH(\v2/.event_store.client.streams.DeleteResp.PositionH\NULR\bposition\DC2<\n\
      \\vno_position\CAN\STX \SOH(\v2\EM.event_store.client.EmptyH\NULR\n\
      \noPosition\SUB^\n\
      \\bPosition\DC2'\n\
      \\SIcommit_position\CAN\SOH \SOH(\EOTR\SOcommitPosition\DC2)\n\
      \\DLEprepare_position\CAN\STX \SOH(\EOTR\SIpreparePositionB\DC1\n\
      \\SIposition_option"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        position__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "position"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor DeleteResp'Position)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'position")) ::
              Data.ProtoLens.FieldDescriptor DeleteResp
        noPosition__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "no_position"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'noPosition")) ::
              Data.ProtoLens.FieldDescriptor DeleteResp
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, position__field_descriptor),
           (Data.ProtoLens.Tag 2, noPosition__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _DeleteResp'_unknownFields
        (\ x__ y__ -> x__ {_DeleteResp'_unknownFields = y__})
  defMessage
    = DeleteResp'_constructor
        {_DeleteResp'positionOption = Prelude.Nothing,
         _DeleteResp'_unknownFields = []}
  parseMessage
    = let
        loop ::
          DeleteResp -> Data.ProtoLens.Encoding.Bytes.Parser DeleteResp
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
                                       "position"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"position") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "no_position"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"noPosition") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "DeleteResp"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view
                    (Data.ProtoLens.Field.field @"maybe'positionOption") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just (DeleteResp'Position' v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage v)
                (Prelude.Just (DeleteResp'NoPosition v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData DeleteResp where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_DeleteResp'_unknownFields x__)
             (Control.DeepSeq.deepseq (_DeleteResp'positionOption x__) ())
instance Control.DeepSeq.NFData DeleteResp'PositionOption where
  rnf (DeleteResp'Position' x__) = Control.DeepSeq.rnf x__
  rnf (DeleteResp'NoPosition x__) = Control.DeepSeq.rnf x__
_DeleteResp'Position' ::
  Data.ProtoLens.Prism.Prism' DeleteResp'PositionOption DeleteResp'Position
_DeleteResp'Position'
  = Data.ProtoLens.Prism.prism'
      DeleteResp'Position'
      (\ p__
         -> case p__ of
              (DeleteResp'Position' p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_DeleteResp'NoPosition ::
  Data.ProtoLens.Prism.Prism' DeleteResp'PositionOption Proto.Shared.Empty
_DeleteResp'NoPosition
  = Data.ProtoLens.Prism.prism'
      DeleteResp'NoPosition
      (\ p__
         -> case p__ of
              (DeleteResp'NoPosition p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.Streams_Fields.commitPosition' @:: Lens' DeleteResp'Position Data.Word.Word64@
         * 'Proto.Streams_Fields.preparePosition' @:: Lens' DeleteResp'Position Data.Word.Word64@ -}
data DeleteResp'Position
  = DeleteResp'Position'_constructor {_DeleteResp'Position'commitPosition :: !Data.Word.Word64,
                                      _DeleteResp'Position'preparePosition :: !Data.Word.Word64,
                                      _DeleteResp'Position'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show DeleteResp'Position where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField DeleteResp'Position "commitPosition" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeleteResp'Position'commitPosition
           (\ x__ y__ -> x__ {_DeleteResp'Position'commitPosition = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField DeleteResp'Position "preparePosition" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeleteResp'Position'preparePosition
           (\ x__ y__ -> x__ {_DeleteResp'Position'preparePosition = y__}))
        Prelude.id
instance Data.ProtoLens.Message DeleteResp'Position where
  messageName _
    = Data.Text.pack "event_store.client.streams.DeleteResp.Position"
  packedMessageDescriptor _
    = "\n\
      \\bPosition\DC2'\n\
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
              Data.ProtoLens.FieldDescriptor DeleteResp'Position
        preparePosition__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "prepare_position"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"preparePosition")) ::
              Data.ProtoLens.FieldDescriptor DeleteResp'Position
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, commitPosition__field_descriptor),
           (Data.ProtoLens.Tag 2, preparePosition__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _DeleteResp'Position'_unknownFields
        (\ x__ y__ -> x__ {_DeleteResp'Position'_unknownFields = y__})
  defMessage
    = DeleteResp'Position'_constructor
        {_DeleteResp'Position'commitPosition = Data.ProtoLens.fieldDefault,
         _DeleteResp'Position'preparePosition = Data.ProtoLens.fieldDefault,
         _DeleteResp'Position'_unknownFields = []}
  parseMessage
    = let
        loop ::
          DeleteResp'Position
          -> Data.ProtoLens.Encoding.Bytes.Parser DeleteResp'Position
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
          (do loop Data.ProtoLens.defMessage) "Position"
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
instance Control.DeepSeq.NFData DeleteResp'Position where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_DeleteResp'Position'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_DeleteResp'Position'commitPosition x__)
                (Control.DeepSeq.deepseq
                   (_DeleteResp'Position'preparePosition x__) ()))
{- | Fields :
     
         * 'Proto.Streams_Fields.options' @:: Lens' ReadReq ReadReq'Options@
         * 'Proto.Streams_Fields.maybe'options' @:: Lens' ReadReq (Prelude.Maybe ReadReq'Options)@ -}
data ReadReq
  = ReadReq'_constructor {_ReadReq'options :: !(Prelude.Maybe ReadReq'Options),
                          _ReadReq'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ReadReq where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField ReadReq "options" ReadReq'Options where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'options (\ x__ y__ -> x__ {_ReadReq'options = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField ReadReq "maybe'options" (Prelude.Maybe ReadReq'Options) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'options (\ x__ y__ -> x__ {_ReadReq'options = y__}))
        Prelude.id
instance Data.ProtoLens.Message ReadReq where
  messageName _ = Data.Text.pack "event_store.client.streams.ReadReq"
  packedMessageDescriptor _
    = "\n\
      \\aReadReq\DC2E\n\
      \\aoptions\CAN\SOH \SOH(\v2+.event_store.client.streams.ReadReq.OptionsR\aoptions\SUB\168\DLE\n\
      \\aOptions\DC2S\n\
      \\ACKstream\CAN\SOH \SOH(\v29.event_store.client.streams.ReadReq.Options.StreamOptionsH\NULR\ACKstream\DC2J\n\
      \\ETXall\CAN\STX \SOH(\v26.event_store.client.streams.ReadReq.Options.AllOptionsH\NULR\ETXall\DC2`\n\
      \\SOread_direction\CAN\ETX \SOH(\SO29.event_store.client.streams.ReadReq.Options.ReadDirectionR\rreadDirection\DC2#\n\
      \\rresolve_links\CAN\EOT \SOH(\bR\fresolveLinks\DC2\SYN\n\
      \\ENQcount\CAN\ENQ \SOH(\EOTH\SOHR\ENQcount\DC2e\n\
      \\fsubscription\CAN\ACK \SOH(\v2?.event_store.client.streams.ReadReq.Options.SubscriptionOptionsH\SOHR\fsubscription\DC2S\n\
      \\ACKfilter\CAN\a \SOH(\v29.event_store.client.streams.ReadReq.Options.FilterOptionsH\STXR\ACKfilter\DC28\n\
      \\tno_filter\CAN\b \SOH(\v2\EM.event_store.client.EmptyH\STXR\bnoFilter\DC2W\n\
      \\vuuid_option\CAN\t \SOH(\v26.event_store.client.streams.ReadReq.Options.UUIDOptionR\n\
      \uuidOption\DC2`\n\
      \\SOcontrol_option\CAN\n\
      \ \SOH(\v29.event_store.client.streams.ReadReq.Options.ControlOptionR\rcontrolOption\SUB\245\SOH\n\
      \\rStreamOptions\DC2Q\n\
      \\DC1stream_identifier\CAN\SOH \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier\DC2\FS\n\
      \\brevision\CAN\STX \SOH(\EOTH\NULR\brevision\DC21\n\
      \\ENQstart\CAN\ETX \SOH(\v2\EM.event_store.client.EmptyH\NULR\ENQstart\DC2-\n\
      \\ETXend\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\NULR\ETXendB\DC1\n\
      \\SIrevision_option\SUB\208\SOH\n\
      \\n\
      \AllOptions\DC2R\n\
      \\bposition\CAN\SOH \SOH(\v24.event_store.client.streams.ReadReq.Options.PositionH\NULR\bposition\DC21\n\
      \\ENQstart\CAN\STX \SOH(\v2\EM.event_store.client.EmptyH\NULR\ENQstart\DC2-\n\
      \\ETXend\CAN\ETX \SOH(\v2\EM.event_store.client.EmptyH\NULR\ETXendB\f\n\
      \\n\
      \all_option\SUB\NAK\n\
      \\DC3SubscriptionOptions\SUB^\n\
      \\bPosition\DC2'\n\
      \\SIcommit_position\CAN\SOH \SOH(\EOTR\SOcommitPosition\DC2)\n\
      \\DLEprepare_position\CAN\STX \SOH(\EOTR\SIpreparePosition\SUB\198\ETX\n\
      \\rFilterOptions\DC2s\n\
      \\DC1stream_identifier\CAN\SOH \SOH(\v2D.event_store.client.streams.ReadReq.Options.FilterOptions.ExpressionH\NULR\DLEstreamIdentifier\DC2e\n\
      \\n\
      \event_type\CAN\STX \SOH(\v2D.event_store.client.streams.ReadReq.Options.FilterOptions.ExpressionH\NULR\teventType\DC2\DC2\n\
      \\ETXmax\CAN\ETX \SOH(\rH\SOHR\ETXmax\DC21\n\
      \\ENQcount\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\SOHR\ENQcount\DC2B\n\
      \\FScheckpointIntervalMultiplier\CAN\ENQ \SOH(\rR\FScheckpointIntervalMultiplier\SUB:\n\
      \\n\
      \Expression\DC2\DC4\n\
      \\ENQregex\CAN\SOH \SOH(\tR\ENQregex\DC2\SYN\n\
      \\ACKprefix\CAN\STX \ETX(\tR\ACKprefixB\b\n\
      \\ACKfilterB\b\n\
      \\ACKwindow\SUB\137\SOH\n\
      \\n\
      \UUIDOption\DC2;\n\
      \\n\
      \structured\CAN\SOH \SOH(\v2\EM.event_store.client.EmptyH\NULR\n\
      \structured\DC23\n\
      \\ACKstring\CAN\STX \SOH(\v2\EM.event_store.client.EmptyH\NULR\ACKstringB\t\n\
      \\acontent\SUB5\n\
      \\rControlOption\DC2$\n\
      \\rcompatibility\CAN\SOH \SOH(\rR\rcompatibility\",\n\
      \\rReadDirection\DC2\f\n\
      \\bForwards\DLE\NUL\DC2\r\n\
      \\tBackwards\DLE\SOHB\SI\n\
      \\rstream_optionB\SO\n\
      \\fcount_optionB\SI\n\
      \\rfilter_option"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        options__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "options"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ReadReq'Options)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'options")) ::
              Data.ProtoLens.FieldDescriptor ReadReq
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, options__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ReadReq'_unknownFields
        (\ x__ y__ -> x__ {_ReadReq'_unknownFields = y__})
  defMessage
    = ReadReq'_constructor
        {_ReadReq'options = Prelude.Nothing, _ReadReq'_unknownFields = []}
  parseMessage
    = let
        loop :: ReadReq -> Data.ProtoLens.Encoding.Bytes.Parser ReadReq
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
                                       "options"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"options") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "ReadReq"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'options") _x
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
instance Control.DeepSeq.NFData ReadReq where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ReadReq'_unknownFields x__)
             (Control.DeepSeq.deepseq (_ReadReq'options x__) ())
{- | Fields :
     
         * 'Proto.Streams_Fields.readDirection' @:: Lens' ReadReq'Options ReadReq'Options'ReadDirection@
         * 'Proto.Streams_Fields.resolveLinks' @:: Lens' ReadReq'Options Prelude.Bool@
         * 'Proto.Streams_Fields.uuidOption' @:: Lens' ReadReq'Options ReadReq'Options'UUIDOption@
         * 'Proto.Streams_Fields.maybe'uuidOption' @:: Lens' ReadReq'Options (Prelude.Maybe ReadReq'Options'UUIDOption)@
         * 'Proto.Streams_Fields.controlOption' @:: Lens' ReadReq'Options ReadReq'Options'ControlOption@
         * 'Proto.Streams_Fields.maybe'controlOption' @:: Lens' ReadReq'Options (Prelude.Maybe ReadReq'Options'ControlOption)@
         * 'Proto.Streams_Fields.maybe'streamOption' @:: Lens' ReadReq'Options (Prelude.Maybe ReadReq'Options'StreamOption)@
         * 'Proto.Streams_Fields.maybe'stream' @:: Lens' ReadReq'Options (Prelude.Maybe ReadReq'Options'StreamOptions)@
         * 'Proto.Streams_Fields.stream' @:: Lens' ReadReq'Options ReadReq'Options'StreamOptions@
         * 'Proto.Streams_Fields.maybe'all' @:: Lens' ReadReq'Options (Prelude.Maybe ReadReq'Options'AllOptions)@
         * 'Proto.Streams_Fields.all' @:: Lens' ReadReq'Options ReadReq'Options'AllOptions@
         * 'Proto.Streams_Fields.maybe'countOption' @:: Lens' ReadReq'Options (Prelude.Maybe ReadReq'Options'CountOption)@
         * 'Proto.Streams_Fields.maybe'count' @:: Lens' ReadReq'Options (Prelude.Maybe Data.Word.Word64)@
         * 'Proto.Streams_Fields.count' @:: Lens' ReadReq'Options Data.Word.Word64@
         * 'Proto.Streams_Fields.maybe'subscription' @:: Lens' ReadReq'Options (Prelude.Maybe ReadReq'Options'SubscriptionOptions)@
         * 'Proto.Streams_Fields.subscription' @:: Lens' ReadReq'Options ReadReq'Options'SubscriptionOptions@
         * 'Proto.Streams_Fields.maybe'filterOption' @:: Lens' ReadReq'Options (Prelude.Maybe ReadReq'Options'FilterOption)@
         * 'Proto.Streams_Fields.maybe'filter' @:: Lens' ReadReq'Options (Prelude.Maybe ReadReq'Options'FilterOptions)@
         * 'Proto.Streams_Fields.filter' @:: Lens' ReadReq'Options ReadReq'Options'FilterOptions@
         * 'Proto.Streams_Fields.maybe'noFilter' @:: Lens' ReadReq'Options (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.noFilter' @:: Lens' ReadReq'Options Proto.Shared.Empty@ -}
data ReadReq'Options
  = ReadReq'Options'_constructor {_ReadReq'Options'readDirection :: !ReadReq'Options'ReadDirection,
                                  _ReadReq'Options'resolveLinks :: !Prelude.Bool,
                                  _ReadReq'Options'uuidOption :: !(Prelude.Maybe ReadReq'Options'UUIDOption),
                                  _ReadReq'Options'controlOption :: !(Prelude.Maybe ReadReq'Options'ControlOption),
                                  _ReadReq'Options'streamOption :: !(Prelude.Maybe ReadReq'Options'StreamOption),
                                  _ReadReq'Options'countOption :: !(Prelude.Maybe ReadReq'Options'CountOption),
                                  _ReadReq'Options'filterOption :: !(Prelude.Maybe ReadReq'Options'FilterOption),
                                  _ReadReq'Options'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ReadReq'Options where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data ReadReq'Options'StreamOption
  = ReadReq'Options'Stream !ReadReq'Options'StreamOptions |
    ReadReq'Options'All !ReadReq'Options'AllOptions
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
data ReadReq'Options'CountOption
  = ReadReq'Options'Count !Data.Word.Word64 |
    ReadReq'Options'Subscription !ReadReq'Options'SubscriptionOptions
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
data ReadReq'Options'FilterOption
  = ReadReq'Options'Filter !ReadReq'Options'FilterOptions |
    ReadReq'Options'NoFilter !Proto.Shared.Empty
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField ReadReq'Options "readDirection" ReadReq'Options'ReadDirection where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'readDirection
           (\ x__ y__ -> x__ {_ReadReq'Options'readDirection = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadReq'Options "resolveLinks" Prelude.Bool where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'resolveLinks
           (\ x__ y__ -> x__ {_ReadReq'Options'resolveLinks = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadReq'Options "uuidOption" ReadReq'Options'UUIDOption where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'uuidOption
           (\ x__ y__ -> x__ {_ReadReq'Options'uuidOption = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField ReadReq'Options "maybe'uuidOption" (Prelude.Maybe ReadReq'Options'UUIDOption) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'uuidOption
           (\ x__ y__ -> x__ {_ReadReq'Options'uuidOption = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadReq'Options "controlOption" ReadReq'Options'ControlOption where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'controlOption
           (\ x__ y__ -> x__ {_ReadReq'Options'controlOption = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField ReadReq'Options "maybe'controlOption" (Prelude.Maybe ReadReq'Options'ControlOption) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'controlOption
           (\ x__ y__ -> x__ {_ReadReq'Options'controlOption = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadReq'Options "maybe'streamOption" (Prelude.Maybe ReadReq'Options'StreamOption) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'streamOption
           (\ x__ y__ -> x__ {_ReadReq'Options'streamOption = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadReq'Options "maybe'stream" (Prelude.Maybe ReadReq'Options'StreamOptions) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'streamOption
           (\ x__ y__ -> x__ {_ReadReq'Options'streamOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadReq'Options'Stream x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadReq'Options'Stream y__))
instance Data.ProtoLens.Field.HasField ReadReq'Options "stream" ReadReq'Options'StreamOptions where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'streamOption
           (\ x__ y__ -> x__ {_ReadReq'Options'streamOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadReq'Options'Stream x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadReq'Options'Stream y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField ReadReq'Options "maybe'all" (Prelude.Maybe ReadReq'Options'AllOptions) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'streamOption
           (\ x__ y__ -> x__ {_ReadReq'Options'streamOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadReq'Options'All x__val)) -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadReq'Options'All y__))
instance Data.ProtoLens.Field.HasField ReadReq'Options "all" ReadReq'Options'AllOptions where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'streamOption
           (\ x__ y__ -> x__ {_ReadReq'Options'streamOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadReq'Options'All x__val)) -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadReq'Options'All y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField ReadReq'Options "maybe'countOption" (Prelude.Maybe ReadReq'Options'CountOption) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'countOption
           (\ x__ y__ -> x__ {_ReadReq'Options'countOption = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadReq'Options "maybe'count" (Prelude.Maybe Data.Word.Word64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'countOption
           (\ x__ y__ -> x__ {_ReadReq'Options'countOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadReq'Options'Count x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadReq'Options'Count y__))
instance Data.ProtoLens.Field.HasField ReadReq'Options "count" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'countOption
           (\ x__ y__ -> x__ {_ReadReq'Options'countOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadReq'Options'Count x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadReq'Options'Count y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Field.HasField ReadReq'Options "maybe'subscription" (Prelude.Maybe ReadReq'Options'SubscriptionOptions) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'countOption
           (\ x__ y__ -> x__ {_ReadReq'Options'countOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadReq'Options'Subscription x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadReq'Options'Subscription y__))
instance Data.ProtoLens.Field.HasField ReadReq'Options "subscription" ReadReq'Options'SubscriptionOptions where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'countOption
           (\ x__ y__ -> x__ {_ReadReq'Options'countOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadReq'Options'Subscription x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadReq'Options'Subscription y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField ReadReq'Options "maybe'filterOption" (Prelude.Maybe ReadReq'Options'FilterOption) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'filterOption
           (\ x__ y__ -> x__ {_ReadReq'Options'filterOption = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadReq'Options "maybe'filter" (Prelude.Maybe ReadReq'Options'FilterOptions) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'filterOption
           (\ x__ y__ -> x__ {_ReadReq'Options'filterOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadReq'Options'Filter x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadReq'Options'Filter y__))
instance Data.ProtoLens.Field.HasField ReadReq'Options "filter" ReadReq'Options'FilterOptions where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'filterOption
           (\ x__ y__ -> x__ {_ReadReq'Options'filterOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadReq'Options'Filter x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadReq'Options'Filter y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField ReadReq'Options "maybe'noFilter" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'filterOption
           (\ x__ y__ -> x__ {_ReadReq'Options'filterOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadReq'Options'NoFilter x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadReq'Options'NoFilter y__))
instance Data.ProtoLens.Field.HasField ReadReq'Options "noFilter" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'filterOption
           (\ x__ y__ -> x__ {_ReadReq'Options'filterOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadReq'Options'NoFilter x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadReq'Options'NoFilter y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message ReadReq'Options where
  messageName _
    = Data.Text.pack "event_store.client.streams.ReadReq.Options"
  packedMessageDescriptor _
    = "\n\
      \\aOptions\DC2S\n\
      \\ACKstream\CAN\SOH \SOH(\v29.event_store.client.streams.ReadReq.Options.StreamOptionsH\NULR\ACKstream\DC2J\n\
      \\ETXall\CAN\STX \SOH(\v26.event_store.client.streams.ReadReq.Options.AllOptionsH\NULR\ETXall\DC2`\n\
      \\SOread_direction\CAN\ETX \SOH(\SO29.event_store.client.streams.ReadReq.Options.ReadDirectionR\rreadDirection\DC2#\n\
      \\rresolve_links\CAN\EOT \SOH(\bR\fresolveLinks\DC2\SYN\n\
      \\ENQcount\CAN\ENQ \SOH(\EOTH\SOHR\ENQcount\DC2e\n\
      \\fsubscription\CAN\ACK \SOH(\v2?.event_store.client.streams.ReadReq.Options.SubscriptionOptionsH\SOHR\fsubscription\DC2S\n\
      \\ACKfilter\CAN\a \SOH(\v29.event_store.client.streams.ReadReq.Options.FilterOptionsH\STXR\ACKfilter\DC28\n\
      \\tno_filter\CAN\b \SOH(\v2\EM.event_store.client.EmptyH\STXR\bnoFilter\DC2W\n\
      \\vuuid_option\CAN\t \SOH(\v26.event_store.client.streams.ReadReq.Options.UUIDOptionR\n\
      \uuidOption\DC2`\n\
      \\SOcontrol_option\CAN\n\
      \ \SOH(\v29.event_store.client.streams.ReadReq.Options.ControlOptionR\rcontrolOption\SUB\245\SOH\n\
      \\rStreamOptions\DC2Q\n\
      \\DC1stream_identifier\CAN\SOH \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier\DC2\FS\n\
      \\brevision\CAN\STX \SOH(\EOTH\NULR\brevision\DC21\n\
      \\ENQstart\CAN\ETX \SOH(\v2\EM.event_store.client.EmptyH\NULR\ENQstart\DC2-\n\
      \\ETXend\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\NULR\ETXendB\DC1\n\
      \\SIrevision_option\SUB\208\SOH\n\
      \\n\
      \AllOptions\DC2R\n\
      \\bposition\CAN\SOH \SOH(\v24.event_store.client.streams.ReadReq.Options.PositionH\NULR\bposition\DC21\n\
      \\ENQstart\CAN\STX \SOH(\v2\EM.event_store.client.EmptyH\NULR\ENQstart\DC2-\n\
      \\ETXend\CAN\ETX \SOH(\v2\EM.event_store.client.EmptyH\NULR\ETXendB\f\n\
      \\n\
      \all_option\SUB\NAK\n\
      \\DC3SubscriptionOptions\SUB^\n\
      \\bPosition\DC2'\n\
      \\SIcommit_position\CAN\SOH \SOH(\EOTR\SOcommitPosition\DC2)\n\
      \\DLEprepare_position\CAN\STX \SOH(\EOTR\SIpreparePosition\SUB\198\ETX\n\
      \\rFilterOptions\DC2s\n\
      \\DC1stream_identifier\CAN\SOH \SOH(\v2D.event_store.client.streams.ReadReq.Options.FilterOptions.ExpressionH\NULR\DLEstreamIdentifier\DC2e\n\
      \\n\
      \event_type\CAN\STX \SOH(\v2D.event_store.client.streams.ReadReq.Options.FilterOptions.ExpressionH\NULR\teventType\DC2\DC2\n\
      \\ETXmax\CAN\ETX \SOH(\rH\SOHR\ETXmax\DC21\n\
      \\ENQcount\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\SOHR\ENQcount\DC2B\n\
      \\FScheckpointIntervalMultiplier\CAN\ENQ \SOH(\rR\FScheckpointIntervalMultiplier\SUB:\n\
      \\n\
      \Expression\DC2\DC4\n\
      \\ENQregex\CAN\SOH \SOH(\tR\ENQregex\DC2\SYN\n\
      \\ACKprefix\CAN\STX \ETX(\tR\ACKprefixB\b\n\
      \\ACKfilterB\b\n\
      \\ACKwindow\SUB\137\SOH\n\
      \\n\
      \UUIDOption\DC2;\n\
      \\n\
      \structured\CAN\SOH \SOH(\v2\EM.event_store.client.EmptyH\NULR\n\
      \structured\DC23\n\
      \\ACKstring\CAN\STX \SOH(\v2\EM.event_store.client.EmptyH\NULR\ACKstringB\t\n\
      \\acontent\SUB5\n\
      \\rControlOption\DC2$\n\
      \\rcompatibility\CAN\SOH \SOH(\rR\rcompatibility\",\n\
      \\rReadDirection\DC2\f\n\
      \\bForwards\DLE\NUL\DC2\r\n\
      \\tBackwards\DLE\SOHB\SI\n\
      \\rstream_optionB\SO\n\
      \\fcount_optionB\SI\n\
      \\rfilter_option"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        readDirection__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "read_direction"
              (Data.ProtoLens.ScalarField Data.ProtoLens.EnumField ::
                 Data.ProtoLens.FieldTypeDescriptor ReadReq'Options'ReadDirection)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"readDirection")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options
        resolveLinks__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "resolve_links"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BoolField ::
                 Data.ProtoLens.FieldTypeDescriptor Prelude.Bool)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"resolveLinks")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options
        uuidOption__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "uuid_option"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ReadReq'Options'UUIDOption)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'uuidOption")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options
        controlOption__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "control_option"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ReadReq'Options'ControlOption)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'controlOption")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options
        stream__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stream"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ReadReq'Options'StreamOptions)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'stream")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options
        all__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "all"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ReadReq'Options'AllOptions)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'all")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options
        count__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "count"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'count")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options
        subscription__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "subscription"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ReadReq'Options'SubscriptionOptions)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'subscription")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options
        filter__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "filter"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ReadReq'Options'FilterOptions)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'filter")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options
        noFilter__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "no_filter"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'noFilter")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 3, readDirection__field_descriptor),
           (Data.ProtoLens.Tag 4, resolveLinks__field_descriptor),
           (Data.ProtoLens.Tag 9, uuidOption__field_descriptor),
           (Data.ProtoLens.Tag 10, controlOption__field_descriptor),
           (Data.ProtoLens.Tag 1, stream__field_descriptor),
           (Data.ProtoLens.Tag 2, all__field_descriptor),
           (Data.ProtoLens.Tag 5, count__field_descriptor),
           (Data.ProtoLens.Tag 6, subscription__field_descriptor),
           (Data.ProtoLens.Tag 7, filter__field_descriptor),
           (Data.ProtoLens.Tag 8, noFilter__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ReadReq'Options'_unknownFields
        (\ x__ y__ -> x__ {_ReadReq'Options'_unknownFields = y__})
  defMessage
    = ReadReq'Options'_constructor
        {_ReadReq'Options'readDirection = Data.ProtoLens.fieldDefault,
         _ReadReq'Options'resolveLinks = Data.ProtoLens.fieldDefault,
         _ReadReq'Options'uuidOption = Prelude.Nothing,
         _ReadReq'Options'controlOption = Prelude.Nothing,
         _ReadReq'Options'streamOption = Prelude.Nothing,
         _ReadReq'Options'countOption = Prelude.Nothing,
         _ReadReq'Options'filterOption = Prelude.Nothing,
         _ReadReq'Options'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ReadReq'Options
          -> Data.ProtoLens.Encoding.Bytes.Parser ReadReq'Options
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
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.toEnum
                                          (Prelude.fmap
                                             Prelude.fromIntegral
                                             Data.ProtoLens.Encoding.Bytes.getVarInt))
                                       "read_direction"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"readDirection") y x)
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          ((Prelude./=) 0) Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "resolve_links"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"resolveLinks") y x)
                        74
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "uuid_option"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"uuidOption") y x)
                        82
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "control_option"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"controlOption") y x)
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "stream"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"stream") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "all"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"all") y x)
                        40
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "count"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"count") y x)
                        50
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "subscription"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"subscription") y x)
                        58
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "filter"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"filter") y x)
                        66
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "no_filter"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"noFilter") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Options"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view
                      (Data.ProtoLens.Field.field @"readDirection") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                      ((Prelude..)
                         ((Prelude..)
                            Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral)
                         Prelude.fromEnum _v))
             ((Data.Monoid.<>)
                (let
                   _v
                     = Lens.Family2.view (Data.ProtoLens.Field.field @"resolveLinks") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                         ((Prelude..)
                            Data.ProtoLens.Encoding.Bytes.putVarInt (\ b -> if b then 1 else 0)
                            _v))
                ((Data.Monoid.<>)
                   (case
                        Lens.Family2.view
                          (Data.ProtoLens.Field.field @"maybe'uuidOption") _x
                    of
                      Prelude.Nothing -> Data.Monoid.mempty
                      (Prelude.Just _v)
                        -> (Data.Monoid.<>)
                             (Data.ProtoLens.Encoding.Bytes.putVarInt 74)
                             ((Prelude..)
                                (\ bs
                                   -> (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt
                                           (Prelude.fromIntegral (Data.ByteString.length bs)))
                                        (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                Data.ProtoLens.encodeMessage _v))
                   ((Data.Monoid.<>)
                      (case
                           Lens.Family2.view
                             (Data.ProtoLens.Field.field @"maybe'controlOption") _x
                       of
                         Prelude.Nothing -> Data.Monoid.mempty
                         (Prelude.Just _v)
                           -> (Data.Monoid.<>)
                                (Data.ProtoLens.Encoding.Bytes.putVarInt 82)
                                ((Prelude..)
                                   (\ bs
                                      -> (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt
                                              (Prelude.fromIntegral (Data.ByteString.length bs)))
                                           (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                   Data.ProtoLens.encodeMessage _v))
                      ((Data.Monoid.<>)
                         (case
                              Lens.Family2.view
                                (Data.ProtoLens.Field.field @"maybe'streamOption") _x
                          of
                            Prelude.Nothing -> Data.Monoid.mempty
                            (Prelude.Just (ReadReq'Options'Stream v))
                              -> (Data.Monoid.<>)
                                   (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                                   ((Prelude..)
                                      (\ bs
                                         -> (Data.Monoid.<>)
                                              (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                 (Prelude.fromIntegral (Data.ByteString.length bs)))
                                              (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                      Data.ProtoLens.encodeMessage v)
                            (Prelude.Just (ReadReq'Options'All v))
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
                                   (Data.ProtoLens.Field.field @"maybe'countOption") _x
                             of
                               Prelude.Nothing -> Data.Monoid.mempty
                               (Prelude.Just (ReadReq'Options'Count v))
                                 -> (Data.Monoid.<>)
                                      (Data.ProtoLens.Encoding.Bytes.putVarInt 40)
                                      (Data.ProtoLens.Encoding.Bytes.putVarInt v)
                               (Prelude.Just (ReadReq'Options'Subscription v))
                                 -> (Data.Monoid.<>)
                                      (Data.ProtoLens.Encoding.Bytes.putVarInt 50)
                                      ((Prelude..)
                                         (\ bs
                                            -> (Data.Monoid.<>)
                                                 (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                    (Prelude.fromIntegral
                                                       (Data.ByteString.length bs)))
                                                 (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                         Data.ProtoLens.encodeMessage v))
                            ((Data.Monoid.<>)
                               (case
                                    Lens.Family2.view
                                      (Data.ProtoLens.Field.field @"maybe'filterOption") _x
                                of
                                  Prelude.Nothing -> Data.Monoid.mempty
                                  (Prelude.Just (ReadReq'Options'Filter v))
                                    -> (Data.Monoid.<>)
                                         (Data.ProtoLens.Encoding.Bytes.putVarInt 58)
                                         ((Prelude..)
                                            (\ bs
                                               -> (Data.Monoid.<>)
                                                    (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                       (Prelude.fromIntegral
                                                          (Data.ByteString.length bs)))
                                                    (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                            Data.ProtoLens.encodeMessage v)
                                  (Prelude.Just (ReadReq'Options'NoFilter v))
                                    -> (Data.Monoid.<>)
                                         (Data.ProtoLens.Encoding.Bytes.putVarInt 66)
                                         ((Prelude..)
                                            (\ bs
                                               -> (Data.Monoid.<>)
                                                    (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                       (Prelude.fromIntegral
                                                          (Data.ByteString.length bs)))
                                                    (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                            Data.ProtoLens.encodeMessage v))
                               (Data.ProtoLens.Encoding.Wire.buildFieldSet
                                  (Lens.Family2.view Data.ProtoLens.unknownFields _x))))))))
instance Control.DeepSeq.NFData ReadReq'Options where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ReadReq'Options'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ReadReq'Options'readDirection x__)
                (Control.DeepSeq.deepseq
                   (_ReadReq'Options'resolveLinks x__)
                   (Control.DeepSeq.deepseq
                      (_ReadReq'Options'uuidOption x__)
                      (Control.DeepSeq.deepseq
                         (_ReadReq'Options'controlOption x__)
                         (Control.DeepSeq.deepseq
                            (_ReadReq'Options'streamOption x__)
                            (Control.DeepSeq.deepseq
                               (_ReadReq'Options'countOption x__)
                               (Control.DeepSeq.deepseq
                                  (_ReadReq'Options'filterOption x__) ())))))))
instance Control.DeepSeq.NFData ReadReq'Options'StreamOption where
  rnf (ReadReq'Options'Stream x__) = Control.DeepSeq.rnf x__
  rnf (ReadReq'Options'All x__) = Control.DeepSeq.rnf x__
instance Control.DeepSeq.NFData ReadReq'Options'CountOption where
  rnf (ReadReq'Options'Count x__) = Control.DeepSeq.rnf x__
  rnf (ReadReq'Options'Subscription x__) = Control.DeepSeq.rnf x__
instance Control.DeepSeq.NFData ReadReq'Options'FilterOption where
  rnf (ReadReq'Options'Filter x__) = Control.DeepSeq.rnf x__
  rnf (ReadReq'Options'NoFilter x__) = Control.DeepSeq.rnf x__
_ReadReq'Options'Stream ::
  Data.ProtoLens.Prism.Prism' ReadReq'Options'StreamOption ReadReq'Options'StreamOptions
_ReadReq'Options'Stream
  = Data.ProtoLens.Prism.prism'
      ReadReq'Options'Stream
      (\ p__
         -> case p__ of
              (ReadReq'Options'Stream p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_ReadReq'Options'All ::
  Data.ProtoLens.Prism.Prism' ReadReq'Options'StreamOption ReadReq'Options'AllOptions
_ReadReq'Options'All
  = Data.ProtoLens.Prism.prism'
      ReadReq'Options'All
      (\ p__
         -> case p__ of
              (ReadReq'Options'All p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_ReadReq'Options'Count ::
  Data.ProtoLens.Prism.Prism' ReadReq'Options'CountOption Data.Word.Word64
_ReadReq'Options'Count
  = Data.ProtoLens.Prism.prism'
      ReadReq'Options'Count
      (\ p__
         -> case p__ of
              (ReadReq'Options'Count p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_ReadReq'Options'Subscription ::
  Data.ProtoLens.Prism.Prism' ReadReq'Options'CountOption ReadReq'Options'SubscriptionOptions
_ReadReq'Options'Subscription
  = Data.ProtoLens.Prism.prism'
      ReadReq'Options'Subscription
      (\ p__
         -> case p__ of
              (ReadReq'Options'Subscription p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_ReadReq'Options'Filter ::
  Data.ProtoLens.Prism.Prism' ReadReq'Options'FilterOption ReadReq'Options'FilterOptions
_ReadReq'Options'Filter
  = Data.ProtoLens.Prism.prism'
      ReadReq'Options'Filter
      (\ p__
         -> case p__ of
              (ReadReq'Options'Filter p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_ReadReq'Options'NoFilter ::
  Data.ProtoLens.Prism.Prism' ReadReq'Options'FilterOption Proto.Shared.Empty
_ReadReq'Options'NoFilter
  = Data.ProtoLens.Prism.prism'
      ReadReq'Options'NoFilter
      (\ p__
         -> case p__ of
              (ReadReq'Options'NoFilter p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.Streams_Fields.maybe'allOption' @:: Lens' ReadReq'Options'AllOptions (Prelude.Maybe ReadReq'Options'AllOptions'AllOption)@
         * 'Proto.Streams_Fields.maybe'position' @:: Lens' ReadReq'Options'AllOptions (Prelude.Maybe ReadReq'Options'Position)@
         * 'Proto.Streams_Fields.position' @:: Lens' ReadReq'Options'AllOptions ReadReq'Options'Position@
         * 'Proto.Streams_Fields.maybe'start' @:: Lens' ReadReq'Options'AllOptions (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.start' @:: Lens' ReadReq'Options'AllOptions Proto.Shared.Empty@
         * 'Proto.Streams_Fields.maybe'end' @:: Lens' ReadReq'Options'AllOptions (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.end' @:: Lens' ReadReq'Options'AllOptions Proto.Shared.Empty@ -}
data ReadReq'Options'AllOptions
  = ReadReq'Options'AllOptions'_constructor {_ReadReq'Options'AllOptions'allOption :: !(Prelude.Maybe ReadReq'Options'AllOptions'AllOption),
                                             _ReadReq'Options'AllOptions'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ReadReq'Options'AllOptions where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data ReadReq'Options'AllOptions'AllOption
  = ReadReq'Options'AllOptions'Position !ReadReq'Options'Position |
    ReadReq'Options'AllOptions'Start !Proto.Shared.Empty |
    ReadReq'Options'AllOptions'End !Proto.Shared.Empty
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField ReadReq'Options'AllOptions "maybe'allOption" (Prelude.Maybe ReadReq'Options'AllOptions'AllOption) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'AllOptions'allOption
           (\ x__ y__ -> x__ {_ReadReq'Options'AllOptions'allOption = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadReq'Options'AllOptions "maybe'position" (Prelude.Maybe ReadReq'Options'Position) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'AllOptions'allOption
           (\ x__ y__ -> x__ {_ReadReq'Options'AllOptions'allOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadReq'Options'AllOptions'Position x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadReq'Options'AllOptions'Position y__))
instance Data.ProtoLens.Field.HasField ReadReq'Options'AllOptions "position" ReadReq'Options'Position where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'AllOptions'allOption
           (\ x__ y__ -> x__ {_ReadReq'Options'AllOptions'allOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadReq'Options'AllOptions'Position x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadReq'Options'AllOptions'Position y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField ReadReq'Options'AllOptions "maybe'start" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'AllOptions'allOption
           (\ x__ y__ -> x__ {_ReadReq'Options'AllOptions'allOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadReq'Options'AllOptions'Start x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadReq'Options'AllOptions'Start y__))
instance Data.ProtoLens.Field.HasField ReadReq'Options'AllOptions "start" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'AllOptions'allOption
           (\ x__ y__ -> x__ {_ReadReq'Options'AllOptions'allOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadReq'Options'AllOptions'Start x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadReq'Options'AllOptions'Start y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField ReadReq'Options'AllOptions "maybe'end" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'AllOptions'allOption
           (\ x__ y__ -> x__ {_ReadReq'Options'AllOptions'allOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadReq'Options'AllOptions'End x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadReq'Options'AllOptions'End y__))
instance Data.ProtoLens.Field.HasField ReadReq'Options'AllOptions "end" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'AllOptions'allOption
           (\ x__ y__ -> x__ {_ReadReq'Options'AllOptions'allOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadReq'Options'AllOptions'End x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadReq'Options'AllOptions'End y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message ReadReq'Options'AllOptions where
  messageName _
    = Data.Text.pack
        "event_store.client.streams.ReadReq.Options.AllOptions"
  packedMessageDescriptor _
    = "\n\
      \\n\
      \AllOptions\DC2R\n\
      \\bposition\CAN\SOH \SOH(\v24.event_store.client.streams.ReadReq.Options.PositionH\NULR\bposition\DC21\n\
      \\ENQstart\CAN\STX \SOH(\v2\EM.event_store.client.EmptyH\NULR\ENQstart\DC2-\n\
      \\ETXend\CAN\ETX \SOH(\v2\EM.event_store.client.EmptyH\NULR\ETXendB\f\n\
      \\n\
      \all_option"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        position__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "position"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ReadReq'Options'Position)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'position")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options'AllOptions
        start__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "start"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'start")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options'AllOptions
        end__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "end"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'end")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options'AllOptions
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, position__field_descriptor),
           (Data.ProtoLens.Tag 2, start__field_descriptor),
           (Data.ProtoLens.Tag 3, end__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ReadReq'Options'AllOptions'_unknownFields
        (\ x__ y__
           -> x__ {_ReadReq'Options'AllOptions'_unknownFields = y__})
  defMessage
    = ReadReq'Options'AllOptions'_constructor
        {_ReadReq'Options'AllOptions'allOption = Prelude.Nothing,
         _ReadReq'Options'AllOptions'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ReadReq'Options'AllOptions
          -> Data.ProtoLens.Encoding.Bytes.Parser ReadReq'Options'AllOptions
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
                                       "position"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"position") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "start"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"start") y x)
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "end"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"end") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "AllOptions"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view
                    (Data.ProtoLens.Field.field @"maybe'allOption") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just (ReadReq'Options'AllOptions'Position v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage v)
                (Prelude.Just (ReadReq'Options'AllOptions'Start v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage v)
                (Prelude.Just (ReadReq'Options'AllOptions'End v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData ReadReq'Options'AllOptions where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ReadReq'Options'AllOptions'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ReadReq'Options'AllOptions'allOption x__) ())
instance Control.DeepSeq.NFData ReadReq'Options'AllOptions'AllOption where
  rnf (ReadReq'Options'AllOptions'Position x__)
    = Control.DeepSeq.rnf x__
  rnf (ReadReq'Options'AllOptions'Start x__)
    = Control.DeepSeq.rnf x__
  rnf (ReadReq'Options'AllOptions'End x__) = Control.DeepSeq.rnf x__
_ReadReq'Options'AllOptions'Position ::
  Data.ProtoLens.Prism.Prism' ReadReq'Options'AllOptions'AllOption ReadReq'Options'Position
_ReadReq'Options'AllOptions'Position
  = Data.ProtoLens.Prism.prism'
      ReadReq'Options'AllOptions'Position
      (\ p__
         -> case p__ of
              (ReadReq'Options'AllOptions'Position p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_ReadReq'Options'AllOptions'Start ::
  Data.ProtoLens.Prism.Prism' ReadReq'Options'AllOptions'AllOption Proto.Shared.Empty
_ReadReq'Options'AllOptions'Start
  = Data.ProtoLens.Prism.prism'
      ReadReq'Options'AllOptions'Start
      (\ p__
         -> case p__ of
              (ReadReq'Options'AllOptions'Start p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_ReadReq'Options'AllOptions'End ::
  Data.ProtoLens.Prism.Prism' ReadReq'Options'AllOptions'AllOption Proto.Shared.Empty
_ReadReq'Options'AllOptions'End
  = Data.ProtoLens.Prism.prism'
      ReadReq'Options'AllOptions'End
      (\ p__
         -> case p__ of
              (ReadReq'Options'AllOptions'End p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.Streams_Fields.compatibility' @:: Lens' ReadReq'Options'ControlOption Data.Word.Word32@ -}
data ReadReq'Options'ControlOption
  = ReadReq'Options'ControlOption'_constructor {_ReadReq'Options'ControlOption'compatibility :: !Data.Word.Word32,
                                                _ReadReq'Options'ControlOption'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ReadReq'Options'ControlOption where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField ReadReq'Options'ControlOption "compatibility" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'ControlOption'compatibility
           (\ x__ y__
              -> x__ {_ReadReq'Options'ControlOption'compatibility = y__}))
        Prelude.id
instance Data.ProtoLens.Message ReadReq'Options'ControlOption where
  messageName _
    = Data.Text.pack
        "event_store.client.streams.ReadReq.Options.ControlOption"
  packedMessageDescriptor _
    = "\n\
      \\rControlOption\DC2$\n\
      \\rcompatibility\CAN\SOH \SOH(\rR\rcompatibility"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        compatibility__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "compatibility"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"compatibility")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options'ControlOption
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, compatibility__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ReadReq'Options'ControlOption'_unknownFields
        (\ x__ y__
           -> x__ {_ReadReq'Options'ControlOption'_unknownFields = y__})
  defMessage
    = ReadReq'Options'ControlOption'_constructor
        {_ReadReq'Options'ControlOption'compatibility = Data.ProtoLens.fieldDefault,
         _ReadReq'Options'ControlOption'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ReadReq'Options'ControlOption
          -> Data.ProtoLens.Encoding.Bytes.Parser ReadReq'Options'ControlOption
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
                                       "compatibility"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"compatibility") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "ControlOption"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view
                      (Data.ProtoLens.Field.field @"compatibility") _x
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
instance Control.DeepSeq.NFData ReadReq'Options'ControlOption where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ReadReq'Options'ControlOption'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ReadReq'Options'ControlOption'compatibility x__) ())
{- | Fields :
     
         * 'Proto.Streams_Fields.checkpointIntervalMultiplier' @:: Lens' ReadReq'Options'FilterOptions Data.Word.Word32@
         * 'Proto.Streams_Fields.maybe'filter' @:: Lens' ReadReq'Options'FilterOptions (Prelude.Maybe ReadReq'Options'FilterOptions'Filter)@
         * 'Proto.Streams_Fields.maybe'streamIdentifier' @:: Lens' ReadReq'Options'FilterOptions (Prelude.Maybe ReadReq'Options'FilterOptions'Expression)@
         * 'Proto.Streams_Fields.streamIdentifier' @:: Lens' ReadReq'Options'FilterOptions ReadReq'Options'FilterOptions'Expression@
         * 'Proto.Streams_Fields.maybe'eventType' @:: Lens' ReadReq'Options'FilterOptions (Prelude.Maybe ReadReq'Options'FilterOptions'Expression)@
         * 'Proto.Streams_Fields.eventType' @:: Lens' ReadReq'Options'FilterOptions ReadReq'Options'FilterOptions'Expression@
         * 'Proto.Streams_Fields.maybe'window' @:: Lens' ReadReq'Options'FilterOptions (Prelude.Maybe ReadReq'Options'FilterOptions'Window)@
         * 'Proto.Streams_Fields.maybe'max' @:: Lens' ReadReq'Options'FilterOptions (Prelude.Maybe Data.Word.Word32)@
         * 'Proto.Streams_Fields.max' @:: Lens' ReadReq'Options'FilterOptions Data.Word.Word32@
         * 'Proto.Streams_Fields.maybe'count' @:: Lens' ReadReq'Options'FilterOptions (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.count' @:: Lens' ReadReq'Options'FilterOptions Proto.Shared.Empty@ -}
data ReadReq'Options'FilterOptions
  = ReadReq'Options'FilterOptions'_constructor {_ReadReq'Options'FilterOptions'checkpointIntervalMultiplier :: !Data.Word.Word32,
                                                _ReadReq'Options'FilterOptions'filter :: !(Prelude.Maybe ReadReq'Options'FilterOptions'Filter),
                                                _ReadReq'Options'FilterOptions'window :: !(Prelude.Maybe ReadReq'Options'FilterOptions'Window),
                                                _ReadReq'Options'FilterOptions'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ReadReq'Options'FilterOptions where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data ReadReq'Options'FilterOptions'Filter
  = ReadReq'Options'FilterOptions'StreamIdentifier !ReadReq'Options'FilterOptions'Expression |
    ReadReq'Options'FilterOptions'EventType !ReadReq'Options'FilterOptions'Expression
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
data ReadReq'Options'FilterOptions'Window
  = ReadReq'Options'FilterOptions'Max !Data.Word.Word32 |
    ReadReq'Options'FilterOptions'Count !Proto.Shared.Empty
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField ReadReq'Options'FilterOptions "checkpointIntervalMultiplier" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'FilterOptions'checkpointIntervalMultiplier
           (\ x__ y__
              -> x__
                   {_ReadReq'Options'FilterOptions'checkpointIntervalMultiplier = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadReq'Options'FilterOptions "maybe'filter" (Prelude.Maybe ReadReq'Options'FilterOptions'Filter) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'FilterOptions'filter
           (\ x__ y__ -> x__ {_ReadReq'Options'FilterOptions'filter = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadReq'Options'FilterOptions "maybe'streamIdentifier" (Prelude.Maybe ReadReq'Options'FilterOptions'Expression) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'FilterOptions'filter
           (\ x__ y__ -> x__ {_ReadReq'Options'FilterOptions'filter = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadReq'Options'FilterOptions'StreamIdentifier x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__
              -> Prelude.fmap
                   ReadReq'Options'FilterOptions'StreamIdentifier y__))
instance Data.ProtoLens.Field.HasField ReadReq'Options'FilterOptions "streamIdentifier" ReadReq'Options'FilterOptions'Expression where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'FilterOptions'filter
           (\ x__ y__ -> x__ {_ReadReq'Options'FilterOptions'filter = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadReq'Options'FilterOptions'StreamIdentifier x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__
                 -> Prelude.fmap
                      ReadReq'Options'FilterOptions'StreamIdentifier y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField ReadReq'Options'FilterOptions "maybe'eventType" (Prelude.Maybe ReadReq'Options'FilterOptions'Expression) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'FilterOptions'filter
           (\ x__ y__ -> x__ {_ReadReq'Options'FilterOptions'filter = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadReq'Options'FilterOptions'EventType x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__
              -> Prelude.fmap ReadReq'Options'FilterOptions'EventType y__))
instance Data.ProtoLens.Field.HasField ReadReq'Options'FilterOptions "eventType" ReadReq'Options'FilterOptions'Expression where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'FilterOptions'filter
           (\ x__ y__ -> x__ {_ReadReq'Options'FilterOptions'filter = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadReq'Options'FilterOptions'EventType x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__
                 -> Prelude.fmap ReadReq'Options'FilterOptions'EventType y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField ReadReq'Options'FilterOptions "maybe'window" (Prelude.Maybe ReadReq'Options'FilterOptions'Window) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'FilterOptions'window
           (\ x__ y__ -> x__ {_ReadReq'Options'FilterOptions'window = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadReq'Options'FilterOptions "maybe'max" (Prelude.Maybe Data.Word.Word32) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'FilterOptions'window
           (\ x__ y__ -> x__ {_ReadReq'Options'FilterOptions'window = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadReq'Options'FilterOptions'Max x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadReq'Options'FilterOptions'Max y__))
instance Data.ProtoLens.Field.HasField ReadReq'Options'FilterOptions "max" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'FilterOptions'window
           (\ x__ y__ -> x__ {_ReadReq'Options'FilterOptions'window = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadReq'Options'FilterOptions'Max x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadReq'Options'FilterOptions'Max y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Field.HasField ReadReq'Options'FilterOptions "maybe'count" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'FilterOptions'window
           (\ x__ y__ -> x__ {_ReadReq'Options'FilterOptions'window = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadReq'Options'FilterOptions'Count x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadReq'Options'FilterOptions'Count y__))
instance Data.ProtoLens.Field.HasField ReadReq'Options'FilterOptions "count" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'FilterOptions'window
           (\ x__ y__ -> x__ {_ReadReq'Options'FilterOptions'window = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadReq'Options'FilterOptions'Count x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadReq'Options'FilterOptions'Count y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message ReadReq'Options'FilterOptions where
  messageName _
    = Data.Text.pack
        "event_store.client.streams.ReadReq.Options.FilterOptions"
  packedMessageDescriptor _
    = "\n\
      \\rFilterOptions\DC2s\n\
      \\DC1stream_identifier\CAN\SOH \SOH(\v2D.event_store.client.streams.ReadReq.Options.FilterOptions.ExpressionH\NULR\DLEstreamIdentifier\DC2e\n\
      \\n\
      \event_type\CAN\STX \SOH(\v2D.event_store.client.streams.ReadReq.Options.FilterOptions.ExpressionH\NULR\teventType\DC2\DC2\n\
      \\ETXmax\CAN\ETX \SOH(\rH\SOHR\ETXmax\DC21\n\
      \\ENQcount\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\SOHR\ENQcount\DC2B\n\
      \\FScheckpointIntervalMultiplier\CAN\ENQ \SOH(\rR\FScheckpointIntervalMultiplier\SUB:\n\
      \\n\
      \Expression\DC2\DC4\n\
      \\ENQregex\CAN\SOH \SOH(\tR\ENQregex\DC2\SYN\n\
      \\ACKprefix\CAN\STX \ETX(\tR\ACKprefixB\b\n\
      \\ACKfilterB\b\n\
      \\ACKwindow"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        checkpointIntervalMultiplier__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "checkpointIntervalMultiplier"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"checkpointIntervalMultiplier")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options'FilterOptions
        streamIdentifier__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stream_identifier"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ReadReq'Options'FilterOptions'Expression)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'streamIdentifier")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options'FilterOptions
        eventType__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "event_type"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ReadReq'Options'FilterOptions'Expression)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'eventType")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options'FilterOptions
        max__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "max"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'max")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options'FilterOptions
        count__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "count"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'count")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options'FilterOptions
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 5, 
            checkpointIntervalMultiplier__field_descriptor),
           (Data.ProtoLens.Tag 1, streamIdentifier__field_descriptor),
           (Data.ProtoLens.Tag 2, eventType__field_descriptor),
           (Data.ProtoLens.Tag 3, max__field_descriptor),
           (Data.ProtoLens.Tag 4, count__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ReadReq'Options'FilterOptions'_unknownFields
        (\ x__ y__
           -> x__ {_ReadReq'Options'FilterOptions'_unknownFields = y__})
  defMessage
    = ReadReq'Options'FilterOptions'_constructor
        {_ReadReq'Options'FilterOptions'checkpointIntervalMultiplier = Data.ProtoLens.fieldDefault,
         _ReadReq'Options'FilterOptions'filter = Prelude.Nothing,
         _ReadReq'Options'FilterOptions'window = Prelude.Nothing,
         _ReadReq'Options'FilterOptions'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ReadReq'Options'FilterOptions
          -> Data.ProtoLens.Encoding.Bytes.Parser ReadReq'Options'FilterOptions
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
                        40
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "checkpointIntervalMultiplier"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"checkpointIntervalMultiplier") y
                                     x)
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "stream_identifier"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"streamIdentifier") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "event_type"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"eventType") y x)
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "max"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"max") y x)
                        34
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "count"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"count") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "FilterOptions"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view
                      (Data.ProtoLens.Field.field @"checkpointIntervalMultiplier") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 40)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
             ((Data.Monoid.<>)
                (case
                     Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'filter") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just (ReadReq'Options'FilterOptions'StreamIdentifier v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage v)
                   (Prelude.Just (ReadReq'Options'FilterOptions'EventType v))
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
                        Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'window") _x
                    of
                      Prelude.Nothing -> Data.Monoid.mempty
                      (Prelude.Just (ReadReq'Options'FilterOptions'Max v))
                        -> (Data.Monoid.<>)
                             (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                             ((Prelude..)
                                Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral v)
                      (Prelude.Just (ReadReq'Options'FilterOptions'Count v))
                        -> (Data.Monoid.<>)
                             (Data.ProtoLens.Encoding.Bytes.putVarInt 34)
                             ((Prelude..)
                                (\ bs
                                   -> (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt
                                           (Prelude.fromIntegral (Data.ByteString.length bs)))
                                        (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                Data.ProtoLens.encodeMessage v))
                   (Data.ProtoLens.Encoding.Wire.buildFieldSet
                      (Lens.Family2.view Data.ProtoLens.unknownFields _x))))
instance Control.DeepSeq.NFData ReadReq'Options'FilterOptions where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ReadReq'Options'FilterOptions'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ReadReq'Options'FilterOptions'checkpointIntervalMultiplier x__)
                (Control.DeepSeq.deepseq
                   (_ReadReq'Options'FilterOptions'filter x__)
                   (Control.DeepSeq.deepseq
                      (_ReadReq'Options'FilterOptions'window x__) ())))
instance Control.DeepSeq.NFData ReadReq'Options'FilterOptions'Filter where
  rnf (ReadReq'Options'FilterOptions'StreamIdentifier x__)
    = Control.DeepSeq.rnf x__
  rnf (ReadReq'Options'FilterOptions'EventType x__)
    = Control.DeepSeq.rnf x__
instance Control.DeepSeq.NFData ReadReq'Options'FilterOptions'Window where
  rnf (ReadReq'Options'FilterOptions'Max x__)
    = Control.DeepSeq.rnf x__
  rnf (ReadReq'Options'FilterOptions'Count x__)
    = Control.DeepSeq.rnf x__
_ReadReq'Options'FilterOptions'StreamIdentifier ::
  Data.ProtoLens.Prism.Prism' ReadReq'Options'FilterOptions'Filter ReadReq'Options'FilterOptions'Expression
_ReadReq'Options'FilterOptions'StreamIdentifier
  = Data.ProtoLens.Prism.prism'
      ReadReq'Options'FilterOptions'StreamIdentifier
      (\ p__
         -> case p__ of
              (ReadReq'Options'FilterOptions'StreamIdentifier p__val)
                -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_ReadReq'Options'FilterOptions'EventType ::
  Data.ProtoLens.Prism.Prism' ReadReq'Options'FilterOptions'Filter ReadReq'Options'FilterOptions'Expression
_ReadReq'Options'FilterOptions'EventType
  = Data.ProtoLens.Prism.prism'
      ReadReq'Options'FilterOptions'EventType
      (\ p__
         -> case p__ of
              (ReadReq'Options'FilterOptions'EventType p__val)
                -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_ReadReq'Options'FilterOptions'Max ::
  Data.ProtoLens.Prism.Prism' ReadReq'Options'FilterOptions'Window Data.Word.Word32
_ReadReq'Options'FilterOptions'Max
  = Data.ProtoLens.Prism.prism'
      ReadReq'Options'FilterOptions'Max
      (\ p__
         -> case p__ of
              (ReadReq'Options'FilterOptions'Max p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_ReadReq'Options'FilterOptions'Count ::
  Data.ProtoLens.Prism.Prism' ReadReq'Options'FilterOptions'Window Proto.Shared.Empty
_ReadReq'Options'FilterOptions'Count
  = Data.ProtoLens.Prism.prism'
      ReadReq'Options'FilterOptions'Count
      (\ p__
         -> case p__ of
              (ReadReq'Options'FilterOptions'Count p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.Streams_Fields.regex' @:: Lens' ReadReq'Options'FilterOptions'Expression Data.Text.Text@
         * 'Proto.Streams_Fields.prefix' @:: Lens' ReadReq'Options'FilterOptions'Expression [Data.Text.Text]@
         * 'Proto.Streams_Fields.vec'prefix' @:: Lens' ReadReq'Options'FilterOptions'Expression (Data.Vector.Vector Data.Text.Text)@ -}
data ReadReq'Options'FilterOptions'Expression
  = ReadReq'Options'FilterOptions'Expression'_constructor {_ReadReq'Options'FilterOptions'Expression'regex :: !Data.Text.Text,
                                                           _ReadReq'Options'FilterOptions'Expression'prefix :: !(Data.Vector.Vector Data.Text.Text),
                                                           _ReadReq'Options'FilterOptions'Expression'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ReadReq'Options'FilterOptions'Expression where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField ReadReq'Options'FilterOptions'Expression "regex" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'FilterOptions'Expression'regex
           (\ x__ y__
              -> x__ {_ReadReq'Options'FilterOptions'Expression'regex = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadReq'Options'FilterOptions'Expression "prefix" [Data.Text.Text] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'FilterOptions'Expression'prefix
           (\ x__ y__
              -> x__ {_ReadReq'Options'FilterOptions'Expression'prefix = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField ReadReq'Options'FilterOptions'Expression "vec'prefix" (Data.Vector.Vector Data.Text.Text) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'FilterOptions'Expression'prefix
           (\ x__ y__
              -> x__ {_ReadReq'Options'FilterOptions'Expression'prefix = y__}))
        Prelude.id
instance Data.ProtoLens.Message ReadReq'Options'FilterOptions'Expression where
  messageName _
    = Data.Text.pack
        "event_store.client.streams.ReadReq.Options.FilterOptions.Expression"
  packedMessageDescriptor _
    = "\n\
      \\n\
      \Expression\DC2\DC4\n\
      \\ENQregex\CAN\SOH \SOH(\tR\ENQregex\DC2\SYN\n\
      \\ACKprefix\CAN\STX \ETX(\tR\ACKprefix"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        regex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "regex"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"regex")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options'FilterOptions'Expression
        prefix__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "prefix"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked (Data.ProtoLens.Field.field @"prefix")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options'FilterOptions'Expression
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, regex__field_descriptor),
           (Data.ProtoLens.Tag 2, prefix__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ReadReq'Options'FilterOptions'Expression'_unknownFields
        (\ x__ y__
           -> x__
                {_ReadReq'Options'FilterOptions'Expression'_unknownFields = y__})
  defMessage
    = ReadReq'Options'FilterOptions'Expression'_constructor
        {_ReadReq'Options'FilterOptions'Expression'regex = Data.ProtoLens.fieldDefault,
         _ReadReq'Options'FilterOptions'Expression'prefix = Data.Vector.Generic.empty,
         _ReadReq'Options'FilterOptions'Expression'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ReadReq'Options'FilterOptions'Expression
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Data.Text.Text
             -> Data.ProtoLens.Encoding.Bytes.Parser ReadReq'Options'FilterOptions'Expression
        loop x mutable'prefix
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'prefix <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                         (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                            mutable'prefix)
                      (let missing = []
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
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t)
                           (Lens.Family2.set
                              (Data.ProtoLens.Field.field @"vec'prefix") frozen'prefix x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getText
                                             (Prelude.fromIntegral len))
                                       "regex"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"regex") y x)
                                  mutable'prefix
                        18
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.getText
                                              (Prelude.fromIntegral len))
                                        "prefix"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'prefix y)
                                loop x v
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'prefix
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'prefix <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                  Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'prefix)
          "Expression"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v = Lens.Family2.view (Data.ProtoLens.Field.field @"regex") _x
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
                (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                   (\ _v
                      -> (Data.Monoid.<>)
                           (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                           ((Prelude..)
                              (\ bs
                                 -> (Data.Monoid.<>)
                                      (Data.ProtoLens.Encoding.Bytes.putVarInt
                                         (Prelude.fromIntegral (Data.ByteString.length bs)))
                                      (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                              Data.Text.Encoding.encodeUtf8 _v))
                   (Lens.Family2.view (Data.ProtoLens.Field.field @"vec'prefix") _x))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData ReadReq'Options'FilterOptions'Expression where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ReadReq'Options'FilterOptions'Expression'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ReadReq'Options'FilterOptions'Expression'regex x__)
                (Control.DeepSeq.deepseq
                   (_ReadReq'Options'FilterOptions'Expression'prefix x__) ()))
{- | Fields :
     
         * 'Proto.Streams_Fields.commitPosition' @:: Lens' ReadReq'Options'Position Data.Word.Word64@
         * 'Proto.Streams_Fields.preparePosition' @:: Lens' ReadReq'Options'Position Data.Word.Word64@ -}
data ReadReq'Options'Position
  = ReadReq'Options'Position'_constructor {_ReadReq'Options'Position'commitPosition :: !Data.Word.Word64,
                                           _ReadReq'Options'Position'preparePosition :: !Data.Word.Word64,
                                           _ReadReq'Options'Position'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ReadReq'Options'Position where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField ReadReq'Options'Position "commitPosition" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'Position'commitPosition
           (\ x__ y__
              -> x__ {_ReadReq'Options'Position'commitPosition = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadReq'Options'Position "preparePosition" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'Position'preparePosition
           (\ x__ y__
              -> x__ {_ReadReq'Options'Position'preparePosition = y__}))
        Prelude.id
instance Data.ProtoLens.Message ReadReq'Options'Position where
  messageName _
    = Data.Text.pack
        "event_store.client.streams.ReadReq.Options.Position"
  packedMessageDescriptor _
    = "\n\
      \\bPosition\DC2'\n\
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
              Data.ProtoLens.FieldDescriptor ReadReq'Options'Position
        preparePosition__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "prepare_position"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"preparePosition")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options'Position
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, commitPosition__field_descriptor),
           (Data.ProtoLens.Tag 2, preparePosition__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ReadReq'Options'Position'_unknownFields
        (\ x__ y__ -> x__ {_ReadReq'Options'Position'_unknownFields = y__})
  defMessage
    = ReadReq'Options'Position'_constructor
        {_ReadReq'Options'Position'commitPosition = Data.ProtoLens.fieldDefault,
         _ReadReq'Options'Position'preparePosition = Data.ProtoLens.fieldDefault,
         _ReadReq'Options'Position'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ReadReq'Options'Position
          -> Data.ProtoLens.Encoding.Bytes.Parser ReadReq'Options'Position
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
          (do loop Data.ProtoLens.defMessage) "Position"
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
instance Control.DeepSeq.NFData ReadReq'Options'Position where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ReadReq'Options'Position'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ReadReq'Options'Position'commitPosition x__)
                (Control.DeepSeq.deepseq
                   (_ReadReq'Options'Position'preparePosition x__) ()))
newtype ReadReq'Options'ReadDirection'UnrecognizedValue
  = ReadReq'Options'ReadDirection'UnrecognizedValue Data.Int.Int32
  deriving stock (Prelude.Eq, Prelude.Ord, Prelude.Show)
data ReadReq'Options'ReadDirection
  = ReadReq'Options'Forwards |
    ReadReq'Options'Backwards |
    ReadReq'Options'ReadDirection'Unrecognized !ReadReq'Options'ReadDirection'UnrecognizedValue
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.MessageEnum ReadReq'Options'ReadDirection where
  maybeToEnum 0 = Prelude.Just ReadReq'Options'Forwards
  maybeToEnum 1 = Prelude.Just ReadReq'Options'Backwards
  maybeToEnum k
    = Prelude.Just
        (ReadReq'Options'ReadDirection'Unrecognized
           (ReadReq'Options'ReadDirection'UnrecognizedValue
              (Prelude.fromIntegral k)))
  showEnum ReadReq'Options'Forwards = "Forwards"
  showEnum ReadReq'Options'Backwards = "Backwards"
  showEnum
    (ReadReq'Options'ReadDirection'Unrecognized (ReadReq'Options'ReadDirection'UnrecognizedValue k))
    = Prelude.show k
  readEnum k
    | (Prelude.==) k "Forwards" = Prelude.Just ReadReq'Options'Forwards
    | (Prelude.==) k "Backwards"
    = Prelude.Just ReadReq'Options'Backwards
    | Prelude.otherwise
    = (Prelude.>>=) (Text.Read.readMaybe k) Data.ProtoLens.maybeToEnum
instance Prelude.Bounded ReadReq'Options'ReadDirection where
  minBound = ReadReq'Options'Forwards
  maxBound = ReadReq'Options'Backwards
instance Prelude.Enum ReadReq'Options'ReadDirection where
  toEnum k__
    = Prelude.maybe
        (Prelude.error
           ((Prelude.++)
              "toEnum: unknown value for enum ReadDirection: "
              (Prelude.show k__)))
        Prelude.id (Data.ProtoLens.maybeToEnum k__)
  fromEnum ReadReq'Options'Forwards = 0
  fromEnum ReadReq'Options'Backwards = 1
  fromEnum
    (ReadReq'Options'ReadDirection'Unrecognized (ReadReq'Options'ReadDirection'UnrecognizedValue k))
    = Prelude.fromIntegral k
  succ ReadReq'Options'Backwards
    = Prelude.error
        "ReadReq'Options'ReadDirection.succ: bad argument ReadReq'Options'Backwards. This value would be out of bounds."
  succ ReadReq'Options'Forwards = ReadReq'Options'Backwards
  succ (ReadReq'Options'ReadDirection'Unrecognized _)
    = Prelude.error
        "ReadReq'Options'ReadDirection.succ: bad argument: unrecognized value"
  pred ReadReq'Options'Forwards
    = Prelude.error
        "ReadReq'Options'ReadDirection.pred: bad argument ReadReq'Options'Forwards. This value would be out of bounds."
  pred ReadReq'Options'Backwards = ReadReq'Options'Forwards
  pred (ReadReq'Options'ReadDirection'Unrecognized _)
    = Prelude.error
        "ReadReq'Options'ReadDirection.pred: bad argument: unrecognized value"
  enumFrom = Data.ProtoLens.Message.Enum.messageEnumFrom
  enumFromTo = Data.ProtoLens.Message.Enum.messageEnumFromTo
  enumFromThen = Data.ProtoLens.Message.Enum.messageEnumFromThen
  enumFromThenTo = Data.ProtoLens.Message.Enum.messageEnumFromThenTo
instance Data.ProtoLens.FieldDefault ReadReq'Options'ReadDirection where
  fieldDefault = ReadReq'Options'Forwards
instance Control.DeepSeq.NFData ReadReq'Options'ReadDirection where
  rnf x__ = Prelude.seq x__ ()
{- | Fields :
     
         * 'Proto.Streams_Fields.streamIdentifier' @:: Lens' ReadReq'Options'StreamOptions Proto.Shared.StreamIdentifier@
         * 'Proto.Streams_Fields.maybe'streamIdentifier' @:: Lens' ReadReq'Options'StreamOptions (Prelude.Maybe Proto.Shared.StreamIdentifier)@
         * 'Proto.Streams_Fields.maybe'revisionOption' @:: Lens' ReadReq'Options'StreamOptions (Prelude.Maybe ReadReq'Options'StreamOptions'RevisionOption)@
         * 'Proto.Streams_Fields.maybe'revision' @:: Lens' ReadReq'Options'StreamOptions (Prelude.Maybe Data.Word.Word64)@
         * 'Proto.Streams_Fields.revision' @:: Lens' ReadReq'Options'StreamOptions Data.Word.Word64@
         * 'Proto.Streams_Fields.maybe'start' @:: Lens' ReadReq'Options'StreamOptions (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.start' @:: Lens' ReadReq'Options'StreamOptions Proto.Shared.Empty@
         * 'Proto.Streams_Fields.maybe'end' @:: Lens' ReadReq'Options'StreamOptions (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.end' @:: Lens' ReadReq'Options'StreamOptions Proto.Shared.Empty@ -}
data ReadReq'Options'StreamOptions
  = ReadReq'Options'StreamOptions'_constructor {_ReadReq'Options'StreamOptions'streamIdentifier :: !(Prelude.Maybe Proto.Shared.StreamIdentifier),
                                                _ReadReq'Options'StreamOptions'revisionOption :: !(Prelude.Maybe ReadReq'Options'StreamOptions'RevisionOption),
                                                _ReadReq'Options'StreamOptions'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ReadReq'Options'StreamOptions where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data ReadReq'Options'StreamOptions'RevisionOption
  = ReadReq'Options'StreamOptions'Revision !Data.Word.Word64 |
    ReadReq'Options'StreamOptions'Start !Proto.Shared.Empty |
    ReadReq'Options'StreamOptions'End !Proto.Shared.Empty
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField ReadReq'Options'StreamOptions "streamIdentifier" Proto.Shared.StreamIdentifier where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'StreamOptions'streamIdentifier
           (\ x__ y__
              -> x__ {_ReadReq'Options'StreamOptions'streamIdentifier = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField ReadReq'Options'StreamOptions "maybe'streamIdentifier" (Prelude.Maybe Proto.Shared.StreamIdentifier) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'StreamOptions'streamIdentifier
           (\ x__ y__
              -> x__ {_ReadReq'Options'StreamOptions'streamIdentifier = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadReq'Options'StreamOptions "maybe'revisionOption" (Prelude.Maybe ReadReq'Options'StreamOptions'RevisionOption) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'StreamOptions'revisionOption
           (\ x__ y__
              -> x__ {_ReadReq'Options'StreamOptions'revisionOption = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadReq'Options'StreamOptions "maybe'revision" (Prelude.Maybe Data.Word.Word64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'StreamOptions'revisionOption
           (\ x__ y__
              -> x__ {_ReadReq'Options'StreamOptions'revisionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadReq'Options'StreamOptions'Revision x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__
              -> Prelude.fmap ReadReq'Options'StreamOptions'Revision y__))
instance Data.ProtoLens.Field.HasField ReadReq'Options'StreamOptions "revision" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'StreamOptions'revisionOption
           (\ x__ y__
              -> x__ {_ReadReq'Options'StreamOptions'revisionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadReq'Options'StreamOptions'Revision x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__
                 -> Prelude.fmap ReadReq'Options'StreamOptions'Revision y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Field.HasField ReadReq'Options'StreamOptions "maybe'start" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'StreamOptions'revisionOption
           (\ x__ y__
              -> x__ {_ReadReq'Options'StreamOptions'revisionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadReq'Options'StreamOptions'Start x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadReq'Options'StreamOptions'Start y__))
instance Data.ProtoLens.Field.HasField ReadReq'Options'StreamOptions "start" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'StreamOptions'revisionOption
           (\ x__ y__
              -> x__ {_ReadReq'Options'StreamOptions'revisionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadReq'Options'StreamOptions'Start x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadReq'Options'StreamOptions'Start y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField ReadReq'Options'StreamOptions "maybe'end" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'StreamOptions'revisionOption
           (\ x__ y__
              -> x__ {_ReadReq'Options'StreamOptions'revisionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadReq'Options'StreamOptions'End x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadReq'Options'StreamOptions'End y__))
instance Data.ProtoLens.Field.HasField ReadReq'Options'StreamOptions "end" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'StreamOptions'revisionOption
           (\ x__ y__
              -> x__ {_ReadReq'Options'StreamOptions'revisionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadReq'Options'StreamOptions'End x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadReq'Options'StreamOptions'End y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message ReadReq'Options'StreamOptions where
  messageName _
    = Data.Text.pack
        "event_store.client.streams.ReadReq.Options.StreamOptions"
  packedMessageDescriptor _
    = "\n\
      \\rStreamOptions\DC2Q\n\
      \\DC1stream_identifier\CAN\SOH \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier\DC2\FS\n\
      \\brevision\CAN\STX \SOH(\EOTH\NULR\brevision\DC21\n\
      \\ENQstart\CAN\ETX \SOH(\v2\EM.event_store.client.EmptyH\NULR\ENQstart\DC2-\n\
      \\ETXend\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\NULR\ETXendB\DC1\n\
      \\SIrevision_option"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        streamIdentifier__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stream_identifier"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.StreamIdentifier)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'streamIdentifier")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options'StreamOptions
        revision__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "revision"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'revision")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options'StreamOptions
        start__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "start"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'start")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options'StreamOptions
        end__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "end"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'end")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options'StreamOptions
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, streamIdentifier__field_descriptor),
           (Data.ProtoLens.Tag 2, revision__field_descriptor),
           (Data.ProtoLens.Tag 3, start__field_descriptor),
           (Data.ProtoLens.Tag 4, end__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ReadReq'Options'StreamOptions'_unknownFields
        (\ x__ y__
           -> x__ {_ReadReq'Options'StreamOptions'_unknownFields = y__})
  defMessage
    = ReadReq'Options'StreamOptions'_constructor
        {_ReadReq'Options'StreamOptions'streamIdentifier = Prelude.Nothing,
         _ReadReq'Options'StreamOptions'revisionOption = Prelude.Nothing,
         _ReadReq'Options'StreamOptions'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ReadReq'Options'StreamOptions
          -> Data.ProtoLens.Encoding.Bytes.Parser ReadReq'Options'StreamOptions
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
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "revision"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"revision") y x)
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "start"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"start") y x)
                        34
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "end"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"end") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "StreamOptions"
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
             ((Data.Monoid.<>)
                (case
                     Lens.Family2.view
                       (Data.ProtoLens.Field.field @"maybe'revisionOption") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just (ReadReq'Options'StreamOptions'Revision v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt v)
                   (Prelude.Just (ReadReq'Options'StreamOptions'Start v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage v)
                   (Prelude.Just (ReadReq'Options'StreamOptions'End v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 34)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData ReadReq'Options'StreamOptions where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ReadReq'Options'StreamOptions'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ReadReq'Options'StreamOptions'streamIdentifier x__)
                (Control.DeepSeq.deepseq
                   (_ReadReq'Options'StreamOptions'revisionOption x__) ()))
instance Control.DeepSeq.NFData ReadReq'Options'StreamOptions'RevisionOption where
  rnf (ReadReq'Options'StreamOptions'Revision x__)
    = Control.DeepSeq.rnf x__
  rnf (ReadReq'Options'StreamOptions'Start x__)
    = Control.DeepSeq.rnf x__
  rnf (ReadReq'Options'StreamOptions'End x__)
    = Control.DeepSeq.rnf x__
_ReadReq'Options'StreamOptions'Revision ::
  Data.ProtoLens.Prism.Prism' ReadReq'Options'StreamOptions'RevisionOption Data.Word.Word64
_ReadReq'Options'StreamOptions'Revision
  = Data.ProtoLens.Prism.prism'
      ReadReq'Options'StreamOptions'Revision
      (\ p__
         -> case p__ of
              (ReadReq'Options'StreamOptions'Revision p__val)
                -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_ReadReq'Options'StreamOptions'Start ::
  Data.ProtoLens.Prism.Prism' ReadReq'Options'StreamOptions'RevisionOption Proto.Shared.Empty
_ReadReq'Options'StreamOptions'Start
  = Data.ProtoLens.Prism.prism'
      ReadReq'Options'StreamOptions'Start
      (\ p__
         -> case p__ of
              (ReadReq'Options'StreamOptions'Start p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_ReadReq'Options'StreamOptions'End ::
  Data.ProtoLens.Prism.Prism' ReadReq'Options'StreamOptions'RevisionOption Proto.Shared.Empty
_ReadReq'Options'StreamOptions'End
  = Data.ProtoLens.Prism.prism'
      ReadReq'Options'StreamOptions'End
      (\ p__
         -> case p__ of
              (ReadReq'Options'StreamOptions'End p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
      -}
data ReadReq'Options'SubscriptionOptions
  = ReadReq'Options'SubscriptionOptions'_constructor {_ReadReq'Options'SubscriptionOptions'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ReadReq'Options'SubscriptionOptions where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Message ReadReq'Options'SubscriptionOptions where
  messageName _
    = Data.Text.pack
        "event_store.client.streams.ReadReq.Options.SubscriptionOptions"
  packedMessageDescriptor _
    = "\n\
      \\DC3SubscriptionOptions"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag = let in Data.Map.fromList []
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ReadReq'Options'SubscriptionOptions'_unknownFields
        (\ x__ y__
           -> x__ {_ReadReq'Options'SubscriptionOptions'_unknownFields = y__})
  defMessage
    = ReadReq'Options'SubscriptionOptions'_constructor
        {_ReadReq'Options'SubscriptionOptions'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ReadReq'Options'SubscriptionOptions
          -> Data.ProtoLens.Encoding.Bytes.Parser ReadReq'Options'SubscriptionOptions
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
          (do loop Data.ProtoLens.defMessage) "SubscriptionOptions"
  buildMessage
    = \ _x
        -> Data.ProtoLens.Encoding.Wire.buildFieldSet
             (Lens.Family2.view Data.ProtoLens.unknownFields _x)
instance Control.DeepSeq.NFData ReadReq'Options'SubscriptionOptions where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ReadReq'Options'SubscriptionOptions'_unknownFields x__) ()
{- | Fields :
     
         * 'Proto.Streams_Fields.maybe'content' @:: Lens' ReadReq'Options'UUIDOption (Prelude.Maybe ReadReq'Options'UUIDOption'Content)@
         * 'Proto.Streams_Fields.maybe'structured' @:: Lens' ReadReq'Options'UUIDOption (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.structured' @:: Lens' ReadReq'Options'UUIDOption Proto.Shared.Empty@
         * 'Proto.Streams_Fields.maybe'string' @:: Lens' ReadReq'Options'UUIDOption (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.string' @:: Lens' ReadReq'Options'UUIDOption Proto.Shared.Empty@ -}
data ReadReq'Options'UUIDOption
  = ReadReq'Options'UUIDOption'_constructor {_ReadReq'Options'UUIDOption'content :: !(Prelude.Maybe ReadReq'Options'UUIDOption'Content),
                                             _ReadReq'Options'UUIDOption'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ReadReq'Options'UUIDOption where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data ReadReq'Options'UUIDOption'Content
  = ReadReq'Options'UUIDOption'Structured !Proto.Shared.Empty |
    ReadReq'Options'UUIDOption'String !Proto.Shared.Empty
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField ReadReq'Options'UUIDOption "maybe'content" (Prelude.Maybe ReadReq'Options'UUIDOption'Content) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'UUIDOption'content
           (\ x__ y__ -> x__ {_ReadReq'Options'UUIDOption'content = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadReq'Options'UUIDOption "maybe'structured" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'UUIDOption'content
           (\ x__ y__ -> x__ {_ReadReq'Options'UUIDOption'content = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadReq'Options'UUIDOption'Structured x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__
              -> Prelude.fmap ReadReq'Options'UUIDOption'Structured y__))
instance Data.ProtoLens.Field.HasField ReadReq'Options'UUIDOption "structured" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'UUIDOption'content
           (\ x__ y__ -> x__ {_ReadReq'Options'UUIDOption'content = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadReq'Options'UUIDOption'Structured x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__
                 -> Prelude.fmap ReadReq'Options'UUIDOption'Structured y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField ReadReq'Options'UUIDOption "maybe'string" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'UUIDOption'content
           (\ x__ y__ -> x__ {_ReadReq'Options'UUIDOption'content = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadReq'Options'UUIDOption'String x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadReq'Options'UUIDOption'String y__))
instance Data.ProtoLens.Field.HasField ReadReq'Options'UUIDOption "string" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadReq'Options'UUIDOption'content
           (\ x__ y__ -> x__ {_ReadReq'Options'UUIDOption'content = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadReq'Options'UUIDOption'String x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadReq'Options'UUIDOption'String y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message ReadReq'Options'UUIDOption where
  messageName _
    = Data.Text.pack
        "event_store.client.streams.ReadReq.Options.UUIDOption"
  packedMessageDescriptor _
    = "\n\
      \\n\
      \UUIDOption\DC2;\n\
      \\n\
      \structured\CAN\SOH \SOH(\v2\EM.event_store.client.EmptyH\NULR\n\
      \structured\DC23\n\
      \\ACKstring\CAN\STX \SOH(\v2\EM.event_store.client.EmptyH\NULR\ACKstringB\t\n\
      \\acontent"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        structured__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "structured"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'structured")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options'UUIDOption
        string__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "string"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'string")) ::
              Data.ProtoLens.FieldDescriptor ReadReq'Options'UUIDOption
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, structured__field_descriptor),
           (Data.ProtoLens.Tag 2, string__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ReadReq'Options'UUIDOption'_unknownFields
        (\ x__ y__
           -> x__ {_ReadReq'Options'UUIDOption'_unknownFields = y__})
  defMessage
    = ReadReq'Options'UUIDOption'_constructor
        {_ReadReq'Options'UUIDOption'content = Prelude.Nothing,
         _ReadReq'Options'UUIDOption'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ReadReq'Options'UUIDOption
          -> Data.ProtoLens.Encoding.Bytes.Parser ReadReq'Options'UUIDOption
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
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
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
          (do loop Data.ProtoLens.defMessage) "UUIDOption"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'content") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just (ReadReq'Options'UUIDOption'Structured v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage v)
                (Prelude.Just (ReadReq'Options'UUIDOption'String v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData ReadReq'Options'UUIDOption where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ReadReq'Options'UUIDOption'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ReadReq'Options'UUIDOption'content x__) ())
instance Control.DeepSeq.NFData ReadReq'Options'UUIDOption'Content where
  rnf (ReadReq'Options'UUIDOption'Structured x__)
    = Control.DeepSeq.rnf x__
  rnf (ReadReq'Options'UUIDOption'String x__)
    = Control.DeepSeq.rnf x__
_ReadReq'Options'UUIDOption'Structured ::
  Data.ProtoLens.Prism.Prism' ReadReq'Options'UUIDOption'Content Proto.Shared.Empty
_ReadReq'Options'UUIDOption'Structured
  = Data.ProtoLens.Prism.prism'
      ReadReq'Options'UUIDOption'Structured
      (\ p__
         -> case p__ of
              (ReadReq'Options'UUIDOption'Structured p__val)
                -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_ReadReq'Options'UUIDOption'String ::
  Data.ProtoLens.Prism.Prism' ReadReq'Options'UUIDOption'Content Proto.Shared.Empty
_ReadReq'Options'UUIDOption'String
  = Data.ProtoLens.Prism.prism'
      ReadReq'Options'UUIDOption'String
      (\ p__
         -> case p__ of
              (ReadReq'Options'UUIDOption'String p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.Streams_Fields.maybe'content' @:: Lens' ReadResp (Prelude.Maybe ReadResp'Content)@
         * 'Proto.Streams_Fields.maybe'event' @:: Lens' ReadResp (Prelude.Maybe ReadResp'ReadEvent)@
         * 'Proto.Streams_Fields.event' @:: Lens' ReadResp ReadResp'ReadEvent@
         * 'Proto.Streams_Fields.maybe'confirmation' @:: Lens' ReadResp (Prelude.Maybe ReadResp'SubscriptionConfirmation)@
         * 'Proto.Streams_Fields.confirmation' @:: Lens' ReadResp ReadResp'SubscriptionConfirmation@
         * 'Proto.Streams_Fields.maybe'checkpoint' @:: Lens' ReadResp (Prelude.Maybe ReadResp'Checkpoint)@
         * 'Proto.Streams_Fields.checkpoint' @:: Lens' ReadResp ReadResp'Checkpoint@
         * 'Proto.Streams_Fields.maybe'streamNotFound' @:: Lens' ReadResp (Prelude.Maybe ReadResp'StreamNotFound)@
         * 'Proto.Streams_Fields.streamNotFound' @:: Lens' ReadResp ReadResp'StreamNotFound@
         * 'Proto.Streams_Fields.maybe'firstStreamPosition' @:: Lens' ReadResp (Prelude.Maybe Data.Word.Word64)@
         * 'Proto.Streams_Fields.firstStreamPosition' @:: Lens' ReadResp Data.Word.Word64@
         * 'Proto.Streams_Fields.maybe'lastStreamPosition' @:: Lens' ReadResp (Prelude.Maybe Data.Word.Word64)@
         * 'Proto.Streams_Fields.lastStreamPosition' @:: Lens' ReadResp Data.Word.Word64@
         * 'Proto.Streams_Fields.maybe'lastAllStreamPosition' @:: Lens' ReadResp (Prelude.Maybe Proto.Shared.AllStreamPosition)@
         * 'Proto.Streams_Fields.lastAllStreamPosition' @:: Lens' ReadResp Proto.Shared.AllStreamPosition@
         * 'Proto.Streams_Fields.maybe'caughtUp' @:: Lens' ReadResp (Prelude.Maybe ReadResp'CaughtUp)@
         * 'Proto.Streams_Fields.caughtUp' @:: Lens' ReadResp ReadResp'CaughtUp@
         * 'Proto.Streams_Fields.maybe'fellBehind' @:: Lens' ReadResp (Prelude.Maybe ReadResp'FellBehind)@
         * 'Proto.Streams_Fields.fellBehind' @:: Lens' ReadResp ReadResp'FellBehind@ -}
data ReadResp
  = ReadResp'_constructor {_ReadResp'content :: !(Prelude.Maybe ReadResp'Content),
                           _ReadResp'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ReadResp where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data ReadResp'Content
  = ReadResp'Event !ReadResp'ReadEvent |
    ReadResp'Confirmation !ReadResp'SubscriptionConfirmation |
    ReadResp'Checkpoint' !ReadResp'Checkpoint |
    ReadResp'StreamNotFound' !ReadResp'StreamNotFound |
    ReadResp'FirstStreamPosition !Data.Word.Word64 |
    ReadResp'LastStreamPosition !Data.Word.Word64 |
    ReadResp'LastAllStreamPosition !Proto.Shared.AllStreamPosition |
    ReadResp'CaughtUp' !ReadResp'CaughtUp |
    ReadResp'FellBehind' !ReadResp'FellBehind
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField ReadResp "maybe'content" (Prelude.Maybe ReadResp'Content) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'content (\ x__ y__ -> x__ {_ReadResp'content = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadResp "maybe'event" (Prelude.Maybe ReadResp'ReadEvent) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'content (\ x__ y__ -> x__ {_ReadResp'content = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadResp'Event x__val)) -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadResp'Event y__))
instance Data.ProtoLens.Field.HasField ReadResp "event" ReadResp'ReadEvent where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'content (\ x__ y__ -> x__ {_ReadResp'content = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadResp'Event x__val)) -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadResp'Event y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField ReadResp "maybe'confirmation" (Prelude.Maybe ReadResp'SubscriptionConfirmation) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'content (\ x__ y__ -> x__ {_ReadResp'content = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadResp'Confirmation x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadResp'Confirmation y__))
instance Data.ProtoLens.Field.HasField ReadResp "confirmation" ReadResp'SubscriptionConfirmation where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'content (\ x__ y__ -> x__ {_ReadResp'content = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadResp'Confirmation x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadResp'Confirmation y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField ReadResp "maybe'checkpoint" (Prelude.Maybe ReadResp'Checkpoint) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'content (\ x__ y__ -> x__ {_ReadResp'content = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadResp'Checkpoint' x__val)) -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadResp'Checkpoint' y__))
instance Data.ProtoLens.Field.HasField ReadResp "checkpoint" ReadResp'Checkpoint where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'content (\ x__ y__ -> x__ {_ReadResp'content = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadResp'Checkpoint' x__val)) -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadResp'Checkpoint' y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField ReadResp "maybe'streamNotFound" (Prelude.Maybe ReadResp'StreamNotFound) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'content (\ x__ y__ -> x__ {_ReadResp'content = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadResp'StreamNotFound' x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadResp'StreamNotFound' y__))
instance Data.ProtoLens.Field.HasField ReadResp "streamNotFound" ReadResp'StreamNotFound where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'content (\ x__ y__ -> x__ {_ReadResp'content = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadResp'StreamNotFound' x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadResp'StreamNotFound' y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField ReadResp "maybe'firstStreamPosition" (Prelude.Maybe Data.Word.Word64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'content (\ x__ y__ -> x__ {_ReadResp'content = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadResp'FirstStreamPosition x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadResp'FirstStreamPosition y__))
instance Data.ProtoLens.Field.HasField ReadResp "firstStreamPosition" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'content (\ x__ y__ -> x__ {_ReadResp'content = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadResp'FirstStreamPosition x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadResp'FirstStreamPosition y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Field.HasField ReadResp "maybe'lastStreamPosition" (Prelude.Maybe Data.Word.Word64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'content (\ x__ y__ -> x__ {_ReadResp'content = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadResp'LastStreamPosition x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadResp'LastStreamPosition y__))
instance Data.ProtoLens.Field.HasField ReadResp "lastStreamPosition" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'content (\ x__ y__ -> x__ {_ReadResp'content = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadResp'LastStreamPosition x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadResp'LastStreamPosition y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Field.HasField ReadResp "maybe'lastAllStreamPosition" (Prelude.Maybe Proto.Shared.AllStreamPosition) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'content (\ x__ y__ -> x__ {_ReadResp'content = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadResp'LastAllStreamPosition x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadResp'LastAllStreamPosition y__))
instance Data.ProtoLens.Field.HasField ReadResp "lastAllStreamPosition" Proto.Shared.AllStreamPosition where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'content (\ x__ y__ -> x__ {_ReadResp'content = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadResp'LastAllStreamPosition x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadResp'LastAllStreamPosition y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField ReadResp "maybe'caughtUp" (Prelude.Maybe ReadResp'CaughtUp) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'content (\ x__ y__ -> x__ {_ReadResp'content = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadResp'CaughtUp' x__val)) -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadResp'CaughtUp' y__))
instance Data.ProtoLens.Field.HasField ReadResp "caughtUp" ReadResp'CaughtUp where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'content (\ x__ y__ -> x__ {_ReadResp'content = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadResp'CaughtUp' x__val)) -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadResp'CaughtUp' y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField ReadResp "maybe'fellBehind" (Prelude.Maybe ReadResp'FellBehind) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'content (\ x__ y__ -> x__ {_ReadResp'content = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadResp'FellBehind' x__val)) -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadResp'FellBehind' y__))
instance Data.ProtoLens.Field.HasField ReadResp "fellBehind" ReadResp'FellBehind where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'content (\ x__ y__ -> x__ {_ReadResp'content = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadResp'FellBehind' x__val)) -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadResp'FellBehind' y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message ReadResp where
  messageName _
    = Data.Text.pack "event_store.client.streams.ReadResp"
  packedMessageDescriptor _
    = "\n\
      \\bReadResp\DC2F\n\
      \\ENQevent\CAN\SOH \SOH(\v2..event_store.client.streams.ReadResp.ReadEventH\NULR\ENQevent\DC2c\n\
      \\fconfirmation\CAN\STX \SOH(\v2=.event_store.client.streams.ReadResp.SubscriptionConfirmationH\NULR\fconfirmation\DC2Q\n\
      \\n\
      \checkpoint\CAN\ETX \SOH(\v2/.event_store.client.streams.ReadResp.CheckpointH\NULR\n\
      \checkpoint\DC2_\n\
      \\DLEstream_not_found\CAN\EOT \SOH(\v23.event_store.client.streams.ReadResp.StreamNotFoundH\NULR\SOstreamNotFound\DC24\n\
      \\NAKfirst_stream_position\CAN\ENQ \SOH(\EOTH\NULR\DC3firstStreamPosition\DC22\n\
      \\DC4last_stream_position\CAN\ACK \SOH(\EOTH\NULR\DC2lastStreamPosition\DC2`\n\
      \\CANlast_all_stream_position\CAN\a \SOH(\v2%.event_store.client.AllStreamPositionH\NULR\NAKlastAllStreamPosition\DC2L\n\
      \\tcaught_up\CAN\b \SOH(\v2-.event_store.client.streams.ReadResp.CaughtUpH\NULR\bcaughtUp\DC2R\n\
      \\vfell_behind\CAN\t \SOH(\v2/.event_store.client.streams.ReadResp.FellBehindH\NULR\n\
      \fellBehind\SUB\227\SOH\n\
      \\bCaughtUp\DC28\n\
      \\ttimestamp\CAN\SOH \SOH(\v2\SUB.google.protobuf.TimestampR\ttimestamp\DC2,\n\
      \\SIstream_revision\CAN\STX \SOH(\ETXH\NULR\SOstreamRevision\136\SOH\SOH\DC2N\n\
      \\bposition\CAN\ETX \SOH(\v2-.event_store.client.streams.ReadResp.PositionH\SOHR\bposition\136\SOH\SOHB\DC2\n\
      \\DLE_stream_revisionB\v\n\
      \\t_position\SUB\229\SOH\n\
      \\n\
      \FellBehind\DC28\n\
      \\ttimestamp\CAN\SOH \SOH(\v2\SUB.google.protobuf.TimestampR\ttimestamp\DC2,\n\
      \\SIstream_revision\CAN\STX \SOH(\ETXH\NULR\SOstreamRevision\136\SOH\SOH\DC2N\n\
      \\bposition\CAN\ETX \SOH(\v2-.event_store.client.streams.ReadResp.PositionH\SOHR\bposition\136\SOH\SOHB\DC2\n\
      \\DLE_stream_revisionB\v\n\
      \\t_position\SUB\148\ACK\n\
      \\tReadEvent\DC2R\n\
      \\ENQevent\CAN\SOH \SOH(\v2<.event_store.client.streams.ReadResp.ReadEvent.RecordedEventR\ENQevent\DC2P\n\
      \\EOTlink\CAN\STX \SOH(\v2<.event_store.client.streams.ReadResp.ReadEvent.RecordedEventR\EOTlink\DC2)\n\
      \\SIcommit_position\CAN\ETX \SOH(\EOTH\NULR\SOcommitPosition\DC2<\n\
      \\vno_position\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\NULR\n\
      \noPosition\SUB\235\ETX\n\
      \\rRecordedEvent\DC2(\n\
      \\STXid\CAN\SOH \SOH(\v2\CAN.event_store.client.UUIDR\STXid\DC2Q\n\
      \\DC1stream_identifier\CAN\STX \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier\DC2'\n\
      \\SIstream_revision\CAN\ETX \SOH(\EOTR\SOstreamRevision\DC2)\n\
      \\DLEprepare_position\CAN\EOT \SOH(\EOTR\SIpreparePosition\DC2'\n\
      \\SIcommit_position\CAN\ENQ \SOH(\EOTR\SOcommitPosition\DC2f\n\
      \\bmetadata\CAN\ACK \ETX(\v2J.event_store.client.streams.ReadResp.ReadEvent.RecordedEvent.MetadataEntryR\bmetadata\DC2'\n\
      \\SIcustom_metadata\CAN\a \SOH(\fR\SOcustomMetadata\DC2\DC2\n\
      \\EOTdata\CAN\b \SOH(\fR\EOTdata\SUB;\n\
      \\rMetadataEntry\DC2\DLE\n\
      \\ETXkey\CAN\SOH \SOH(\tR\ETXkey\DC2\DC4\n\
      \\ENQvalue\CAN\STX \SOH(\tR\ENQvalue:\STX8\SOHB\n\
      \\n\
      \\bposition\SUBC\n\
      \\CANSubscriptionConfirmation\DC2'\n\
      \\SIsubscription_id\CAN\SOH \SOH(\tR\SOsubscriptionId\SUB\154\SOH\n\
      \\n\
      \Checkpoint\DC2'\n\
      \\SIcommit_position\CAN\SOH \SOH(\EOTR\SOcommitPosition\DC2)\n\
      \\DLEprepare_position\CAN\STX \SOH(\EOTR\SIpreparePosition\DC28\n\
      \\ttimestamp\CAN\ETX \SOH(\v2\SUB.google.protobuf.TimestampR\ttimestamp\SUB^\n\
      \\bPosition\DC2'\n\
      \\SIcommit_position\CAN\SOH \SOH(\EOTR\SOcommitPosition\DC2)\n\
      \\DLEprepare_position\CAN\STX \SOH(\EOTR\SIpreparePosition\SUBc\n\
      \\SOStreamNotFound\DC2Q\n\
      \\DC1stream_identifier\CAN\SOH \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifierB\t\n\
      \\acontent"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        event__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "event"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ReadResp'ReadEvent)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'event")) ::
              Data.ProtoLens.FieldDescriptor ReadResp
        confirmation__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "confirmation"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ReadResp'SubscriptionConfirmation)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'confirmation")) ::
              Data.ProtoLens.FieldDescriptor ReadResp
        checkpoint__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "checkpoint"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ReadResp'Checkpoint)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'checkpoint")) ::
              Data.ProtoLens.FieldDescriptor ReadResp
        streamNotFound__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stream_not_found"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ReadResp'StreamNotFound)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'streamNotFound")) ::
              Data.ProtoLens.FieldDescriptor ReadResp
        firstStreamPosition__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "first_stream_position"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'firstStreamPosition")) ::
              Data.ProtoLens.FieldDescriptor ReadResp
        lastStreamPosition__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "last_stream_position"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'lastStreamPosition")) ::
              Data.ProtoLens.FieldDescriptor ReadResp
        lastAllStreamPosition__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "last_all_stream_position"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.AllStreamPosition)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'lastAllStreamPosition")) ::
              Data.ProtoLens.FieldDescriptor ReadResp
        caughtUp__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "caught_up"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ReadResp'CaughtUp)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'caughtUp")) ::
              Data.ProtoLens.FieldDescriptor ReadResp
        fellBehind__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "fell_behind"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ReadResp'FellBehind)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'fellBehind")) ::
              Data.ProtoLens.FieldDescriptor ReadResp
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, event__field_descriptor),
           (Data.ProtoLens.Tag 2, confirmation__field_descriptor),
           (Data.ProtoLens.Tag 3, checkpoint__field_descriptor),
           (Data.ProtoLens.Tag 4, streamNotFound__field_descriptor),
           (Data.ProtoLens.Tag 5, firstStreamPosition__field_descriptor),
           (Data.ProtoLens.Tag 6, lastStreamPosition__field_descriptor),
           (Data.ProtoLens.Tag 7, lastAllStreamPosition__field_descriptor),
           (Data.ProtoLens.Tag 8, caughtUp__field_descriptor),
           (Data.ProtoLens.Tag 9, fellBehind__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ReadResp'_unknownFields
        (\ x__ y__ -> x__ {_ReadResp'_unknownFields = y__})
  defMessage
    = ReadResp'_constructor
        {_ReadResp'content = Prelude.Nothing,
         _ReadResp'_unknownFields = []}
  parseMessage
    = let
        loop :: ReadResp -> Data.ProtoLens.Encoding.Bytes.Parser ReadResp
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
                                       "event"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"event") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "confirmation"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"confirmation") y x)
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "checkpoint"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"checkpoint") y x)
                        34
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "stream_not_found"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"streamNotFound") y x)
                        40
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt
                                       "first_stream_position"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"firstStreamPosition") y x)
                        48
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt
                                       "last_stream_position"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"lastStreamPosition") y x)
                        58
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "last_all_stream_position"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"lastAllStreamPosition") y x)
                        66
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "caught_up"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"caughtUp") y x)
                        74
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "fell_behind"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"fellBehind") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "ReadResp"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'content") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just (ReadResp'Event v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage v)
                (Prelude.Just (ReadResp'Confirmation v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage v)
                (Prelude.Just (ReadResp'Checkpoint' v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage v)
                (Prelude.Just (ReadResp'StreamNotFound' v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 34)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage v)
                (Prelude.Just (ReadResp'FirstStreamPosition v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 40)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt v)
                (Prelude.Just (ReadResp'LastStreamPosition v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 48)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt v)
                (Prelude.Just (ReadResp'LastAllStreamPosition v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 58)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage v)
                (Prelude.Just (ReadResp'CaughtUp' v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 66)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage v)
                (Prelude.Just (ReadResp'FellBehind' v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 74)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData ReadResp where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ReadResp'_unknownFields x__)
             (Control.DeepSeq.deepseq (_ReadResp'content x__) ())
instance Control.DeepSeq.NFData ReadResp'Content where
  rnf (ReadResp'Event x__) = Control.DeepSeq.rnf x__
  rnf (ReadResp'Confirmation x__) = Control.DeepSeq.rnf x__
  rnf (ReadResp'Checkpoint' x__) = Control.DeepSeq.rnf x__
  rnf (ReadResp'StreamNotFound' x__) = Control.DeepSeq.rnf x__
  rnf (ReadResp'FirstStreamPosition x__) = Control.DeepSeq.rnf x__
  rnf (ReadResp'LastStreamPosition x__) = Control.DeepSeq.rnf x__
  rnf (ReadResp'LastAllStreamPosition x__) = Control.DeepSeq.rnf x__
  rnf (ReadResp'CaughtUp' x__) = Control.DeepSeq.rnf x__
  rnf (ReadResp'FellBehind' x__) = Control.DeepSeq.rnf x__
_ReadResp'Event ::
  Data.ProtoLens.Prism.Prism' ReadResp'Content ReadResp'ReadEvent
_ReadResp'Event
  = Data.ProtoLens.Prism.prism'
      ReadResp'Event
      (\ p__
         -> case p__ of
              (ReadResp'Event p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_ReadResp'Confirmation ::
  Data.ProtoLens.Prism.Prism' ReadResp'Content ReadResp'SubscriptionConfirmation
_ReadResp'Confirmation
  = Data.ProtoLens.Prism.prism'
      ReadResp'Confirmation
      (\ p__
         -> case p__ of
              (ReadResp'Confirmation p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_ReadResp'Checkpoint' ::
  Data.ProtoLens.Prism.Prism' ReadResp'Content ReadResp'Checkpoint
_ReadResp'Checkpoint'
  = Data.ProtoLens.Prism.prism'
      ReadResp'Checkpoint'
      (\ p__
         -> case p__ of
              (ReadResp'Checkpoint' p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_ReadResp'StreamNotFound' ::
  Data.ProtoLens.Prism.Prism' ReadResp'Content ReadResp'StreamNotFound
_ReadResp'StreamNotFound'
  = Data.ProtoLens.Prism.prism'
      ReadResp'StreamNotFound'
      (\ p__
         -> case p__ of
              (ReadResp'StreamNotFound' p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_ReadResp'FirstStreamPosition ::
  Data.ProtoLens.Prism.Prism' ReadResp'Content Data.Word.Word64
_ReadResp'FirstStreamPosition
  = Data.ProtoLens.Prism.prism'
      ReadResp'FirstStreamPosition
      (\ p__
         -> case p__ of
              (ReadResp'FirstStreamPosition p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_ReadResp'LastStreamPosition ::
  Data.ProtoLens.Prism.Prism' ReadResp'Content Data.Word.Word64
_ReadResp'LastStreamPosition
  = Data.ProtoLens.Prism.prism'
      ReadResp'LastStreamPosition
      (\ p__
         -> case p__ of
              (ReadResp'LastStreamPosition p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_ReadResp'LastAllStreamPosition ::
  Data.ProtoLens.Prism.Prism' ReadResp'Content Proto.Shared.AllStreamPosition
_ReadResp'LastAllStreamPosition
  = Data.ProtoLens.Prism.prism'
      ReadResp'LastAllStreamPosition
      (\ p__
         -> case p__ of
              (ReadResp'LastAllStreamPosition p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_ReadResp'CaughtUp' ::
  Data.ProtoLens.Prism.Prism' ReadResp'Content ReadResp'CaughtUp
_ReadResp'CaughtUp'
  = Data.ProtoLens.Prism.prism'
      ReadResp'CaughtUp'
      (\ p__
         -> case p__ of
              (ReadResp'CaughtUp' p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_ReadResp'FellBehind' ::
  Data.ProtoLens.Prism.Prism' ReadResp'Content ReadResp'FellBehind
_ReadResp'FellBehind'
  = Data.ProtoLens.Prism.prism'
      ReadResp'FellBehind'
      (\ p__
         -> case p__ of
              (ReadResp'FellBehind' p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.Streams_Fields.timestamp' @:: Lens' ReadResp'CaughtUp Proto.Google.Protobuf.Timestamp.Timestamp@
         * 'Proto.Streams_Fields.maybe'timestamp' @:: Lens' ReadResp'CaughtUp (Prelude.Maybe Proto.Google.Protobuf.Timestamp.Timestamp)@
         * 'Proto.Streams_Fields.streamRevision' @:: Lens' ReadResp'CaughtUp Data.Int.Int64@
         * 'Proto.Streams_Fields.maybe'streamRevision' @:: Lens' ReadResp'CaughtUp (Prelude.Maybe Data.Int.Int64)@
         * 'Proto.Streams_Fields.position' @:: Lens' ReadResp'CaughtUp ReadResp'Position@
         * 'Proto.Streams_Fields.maybe'position' @:: Lens' ReadResp'CaughtUp (Prelude.Maybe ReadResp'Position)@ -}
data ReadResp'CaughtUp
  = ReadResp'CaughtUp'_constructor {_ReadResp'CaughtUp'timestamp :: !(Prelude.Maybe Proto.Google.Protobuf.Timestamp.Timestamp),
                                    _ReadResp'CaughtUp'streamRevision :: !(Prelude.Maybe Data.Int.Int64),
                                    _ReadResp'CaughtUp'position :: !(Prelude.Maybe ReadResp'Position),
                                    _ReadResp'CaughtUp'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ReadResp'CaughtUp where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField ReadResp'CaughtUp "timestamp" Proto.Google.Protobuf.Timestamp.Timestamp where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'CaughtUp'timestamp
           (\ x__ y__ -> x__ {_ReadResp'CaughtUp'timestamp = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField ReadResp'CaughtUp "maybe'timestamp" (Prelude.Maybe Proto.Google.Protobuf.Timestamp.Timestamp) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'CaughtUp'timestamp
           (\ x__ y__ -> x__ {_ReadResp'CaughtUp'timestamp = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadResp'CaughtUp "streamRevision" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'CaughtUp'streamRevision
           (\ x__ y__ -> x__ {_ReadResp'CaughtUp'streamRevision = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault)
instance Data.ProtoLens.Field.HasField ReadResp'CaughtUp "maybe'streamRevision" (Prelude.Maybe Data.Int.Int64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'CaughtUp'streamRevision
           (\ x__ y__ -> x__ {_ReadResp'CaughtUp'streamRevision = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadResp'CaughtUp "position" ReadResp'Position where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'CaughtUp'position
           (\ x__ y__ -> x__ {_ReadResp'CaughtUp'position = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField ReadResp'CaughtUp "maybe'position" (Prelude.Maybe ReadResp'Position) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'CaughtUp'position
           (\ x__ y__ -> x__ {_ReadResp'CaughtUp'position = y__}))
        Prelude.id
instance Data.ProtoLens.Message ReadResp'CaughtUp where
  messageName _
    = Data.Text.pack "event_store.client.streams.ReadResp.CaughtUp"
  packedMessageDescriptor _
    = "\n\
      \\bCaughtUp\DC28\n\
      \\ttimestamp\CAN\SOH \SOH(\v2\SUB.google.protobuf.TimestampR\ttimestamp\DC2,\n\
      \\SIstream_revision\CAN\STX \SOH(\ETXH\NULR\SOstreamRevision\136\SOH\SOH\DC2N\n\
      \\bposition\CAN\ETX \SOH(\v2-.event_store.client.streams.ReadResp.PositionH\SOHR\bposition\136\SOH\SOHB\DC2\n\
      \\DLE_stream_revisionB\v\n\
      \\t_position"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        timestamp__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "timestamp"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Google.Protobuf.Timestamp.Timestamp)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'timestamp")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'CaughtUp
        streamRevision__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stream_revision"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'streamRevision")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'CaughtUp
        position__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "position"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ReadResp'Position)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'position")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'CaughtUp
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, timestamp__field_descriptor),
           (Data.ProtoLens.Tag 2, streamRevision__field_descriptor),
           (Data.ProtoLens.Tag 3, position__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ReadResp'CaughtUp'_unknownFields
        (\ x__ y__ -> x__ {_ReadResp'CaughtUp'_unknownFields = y__})
  defMessage
    = ReadResp'CaughtUp'_constructor
        {_ReadResp'CaughtUp'timestamp = Prelude.Nothing,
         _ReadResp'CaughtUp'streamRevision = Prelude.Nothing,
         _ReadResp'CaughtUp'position = Prelude.Nothing,
         _ReadResp'CaughtUp'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ReadResp'CaughtUp
          -> Data.ProtoLens.Encoding.Bytes.Parser ReadResp'CaughtUp
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
                                       "timestamp"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"timestamp") y x)
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "stream_revision"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"streamRevision") y x)
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "position"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"position") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "CaughtUp"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view
                    (Data.ProtoLens.Field.field @"maybe'timestamp") _x
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
             ((Data.Monoid.<>)
                (case
                     Lens.Family2.view
                       (Data.ProtoLens.Field.field @"maybe'streamRevision") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just _v)
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                          ((Prelude..)
                             Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                ((Data.Monoid.<>)
                   (case
                        Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'position") _x
                    of
                      Prelude.Nothing -> Data.Monoid.mempty
                      (Prelude.Just _v)
                        -> (Data.Monoid.<>)
                             (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                             ((Prelude..)
                                (\ bs
                                   -> (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt
                                           (Prelude.fromIntegral (Data.ByteString.length bs)))
                                        (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                Data.ProtoLens.encodeMessage _v))
                   (Data.ProtoLens.Encoding.Wire.buildFieldSet
                      (Lens.Family2.view Data.ProtoLens.unknownFields _x))))
instance Control.DeepSeq.NFData ReadResp'CaughtUp where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ReadResp'CaughtUp'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ReadResp'CaughtUp'timestamp x__)
                (Control.DeepSeq.deepseq
                   (_ReadResp'CaughtUp'streamRevision x__)
                   (Control.DeepSeq.deepseq (_ReadResp'CaughtUp'position x__) ())))
{- | Fields :
     
         * 'Proto.Streams_Fields.commitPosition' @:: Lens' ReadResp'Checkpoint Data.Word.Word64@
         * 'Proto.Streams_Fields.preparePosition' @:: Lens' ReadResp'Checkpoint Data.Word.Word64@
         * 'Proto.Streams_Fields.timestamp' @:: Lens' ReadResp'Checkpoint Proto.Google.Protobuf.Timestamp.Timestamp@
         * 'Proto.Streams_Fields.maybe'timestamp' @:: Lens' ReadResp'Checkpoint (Prelude.Maybe Proto.Google.Protobuf.Timestamp.Timestamp)@ -}
data ReadResp'Checkpoint
  = ReadResp'Checkpoint'_constructor {_ReadResp'Checkpoint'commitPosition :: !Data.Word.Word64,
                                      _ReadResp'Checkpoint'preparePosition :: !Data.Word.Word64,
                                      _ReadResp'Checkpoint'timestamp :: !(Prelude.Maybe Proto.Google.Protobuf.Timestamp.Timestamp),
                                      _ReadResp'Checkpoint'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ReadResp'Checkpoint where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField ReadResp'Checkpoint "commitPosition" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'Checkpoint'commitPosition
           (\ x__ y__ -> x__ {_ReadResp'Checkpoint'commitPosition = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadResp'Checkpoint "preparePosition" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'Checkpoint'preparePosition
           (\ x__ y__ -> x__ {_ReadResp'Checkpoint'preparePosition = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadResp'Checkpoint "timestamp" Proto.Google.Protobuf.Timestamp.Timestamp where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'Checkpoint'timestamp
           (\ x__ y__ -> x__ {_ReadResp'Checkpoint'timestamp = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField ReadResp'Checkpoint "maybe'timestamp" (Prelude.Maybe Proto.Google.Protobuf.Timestamp.Timestamp) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'Checkpoint'timestamp
           (\ x__ y__ -> x__ {_ReadResp'Checkpoint'timestamp = y__}))
        Prelude.id
instance Data.ProtoLens.Message ReadResp'Checkpoint where
  messageName _
    = Data.Text.pack "event_store.client.streams.ReadResp.Checkpoint"
  packedMessageDescriptor _
    = "\n\
      \\n\
      \Checkpoint\DC2'\n\
      \\SIcommit_position\CAN\SOH \SOH(\EOTR\SOcommitPosition\DC2)\n\
      \\DLEprepare_position\CAN\STX \SOH(\EOTR\SIpreparePosition\DC28\n\
      \\ttimestamp\CAN\ETX \SOH(\v2\SUB.google.protobuf.TimestampR\ttimestamp"
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
              Data.ProtoLens.FieldDescriptor ReadResp'Checkpoint
        preparePosition__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "prepare_position"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"preparePosition")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'Checkpoint
        timestamp__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "timestamp"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Google.Protobuf.Timestamp.Timestamp)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'timestamp")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'Checkpoint
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, commitPosition__field_descriptor),
           (Data.ProtoLens.Tag 2, preparePosition__field_descriptor),
           (Data.ProtoLens.Tag 3, timestamp__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ReadResp'Checkpoint'_unknownFields
        (\ x__ y__ -> x__ {_ReadResp'Checkpoint'_unknownFields = y__})
  defMessage
    = ReadResp'Checkpoint'_constructor
        {_ReadResp'Checkpoint'commitPosition = Data.ProtoLens.fieldDefault,
         _ReadResp'Checkpoint'preparePosition = Data.ProtoLens.fieldDefault,
         _ReadResp'Checkpoint'timestamp = Prelude.Nothing,
         _ReadResp'Checkpoint'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ReadResp'Checkpoint
          -> Data.ProtoLens.Encoding.Bytes.Parser ReadResp'Checkpoint
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
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "timestamp"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"timestamp") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Checkpoint"
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
                ((Data.Monoid.<>)
                   (case
                        Lens.Family2.view
                          (Data.ProtoLens.Field.field @"maybe'timestamp") _x
                    of
                      Prelude.Nothing -> Data.Monoid.mempty
                      (Prelude.Just _v)
                        -> (Data.Monoid.<>)
                             (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                             ((Prelude..)
                                (\ bs
                                   -> (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt
                                           (Prelude.fromIntegral (Data.ByteString.length bs)))
                                        (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                Data.ProtoLens.encodeMessage _v))
                   (Data.ProtoLens.Encoding.Wire.buildFieldSet
                      (Lens.Family2.view Data.ProtoLens.unknownFields _x))))
instance Control.DeepSeq.NFData ReadResp'Checkpoint where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ReadResp'Checkpoint'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ReadResp'Checkpoint'commitPosition x__)
                (Control.DeepSeq.deepseq
                   (_ReadResp'Checkpoint'preparePosition x__)
                   (Control.DeepSeq.deepseq (_ReadResp'Checkpoint'timestamp x__) ())))
{- | Fields :
     
         * 'Proto.Streams_Fields.timestamp' @:: Lens' ReadResp'FellBehind Proto.Google.Protobuf.Timestamp.Timestamp@
         * 'Proto.Streams_Fields.maybe'timestamp' @:: Lens' ReadResp'FellBehind (Prelude.Maybe Proto.Google.Protobuf.Timestamp.Timestamp)@
         * 'Proto.Streams_Fields.streamRevision' @:: Lens' ReadResp'FellBehind Data.Int.Int64@
         * 'Proto.Streams_Fields.maybe'streamRevision' @:: Lens' ReadResp'FellBehind (Prelude.Maybe Data.Int.Int64)@
         * 'Proto.Streams_Fields.position' @:: Lens' ReadResp'FellBehind ReadResp'Position@
         * 'Proto.Streams_Fields.maybe'position' @:: Lens' ReadResp'FellBehind (Prelude.Maybe ReadResp'Position)@ -}
data ReadResp'FellBehind
  = ReadResp'FellBehind'_constructor {_ReadResp'FellBehind'timestamp :: !(Prelude.Maybe Proto.Google.Protobuf.Timestamp.Timestamp),
                                      _ReadResp'FellBehind'streamRevision :: !(Prelude.Maybe Data.Int.Int64),
                                      _ReadResp'FellBehind'position :: !(Prelude.Maybe ReadResp'Position),
                                      _ReadResp'FellBehind'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ReadResp'FellBehind where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField ReadResp'FellBehind "timestamp" Proto.Google.Protobuf.Timestamp.Timestamp where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'FellBehind'timestamp
           (\ x__ y__ -> x__ {_ReadResp'FellBehind'timestamp = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField ReadResp'FellBehind "maybe'timestamp" (Prelude.Maybe Proto.Google.Protobuf.Timestamp.Timestamp) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'FellBehind'timestamp
           (\ x__ y__ -> x__ {_ReadResp'FellBehind'timestamp = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadResp'FellBehind "streamRevision" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'FellBehind'streamRevision
           (\ x__ y__ -> x__ {_ReadResp'FellBehind'streamRevision = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault)
instance Data.ProtoLens.Field.HasField ReadResp'FellBehind "maybe'streamRevision" (Prelude.Maybe Data.Int.Int64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'FellBehind'streamRevision
           (\ x__ y__ -> x__ {_ReadResp'FellBehind'streamRevision = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadResp'FellBehind "position" ReadResp'Position where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'FellBehind'position
           (\ x__ y__ -> x__ {_ReadResp'FellBehind'position = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField ReadResp'FellBehind "maybe'position" (Prelude.Maybe ReadResp'Position) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'FellBehind'position
           (\ x__ y__ -> x__ {_ReadResp'FellBehind'position = y__}))
        Prelude.id
instance Data.ProtoLens.Message ReadResp'FellBehind where
  messageName _
    = Data.Text.pack "event_store.client.streams.ReadResp.FellBehind"
  packedMessageDescriptor _
    = "\n\
      \\n\
      \FellBehind\DC28\n\
      \\ttimestamp\CAN\SOH \SOH(\v2\SUB.google.protobuf.TimestampR\ttimestamp\DC2,\n\
      \\SIstream_revision\CAN\STX \SOH(\ETXH\NULR\SOstreamRevision\136\SOH\SOH\DC2N\n\
      \\bposition\CAN\ETX \SOH(\v2-.event_store.client.streams.ReadResp.PositionH\SOHR\bposition\136\SOH\SOHB\DC2\n\
      \\DLE_stream_revisionB\v\n\
      \\t_position"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        timestamp__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "timestamp"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Google.Protobuf.Timestamp.Timestamp)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'timestamp")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'FellBehind
        streamRevision__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stream_revision"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'streamRevision")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'FellBehind
        position__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "position"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ReadResp'Position)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'position")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'FellBehind
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, timestamp__field_descriptor),
           (Data.ProtoLens.Tag 2, streamRevision__field_descriptor),
           (Data.ProtoLens.Tag 3, position__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ReadResp'FellBehind'_unknownFields
        (\ x__ y__ -> x__ {_ReadResp'FellBehind'_unknownFields = y__})
  defMessage
    = ReadResp'FellBehind'_constructor
        {_ReadResp'FellBehind'timestamp = Prelude.Nothing,
         _ReadResp'FellBehind'streamRevision = Prelude.Nothing,
         _ReadResp'FellBehind'position = Prelude.Nothing,
         _ReadResp'FellBehind'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ReadResp'FellBehind
          -> Data.ProtoLens.Encoding.Bytes.Parser ReadResp'FellBehind
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
                                       "timestamp"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"timestamp") y x)
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "stream_revision"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"streamRevision") y x)
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "position"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"position") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "FellBehind"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view
                    (Data.ProtoLens.Field.field @"maybe'timestamp") _x
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
             ((Data.Monoid.<>)
                (case
                     Lens.Family2.view
                       (Data.ProtoLens.Field.field @"maybe'streamRevision") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just _v)
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                          ((Prelude..)
                             Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                ((Data.Monoid.<>)
                   (case
                        Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'position") _x
                    of
                      Prelude.Nothing -> Data.Monoid.mempty
                      (Prelude.Just _v)
                        -> (Data.Monoid.<>)
                             (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                             ((Prelude..)
                                (\ bs
                                   -> (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt
                                           (Prelude.fromIntegral (Data.ByteString.length bs)))
                                        (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                Data.ProtoLens.encodeMessage _v))
                   (Data.ProtoLens.Encoding.Wire.buildFieldSet
                      (Lens.Family2.view Data.ProtoLens.unknownFields _x))))
instance Control.DeepSeq.NFData ReadResp'FellBehind where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ReadResp'FellBehind'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ReadResp'FellBehind'timestamp x__)
                (Control.DeepSeq.deepseq
                   (_ReadResp'FellBehind'streamRevision x__)
                   (Control.DeepSeq.deepseq (_ReadResp'FellBehind'position x__) ())))
{- | Fields :
     
         * 'Proto.Streams_Fields.commitPosition' @:: Lens' ReadResp'Position Data.Word.Word64@
         * 'Proto.Streams_Fields.preparePosition' @:: Lens' ReadResp'Position Data.Word.Word64@ -}
data ReadResp'Position
  = ReadResp'Position'_constructor {_ReadResp'Position'commitPosition :: !Data.Word.Word64,
                                    _ReadResp'Position'preparePosition :: !Data.Word.Word64,
                                    _ReadResp'Position'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ReadResp'Position where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField ReadResp'Position "commitPosition" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'Position'commitPosition
           (\ x__ y__ -> x__ {_ReadResp'Position'commitPosition = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadResp'Position "preparePosition" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'Position'preparePosition
           (\ x__ y__ -> x__ {_ReadResp'Position'preparePosition = y__}))
        Prelude.id
instance Data.ProtoLens.Message ReadResp'Position where
  messageName _
    = Data.Text.pack "event_store.client.streams.ReadResp.Position"
  packedMessageDescriptor _
    = "\n\
      \\bPosition\DC2'\n\
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
              Data.ProtoLens.FieldDescriptor ReadResp'Position
        preparePosition__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "prepare_position"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"preparePosition")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'Position
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, commitPosition__field_descriptor),
           (Data.ProtoLens.Tag 2, preparePosition__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ReadResp'Position'_unknownFields
        (\ x__ y__ -> x__ {_ReadResp'Position'_unknownFields = y__})
  defMessage
    = ReadResp'Position'_constructor
        {_ReadResp'Position'commitPosition = Data.ProtoLens.fieldDefault,
         _ReadResp'Position'preparePosition = Data.ProtoLens.fieldDefault,
         _ReadResp'Position'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ReadResp'Position
          -> Data.ProtoLens.Encoding.Bytes.Parser ReadResp'Position
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
          (do loop Data.ProtoLens.defMessage) "Position"
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
instance Control.DeepSeq.NFData ReadResp'Position where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ReadResp'Position'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ReadResp'Position'commitPosition x__)
                (Control.DeepSeq.deepseq
                   (_ReadResp'Position'preparePosition x__) ()))
{- | Fields :
     
         * 'Proto.Streams_Fields.event' @:: Lens' ReadResp'ReadEvent ReadResp'ReadEvent'RecordedEvent@
         * 'Proto.Streams_Fields.maybe'event' @:: Lens' ReadResp'ReadEvent (Prelude.Maybe ReadResp'ReadEvent'RecordedEvent)@
         * 'Proto.Streams_Fields.link' @:: Lens' ReadResp'ReadEvent ReadResp'ReadEvent'RecordedEvent@
         * 'Proto.Streams_Fields.maybe'link' @:: Lens' ReadResp'ReadEvent (Prelude.Maybe ReadResp'ReadEvent'RecordedEvent)@
         * 'Proto.Streams_Fields.maybe'position' @:: Lens' ReadResp'ReadEvent (Prelude.Maybe ReadResp'ReadEvent'Position)@
         * 'Proto.Streams_Fields.maybe'commitPosition' @:: Lens' ReadResp'ReadEvent (Prelude.Maybe Data.Word.Word64)@
         * 'Proto.Streams_Fields.commitPosition' @:: Lens' ReadResp'ReadEvent Data.Word.Word64@
         * 'Proto.Streams_Fields.maybe'noPosition' @:: Lens' ReadResp'ReadEvent (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.noPosition' @:: Lens' ReadResp'ReadEvent Proto.Shared.Empty@ -}
data ReadResp'ReadEvent
  = ReadResp'ReadEvent'_constructor {_ReadResp'ReadEvent'event :: !(Prelude.Maybe ReadResp'ReadEvent'RecordedEvent),
                                     _ReadResp'ReadEvent'link :: !(Prelude.Maybe ReadResp'ReadEvent'RecordedEvent),
                                     _ReadResp'ReadEvent'position :: !(Prelude.Maybe ReadResp'ReadEvent'Position),
                                     _ReadResp'ReadEvent'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ReadResp'ReadEvent where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data ReadResp'ReadEvent'Position
  = ReadResp'ReadEvent'CommitPosition !Data.Word.Word64 |
    ReadResp'ReadEvent'NoPosition !Proto.Shared.Empty
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField ReadResp'ReadEvent "event" ReadResp'ReadEvent'RecordedEvent where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'ReadEvent'event
           (\ x__ y__ -> x__ {_ReadResp'ReadEvent'event = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField ReadResp'ReadEvent "maybe'event" (Prelude.Maybe ReadResp'ReadEvent'RecordedEvent) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'ReadEvent'event
           (\ x__ y__ -> x__ {_ReadResp'ReadEvent'event = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadResp'ReadEvent "link" ReadResp'ReadEvent'RecordedEvent where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'ReadEvent'link
           (\ x__ y__ -> x__ {_ReadResp'ReadEvent'link = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField ReadResp'ReadEvent "maybe'link" (Prelude.Maybe ReadResp'ReadEvent'RecordedEvent) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'ReadEvent'link
           (\ x__ y__ -> x__ {_ReadResp'ReadEvent'link = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadResp'ReadEvent "maybe'position" (Prelude.Maybe ReadResp'ReadEvent'Position) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'ReadEvent'position
           (\ x__ y__ -> x__ {_ReadResp'ReadEvent'position = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadResp'ReadEvent "maybe'commitPosition" (Prelude.Maybe Data.Word.Word64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'ReadEvent'position
           (\ x__ y__ -> x__ {_ReadResp'ReadEvent'position = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadResp'ReadEvent'CommitPosition x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadResp'ReadEvent'CommitPosition y__))
instance Data.ProtoLens.Field.HasField ReadResp'ReadEvent "commitPosition" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'ReadEvent'position
           (\ x__ y__ -> x__ {_ReadResp'ReadEvent'position = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadResp'ReadEvent'CommitPosition x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadResp'ReadEvent'CommitPosition y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Field.HasField ReadResp'ReadEvent "maybe'noPosition" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'ReadEvent'position
           (\ x__ y__ -> x__ {_ReadResp'ReadEvent'position = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (ReadResp'ReadEvent'NoPosition x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap ReadResp'ReadEvent'NoPosition y__))
instance Data.ProtoLens.Field.HasField ReadResp'ReadEvent "noPosition" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'ReadEvent'position
           (\ x__ y__ -> x__ {_ReadResp'ReadEvent'position = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (ReadResp'ReadEvent'NoPosition x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap ReadResp'ReadEvent'NoPosition y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message ReadResp'ReadEvent where
  messageName _
    = Data.Text.pack "event_store.client.streams.ReadResp.ReadEvent"
  packedMessageDescriptor _
    = "\n\
      \\tReadEvent\DC2R\n\
      \\ENQevent\CAN\SOH \SOH(\v2<.event_store.client.streams.ReadResp.ReadEvent.RecordedEventR\ENQevent\DC2P\n\
      \\EOTlink\CAN\STX \SOH(\v2<.event_store.client.streams.ReadResp.ReadEvent.RecordedEventR\EOTlink\DC2)\n\
      \\SIcommit_position\CAN\ETX \SOH(\EOTH\NULR\SOcommitPosition\DC2<\n\
      \\vno_position\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\NULR\n\
      \noPosition\SUB\235\ETX\n\
      \\rRecordedEvent\DC2(\n\
      \\STXid\CAN\SOH \SOH(\v2\CAN.event_store.client.UUIDR\STXid\DC2Q\n\
      \\DC1stream_identifier\CAN\STX \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier\DC2'\n\
      \\SIstream_revision\CAN\ETX \SOH(\EOTR\SOstreamRevision\DC2)\n\
      \\DLEprepare_position\CAN\EOT \SOH(\EOTR\SIpreparePosition\DC2'\n\
      \\SIcommit_position\CAN\ENQ \SOH(\EOTR\SOcommitPosition\DC2f\n\
      \\bmetadata\CAN\ACK \ETX(\v2J.event_store.client.streams.ReadResp.ReadEvent.RecordedEvent.MetadataEntryR\bmetadata\DC2'\n\
      \\SIcustom_metadata\CAN\a \SOH(\fR\SOcustomMetadata\DC2\DC2\n\
      \\EOTdata\CAN\b \SOH(\fR\EOTdata\SUB;\n\
      \\rMetadataEntry\DC2\DLE\n\
      \\ETXkey\CAN\SOH \SOH(\tR\ETXkey\DC2\DC4\n\
      \\ENQvalue\CAN\STX \SOH(\tR\ENQvalue:\STX8\SOHB\n\
      \\n\
      \\bposition"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        event__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "event"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ReadResp'ReadEvent'RecordedEvent)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'event")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'ReadEvent
        link__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "link"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ReadResp'ReadEvent'RecordedEvent)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'link")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'ReadEvent
        commitPosition__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "commit_position"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'commitPosition")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'ReadEvent
        noPosition__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "no_position"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'noPosition")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'ReadEvent
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, event__field_descriptor),
           (Data.ProtoLens.Tag 2, link__field_descriptor),
           (Data.ProtoLens.Tag 3, commitPosition__field_descriptor),
           (Data.ProtoLens.Tag 4, noPosition__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ReadResp'ReadEvent'_unknownFields
        (\ x__ y__ -> x__ {_ReadResp'ReadEvent'_unknownFields = y__})
  defMessage
    = ReadResp'ReadEvent'_constructor
        {_ReadResp'ReadEvent'event = Prelude.Nothing,
         _ReadResp'ReadEvent'link = Prelude.Nothing,
         _ReadResp'ReadEvent'position = Prelude.Nothing,
         _ReadResp'ReadEvent'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ReadResp'ReadEvent
          -> Data.ProtoLens.Encoding.Bytes.Parser ReadResp'ReadEvent
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
                                       "event"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"event") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "link"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"link") y x)
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "commit_position"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"commitPosition") y x)
                        34
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "no_position"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"noPosition") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "ReadEvent"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'event") _x
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
             ((Data.Monoid.<>)
                (case
                     Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'link") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just _v)
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage _v))
                ((Data.Monoid.<>)
                   (case
                        Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'position") _x
                    of
                      Prelude.Nothing -> Data.Monoid.mempty
                      (Prelude.Just (ReadResp'ReadEvent'CommitPosition v))
                        -> (Data.Monoid.<>)
                             (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                             (Data.ProtoLens.Encoding.Bytes.putVarInt v)
                      (Prelude.Just (ReadResp'ReadEvent'NoPosition v))
                        -> (Data.Monoid.<>)
                             (Data.ProtoLens.Encoding.Bytes.putVarInt 34)
                             ((Prelude..)
                                (\ bs
                                   -> (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt
                                           (Prelude.fromIntegral (Data.ByteString.length bs)))
                                        (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                Data.ProtoLens.encodeMessage v))
                   (Data.ProtoLens.Encoding.Wire.buildFieldSet
                      (Lens.Family2.view Data.ProtoLens.unknownFields _x))))
instance Control.DeepSeq.NFData ReadResp'ReadEvent where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ReadResp'ReadEvent'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ReadResp'ReadEvent'event x__)
                (Control.DeepSeq.deepseq
                   (_ReadResp'ReadEvent'link x__)
                   (Control.DeepSeq.deepseq (_ReadResp'ReadEvent'position x__) ())))
instance Control.DeepSeq.NFData ReadResp'ReadEvent'Position where
  rnf (ReadResp'ReadEvent'CommitPosition x__)
    = Control.DeepSeq.rnf x__
  rnf (ReadResp'ReadEvent'NoPosition x__) = Control.DeepSeq.rnf x__
_ReadResp'ReadEvent'CommitPosition ::
  Data.ProtoLens.Prism.Prism' ReadResp'ReadEvent'Position Data.Word.Word64
_ReadResp'ReadEvent'CommitPosition
  = Data.ProtoLens.Prism.prism'
      ReadResp'ReadEvent'CommitPosition
      (\ p__
         -> case p__ of
              (ReadResp'ReadEvent'CommitPosition p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_ReadResp'ReadEvent'NoPosition ::
  Data.ProtoLens.Prism.Prism' ReadResp'ReadEvent'Position Proto.Shared.Empty
_ReadResp'ReadEvent'NoPosition
  = Data.ProtoLens.Prism.prism'
      ReadResp'ReadEvent'NoPosition
      (\ p__
         -> case p__ of
              (ReadResp'ReadEvent'NoPosition p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.Streams_Fields.id' @:: Lens' ReadResp'ReadEvent'RecordedEvent Proto.Shared.UUID@
         * 'Proto.Streams_Fields.maybe'id' @:: Lens' ReadResp'ReadEvent'RecordedEvent (Prelude.Maybe Proto.Shared.UUID)@
         * 'Proto.Streams_Fields.streamIdentifier' @:: Lens' ReadResp'ReadEvent'RecordedEvent Proto.Shared.StreamIdentifier@
         * 'Proto.Streams_Fields.maybe'streamIdentifier' @:: Lens' ReadResp'ReadEvent'RecordedEvent (Prelude.Maybe Proto.Shared.StreamIdentifier)@
         * 'Proto.Streams_Fields.streamRevision' @:: Lens' ReadResp'ReadEvent'RecordedEvent Data.Word.Word64@
         * 'Proto.Streams_Fields.preparePosition' @:: Lens' ReadResp'ReadEvent'RecordedEvent Data.Word.Word64@
         * 'Proto.Streams_Fields.commitPosition' @:: Lens' ReadResp'ReadEvent'RecordedEvent Data.Word.Word64@
         * 'Proto.Streams_Fields.metadata' @:: Lens' ReadResp'ReadEvent'RecordedEvent (Data.Map.Map Data.Text.Text Data.Text.Text)@
         * 'Proto.Streams_Fields.customMetadata' @:: Lens' ReadResp'ReadEvent'RecordedEvent Data.ByteString.ByteString@
         * 'Proto.Streams_Fields.data'' @:: Lens' ReadResp'ReadEvent'RecordedEvent Data.ByteString.ByteString@ -}
data ReadResp'ReadEvent'RecordedEvent
  = ReadResp'ReadEvent'RecordedEvent'_constructor {_ReadResp'ReadEvent'RecordedEvent'id :: !(Prelude.Maybe Proto.Shared.UUID),
                                                   _ReadResp'ReadEvent'RecordedEvent'streamIdentifier :: !(Prelude.Maybe Proto.Shared.StreamIdentifier),
                                                   _ReadResp'ReadEvent'RecordedEvent'streamRevision :: !Data.Word.Word64,
                                                   _ReadResp'ReadEvent'RecordedEvent'preparePosition :: !Data.Word.Word64,
                                                   _ReadResp'ReadEvent'RecordedEvent'commitPosition :: !Data.Word.Word64,
                                                   _ReadResp'ReadEvent'RecordedEvent'metadata :: !(Data.Map.Map Data.Text.Text Data.Text.Text),
                                                   _ReadResp'ReadEvent'RecordedEvent'customMetadata :: !Data.ByteString.ByteString,
                                                   _ReadResp'ReadEvent'RecordedEvent'data' :: !Data.ByteString.ByteString,
                                                   _ReadResp'ReadEvent'RecordedEvent'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ReadResp'ReadEvent'RecordedEvent where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField ReadResp'ReadEvent'RecordedEvent "id" Proto.Shared.UUID where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'ReadEvent'RecordedEvent'id
           (\ x__ y__ -> x__ {_ReadResp'ReadEvent'RecordedEvent'id = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField ReadResp'ReadEvent'RecordedEvent "maybe'id" (Prelude.Maybe Proto.Shared.UUID) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'ReadEvent'RecordedEvent'id
           (\ x__ y__ -> x__ {_ReadResp'ReadEvent'RecordedEvent'id = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadResp'ReadEvent'RecordedEvent "streamIdentifier" Proto.Shared.StreamIdentifier where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'ReadEvent'RecordedEvent'streamIdentifier
           (\ x__ y__
              -> x__ {_ReadResp'ReadEvent'RecordedEvent'streamIdentifier = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField ReadResp'ReadEvent'RecordedEvent "maybe'streamIdentifier" (Prelude.Maybe Proto.Shared.StreamIdentifier) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'ReadEvent'RecordedEvent'streamIdentifier
           (\ x__ y__
              -> x__ {_ReadResp'ReadEvent'RecordedEvent'streamIdentifier = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadResp'ReadEvent'RecordedEvent "streamRevision" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'ReadEvent'RecordedEvent'streamRevision
           (\ x__ y__
              -> x__ {_ReadResp'ReadEvent'RecordedEvent'streamRevision = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadResp'ReadEvent'RecordedEvent "preparePosition" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'ReadEvent'RecordedEvent'preparePosition
           (\ x__ y__
              -> x__ {_ReadResp'ReadEvent'RecordedEvent'preparePosition = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadResp'ReadEvent'RecordedEvent "commitPosition" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'ReadEvent'RecordedEvent'commitPosition
           (\ x__ y__
              -> x__ {_ReadResp'ReadEvent'RecordedEvent'commitPosition = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadResp'ReadEvent'RecordedEvent "metadata" (Data.Map.Map Data.Text.Text Data.Text.Text) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'ReadEvent'RecordedEvent'metadata
           (\ x__ y__
              -> x__ {_ReadResp'ReadEvent'RecordedEvent'metadata = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadResp'ReadEvent'RecordedEvent "customMetadata" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'ReadEvent'RecordedEvent'customMetadata
           (\ x__ y__
              -> x__ {_ReadResp'ReadEvent'RecordedEvent'customMetadata = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadResp'ReadEvent'RecordedEvent "data'" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'ReadEvent'RecordedEvent'data'
           (\ x__ y__ -> x__ {_ReadResp'ReadEvent'RecordedEvent'data' = y__}))
        Prelude.id
instance Data.ProtoLens.Message ReadResp'ReadEvent'RecordedEvent where
  messageName _
    = Data.Text.pack
        "event_store.client.streams.ReadResp.ReadEvent.RecordedEvent"
  packedMessageDescriptor _
    = "\n\
      \\rRecordedEvent\DC2(\n\
      \\STXid\CAN\SOH \SOH(\v2\CAN.event_store.client.UUIDR\STXid\DC2Q\n\
      \\DC1stream_identifier\CAN\STX \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier\DC2'\n\
      \\SIstream_revision\CAN\ETX \SOH(\EOTR\SOstreamRevision\DC2)\n\
      \\DLEprepare_position\CAN\EOT \SOH(\EOTR\SIpreparePosition\DC2'\n\
      \\SIcommit_position\CAN\ENQ \SOH(\EOTR\SOcommitPosition\DC2f\n\
      \\bmetadata\CAN\ACK \ETX(\v2J.event_store.client.streams.ReadResp.ReadEvent.RecordedEvent.MetadataEntryR\bmetadata\DC2'\n\
      \\SIcustom_metadata\CAN\a \SOH(\fR\SOcustomMetadata\DC2\DC2\n\
      \\EOTdata\CAN\b \SOH(\fR\EOTdata\SUB;\n\
      \\rMetadataEntry\DC2\DLE\n\
      \\ETXkey\CAN\SOH \SOH(\tR\ETXkey\DC2\DC4\n\
      \\ENQvalue\CAN\STX \SOH(\tR\ENQvalue:\STX8\SOH"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        id__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "id"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.UUID)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'id")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'ReadEvent'RecordedEvent
        streamIdentifier__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stream_identifier"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.StreamIdentifier)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'streamIdentifier")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'ReadEvent'RecordedEvent
        streamRevision__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stream_revision"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"streamRevision")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'ReadEvent'RecordedEvent
        preparePosition__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "prepare_position"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"preparePosition")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'ReadEvent'RecordedEvent
        commitPosition__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "commit_position"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"commitPosition")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'ReadEvent'RecordedEvent
        metadata__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "metadata"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ReadResp'ReadEvent'RecordedEvent'MetadataEntry)
              (Data.ProtoLens.MapField
                 (Data.ProtoLens.Field.field @"key")
                 (Data.ProtoLens.Field.field @"value")
                 (Data.ProtoLens.Field.field @"metadata")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'ReadEvent'RecordedEvent
        customMetadata__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "custom_metadata"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"customMetadata")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'ReadEvent'RecordedEvent
        data'__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "data"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"data'")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'ReadEvent'RecordedEvent
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, id__field_descriptor),
           (Data.ProtoLens.Tag 2, streamIdentifier__field_descriptor),
           (Data.ProtoLens.Tag 3, streamRevision__field_descriptor),
           (Data.ProtoLens.Tag 4, preparePosition__field_descriptor),
           (Data.ProtoLens.Tag 5, commitPosition__field_descriptor),
           (Data.ProtoLens.Tag 6, metadata__field_descriptor),
           (Data.ProtoLens.Tag 7, customMetadata__field_descriptor),
           (Data.ProtoLens.Tag 8, data'__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ReadResp'ReadEvent'RecordedEvent'_unknownFields
        (\ x__ y__
           -> x__ {_ReadResp'ReadEvent'RecordedEvent'_unknownFields = y__})
  defMessage
    = ReadResp'ReadEvent'RecordedEvent'_constructor
        {_ReadResp'ReadEvent'RecordedEvent'id = Prelude.Nothing,
         _ReadResp'ReadEvent'RecordedEvent'streamIdentifier = Prelude.Nothing,
         _ReadResp'ReadEvent'RecordedEvent'streamRevision = Data.ProtoLens.fieldDefault,
         _ReadResp'ReadEvent'RecordedEvent'preparePosition = Data.ProtoLens.fieldDefault,
         _ReadResp'ReadEvent'RecordedEvent'commitPosition = Data.ProtoLens.fieldDefault,
         _ReadResp'ReadEvent'RecordedEvent'metadata = Data.Map.empty,
         _ReadResp'ReadEvent'RecordedEvent'customMetadata = Data.ProtoLens.fieldDefault,
         _ReadResp'ReadEvent'RecordedEvent'data' = Data.ProtoLens.fieldDefault,
         _ReadResp'ReadEvent'RecordedEvent'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ReadResp'ReadEvent'RecordedEvent
          -> Data.ProtoLens.Encoding.Bytes.Parser ReadResp'ReadEvent'RecordedEvent
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
                                       "id"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"id") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "stream_identifier"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"streamIdentifier") y x)
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "stream_revision"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"streamRevision") y x)
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "prepare_position"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"preparePosition") y x)
                        40
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "commit_position"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"commitPosition") y x)
                        50
                          -> do !(entry :: ReadResp'ReadEvent'RecordedEvent'MetadataEntry) <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                                                                                (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                                                                                    Data.ProtoLens.Encoding.Bytes.isolate
                                                                                                      (Prelude.fromIntegral
                                                                                                         len)
                                                                                                      Data.ProtoLens.parseMessage)
                                                                                                "metadata"
                                (let
                                   key = Lens.Family2.view (Data.ProtoLens.Field.field @"key") entry
                                   value
                                     = Lens.Family2.view (Data.ProtoLens.Field.field @"value") entry
                                 in
                                   loop
                                     (Lens.Family2.over
                                        (Data.ProtoLens.Field.field @"metadata")
                                        (\ !t -> Data.Map.insert key value t) x))
                        58
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "custom_metadata"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"customMetadata") y x)
                        66
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "data"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"data'") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "RecordedEvent"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'id") _x
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
             ((Data.Monoid.<>)
                (case
                     Lens.Family2.view
                       (Data.ProtoLens.Field.field @"maybe'streamIdentifier") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just _v)
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage _v))
                ((Data.Monoid.<>)
                   (let
                      _v
                        = Lens.Family2.view
                            (Data.ProtoLens.Field.field @"streamRevision") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
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
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
                      ((Data.Monoid.<>)
                         (let
                            _v
                              = Lens.Family2.view
                                  (Data.ProtoLens.Field.field @"commitPosition") _x
                          in
                            if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                Data.Monoid.mempty
                            else
                                (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt 40)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
                         ((Data.Monoid.<>)
                            (Data.Monoid.mconcat
                               (Prelude.map
                                  (\ _v
                                     -> (Data.Monoid.<>)
                                          (Data.ProtoLens.Encoding.Bytes.putVarInt 50)
                                          ((Prelude..)
                                             (\ bs
                                                -> (Data.Monoid.<>)
                                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                        (Prelude.fromIntegral
                                                           (Data.ByteString.length bs)))
                                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                             Data.ProtoLens.encodeMessage
                                             (Lens.Family2.set
                                                (Data.ProtoLens.Field.field @"key") (Prelude.fst _v)
                                                (Lens.Family2.set
                                                   (Data.ProtoLens.Field.field @"value")
                                                   (Prelude.snd _v)
                                                   (Data.ProtoLens.defMessage ::
                                                      ReadResp'ReadEvent'RecordedEvent'MetadataEntry)))))
                                  (Data.Map.toList
                                     (Lens.Family2.view
                                        (Data.ProtoLens.Field.field @"metadata") _x))))
                            ((Data.Monoid.<>)
                               (let
                                  _v
                                    = Lens.Family2.view
                                        (Data.ProtoLens.Field.field @"customMetadata") _x
                                in
                                  if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                      Data.Monoid.mempty
                                  else
                                      (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt 58)
                                        ((\ bs
                                            -> (Data.Monoid.<>)
                                                 (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                    (Prelude.fromIntegral
                                                       (Data.ByteString.length bs)))
                                                 (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                           _v))
                               ((Data.Monoid.<>)
                                  (let
                                     _v = Lens.Family2.view (Data.ProtoLens.Field.field @"data'") _x
                                   in
                                     if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                         Data.Monoid.mempty
                                     else
                                         (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt 66)
                                           ((\ bs
                                               -> (Data.Monoid.<>)
                                                    (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                       (Prelude.fromIntegral
                                                          (Data.ByteString.length bs)))
                                                    (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                              _v))
                                  (Data.ProtoLens.Encoding.Wire.buildFieldSet
                                     (Lens.Family2.view Data.ProtoLens.unknownFields _x)))))))))
instance Control.DeepSeq.NFData ReadResp'ReadEvent'RecordedEvent where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ReadResp'ReadEvent'RecordedEvent'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ReadResp'ReadEvent'RecordedEvent'id x__)
                (Control.DeepSeq.deepseq
                   (_ReadResp'ReadEvent'RecordedEvent'streamIdentifier x__)
                   (Control.DeepSeq.deepseq
                      (_ReadResp'ReadEvent'RecordedEvent'streamRevision x__)
                      (Control.DeepSeq.deepseq
                         (_ReadResp'ReadEvent'RecordedEvent'preparePosition x__)
                         (Control.DeepSeq.deepseq
                            (_ReadResp'ReadEvent'RecordedEvent'commitPosition x__)
                            (Control.DeepSeq.deepseq
                               (_ReadResp'ReadEvent'RecordedEvent'metadata x__)
                               (Control.DeepSeq.deepseq
                                  (_ReadResp'ReadEvent'RecordedEvent'customMetadata x__)
                                  (Control.DeepSeq.deepseq
                                     (_ReadResp'ReadEvent'RecordedEvent'data' x__) ()))))))))
{- | Fields :
     
         * 'Proto.Streams_Fields.key' @:: Lens' ReadResp'ReadEvent'RecordedEvent'MetadataEntry Data.Text.Text@
         * 'Proto.Streams_Fields.value' @:: Lens' ReadResp'ReadEvent'RecordedEvent'MetadataEntry Data.Text.Text@ -}
data ReadResp'ReadEvent'RecordedEvent'MetadataEntry
  = ReadResp'ReadEvent'RecordedEvent'MetadataEntry'_constructor {_ReadResp'ReadEvent'RecordedEvent'MetadataEntry'key :: !Data.Text.Text,
                                                                 _ReadResp'ReadEvent'RecordedEvent'MetadataEntry'value :: !Data.Text.Text,
                                                                 _ReadResp'ReadEvent'RecordedEvent'MetadataEntry'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ReadResp'ReadEvent'RecordedEvent'MetadataEntry where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField ReadResp'ReadEvent'RecordedEvent'MetadataEntry "key" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'ReadEvent'RecordedEvent'MetadataEntry'key
           (\ x__ y__
              -> x__
                   {_ReadResp'ReadEvent'RecordedEvent'MetadataEntry'key = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ReadResp'ReadEvent'RecordedEvent'MetadataEntry "value" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'ReadEvent'RecordedEvent'MetadataEntry'value
           (\ x__ y__
              -> x__
                   {_ReadResp'ReadEvent'RecordedEvent'MetadataEntry'value = y__}))
        Prelude.id
instance Data.ProtoLens.Message ReadResp'ReadEvent'RecordedEvent'MetadataEntry where
  messageName _
    = Data.Text.pack
        "event_store.client.streams.ReadResp.ReadEvent.RecordedEvent.MetadataEntry"
  packedMessageDescriptor _
    = "\n\
      \\rMetadataEntry\DC2\DLE\n\
      \\ETXkey\CAN\SOH \SOH(\tR\ETXkey\DC2\DC4\n\
      \\ENQvalue\CAN\STX \SOH(\tR\ENQvalue:\STX8\SOH"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        key__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "key"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"key")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'ReadEvent'RecordedEvent'MetadataEntry
        value__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "value"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"value")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'ReadEvent'RecordedEvent'MetadataEntry
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, key__field_descriptor),
           (Data.ProtoLens.Tag 2, value__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ReadResp'ReadEvent'RecordedEvent'MetadataEntry'_unknownFields
        (\ x__ y__
           -> x__
                {_ReadResp'ReadEvent'RecordedEvent'MetadataEntry'_unknownFields = y__})
  defMessage
    = ReadResp'ReadEvent'RecordedEvent'MetadataEntry'_constructor
        {_ReadResp'ReadEvent'RecordedEvent'MetadataEntry'key = Data.ProtoLens.fieldDefault,
         _ReadResp'ReadEvent'RecordedEvent'MetadataEntry'value = Data.ProtoLens.fieldDefault,
         _ReadResp'ReadEvent'RecordedEvent'MetadataEntry'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ReadResp'ReadEvent'RecordedEvent'MetadataEntry
          -> Data.ProtoLens.Encoding.Bytes.Parser ReadResp'ReadEvent'RecordedEvent'MetadataEntry
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
                                       "key"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"key") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getText
                                             (Prelude.fromIntegral len))
                                       "value"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"value") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "MetadataEntry"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"key") _x
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
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"value") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                         ((Prelude..)
                            (\ bs
                               -> (Data.Monoid.<>)
                                    (Data.ProtoLens.Encoding.Bytes.putVarInt
                                       (Prelude.fromIntegral (Data.ByteString.length bs)))
                                    (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                            Data.Text.Encoding.encodeUtf8 _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData ReadResp'ReadEvent'RecordedEvent'MetadataEntry where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ReadResp'ReadEvent'RecordedEvent'MetadataEntry'_unknownFields
                x__)
             (Control.DeepSeq.deepseq
                (_ReadResp'ReadEvent'RecordedEvent'MetadataEntry'key x__)
                (Control.DeepSeq.deepseq
                   (_ReadResp'ReadEvent'RecordedEvent'MetadataEntry'value x__) ()))
{- | Fields :
     
         * 'Proto.Streams_Fields.streamIdentifier' @:: Lens' ReadResp'StreamNotFound Proto.Shared.StreamIdentifier@
         * 'Proto.Streams_Fields.maybe'streamIdentifier' @:: Lens' ReadResp'StreamNotFound (Prelude.Maybe Proto.Shared.StreamIdentifier)@ -}
data ReadResp'StreamNotFound
  = ReadResp'StreamNotFound'_constructor {_ReadResp'StreamNotFound'streamIdentifier :: !(Prelude.Maybe Proto.Shared.StreamIdentifier),
                                          _ReadResp'StreamNotFound'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ReadResp'StreamNotFound where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField ReadResp'StreamNotFound "streamIdentifier" Proto.Shared.StreamIdentifier where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'StreamNotFound'streamIdentifier
           (\ x__ y__
              -> x__ {_ReadResp'StreamNotFound'streamIdentifier = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField ReadResp'StreamNotFound "maybe'streamIdentifier" (Prelude.Maybe Proto.Shared.StreamIdentifier) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'StreamNotFound'streamIdentifier
           (\ x__ y__
              -> x__ {_ReadResp'StreamNotFound'streamIdentifier = y__}))
        Prelude.id
instance Data.ProtoLens.Message ReadResp'StreamNotFound where
  messageName _
    = Data.Text.pack
        "event_store.client.streams.ReadResp.StreamNotFound"
  packedMessageDescriptor _
    = "\n\
      \\SOStreamNotFound\DC2Q\n\
      \\DC1stream_identifier\CAN\SOH \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        streamIdentifier__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stream_identifier"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.StreamIdentifier)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'streamIdentifier")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'StreamNotFound
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, streamIdentifier__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ReadResp'StreamNotFound'_unknownFields
        (\ x__ y__ -> x__ {_ReadResp'StreamNotFound'_unknownFields = y__})
  defMessage
    = ReadResp'StreamNotFound'_constructor
        {_ReadResp'StreamNotFound'streamIdentifier = Prelude.Nothing,
         _ReadResp'StreamNotFound'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ReadResp'StreamNotFound
          -> Data.ProtoLens.Encoding.Bytes.Parser ReadResp'StreamNotFound
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
          (do loop Data.ProtoLens.defMessage) "StreamNotFound"
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
instance Control.DeepSeq.NFData ReadResp'StreamNotFound where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ReadResp'StreamNotFound'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ReadResp'StreamNotFound'streamIdentifier x__) ())
{- | Fields :
     
         * 'Proto.Streams_Fields.subscriptionId' @:: Lens' ReadResp'SubscriptionConfirmation Data.Text.Text@ -}
data ReadResp'SubscriptionConfirmation
  = ReadResp'SubscriptionConfirmation'_constructor {_ReadResp'SubscriptionConfirmation'subscriptionId :: !Data.Text.Text,
                                                    _ReadResp'SubscriptionConfirmation'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ReadResp'SubscriptionConfirmation where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField ReadResp'SubscriptionConfirmation "subscriptionId" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ReadResp'SubscriptionConfirmation'subscriptionId
           (\ x__ y__
              -> x__ {_ReadResp'SubscriptionConfirmation'subscriptionId = y__}))
        Prelude.id
instance Data.ProtoLens.Message ReadResp'SubscriptionConfirmation where
  messageName _
    = Data.Text.pack
        "event_store.client.streams.ReadResp.SubscriptionConfirmation"
  packedMessageDescriptor _
    = "\n\
      \\CANSubscriptionConfirmation\DC2'\n\
      \\SIsubscription_id\CAN\SOH \SOH(\tR\SOsubscriptionId"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        subscriptionId__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "subscription_id"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"subscriptionId")) ::
              Data.ProtoLens.FieldDescriptor ReadResp'SubscriptionConfirmation
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, subscriptionId__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ReadResp'SubscriptionConfirmation'_unknownFields
        (\ x__ y__
           -> x__ {_ReadResp'SubscriptionConfirmation'_unknownFields = y__})
  defMessage
    = ReadResp'SubscriptionConfirmation'_constructor
        {_ReadResp'SubscriptionConfirmation'subscriptionId = Data.ProtoLens.fieldDefault,
         _ReadResp'SubscriptionConfirmation'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ReadResp'SubscriptionConfirmation
          -> Data.ProtoLens.Encoding.Bytes.Parser ReadResp'SubscriptionConfirmation
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
                                       "subscription_id"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"subscriptionId") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "SubscriptionConfirmation"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view
                      (Data.ProtoLens.Field.field @"subscriptionId") _x
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
instance Control.DeepSeq.NFData ReadResp'SubscriptionConfirmation where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ReadResp'SubscriptionConfirmation'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ReadResp'SubscriptionConfirmation'subscriptionId x__) ())
{- | Fields :
     
         * 'Proto.Streams_Fields.options' @:: Lens' TombstoneReq TombstoneReq'Options@
         * 'Proto.Streams_Fields.maybe'options' @:: Lens' TombstoneReq (Prelude.Maybe TombstoneReq'Options)@ -}
data TombstoneReq
  = TombstoneReq'_constructor {_TombstoneReq'options :: !(Prelude.Maybe TombstoneReq'Options),
                               _TombstoneReq'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show TombstoneReq where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField TombstoneReq "options" TombstoneReq'Options where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TombstoneReq'options
           (\ x__ y__ -> x__ {_TombstoneReq'options = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField TombstoneReq "maybe'options" (Prelude.Maybe TombstoneReq'Options) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TombstoneReq'options
           (\ x__ y__ -> x__ {_TombstoneReq'options = y__}))
        Prelude.id
instance Data.ProtoLens.Message TombstoneReq where
  messageName _
    = Data.Text.pack "event_store.client.streams.TombstoneReq"
  packedMessageDescriptor _
    = "\n\
      \\fTombstoneReq\DC2J\n\
      \\aoptions\CAN\SOH \SOH(\v20.event_store.client.streams.TombstoneReq.OptionsR\aoptions\SUB\193\STX\n\
      \\aOptions\DC2Q\n\
      \\DC1stream_identifier\CAN\SOH \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier\DC2\FS\n\
      \\brevision\CAN\STX \SOH(\EOTH\NULR\brevision\DC28\n\
      \\tno_stream\CAN\ETX \SOH(\v2\EM.event_store.client.EmptyH\NULR\bnoStream\DC2-\n\
      \\ETXany\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\NULR\ETXany\DC2@\n\
      \\rstream_exists\CAN\ENQ \SOH(\v2\EM.event_store.client.EmptyH\NULR\fstreamExistsB\SUB\n\
      \\CANexpected_stream_revision"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        options__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "options"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor TombstoneReq'Options)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'options")) ::
              Data.ProtoLens.FieldDescriptor TombstoneReq
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, options__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _TombstoneReq'_unknownFields
        (\ x__ y__ -> x__ {_TombstoneReq'_unknownFields = y__})
  defMessage
    = TombstoneReq'_constructor
        {_TombstoneReq'options = Prelude.Nothing,
         _TombstoneReq'_unknownFields = []}
  parseMessage
    = let
        loop ::
          TombstoneReq -> Data.ProtoLens.Encoding.Bytes.Parser TombstoneReq
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
                                       "options"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"options") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "TombstoneReq"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'options") _x
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
instance Control.DeepSeq.NFData TombstoneReq where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_TombstoneReq'_unknownFields x__)
             (Control.DeepSeq.deepseq (_TombstoneReq'options x__) ())
{- | Fields :
     
         * 'Proto.Streams_Fields.streamIdentifier' @:: Lens' TombstoneReq'Options Proto.Shared.StreamIdentifier@
         * 'Proto.Streams_Fields.maybe'streamIdentifier' @:: Lens' TombstoneReq'Options (Prelude.Maybe Proto.Shared.StreamIdentifier)@
         * 'Proto.Streams_Fields.maybe'expectedStreamRevision' @:: Lens' TombstoneReq'Options (Prelude.Maybe TombstoneReq'Options'ExpectedStreamRevision)@
         * 'Proto.Streams_Fields.maybe'revision' @:: Lens' TombstoneReq'Options (Prelude.Maybe Data.Word.Word64)@
         * 'Proto.Streams_Fields.revision' @:: Lens' TombstoneReq'Options Data.Word.Word64@
         * 'Proto.Streams_Fields.maybe'noStream' @:: Lens' TombstoneReq'Options (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.noStream' @:: Lens' TombstoneReq'Options Proto.Shared.Empty@
         * 'Proto.Streams_Fields.maybe'any' @:: Lens' TombstoneReq'Options (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.any' @:: Lens' TombstoneReq'Options Proto.Shared.Empty@
         * 'Proto.Streams_Fields.maybe'streamExists' @:: Lens' TombstoneReq'Options (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.streamExists' @:: Lens' TombstoneReq'Options Proto.Shared.Empty@ -}
data TombstoneReq'Options
  = TombstoneReq'Options'_constructor {_TombstoneReq'Options'streamIdentifier :: !(Prelude.Maybe Proto.Shared.StreamIdentifier),
                                       _TombstoneReq'Options'expectedStreamRevision :: !(Prelude.Maybe TombstoneReq'Options'ExpectedStreamRevision),
                                       _TombstoneReq'Options'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show TombstoneReq'Options where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data TombstoneReq'Options'ExpectedStreamRevision
  = TombstoneReq'Options'Revision !Data.Word.Word64 |
    TombstoneReq'Options'NoStream !Proto.Shared.Empty |
    TombstoneReq'Options'Any !Proto.Shared.Empty |
    TombstoneReq'Options'StreamExists !Proto.Shared.Empty
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField TombstoneReq'Options "streamIdentifier" Proto.Shared.StreamIdentifier where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TombstoneReq'Options'streamIdentifier
           (\ x__ y__ -> x__ {_TombstoneReq'Options'streamIdentifier = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField TombstoneReq'Options "maybe'streamIdentifier" (Prelude.Maybe Proto.Shared.StreamIdentifier) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TombstoneReq'Options'streamIdentifier
           (\ x__ y__ -> x__ {_TombstoneReq'Options'streamIdentifier = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField TombstoneReq'Options "maybe'expectedStreamRevision" (Prelude.Maybe TombstoneReq'Options'ExpectedStreamRevision) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TombstoneReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_TombstoneReq'Options'expectedStreamRevision = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField TombstoneReq'Options "maybe'revision" (Prelude.Maybe Data.Word.Word64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TombstoneReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_TombstoneReq'Options'expectedStreamRevision = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (TombstoneReq'Options'Revision x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap TombstoneReq'Options'Revision y__))
instance Data.ProtoLens.Field.HasField TombstoneReq'Options "revision" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TombstoneReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_TombstoneReq'Options'expectedStreamRevision = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (TombstoneReq'Options'Revision x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap TombstoneReq'Options'Revision y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Field.HasField TombstoneReq'Options "maybe'noStream" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TombstoneReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_TombstoneReq'Options'expectedStreamRevision = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (TombstoneReq'Options'NoStream x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap TombstoneReq'Options'NoStream y__))
instance Data.ProtoLens.Field.HasField TombstoneReq'Options "noStream" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TombstoneReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_TombstoneReq'Options'expectedStreamRevision = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (TombstoneReq'Options'NoStream x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap TombstoneReq'Options'NoStream y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField TombstoneReq'Options "maybe'any" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TombstoneReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_TombstoneReq'Options'expectedStreamRevision = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (TombstoneReq'Options'Any x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap TombstoneReq'Options'Any y__))
instance Data.ProtoLens.Field.HasField TombstoneReq'Options "any" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TombstoneReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_TombstoneReq'Options'expectedStreamRevision = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (TombstoneReq'Options'Any x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap TombstoneReq'Options'Any y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField TombstoneReq'Options "maybe'streamExists" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TombstoneReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_TombstoneReq'Options'expectedStreamRevision = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (TombstoneReq'Options'StreamExists x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap TombstoneReq'Options'StreamExists y__))
instance Data.ProtoLens.Field.HasField TombstoneReq'Options "streamExists" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TombstoneReq'Options'expectedStreamRevision
           (\ x__ y__
              -> x__ {_TombstoneReq'Options'expectedStreamRevision = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (TombstoneReq'Options'StreamExists x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap TombstoneReq'Options'StreamExists y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message TombstoneReq'Options where
  messageName _
    = Data.Text.pack "event_store.client.streams.TombstoneReq.Options"
  packedMessageDescriptor _
    = "\n\
      \\aOptions\DC2Q\n\
      \\DC1stream_identifier\CAN\SOH \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier\DC2\FS\n\
      \\brevision\CAN\STX \SOH(\EOTH\NULR\brevision\DC28\n\
      \\tno_stream\CAN\ETX \SOH(\v2\EM.event_store.client.EmptyH\NULR\bnoStream\DC2-\n\
      \\ETXany\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\NULR\ETXany\DC2@\n\
      \\rstream_exists\CAN\ENQ \SOH(\v2\EM.event_store.client.EmptyH\NULR\fstreamExistsB\SUB\n\
      \\CANexpected_stream_revision"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        streamIdentifier__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stream_identifier"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.StreamIdentifier)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'streamIdentifier")) ::
              Data.ProtoLens.FieldDescriptor TombstoneReq'Options
        revision__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "revision"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'revision")) ::
              Data.ProtoLens.FieldDescriptor TombstoneReq'Options
        noStream__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "no_stream"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'noStream")) ::
              Data.ProtoLens.FieldDescriptor TombstoneReq'Options
        any__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "any"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'any")) ::
              Data.ProtoLens.FieldDescriptor TombstoneReq'Options
        streamExists__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stream_exists"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'streamExists")) ::
              Data.ProtoLens.FieldDescriptor TombstoneReq'Options
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, streamIdentifier__field_descriptor),
           (Data.ProtoLens.Tag 2, revision__field_descriptor),
           (Data.ProtoLens.Tag 3, noStream__field_descriptor),
           (Data.ProtoLens.Tag 4, any__field_descriptor),
           (Data.ProtoLens.Tag 5, streamExists__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _TombstoneReq'Options'_unknownFields
        (\ x__ y__ -> x__ {_TombstoneReq'Options'_unknownFields = y__})
  defMessage
    = TombstoneReq'Options'_constructor
        {_TombstoneReq'Options'streamIdentifier = Prelude.Nothing,
         _TombstoneReq'Options'expectedStreamRevision = Prelude.Nothing,
         _TombstoneReq'Options'_unknownFields = []}
  parseMessage
    = let
        loop ::
          TombstoneReq'Options
          -> Data.ProtoLens.Encoding.Bytes.Parser TombstoneReq'Options
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
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "revision"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"revision") y x)
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "no_stream"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"noStream") y x)
                        34
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "any"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"any") y x)
                        42
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "stream_exists"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"streamExists") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Options"
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
             ((Data.Monoid.<>)
                (case
                     Lens.Family2.view
                       (Data.ProtoLens.Field.field @"maybe'expectedStreamRevision") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just (TombstoneReq'Options'Revision v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt v)
                   (Prelude.Just (TombstoneReq'Options'NoStream v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage v)
                   (Prelude.Just (TombstoneReq'Options'Any v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 34)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage v)
                   (Prelude.Just (TombstoneReq'Options'StreamExists v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 42)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData TombstoneReq'Options where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_TombstoneReq'Options'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_TombstoneReq'Options'streamIdentifier x__)
                (Control.DeepSeq.deepseq
                   (_TombstoneReq'Options'expectedStreamRevision x__) ()))
instance Control.DeepSeq.NFData TombstoneReq'Options'ExpectedStreamRevision where
  rnf (TombstoneReq'Options'Revision x__) = Control.DeepSeq.rnf x__
  rnf (TombstoneReq'Options'NoStream x__) = Control.DeepSeq.rnf x__
  rnf (TombstoneReq'Options'Any x__) = Control.DeepSeq.rnf x__
  rnf (TombstoneReq'Options'StreamExists x__)
    = Control.DeepSeq.rnf x__
_TombstoneReq'Options'Revision ::
  Data.ProtoLens.Prism.Prism' TombstoneReq'Options'ExpectedStreamRevision Data.Word.Word64
_TombstoneReq'Options'Revision
  = Data.ProtoLens.Prism.prism'
      TombstoneReq'Options'Revision
      (\ p__
         -> case p__ of
              (TombstoneReq'Options'Revision p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_TombstoneReq'Options'NoStream ::
  Data.ProtoLens.Prism.Prism' TombstoneReq'Options'ExpectedStreamRevision Proto.Shared.Empty
_TombstoneReq'Options'NoStream
  = Data.ProtoLens.Prism.prism'
      TombstoneReq'Options'NoStream
      (\ p__
         -> case p__ of
              (TombstoneReq'Options'NoStream p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_TombstoneReq'Options'Any ::
  Data.ProtoLens.Prism.Prism' TombstoneReq'Options'ExpectedStreamRevision Proto.Shared.Empty
_TombstoneReq'Options'Any
  = Data.ProtoLens.Prism.prism'
      TombstoneReq'Options'Any
      (\ p__
         -> case p__ of
              (TombstoneReq'Options'Any p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_TombstoneReq'Options'StreamExists ::
  Data.ProtoLens.Prism.Prism' TombstoneReq'Options'ExpectedStreamRevision Proto.Shared.Empty
_TombstoneReq'Options'StreamExists
  = Data.ProtoLens.Prism.prism'
      TombstoneReq'Options'StreamExists
      (\ p__
         -> case p__ of
              (TombstoneReq'Options'StreamExists p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.Streams_Fields.maybe'positionOption' @:: Lens' TombstoneResp (Prelude.Maybe TombstoneResp'PositionOption)@
         * 'Proto.Streams_Fields.maybe'position' @:: Lens' TombstoneResp (Prelude.Maybe TombstoneResp'Position)@
         * 'Proto.Streams_Fields.position' @:: Lens' TombstoneResp TombstoneResp'Position@
         * 'Proto.Streams_Fields.maybe'noPosition' @:: Lens' TombstoneResp (Prelude.Maybe Proto.Shared.Empty)@
         * 'Proto.Streams_Fields.noPosition' @:: Lens' TombstoneResp Proto.Shared.Empty@ -}
data TombstoneResp
  = TombstoneResp'_constructor {_TombstoneResp'positionOption :: !(Prelude.Maybe TombstoneResp'PositionOption),
                                _TombstoneResp'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show TombstoneResp where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data TombstoneResp'PositionOption
  = TombstoneResp'Position' !TombstoneResp'Position |
    TombstoneResp'NoPosition !Proto.Shared.Empty
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField TombstoneResp "maybe'positionOption" (Prelude.Maybe TombstoneResp'PositionOption) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TombstoneResp'positionOption
           (\ x__ y__ -> x__ {_TombstoneResp'positionOption = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField TombstoneResp "maybe'position" (Prelude.Maybe TombstoneResp'Position) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TombstoneResp'positionOption
           (\ x__ y__ -> x__ {_TombstoneResp'positionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (TombstoneResp'Position' x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap TombstoneResp'Position' y__))
instance Data.ProtoLens.Field.HasField TombstoneResp "position" TombstoneResp'Position where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TombstoneResp'positionOption
           (\ x__ y__ -> x__ {_TombstoneResp'positionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (TombstoneResp'Position' x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap TombstoneResp'Position' y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField TombstoneResp "maybe'noPosition" (Prelude.Maybe Proto.Shared.Empty) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TombstoneResp'positionOption
           (\ x__ y__ -> x__ {_TombstoneResp'positionOption = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (TombstoneResp'NoPosition x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap TombstoneResp'NoPosition y__))
instance Data.ProtoLens.Field.HasField TombstoneResp "noPosition" Proto.Shared.Empty where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TombstoneResp'positionOption
           (\ x__ y__ -> x__ {_TombstoneResp'positionOption = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (TombstoneResp'NoPosition x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap TombstoneResp'NoPosition y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message TombstoneResp where
  messageName _
    = Data.Text.pack "event_store.client.streams.TombstoneResp"
  packedMessageDescriptor _
    = "\n\
      \\rTombstoneResp\DC2P\n\
      \\bposition\CAN\SOH \SOH(\v22.event_store.client.streams.TombstoneResp.PositionH\NULR\bposition\DC2<\n\
      \\vno_position\CAN\STX \SOH(\v2\EM.event_store.client.EmptyH\NULR\n\
      \noPosition\SUB^\n\
      \\bPosition\DC2'\n\
      \\SIcommit_position\CAN\SOH \SOH(\EOTR\SOcommitPosition\DC2)\n\
      \\DLEprepare_position\CAN\STX \SOH(\EOTR\SIpreparePositionB\DC1\n\
      \\SIposition_option"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        position__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "position"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor TombstoneResp'Position)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'position")) ::
              Data.ProtoLens.FieldDescriptor TombstoneResp
        noPosition__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "no_position"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Shared.Empty)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'noPosition")) ::
              Data.ProtoLens.FieldDescriptor TombstoneResp
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, position__field_descriptor),
           (Data.ProtoLens.Tag 2, noPosition__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _TombstoneResp'_unknownFields
        (\ x__ y__ -> x__ {_TombstoneResp'_unknownFields = y__})
  defMessage
    = TombstoneResp'_constructor
        {_TombstoneResp'positionOption = Prelude.Nothing,
         _TombstoneResp'_unknownFields = []}
  parseMessage
    = let
        loop ::
          TombstoneResp -> Data.ProtoLens.Encoding.Bytes.Parser TombstoneResp
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
                                       "position"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"position") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "no_position"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"noPosition") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "TombstoneResp"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view
                    (Data.ProtoLens.Field.field @"maybe'positionOption") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just (TombstoneResp'Position' v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage v)
                (Prelude.Just (TombstoneResp'NoPosition v))
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData TombstoneResp where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_TombstoneResp'_unknownFields x__)
             (Control.DeepSeq.deepseq (_TombstoneResp'positionOption x__) ())
instance Control.DeepSeq.NFData TombstoneResp'PositionOption where
  rnf (TombstoneResp'Position' x__) = Control.DeepSeq.rnf x__
  rnf (TombstoneResp'NoPosition x__) = Control.DeepSeq.rnf x__
_TombstoneResp'Position' ::
  Data.ProtoLens.Prism.Prism' TombstoneResp'PositionOption TombstoneResp'Position
_TombstoneResp'Position'
  = Data.ProtoLens.Prism.prism'
      TombstoneResp'Position'
      (\ p__
         -> case p__ of
              (TombstoneResp'Position' p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_TombstoneResp'NoPosition ::
  Data.ProtoLens.Prism.Prism' TombstoneResp'PositionOption Proto.Shared.Empty
_TombstoneResp'NoPosition
  = Data.ProtoLens.Prism.prism'
      TombstoneResp'NoPosition
      (\ p__
         -> case p__ of
              (TombstoneResp'NoPosition p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.Streams_Fields.commitPosition' @:: Lens' TombstoneResp'Position Data.Word.Word64@
         * 'Proto.Streams_Fields.preparePosition' @:: Lens' TombstoneResp'Position Data.Word.Word64@ -}
data TombstoneResp'Position
  = TombstoneResp'Position'_constructor {_TombstoneResp'Position'commitPosition :: !Data.Word.Word64,
                                         _TombstoneResp'Position'preparePosition :: !Data.Word.Word64,
                                         _TombstoneResp'Position'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show TombstoneResp'Position where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField TombstoneResp'Position "commitPosition" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TombstoneResp'Position'commitPosition
           (\ x__ y__ -> x__ {_TombstoneResp'Position'commitPosition = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField TombstoneResp'Position "preparePosition" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TombstoneResp'Position'preparePosition
           (\ x__ y__ -> x__ {_TombstoneResp'Position'preparePosition = y__}))
        Prelude.id
instance Data.ProtoLens.Message TombstoneResp'Position where
  messageName _
    = Data.Text.pack
        "event_store.client.streams.TombstoneResp.Position"
  packedMessageDescriptor _
    = "\n\
      \\bPosition\DC2'\n\
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
              Data.ProtoLens.FieldDescriptor TombstoneResp'Position
        preparePosition__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "prepare_position"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"preparePosition")) ::
              Data.ProtoLens.FieldDescriptor TombstoneResp'Position
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, commitPosition__field_descriptor),
           (Data.ProtoLens.Tag 2, preparePosition__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _TombstoneResp'Position'_unknownFields
        (\ x__ y__ -> x__ {_TombstoneResp'Position'_unknownFields = y__})
  defMessage
    = TombstoneResp'Position'_constructor
        {_TombstoneResp'Position'commitPosition = Data.ProtoLens.fieldDefault,
         _TombstoneResp'Position'preparePosition = Data.ProtoLens.fieldDefault,
         _TombstoneResp'Position'_unknownFields = []}
  parseMessage
    = let
        loop ::
          TombstoneResp'Position
          -> Data.ProtoLens.Encoding.Bytes.Parser TombstoneResp'Position
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
          (do loop Data.ProtoLens.defMessage) "Position"
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
instance Control.DeepSeq.NFData TombstoneResp'Position where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_TombstoneResp'Position'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_TombstoneResp'Position'commitPosition x__)
                (Control.DeepSeq.deepseq
                   (_TombstoneResp'Position'preparePosition x__) ()))
data Streams = Streams {}
instance Data.ProtoLens.Service.Types.Service Streams where
  type ServiceName Streams = "Streams"
  type ServicePackage Streams = "event_store.client.streams"
  type ServiceMethods Streams = '["append",
                                  "batchAppend",
                                  "delete",
                                  "read",
                                  "tombstone"]
  packedServiceDescriptor _
    = "\n\
      \\aStreams\DC2S\n\
      \\EOTRead\DC2#.event_store.client.streams.ReadReq\SUB$.event_store.client.streams.ReadResp0\SOH\DC2Y\n\
      \\ACKAppend\DC2%.event_store.client.streams.AppendReq\SUB&.event_store.client.streams.AppendResp(\SOH\DC2W\n\
      \\ACKDelete\DC2%.event_store.client.streams.DeleteReq\SUB&.event_store.client.streams.DeleteResp\DC2`\n\
      \\tTombstone\DC2(.event_store.client.streams.TombstoneReq\SUB).event_store.client.streams.TombstoneResp\DC2j\n\
      \\vBatchAppend\DC2*.event_store.client.streams.BatchAppendReq\SUB+.event_store.client.streams.BatchAppendResp(\SOH0\SOH"
instance Data.ProtoLens.Service.Types.HasMethodImpl Streams "read" where
  type MethodName Streams "read" = "Read"
  type MethodInput Streams "read" = ReadReq
  type MethodOutput Streams "read" = ReadResp
  type MethodStreamingType Streams "read" = 'Data.ProtoLens.Service.Types.ServerStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl Streams "append" where
  type MethodName Streams "append" = "Append"
  type MethodInput Streams "append" = AppendReq
  type MethodOutput Streams "append" = AppendResp
  type MethodStreamingType Streams "append" = 'Data.ProtoLens.Service.Types.ClientStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl Streams "delete" where
  type MethodName Streams "delete" = "Delete"
  type MethodInput Streams "delete" = DeleteReq
  type MethodOutput Streams "delete" = DeleteResp
  type MethodStreamingType Streams "delete" = 'Data.ProtoLens.Service.Types.NonStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl Streams "tombstone" where
  type MethodName Streams "tombstone" = "Tombstone"
  type MethodInput Streams "tombstone" = TombstoneReq
  type MethodOutput Streams "tombstone" = TombstoneResp
  type MethodStreamingType Streams "tombstone" = 'Data.ProtoLens.Service.Types.NonStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl Streams "batchAppend" where
  type MethodName Streams "batchAppend" = "BatchAppend"
  type MethodInput Streams "batchAppend" = BatchAppendReq
  type MethodOutput Streams "batchAppend" = BatchAppendResp
  type MethodStreamingType Streams "batchAppend" = 'Data.ProtoLens.Service.Types.BiDiStreaming
packedFileDescriptor :: Data.ByteString.ByteString
packedFileDescriptor
  = "\n\
    \\rstreams.proto\DC2\SUBevent_store.client.streams\SUB\fshared.proto\SUB\fstatus.proto\SUB\RSgoogle/protobuf/duration.proto\SUB\ESCgoogle/protobuf/empty.proto\SUB\USgoogle/protobuf/timestamp.proto\"\251\DLE\n\
    \\aReadReq\DC2E\n\
    \\aoptions\CAN\SOH \SOH(\v2+.event_store.client.streams.ReadReq.OptionsR\aoptions\SUB\168\DLE\n\
    \\aOptions\DC2S\n\
    \\ACKstream\CAN\SOH \SOH(\v29.event_store.client.streams.ReadReq.Options.StreamOptionsH\NULR\ACKstream\DC2J\n\
    \\ETXall\CAN\STX \SOH(\v26.event_store.client.streams.ReadReq.Options.AllOptionsH\NULR\ETXall\DC2`\n\
    \\SOread_direction\CAN\ETX \SOH(\SO29.event_store.client.streams.ReadReq.Options.ReadDirectionR\rreadDirection\DC2#\n\
    \\rresolve_links\CAN\EOT \SOH(\bR\fresolveLinks\DC2\SYN\n\
    \\ENQcount\CAN\ENQ \SOH(\EOTH\SOHR\ENQcount\DC2e\n\
    \\fsubscription\CAN\ACK \SOH(\v2?.event_store.client.streams.ReadReq.Options.SubscriptionOptionsH\SOHR\fsubscription\DC2S\n\
    \\ACKfilter\CAN\a \SOH(\v29.event_store.client.streams.ReadReq.Options.FilterOptionsH\STXR\ACKfilter\DC28\n\
    \\tno_filter\CAN\b \SOH(\v2\EM.event_store.client.EmptyH\STXR\bnoFilter\DC2W\n\
    \\vuuid_option\CAN\t \SOH(\v26.event_store.client.streams.ReadReq.Options.UUIDOptionR\n\
    \uuidOption\DC2`\n\
    \\SOcontrol_option\CAN\n\
    \ \SOH(\v29.event_store.client.streams.ReadReq.Options.ControlOptionR\rcontrolOption\SUB\245\SOH\n\
    \\rStreamOptions\DC2Q\n\
    \\DC1stream_identifier\CAN\SOH \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier\DC2\FS\n\
    \\brevision\CAN\STX \SOH(\EOTH\NULR\brevision\DC21\n\
    \\ENQstart\CAN\ETX \SOH(\v2\EM.event_store.client.EmptyH\NULR\ENQstart\DC2-\n\
    \\ETXend\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\NULR\ETXendB\DC1\n\
    \\SIrevision_option\SUB\208\SOH\n\
    \\n\
    \AllOptions\DC2R\n\
    \\bposition\CAN\SOH \SOH(\v24.event_store.client.streams.ReadReq.Options.PositionH\NULR\bposition\DC21\n\
    \\ENQstart\CAN\STX \SOH(\v2\EM.event_store.client.EmptyH\NULR\ENQstart\DC2-\n\
    \\ETXend\CAN\ETX \SOH(\v2\EM.event_store.client.EmptyH\NULR\ETXendB\f\n\
    \\n\
    \all_option\SUB\NAK\n\
    \\DC3SubscriptionOptions\SUB^\n\
    \\bPosition\DC2'\n\
    \\SIcommit_position\CAN\SOH \SOH(\EOTR\SOcommitPosition\DC2)\n\
    \\DLEprepare_position\CAN\STX \SOH(\EOTR\SIpreparePosition\SUB\198\ETX\n\
    \\rFilterOptions\DC2s\n\
    \\DC1stream_identifier\CAN\SOH \SOH(\v2D.event_store.client.streams.ReadReq.Options.FilterOptions.ExpressionH\NULR\DLEstreamIdentifier\DC2e\n\
    \\n\
    \event_type\CAN\STX \SOH(\v2D.event_store.client.streams.ReadReq.Options.FilterOptions.ExpressionH\NULR\teventType\DC2\DC2\n\
    \\ETXmax\CAN\ETX \SOH(\rH\SOHR\ETXmax\DC21\n\
    \\ENQcount\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\SOHR\ENQcount\DC2B\n\
    \\FScheckpointIntervalMultiplier\CAN\ENQ \SOH(\rR\FScheckpointIntervalMultiplier\SUB:\n\
    \\n\
    \Expression\DC2\DC4\n\
    \\ENQregex\CAN\SOH \SOH(\tR\ENQregex\DC2\SYN\n\
    \\ACKprefix\CAN\STX \ETX(\tR\ACKprefixB\b\n\
    \\ACKfilterB\b\n\
    \\ACKwindow\SUB\137\SOH\n\
    \\n\
    \UUIDOption\DC2;\n\
    \\n\
    \structured\CAN\SOH \SOH(\v2\EM.event_store.client.EmptyH\NULR\n\
    \structured\DC23\n\
    \\ACKstring\CAN\STX \SOH(\v2\EM.event_store.client.EmptyH\NULR\ACKstringB\t\n\
    \\acontent\SUB5\n\
    \\rControlOption\DC2$\n\
    \\rcompatibility\CAN\SOH \SOH(\rR\rcompatibility\",\n\
    \\rReadDirection\DC2\f\n\
    \\bForwards\DLE\NUL\DC2\r\n\
    \\tBackwards\DLE\SOHB\SI\n\
    \\rstream_optionB\SO\n\
    \\fcount_optionB\SI\n\
    \\rfilter_option\"\240\DC2\n\
    \\bReadResp\DC2F\n\
    \\ENQevent\CAN\SOH \SOH(\v2..event_store.client.streams.ReadResp.ReadEventH\NULR\ENQevent\DC2c\n\
    \\fconfirmation\CAN\STX \SOH(\v2=.event_store.client.streams.ReadResp.SubscriptionConfirmationH\NULR\fconfirmation\DC2Q\n\
    \\n\
    \checkpoint\CAN\ETX \SOH(\v2/.event_store.client.streams.ReadResp.CheckpointH\NULR\n\
    \checkpoint\DC2_\n\
    \\DLEstream_not_found\CAN\EOT \SOH(\v23.event_store.client.streams.ReadResp.StreamNotFoundH\NULR\SOstreamNotFound\DC24\n\
    \\NAKfirst_stream_position\CAN\ENQ \SOH(\EOTH\NULR\DC3firstStreamPosition\DC22\n\
    \\DC4last_stream_position\CAN\ACK \SOH(\EOTH\NULR\DC2lastStreamPosition\DC2`\n\
    \\CANlast_all_stream_position\CAN\a \SOH(\v2%.event_store.client.AllStreamPositionH\NULR\NAKlastAllStreamPosition\DC2L\n\
    \\tcaught_up\CAN\b \SOH(\v2-.event_store.client.streams.ReadResp.CaughtUpH\NULR\bcaughtUp\DC2R\n\
    \\vfell_behind\CAN\t \SOH(\v2/.event_store.client.streams.ReadResp.FellBehindH\NULR\n\
    \fellBehind\SUB\227\SOH\n\
    \\bCaughtUp\DC28\n\
    \\ttimestamp\CAN\SOH \SOH(\v2\SUB.google.protobuf.TimestampR\ttimestamp\DC2,\n\
    \\SIstream_revision\CAN\STX \SOH(\ETXH\NULR\SOstreamRevision\136\SOH\SOH\DC2N\n\
    \\bposition\CAN\ETX \SOH(\v2-.event_store.client.streams.ReadResp.PositionH\SOHR\bposition\136\SOH\SOHB\DC2\n\
    \\DLE_stream_revisionB\v\n\
    \\t_position\SUB\229\SOH\n\
    \\n\
    \FellBehind\DC28\n\
    \\ttimestamp\CAN\SOH \SOH(\v2\SUB.google.protobuf.TimestampR\ttimestamp\DC2,\n\
    \\SIstream_revision\CAN\STX \SOH(\ETXH\NULR\SOstreamRevision\136\SOH\SOH\DC2N\n\
    \\bposition\CAN\ETX \SOH(\v2-.event_store.client.streams.ReadResp.PositionH\SOHR\bposition\136\SOH\SOHB\DC2\n\
    \\DLE_stream_revisionB\v\n\
    \\t_position\SUB\148\ACK\n\
    \\tReadEvent\DC2R\n\
    \\ENQevent\CAN\SOH \SOH(\v2<.event_store.client.streams.ReadResp.ReadEvent.RecordedEventR\ENQevent\DC2P\n\
    \\EOTlink\CAN\STX \SOH(\v2<.event_store.client.streams.ReadResp.ReadEvent.RecordedEventR\EOTlink\DC2)\n\
    \\SIcommit_position\CAN\ETX \SOH(\EOTH\NULR\SOcommitPosition\DC2<\n\
    \\vno_position\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\NULR\n\
    \noPosition\SUB\235\ETX\n\
    \\rRecordedEvent\DC2(\n\
    \\STXid\CAN\SOH \SOH(\v2\CAN.event_store.client.UUIDR\STXid\DC2Q\n\
    \\DC1stream_identifier\CAN\STX \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier\DC2'\n\
    \\SIstream_revision\CAN\ETX \SOH(\EOTR\SOstreamRevision\DC2)\n\
    \\DLEprepare_position\CAN\EOT \SOH(\EOTR\SIpreparePosition\DC2'\n\
    \\SIcommit_position\CAN\ENQ \SOH(\EOTR\SOcommitPosition\DC2f\n\
    \\bmetadata\CAN\ACK \ETX(\v2J.event_store.client.streams.ReadResp.ReadEvent.RecordedEvent.MetadataEntryR\bmetadata\DC2'\n\
    \\SIcustom_metadata\CAN\a \SOH(\fR\SOcustomMetadata\DC2\DC2\n\
    \\EOTdata\CAN\b \SOH(\fR\EOTdata\SUB;\n\
    \\rMetadataEntry\DC2\DLE\n\
    \\ETXkey\CAN\SOH \SOH(\tR\ETXkey\DC2\DC4\n\
    \\ENQvalue\CAN\STX \SOH(\tR\ENQvalue:\STX8\SOHB\n\
    \\n\
    \\bposition\SUBC\n\
    \\CANSubscriptionConfirmation\DC2'\n\
    \\SIsubscription_id\CAN\SOH \SOH(\tR\SOsubscriptionId\SUB\154\SOH\n\
    \\n\
    \Checkpoint\DC2'\n\
    \\SIcommit_position\CAN\SOH \SOH(\EOTR\SOcommitPosition\DC2)\n\
    \\DLEprepare_position\CAN\STX \SOH(\EOTR\SIpreparePosition\DC28\n\
    \\ttimestamp\CAN\ETX \SOH(\v2\SUB.google.protobuf.TimestampR\ttimestamp\SUB^\n\
    \\bPosition\DC2'\n\
    \\SIcommit_position\CAN\SOH \SOH(\EOTR\SOcommitPosition\DC2)\n\
    \\DLEprepare_position\CAN\STX \SOH(\EOTR\SIpreparePosition\SUBc\n\
    \\SOStreamNotFound\DC2Q\n\
    \\DC1stream_identifier\CAN\SOH \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifierB\t\n\
    \\acontent\"\162\ACK\n\
    \\tAppendReq\DC2I\n\
    \\aoptions\CAN\SOH \SOH(\v2-.event_store.client.streams.AppendReq.OptionsH\NULR\aoptions\DC2b\n\
    \\DLEproposed_message\CAN\STX \SOH(\v25.event_store.client.streams.AppendReq.ProposedMessageH\NULR\SIproposedMessage\SUB\193\STX\n\
    \\aOptions\DC2Q\n\
    \\DC1stream_identifier\CAN\SOH \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier\DC2\FS\n\
    \\brevision\CAN\STX \SOH(\EOTH\NULR\brevision\DC28\n\
    \\tno_stream\CAN\ETX \SOH(\v2\EM.event_store.client.EmptyH\NULR\bnoStream\DC2-\n\
    \\ETXany\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\NULR\ETXany\DC2@\n\
    \\rstream_exists\CAN\ENQ \SOH(\v2\EM.event_store.client.EmptyH\NULR\fstreamExistsB\SUB\n\
    \\CANexpected_stream_revision\SUB\150\STX\n\
    \\SIProposedMessage\DC2(\n\
    \\STXid\CAN\SOH \SOH(\v2\CAN.event_store.client.UUIDR\STXid\DC2_\n\
    \\bmetadata\CAN\STX \ETX(\v2C.event_store.client.streams.AppendReq.ProposedMessage.MetadataEntryR\bmetadata\DC2'\n\
    \\SIcustom_metadata\CAN\ETX \SOH(\fR\SOcustomMetadata\DC2\DC2\n\
    \\EOTdata\CAN\EOT \SOH(\fR\EOTdata\SUB;\n\
    \\rMetadataEntry\DC2\DLE\n\
    \\ETXkey\CAN\SOH \SOH(\tR\ETXkey\DC2\DC4\n\
    \\ENQvalue\CAN\STX \SOH(\tR\ENQvalue:\STX8\SOHB\t\n\
    \\acontent\"\187\v\n\
    \\n\
    \AppendResp\DC2J\n\
    \\asuccess\CAN\SOH \SOH(\v2..event_store.client.streams.AppendResp.SuccessH\NULR\asuccess\DC2s\n\
    \\SYNwrong_expected_version\CAN\STX \SOH(\v2;.event_store.client.streams.AppendResp.WrongExpectedVersionH\NULR\DC4wrongExpectedVersion\SUB^\n\
    \\bPosition\DC2'\n\
    \\SIcommit_position\CAN\SOH \SOH(\EOTR\SOcommitPosition\DC2)\n\
    \\DLEprepare_position\CAN\STX \SOH(\EOTR\SIpreparePosition\SUB\171\STX\n\
    \\aSuccess\DC2+\n\
    \\DLEcurrent_revision\CAN\SOH \SOH(\EOTH\NULR\SIcurrentRevision\DC28\n\
    \\tno_stream\CAN\STX \SOH(\v2\EM.event_store.client.EmptyH\NULR\bnoStream\DC2M\n\
    \\bposition\CAN\ETX \SOH(\v2/.event_store.client.streams.AppendResp.PositionH\SOHR\bposition\DC2<\n\
    \\vno_position\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\SOHR\n\
    \noPositionB\EM\n\
    \\ETBcurrent_revision_optionB\DC1\n\
    \\SIposition_option\SUB\211\ACK\n\
    \\DC4WrongExpectedVersion\DC26\n\
    \\ETBcurrent_revision_20_6_0\CAN\SOH \SOH(\EOTH\NULR\DC3currentRevision2060\DC2C\n\
    \\DLEno_stream_20_6_0\CAN\STX \SOH(\v2\EM.event_store.client.EmptyH\NULR\fnoStream2060\DC28\n\
    \\CANexpected_revision_20_6_0\CAN\ETX \SOH(\EOTH\SOHR\DC4expectedRevision2060\DC28\n\
    \\n\
    \any_20_6_0\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\SOHR\aany2060\DC2K\n\
    \\DC4stream_exists_20_6_0\CAN\ENQ \SOH(\v2\EM.event_store.client.EmptyH\SOHR\DLEstreamExists2060\DC2+\n\
    \\DLEcurrent_revision\CAN\ACK \SOH(\EOTH\STXR\SIcurrentRevision\DC2G\n\
    \\DC1current_no_stream\CAN\a \SOH(\v2\EM.event_store.client.EmptyH\STXR\SIcurrentNoStream\DC2-\n\
    \\DC1expected_revision\CAN\b \SOH(\EOTH\ETXR\DLEexpectedRevision\DC2>\n\
    \\fexpected_any\CAN\t \SOH(\v2\EM.event_store.client.EmptyH\ETXR\vexpectedAny\DC2Q\n\
    \\SYNexpected_stream_exists\CAN\n\
    \ \SOH(\v2\EM.event_store.client.EmptyH\ETXR\DC4expectedStreamExists\DC2I\n\
    \\DC2expected_no_stream\CAN\v \SOH(\v2\EM.event_store.client.EmptyH\ETXR\DLEexpectedNoStreamB \n\
    \\RScurrent_revision_option_20_6_0B!\n\
    \\USexpected_revision_option_20_6_0B\EM\n\
    \\ETBcurrent_revision_optionB\SUB\n\
    \\CANexpected_revision_optionB\b\n\
    \\ACKresult\"\156\b\n\
    \\SOBatchAppendReq\DC2?\n\
    \\SOcorrelation_id\CAN\SOH \SOH(\v2\CAN.event_store.client.UUIDR\rcorrelationId\DC2L\n\
    \\aoptions\CAN\STX \SOH(\v22.event_store.client.streams.BatchAppendReq.OptionsR\aoptions\DC2g\n\
    \\DC1proposed_messages\CAN\ETX \ETX(\v2:.event_store.client.streams.BatchAppendReq.ProposedMessageR\DLEproposedMessages\DC2\EM\n\
    \\bis_final\CAN\EOT \SOH(\bR\aisFinal\SUB\216\ETX\n\
    \\aOptions\DC2Q\n\
    \\DC1stream_identifier\CAN\SOH \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier\DC2)\n\
    \\SIstream_position\CAN\STX \SOH(\EOTH\NULR\SOstreamPosition\DC25\n\
    \\tno_stream\CAN\ETX \SOH(\v2\SYN.google.protobuf.EmptyH\NULR\bnoStream\DC2*\n\
    \\ETXany\CAN\EOT \SOH(\v2\SYN.google.protobuf.EmptyH\NULR\ETXany\DC2=\n\
    \\rstream_exists\CAN\ENQ \SOH(\v2\SYN.google.protobuf.EmptyH\NULR\fstreamExists\DC2E\n\
    \\DLEdeadline_21_10_0\CAN\ACK \SOH(\v2\SUB.google.protobuf.TimestampH\SOHR\rdeadline21100\DC27\n\
    \\bdeadline\CAN\a \SOH(\v2\EM.google.protobuf.DurationH\SOHR\bdeadlineB\SUB\n\
    \\CANexpected_stream_positionB\DC1\n\
    \\SIdeadline_option\SUB\155\STX\n\
    \\SIProposedMessage\DC2(\n\
    \\STXid\CAN\SOH \SOH(\v2\CAN.event_store.client.UUIDR\STXid\DC2d\n\
    \\bmetadata\CAN\STX \ETX(\v2H.event_store.client.streams.BatchAppendReq.ProposedMessage.MetadataEntryR\bmetadata\DC2'\n\
    \\SIcustom_metadata\CAN\ETX \SOH(\fR\SOcustomMetadata\DC2\DC2\n\
    \\EOTdata\CAN\EOT \SOH(\fR\EOTdata\SUB;\n\
    \\rMetadataEntry\DC2\DLE\n\
    \\ETXkey\CAN\SOH \SOH(\tR\ETXkey\DC2\DC4\n\
    \\ENQvalue\CAN\STX \SOH(\tR\ENQvalue:\STX8\SOH\"\179\ACK\n\
    \\SIBatchAppendResp\DC2?\n\
    \\SOcorrelation_id\CAN\SOH \SOH(\v2\CAN.event_store.client.UUIDR\rcorrelationId\DC2*\n\
    \\ENQerror\CAN\STX \SOH(\v2\DC2.google.rpc.StatusH\NULR\ENQerror\DC2O\n\
    \\asuccess\CAN\ETX \SOH(\v23.event_store.client.streams.BatchAppendResp.SuccessH\NULR\asuccess\DC2Q\n\
    \\DC1stream_identifier\CAN\EOT \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier\DC2)\n\
    \\SIstream_position\CAN\ENQ \SOH(\EOTH\SOHR\SOstreamPosition\DC25\n\
    \\tno_stream\CAN\ACK \SOH(\v2\SYN.google.protobuf.EmptyH\SOHR\bnoStream\DC2*\n\
    \\ETXany\CAN\a \SOH(\v2\SYN.google.protobuf.EmptyH\SOHR\ETXany\DC2=\n\
    \\rstream_exists\CAN\b \SOH(\v2\SYN.google.protobuf.EmptyH\SOHR\fstreamExists\SUB\155\STX\n\
    \\aSuccess\DC2+\n\
    \\DLEcurrent_revision\CAN\SOH \SOH(\EOTH\NULR\SIcurrentRevision\DC25\n\
    \\tno_stream\CAN\STX \SOH(\v2\SYN.google.protobuf.EmptyH\NULR\bnoStream\DC2C\n\
    \\bposition\CAN\ETX \SOH(\v2%.event_store.client.AllStreamPositionH\SOHR\bposition\DC29\n\
    \\vno_position\CAN\EOT \SOH(\v2\SYN.google.protobuf.EmptyH\SOHR\n\
    \noPositionB\EM\n\
    \\ETBcurrent_revision_optionB\DC1\n\
    \\SIposition_optionB\b\n\
    \\ACKresultB\SUB\n\
    \\CANexpected_stream_position\"\152\ETX\n\
    \\tDeleteReq\DC2G\n\
    \\aoptions\CAN\SOH \SOH(\v2-.event_store.client.streams.DeleteReq.OptionsR\aoptions\SUB\193\STX\n\
    \\aOptions\DC2Q\n\
    \\DC1stream_identifier\CAN\SOH \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier\DC2\FS\n\
    \\brevision\CAN\STX \SOH(\EOTH\NULR\brevision\DC28\n\
    \\tno_stream\CAN\ETX \SOH(\v2\EM.event_store.client.EmptyH\NULR\bnoStream\DC2-\n\
    \\ETXany\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\NULR\ETXany\DC2@\n\
    \\rstream_exists\CAN\ENQ \SOH(\v2\EM.event_store.client.EmptyH\NULR\fstreamExistsB\SUB\n\
    \\CANexpected_stream_revision\"\140\STX\n\
    \\n\
    \DeleteResp\DC2M\n\
    \\bposition\CAN\SOH \SOH(\v2/.event_store.client.streams.DeleteResp.PositionH\NULR\bposition\DC2<\n\
    \\vno_position\CAN\STX \SOH(\v2\EM.event_store.client.EmptyH\NULR\n\
    \noPosition\SUB^\n\
    \\bPosition\DC2'\n\
    \\SIcommit_position\CAN\SOH \SOH(\EOTR\SOcommitPosition\DC2)\n\
    \\DLEprepare_position\CAN\STX \SOH(\EOTR\SIpreparePositionB\DC1\n\
    \\SIposition_option\"\158\ETX\n\
    \\fTombstoneReq\DC2J\n\
    \\aoptions\CAN\SOH \SOH(\v20.event_store.client.streams.TombstoneReq.OptionsR\aoptions\SUB\193\STX\n\
    \\aOptions\DC2Q\n\
    \\DC1stream_identifier\CAN\SOH \SOH(\v2$.event_store.client.StreamIdentifierR\DLEstreamIdentifier\DC2\FS\n\
    \\brevision\CAN\STX \SOH(\EOTH\NULR\brevision\DC28\n\
    \\tno_stream\CAN\ETX \SOH(\v2\EM.event_store.client.EmptyH\NULR\bnoStream\DC2-\n\
    \\ETXany\CAN\EOT \SOH(\v2\EM.event_store.client.EmptyH\NULR\ETXany\DC2@\n\
    \\rstream_exists\CAN\ENQ \SOH(\v2\EM.event_store.client.EmptyH\NULR\fstreamExistsB\SUB\n\
    \\CANexpected_stream_revision\"\146\STX\n\
    \\rTombstoneResp\DC2P\n\
    \\bposition\CAN\SOH \SOH(\v22.event_store.client.streams.TombstoneResp.PositionH\NULR\bposition\DC2<\n\
    \\vno_position\CAN\STX \SOH(\v2\EM.event_store.client.EmptyH\NULR\n\
    \noPosition\SUB^\n\
    \\bPosition\DC2'\n\
    \\SIcommit_position\CAN\SOH \SOH(\EOTR\SOcommitPosition\DC2)\n\
    \\DLEprepare_position\CAN\STX \SOH(\EOTR\SIpreparePositionB\DC1\n\
    \\SIposition_option2\224\ETX\n\
    \\aStreams\DC2S\n\
    \\EOTRead\DC2#.event_store.client.streams.ReadReq\SUB$.event_store.client.streams.ReadResp0\SOH\DC2Y\n\
    \\ACKAppend\DC2%.event_store.client.streams.AppendReq\SUB&.event_store.client.streams.AppendResp(\SOH\DC2W\n\
    \\ACKDelete\DC2%.event_store.client.streams.DeleteReq\SUB&.event_store.client.streams.DeleteResp\DC2`\n\
    \\tTombstone\DC2(.event_store.client.streams.TombstoneReq\SUB).event_store.client.streams.TombstoneResp\DC2j\n\
    \\vBatchAppend\DC2*.event_store.client.streams.BatchAppendReq\SUB+.event_store.client.streams.BatchAppendResp(\SOH0\SOHB'\n\
    \%com.eventstore.dbclient.proto.streamsJ\188f\n\
    \\a\DC2\ENQ\NUL\NUL\224\STX\SOH\n\
    \\b\n\
    \\SOH\f\DC2\ETX\NUL\NUL\DC2\n\
    \\b\n\
    \\SOH\STX\DC2\ETX\SOH\NUL#\n\
    \\b\n\
    \\SOH\b\DC2\ETX\STX\NUL>\n\
    \\t\n\
    \\STX\b\SOH\DC2\ETX\STX\NUL>\n\
    \\t\n\
    \\STX\ETX\NUL\DC2\ETX\EOT\NUL\SYN\n\
    \\t\n\
    \\STX\ETX\SOH\DC2\ETX\ENQ\NUL\SYN\n\
    \\t\n\
    \\STX\ETX\STX\DC2\ETX\ACK\NUL(\n\
    \\t\n\
    \\STX\ETX\ETX\DC2\ETX\a\NUL%\n\
    \\t\n\
    \\STX\ETX\EOT\DC2\ETX\b\NUL)\n\
    \\n\
    \\n\
    \\STX\ACK\NUL\DC2\EOT\n\
    \\NUL\DLE\SOH\n\
    \\n\
    \\n\
    \\ETX\ACK\NUL\SOH\DC2\ETX\n\
    \\b\SI\n\
    \\v\n\
    \\EOT\ACK\NUL\STX\NUL\DC2\ETX\v\b5\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\NUL\SOH\DC2\ETX\v\f\DLE\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\NUL\STX\DC2\ETX\v\DC2\EM\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\NUL\ACK\DC2\ETX\v$*\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\NUL\ETX\DC2\ETX\v+3\n\
    \\v\n\
    \\EOT\ACK\NUL\STX\SOH\DC2\ETX\f\b;\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\SOH\SOH\DC2\ETX\f\f\DC2\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\SOH\ENQ\DC2\ETX\f\DC4\SUB\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\SOH\STX\DC2\ETX\f\ESC$\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\SOH\ETX\DC2\ETX\f/9\n\
    \\v\n\
    \\EOT\ACK\NUL\STX\STX\DC2\ETX\r\b4\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\STX\SOH\DC2\ETX\r\f\DC2\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\STX\STX\DC2\ETX\r\DC4\GS\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\STX\ETX\DC2\ETX\r(2\n\
    \\v\n\
    \\EOT\ACK\NUL\STX\ETX\DC2\ETX\SO\b=\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\ETX\SOH\DC2\ETX\SO\f\NAK\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\ETX\STX\DC2\ETX\SO\ETB#\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\ETX\ETX\DC2\ETX\SO.;\n\
    \\v\n\
    \\EOT\ACK\NUL\STX\EOT\DC2\ETX\SI\bQ\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\EOT\SOH\DC2\ETX\SI\f\ETB\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\EOT\ENQ\DC2\ETX\SI\EM\US\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\EOT\STX\DC2\ETX\SI .\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\EOT\ACK\DC2\ETX\SI9?\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\EOT\ETX\DC2\ETX\SI@O\n\
    \\n\
    \\n\
    \\STX\EOT\NUL\DC2\EOT\DC2\NULZ\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\NUL\SOH\DC2\ETX\DC2\b\SI\n\
    \\v\n\
    \\EOT\EOT\NUL\STX\NUL\DC2\ETX\DC3\b\FS\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ACK\DC2\ETX\DC3\b\SI\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\SOH\DC2\ETX\DC3\DLE\ETB\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ETX\DC2\ETX\DC3\SUB\ESC\n\
    \\f\n\
    \\EOT\EOT\NUL\ETX\NUL\DC2\EOT\NAK\bY\t\n\
    \\f\n\
    \\ENQ\EOT\NUL\ETX\NUL\SOH\DC2\ETX\NAK\DLE\ETB\n\
    \\SO\n\
    \\ACK\EOT\NUL\ETX\NUL\b\NUL\DC2\EOT\SYN\DLE\EM\DC1\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\b\NUL\SOH\DC2\ETX\SYN\SYN#\n\
    \\r\n\
    \\ACK\EOT\NUL\ETX\NUL\STX\NUL\DC2\ETX\ETB\CAN1\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\NUL\ACK\DC2\ETX\ETB\CAN%\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\NUL\SOH\DC2\ETX\ETB&,\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\NUL\ETX\DC2\ETX\ETB/0\n\
    \\r\n\
    \\ACK\EOT\NUL\ETX\NUL\STX\SOH\DC2\ETX\CAN\CAN+\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\SOH\ACK\DC2\ETX\CAN\CAN\"\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\SOH\SOH\DC2\ETX\CAN#&\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\SOH\ETX\DC2\ETX\CAN)*\n\
    \\r\n\
    \\ACK\EOT\NUL\ETX\NUL\STX\STX\DC2\ETX\SUB\DLE1\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\STX\ACK\DC2\ETX\SUB\DLE\GS\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\STX\SOH\DC2\ETX\SUB\RS,\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\STX\ETX\DC2\ETX\SUB/0\n\
    \\r\n\
    \\ACK\EOT\NUL\ETX\NUL\STX\ETX\DC2\ETX\ESC\DLE'\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\ETX\ENQ\DC2\ETX\ESC\DLE\DC4\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\ETX\SOH\DC2\ETX\ESC\NAK\"\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\ETX\ETX\DC2\ETX\ESC%&\n\
    \\SO\n\
    \\ACK\EOT\NUL\ETX\NUL\b\SOH\DC2\EOT\FS\DLE\US\DC1\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\b\SOH\SOH\DC2\ETX\FS\SYN\"\n\
    \\r\n\
    \\ACK\EOT\NUL\ETX\NUL\STX\EOT\DC2\ETX\GS\CAN)\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\EOT\ENQ\DC2\ETX\GS\CAN\RS\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\EOT\SOH\DC2\ETX\GS\US$\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\EOT\ETX\DC2\ETX\GS'(\n\
    \\r\n\
    \\ACK\EOT\NUL\ETX\NUL\STX\ENQ\DC2\ETX\RS\CAN=\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\ENQ\ACK\DC2\ETX\RS\CAN+\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\ENQ\SOH\DC2\ETX\RS,8\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\ENQ\ETX\DC2\ETX\RS;<\n\
    \\SO\n\
    \\ACK\EOT\NUL\ETX\NUL\b\STX\DC2\EOT \DLE#\DC1\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\b\STX\SOH\DC2\ETX \SYN#\n\
    \\r\n\
    \\ACK\EOT\NUL\ETX\NUL\STX\ACK\DC2\ETX!\CAN1\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\ACK\ACK\DC2\ETX!\CAN%\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\ACK\SOH\DC2\ETX!&,\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\ACK\ETX\DC2\ETX!/0\n\
    \\r\n\
    \\ACK\EOT\NUL\ETX\NUL\STX\a\DC2\ETX\"\CAN?\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\a\ACK\DC2\ETX\"\CAN0\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\a\SOH\DC2\ETX\"1:\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\a\ETX\DC2\ETX\"=>\n\
    \\r\n\
    \\ACK\EOT\NUL\ETX\NUL\STX\b\DC2\ETX$\DLE+\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\b\ACK\DC2\ETX$\DLE\SUB\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\b\SOH\DC2\ETX$\ESC&\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\b\ETX\DC2\ETX$)*\n\
    \\r\n\
    \\ACK\EOT\NUL\ETX\NUL\STX\t\DC2\ETX%\DLE2\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\t\ACK\DC2\ETX%\DLE\GS\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\t\SOH\DC2\ETX%\RS,\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\STX\t\ETX\DC2\ETX%/1\n\
    \\SO\n\
    \\ACK\EOT\NUL\ETX\NUL\EOT\NUL\DC2\EOT'\DLE*\DC1\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\EOT\NUL\SOH\DC2\ETX'\NAK\"\n\
    \\SI\n\
    \\b\EOT\NUL\ETX\NUL\EOT\NUL\STX\NUL\DC2\ETX(\CAN%\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\EOT\NUL\STX\NUL\SOH\DC2\ETX(\CAN \n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\EOT\NUL\STX\NUL\STX\DC2\ETX(#$\n\
    \\SI\n\
    \\b\EOT\NUL\ETX\NUL\EOT\NUL\STX\SOH\DC2\ETX)\CAN&\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\EOT\NUL\STX\SOH\SOH\DC2\ETX)\CAN!\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\EOT\NUL\STX\SOH\STX\DC2\ETX)$%\n\
    \\SO\n\
    \\ACK\EOT\NUL\ETX\NUL\ETX\NUL\DC2\EOT+\DLE2\DC1\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\ETX\NUL\SOH\DC2\ETX+\CAN%\n\
    \\SI\n\
    \\b\EOT\NUL\ETX\NUL\ETX\NUL\STX\NUL\DC2\ETX,\CANR\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\NUL\STX\NUL\ACK\DC2\ETX,\CAN;\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\NUL\STX\NUL\SOH\DC2\ETX,<M\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\NUL\STX\NUL\ETX\DC2\ETX,PQ\n\
    \\DLE\n\
    \\b\EOT\NUL\ETX\NUL\ETX\NUL\b\NUL\DC2\EOT-\CAN1\EM\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\NUL\b\NUL\SOH\DC2\ETX-\RS-\n\
    \\SI\n\
    \\b\EOT\NUL\ETX\NUL\ETX\NUL\STX\SOH\DC2\ETX. 4\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\NUL\STX\SOH\ENQ\DC2\ETX. &\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\NUL\STX\SOH\SOH\DC2\ETX.'/\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\NUL\STX\SOH\ETX\DC2\ETX.23\n\
    \\SI\n\
    \\b\EOT\NUL\ETX\NUL\ETX\NUL\STX\STX\DC2\ETX/ C\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\NUL\STX\STX\ACK\DC2\ETX/ 8\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\NUL\STX\STX\SOH\DC2\ETX/9>\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\NUL\STX\STX\ETX\DC2\ETX/AB\n\
    \\SI\n\
    \\b\EOT\NUL\ETX\NUL\ETX\NUL\STX\ETX\DC2\ETX0 A\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\NUL\STX\ETX\ACK\DC2\ETX0 8\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\NUL\STX\ETX\SOH\DC2\ETX09<\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\NUL\STX\ETX\ETX\DC2\ETX0?@\n\
    \\SO\n\
    \\ACK\EOT\NUL\ETX\NUL\ETX\SOH\DC2\EOT3\DLE9\DC1\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\ETX\SOH\SOH\DC2\ETX3\CAN\"\n\
    \\DLE\n\
    \\b\EOT\NUL\ETX\NUL\ETX\SOH\b\NUL\DC2\EOT4\CAN8\EM\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\SOH\b\NUL\SOH\DC2\ETX4\RS(\n\
    \\SI\n\
    \\b\EOT\NUL\ETX\NUL\ETX\SOH\STX\NUL\DC2\ETX5 6\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\SOH\STX\NUL\ACK\DC2\ETX5 (\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\SOH\STX\NUL\SOH\DC2\ETX5)1\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\SOH\STX\NUL\ETX\DC2\ETX545\n\
    \\SI\n\
    \\b\EOT\NUL\ETX\NUL\ETX\SOH\STX\SOH\DC2\ETX6 C\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\SOH\STX\SOH\ACK\DC2\ETX6 8\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\SOH\STX\SOH\SOH\DC2\ETX69>\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\SOH\STX\SOH\ETX\DC2\ETX6AB\n\
    \\SI\n\
    \\b\EOT\NUL\ETX\NUL\ETX\SOH\STX\STX\DC2\ETX7 A\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\SOH\STX\STX\ACK\DC2\ETX7 8\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\SOH\STX\STX\SOH\DC2\ETX79<\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\SOH\STX\STX\ETX\DC2\ETX7?@\n\
    \\SO\n\
    \\ACK\EOT\NUL\ETX\NUL\ETX\STX\DC2\EOT:\DLE;\DC1\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\ETX\STX\SOH\DC2\ETX:\CAN+\n\
    \\SO\n\
    \\ACK\EOT\NUL\ETX\NUL\ETX\ETX\DC2\EOT<\DLE?\DC1\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\ETX\ETX\SOH\DC2\ETX<\CAN \n\
    \\SI\n\
    \\b\EOT\NUL\ETX\NUL\ETX\ETX\STX\NUL\DC2\ETX=\CAN3\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\ETX\STX\NUL\ENQ\DC2\ETX=\CAN\RS\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\ETX\STX\NUL\SOH\DC2\ETX=\US.\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\ETX\STX\NUL\ETX\DC2\ETX=12\n\
    \\SI\n\
    \\b\EOT\NUL\ETX\NUL\ETX\ETX\STX\SOH\DC2\ETX>\CAN4\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\ETX\STX\SOH\ENQ\DC2\ETX>\CAN\RS\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\ETX\STX\SOH\SOH\DC2\ETX>\US/\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\ETX\STX\SOH\ETX\DC2\ETX>23\n\
    \\SO\n\
    \\ACK\EOT\NUL\ETX\NUL\ETX\EOT\DC2\EOT@\DLEO\DC1\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\ETX\EOT\SOH\DC2\ETX@\CAN%\n\
    \\DLE\n\
    \\b\EOT\NUL\ETX\NUL\ETX\EOT\b\NUL\DC2\EOTA\CAND\EM\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\EOT\b\NUL\SOH\DC2\ETXA\RS$\n\
    \\SI\n\
    \\b\EOT\NUL\ETX\NUL\ETX\EOT\STX\NUL\DC2\ETXB A\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\EOT\STX\NUL\ACK\DC2\ETXB *\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\EOT\STX\NUL\SOH\DC2\ETXB+<\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\EOT\STX\NUL\ETX\DC2\ETXB?@\n\
    \\SI\n\
    \\b\EOT\NUL\ETX\NUL\ETX\EOT\STX\SOH\DC2\ETXC :\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\EOT\STX\SOH\ACK\DC2\ETXC *\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\EOT\STX\SOH\SOH\DC2\ETXC+5\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\EOT\STX\SOH\ETX\DC2\ETXC89\n\
    \\DLE\n\
    \\b\EOT\NUL\ETX\NUL\ETX\EOT\b\SOH\DC2\EOTE\CANH\EM\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\EOT\b\SOH\SOH\DC2\ETXE\RS$\n\
    \\SI\n\
    \\b\EOT\NUL\ETX\NUL\ETX\EOT\STX\STX\DC2\ETXF /\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\EOT\STX\STX\ENQ\DC2\ETXF &\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\EOT\STX\STX\SOH\DC2\ETXF'*\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\EOT\STX\STX\ETX\DC2\ETXF-.\n\
    \\SI\n\
    \\b\EOT\NUL\ETX\NUL\ETX\EOT\STX\ETX\DC2\ETXG C\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\EOT\STX\ETX\ACK\DC2\ETXG 8\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\EOT\STX\ETX\SOH\DC2\ETXG9>\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\EOT\STX\ETX\ETX\DC2\ETXGAB\n\
    \\SI\n\
    \\b\EOT\NUL\ETX\NUL\ETX\EOT\STX\EOT\DC2\ETXI\CAN@\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\EOT\STX\EOT\ENQ\DC2\ETXI\CAN\RS\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\EOT\STX\EOT\SOH\DC2\ETXI\US;\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\EOT\STX\EOT\ETX\DC2\ETXI>?\n\
    \\DLE\n\
    \\b\EOT\NUL\ETX\NUL\ETX\EOT\ETX\NUL\DC2\EOTK\CANN\EM\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\EOT\ETX\NUL\SOH\DC2\ETXK *\n\
    \\DC1\n\
    \\n\
    \\EOT\NUL\ETX\NUL\ETX\EOT\ETX\NUL\STX\NUL\DC2\ETXL 1\n\
    \\DC2\n\
    \\v\EOT\NUL\ETX\NUL\ETX\EOT\ETX\NUL\STX\NUL\ENQ\DC2\ETXL &\n\
    \\DC2\n\
    \\v\EOT\NUL\ETX\NUL\ETX\EOT\ETX\NUL\STX\NUL\SOH\DC2\ETXL',\n\
    \\DC2\n\
    \\v\EOT\NUL\ETX\NUL\ETX\EOT\ETX\NUL\STX\NUL\ETX\DC2\ETXL/0\n\
    \\DC1\n\
    \\n\
    \\EOT\NUL\ETX\NUL\ETX\EOT\ETX\NUL\STX\SOH\DC2\ETXM ;\n\
    \\DC2\n\
    \\v\EOT\NUL\ETX\NUL\ETX\EOT\ETX\NUL\STX\SOH\EOT\DC2\ETXM (\n\
    \\DC2\n\
    \\v\EOT\NUL\ETX\NUL\ETX\EOT\ETX\NUL\STX\SOH\ENQ\DC2\ETXM)/\n\
    \\DC2\n\
    \\v\EOT\NUL\ETX\NUL\ETX\EOT\ETX\NUL\STX\SOH\SOH\DC2\ETXM06\n\
    \\DC2\n\
    \\v\EOT\NUL\ETX\NUL\ETX\EOT\ETX\NUL\STX\SOH\ETX\DC2\ETXM9:\n\
    \\SO\n\
    \\ACK\EOT\NUL\ETX\NUL\ETX\ENQ\DC2\EOTP\DLEU\DC1\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\ETX\ENQ\SOH\DC2\ETXP\CAN\"\n\
    \\DLE\n\
    \\b\EOT\NUL\ETX\NUL\ETX\ENQ\b\NUL\DC2\EOTQ\CANT\EM\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\ENQ\b\NUL\SOH\DC2\ETXQ\RS%\n\
    \\SI\n\
    \\b\EOT\NUL\ETX\NUL\ETX\ENQ\STX\NUL\DC2\ETXR H\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\ENQ\STX\NUL\ACK\DC2\ETXR 8\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\ENQ\STX\NUL\SOH\DC2\ETXR9C\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\ENQ\STX\NUL\ETX\DC2\ETXRFG\n\
    \\SI\n\
    \\b\EOT\NUL\ETX\NUL\ETX\ENQ\STX\SOH\DC2\ETXS D\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\ENQ\STX\SOH\ACK\DC2\ETXS 8\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\ENQ\STX\SOH\SOH\DC2\ETXS9?\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\ENQ\STX\SOH\ETX\DC2\ETXSBC\n\
    \\SO\n\
    \\ACK\EOT\NUL\ETX\NUL\ETX\ACK\DC2\EOTV\DLEX\DC1\n\
    \\SO\n\
    \\a\EOT\NUL\ETX\NUL\ETX\ACK\SOH\DC2\ETXV\CAN%\n\
    \\SI\n\
    \\b\EOT\NUL\ETX\NUL\ETX\ACK\STX\NUL\DC2\ETXW\CAN1\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\ACK\STX\NUL\ENQ\DC2\ETXW\CAN\RS\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\ACK\STX\NUL\SOH\DC2\ETXW\US,\n\
    \\DLE\n\
    \\t\EOT\NUL\ETX\NUL\ETX\ACK\STX\NUL\ETX\DC2\ETXW/0\n\
    \\v\n\
    \\STX\EOT\SOH\DC2\ENQ\\\NUL\175\SOH\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\SOH\SOH\DC2\ETX\\\b\DLE\n\
    \\f\n\
    \\EOT\EOT\SOH\b\NUL\DC2\EOT]\bg\t\n\
    \\f\n\
    \\ENQ\EOT\SOH\b\NUL\SOH\DC2\ETX]\SO\NAK\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\NUL\DC2\ETX^\DLE$\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ACK\DC2\ETX^\DLE\EM\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\SOH\DC2\ETX^\SUB\US\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ETX\DC2\ETX^\"#\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\SOH\DC2\ETX_\DLE:\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\ACK\DC2\ETX_\DLE(\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\SOH\DC2\ETX_)5\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\ETX\DC2\ETX_89\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\STX\DC2\ETX`\DLE*\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\STX\ACK\DC2\ETX`\DLE\SUB\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\STX\SOH\DC2\ETX`\ESC%\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\STX\ETX\DC2\ETX`()\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\ETX\DC2\ETXa\DLE4\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\ETX\ACK\DC2\ETXa\DLE\RS\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\ETX\SOH\DC2\ETXa\US/\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\ETX\ETX\DC2\ETXa23\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\EOT\DC2\ETXb\DLE1\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\EOT\ENQ\DC2\ETXb\DLE\SYN\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\EOT\SOH\DC2\ETXb\ETB,\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\EOT\ETX\DC2\ETXb/0\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\ENQ\DC2\ETXc\DLE0\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\ENQ\ENQ\DC2\ETXc\DLE\SYN\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\ENQ\SOH\DC2\ETXc\ETB+\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\ENQ\ETX\DC2\ETXc./\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\ACK\DC2\ETXd\DLE?\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\ACK\ACK\DC2\ETXd\DLE!\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\ACK\SOH\DC2\ETXd\":\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\ACK\ETX\DC2\ETXd=>\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\a\DC2\ETXe\DLE'\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\a\ACK\DC2\ETXe\DLE\CAN\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\a\SOH\DC2\ETXe\EM\"\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\a\ETX\DC2\ETXe%&\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\b\DC2\ETXf\DLE+\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\b\ACK\DC2\ETXf\DLE\SUB\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\b\SOH\DC2\ETXf\ESC&\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\b\ETX\DC2\ETXf)*\n\
    \N\n\
    \\EOT\EOT\SOH\ETX\NUL\DC2\EOTj\bw\t\SUB@ The $all or stream subscription has caught up and become live.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\SOH\ETX\NUL\SOH\DC2\ETXj\DLE\CAN\n\
    \K\n\
    \\ACK\EOT\SOH\ETX\NUL\STX\NUL\DC2\ETXl\DLE8\SUB< Current time in the server when the subscription caught up\n\
    \\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\NUL\STX\NUL\ACK\DC2\ETXl\DLE)\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\NUL\STX\NUL\SOH\DC2\ETXl*3\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\NUL\STX\NUL\ETX\DC2\ETXl67\n\
    \\179\SOH\n\
    \\ACK\EOT\SOH\ETX\NUL\STX\SOH\DC2\ETXq\DLE3\SUB\163\SOH Checkpoint for resuming a stream subscription.\n\
    \ For stream subscriptions it is populated unless the stream is empty.\n\
    \ For $all subscriptions it is not populated.\n\
    \\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\NUL\STX\SOH\EOT\DC2\ETXq\DLE\CAN\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\NUL\STX\SOH\ENQ\DC2\ETXq\EM\RS\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\NUL\STX\SOH\SOH\DC2\ETXq\US.\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\NUL\STX\SOH\ETX\DC2\ETXq12\n\
    \\179\SOH\n\
    \\ACK\EOT\SOH\ETX\NUL\STX\STX\DC2\ETXv\DLE/\SUB\163\SOH Checkpoint for resuming a $all subscription.\n\
    \ For stream subscriptions it is not populated.\n\
    \ For $all subscriptions it is populated unless the database is empty.\n\
    \\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\NUL\STX\STX\EOT\DC2\ETXv\DLE\CAN\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\NUL\STX\STX\ACK\DC2\ETXv\EM!\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\NUL\STX\STX\SOH\DC2\ETXv\"*\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\NUL\STX\STX\ETX\DC2\ETXv-.\n\
    \i\n\
    \\EOT\EOT\SOH\ETX\SOH\DC2\ENQz\b\135\SOH\t\SUBZ The $all or stream subscription has fallen back into catchup mode and is no longer live.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\SOH\ETX\SOH\SOH\DC2\ETXz\DLE\SUB\n\
    \M\n\
    \\ACK\EOT\SOH\ETX\SOH\STX\NUL\DC2\ETX|\DLE8\SUB> Current time in the server when the subscription fell behind\n\
    \\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\STX\NUL\ACK\DC2\ETX|\DLE)\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\STX\NUL\SOH\DC2\ETX|*3\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\STX\NUL\ETX\DC2\ETX|67\n\
    \\180\SOH\n\
    \\ACK\EOT\SOH\ETX\SOH\STX\SOH\DC2\EOT\129\SOH\DLE3\SUB\163\SOH Checkpoint for resuming a stream subscription.\n\
    \ For stream subscriptions it is populated unless the stream is empty.\n\
    \ For $all subscriptions it is not populated.\n\
    \\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\SOH\STX\SOH\EOT\DC2\EOT\129\SOH\DLE\CAN\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\SOH\STX\SOH\ENQ\DC2\EOT\129\SOH\EM\RS\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\SOH\STX\SOH\SOH\DC2\EOT\129\SOH\US.\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\SOH\STX\SOH\ETX\DC2\EOT\129\SOH12\n\
    \\180\SOH\n\
    \\ACK\EOT\SOH\ETX\SOH\STX\STX\DC2\EOT\134\SOH\DLE/\SUB\163\SOH Checkpoint for resuming a $all subscription.\n\
    \ For stream subscriptions it is not populated.\n\
    \ For $all subscriptions it is populated unless the database is empty.\n\
    \\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\SOH\STX\STX\EOT\DC2\EOT\134\SOH\DLE\CAN\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\SOH\STX\STX\ACK\DC2\EOT\134\SOH\EM!\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\SOH\STX\STX\SOH\DC2\EOT\134\SOH\"*\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\SOH\STX\STX\ETX\DC2\EOT\134\SOH-.\n\
    \\SO\n\
    \\EOT\EOT\SOH\ETX\STX\DC2\ACK\137\SOH\b\155\SOH\t\n\
    \\r\n\
    \\ENQ\EOT\SOH\ETX\STX\SOH\DC2\EOT\137\SOH\DLE\EM\n\
    \\SO\n\
    \\ACK\EOT\SOH\ETX\STX\STX\NUL\DC2\EOT\138\SOH\DLE(\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\STX\STX\NUL\ACK\DC2\EOT\138\SOH\DLE\GS\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\STX\STX\NUL\SOH\DC2\EOT\138\SOH\RS#\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\STX\STX\NUL\ETX\DC2\EOT\138\SOH&'\n\
    \\SO\n\
    \\ACK\EOT\SOH\ETX\STX\STX\SOH\DC2\EOT\139\SOH\DLE'\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\STX\STX\SOH\ACK\DC2\EOT\139\SOH\DLE\GS\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\STX\STX\SOH\SOH\DC2\EOT\139\SOH\RS\"\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\STX\STX\SOH\ETX\DC2\EOT\139\SOH%&\n\
    \\DLE\n\
    \\ACK\EOT\SOH\ETX\STX\b\NUL\DC2\ACK\140\SOH\DLE\143\SOH\DC1\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\STX\b\NUL\SOH\DC2\EOT\140\SOH\SYN\RS\n\
    \\SO\n\
    \\ACK\EOT\SOH\ETX\STX\STX\STX\DC2\EOT\141\SOH\CAN3\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\STX\STX\STX\ENQ\DC2\EOT\141\SOH\CAN\RS\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\STX\STX\STX\SOH\DC2\EOT\141\SOH\US.\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\STX\STX\STX\ETX\DC2\EOT\141\SOH12\n\
    \\SO\n\
    \\ACK\EOT\SOH\ETX\STX\STX\ETX\DC2\EOT\142\SOH\CANA\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\STX\STX\ETX\ACK\DC2\EOT\142\SOH\CAN0\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\STX\STX\ETX\SOH\DC2\EOT\142\SOH1<\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\STX\STX\ETX\ETX\DC2\EOT\142\SOH?@\n\
    \\DLE\n\
    \\ACK\EOT\SOH\ETX\STX\ETX\NUL\DC2\ACK\145\SOH\DLE\154\SOH\DC1\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\STX\ETX\NUL\SOH\DC2\EOT\145\SOH\CAN%\n\
    \\DLE\n\
    \\b\EOT\SOH\ETX\STX\ETX\NUL\STX\NUL\DC2\EOT\146\SOH\CAN7\n\
    \\DC1\n\
    \\t\EOT\SOH\ETX\STX\ETX\NUL\STX\NUL\ACK\DC2\EOT\146\SOH\CAN/\n\
    \\DC1\n\
    \\t\EOT\SOH\ETX\STX\ETX\NUL\STX\NUL\SOH\DC2\EOT\146\SOH02\n\
    \\DC1\n\
    \\t\EOT\SOH\ETX\STX\ETX\NUL\STX\NUL\ETX\DC2\EOT\146\SOH56\n\
    \\DLE\n\
    \\b\EOT\SOH\ETX\STX\ETX\NUL\STX\SOH\DC2\EOT\147\SOH\CANR\n\
    \\DC1\n\
    \\t\EOT\SOH\ETX\STX\ETX\NUL\STX\SOH\ACK\DC2\EOT\147\SOH\CAN;\n\
    \\DC1\n\
    \\t\EOT\SOH\ETX\STX\ETX\NUL\STX\SOH\SOH\DC2\EOT\147\SOH<M\n\
    \\DC1\n\
    \\t\EOT\SOH\ETX\STX\ETX\NUL\STX\SOH\ETX\DC2\EOT\147\SOHPQ\n\
    \\DLE\n\
    \\b\EOT\SOH\ETX\STX\ETX\NUL\STX\STX\DC2\EOT\148\SOH\CAN3\n\
    \\DC1\n\
    \\t\EOT\SOH\ETX\STX\ETX\NUL\STX\STX\ENQ\DC2\EOT\148\SOH\CAN\RS\n\
    \\DC1\n\
    \\t\EOT\SOH\ETX\STX\ETX\NUL\STX\STX\SOH\DC2\EOT\148\SOH\US.\n\
    \\DC1\n\
    \\t\EOT\SOH\ETX\STX\ETX\NUL\STX\STX\ETX\DC2\EOT\148\SOH12\n\
    \\DLE\n\
    \\b\EOT\SOH\ETX\STX\ETX\NUL\STX\ETX\DC2\EOT\149\SOH\CAN4\n\
    \\DC1\n\
    \\t\EOT\SOH\ETX\STX\ETX\NUL\STX\ETX\ENQ\DC2\EOT\149\SOH\CAN\RS\n\
    \\DC1\n\
    \\t\EOT\SOH\ETX\STX\ETX\NUL\STX\ETX\SOH\DC2\EOT\149\SOH\US/\n\
    \\DC1\n\
    \\t\EOT\SOH\ETX\STX\ETX\NUL\STX\ETX\ETX\DC2\EOT\149\SOH23\n\
    \\DLE\n\
    \\b\EOT\SOH\ETX\STX\ETX\NUL\STX\EOT\DC2\EOT\150\SOH\CAN3\n\
    \\DC1\n\
    \\t\EOT\SOH\ETX\STX\ETX\NUL\STX\EOT\ENQ\DC2\EOT\150\SOH\CAN\RS\n\
    \\DC1\n\
    \\t\EOT\SOH\ETX\STX\ETX\NUL\STX\EOT\SOH\DC2\EOT\150\SOH\US.\n\
    \\DC1\n\
    \\t\EOT\SOH\ETX\STX\ETX\NUL\STX\EOT\ETX\DC2\EOT\150\SOH12\n\
    \\DLE\n\
    \\b\EOT\SOH\ETX\STX\ETX\NUL\STX\ENQ\DC2\EOT\151\SOH\CAN9\n\
    \\DC1\n\
    \\t\EOT\SOH\ETX\STX\ETX\NUL\STX\ENQ\ACK\DC2\EOT\151\SOH\CAN+\n\
    \\DC1\n\
    \\t\EOT\SOH\ETX\STX\ETX\NUL\STX\ENQ\SOH\DC2\EOT\151\SOH,4\n\
    \\DC1\n\
    \\t\EOT\SOH\ETX\STX\ETX\NUL\STX\ENQ\ETX\DC2\EOT\151\SOH78\n\
    \\DLE\n\
    \\b\EOT\SOH\ETX\STX\ETX\NUL\STX\ACK\DC2\EOT\152\SOH\CAN2\n\
    \\DC1\n\
    \\t\EOT\SOH\ETX\STX\ETX\NUL\STX\ACK\ENQ\DC2\EOT\152\SOH\CAN\GS\n\
    \\DC1\n\
    \\t\EOT\SOH\ETX\STX\ETX\NUL\STX\ACK\SOH\DC2\EOT\152\SOH\RS-\n\
    \\DC1\n\
    \\t\EOT\SOH\ETX\STX\ETX\NUL\STX\ACK\ETX\DC2\EOT\152\SOH01\n\
    \\DLE\n\
    \\b\EOT\SOH\ETX\STX\ETX\NUL\STX\a\DC2\EOT\153\SOH\CAN'\n\
    \\DC1\n\
    \\t\EOT\SOH\ETX\STX\ETX\NUL\STX\a\ENQ\DC2\EOT\153\SOH\CAN\GS\n\
    \\DC1\n\
    \\t\EOT\SOH\ETX\STX\ETX\NUL\STX\a\SOH\DC2\EOT\153\SOH\RS\"\n\
    \\DC1\n\
    \\t\EOT\SOH\ETX\STX\ETX\NUL\STX\a\ETX\DC2\EOT\153\SOH%&\n\
    \\SO\n\
    \\EOT\EOT\SOH\ETX\ETX\DC2\ACK\156\SOH\b\158\SOH\t\n\
    \\r\n\
    \\ENQ\EOT\SOH\ETX\ETX\SOH\DC2\EOT\156\SOH\DLE(\n\
    \\SO\n\
    \\ACK\EOT\SOH\ETX\ETX\STX\NUL\DC2\EOT\157\SOH\DLE+\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\ETX\STX\NUL\ENQ\DC2\EOT\157\SOH\DLE\SYN\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\ETX\STX\NUL\SOH\DC2\EOT\157\SOH\ETB&\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\ETX\STX\NUL\ETX\DC2\EOT\157\SOH)*\n\
    \\SO\n\
    \\EOT\EOT\SOH\ETX\EOT\DC2\ACK\159\SOH\b\165\SOH\t\n\
    \\r\n\
    \\ENQ\EOT\SOH\ETX\EOT\SOH\DC2\EOT\159\SOH\DLE\SUB\n\
    \\SO\n\
    \\ACK\EOT\SOH\ETX\EOT\STX\NUL\DC2\EOT\160\SOH\DLE+\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\EOT\STX\NUL\ENQ\DC2\EOT\160\SOH\DLE\SYN\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\EOT\STX\NUL\SOH\DC2\EOT\160\SOH\ETB&\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\EOT\STX\NUL\ETX\DC2\EOT\160\SOH)*\n\
    \\SO\n\
    \\ACK\EOT\SOH\ETX\EOT\STX\SOH\DC2\EOT\161\SOH\DLE,\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\EOT\STX\SOH\ENQ\DC2\EOT\161\SOH\DLE\SYN\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\EOT\STX\SOH\SOH\DC2\EOT\161\SOH\ETB'\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\EOT\STX\SOH\ETX\DC2\EOT\161\SOH*+\n\
    \L\n\
    \\ACK\EOT\SOH\ETX\EOT\STX\STX\DC2\EOT\164\SOH\DLE8\SUB< Current time in the server when the checkpoint was reached\n\
    \\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\EOT\STX\STX\ACK\DC2\EOT\164\SOH\DLE)\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\EOT\STX\STX\SOH\DC2\EOT\164\SOH*3\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\EOT\STX\STX\ETX\DC2\EOT\164\SOH67\n\
    \\SO\n\
    \\EOT\EOT\SOH\ETX\ENQ\DC2\ACK\167\SOH\b\170\SOH\t\n\
    \\r\n\
    \\ENQ\EOT\SOH\ETX\ENQ\SOH\DC2\EOT\167\SOH\DLE\CAN\n\
    \\SO\n\
    \\ACK\EOT\SOH\ETX\ENQ\STX\NUL\DC2\EOT\168\SOH\DLE+\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\ENQ\STX\NUL\ENQ\DC2\EOT\168\SOH\DLE\SYN\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\ENQ\STX\NUL\SOH\DC2\EOT\168\SOH\ETB&\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\ENQ\STX\NUL\ETX\DC2\EOT\168\SOH)*\n\
    \\SO\n\
    \\ACK\EOT\SOH\ETX\ENQ\STX\SOH\DC2\EOT\169\SOH\DLE,\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\ENQ\STX\SOH\ENQ\DC2\EOT\169\SOH\DLE\SYN\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\ENQ\STX\SOH\SOH\DC2\EOT\169\SOH\ETB'\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\ENQ\STX\SOH\ETX\DC2\EOT\169\SOH*+\n\
    \\SO\n\
    \\EOT\EOT\SOH\ETX\ACK\DC2\ACK\172\SOH\b\174\SOH\t\n\
    \\r\n\
    \\ENQ\EOT\SOH\ETX\ACK\SOH\DC2\EOT\172\SOH\DLE\RS\n\
    \\SO\n\
    \\ACK\EOT\SOH\ETX\ACK\STX\NUL\DC2\EOT\173\SOH\DLEJ\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\ACK\STX\NUL\ACK\DC2\EOT\173\SOH\DLE3\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\ACK\STX\NUL\SOH\DC2\EOT\173\SOH4E\n\
    \\SI\n\
    \\a\EOT\SOH\ETX\ACK\STX\NUL\ETX\DC2\EOT\173\SOHHI\n\
    \\f\n\
    \\STX\EOT\STX\DC2\ACK\177\SOH\NUL\198\SOH\SOH\n\
    \\v\n\
    \\ETX\EOT\STX\SOH\DC2\EOT\177\SOH\b\DC1\n\
    \\SO\n\
    \\EOT\EOT\STX\b\NUL\DC2\ACK\178\SOH\b\181\SOH\t\n\
    \\r\n\
    \\ENQ\EOT\STX\b\NUL\SOH\DC2\EOT\178\SOH\SO\NAK\n\
    \\f\n\
    \\EOT\EOT\STX\STX\NUL\DC2\EOT\179\SOH\DLE$\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\NUL\ACK\DC2\EOT\179\SOH\DLE\ETB\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\NUL\SOH\DC2\EOT\179\SOH\CAN\US\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\NUL\ETX\DC2\EOT\179\SOH\"#\n\
    \\f\n\
    \\EOT\EOT\STX\STX\SOH\DC2\EOT\180\SOH\DLE5\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\SOH\ACK\DC2\EOT\180\SOH\DLE\US\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\SOH\SOH\DC2\EOT\180\SOH 0\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\SOH\ETX\DC2\EOT\180\SOH34\n\
    \\SO\n\
    \\EOT\EOT\STX\ETX\NUL\DC2\ACK\183\SOH\b\191\SOH\t\n\
    \\r\n\
    \\ENQ\EOT\STX\ETX\NUL\SOH\DC2\EOT\183\SOH\DLE\ETB\n\
    \\SO\n\
    \\ACK\EOT\STX\ETX\NUL\STX\NUL\DC2\EOT\184\SOH\DLEJ\n\
    \\SI\n\
    \\a\EOT\STX\ETX\NUL\STX\NUL\ACK\DC2\EOT\184\SOH\DLE3\n\
    \\SI\n\
    \\a\EOT\STX\ETX\NUL\STX\NUL\SOH\DC2\EOT\184\SOH4E\n\
    \\SI\n\
    \\a\EOT\STX\ETX\NUL\STX\NUL\ETX\DC2\EOT\184\SOHHI\n\
    \\DLE\n\
    \\ACK\EOT\STX\ETX\NUL\b\NUL\DC2\ACK\185\SOH\DLE\190\SOH\DC1\n\
    \\SI\n\
    \\a\EOT\STX\ETX\NUL\b\NUL\SOH\DC2\EOT\185\SOH\SYN.\n\
    \\SO\n\
    \\ACK\EOT\STX\ETX\NUL\STX\SOH\DC2\EOT\186\SOH\CAN,\n\
    \\SI\n\
    \\a\EOT\STX\ETX\NUL\STX\SOH\ENQ\DC2\EOT\186\SOH\CAN\RS\n\
    \\SI\n\
    \\a\EOT\STX\ETX\NUL\STX\SOH\SOH\DC2\EOT\186\SOH\US'\n\
    \\SI\n\
    \\a\EOT\STX\ETX\NUL\STX\SOH\ETX\DC2\EOT\186\SOH*+\n\
    \\SO\n\
    \\ACK\EOT\STX\ETX\NUL\STX\STX\DC2\EOT\187\SOH\CAN?\n\
    \\SI\n\
    \\a\EOT\STX\ETX\NUL\STX\STX\ACK\DC2\EOT\187\SOH\CAN0\n\
    \\SI\n\
    \\a\EOT\STX\ETX\NUL\STX\STX\SOH\DC2\EOT\187\SOH1:\n\
    \\SI\n\
    \\a\EOT\STX\ETX\NUL\STX\STX\ETX\DC2\EOT\187\SOH=>\n\
    \\SO\n\
    \\ACK\EOT\STX\ETX\NUL\STX\ETX\DC2\EOT\188\SOH\CAN9\n\
    \\SI\n\
    \\a\EOT\STX\ETX\NUL\STX\ETX\ACK\DC2\EOT\188\SOH\CAN0\n\
    \\SI\n\
    \\a\EOT\STX\ETX\NUL\STX\ETX\SOH\DC2\EOT\188\SOH14\n\
    \\SI\n\
    \\a\EOT\STX\ETX\NUL\STX\ETX\ETX\DC2\EOT\188\SOH78\n\
    \\SO\n\
    \\ACK\EOT\STX\ETX\NUL\STX\EOT\DC2\EOT\189\SOH\CANC\n\
    \\SI\n\
    \\a\EOT\STX\ETX\NUL\STX\EOT\ACK\DC2\EOT\189\SOH\CAN0\n\
    \\SI\n\
    \\a\EOT\STX\ETX\NUL\STX\EOT\SOH\DC2\EOT\189\SOH1>\n\
    \\SI\n\
    \\a\EOT\STX\ETX\NUL\STX\EOT\ETX\DC2\EOT\189\SOHAB\n\
    \\SO\n\
    \\EOT\EOT\STX\ETX\SOH\DC2\ACK\192\SOH\b\197\SOH\t\n\
    \\r\n\
    \\ENQ\EOT\STX\ETX\SOH\SOH\DC2\EOT\192\SOH\DLE\US\n\
    \\SO\n\
    \\ACK\EOT\STX\ETX\SOH\STX\NUL\DC2\EOT\193\SOH\DLE/\n\
    \\SI\n\
    \\a\EOT\STX\ETX\SOH\STX\NUL\ACK\DC2\EOT\193\SOH\DLE'\n\
    \\SI\n\
    \\a\EOT\STX\ETX\SOH\STX\NUL\SOH\DC2\EOT\193\SOH(*\n\
    \\SI\n\
    \\a\EOT\STX\ETX\SOH\STX\NUL\ETX\DC2\EOT\193\SOH-.\n\
    \\SO\n\
    \\ACK\EOT\STX\ETX\SOH\STX\SOH\DC2\EOT\194\SOH\DLE1\n\
    \\SI\n\
    \\a\EOT\STX\ETX\SOH\STX\SOH\ACK\DC2\EOT\194\SOH\DLE#\n\
    \\SI\n\
    \\a\EOT\STX\ETX\SOH\STX\SOH\SOH\DC2\EOT\194\SOH$,\n\
    \\SI\n\
    \\a\EOT\STX\ETX\SOH\STX\SOH\ETX\DC2\EOT\194\SOH/0\n\
    \\SO\n\
    \\ACK\EOT\STX\ETX\SOH\STX\STX\DC2\EOT\195\SOH\DLE*\n\
    \\SI\n\
    \\a\EOT\STX\ETX\SOH\STX\STX\ENQ\DC2\EOT\195\SOH\DLE\NAK\n\
    \\SI\n\
    \\a\EOT\STX\ETX\SOH\STX\STX\SOH\DC2\EOT\195\SOH\SYN%\n\
    \\SI\n\
    \\a\EOT\STX\ETX\SOH\STX\STX\ETX\DC2\EOT\195\SOH()\n\
    \\SO\n\
    \\ACK\EOT\STX\ETX\SOH\STX\ETX\DC2\EOT\196\SOH\DLE\US\n\
    \\SI\n\
    \\a\EOT\STX\ETX\SOH\STX\ETX\ENQ\DC2\EOT\196\SOH\DLE\NAK\n\
    \\SI\n\
    \\a\EOT\STX\ETX\SOH\STX\ETX\SOH\DC2\EOT\196\SOH\SYN\SUB\n\
    \\SI\n\
    \\a\EOT\STX\ETX\SOH\STX\ETX\ETX\DC2\EOT\196\SOH\GS\RS\n\
    \\f\n\
    \\STX\EOT\ETX\DC2\ACK\200\SOH\NUL\244\SOH\SOH\n\
    \\v\n\
    \\ETX\EOT\ETX\SOH\DC2\EOT\200\SOH\b\DC2\n\
    \\SO\n\
    \\EOT\EOT\ETX\b\NUL\DC2\ACK\201\SOH\b\204\SOH\t\n\
    \\r\n\
    \\ENQ\EOT\ETX\b\NUL\SOH\DC2\EOT\201\SOH\SO\DC4\n\
    \\f\n\
    \\EOT\EOT\ETX\STX\NUL\DC2\EOT\202\SOH\DLE$\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\NUL\ACK\DC2\EOT\202\SOH\DLE\ETB\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\NUL\SOH\DC2\EOT\202\SOH\CAN\US\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\NUL\ETX\DC2\EOT\202\SOH\"#\n\
    \\f\n\
    \\EOT\EOT\ETX\STX\SOH\DC2\EOT\203\SOH\DLE@\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\SOH\ACK\DC2\EOT\203\SOH\DLE$\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\SOH\SOH\DC2\EOT\203\SOH%;\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\SOH\ETX\DC2\EOT\203\SOH>?\n\
    \\SO\n\
    \\EOT\EOT\ETX\ETX\NUL\DC2\ACK\206\SOH\b\209\SOH\t\n\
    \\r\n\
    \\ENQ\EOT\ETX\ETX\NUL\SOH\DC2\EOT\206\SOH\DLE\CAN\n\
    \\SO\n\
    \\ACK\EOT\ETX\ETX\NUL\STX\NUL\DC2\EOT\207\SOH\DLE+\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\NUL\STX\NUL\ENQ\DC2\EOT\207\SOH\DLE\SYN\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\NUL\STX\NUL\SOH\DC2\EOT\207\SOH\ETB&\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\NUL\STX\NUL\ETX\DC2\EOT\207\SOH)*\n\
    \\SO\n\
    \\ACK\EOT\ETX\ETX\NUL\STX\SOH\DC2\EOT\208\SOH\DLE,\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\NUL\STX\SOH\ENQ\DC2\EOT\208\SOH\DLE\SYN\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\NUL\STX\SOH\SOH\DC2\EOT\208\SOH\ETB'\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\NUL\STX\SOH\ETX\DC2\EOT\208\SOH*+\n\
    \\SO\n\
    \\EOT\EOT\ETX\ETX\SOH\DC2\ACK\211\SOH\b\220\SOH\t\n\
    \\r\n\
    \\ENQ\EOT\ETX\ETX\SOH\SOH\DC2\EOT\211\SOH\DLE\ETB\n\
    \\DLE\n\
    \\ACK\EOT\ETX\ETX\SOH\b\NUL\DC2\ACK\212\SOH\DLE\215\SOH\DC1\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\b\NUL\SOH\DC2\EOT\212\SOH\SYN-\n\
    \\SO\n\
    \\ACK\EOT\ETX\ETX\SOH\STX\NUL\DC2\EOT\213\SOH\CAN4\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\NUL\ENQ\DC2\EOT\213\SOH\CAN\RS\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\NUL\SOH\DC2\EOT\213\SOH\US/\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\NUL\ETX\DC2\EOT\213\SOH23\n\
    \\SO\n\
    \\ACK\EOT\ETX\ETX\SOH\STX\SOH\DC2\EOT\214\SOH\CAN?\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\SOH\ACK\DC2\EOT\214\SOH\CAN0\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\SOH\SOH\DC2\EOT\214\SOH1:\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\SOH\ETX\DC2\EOT\214\SOH=>\n\
    \\DLE\n\
    \\ACK\EOT\ETX\ETX\SOH\b\SOH\DC2\ACK\216\SOH\DLE\219\SOH\DC1\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\b\SOH\SOH\DC2\EOT\216\SOH\SYN%\n\
    \\SO\n\
    \\ACK\EOT\ETX\ETX\SOH\STX\STX\DC2\EOT\217\SOH\CAN.\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\STX\ACK\DC2\EOT\217\SOH\CAN \n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\STX\SOH\DC2\EOT\217\SOH!)\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\STX\ETX\DC2\EOT\217\SOH,-\n\
    \\SO\n\
    \\ACK\EOT\ETX\ETX\SOH\STX\ETX\DC2\EOT\218\SOH\CANA\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\ETX\ACK\DC2\EOT\218\SOH\CAN0\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\ETX\SOH\DC2\EOT\218\SOH1<\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\ETX\ETX\DC2\EOT\218\SOH?@\n\
    \\SO\n\
    \\EOT\EOT\ETX\ETX\STX\DC2\ACK\222\SOH\b\243\SOH\t\n\
    \\r\n\
    \\ENQ\EOT\ETX\ETX\STX\SOH\DC2\EOT\222\SOH\DLE$\n\
    \\DLE\n\
    \\ACK\EOT\ETX\ETX\STX\b\NUL\DC2\ACK\223\SOH\DLE\226\SOH\DC1\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\b\NUL\SOH\DC2\EOT\223\SOH\SYN4\n\
    \\SO\n\
    \\ACK\EOT\ETX\ETX\STX\STX\NUL\DC2\EOT\224\SOH\CAN;\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\NUL\ENQ\DC2\EOT\224\SOH\CAN\RS\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\NUL\SOH\DC2\EOT\224\SOH\US6\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\NUL\ETX\DC2\EOT\224\SOH9:\n\
    \\SO\n\
    \\ACK\EOT\ETX\ETX\STX\STX\SOH\DC2\EOT\225\SOH\CANF\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\SOH\ACK\DC2\EOT\225\SOH\CAN0\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\SOH\SOH\DC2\EOT\225\SOH1A\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\SOH\ETX\DC2\EOT\225\SOHDE\n\
    \\DLE\n\
    \\ACK\EOT\ETX\ETX\STX\b\SOH\DC2\ACK\227\SOH\DLE\231\SOH\DC1\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\b\SOH\SOH\DC2\EOT\227\SOH\SYN5\n\
    \\SO\n\
    \\ACK\EOT\ETX\ETX\STX\STX\STX\DC2\EOT\228\SOH\CAN<\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\STX\ENQ\DC2\EOT\228\SOH\CAN\RS\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\STX\SOH\DC2\EOT\228\SOH\US7\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\STX\ETX\DC2\EOT\228\SOH:;\n\
    \\SO\n\
    \\ACK\EOT\ETX\ETX\STX\STX\ETX\DC2\EOT\229\SOH\CAN@\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\ETX\ACK\DC2\EOT\229\SOH\CAN0\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\ETX\SOH\DC2\EOT\229\SOH1;\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\ETX\ETX\DC2\EOT\229\SOH>?\n\
    \\SO\n\
    \\ACK\EOT\ETX\ETX\STX\STX\EOT\DC2\EOT\230\SOH\CANJ\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\EOT\ACK\DC2\EOT\230\SOH\CAN0\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\EOT\SOH\DC2\EOT\230\SOH1E\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\EOT\ETX\DC2\EOT\230\SOHHI\n\
    \\DLE\n\
    \\ACK\EOT\ETX\ETX\STX\b\STX\DC2\ACK\232\SOH\DLE\235\SOH\DC1\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\b\STX\SOH\DC2\EOT\232\SOH\SYN-\n\
    \\SO\n\
    \\ACK\EOT\ETX\ETX\STX\STX\ENQ\DC2\EOT\233\SOH\CAN4\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\ENQ\ENQ\DC2\EOT\233\SOH\CAN\RS\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\ENQ\SOH\DC2\EOT\233\SOH\US/\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\ENQ\ETX\DC2\EOT\233\SOH23\n\
    \\SO\n\
    \\ACK\EOT\ETX\ETX\STX\STX\ACK\DC2\EOT\234\SOH\CANG\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\ACK\ACK\DC2\EOT\234\SOH\CAN0\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\ACK\SOH\DC2\EOT\234\SOH1B\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\ACK\ETX\DC2\EOT\234\SOHEF\n\
    \\DLE\n\
    \\ACK\EOT\ETX\ETX\STX\b\ETX\DC2\ACK\236\SOH\DLE\241\SOH\DC1\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\b\ETX\SOH\DC2\EOT\236\SOH\SYN.\n\
    \\SO\n\
    \\ACK\EOT\ETX\ETX\STX\STX\a\DC2\EOT\237\SOH\CAN5\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\a\ENQ\DC2\EOT\237\SOH\CAN\RS\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\a\SOH\DC2\EOT\237\SOH\US0\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\a\ETX\DC2\EOT\237\SOH34\n\
    \\SO\n\
    \\ACK\EOT\ETX\ETX\STX\STX\b\DC2\EOT\238\SOH\CANB\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\b\ACK\DC2\EOT\238\SOH\CAN0\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\b\SOH\DC2\EOT\238\SOH1=\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\b\ETX\DC2\EOT\238\SOH@A\n\
    \\SO\n\
    \\ACK\EOT\ETX\ETX\STX\STX\t\DC2\EOT\239\SOH\CANM\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\t\ACK\DC2\EOT\239\SOH\CAN0\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\t\SOH\DC2\EOT\239\SOH1G\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\t\ETX\DC2\EOT\239\SOHJL\n\
    \\SO\n\
    \\ACK\EOT\ETX\ETX\STX\STX\n\
    \\DC2\EOT\240\SOH\CANI\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\n\
    \\ACK\DC2\EOT\240\SOH\CAN0\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\n\
    \\SOH\DC2\EOT\240\SOH1C\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\STX\STX\n\
    \\ETX\DC2\EOT\240\SOHFH\n\
    \\f\n\
    \\STX\EOT\EOT\DC2\ACK\246\SOH\NUL\144\STX\SOH\n\
    \\v\n\
    \\ETX\EOT\EOT\SOH\DC2\EOT\246\SOH\b\SYN\n\
    \\f\n\
    \\EOT\EOT\EOT\STX\NUL\DC2\EOT\247\SOH\b3\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\NUL\ACK\DC2\EOT\247\SOH\b\US\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\NUL\SOH\DC2\EOT\247\SOH .\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\NUL\ETX\DC2\EOT\247\SOH12\n\
    \\f\n\
    \\EOT\EOT\EOT\STX\SOH\DC2\EOT\248\SOH\b\FS\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\SOH\ACK\DC2\EOT\248\SOH\b\SI\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\SOH\SOH\DC2\EOT\248\SOH\DLE\ETB\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\SOH\ETX\DC2\EOT\248\SOH\SUB\ESC\n\
    \\f\n\
    \\EOT\EOT\EOT\STX\STX\DC2\EOT\249\SOH\b7\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\STX\EOT\DC2\EOT\249\SOH\b\DLE\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\STX\ACK\DC2\EOT\249\SOH\DC1 \n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\STX\SOH\DC2\EOT\249\SOH!2\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\STX\ETX\DC2\EOT\249\SOH56\n\
    \\f\n\
    \\EOT\EOT\EOT\STX\ETX\DC2\EOT\250\SOH\b\SUB\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\ETX\ENQ\DC2\EOT\250\SOH\b\f\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\ETX\SOH\DC2\EOT\250\SOH\r\NAK\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\ETX\ETX\DC2\EOT\250\SOH\CAN\EM\n\
    \\SO\n\
    \\EOT\EOT\EOT\ETX\NUL\DC2\ACK\252\SOH\b\136\STX\t\n\
    \\r\n\
    \\ENQ\EOT\EOT\ETX\NUL\SOH\DC2\EOT\252\SOH\DLE\ETB\n\
    \\SO\n\
    \\ACK\EOT\EOT\ETX\NUL\STX\NUL\DC2\EOT\253\SOH\DLEJ\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\NUL\STX\NUL\ACK\DC2\EOT\253\SOH\DLE3\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\NUL\STX\NUL\SOH\DC2\EOT\253\SOH4E\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\NUL\STX\NUL\ETX\DC2\EOT\253\SOHHI\n\
    \\DLE\n\
    \\ACK\EOT\EOT\ETX\NUL\b\NUL\DC2\ACK\254\SOH\DLE\131\STX\DC1\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\NUL\b\NUL\SOH\DC2\EOT\254\SOH\SYN.\n\
    \\SO\n\
    \\ACK\EOT\EOT\ETX\NUL\STX\SOH\DC2\EOT\255\SOH\CAN3\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\NUL\STX\SOH\ENQ\DC2\EOT\255\SOH\CAN\RS\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\NUL\STX\SOH\SOH\DC2\EOT\255\SOH\US.\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\NUL\STX\SOH\ETX\DC2\EOT\255\SOH12\n\
    \\SO\n\
    \\ACK\EOT\EOT\ETX\NUL\STX\STX\DC2\EOT\128\STX\CAN<\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\NUL\STX\STX\ACK\DC2\EOT\128\STX\CAN-\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\NUL\STX\STX\SOH\DC2\EOT\128\STX.7\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\NUL\STX\STX\ETX\DC2\EOT\128\STX:;\n\
    \\SO\n\
    \\ACK\EOT\EOT\ETX\NUL\STX\ETX\DC2\EOT\129\STX\CAN6\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\NUL\STX\ETX\ACK\DC2\EOT\129\STX\CAN-\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\NUL\STX\ETX\SOH\DC2\EOT\129\STX.1\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\NUL\STX\ETX\ETX\DC2\EOT\129\STX45\n\
    \\SO\n\
    \\ACK\EOT\EOT\ETX\NUL\STX\EOT\DC2\EOT\130\STX\CAN@\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\NUL\STX\EOT\ACK\DC2\EOT\130\STX\CAN-\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\NUL\STX\EOT\SOH\DC2\EOT\130\STX.;\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\NUL\STX\EOT\ETX\DC2\EOT\130\STX>?\n\
    \\DLE\n\
    \\ACK\EOT\EOT\ETX\NUL\b\SOH\DC2\ACK\132\STX\DLE\135\STX\DC1\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\NUL\b\SOH\SOH\DC2\EOT\132\STX\SYN%\n\
    \\SO\n\
    \\ACK\EOT\EOT\ETX\NUL\STX\ENQ\DC2\EOT\133\STX\CANG\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\NUL\STX\ENQ\ACK\DC2\EOT\133\STX\CAN1\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\NUL\STX\ENQ\SOH\DC2\EOT\133\STX2B\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\NUL\STX\ENQ\ETX\DC2\EOT\133\STXEF\n\
    \\SO\n\
    \\ACK\EOT\EOT\ETX\NUL\STX\ACK\DC2\EOT\134\STX\CAN>\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\NUL\STX\ACK\ACK\DC2\EOT\134\STX\CAN0\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\NUL\STX\ACK\SOH\DC2\EOT\134\STX19\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\NUL\STX\ACK\ETX\DC2\EOT\134\STX<=\n\
    \\SO\n\
    \\EOT\EOT\EOT\ETX\SOH\DC2\ACK\138\STX\b\143\STX\t\n\
    \\r\n\
    \\ENQ\EOT\EOT\ETX\SOH\SOH\DC2\EOT\138\STX\DLE\US\n\
    \\SO\n\
    \\ACK\EOT\EOT\ETX\SOH\STX\NUL\DC2\EOT\139\STX\DLE/\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\SOH\STX\NUL\ACK\DC2\EOT\139\STX\DLE'\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\SOH\STX\NUL\SOH\DC2\EOT\139\STX(*\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\SOH\STX\NUL\ETX\DC2\EOT\139\STX-.\n\
    \\SO\n\
    \\ACK\EOT\EOT\ETX\SOH\STX\SOH\DC2\EOT\140\STX\DLE1\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\SOH\STX\SOH\ACK\DC2\EOT\140\STX\DLE#\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\SOH\STX\SOH\SOH\DC2\EOT\140\STX$,\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\SOH\STX\SOH\ETX\DC2\EOT\140\STX/0\n\
    \\SO\n\
    \\ACK\EOT\EOT\ETX\SOH\STX\STX\DC2\EOT\141\STX\DLE*\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\SOH\STX\STX\ENQ\DC2\EOT\141\STX\DLE\NAK\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\SOH\STX\STX\SOH\DC2\EOT\141\STX\SYN%\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\SOH\STX\STX\ETX\DC2\EOT\141\STX()\n\
    \\SO\n\
    \\ACK\EOT\EOT\ETX\SOH\STX\ETX\DC2\EOT\142\STX\DLE\US\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\SOH\STX\ETX\ENQ\DC2\EOT\142\STX\DLE\NAK\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\SOH\STX\ETX\SOH\DC2\EOT\142\STX\SYN\SUB\n\
    \\SI\n\
    \\a\EOT\EOT\ETX\SOH\STX\ETX\ETX\DC2\EOT\142\STX\GS\RS\n\
    \\f\n\
    \\STX\EOT\ENQ\DC2\ACK\146\STX\NUL\172\STX\SOH\n\
    \\v\n\
    \\ETX\EOT\ENQ\SOH\DC2\EOT\146\STX\b\ETB\n\
    \\f\n\
    \\EOT\EOT\ENQ\STX\NUL\DC2\EOT\147\STX\b3\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\NUL\ACK\DC2\EOT\147\STX\b\US\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\NUL\SOH\DC2\EOT\147\STX .\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\NUL\ETX\DC2\EOT\147\STX12\n\
    \\SO\n\
    \\EOT\EOT\ENQ\b\NUL\DC2\ACK\148\STX\b\151\STX\t\n\
    \\r\n\
    \\ENQ\EOT\ENQ\b\NUL\SOH\DC2\EOT\148\STX\SO\DC4\n\
    \\f\n\
    \\EOT\EOT\ENQ\STX\SOH\DC2\EOT\149\STX\DLE,\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\SOH\ACK\DC2\EOT\149\STX\DLE!\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\SOH\SOH\DC2\EOT\149\STX\"'\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\SOH\ETX\DC2\EOT\149\STX*+\n\
    \\f\n\
    \\EOT\EOT\ENQ\STX\STX\DC2\EOT\150\STX\DLE$\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\STX\ACK\DC2\EOT\150\STX\DLE\ETB\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\STX\SOH\DC2\EOT\150\STX\CAN\US\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\STX\ETX\DC2\EOT\150\STX\"#\n\
    \\f\n\
    \\EOT\EOT\ENQ\STX\ETX\DC2\EOT\153\STX\bB\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\ETX\ACK\DC2\EOT\153\STX\b+\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\ETX\SOH\DC2\EOT\153\STX,=\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\ETX\ETX\DC2\EOT\153\STX@A\n\
    \\SO\n\
    \\EOT\EOT\ENQ\b\SOH\DC2\ACK\155\STX\b\160\STX\t\n\
    \\r\n\
    \\ENQ\EOT\ENQ\b\SOH\SOH\DC2\EOT\155\STX\SO&\n\
    \\f\n\
    \\EOT\EOT\ENQ\STX\EOT\DC2\EOT\156\STX\DLE+\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\EOT\ENQ\DC2\EOT\156\STX\DLE\SYN\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\EOT\SOH\DC2\EOT\156\STX\ETB&\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\EOT\ETX\DC2\EOT\156\STX)*\n\
    \\f\n\
    \\EOT\EOT\ENQ\STX\ENQ\DC2\EOT\157\STX\DLE4\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\ENQ\ACK\DC2\EOT\157\STX\DLE%\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\ENQ\SOH\DC2\EOT\157\STX&/\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\ENQ\ETX\DC2\EOT\157\STX23\n\
    \\f\n\
    \\EOT\EOT\ENQ\STX\ACK\DC2\EOT\158\STX\DLE.\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\ACK\ACK\DC2\EOT\158\STX\DLE%\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\ACK\SOH\DC2\EOT\158\STX&)\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\ACK\ETX\DC2\EOT\158\STX,-\n\
    \\f\n\
    \\EOT\EOT\ENQ\STX\a\DC2\EOT\159\STX\DLE8\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\a\ACK\DC2\EOT\159\STX\DLE%\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\a\SOH\DC2\EOT\159\STX&3\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\a\ETX\DC2\EOT\159\STX67\n\
    \\SO\n\
    \\EOT\EOT\ENQ\ETX\NUL\DC2\ACK\162\STX\b\171\STX\t\n\
    \\r\n\
    \\ENQ\EOT\ENQ\ETX\NUL\SOH\DC2\EOT\162\STX\DLE\ETB\n\
    \\DLE\n\
    \\ACK\EOT\ENQ\ETX\NUL\b\NUL\DC2\ACK\163\STX\DLE\166\STX\DC1\n\
    \\SI\n\
    \\a\EOT\ENQ\ETX\NUL\b\NUL\SOH\DC2\EOT\163\STX\SYN-\n\
    \\SO\n\
    \\ACK\EOT\ENQ\ETX\NUL\STX\NUL\DC2\EOT\164\STX\CAN4\n\
    \\SI\n\
    \\a\EOT\ENQ\ETX\NUL\STX\NUL\ENQ\DC2\EOT\164\STX\CAN\RS\n\
    \\SI\n\
    \\a\EOT\ENQ\ETX\NUL\STX\NUL\SOH\DC2\EOT\164\STX\US/\n\
    \\SI\n\
    \\a\EOT\ENQ\ETX\NUL\STX\NUL\ETX\DC2\EOT\164\STX23\n\
    \\SO\n\
    \\ACK\EOT\ENQ\ETX\NUL\STX\SOH\DC2\EOT\165\STX\CAN<\n\
    \\SI\n\
    \\a\EOT\ENQ\ETX\NUL\STX\SOH\ACK\DC2\EOT\165\STX\CAN-\n\
    \\SI\n\
    \\a\EOT\ENQ\ETX\NUL\STX\SOH\SOH\DC2\EOT\165\STX.7\n\
    \\SI\n\
    \\a\EOT\ENQ\ETX\NUL\STX\SOH\ETX\DC2\EOT\165\STX:;\n\
    \\DLE\n\
    \\ACK\EOT\ENQ\ETX\NUL\b\SOH\DC2\ACK\167\STX\DLE\170\STX\DC1\n\
    \\SI\n\
    \\a\EOT\ENQ\ETX\NUL\b\SOH\SOH\DC2\EOT\167\STX\SYN%\n\
    \\SO\n\
    \\ACK\EOT\ENQ\ETX\NUL\STX\STX\DC2\EOT\168\STX\CANJ\n\
    \\SI\n\
    \\a\EOT\ENQ\ETX\NUL\STX\STX\ACK\DC2\EOT\168\STX\CAN<\n\
    \\SI\n\
    \\a\EOT\ENQ\ETX\NUL\STX\STX\SOH\DC2\EOT\168\STX=E\n\
    \\SI\n\
    \\a\EOT\ENQ\ETX\NUL\STX\STX\ETX\DC2\EOT\168\STXHI\n\
    \\SO\n\
    \\ACK\EOT\ENQ\ETX\NUL\STX\ETX\DC2\EOT\169\STX\CAN>\n\
    \\SI\n\
    \\a\EOT\ENQ\ETX\NUL\STX\ETX\ACK\DC2\EOT\169\STX\CAN-\n\
    \\SI\n\
    \\a\EOT\ENQ\ETX\NUL\STX\ETX\SOH\DC2\EOT\169\STX.9\n\
    \\SI\n\
    \\a\EOT\ENQ\ETX\NUL\STX\ETX\ETX\DC2\EOT\169\STX<=\n\
    \\f\n\
    \\STX\EOT\ACK\DC2\ACK\174\STX\NUL\186\STX\SOH\n\
    \\v\n\
    \\ETX\EOT\ACK\SOH\DC2\EOT\174\STX\b\DC1\n\
    \\f\n\
    \\EOT\EOT\ACK\STX\NUL\DC2\EOT\175\STX\b\FS\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\NUL\ACK\DC2\EOT\175\STX\b\SI\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\NUL\SOH\DC2\EOT\175\STX\DLE\ETB\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\NUL\ETX\DC2\EOT\175\STX\SUB\ESC\n\
    \\SO\n\
    \\EOT\EOT\ACK\ETX\NUL\DC2\ACK\177\STX\b\185\STX\t\n\
    \\r\n\
    \\ENQ\EOT\ACK\ETX\NUL\SOH\DC2\EOT\177\STX\DLE\ETB\n\
    \\SO\n\
    \\ACK\EOT\ACK\ETX\NUL\STX\NUL\DC2\EOT\178\STX\DLEJ\n\
    \\SI\n\
    \\a\EOT\ACK\ETX\NUL\STX\NUL\ACK\DC2\EOT\178\STX\DLE3\n\
    \\SI\n\
    \\a\EOT\ACK\ETX\NUL\STX\NUL\SOH\DC2\EOT\178\STX4E\n\
    \\SI\n\
    \\a\EOT\ACK\ETX\NUL\STX\NUL\ETX\DC2\EOT\178\STXHI\n\
    \\DLE\n\
    \\ACK\EOT\ACK\ETX\NUL\b\NUL\DC2\ACK\179\STX\DLE\184\STX\DC1\n\
    \\SI\n\
    \\a\EOT\ACK\ETX\NUL\b\NUL\SOH\DC2\EOT\179\STX\SYN.\n\
    \\SO\n\
    \\ACK\EOT\ACK\ETX\NUL\STX\SOH\DC2\EOT\180\STX\CAN,\n\
    \\SI\n\
    \\a\EOT\ACK\ETX\NUL\STX\SOH\ENQ\DC2\EOT\180\STX\CAN\RS\n\
    \\SI\n\
    \\a\EOT\ACK\ETX\NUL\STX\SOH\SOH\DC2\EOT\180\STX\US'\n\
    \\SI\n\
    \\a\EOT\ACK\ETX\NUL\STX\SOH\ETX\DC2\EOT\180\STX*+\n\
    \\SO\n\
    \\ACK\EOT\ACK\ETX\NUL\STX\STX\DC2\EOT\181\STX\CAN?\n\
    \\SI\n\
    \\a\EOT\ACK\ETX\NUL\STX\STX\ACK\DC2\EOT\181\STX\CAN0\n\
    \\SI\n\
    \\a\EOT\ACK\ETX\NUL\STX\STX\SOH\DC2\EOT\181\STX1:\n\
    \\SI\n\
    \\a\EOT\ACK\ETX\NUL\STX\STX\ETX\DC2\EOT\181\STX=>\n\
    \\SO\n\
    \\ACK\EOT\ACK\ETX\NUL\STX\ETX\DC2\EOT\182\STX\CAN9\n\
    \\SI\n\
    \\a\EOT\ACK\ETX\NUL\STX\ETX\ACK\DC2\EOT\182\STX\CAN0\n\
    \\SI\n\
    \\a\EOT\ACK\ETX\NUL\STX\ETX\SOH\DC2\EOT\182\STX14\n\
    \\SI\n\
    \\a\EOT\ACK\ETX\NUL\STX\ETX\ETX\DC2\EOT\182\STX78\n\
    \\SO\n\
    \\ACK\EOT\ACK\ETX\NUL\STX\EOT\DC2\EOT\183\STX\CANC\n\
    \\SI\n\
    \\a\EOT\ACK\ETX\NUL\STX\EOT\ACK\DC2\EOT\183\STX\CAN0\n\
    \\SI\n\
    \\a\EOT\ACK\ETX\NUL\STX\EOT\SOH\DC2\EOT\183\STX1>\n\
    \\SI\n\
    \\a\EOT\ACK\ETX\NUL\STX\EOT\ETX\DC2\EOT\183\STXAB\n\
    \\f\n\
    \\STX\EOT\a\DC2\ACK\188\STX\NUL\198\STX\SOH\n\
    \\v\n\
    \\ETX\EOT\a\SOH\DC2\EOT\188\STX\b\DC2\n\
    \\SO\n\
    \\EOT\EOT\a\b\NUL\DC2\ACK\189\STX\b\192\STX\t\n\
    \\r\n\
    \\ENQ\EOT\a\b\NUL\SOH\DC2\EOT\189\STX\SO\GS\n\
    \\f\n\
    \\EOT\EOT\a\STX\NUL\DC2\EOT\190\STX\DLE&\n\
    \\r\n\
    \\ENQ\EOT\a\STX\NUL\ACK\DC2\EOT\190\STX\DLE\CAN\n\
    \\r\n\
    \\ENQ\EOT\a\STX\NUL\SOH\DC2\EOT\190\STX\EM!\n\
    \\r\n\
    \\ENQ\EOT\a\STX\NUL\ETX\DC2\EOT\190\STX$%\n\
    \\f\n\
    \\EOT\EOT\a\STX\SOH\DC2\EOT\191\STX\DLE9\n\
    \\r\n\
    \\ENQ\EOT\a\STX\SOH\ACK\DC2\EOT\191\STX\DLE(\n\
    \\r\n\
    \\ENQ\EOT\a\STX\SOH\SOH\DC2\EOT\191\STX)4\n\
    \\r\n\
    \\ENQ\EOT\a\STX\SOH\ETX\DC2\EOT\191\STX78\n\
    \\SO\n\
    \\EOT\EOT\a\ETX\NUL\DC2\ACK\194\STX\b\197\STX\t\n\
    \\r\n\
    \\ENQ\EOT\a\ETX\NUL\SOH\DC2\EOT\194\STX\DLE\CAN\n\
    \\SO\n\
    \\ACK\EOT\a\ETX\NUL\STX\NUL\DC2\EOT\195\STX\DLE+\n\
    \\SI\n\
    \\a\EOT\a\ETX\NUL\STX\NUL\ENQ\DC2\EOT\195\STX\DLE\SYN\n\
    \\SI\n\
    \\a\EOT\a\ETX\NUL\STX\NUL\SOH\DC2\EOT\195\STX\ETB&\n\
    \\SI\n\
    \\a\EOT\a\ETX\NUL\STX\NUL\ETX\DC2\EOT\195\STX)*\n\
    \\SO\n\
    \\ACK\EOT\a\ETX\NUL\STX\SOH\DC2\EOT\196\STX\DLE,\n\
    \\SI\n\
    \\a\EOT\a\ETX\NUL\STX\SOH\ENQ\DC2\EOT\196\STX\DLE\SYN\n\
    \\SI\n\
    \\a\EOT\a\ETX\NUL\STX\SOH\SOH\DC2\EOT\196\STX\ETB'\n\
    \\SI\n\
    \\a\EOT\a\ETX\NUL\STX\SOH\ETX\DC2\EOT\196\STX*+\n\
    \\f\n\
    \\STX\EOT\b\DC2\ACK\200\STX\NUL\212\STX\SOH\n\
    \\v\n\
    \\ETX\EOT\b\SOH\DC2\EOT\200\STX\b\DC4\n\
    \\f\n\
    \\EOT\EOT\b\STX\NUL\DC2\EOT\201\STX\b\FS\n\
    \\r\n\
    \\ENQ\EOT\b\STX\NUL\ACK\DC2\EOT\201\STX\b\SI\n\
    \\r\n\
    \\ENQ\EOT\b\STX\NUL\SOH\DC2\EOT\201\STX\DLE\ETB\n\
    \\r\n\
    \\ENQ\EOT\b\STX\NUL\ETX\DC2\EOT\201\STX\SUB\ESC\n\
    \\SO\n\
    \\EOT\EOT\b\ETX\NUL\DC2\ACK\203\STX\b\211\STX\t\n\
    \\r\n\
    \\ENQ\EOT\b\ETX\NUL\SOH\DC2\EOT\203\STX\DLE\ETB\n\
    \\SO\n\
    \\ACK\EOT\b\ETX\NUL\STX\NUL\DC2\EOT\204\STX\DLEJ\n\
    \\SI\n\
    \\a\EOT\b\ETX\NUL\STX\NUL\ACK\DC2\EOT\204\STX\DLE3\n\
    \\SI\n\
    \\a\EOT\b\ETX\NUL\STX\NUL\SOH\DC2\EOT\204\STX4E\n\
    \\SI\n\
    \\a\EOT\b\ETX\NUL\STX\NUL\ETX\DC2\EOT\204\STXHI\n\
    \\DLE\n\
    \\ACK\EOT\b\ETX\NUL\b\NUL\DC2\ACK\205\STX\DLE\210\STX\DC1\n\
    \\SI\n\
    \\a\EOT\b\ETX\NUL\b\NUL\SOH\DC2\EOT\205\STX\SYN.\n\
    \\SO\n\
    \\ACK\EOT\b\ETX\NUL\STX\SOH\DC2\EOT\206\STX\CAN,\n\
    \\SI\n\
    \\a\EOT\b\ETX\NUL\STX\SOH\ENQ\DC2\EOT\206\STX\CAN\RS\n\
    \\SI\n\
    \\a\EOT\b\ETX\NUL\STX\SOH\SOH\DC2\EOT\206\STX\US'\n\
    \\SI\n\
    \\a\EOT\b\ETX\NUL\STX\SOH\ETX\DC2\EOT\206\STX*+\n\
    \\SO\n\
    \\ACK\EOT\b\ETX\NUL\STX\STX\DC2\EOT\207\STX\CAN?\n\
    \\SI\n\
    \\a\EOT\b\ETX\NUL\STX\STX\ACK\DC2\EOT\207\STX\CAN0\n\
    \\SI\n\
    \\a\EOT\b\ETX\NUL\STX\STX\SOH\DC2\EOT\207\STX1:\n\
    \\SI\n\
    \\a\EOT\b\ETX\NUL\STX\STX\ETX\DC2\EOT\207\STX=>\n\
    \\SO\n\
    \\ACK\EOT\b\ETX\NUL\STX\ETX\DC2\EOT\208\STX\CAN9\n\
    \\SI\n\
    \\a\EOT\b\ETX\NUL\STX\ETX\ACK\DC2\EOT\208\STX\CAN0\n\
    \\SI\n\
    \\a\EOT\b\ETX\NUL\STX\ETX\SOH\DC2\EOT\208\STX14\n\
    \\SI\n\
    \\a\EOT\b\ETX\NUL\STX\ETX\ETX\DC2\EOT\208\STX78\n\
    \\SO\n\
    \\ACK\EOT\b\ETX\NUL\STX\EOT\DC2\EOT\209\STX\CANC\n\
    \\SI\n\
    \\a\EOT\b\ETX\NUL\STX\EOT\ACK\DC2\EOT\209\STX\CAN0\n\
    \\SI\n\
    \\a\EOT\b\ETX\NUL\STX\EOT\SOH\DC2\EOT\209\STX1>\n\
    \\SI\n\
    \\a\EOT\b\ETX\NUL\STX\EOT\ETX\DC2\EOT\209\STXAB\n\
    \\f\n\
    \\STX\EOT\t\DC2\ACK\214\STX\NUL\224\STX\SOH\n\
    \\v\n\
    \\ETX\EOT\t\SOH\DC2\EOT\214\STX\b\NAK\n\
    \\SO\n\
    \\EOT\EOT\t\b\NUL\DC2\ACK\215\STX\b\218\STX\t\n\
    \\r\n\
    \\ENQ\EOT\t\b\NUL\SOH\DC2\EOT\215\STX\SO\GS\n\
    \\f\n\
    \\EOT\EOT\t\STX\NUL\DC2\EOT\216\STX\DLE&\n\
    \\r\n\
    \\ENQ\EOT\t\STX\NUL\ACK\DC2\EOT\216\STX\DLE\CAN\n\
    \\r\n\
    \\ENQ\EOT\t\STX\NUL\SOH\DC2\EOT\216\STX\EM!\n\
    \\r\n\
    \\ENQ\EOT\t\STX\NUL\ETX\DC2\EOT\216\STX$%\n\
    \\f\n\
    \\EOT\EOT\t\STX\SOH\DC2\EOT\217\STX\DLE9\n\
    \\r\n\
    \\ENQ\EOT\t\STX\SOH\ACK\DC2\EOT\217\STX\DLE(\n\
    \\r\n\
    \\ENQ\EOT\t\STX\SOH\SOH\DC2\EOT\217\STX)4\n\
    \\r\n\
    \\ENQ\EOT\t\STX\SOH\ETX\DC2\EOT\217\STX78\n\
    \\SO\n\
    \\EOT\EOT\t\ETX\NUL\DC2\ACK\220\STX\b\223\STX\t\n\
    \\r\n\
    \\ENQ\EOT\t\ETX\NUL\SOH\DC2\EOT\220\STX\DLE\CAN\n\
    \\SO\n\
    \\ACK\EOT\t\ETX\NUL\STX\NUL\DC2\EOT\221\STX\DLE+\n\
    \\SI\n\
    \\a\EOT\t\ETX\NUL\STX\NUL\ENQ\DC2\EOT\221\STX\DLE\SYN\n\
    \\SI\n\
    \\a\EOT\t\ETX\NUL\STX\NUL\SOH\DC2\EOT\221\STX\ETB&\n\
    \\SI\n\
    \\a\EOT\t\ETX\NUL\STX\NUL\ETX\DC2\EOT\221\STX)*\n\
    \\SO\n\
    \\ACK\EOT\t\ETX\NUL\STX\SOH\DC2\EOT\222\STX\DLE,\n\
    \\SI\n\
    \\a\EOT\t\ETX\NUL\STX\SOH\ENQ\DC2\EOT\222\STX\DLE\SYN\n\
    \\SI\n\
    \\a\EOT\t\ETX\NUL\STX\SOH\SOH\DC2\EOT\222\STX\ETB'\n\
    \\SI\n\
    \\a\EOT\t\ETX\NUL\STX\SOH\ETX\DC2\EOT\222\STX*+b\ACKproto3"