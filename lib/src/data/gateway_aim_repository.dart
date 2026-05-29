import 'dart:async';

import 'package:drift/drift.dart' show OrderingMode, OrderingTerm, Value;
import 'package:flutter/foundation.dart';

import 'aim_repository.dart';
import 'database.dart';
import 'gateway_api_client.dart';
import 'gateway_realtime_client.dart';
import 'ws_reconnect.dart';
import '../domain/models.dart';

class GatewayAimRepository implements AimRepository {
  GatewayAimRepository({
    GatewayApiClient? apiClient,
    GatewayRealtimeClient? realtimeClient,
    AimLocalDatabase? database,
  }) : _realtimeClient = realtimeClient ?? GatewayRealtimeClient(),
       _db = database {
    _apiClient =
        apiClient ?? GatewayApiClient(onTokenExpired: _refreshAccessToken);
  }

  late final GatewayApiClient _apiClient;
  final GatewayRealtimeClient _realtimeClient;
  final WsReconnectManager _reconnectManager = WsReconnectManager();
  final AimLocalDatabase? _db;
  AuthSession? _session;

  bool get isRealtimeConnected => _realtimeClient.isConnected;

  Future<String?> _refreshAccessToken() async {
    final current = _session;
    if (current == null) {
      debugPrint('[AuthInterceptor] _refreshAccessToken: _session is null, '
          'skipping refresh');
      return null;
    }
    debugPrint('[AuthInterceptor] _refreshAccessToken: refreshing token...');
    try {
      final refreshed = await _apiClient.refresh(current.refreshToken);
      final next = AuthSession(
        user: current.user,
        accessToken: refreshed.accessToken,
        refreshToken: refreshed.refreshToken,
        expiresAt: refreshed.expiresAt,
      );
      _session = next;
      debugPrint('[AuthInterceptor] _refreshAccessToken: refresh succeeded');
      return next.accessToken;
    } catch (e) {
      debugPrint('[AuthInterceptor] _refreshAccessToken: refresh failed: $e');
      rethrow;
    }
  }

  /// Trigger reconnection with exponential backoff, then sync presence and
  /// incremental history.
  Future<void> reconnectAndSync(String accessToken) async {
    _reconnectManager.resetAttempts();
    final delay = _reconnectManager.nextBackoff();
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    await _realtimeClient.connect(accessToken);
    _reconnectManager.startHeartbeat();
    // After reconnect: refresh presence snapshot (manual §8.4)
    try {
      await _apiClient.getFriendsPresence();
    } catch (_) {
      // Non-critical, presence will update via WS
    }
  }

  @override
  Stream<RealtimeEvent> get realtimeEvents => _realtimeClient.events;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
    required String deviceId,
  }) async {
    final session = await _apiClient.login(
      email: email,
      password: password,
      deviceId: deviceId,
    );
    _session = session;
    await _realtimeClient.connect(session.accessToken);
    return session;
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String username,
    required String deviceId,
  }) async {
    await _apiClient.register(
      email: email,
      password: password,
      username: username,
      deviceId: deviceId,
    );
    return login(email: email, password: password, deviceId: deviceId);
  }

  @override
  Future<AuthSession> refreshSession(AuthSession session) async {
    final refreshed = await _apiClient.refresh(session.refreshToken);

    // refresh 接口不返回用户详情，若 session.user 缺少昵称/邮箱，则从服务端补全。
    UserProfile user = session.user;
    if (user.id > 0 && (user.nickname.isEmpty || user.email.isEmpty)) {
      try {
        user = await _apiClient.getUserById(user.id);
      } catch (_) {
        // 获取失败不影响刷新流程，仅保留不完整信息。
      }
    }

    final nextSession = AuthSession(
      user: user,
      accessToken: refreshed.accessToken,
      refreshToken: refreshed.refreshToken,
      expiresAt: refreshed.expiresAt,
    );
    _session = nextSession;
    await _realtimeClient.connect(nextSession.accessToken);
    return nextSession;
  }

  @override
  Future<void> logout(String accessToken) async {
    await _realtimeClient.close();
    if (_session != null) {
      await _apiClient.logout();
    }
    _session = null;
  }

  /// 从本地 Drift 缓存加载引导数据，用于快速首屏展示。
  /// 返回 null 表示本地无缓存数据。
  Future<AimBootstrapData?> loadLocalBootstrapData() async {
    final db = _db;
    if (db == null) return null;
    try {
      final localConvs = await db.select(db.localConversations).get();
      if (localConvs.isEmpty) return null;
      final conversations = localConvs.map((c) {
        return Conversation(
          id: c.conversationId,
          type: c.conversationType == 'group'
              ? ConversationType.group
              : ConversationType.direct,
          name: c.name,
          avatarText: c.avatarText,
          memberIds: const JsonIntListConverter().fromSql(c.memberIdsJson),
          createdAt: c.createdAt,
          updatedAt: c.updatedAt,
          lastMessagePreview: c.lastMessagePreview,
          unreadCount: c.unreadCount,
          isPinned: c.isPinned,
          isActive: c.isActive,
          ownerId: c.ownerId,
        );
      }).toList();

      final histories = <int, List<ChatMessage>>{};
      for (final c in conversations) {
        final localMsgs =
            await (db.select(db.localMessages)
                  ..where((tbl) => tbl.conversationId.equals(c.id))
                  ..orderBy([
                    (t) => OrderingTerm(
                      expression: t.createdAt,
                      mode: OrderingMode.asc,
                    ),
                  ]))
                .get();
        if (localMsgs.isNotEmpty) {
          histories[c.id] = localMsgs.map((m) {
            return ChatMessage(
              id: m.messageId,
              conversationId: m.conversationId,
              senderId: m.senderId,
              senderName: m.senderDisplayName.isNotEmpty
                  ? m.senderDisplayName
                  : m.senderName,
              type: _messageTypeFromString(m.messageType),
              content: m.content,
              createdAt: m.createdAt,
              clientMessageId: m.clientMsgId ?? '',
              isSystem: m.isSystem,
              mentions: const JsonStringListConverter().fromSql(m.mentionsJson),
              readBy: const JsonIntListConverter().fromSql(m.readByJson),
              status: _messageStatusFromLocal(m.localStatus),
            );
          }).toList();
        }
      }

      return AimBootstrapData(
        conversations: conversations,
        messagesByConversation: histories,
        friends: const [],
        friendRequests: const [],
        attachments: const [],
        orders: const [],
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AimBootstrapData> loadBootstrapData(UserProfile user) async {
    final conversations = await _apiClient.listConversations();

    // 并行拉取所有会话的历史记录，而非逐个串行等待
    final historyFutures = conversations.map((c) async {
      try {
        final history = await _apiClient.getHistory(c.id, limit: 50);
        // Persist read states from server (manual §9)
        await _writeReadStates(c.id, history.readStates);
        return MapEntry(c.id, history.messages);
      } catch (_) {
        return MapEntry(c.id, <ChatMessage>[]);
      }
    });
    final historyEntries = await Future.wait(historyFutures);
    final histories = <int, List<ChatMessage>>{};
    for (final entry in historyEntries) {
      histories[entry.key] = entry.value;
    }

    final friends = await _apiClient
        .listFriends(user)
        .catchError((_) => <Friendship>[]);
    final requests = await _apiClient
        .listFriendApplications(user)
        .catchError((_) => <Friendship>[]);
    final presences = await _apiClient.getFriendsPresence().catchError(
      (_) => <PresenceItem>[],
    );
    final presenceMap = <int, String>{
      for (final p in presences) p.userId: p.status,
    };
    final friendsWithPresence = friends.map((f) {
      final status = presenceMap[f.user.id];
      if (status == null) return f;
      final presenceStatus = status == 'online'
          ? PresenceStatus.online
          : PresenceStatus.offline;
      return Friendship(
        id: f.id,
        user: f.user.copyWith(status: presenceStatus),
        status: f.status,
        createdAt: f.createdAt,
        updatedAt: f.updatedAt,
        incoming: f.incoming,
      );
    }).toList();

    // Persist to local database (manual §7)
    await _writeBootstrapToDb(conversations, histories);

    return AimBootstrapData(
      conversations: conversations,
      messagesByConversation: histories,
      friends: friendsWithPresence,
      friendRequests: requests,
      attachments: const [],
      orders: const [],
    );
  }

  /// Write conversations and messages to local Drift cache.
  Future<void> _writeBootstrapToDb(
    List<Conversation> conversations,
    Map<int, List<ChatMessage>> messagesByConversation,
  ) async {
    final db = _db;
    if (db == null) return;
    try {
      for (final c in conversations) {
        await db
            .into(db.localConversations)
            .insertOnConflictUpdate(
              LocalConversationsCompanion(
                conversationId: Value(c.id),
                conversationType: Value(
                  c.type == ConversationType.group ? 'group' : 'direct',
                ),
                name: Value(c.name),
                avatarText: Value(c.avatarText),
                memberIdsJson: Value(
                  const JsonIntListConverter().toSql(c.memberIds),
                ),
                createdAt: Value(c.createdAt),
                updatedAt: Value(c.updatedAt),
                lastMessagePreview: Value(c.lastMessagePreview),
                unreadCount: Value(c.unreadCount),
                isPinned: Value(c.isPinned),
                isActive: Value(c.isActive),
                ownerId: Value(c.ownerId),
              ),
            );
      }
      for (final entry in messagesByConversation.entries) {
        for (final msg in entry.value) {
          if (msg.id <= 0) continue;
          await _upsertMessage(msg);
          // 对附件消息也持久化到 local_attachments 表
          _maybeUpsertAttachment(msg);
        }
      }
    } catch (_) {
      // Best-effort
    }
  }

  /// Upsert a single message into the local DB (dedup by message_id).
  /// Upsert a single message into the local DB (dedup by message_id).
  Future<void> _upsertMessage(ChatMessage msg) async {
    final db = _db;
    if (db == null || msg.id <= 0) return;
    try {
      await db
          .into(db.localMessages)
          .insertOnConflictUpdate(
            LocalMessagesCompanion(
              messageId: Value(msg.id),
              clientMsgId: Value(
                msg.clientMessageId.isNotEmpty ? msg.clientMessageId : null,
              ),
              conversationId: Value(msg.conversationId),
              senderId: Value(msg.senderId),
              senderName: Value(msg.senderName),
              senderDisplayName: Value(msg.senderName),
              senderEmail: const Value(''),
              messageType: Value(_messageTypeStr(msg.type)),
              content: Value(msg.content),
              createdAt: Value(msg.createdAt),
              isSystem: Value(msg.isSystem),
              mentionsJson: Value(
                const JsonStringListConverter().toSql(msg.mentions),
              ),
              readByJson: Value(const JsonIntListConverter().toSql(msg.readBy)),
              localStatus: Value(_messageStatusToLocal(msg.status)),
              createdLocally: const Value(false),
            ),
          );
    } catch (_) {
      // Best-effort
    }
  }

  /// 如果消息是附件消息，尝试提取附件元信息写入 local_attachments 表。
  void _maybeUpsertAttachment(ChatMessage msg) {
    final db = _db;
    if (db == null) return;
    final payload = AttachmentMessagePayload.tryParse(msg.content);
    if (payload == null || payload.fileId.isEmpty) return;
    try {
      db.into(db.localAttachments).insertOnConflictUpdate(
        LocalAttachmentsCompanion(
          attachmentId: Value(payload.fileId),
          conversationId: Value(payload.conversationId > 0
              ? payload.conversationId
              : msg.conversationId),
          kind: Value(payload.kind),
          name: Value(payload.name),
          mime: Value(payload.mime),
          sizeBytes: Value(payload.sizeBytes),
          sizeLabel: Value(payload.sizeLabel),
          status: Value(payload.status),
          parseStatus: Value(payload.parseStatus),
          downloadUrl: Value(payload.downloadUrl),
          thumbnailUrl: Value(payload.thumbnailFileId.isNotEmpty
              ? payload.thumbnailFileId
              : payload.thumbnailUrl),
          width: Value(payload.width),
          height: Value(payload.height),
          durationMs: Value(payload.durationMs),
          createdAt: Value(msg.createdAt),
        ),
      );
    } catch (_) {
      // Best-effort
    }
  }

  /// Check if a message with the given server ID already exists in local DB.
  Future<bool> hasMessage(int messageId) async {
    final db = _db;
    if (db == null) return false;
    try {
      final count =
          await (db.select(db.localMessages)
                ..where((tbl) => tbl.messageId.equals(messageId)))
              .get()
              .then((rows) => rows.length);
      return count > 0;
    } catch (_) {
      return false;
    }
  }

  /// Write read states from history response to local DB.
  Future<void> _writeReadStates(
    int conversationId,
    List<ReadStateItem> readStates,
  ) async {
    final db = _db;
    if (db == null) return;
    try {
      for (final rs in readStates) {
        await db
            .into(db.localReadStates)
            .insertOnConflictUpdate(
              LocalReadStatesCompanion(
                conversationId: Value(conversationId),
                userId: Value(rs.userId),
                lastReadMessageId: Value(rs.lastReadMessageId),
                updatedAt: Value(rs.updatedAt),
              ),
            );
      }
    } catch (_) {
      // Best-effort
    }
  }

  String _messageTypeStr(MessageType type) {
    return switch (type) {
      MessageType.image => 'image',
      MessageType.file => 'file',
      MessageType.system => 'system',
      MessageType.text => 'text',
    };
  }

  MessageType _messageTypeFromString(String value) {
    return switch (value) {
      'image' => MessageType.image,
      'file' || 'audio' || 'video' => MessageType.file,
      'system' => MessageType.system,
      _ => MessageType.text,
    };
  }

  MessageStatus _messageStatusFromLocal(int value) {
    return switch (value) {
      1 => MessageStatus.sending,
      2 => MessageStatus.sent,
      3 => MessageStatus.failed,
      _ => MessageStatus.received,
    };
  }

  int _messageStatusToLocal(MessageStatus status) {
    return switch (status) {
      MessageStatus.sending => 1,
      MessageStatus.sent => 2,
      MessageStatus.failed => 3,
      MessageStatus.received => 0,
    };
  }

  @override
  Future<SendResult> sendTextMessage({
    required int conversationId,
    required UserProfile sender,
    required String content,
    required String clientMessageId,
    required DateTime createdAt,
  }) async {
    final ack = await _realtimeClient.sendTextMessage(
      conversationId: conversationId,
      content: content,
      clientMessageId: clientMessageId,
    );
    final msg = ChatMessage(
      id: ack.messageId == 0 ? createdAt.millisecondsSinceEpoch : ack.messageId,
      conversationId: conversationId,
      senderId: sender.id,
      senderName: sender.nickname,
      type: MessageType.text,
      content: content,
      createdAt: createdAt,
      clientMessageId: clientMessageId,
      status: ack.code == 0 && ack.status != 2
          ? MessageStatus.sent
          : MessageStatus.failed,
      readBy: [sender.id],
    );
    await _upsertMessage(msg);
    return SendResult(
      message: msg,
      ackStatus: ack.status,
      ackCode: ack.code,
      ackText: ack.message,
    );
  }

  @override
  Future<SendResult> sendAttachmentMessage({
    required int conversationId,
    required UserProfile sender,
    required AttachmentMessagePayload payload,
    required String displayContent,
    required String clientMessageId,
    required DateTime createdAt,
  }) async {
    final messageType = switch (payload.kind) {
      'image' || 'video' || 'audio' => payload.kind,
      _ => payload.isImage ? 'image' : 'file',
    };
    final ack = await _realtimeClient.sendMessage(
      conversationId: conversationId,
      messageType: messageType,
      content: payload.toJsonString(includeLocalPreview: false),
      clientMessageId: clientMessageId,
    );
    final msg = ChatMessage(
      id: ack.messageId == 0 ? createdAt.millisecondsSinceEpoch : ack.messageId,
      conversationId: conversationId,
      senderId: sender.id,
      senderName: sender.nickname,
      type: payload.isImage ? MessageType.image : MessageType.file,
      content: displayContent,
      createdAt: createdAt,
      clientMessageId: clientMessageId,
      status: ack.code == 0 && ack.status != 2
          ? MessageStatus.sent
          : MessageStatus.failed,
      readBy: [sender.id],
    );
    await _upsertMessage(msg);
    return SendResult(
      message: msg,
      ackStatus: ack.status,
      ackCode: ack.code,
      ackText: ack.message,
    );
  }

  @override
  Future<void> sendTyping(int conversationId) async {
    _realtimeClient.sendTyping(conversationId);
  }

  @override
  Future<void> sendReadReceipt({
    required int conversationId,
    required int lastMessageId,
  }) async {
    _realtimeClient.sendReadReceipt(
      conversationId: conversationId,
      lastMessageId: lastMessageId,
    );
  }

  @override
  Future<List<UserProfile>> searchUsers(String keyword) {
    return _apiClient.searchUsers(keyword);
  }

  @override
  Future<Friendship> requestFriend(
    UserProfile currentUser,
    UserProfile targetUser,
  ) {
    if (targetUser.id == currentUser.id) throw ArgumentError('不能添加自己为好友');
    return _apiClient.addFriend(currentUser, targetUser.id);
  }

  @override
  Future<Friendship> acceptFriend(UserProfile currentUser, int friendshipId) {
    if (friendshipId <= 0) {
      throw StateError('缺少对端用户 ID，无法接受好友申请');
    }
    return _apiClient.acceptFriend(currentUser, friendshipId);
  }

  @override
  Future<void> rejectFriend(int friendshipId) async {
    if (friendshipId <= 0) {
      throw StateError('缺少对端用户 ID，无法拒绝好友申请');
    }
    await _apiClient.rejectFriend(
      _session?.user ??
          const UserProfile(
            id: 0,
            email: '',
            nickname: '',
            avatarUrl: '',
            status: PresenceStatus.offline,
          ),
      friendshipId,
    );
  }

  @override
  Future<Conversation> createDirectConversation({
    required UserProfile currentUser,
    required UserProfile targetUser,
  }) {
    if (targetUser.id == currentUser.id) throw ArgumentError('不能和自己发起直聊');
    return _apiClient.createConversation(
      type: ConversationType.direct,
      name: targetUser.nickname,
      memberIds: [targetUser.id],
    );
  }

  @override
  Future<Conversation> createGroup({
    required UserProfile currentUser,
    required String name,
    required List<int> memberIds,
  }) {
    return _apiClient.createGroup(name: name, memberIds: memberIds);
  }

  @override
  Future<Conversation> updateGroupName(int conversationId, String name) {
    return _apiClient.updateGroupInfo(conversationId, name: name);
  }

  @override
  Future<List<UserProfile>> getConversationMembers(int conversationId) {
    return _apiClient.getConversationMembers(conversationId);
  }

  @override
  Future<void> leaveConversation(int conversationId) {
    return _apiClient.leaveConversation(conversationId);
  }

  @override
  Future<HistoryPage?> loadMoreHistory(
    int conversationId, {
    required int cursorCreatedAt,
    required int cursorId,
  }) async {
    try {
      final data = await _apiClient.getHistory(
        conversationId,
        cursorCreatedAt: cursorCreatedAt,
        cursorId: cursorId,
      );
      await _writeReadStates(conversationId, data.readStates);
      for (final message in data.messages) {
        await _upsertMessage(message);
      }
      return HistoryPage(
        messages: data.messages,
        hasMore: data.hasMore,
        nextCursorCreatedAt: data.nextCursorCreatedAt,
        nextCursorId: data.nextCursorId,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  /// 添加群成员
  Future<Conversation> addGroupMembers(
    int conversationId,
    List<int> memberIds,
  ) {
    return _apiClient.addGroupMembers(conversationId, memberIds);
  }

  @override
  /// 移除群成员
  Future<void> removeGroupMember(int conversationId, int userId) {
    return _apiClient.removeGroupMember(conversationId, userId);
  }

  @override
  /// 授予群管理员
  Future<void> grantAdmin(int conversationId, int userId) {
    return _apiClient.grantAdmin(conversationId, userId);
  }

  @override
  /// 撤销群管理员
  Future<void> revokeAdmin(int conversationId, int userId) {
    return _apiClient.revokeAdmin(conversationId, userId);
  }

  @override
  /// 转让群主
  Future<Conversation> transferGroupOwner(int conversationId, int newOwnerId) {
    return _apiClient.transferGroupOwner(conversationId, newOwnerId);
  }

  @override
  /// 解散群聊
  Future<void> dismissGroup(int conversationId) {
    return _apiClient.dismissGroup(conversationId);
  }

  @override
  Future<AttachmentItem> initAttachmentUpload({
    required int conversationId,
    required String kind,
    required String originalName,
    required String mime,
    required int size,
  }) {
    return _apiClient.initAttachmentUpload(
      conversationId: conversationId,
      kind: kind,
      originalName: originalName,
      mime: mime,
      size: size,
    );
  }

  @override
  Future<AttachmentItem> uploadAttachment({
    required int conversationId,
    required String kind,
    required String originalName,
    required String mime,
    required int size,
    required Uint8List bytes,
    String localPreviewDataUri = '',
    void Function(double progress)? onProgress,
  }) {
    return _apiClient.uploadAttachment(
      conversationId: conversationId,
      kind: kind,
      originalName: originalName,
      mime: mime,
      size: size,
      bytes: bytes,
      localPreviewDataUri: localPreviewDataUri,
      onProgress: onProgress,
    );
  }

  @override
  Future<AttachmentItem> uploadAttachmentStream({
    required int conversationId,
    required String kind,
    required String originalName,
    required String mime,
    required int size,
    required Stream<List<int>> Function() openRead,
    String localPreviewDataUri = '',
    void Function(double progress)? onProgress,
  }) {
    return _apiClient.uploadAttachmentStream(
      conversationId: conversationId,
      kind: kind,
      originalName: originalName,
      mime: mime,
      size: size,
      openRead: openRead,
      localPreviewDataUri: localPreviewDataUri,
      onProgress: onProgress,
    );
  }

  @override
  Future<AttachmentDownloadResult> downloadAttachment(
    AttachmentMessagePayload payload,
  ) async {
    final bytes = await _apiClient.downloadAttachmentBytes(payload.fileId);
    final url = await _apiClient
        .getAttachmentDownloadUrl(payload.fileId)
        .catchError((_) => payload.downloadUrl);
    return AttachmentDownloadResult(
      fileName: payload.name,
      mime: payload.mime,
      bytes: bytes,
      sourceUrl: url,
    );
  }

  /// 下载附件缩略图（manual §11.4）。
  /// 使用 [payload.thumbnailFileId] 作为 object_key。
  Future<AttachmentDownloadResult?> downloadThumbnail(
    AttachmentMessagePayload payload,
  ) async {
    final fileId = payload.thumbnailFileId;
    if (fileId.isEmpty) return null;
    try {
      final bytes = await _apiClient.downloadThumbnailBytes(fileId);
      if (bytes == null) return null;
      return AttachmentDownloadResult(
        fileName: 'thumbnail_${payload.name}',
        mime: 'image/png',
        bytes: bytes,
      );
    } catch (_) {
      return null;
    }
  }
}
