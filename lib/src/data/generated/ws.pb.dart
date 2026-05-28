// This is a generated file - do not edit.
//
// Generated from ws.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'ws.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'ws.pbenum.dart';

class WsFrame extends $pb.GeneratedMessage {
  factory WsFrame({
    FrameType? type,
    $fixnum.Int64? seq,
    $core.List<$core.int>? payload,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (seq != null) result.seq = seq;
    if (payload != null) result.payload = payload;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  WsFrame._();

  factory WsFrame.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WsFrame.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WsFrame',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'ws'),
      createEmptyInstance: create)
    ..aE<FrameType>(1, _omitFieldNames ? '' : 'type',
        enumValues: FrameType.values)
    ..aInt64(2, _omitFieldNames ? '' : 'seq')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..aInt64(4, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WsFrame clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WsFrame copyWith(void Function(WsFrame) updates) =>
      super.copyWith((message) => updates(message as WsFrame)) as WsFrame;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WsFrame create() => WsFrame._();
  @$core.override
  WsFrame createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WsFrame getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WsFrame>(create);
  static WsFrame? _defaultInstance;

  @$pb.TagNumber(1)
  FrameType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(FrameType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get seq => $_getI64(1);
  @$pb.TagNumber(2)
  set seq($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSeq() => $_has(1);
  @$pb.TagNumber(2)
  void clearSeq() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get payload => $_getN(2);
  @$pb.TagNumber(3)
  set payload($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPayload() => $_has(2);
  @$pb.TagNumber(3)
  void clearPayload() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);
}

/// SendMessagePayload — 客户端发送聊天消息
class SendMessagePayload extends $pb.GeneratedMessage {
  factory SendMessagePayload({
    $fixnum.Int64? conversationId,
    $core.String? messageType,
    $core.String? content,
    $core.String? clientMsgId,
    $core.Iterable<$core.String>? mentions,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (messageType != null) result.messageType = messageType;
    if (content != null) result.content = content;
    if (clientMsgId != null) result.clientMsgId = clientMsgId;
    if (mentions != null) result.mentions.addAll(mentions);
    return result;
  }

  SendMessagePayload._();

  factory SendMessagePayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendMessagePayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendMessagePayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'ws'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'messageType')
    ..aOS(3, _omitFieldNames ? '' : 'content')
    ..aOS(4, _omitFieldNames ? '' : 'clientMsgId')
    ..pPS(5, _omitFieldNames ? '' : 'mentions')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessagePayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessagePayload copyWith(void Function(SendMessagePayload) updates) =>
      super.copyWith((message) => updates(message as SendMessagePayload))
          as SendMessagePayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendMessagePayload create() => SendMessagePayload._();
  @$core.override
  SendMessagePayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendMessagePayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendMessagePayload>(create);
  static SendMessagePayload? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get conversationId => $_getI64(0);
  @$pb.TagNumber(1)
  set conversationId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get messageType => $_getSZ(1);
  @$pb.TagNumber(2)
  set messageType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessageType() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessageType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get content => $_getSZ(2);
  @$pb.TagNumber(3)
  set content($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasContent() => $_has(2);
  @$pb.TagNumber(3)
  void clearContent() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get clientMsgId => $_getSZ(3);
  @$pb.TagNumber(4)
  set clientMsgId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasClientMsgId() => $_has(3);
  @$pb.TagNumber(4)
  void clearClientMsgId() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get mentions => $_getList(4);
}

/// HeartbeatPayload — 心跳保活
class HeartbeatPayload extends $pb.GeneratedMessage {
  factory HeartbeatPayload({
    $fixnum.Int64? lastSeq,
  }) {
    final result = create();
    if (lastSeq != null) result.lastSeq = lastSeq;
    return result;
  }

  HeartbeatPayload._();

  factory HeartbeatPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HeartbeatPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HeartbeatPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'ws'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'lastSeq')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HeartbeatPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HeartbeatPayload copyWith(void Function(HeartbeatPayload) updates) =>
      super.copyWith((message) => updates(message as HeartbeatPayload))
          as HeartbeatPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HeartbeatPayload create() => HeartbeatPayload._();
  @$core.override
  HeartbeatPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HeartbeatPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HeartbeatPayload>(create);
  static HeartbeatPayload? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get lastSeq => $_getI64(0);
  @$pb.TagNumber(1)
  set lastSeq($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLastSeq() => $_has(0);
  @$pb.TagNumber(1)
  void clearLastSeq() => $_clearField(1);
}

/// TypingPayload — 正在输入通知
class TypingPayload extends $pb.GeneratedMessage {
  factory TypingPayload({
    $fixnum.Int64? conversationId,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    return result;
  }

  TypingPayload._();

  factory TypingPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TypingPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TypingPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'ws'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'conversationId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TypingPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TypingPayload copyWith(void Function(TypingPayload) updates) =>
      super.copyWith((message) => updates(message as TypingPayload))
          as TypingPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TypingPayload create() => TypingPayload._();
  @$core.override
  TypingPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TypingPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TypingPayload>(create);
  static TypingPayload? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get conversationId => $_getI64(0);
  @$pb.TagNumber(1)
  set conversationId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);
}

/// ReadReceiptPayload — 已读回执
class ReadReceiptPayload extends $pb.GeneratedMessage {
  factory ReadReceiptPayload({
    $fixnum.Int64? conversationId,
    $fixnum.Int64? lastMsgId,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (lastMsgId != null) result.lastMsgId = lastMsgId;
    return result;
  }

  ReadReceiptPayload._();

  factory ReadReceiptPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReadReceiptPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReadReceiptPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'ws'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'conversationId')
    ..aInt64(2, _omitFieldNames ? '' : 'lastMsgId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReadReceiptPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReadReceiptPayload copyWith(void Function(ReadReceiptPayload) updates) =>
      super.copyWith((message) => updates(message as ReadReceiptPayload))
          as ReadReceiptPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReadReceiptPayload create() => ReadReceiptPayload._();
  @$core.override
  ReadReceiptPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReadReceiptPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReadReceiptPayload>(create);
  static ReadReceiptPayload? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get conversationId => $_getI64(0);
  @$pb.TagNumber(1)
  set conversationId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get lastMsgId => $_getI64(1);
  @$pb.TagNumber(2)
  set lastMsgId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLastMsgId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastMsgId() => $_clearField(2);
}

/// ClientAckPayload — 客户端确认收到服务端推送
class ClientAckPayload extends $pb.GeneratedMessage {
  factory ClientAckPayload({
    $fixnum.Int64? ackSeq,
  }) {
    final result = create();
    if (ackSeq != null) result.ackSeq = ackSeq;
    return result;
  }

  ClientAckPayload._();

  factory ClientAckPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClientAckPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientAckPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'ws'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'ackSeq')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientAckPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientAckPayload copyWith(void Function(ClientAckPayload) updates) =>
      super.copyWith((message) => updates(message as ClientAckPayload))
          as ClientAckPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientAckPayload create() => ClientAckPayload._();
  @$core.override
  ClientAckPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClientAckPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientAckPayload>(create);
  static ClientAckPayload? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get ackSeq => $_getI64(0);
  @$pb.TagNumber(1)
  set ackSeq($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAckSeq() => $_has(0);
  @$pb.TagNumber(1)
  void clearAckSeq() => $_clearField(1);
}

class SenderInfo extends $pb.GeneratedMessage {
  factory SenderInfo({
    $core.String? name,
    $core.String? email,
    $core.String? displayName,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (email != null) result.email = email;
    if (displayName != null) result.displayName = displayName;
    return result;
  }

  SenderInfo._();

  factory SenderInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SenderInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SenderInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'ws'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'email')
    ..aOS(3, _omitFieldNames ? '' : 'displayName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SenderInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SenderInfo copyWith(void Function(SenderInfo) updates) =>
      super.copyWith((message) => updates(message as SenderInfo)) as SenderInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SenderInfo create() => SenderInfo._();
  @$core.override
  SenderInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SenderInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SenderInfo>(create);
  static SenderInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get email => $_getSZ(1);
  @$pb.TagNumber(2)
  set email($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEmail() => $_has(1);
  @$pb.TagNumber(2)
  void clearEmail() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get displayName => $_getSZ(2);
  @$pb.TagNumber(3)
  set displayName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDisplayName() => $_has(2);
  @$pb.TagNumber(3)
  void clearDisplayName() => $_clearField(3);
}

/// PushMessagePayload — 推送聊天消息
class PushMessagePayload extends $pb.GeneratedMessage {
  factory PushMessagePayload({
    $fixnum.Int64? messageId,
    $fixnum.Int64? conversationId,
    $core.String? messageType,
    $core.String? content,
    $fixnum.Int64? senderId,
    $fixnum.Int64? sentAt,
    $core.String? conversationType,
    $core.String? clientMsgId,
    $core.bool? isSystem,
    SenderInfo? senderInfo,
    $core.Iterable<$core.String>? mentions,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (conversationId != null) result.conversationId = conversationId;
    if (messageType != null) result.messageType = messageType;
    if (content != null) result.content = content;
    if (senderId != null) result.senderId = senderId;
    if (sentAt != null) result.sentAt = sentAt;
    if (conversationType != null) result.conversationType = conversationType;
    if (clientMsgId != null) result.clientMsgId = clientMsgId;
    if (isSystem != null) result.isSystem = isSystem;
    if (senderInfo != null) result.senderInfo = senderInfo;
    if (mentions != null) result.mentions.addAll(mentions);
    return result;
  }

  PushMessagePayload._();

  factory PushMessagePayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushMessagePayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushMessagePayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'ws'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'messageId')
    ..aInt64(2, _omitFieldNames ? '' : 'conversationId')
    ..aOS(3, _omitFieldNames ? '' : 'messageType')
    ..aOS(4, _omitFieldNames ? '' : 'content')
    ..aInt64(5, _omitFieldNames ? '' : 'senderId')
    ..aInt64(6, _omitFieldNames ? '' : 'sentAt')
    ..aOS(7, _omitFieldNames ? '' : 'conversationType')
    ..aOS(8, _omitFieldNames ? '' : 'clientMsgId')
    ..aOB(9, _omitFieldNames ? '' : 'isSystem')
    ..aOM<SenderInfo>(10, _omitFieldNames ? '' : 'senderInfo',
        subBuilder: SenderInfo.create)
    ..pPS(11, _omitFieldNames ? '' : 'mentions')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushMessagePayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushMessagePayload copyWith(void Function(PushMessagePayload) updates) =>
      super.copyWith((message) => updates(message as PushMessagePayload))
          as PushMessagePayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushMessagePayload create() => PushMessagePayload._();
  @$core.override
  PushMessagePayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushMessagePayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushMessagePayload>(create);
  static PushMessagePayload? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get messageId => $_getI64(0);
  @$pb.TagNumber(1)
  set messageId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get conversationId => $_getI64(1);
  @$pb.TagNumber(2)
  set conversationId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConversationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConversationId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get messageType => $_getSZ(2);
  @$pb.TagNumber(3)
  set messageType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMessageType() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessageType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get content => $_getSZ(3);
  @$pb.TagNumber(4)
  set content($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasContent() => $_has(3);
  @$pb.TagNumber(4)
  void clearContent() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get senderId => $_getI64(4);
  @$pb.TagNumber(5)
  set senderId($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSenderId() => $_has(4);
  @$pb.TagNumber(5)
  void clearSenderId() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get sentAt => $_getI64(5);
  @$pb.TagNumber(6)
  set sentAt($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSentAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearSentAt() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get conversationType => $_getSZ(6);
  @$pb.TagNumber(7)
  set conversationType($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasConversationType() => $_has(6);
  @$pb.TagNumber(7)
  void clearConversationType() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get clientMsgId => $_getSZ(7);
  @$pb.TagNumber(8)
  set clientMsgId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasClientMsgId() => $_has(7);
  @$pb.TagNumber(8)
  void clearClientMsgId() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get isSystem => $_getBF(8);
  @$pb.TagNumber(9)
  set isSystem($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasIsSystem() => $_has(8);
  @$pb.TagNumber(9)
  void clearIsSystem() => $_clearField(9);

  @$pb.TagNumber(10)
  SenderInfo get senderInfo => $_getN(9);
  @$pb.TagNumber(10)
  set senderInfo(SenderInfo value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasSenderInfo() => $_has(9);
  @$pb.TagNumber(10)
  void clearSenderInfo() => $_clearField(10);
  @$pb.TagNumber(10)
  SenderInfo ensureSenderInfo() => $_ensure(9);

  @$pb.TagNumber(11)
  $pb.PbList<$core.String> get mentions => $_getList(10);
}

/// PushPresencePayload — 推送在线状态变更
class PushPresencePayload extends $pb.GeneratedMessage {
  factory PushPresencePayload({
    $fixnum.Int64? userId,
    $core.String? status,
    $fixnum.Int64? updatedAt,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (status != null) result.status = status;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  PushPresencePayload._();

  factory PushPresencePayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushPresencePayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushPresencePayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'ws'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'status')
    ..aInt64(3, _omitFieldNames ? '' : 'updatedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushPresencePayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushPresencePayload copyWith(void Function(PushPresencePayload) updates) =>
      super.copyWith((message) => updates(message as PushPresencePayload))
          as PushPresencePayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushPresencePayload create() => PushPresencePayload._();
  @$core.override
  PushPresencePayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushPresencePayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushPresencePayload>(create);
  static PushPresencePayload? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get status => $_getSZ(1);
  @$pb.TagNumber(2)
  set status($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get updatedAt => $_getI64(2);
  @$pb.TagNumber(3)
  set updatedAt($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUpdatedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearUpdatedAt() => $_clearField(3);
}

/// PushNotificationPayload — 推送系统通知
class PushNotificationPayload extends $pb.GeneratedMessage {
  factory PushNotificationPayload({
    $core.String? notificationType,
    $core.String? title,
    $core.String? body,
    $fixnum.Int64? relatedId,
  }) {
    final result = create();
    if (notificationType != null) result.notificationType = notificationType;
    if (title != null) result.title = title;
    if (body != null) result.body = body;
    if (relatedId != null) result.relatedId = relatedId;
    return result;
  }

  PushNotificationPayload._();

  factory PushNotificationPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushNotificationPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushNotificationPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'ws'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'notificationType')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'body')
    ..aInt64(4, _omitFieldNames ? '' : 'relatedId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushNotificationPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushNotificationPayload copyWith(
          void Function(PushNotificationPayload) updates) =>
      super.copyWith((message) => updates(message as PushNotificationPayload))
          as PushNotificationPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushNotificationPayload create() => PushNotificationPayload._();
  @$core.override
  PushNotificationPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushNotificationPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushNotificationPayload>(create);
  static PushNotificationPayload? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get notificationType => $_getSZ(0);
  @$pb.TagNumber(1)
  set notificationType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNotificationType() => $_has(0);
  @$pb.TagNumber(1)
  void clearNotificationType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get body => $_getSZ(2);
  @$pb.TagNumber(3)
  set body($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBody() => $_has(2);
  @$pb.TagNumber(3)
  void clearBody() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get relatedId => $_getI64(3);
  @$pb.TagNumber(4)
  set relatedId($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRelatedId() => $_has(3);
  @$pb.TagNumber(4)
  void clearRelatedId() => $_clearField(4);
}

/// PushFriendApplicationPayload - friend application push
class PushFriendApplicationPayload extends $pb.GeneratedMessage {
  factory PushFriendApplicationPayload({
    $fixnum.Int64? userId,
    $fixnum.Int64? friendId,
    $core.String? status,
    $fixnum.Int64? createdAt,
    $fixnum.Int64? updatedAt,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (friendId != null) result.friendId = friendId;
    if (status != null) result.status = status;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  PushFriendApplicationPayload._();

  factory PushFriendApplicationPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushFriendApplicationPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushFriendApplicationPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'ws'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aInt64(2, _omitFieldNames ? '' : 'friendId')
    ..aOS(3, _omitFieldNames ? '' : 'status')
    ..aInt64(4, _omitFieldNames ? '' : 'createdAt')
    ..aInt64(5, _omitFieldNames ? '' : 'updatedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushFriendApplicationPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushFriendApplicationPayload copyWith(
          void Function(PushFriendApplicationPayload) updates) =>
      super.copyWith(
              (message) => updates(message as PushFriendApplicationPayload))
          as PushFriendApplicationPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushFriendApplicationPayload create() =>
      PushFriendApplicationPayload._();
  @$core.override
  PushFriendApplicationPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushFriendApplicationPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushFriendApplicationPayload>(create);
  static PushFriendApplicationPayload? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get friendId => $_getI64(1);
  @$pb.TagNumber(2)
  set friendId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFriendId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFriendId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get status => $_getSZ(2);
  @$pb.TagNumber(3)
  set status($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get createdAt => $_getI64(3);
  @$pb.TagNumber(4)
  set createdAt($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCreatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreatedAt() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get updatedAt => $_getI64(4);
  @$pb.TagNumber(5)
  set updatedAt($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUpdatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearUpdatedAt() => $_clearField(5);
}

/// PushTypingPayload — 推送输入状态
class PushTypingPayload extends $pb.GeneratedMessage {
  factory PushTypingPayload({
    $fixnum.Int64? userId,
    $fixnum.Int64? conversationId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (conversationId != null) result.conversationId = conversationId;
    return result;
  }

  PushTypingPayload._();

  factory PushTypingPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushTypingPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushTypingPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'ws'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aInt64(2, _omitFieldNames ? '' : 'conversationId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushTypingPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushTypingPayload copyWith(void Function(PushTypingPayload) updates) =>
      super.copyWith((message) => updates(message as PushTypingPayload))
          as PushTypingPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushTypingPayload create() => PushTypingPayload._();
  @$core.override
  PushTypingPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushTypingPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushTypingPayload>(create);
  static PushTypingPayload? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get conversationId => $_getI64(1);
  @$pb.TagNumber(2)
  set conversationId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConversationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConversationId() => $_clearField(2);
}

/// PushReadReceiptPayload — 推送已读回执更新（会话内某成员推进了已读游标）
class PushReadReceiptPayload extends $pb.GeneratedMessage {
  factory PushReadReceiptPayload({
    $fixnum.Int64? conversationId,
    $fixnum.Int64? userId,
    $fixnum.Int64? lastReadMessageId,
    $fixnum.Int64? updatedAt,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (userId != null) result.userId = userId;
    if (lastReadMessageId != null) result.lastReadMessageId = lastReadMessageId;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  PushReadReceiptPayload._();

  factory PushReadReceiptPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushReadReceiptPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushReadReceiptPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'ws'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'conversationId')
    ..aInt64(2, _omitFieldNames ? '' : 'userId')
    ..aInt64(3, _omitFieldNames ? '' : 'lastReadMessageId')
    ..aInt64(4, _omitFieldNames ? '' : 'updatedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushReadReceiptPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushReadReceiptPayload copyWith(
          void Function(PushReadReceiptPayload) updates) =>
      super.copyWith((message) => updates(message as PushReadReceiptPayload))
          as PushReadReceiptPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushReadReceiptPayload create() => PushReadReceiptPayload._();
  @$core.override
  PushReadReceiptPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushReadReceiptPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushReadReceiptPayload>(create);
  static PushReadReceiptPayload? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get conversationId => $_getI64(0);
  @$pb.TagNumber(1)
  set conversationId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get userId => $_getI64(1);
  @$pb.TagNumber(2)
  set userId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get lastReadMessageId => $_getI64(2);
  @$pb.TagNumber(3)
  set lastReadMessageId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLastReadMessageId() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastReadMessageId() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get updatedAt => $_getI64(3);
  @$pb.TagNumber(4)
  set updatedAt($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUpdatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearUpdatedAt() => $_clearField(4);
}

/// ReconnectPayload — 网关要求客户端重连（drain 窗口）
class ReconnectPayload extends $pb.GeneratedMessage {
  factory ReconnectPayload({
    $fixnum.Int64? reconnectDelayMs,
    $core.String? gatewayNodeId,
  }) {
    final result = create();
    if (reconnectDelayMs != null) result.reconnectDelayMs = reconnectDelayMs;
    if (gatewayNodeId != null) result.gatewayNodeId = gatewayNodeId;
    return result;
  }

  ReconnectPayload._();

  factory ReconnectPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReconnectPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReconnectPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'ws'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'reconnectDelayMs')
    ..aOS(2, _omitFieldNames ? '' : 'gatewayNodeId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReconnectPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReconnectPayload copyWith(void Function(ReconnectPayload) updates) =>
      super.copyWith((message) => updates(message as ReconnectPayload))
          as ReconnectPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReconnectPayload create() => ReconnectPayload._();
  @$core.override
  ReconnectPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReconnectPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReconnectPayload>(create);
  static ReconnectPayload? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get reconnectDelayMs => $_getI64(0);
  @$pb.TagNumber(1)
  set reconnectDelayMs($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasReconnectDelayMs() => $_has(0);
  @$pb.TagNumber(1)
  void clearReconnectDelayMs() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get gatewayNodeId => $_getSZ(1);
  @$pb.TagNumber(2)
  set gatewayNodeId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGatewayNodeId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGatewayNodeId() => $_clearField(2);
}

/// TokenExpiredPayload — 网关通知客户端 Token 已过期
class TokenExpiredPayload extends $pb.GeneratedMessage {
  factory TokenExpiredPayload({
    $fixnum.Int64? expiredAt,
    $core.String? reason,
  }) {
    final result = create();
    if (expiredAt != null) result.expiredAt = expiredAt;
    if (reason != null) result.reason = reason;
    return result;
  }

  TokenExpiredPayload._();

  factory TokenExpiredPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TokenExpiredPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TokenExpiredPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'ws'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'expiredAt')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TokenExpiredPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TokenExpiredPayload copyWith(void Function(TokenExpiredPayload) updates) =>
      super.copyWith((message) => updates(message as TokenExpiredPayload))
          as TokenExpiredPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TokenExpiredPayload create() => TokenExpiredPayload._();
  @$core.override
  TokenExpiredPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TokenExpiredPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TokenExpiredPayload>(create);
  static TokenExpiredPayload? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get expiredAt => $_getI64(0);
  @$pb.TagNumber(1)
  set expiredAt($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasExpiredAt() => $_has(0);
  @$pb.TagNumber(1)
  void clearExpiredAt() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

/// ServerAckPayload — 服务端确认收到客户端消息
class ServerAckPayload extends $pb.GeneratedMessage {
  factory ServerAckPayload({
    $fixnum.Int64? ackSeq,
    $core.String? clientMsgId,
    $core.int? code,
    $core.String? msg,
    AckStatus? status,
    $fixnum.Int64? messageId,
  }) {
    final result = create();
    if (ackSeq != null) result.ackSeq = ackSeq;
    if (clientMsgId != null) result.clientMsgId = clientMsgId;
    if (code != null) result.code = code;
    if (msg != null) result.msg = msg;
    if (status != null) result.status = status;
    if (messageId != null) result.messageId = messageId;
    return result;
  }

  ServerAckPayload._();

  factory ServerAckPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ServerAckPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ServerAckPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'ws'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'ackSeq')
    ..aOS(2, _omitFieldNames ? '' : 'clientMsgId')
    ..aI(3, _omitFieldNames ? '' : 'code')
    ..aOS(4, _omitFieldNames ? '' : 'msg')
    ..aE<AckStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: AckStatus.values)
    ..aInt64(6, _omitFieldNames ? '' : 'messageId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerAckPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerAckPayload copyWith(void Function(ServerAckPayload) updates) =>
      super.copyWith((message) => updates(message as ServerAckPayload))
          as ServerAckPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ServerAckPayload create() => ServerAckPayload._();
  @$core.override
  ServerAckPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ServerAckPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ServerAckPayload>(create);
  static ServerAckPayload? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get ackSeq => $_getI64(0);
  @$pb.TagNumber(1)
  set ackSeq($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAckSeq() => $_has(0);
  @$pb.TagNumber(1)
  void clearAckSeq() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get clientMsgId => $_getSZ(1);
  @$pb.TagNumber(2)
  set clientMsgId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasClientMsgId() => $_has(1);
  @$pb.TagNumber(2)
  void clearClientMsgId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get code => $_getIZ(2);
  @$pb.TagNumber(3)
  set code($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCode() => $_has(2);
  @$pb.TagNumber(3)
  void clearCode() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get msg => $_getSZ(3);
  @$pb.TagNumber(4)
  set msg($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMsg() => $_has(3);
  @$pb.TagNumber(4)
  void clearMsg() => $_clearField(4);

  @$pb.TagNumber(5)
  AckStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(AckStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get messageId => $_getI64(5);
  @$pb.TagNumber(6)
  set messageId($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMessageId() => $_has(5);
  @$pb.TagNumber(6)
  void clearMessageId() => $_clearField(6);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
