import 'dart:typed_data';

import 'package:aim_desktop/src/data/generated/ws.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('WsFrame 编解码往返', () {
    final payload = SendMessagePayload(
      conversationId: Int64(123),
      messageType: 'text',
      content: 'Hello World',
      clientMsgId: 'd1-test',
      mentions: ['456'],
    );

    final frame = WsFrame(
      type: FrameType.FRAME_TYPE_SEND_MESSAGE,
      seq: Int64(1),
      payload: payload.writeToBuffer(),
      timestamp: Int64(1700000000000),
    );

    // Encode
    final bytes = frame.writeToBuffer();

    // Decode
    final decoded = WsFrame.fromBuffer(bytes);
    expect(decoded.type, FrameType.FRAME_TYPE_SEND_MESSAGE);
    expect(decoded.seq, Int64(1));
    expect(decoded.timestamp, Int64(1700000000000));

    // Decode inner payload
    final inner = SendMessagePayload.fromBuffer(decoded.payload);
    expect(inner.conversationId, Int64(123));
    expect(inner.messageType, 'text');
    expect(inner.content, 'Hello World');
    expect(inner.clientMsgId, 'd1-test');
    expect(inner.mentions, ['456']);
  });

  test('ServerAckPayload 解码', () {
    final ack = ServerAckPayload(
      ackSeq: Int64(5),
      clientMsgId: 'd1-client',
      code: 0,
      msg: 'ok',
      status: AckStatus.ACK_STATUS_ACCEPTED,
      messageId: Int64(10001),
    );

    final frame = WsFrame(
      type: FrameType.FRAME_TYPE_SERVER_ACK,
      seq: Int64(100),
      payload: ack.writeToBuffer(),
    );

    final decoded = WsFrame.fromBuffer(frame.writeToBuffer());
    final decodedAck = ServerAckPayload.fromBuffer(decoded.payload);

    expect(decodedAck.ackSeq, Int64(5));
    expect(decodedAck.code, 0);
    expect(decodedAck.status, AckStatus.ACK_STATUS_ACCEPTED);
    expect(decodedAck.messageId, Int64(10001));
  });

  test('所有帧类型枚举值正确', () {
    expect(FrameType.FRAME_TYPE_SEND_MESSAGE.value, 1);
    expect(FrameType.FRAME_TYPE_HEARTBEAT.value, 2);
    expect(FrameType.FRAME_TYPE_PUSH_MESSAGE.value, 101);
    expect(FrameType.FRAME_TYPE_SERVER_ACK.value, 106);
    expect(FrameType.FRAME_TYPE_TOKEN_EXPIRED.value, 107);
    expect(FrameType.FRAME_TYPE_PUSH_READ_RECEIPT.value, 109);
    expect(AckStatus.ACK_STATUS_RETRYABLE.value, 3);
  });

  test('未知字段兼容（向前兼容）', () {
    // Construct a frame with extra unknown bytes tacked on
    final payload = HeartbeatPayload(lastSeq: Int64(42));
    final frame = WsFrame(
      type: FrameType.FRAME_TYPE_HEARTBEAT,
      seq: Int64(1),
      payload: payload.writeToBuffer(),
    );
    final bytes = frame.writeToBuffer();
    // Append an unknown field (tag 999, varint 0) - should be ignored
    final extended = Uint8List(bytes.length + 3);
    extended.setAll(0, bytes);
    extended[bytes.length] = 0xF8; // tag: field 999, wire type 0
    extended[bytes.length + 1] = 0x7E; // varint continuation
    extended[bytes.length + 2] = 0x00; // value 0

    final decoded = WsFrame.fromBuffer(extended);
    expect(decoded.type, FrameType.FRAME_TYPE_HEARTBEAT);
    expect(decoded.seq, Int64(1));

    final inner = HeartbeatPayload.fromBuffer(decoded.payload);
    expect(inner.lastSeq, Int64(42));
  });
}
