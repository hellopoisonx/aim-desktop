import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:aim_desktop/src/data/aim_repository.dart';
import 'package:aim_desktop/src/data/gateway_realtime_client.dart';
import 'package:aim_desktop/src/data/secure_storage.dart';
import 'package:aim_desktop/src/domain/models.dart';

class MemoryTokenStorage implements TokenStorage {
  String? accessToken;
  String? refreshToken;
  String? userId;
  String? deviceId;

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<String?> readUserId() async => userId;

  @override
  Future<String?> readDeviceId() async => deviceId;

  @override
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String deviceId,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    this.userId = userId;
    this.deviceId = deviceId;
  }

  @override
  Future<void> clearSession() async {
    accessToken = null;
    refreshToken = null;
    userId = null;
    deviceId = null;
  }
}

class FakeAimRepository implements AimRepository {
  FakeAimRepository();

  final _eventsController = StreamController<RealtimeEvent>.broadcast();
  AuthSession? _session;
  List<Conversation> _conversations = const [];
  Map<int, List<ChatMessage>> _messages = const {};
  List<Friendship> _friends = const [];
  List<Friendship> _friendRequests = const [];
  List<FriendTag> _friendTags = const [];
  final List<AttachmentItem> _attachments = [];

  @override
  Stream<RealtimeEvent> get realtimeEvents => _eventsController.stream;

  void emit(RealtimeEvent event) => _eventsController.add(event);

  Future<void> close() => _eventsController.close();

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
    required String deviceId,
  }) async {
    if (email.trim().isEmpty || password.length < 6) {
      throw ArgumentError('请输入有效邮箱和至少 6 位密码');
    }
    final user = UserProfile(
      id: 1001,
      email: email.trim(),
      nickname: email.split('@').first,
      avatarUrl: '',
      status: PresenceStatus.online,
    );
    _session = _sessionFor(user);
    _resetData(user);
    return _session!;
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String username,
    required String deviceId,
  }) async {
    if (email.trim().isEmpty ||
        password.length < 8 ||
        username.trim().isEmpty) {
      throw ArgumentError('注册需要邮箱、昵称和至少 8 位密码');
    }
    final user = UserProfile(
      id: 1001,
      email: email.trim(),
      nickname: username.trim(),
      avatarUrl: '',
      status: PresenceStatus.online,
    );
    _session = _sessionFor(user);
    _resetData(user);
    return _session!;
  }

  @override
  Future<AuthSession> refreshSession(AuthSession session) async {
    _session = _sessionFor(session.user);
    return _session!;
  }

  @override
  Future<void> logout(String accessToken) async {
    _session = null;
  }

  @override
  Future<AimBootstrapData> loadBootstrapData(UserProfile user) async {
    if (_conversations.isEmpty) _resetData(user);
    return AimBootstrapData(
      conversations: [..._conversations],
      messagesByConversation: {
        for (final entry in _messages.entries) entry.key: [...entry.value],
      },
      friends: [..._friends],
      friendRequests: [..._friendRequests],
      friendTags: [..._friendTags],
      attachments: [..._attachments],
      orders: const [],
    );
  }

  @override
  Future<SendResult> sendTextMessage({
    required int conversationId,
    required UserProfile sender,
    required String content,
    required String clientMessageId,
    required DateTime createdAt,
  }) async {
    final message = ChatMessage(
      id: createdAt.millisecondsSinceEpoch,
      conversationId: conversationId,
      senderId: sender.id,
      senderName: sender.nickname,
      type: MessageType.text,
      content: content,
      createdAt: createdAt,
      clientMessageId: clientMessageId,
      status: MessageStatus.sent,
      readBy: [sender.id],
    );
    _messages = {
      ..._messages,
      conversationId: [..._messages[conversationId] ?? const [], message],
    };
    return SendResult(message: message, ackStatus: 1);
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
    final message = ChatMessage(
      id: createdAt.millisecondsSinceEpoch,
      conversationId: conversationId,
      senderId: sender.id,
      senderName: sender.nickname,
      type: messageTypeFromAttachmentPayload(payload),
      content: displayContent,
      createdAt: createdAt,
      clientMessageId: clientMessageId,
      status: MessageStatus.sent,
      readBy: [sender.id],
    );
    _messages = {
      ..._messages,
      conversationId: [..._messages[conversationId] ?? const [], message],
    };
    return SendResult(message: message, ackStatus: 1);
  }

  @override
  Future<void> sendTyping(int conversationId) async {}

  @override
  Future<void> sendReadReceipt({
    required int conversationId,
    required int lastMessageId,
  }) async {}

  @override
  Future<List<UserProfile>> searchUsers(String keyword) async {
    final value = keyword.trim();
    if (value.isEmpty) return const [];
    return [
      UserProfile(
        id: 6001,
        email: '${value.toLowerCase()}@example.test',
        nickname: value,
        avatarUrl: '',
        status: PresenceStatus.offline,
      ),
    ];
  }

  @override
  Future<List<FriendTag>> listFriendTags() async => [..._friendTags];

  @override
  Future<FriendTag> createFriendTag(String name) async {
    final now = DateTime.now();
    final tag = FriendTag(
      id: now.microsecondsSinceEpoch,
      userId: _session?.user.id ?? 0,
      name: name.trim(),
      createdAt: now,
      updatedAt: now,
    );
    _friendTags = [tag, ..._friendTags];
    return tag;
  }

  @override
  Future<FriendTag> renameFriendTag(int tagId, String name) async {
    final existing = _friendTags.firstWhere((item) => item.id == tagId);
    final renamed = existing.copyWith(name: name.trim(), updatedAt: DateTime.now());
    _friendTags = _friendTags.map((item) => item.id == tagId ? renamed : item).toList();
    _friends = _friends
        .map((friendship) => friendship.copyWith(
              tags: friendship.tags
                  .map((tag) => tag.id == tagId ? renamed : tag)
                  .toList(),
            ))
        .toList();
    return renamed;
  }

  @override
  Future<void> deleteFriendTag(int tagId) async {
    _friendTags = _friendTags.where((item) => item.id != tagId).toList();
    _friends = _friends
        .map((friendship) => friendship.copyWith(
              tags: friendship.tags.where((tag) => tag.id != tagId).toList(),
            ))
        .toList();
  }

  @override
  Future<Friendship> setFriendTags(int friendId, List<int> tagIds) async {
    final tagIdSet = tagIds.toSet();
    final tags = _friendTags.where((tag) => tagIdSet.contains(tag.id)).toList();
    late Friendship updated;
    _friends = _friends.map((friendship) {
      if (friendship.id != friendId) return friendship;
      updated = friendship.copyWith(tags: tags);
      return updated;
    }).toList();
    return updated;
  }

  @override
  Future<Friendship> removeFriendTag(int friendId, int tagId) async {
    late Friendship updated;
    _friends = _friends.map((friendship) {
      if (friendship.id != friendId) return friendship;
      updated = friendship.copyWith(
        tags: friendship.tags.where((tag) => tag.id != tagId).toList(),
      );
      return updated;
    }).toList();
    return updated;
  }

  @override
  Future<UnifiedSearchResult> search(
    String query, {
    List<String> scopes = const [],
    int? conversationId,
    int? cursorCreatedAt,
    int? cursorId,
    int limit = 20,
  }) async {
    final value = query.trim().toLowerCase();
    if (value.isEmpty) return const UnifiedSearchResult();
    final friendResults = _friends
        .where((friendship) =>
            friendship.user.nickname.toLowerCase().contains(value) ||
            friendship.user.email.toLowerCase().contains(value) ||
            friendship.tags.any((tag) => tag.name.toLowerCase().contains(value)))
        .map((friendship) => SearchFriendResult(
              friendship: friendship,
              user: friendship.user,
              snippet: friendship.user.nickname,
            ))
        .toList();
    final conversationResults = _conversations
        .where((conversation) => conversation.name.toLowerCase().contains(value))
        .map((conversation) => SearchConversationResult(
              conversation: conversation,
              snippet: conversation.name,
            ))
        .toList();
    final messageResults = _messages.values
        .expand((messages) => messages)
        .where((message) =>
            (conversationId == null || message.conversationId == conversationId) &&
            message.content.toLowerCase().contains(value))
        .map((message) => SearchMessageResult(
              message: message,
              snippet: message.content,
            ))
        .toList();
    return UnifiedSearchResult(
      friends: friendResults,
      conversations: conversationResults,
      messages: messageResults.take(limit).toList(),
    );
  }

  @override
  Future<Friendship> requestFriend(
    UserProfile currentUser,
    UserProfile targetUser,
  ) async {
    final now = DateTime.now();
    final request = Friendship(
      id: targetUser.id,
      user: targetUser,
      status: FriendStatus.pending,
      createdAt: now,
      updatedAt: now,
    );
    _friendRequests = [request, ..._friendRequests];
    return request;
  }

  @override
  Future<Friendship> acceptFriend(
    UserProfile currentUser,
    int friendshipId,
  ) async {
    final existing = _friendRequests
        .where((item) => item.id == friendshipId)
        .firstOrNull;
    final now = DateTime.now();
    final accepted = Friendship(
      id: friendshipId,
      user:
          existing?.user ??
          UserProfile(
            id: friendshipId,
            email: 'user-$friendshipId@example.test',
            nickname: '用户 $friendshipId',
            avatarUrl: '',
            status: PresenceStatus.online,
          ),
      status: FriendStatus.accepted,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    _friendRequests = _friendRequests
        .where((item) => item.id != friendshipId)
        .toList();
    _friends = [accepted, ..._friends];
    return accepted;
  }

  @override
  Future<void> rejectFriend(int friendshipId) async {
    _friendRequests = _friendRequests
        .where((item) => item.id != friendshipId)
        .toList();
  }

  @override
  Future<Conversation> createDirectConversation({
    required UserProfile currentUser,
    required UserProfile targetUser,
  }) async {
    final now = DateTime.now();
    final conversation = Conversation(
      id: now.microsecondsSinceEpoch,
      type: ConversationType.direct,
      name: targetUser.nickname,
      avatarText: targetUser.initials,
      memberIds: [currentUser.id, targetUser.id],
      createdAt: now,
      updatedAt: now,
      lastMessagePreview: '新的直聊会话已创建',
    );
    _conversations = [conversation, ..._conversations];
    _messages = {..._messages, conversation.id: const []};
    return conversation;
  }

  @override
  Future<Conversation> createGroup({
    required UserProfile currentUser,
    required String name,
    required List<int> memberIds,
  }) async {
    final now = DateTime.now();
    final conversation = Conversation(
      id: now.microsecondsSinceEpoch,
      type: ConversationType.group,
      name: name,
      avatarText: _avatarText(name),
      memberIds: <int>{currentUser.id, ...memberIds}.toList(),
      ownerId: currentUser.id,
      createdAt: now,
      updatedAt: now,
      lastMessagePreview: '群聊已创建',
    );
    _conversations = [conversation, ..._conversations];
    _messages = {..._messages, conversation.id: const []};
    return conversation;
  }

  @override
  Future<Conversation> updateGroupName(int conversationId, String name) async {
    final existing = _conversations.firstWhere(
      (item) => item.id == conversationId,
    );
    final updated = existing.copyWith(
      name: name,
      avatarText: _avatarText(name),
      updatedAt: DateTime.now(),
      lastMessagePreview: '群信息已更新',
    );
    _conversations = _conversations
        .map((item) => item.id == conversationId ? updated : item)
        .toList();
    return updated;
  }

  @override
  Future<List<UserProfile>> getConversationMembers(int conversationId) async {
    final conversation = _conversations.firstWhere(
      (item) => item.id == conversationId,
    );
    return conversation.memberIds.map((id) => _profileForId(id)).toList();
  }

  @override
  Future<Conversation> addGroupMembers(
    int conversationId,
    List<int> memberIds,
  ) async {
    final existing = _conversations.firstWhere(
      (item) => item.id == conversationId,
    );
    final updated = existing.copyWith(
      memberIds: <int>{...existing.memberIds, ...memberIds}.toList(),
      updatedAt: DateTime.now(),
      lastMessagePreview: '已添加群成员',
    );
    _conversations = _conversations
        .map((item) => item.id == conversationId ? updated : item)
        .toList();
    return updated;
  }

  @override
  Future<void> removeGroupMember(int conversationId, int userId) async {
    _conversations = _conversations.map((item) {
      if (item.id != conversationId) return item;
      return item.copyWith(
        memberIds: item.memberIds.where((id) => id != userId).toList(),
        updatedAt: DateTime.now(),
        lastMessagePreview: '已移出群成员',
      );
    }).toList();
  }

  @override
  Future<void> grantAdmin(int conversationId, int userId) async {}

  @override
  Future<void> revokeAdmin(int conversationId, int userId) async {}

  @override
  Future<Conversation> transferGroupOwner(
    int conversationId,
    int newOwnerId,
  ) async {
    final existing = _conversations.firstWhere(
      (item) => item.id == conversationId,
    );
    final updated = existing.copyWith(
      ownerId: newOwnerId,
      updatedAt: DateTime.now(),
      lastMessagePreview: '群主已转让',
    );
    _conversations = _conversations
        .map((item) => item.id == conversationId ? updated : item)
        .toList();
    return updated;
  }

  @override
  Future<void> dismissGroup(int conversationId) async {
    _conversations = _conversations.map((item) {
      if (item.id != conversationId) return item;
      return item.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
        lastMessagePreview: '群聊已解散',
      );
    }).toList();
  }

  @override
  Future<void> leaveConversation(int conversationId) async {
    _conversations = _conversations.map((item) {
      if (item.id != conversationId) return item;
      return item.copyWith(isActive: false, updatedAt: DateTime.now());
    }).toList();
  }

  @override
  Future<HistoryPage?> loadMoreHistory(
    int conversationId, {
    required int cursorCreatedAt,
    required int cursorId,
  }) async => null;

  @override
  Future<AttachmentItem> initAttachmentUpload({
    required int conversationId,
    required String kind,
    required String originalName,
    required String mime,
    required int size,
  }) async {
    final attachment = AttachmentItem(
      id: 'att_${DateTime.now().microsecondsSinceEpoch}',
      conversationId: conversationId,
      kind: kind,
      name: originalName,
      sizeLabel: _formatBytes(size),
      status: 'uploaded / parsed',
      mime: mime,
      sizeBytes: size,
      parseStatus: 'parsed',
    );
    _attachments.add(attachment);
    return attachment;
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
  }) async {
    onProgress?.call(1);
    final attachment = await initAttachmentUpload(
      conversationId: conversationId,
      kind: kind,
      originalName: originalName,
      mime: mime,
      size: size,
    );
    return attachment.copyWith(localPreviewDataUri: localPreviewDataUri);
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
  }) async {
    onProgress?.call(1);
    return uploadAttachment(
      conversationId: conversationId,
      kind: kind,
      originalName: originalName,
      mime: mime,
      size: size,
      bytes: Uint8List(0),
      localPreviewDataUri: localPreviewDataUri,
    );
  }

  @override
  Future<AttachmentDownloadResult> downloadAttachment(
    AttachmentMessagePayload payload,
  ) async {
    final bytes = payload.localPreviewDataUri.startsWith('data:')
        ? base64Decode(payload.localPreviewDataUri.split(',').last)
        : Uint8List(0);
    return AttachmentDownloadResult(
      fileName: payload.name,
      mime: payload.mime,
      bytes: bytes,
      sourceUrl: payload.downloadUrl,
    );
  }

  UserProfile _profileForId(int userId) {
    if (_session?.user.id == userId) return _session!.user;
    for (final friendship in [..._friends, ..._friendRequests]) {
      if (friendship.user.id == userId) return friendship.user;
    }
    return UserProfile(
      id: userId,
      email: 'member$userId@example.test',
      nickname: '成员 $userId',
      avatarUrl: '',
      status: PresenceStatus.offline,
    );
  }

  AuthSession _sessionFor(UserProfile user) {
    final now = DateTime.now();
    return AuthSession(
      user: user,
      accessToken: 'test-access-token-${now.microsecondsSinceEpoch}',
      refreshToken: 'test-refresh-token-${now.microsecondsSinceEpoch}',
      expiresAt: now.add(const Duration(hours: 1)),
    );
  }

  void _resetData(UserProfile user) {
    final now = DateTime.now();
    final alice = const UserProfile(
      id: 2001,
      email: 'alice@example.test',
      nickname: 'Alice',
      avatarUrl: '',
      status: PresenceStatus.online,
    );
    final bob = const UserProfile(
      id: 2002,
      email: 'bob@example.test',
      nickname: 'Bob',
      avatarUrl: '',
      status: PresenceStatus.offline,
    );
    final group = Conversation(
      id: 501,
      type: ConversationType.group,
      name: 'AIM 研发群',
      avatarText: 'AIM',
      memberIds: [user.id, alice.id, bob.id],
      ownerId: user.id,
      createdAt: now.subtract(const Duration(days: 7)),
      updatedAt: now.subtract(const Duration(minutes: 2)),
      lastMessagePreview: 'Alice: 欢迎使用 AIM。',
      unreadCount: 1,
      isPinned: true,
    );
    final direct = Conversation(
      id: 502,
      type: ConversationType.direct,
      name: 'Alice',
      avatarText: 'AL',
      memberIds: [user.id, alice.id],
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(minutes: 18)),
      lastMessagePreview: '我把接口文档整理好了。',
      unreadCount: 1,
    );
    _conversations = [group, direct];
    _messages = {
      501: [
        ChatMessage(
          id: 90001,
          conversationId: 501,
          senderId: alice.id,
          senderName: alice.nickname,
          type: MessageType.text,
          content: '欢迎使用 AIM。',
          createdAt: now.subtract(const Duration(minutes: 8)),
          clientMessageId: 'seed-501-1',
        ),
      ],
      502: [
        ChatMessage(
          id: 91001,
          conversationId: 502,
          senderId: alice.id,
          senderName: alice.nickname,
          type: MessageType.text,
          content: '我把接口文档整理好了。',
          createdAt: now.subtract(const Duration(minutes: 18)),
          clientMessageId: 'seed-502-1',
        ),
      ],
    };
    final tag = FriendTag(
      id: 7001,
      userId: user.id,
      name: '同事',
      createdAt: now.subtract(const Duration(days: 5)),
      updatedAt: now.subtract(const Duration(days: 1)),
    );
    _friendTags = [tag];
    _friends = [
      Friendship(
        id: alice.id,
        user: alice,
        status: FriendStatus.accepted,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 1)),
        tags: [tag],
      ),
      Friendship(
        id: bob.id,
        user: bob,
        status: FriendStatus.accepted,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
    _friendRequests = const [];
    _attachments.clear();
  }
}

String _avatarText(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return '?';
  return String.fromCharCodes(trimmed.runes.take(3)).toUpperCase();
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
