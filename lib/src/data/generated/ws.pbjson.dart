// This is a generated file - do not edit.
//
// Generated from ws.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use frameTypeDescriptor instead')
const FrameType$json = {
  '1': 'FrameType',
  '2': [
    {'1': 'FRAME_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'FRAME_TYPE_SEND_MESSAGE', '2': 1},
    {'1': 'FRAME_TYPE_HEARTBEAT', '2': 2},
    {'1': 'FRAME_TYPE_TYPING', '2': 3},
    {'1': 'FRAME_TYPE_READ_RECEIPT', '2': 4},
    {'1': 'FRAME_TYPE_ACK', '2': 5},
    {'1': 'FRAME_TYPE_PUSH_MESSAGE', '2': 101},
    {'1': 'FRAME_TYPE_PUSH_PRESENCE', '2': 102},
    {'1': 'FRAME_TYPE_PUSH_NOTIFICATION', '2': 103},
    {'1': 'FRAME_TYPE_PUSH_TYPING', '2': 104},
    {'1': 'FRAME_TYPE_RECONNECT', '2': 105},
    {'1': 'FRAME_TYPE_SERVER_ACK', '2': 106},
    {'1': 'FRAME_TYPE_TOKEN_EXPIRED', '2': 107},
    {'1': 'FRAME_TYPE_PUSH_FRIEND_APPLICATION', '2': 108},
    {'1': 'FRAME_TYPE_PUSH_READ_RECEIPT', '2': 109},
  ],
};

/// Descriptor for `FrameType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List frameTypeDescriptor = $convert.base64Decode(
    'CglGcmFtZVR5cGUSGgoWRlJBTUVfVFlQRV9VTlNQRUNJRklFRBAAEhsKF0ZSQU1FX1RZUEVfU0'
    'VORF9NRVNTQUdFEAESGAoURlJBTUVfVFlQRV9IRUFSVEJFQVQQAhIVChFGUkFNRV9UWVBFX1RZ'
    'UElORxADEhsKF0ZSQU1FX1RZUEVfUkVBRF9SRUNFSVBUEAQSEgoORlJBTUVfVFlQRV9BQ0sQBR'
    'IbChdGUkFNRV9UWVBFX1BVU0hfTUVTU0FHRRBlEhwKGEZSQU1FX1RZUEVfUFVTSF9QUkVTRU5D'
    'RRBmEiAKHEZSQU1FX1RZUEVfUFVTSF9OT1RJRklDQVRJT04QZxIaChZGUkFNRV9UWVBFX1BVU0'
    'hfVFlQSU5HEGgSGAoURlJBTUVfVFlQRV9SRUNPTk5FQ1QQaRIZChVGUkFNRV9UWVBFX1NFUlZF'
    'Ul9BQ0sQahIcChhGUkFNRV9UWVBFX1RPS0VOX0VYUElSRUQQaxImCiJGUkFNRV9UWVBFX1BVU0'
    'hfRlJJRU5EX0FQUExJQ0FUSU9OEGwSIAocRlJBTUVfVFlQRV9QVVNIX1JFQURfUkVDRUlQVBBt');

@$core.Deprecated('Use ackStatusDescriptor instead')
const AckStatus$json = {
  '1': 'AckStatus',
  '2': [
    {'1': 'ACK_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'ACK_STATUS_ACCEPTED', '2': 1},
    {'1': 'ACK_STATUS_REJECTED', '2': 2},
    {'1': 'ACK_STATUS_RETRYABLE', '2': 3},
  ],
};

/// Descriptor for `AckStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List ackStatusDescriptor = $convert.base64Decode(
    'CglBY2tTdGF0dXMSGgoWQUNLX1NUQVRVU19VTlNQRUNJRklFRBAAEhcKE0FDS19TVEFUVVNfQU'
    'NDRVBURUQQARIXChNBQ0tfU1RBVFVTX1JFSkVDVEVEEAISGAoUQUNLX1NUQVRVU19SRVRSWUFC'
    'TEUQAw==');

@$core.Deprecated('Use wsFrameDescriptor instead')
const WsFrame$json = {
  '1': 'WsFrame',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.ws.FrameType', '10': 'type'},
    {'1': 'seq', '3': 2, '4': 1, '5': 3, '10': 'seq'},
    {'1': 'payload', '3': 3, '4': 1, '5': 12, '10': 'payload'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `WsFrame`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wsFrameDescriptor = $convert.base64Decode(
    'CgdXc0ZyYW1lEiEKBHR5cGUYASABKA4yDS53cy5GcmFtZVR5cGVSBHR5cGUSEAoDc2VxGAIgAS'
    'gDUgNzZXESGAoHcGF5bG9hZBgDIAEoDFIHcGF5bG9hZBIcCgl0aW1lc3RhbXAYBCABKANSCXRp'
    'bWVzdGFtcA==');

@$core.Deprecated('Use sendMessagePayloadDescriptor instead')
const SendMessagePayload$json = {
  '1': 'SendMessagePayload',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 3, '10': 'conversationId'},
    {'1': 'message_type', '3': 2, '4': 1, '5': 9, '10': 'messageType'},
    {'1': 'content', '3': 3, '4': 1, '5': 9, '10': 'content'},
    {'1': 'client_msg_id', '3': 4, '4': 1, '5': 9, '10': 'clientMsgId'},
    {'1': 'mentions', '3': 5, '4': 3, '5': 9, '10': 'mentions'},
  ],
};

/// Descriptor for `SendMessagePayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendMessagePayloadDescriptor = $convert.base64Decode(
    'ChJTZW5kTWVzc2FnZVBheWxvYWQSJwoPY29udmVyc2F0aW9uX2lkGAEgASgDUg5jb252ZXJzYX'
    'Rpb25JZBIhCgxtZXNzYWdlX3R5cGUYAiABKAlSC21lc3NhZ2VUeXBlEhgKB2NvbnRlbnQYAyAB'
    'KAlSB2NvbnRlbnQSIgoNY2xpZW50X21zZ19pZBgEIAEoCVILY2xpZW50TXNnSWQSGgoIbWVudG'
    'lvbnMYBSADKAlSCG1lbnRpb25z');

@$core.Deprecated('Use heartbeatPayloadDescriptor instead')
const HeartbeatPayload$json = {
  '1': 'HeartbeatPayload',
  '2': [
    {'1': 'last_seq', '3': 1, '4': 1, '5': 3, '10': 'lastSeq'},
  ],
};

/// Descriptor for `HeartbeatPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List heartbeatPayloadDescriptor = $convert.base64Decode(
    'ChBIZWFydGJlYXRQYXlsb2FkEhkKCGxhc3Rfc2VxGAEgASgDUgdsYXN0U2Vx');

@$core.Deprecated('Use typingPayloadDescriptor instead')
const TypingPayload$json = {
  '1': 'TypingPayload',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 3, '10': 'conversationId'},
  ],
};

/// Descriptor for `TypingPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List typingPayloadDescriptor = $convert.base64Decode(
    'Cg1UeXBpbmdQYXlsb2FkEicKD2NvbnZlcnNhdGlvbl9pZBgBIAEoA1IOY29udmVyc2F0aW9uSW'
    'Q=');

@$core.Deprecated('Use readReceiptPayloadDescriptor instead')
const ReadReceiptPayload$json = {
  '1': 'ReadReceiptPayload',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 3, '10': 'conversationId'},
    {'1': 'last_msg_id', '3': 2, '4': 1, '5': 3, '10': 'lastMsgId'},
  ],
};

/// Descriptor for `ReadReceiptPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List readReceiptPayloadDescriptor = $convert.base64Decode(
    'ChJSZWFkUmVjZWlwdFBheWxvYWQSJwoPY29udmVyc2F0aW9uX2lkGAEgASgDUg5jb252ZXJzYX'
    'Rpb25JZBIeCgtsYXN0X21zZ19pZBgCIAEoA1IJbGFzdE1zZ0lk');

@$core.Deprecated('Use clientAckPayloadDescriptor instead')
const ClientAckPayload$json = {
  '1': 'ClientAckPayload',
  '2': [
    {'1': 'ack_seq', '3': 1, '4': 1, '5': 3, '10': 'ackSeq'},
  ],
};

/// Descriptor for `ClientAckPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientAckPayloadDescriptor = $convert.base64Decode(
    'ChBDbGllbnRBY2tQYXlsb2FkEhcKB2Fja19zZXEYASABKANSBmFja1NlcQ==');

@$core.Deprecated('Use senderInfoDescriptor instead')
const SenderInfo$json = {
  '1': 'SenderInfo',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'email', '3': 2, '4': 1, '5': 9, '10': 'email'},
    {'1': 'display_name', '3': 3, '4': 1, '5': 9, '10': 'displayName'},
  ],
};

/// Descriptor for `SenderInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List senderInfoDescriptor = $convert.base64Decode(
    'CgpTZW5kZXJJbmZvEhIKBG5hbWUYASABKAlSBG5hbWUSFAoFZW1haWwYAiABKAlSBWVtYWlsEi'
    'EKDGRpc3BsYXlfbmFtZRgDIAEoCVILZGlzcGxheU5hbWU=');

@$core.Deprecated('Use pushMessagePayloadDescriptor instead')
const PushMessagePayload$json = {
  '1': 'PushMessagePayload',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 3, '10': 'messageId'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 3, '10': 'conversationId'},
    {'1': 'message_type', '3': 3, '4': 1, '5': 9, '10': 'messageType'},
    {'1': 'content', '3': 4, '4': 1, '5': 9, '10': 'content'},
    {'1': 'sender_id', '3': 5, '4': 1, '5': 3, '10': 'senderId'},
    {'1': 'sent_at', '3': 6, '4': 1, '5': 3, '10': 'sentAt'},
    {
      '1': 'conversation_type',
      '3': 7,
      '4': 1,
      '5': 9,
      '10': 'conversationType'
    },
    {'1': 'client_msg_id', '3': 8, '4': 1, '5': 9, '10': 'clientMsgId'},
    {'1': 'is_system', '3': 9, '4': 1, '5': 8, '10': 'isSystem'},
    {
      '1': 'sender_info',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.ws.SenderInfo',
      '10': 'senderInfo'
    },
    {'1': 'mentions', '3': 11, '4': 3, '5': 9, '10': 'mentions'},
  ],
};

/// Descriptor for `PushMessagePayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushMessagePayloadDescriptor = $convert.base64Decode(
    'ChJQdXNoTWVzc2FnZVBheWxvYWQSHQoKbWVzc2FnZV9pZBgBIAEoA1IJbWVzc2FnZUlkEicKD2'
    'NvbnZlcnNhdGlvbl9pZBgCIAEoA1IOY29udmVyc2F0aW9uSWQSIQoMbWVzc2FnZV90eXBlGAMg'
    'ASgJUgttZXNzYWdlVHlwZRIYCgdjb250ZW50GAQgASgJUgdjb250ZW50EhsKCXNlbmRlcl9pZB'
    'gFIAEoA1IIc2VuZGVySWQSFwoHc2VudF9hdBgGIAEoA1IGc2VudEF0EisKEWNvbnZlcnNhdGlv'
    'bl90eXBlGAcgASgJUhBjb252ZXJzYXRpb25UeXBlEiIKDWNsaWVudF9tc2dfaWQYCCABKAlSC2'
    'NsaWVudE1zZ0lkEhsKCWlzX3N5c3RlbRgJIAEoCFIIaXNTeXN0ZW0SLwoLc2VuZGVyX2luZm8Y'
    'CiABKAsyDi53cy5TZW5kZXJJbmZvUgpzZW5kZXJJbmZvEhoKCG1lbnRpb25zGAsgAygJUghtZW'
    '50aW9ucw==');

@$core.Deprecated('Use pushPresencePayloadDescriptor instead')
const PushPresencePayload$json = {
  '1': 'PushPresencePayload',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'status', '3': 2, '4': 1, '5': 9, '10': 'status'},
    {'1': 'updated_at', '3': 3, '4': 1, '5': 3, '10': 'updatedAt'},
  ],
};

/// Descriptor for `PushPresencePayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushPresencePayloadDescriptor = $convert.base64Decode(
    'ChNQdXNoUHJlc2VuY2VQYXlsb2FkEhcKB3VzZXJfaWQYASABKANSBnVzZXJJZBIWCgZzdGF0dX'
    'MYAiABKAlSBnN0YXR1cxIdCgp1cGRhdGVkX2F0GAMgASgDUgl1cGRhdGVkQXQ=');

@$core.Deprecated('Use pushNotificationPayloadDescriptor instead')
const PushNotificationPayload$json = {
  '1': 'PushNotificationPayload',
  '2': [
    {
      '1': 'notification_type',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'notificationType'
    },
    {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    {'1': 'body', '3': 3, '4': 1, '5': 9, '10': 'body'},
    {'1': 'related_id', '3': 4, '4': 1, '5': 3, '10': 'relatedId'},
  ],
};

/// Descriptor for `PushNotificationPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushNotificationPayloadDescriptor = $convert.base64Decode(
    'ChdQdXNoTm90aWZpY2F0aW9uUGF5bG9hZBIrChFub3RpZmljYXRpb25fdHlwZRgBIAEoCVIQbm'
    '90aWZpY2F0aW9uVHlwZRIUCgV0aXRsZRgCIAEoCVIFdGl0bGUSEgoEYm9keRgDIAEoCVIEYm9k'
    'eRIdCgpyZWxhdGVkX2lkGAQgASgDUglyZWxhdGVkSWQ=');

@$core.Deprecated('Use pushFriendApplicationPayloadDescriptor instead')
const PushFriendApplicationPayload$json = {
  '1': 'PushFriendApplicationPayload',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'friend_id', '3': 2, '4': 1, '5': 3, '10': 'friendId'},
    {'1': 'status', '3': 3, '4': 1, '5': 9, '10': 'status'},
    {'1': 'created_at', '3': 4, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'updated_at', '3': 5, '4': 1, '5': 3, '10': 'updatedAt'},
  ],
};

/// Descriptor for `PushFriendApplicationPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushFriendApplicationPayloadDescriptor = $convert.base64Decode(
    'ChxQdXNoRnJpZW5kQXBwbGljYXRpb25QYXlsb2FkEhcKB3VzZXJfaWQYASABKANSBnVzZXJJZB'
    'IbCglmcmllbmRfaWQYAiABKANSCGZyaWVuZElkEhYKBnN0YXR1cxgDIAEoCVIGc3RhdHVzEh0K'
    'CmNyZWF0ZWRfYXQYBCABKANSCWNyZWF0ZWRBdBIdCgp1cGRhdGVkX2F0GAUgASgDUgl1cGRhdG'
    'VkQXQ=');

@$core.Deprecated('Use pushTypingPayloadDescriptor instead')
const PushTypingPayload$json = {
  '1': 'PushTypingPayload',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 3, '10': 'conversationId'},
  ],
};

/// Descriptor for `PushTypingPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushTypingPayloadDescriptor = $convert.base64Decode(
    'ChFQdXNoVHlwaW5nUGF5bG9hZBIXCgd1c2VyX2lkGAEgASgDUgZ1c2VySWQSJwoPY29udmVyc2'
    'F0aW9uX2lkGAIgASgDUg5jb252ZXJzYXRpb25JZA==');

@$core.Deprecated('Use pushReadReceiptPayloadDescriptor instead')
const PushReadReceiptPayload$json = {
  '1': 'PushReadReceiptPayload',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 3, '10': 'conversationId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 3, '10': 'userId'},
    {
      '1': 'last_read_message_id',
      '3': 3,
      '4': 1,
      '5': 3,
      '10': 'lastReadMessageId'
    },
    {'1': 'updated_at', '3': 4, '4': 1, '5': 3, '10': 'updatedAt'},
  ],
};

/// Descriptor for `PushReadReceiptPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushReadReceiptPayloadDescriptor = $convert.base64Decode(
    'ChZQdXNoUmVhZFJlY2VpcHRQYXlsb2FkEicKD2NvbnZlcnNhdGlvbl9pZBgBIAEoA1IOY29udm'
    'Vyc2F0aW9uSWQSFwoHdXNlcl9pZBgCIAEoA1IGdXNlcklkEi8KFGxhc3RfcmVhZF9tZXNzYWdl'
    'X2lkGAMgASgDUhFsYXN0UmVhZE1lc3NhZ2VJZBIdCgp1cGRhdGVkX2F0GAQgASgDUgl1cGRhdG'
    'VkQXQ=');

@$core.Deprecated('Use reconnectPayloadDescriptor instead')
const ReconnectPayload$json = {
  '1': 'ReconnectPayload',
  '2': [
    {
      '1': 'reconnect_delay_ms',
      '3': 1,
      '4': 1,
      '5': 3,
      '10': 'reconnectDelayMs'
    },
    {'1': 'gateway_node_id', '3': 2, '4': 1, '5': 9, '10': 'gatewayNodeId'},
  ],
};

/// Descriptor for `ReconnectPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reconnectPayloadDescriptor = $convert.base64Decode(
    'ChBSZWNvbm5lY3RQYXlsb2FkEiwKEnJlY29ubmVjdF9kZWxheV9tcxgBIAEoA1IQcmVjb25uZW'
    'N0RGVsYXlNcxImCg9nYXRld2F5X25vZGVfaWQYAiABKAlSDWdhdGV3YXlOb2RlSWQ=');

@$core.Deprecated('Use tokenExpiredPayloadDescriptor instead')
const TokenExpiredPayload$json = {
  '1': 'TokenExpiredPayload',
  '2': [
    {'1': 'expired_at', '3': 1, '4': 1, '5': 3, '10': 'expiredAt'},
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `TokenExpiredPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tokenExpiredPayloadDescriptor = $convert.base64Decode(
    'ChNUb2tlbkV4cGlyZWRQYXlsb2FkEh0KCmV4cGlyZWRfYXQYASABKANSCWV4cGlyZWRBdBIWCg'
    'ZyZWFzb24YAiABKAlSBnJlYXNvbg==');

@$core.Deprecated('Use serverAckPayloadDescriptor instead')
const ServerAckPayload$json = {
  '1': 'ServerAckPayload',
  '2': [
    {'1': 'ack_seq', '3': 1, '4': 1, '5': 3, '10': 'ackSeq'},
    {'1': 'client_msg_id', '3': 2, '4': 1, '5': 9, '10': 'clientMsgId'},
    {'1': 'code', '3': 3, '4': 1, '5': 5, '10': 'code'},
    {'1': 'msg', '3': 4, '4': 1, '5': 9, '10': 'msg'},
    {
      '1': 'status',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.ws.AckStatus',
      '10': 'status'
    },
    {'1': 'message_id', '3': 6, '4': 1, '5': 3, '10': 'messageId'},
  ],
};

/// Descriptor for `ServerAckPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serverAckPayloadDescriptor = $convert.base64Decode(
    'ChBTZXJ2ZXJBY2tQYXlsb2FkEhcKB2Fja19zZXEYASABKANSBmFja1NlcRIiCg1jbGllbnRfbX'
    'NnX2lkGAIgASgJUgtjbGllbnRNc2dJZBISCgRjb2RlGAMgASgFUgRjb2RlEhAKA21zZxgEIAEo'
    'CVIDbXNnEiUKBnN0YXR1cxgFIAEoDjINLndzLkFja1N0YXR1c1IGc3RhdHVzEh0KCm1lc3NhZ2'
    'VfaWQYBiABKANSCW1lc3NhZ2VJZA==');
