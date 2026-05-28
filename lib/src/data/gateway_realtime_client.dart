import 'dart:async';
import 'dart:io';

import 'package:fixnum/fixnum.dart';

import 'generated/ws.pb.dart';
import 'gateway_config.dart';

// ---------------------------------------------------------------------------
// Types exposed to the rest of the app (unchanged signatures)
// ---------------------------------------------------------------------------

class SendMessageAck {
  const SendMessageAck({
    required this.ackSeq,
    required this.clientMessageId,
    required this.code,
    required this.message,
    required this.status,
    required this.messageId,
  });

  final int ackSeq;
  final String clientMessageId;
  final int code;
  final String message;
  final int status;
  final int messageId;
}

sealed class RealtimeEvent {
  const RealtimeEvent();
}

class RealtimeMessageEvent extends RealtimeEvent {
  const RealtimeMessageEvent({
    required this.messageId,
    required this.conversationId,
    required this.messageType,
    required this.content,
    required this.senderId,
    required this.sentAt,
    required this.conversationType,
    required this.clientMessageId,
    required this.isSystem,
    required this.senderDisplayName,
    required this.mentions,
  });

  final int messageId;
  final int conversationId;
  final String messageType;
  final String content;
  final int senderId;
  final int sentAt;
  final String conversationType;
  final String clientMessageId;
  final bool isSystem;
  final String senderDisplayName;
  final List<String> mentions;
}

class RealtimePresenceEvent extends RealtimeEvent {
  const RealtimePresenceEvent({
    required this.userId,
    required this.status,
    required this.updatedAt,
  });

  final int userId;
  final String status;
  final int updatedAt;
}

class RealtimeTypingEvent extends RealtimeEvent {
  const RealtimeTypingEvent({
    required this.userId,
    required this.conversationId,
  });

  final int userId;
  final int conversationId;
}

class RealtimeFriendApplicationEvent extends RealtimeEvent {
  const RealtimeFriendApplicationEvent({
    required this.userId,
    required this.friendId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int userId;
  final int friendId;
  final String status;
  final int createdAt;
  final int updatedAt;
}

class RealtimeReadReceiptEvent extends RealtimeEvent {
  const RealtimeReadReceiptEvent({
    required this.conversationId,
    required this.userId,
    required this.lastReadMessageId,
    required this.updatedAt,
  });

  final int conversationId;
  final int userId;
  final int lastReadMessageId;
  final int updatedAt;
}

class RealtimeReconnectEvent extends RealtimeEvent {
  const RealtimeReconnectEvent({
    required this.reconnectDelayMs,
    required this.gatewayNodeId,
  });

  final int reconnectDelayMs;
  final String gatewayNodeId;
}

class RealtimeTokenExpiredEvent extends RealtimeEvent {
  const RealtimeTokenExpiredEvent({
    required this.expiredAt,
    required this.reason,
  });

  final int expiredAt;
  final String reason;
}

class RealtimeConnectionClosedEvent extends RealtimeEvent {
  const RealtimeConnectionClosedEvent({this.code, this.reason = ''});

  final int? code;
  final String reason;
}

class RealtimeNotificationEvent extends RealtimeEvent {
  const RealtimeNotificationEvent({
    required this.notificationType,
    required this.title,
    required this.body,
    required this.relatedId,
  });

  final String notificationType;
  final String title;
  final String body;
  final int relatedId;
}

// ---------------------------------------------------------------------------
// GatewayRealtimeClient — Protobuf-based WebSocket client
// ---------------------------------------------------------------------------

class GatewayRealtimeClient {
  GatewayRealtimeClient({
    Uri? wsUri,
    this.heartbeatInterval = const Duration(seconds: 25),
  }) : wsUri = wsUri ?? GatewayConfig.current.wsUri;

  final Uri wsUri;
  final Duration heartbeatInterval;
  final StreamController<RealtimeEvent> _eventsController =
      StreamController<RealtimeEvent>.broadcast();

  WebSocket? _socket;
  Timer? _heartbeatTimer;
  Timer? _heartbeatWatchdog;
  int _seq = 0;
  int _lastServerSeq = 0;
  final Map<int, Completer<SendMessageAck>> _pendingMessageAcks = {};

  Stream<RealtimeEvent> get events => _eventsController.stream;

  bool get isConnected => _socket?.readyState == WebSocket.open;

  // ---- Connection -----------------------------------------------------------

  Future<void> connect(String accessToken) async {
    await close();
    final socket = await WebSocket.connect(
      wsUri.toString(),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    _socket = socket;
    socket.listen(
      _handleSocketData,
      onDone: () => _handleSocketClosed(socket.closeCode, socket.closeReason),
      onError: (Object error, StackTrace stackTrace) =>
          _handleSocketClosed(null, '$error'),
      cancelOnError: true,
    );
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (_) => sendHeartbeat());
    _markRemoteActivity();
  }

  Future<void> close() async {
    _heartbeatTimer?.cancel();
    _heartbeatWatchdog?.cancel();
    _heartbeatTimer = null;
    _heartbeatWatchdog = null;
    final socket = _socket;
    _socket = null;
    if (socket != null && socket.readyState == WebSocket.open) {
      await socket.close();
    }
    _completePendingOnDisconnect();
  }

  Future<void> dispose() async {
    await close();
    await _eventsController.close();
  }

  // ---- Sending --------------------------------------------------------------

  void _sendFrame(WsFrame frame) {
    final socket = _requireSocket();
    final bytes = frame.writeToBuffer();
    if (bytes.length > 1024) {
      throw ArgumentError('WebSocket 帧超过 1024 bytes 限制');
    }
    socket.add(bytes);
  }

  WsFrame _newFrame(FrameType type) =>
      WsFrame(type: type, seq: Int64(_nextSeq()));

  Future<SendMessageAck> sendMessage({
    required int conversationId,
    required String messageType,
    required String content,
    required String clientMessageId,
    List<String> mentions = const [],
  }) async {
    _requireSocket();
    final seq = _nextSeq();
    final payload = SendMessagePayload(
      conversationId: Int64(conversationId),
      messageType: messageType,
      content: content,
      clientMsgId: clientMessageId,
      mentions: mentions,
    );
    final frame = WsFrame(
      type: FrameType.FRAME_TYPE_SEND_MESSAGE,
      seq: Int64(seq),
      payload: payload.writeToBuffer(),
      timestamp: Int64(DateTime.now().millisecondsSinceEpoch),
    );
    final completer = Completer<SendMessageAck>();
    _pendingMessageAcks[seq] = completer;
    _sendFrame(frame);
    return completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () {
        _pendingMessageAcks.remove(seq);
        throw TimeoutException('等待 SERVER_ACK 超时');
      },
    );
  }

  Future<SendMessageAck> sendTextMessage({
    required int conversationId,
    required String content,
    required String clientMessageId,
    List<String> mentions = const [],
  }) {
    return sendMessage(
      conversationId: conversationId,
      messageType: 'text',
      content: content,
      clientMessageId: clientMessageId,
      mentions: mentions,
    );
  }

  void sendTyping(int conversationId) {
    if (!isConnected) return;
    final payload = TypingPayload(conversationId: Int64(conversationId));
    _sendFrame(
      _newFrame(FrameType.FRAME_TYPE_TYPING)..payload = payload.writeToBuffer(),
    );
  }

  void sendReadReceipt({
    required int conversationId,
    required int lastMessageId,
  }) {
    if (!isConnected) return;
    final payload = ReadReceiptPayload(
      conversationId: Int64(conversationId),
      lastMsgId: Int64(lastMessageId),
    );
    _sendFrame(
      _newFrame(FrameType.FRAME_TYPE_READ_RECEIPT)
        ..payload = payload.writeToBuffer(),
    );
  }

  void sendHeartbeat() {
    if (!isConnected) return;
    final payload = HeartbeatPayload(lastSeq: Int64(_lastServerSeq));
    _sendFrame(
      _newFrame(FrameType.FRAME_TYPE_HEARTBEAT)
        ..payload = payload.writeToBuffer(),
    );
  }

  // ---- Helpers --------------------------------------------------------------

  WebSocket _requireSocket() {
    final socket = _socket;
    if (socket == null || socket.readyState != WebSocket.open) {
      throw StateError('WebSocket 尚未连接');
    }
    return socket;
  }

  int _nextSeq() => ++_seq;

  void _sendServerAckIfNeeded(int serverSeq) {
    if (serverSeq <= 0 || !isConnected) return;
    final payload = ClientAckPayload(ackSeq: Int64(serverSeq));
    _sendFrame(
      _newFrame(FrameType.FRAME_TYPE_ACK)..payload = payload.writeToBuffer(),
    );
  }

  void _completePendingOnDisconnect() {
    final pending = Map<int, Completer<SendMessageAck>>.from(
      _pendingMessageAcks,
    );
    _pendingMessageAcks.clear();
    for (final completer in pending.values) {
      if (!completer.isCompleted) {
        completer.completeError(StateError('WebSocket 连接已关闭'));
      }
    }
  }

  void _markRemoteActivity() {
    _heartbeatWatchdog?.cancel();
    _heartbeatWatchdog = Timer(const Duration(seconds: 90), () {
      _handleSocketClosed(null, 'heartbeat timeout');
    });
  }

  void _handleSocketClosed(int? code, String? reason) {
    _heartbeatTimer?.cancel();
    _heartbeatWatchdog?.cancel();
    _heartbeatTimer = null;
    _heartbeatWatchdog = null;
    _socket = null;
    _completePendingOnDisconnect();
    if (!_eventsController.isClosed && code != 1000) {
      _eventsController.add(
        RealtimeConnectionClosedEvent(code: code, reason: reason ?? ''),
      );
    }
  }

  // ---- Receiving ------------------------------------------------------------

  void _handleSocketData(dynamic data) {
    final bytes = data is List<int> ? data : (data as dynamic).toList();
    final frame = WsFrame.fromBuffer(bytes);
    _markRemoteActivity();

    final serverSeq = frame.seq.toInt();
    if (serverSeq > 0) _lastServerSeq = serverSeq;

    switch (frame.type) {
      case FrameType.FRAME_TYPE_PUSH_MESSAGE:
        final push = PushMessagePayload.fromBuffer(frame.payload);
        _eventsController.add(
          RealtimeMessageEvent(
            messageId: push.messageId.toInt(),
            conversationId: push.conversationId.toInt(),
            messageType: push.messageType,
            content: push.content,
            senderId: push.senderId.toInt(),
            sentAt: push.sentAt.toInt(),
            conversationType: push.conversationType,
            clientMessageId: push.clientMsgId,
            isSystem: push.isSystem,
            senderDisplayName: push.senderInfo.displayName.isNotEmpty
                ? push.senderInfo.displayName
                : push.senderInfo.name,
            mentions: List<String>.from(push.mentions),
          ),
        );
        _sendServerAckIfNeeded(serverSeq);
        break;

      case FrameType.FRAME_TYPE_PUSH_PRESENCE:
        final push = PushPresencePayload.fromBuffer(frame.payload);
        _eventsController.add(
          RealtimePresenceEvent(
            userId: push.userId.toInt(),
            status: push.status,
            updatedAt: push.updatedAt.toInt(),
          ),
        );
        _sendServerAckIfNeeded(serverSeq);
        break;

      case FrameType.FRAME_TYPE_PUSH_NOTIFICATION:
        final push = PushNotificationPayload.fromBuffer(frame.payload);
        _eventsController.add(
          RealtimeNotificationEvent(
            notificationType: push.notificationType,
            title: push.title,
            body: push.body,
            relatedId: push.relatedId.toInt(),
          ),
        );
        _sendServerAckIfNeeded(serverSeq);
        break;

      case FrameType.FRAME_TYPE_PUSH_TYPING:
        final push = PushTypingPayload.fromBuffer(frame.payload);
        _eventsController.add(
          RealtimeTypingEvent(
            userId: push.userId.toInt(),
            conversationId: push.conversationId.toInt(),
          ),
        );
        _sendServerAckIfNeeded(serverSeq);
        break;

      case FrameType.FRAME_TYPE_RECONNECT:
        final push = ReconnectPayload.fromBuffer(frame.payload);
        _eventsController.add(
          RealtimeReconnectEvent(
            reconnectDelayMs: push.reconnectDelayMs.toInt(),
            gatewayNodeId: push.gatewayNodeId,
          ),
        );
        _sendServerAckIfNeeded(serverSeq);
        break;

      case FrameType.FRAME_TYPE_SERVER_ACK:
        final ack = ServerAckPayload.fromBuffer(frame.payload);
        _pendingMessageAcks
            .remove(ack.ackSeq.toInt())
            ?.complete(
              SendMessageAck(
                ackSeq: ack.ackSeq.toInt(),
                clientMessageId: ack.clientMsgId,
                code: ack.code,
                message: ack.msg,
                status: ack.status.value,
                messageId: ack.messageId.toInt(),
              ),
            );
        break;

      case FrameType.FRAME_TYPE_TOKEN_EXPIRED:
        final push = TokenExpiredPayload.fromBuffer(frame.payload);
        _eventsController.add(
          RealtimeTokenExpiredEvent(
            expiredAt: push.expiredAt.toInt(),
            reason: push.reason,
          ),
        );
        unawaited(close());
        break;

      case FrameType.FRAME_TYPE_PUSH_FRIEND_APPLICATION:
        final push = PushFriendApplicationPayload.fromBuffer(frame.payload);
        _eventsController.add(
          RealtimeFriendApplicationEvent(
            userId: push.userId.toInt(),
            friendId: push.friendId.toInt(),
            status: push.status,
            createdAt: push.createdAt.toInt(),
            updatedAt: push.updatedAt.toInt(),
          ),
        );
        _sendServerAckIfNeeded(serverSeq);
        break;

      case FrameType.FRAME_TYPE_PUSH_READ_RECEIPT:
        final push = PushReadReceiptPayload.fromBuffer(frame.payload);
        _eventsController.add(
          RealtimeReadReceiptEvent(
            conversationId: push.conversationId.toInt(),
            userId: push.userId.toInt(),
            lastReadMessageId: push.lastReadMessageId.toInt(),
            updatedAt: push.updatedAt.toInt(),
          ),
        );
        _sendServerAckIfNeeded(serverSeq);
        break;

      default:
        break;
    }
  }
}
