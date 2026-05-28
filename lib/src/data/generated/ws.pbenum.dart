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

import 'package:protobuf/protobuf.dart' as $pb;

class FrameType extends $pb.ProtobufEnum {
  static const FrameType FRAME_TYPE_UNSPECIFIED =
      FrameType._(0, _omitEnumNames ? '' : 'FRAME_TYPE_UNSPECIFIED');

  /// ---- 客户端 → 网关 ----
  static const FrameType FRAME_TYPE_SEND_MESSAGE =
      FrameType._(1, _omitEnumNames ? '' : 'FRAME_TYPE_SEND_MESSAGE');
  static const FrameType FRAME_TYPE_HEARTBEAT =
      FrameType._(2, _omitEnumNames ? '' : 'FRAME_TYPE_HEARTBEAT');
  static const FrameType FRAME_TYPE_TYPING =
      FrameType._(3, _omitEnumNames ? '' : 'FRAME_TYPE_TYPING');
  static const FrameType FRAME_TYPE_READ_RECEIPT =
      FrameType._(4, _omitEnumNames ? '' : 'FRAME_TYPE_READ_RECEIPT');
  static const FrameType FRAME_TYPE_ACK =
      FrameType._(5, _omitEnumNames ? '' : 'FRAME_TYPE_ACK');

  /// ---- 网关 → 客户端 ----
  static const FrameType FRAME_TYPE_PUSH_MESSAGE =
      FrameType._(101, _omitEnumNames ? '' : 'FRAME_TYPE_PUSH_MESSAGE');
  static const FrameType FRAME_TYPE_PUSH_PRESENCE =
      FrameType._(102, _omitEnumNames ? '' : 'FRAME_TYPE_PUSH_PRESENCE');
  static const FrameType FRAME_TYPE_PUSH_NOTIFICATION =
      FrameType._(103, _omitEnumNames ? '' : 'FRAME_TYPE_PUSH_NOTIFICATION');
  static const FrameType FRAME_TYPE_PUSH_TYPING =
      FrameType._(104, _omitEnumNames ? '' : 'FRAME_TYPE_PUSH_TYPING');
  static const FrameType FRAME_TYPE_RECONNECT =
      FrameType._(105, _omitEnumNames ? '' : 'FRAME_TYPE_RECONNECT');
  static const FrameType FRAME_TYPE_SERVER_ACK =
      FrameType._(106, _omitEnumNames ? '' : 'FRAME_TYPE_SERVER_ACK');
  static const FrameType FRAME_TYPE_TOKEN_EXPIRED =
      FrameType._(107, _omitEnumNames ? '' : 'FRAME_TYPE_TOKEN_EXPIRED');
  static const FrameType FRAME_TYPE_PUSH_FRIEND_APPLICATION = FrameType._(
      108, _omitEnumNames ? '' : 'FRAME_TYPE_PUSH_FRIEND_APPLICATION');
  static const FrameType FRAME_TYPE_PUSH_READ_RECEIPT =
      FrameType._(109, _omitEnumNames ? '' : 'FRAME_TYPE_PUSH_READ_RECEIPT');

  static const $core.List<FrameType> values = <FrameType>[
    FRAME_TYPE_UNSPECIFIED,
    FRAME_TYPE_SEND_MESSAGE,
    FRAME_TYPE_HEARTBEAT,
    FRAME_TYPE_TYPING,
    FRAME_TYPE_READ_RECEIPT,
    FRAME_TYPE_ACK,
    FRAME_TYPE_PUSH_MESSAGE,
    FRAME_TYPE_PUSH_PRESENCE,
    FRAME_TYPE_PUSH_NOTIFICATION,
    FRAME_TYPE_PUSH_TYPING,
    FRAME_TYPE_RECONNECT,
    FRAME_TYPE_SERVER_ACK,
    FRAME_TYPE_TOKEN_EXPIRED,
    FRAME_TYPE_PUSH_FRIEND_APPLICATION,
    FRAME_TYPE_PUSH_READ_RECEIPT,
  ];

  static final $core.Map<$core.int, FrameType> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static FrameType? valueOf($core.int value) => _byValue[value];

  const FrameType._(super.value, super.name);
}

class AckStatus extends $pb.ProtobufEnum {
  static const AckStatus ACK_STATUS_UNSPECIFIED =
      AckStatus._(0, _omitEnumNames ? '' : 'ACK_STATUS_UNSPECIFIED');
  static const AckStatus ACK_STATUS_ACCEPTED =
      AckStatus._(1, _omitEnumNames ? '' : 'ACK_STATUS_ACCEPTED');
  static const AckStatus ACK_STATUS_REJECTED =
      AckStatus._(2, _omitEnumNames ? '' : 'ACK_STATUS_REJECTED');
  static const AckStatus ACK_STATUS_RETRYABLE =
      AckStatus._(3, _omitEnumNames ? '' : 'ACK_STATUS_RETRYABLE');

  static const $core.List<AckStatus> values = <AckStatus>[
    ACK_STATUS_UNSPECIFIED,
    ACK_STATUS_ACCEPTED,
    ACK_STATUS_REJECTED,
    ACK_STATUS_RETRYABLE,
  ];

  static final $core.List<AckStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static AckStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AckStatus._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
