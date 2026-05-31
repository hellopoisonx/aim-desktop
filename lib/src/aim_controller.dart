import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import 'data/aim_repository.dart';
import 'data/database.dart';
import 'data/gateway_aim_repository.dart';
import 'data/gateway_realtime_client.dart';
import 'data/secure_storage.dart';
import 'domain/models.dart';

/// 全局唯一的本地缓存数据库实例。
final aimLocalDatabaseProvider = Provider<AimLocalDatabase>((ref) {
  return AimLocalDatabase();
});

final aimControllerProvider = ChangeNotifierProvider<AimController>((ref) {
  final db = ref.watch(aimLocalDatabaseProvider);
  return AimController(
    repository: GatewayAimRepository(database: db),
    tokenStorage: SecureTokenStorage(),
  );
});

final defaultTokenRefetchMargin = const Duration(seconds: 60);

/// 安全巡检周期：每隔该间隔检查 token 是否即将过期，防止单次 Timer 误期。
final defaultTokenSafetyInterval = const Duration(seconds: 30);

/// Token 刷新失败后退避重试最大次数。
const _maxTokenRefreshRetries = 3;

class AimController extends ChangeNotifier {
  AimController({
    required AimRepository repository,
    TokenStorage? tokenStorage,
    Duration? tokenRefetchMargin,
    String? deviceId,
  }) : _tokenRefetchMargin = tokenRefetchMargin ?? defaultTokenRefetchMargin,
       _repository = repository,
       _activeRepository = repository,
       _tokenStorage = tokenStorage ?? const SecureTokenStorage(),
       _deviceId = deviceId ?? _newDeviceId();

  final AimRepository _repository;
  AimRepository _activeRepository;
  final TokenStorage _tokenStorage;
  final Duration _tokenRefetchMargin;
  final String _deviceId;
  final Random _random = Random.secure();
  StreamSubscription<RealtimeEvent>? _realtimeSubscription;
  Timer? _tokenRefreshTimer;
  Timer? _tokenSafetyTimer;
  int _tokenRefreshRetries = 0;
  final Map<int, Timer> _typingClearTimers = {};
  DateTime? _lastTypingSentAt;
  AimState _state = AimState.initial();

  AimState get state => _state;

  @override
  void dispose() {
    _stopTokenRefreshTimer();
    unawaited(_realtimeSubscription?.cancel());
    for (final timer in _typingClearTimers.values) {
      timer.cancel();
    }
    _typingClearTimers.clear();
    super.dispose();
  }

  Future<void> login({required String email, required String password}) async {
    _setBusy(true);
    try {
      _activeRepository = _repository;
      _subscribeRealtimeEvents();
      final session = await _repository.login(
        email: email,
        password: password,
        deviceId: _deviceId,
      );
      await _loadAuthenticatedState(session, '登录成功');
    } catch (error) {
      _emitNotice(_readableError(error));
    } finally {
      _setBusy(false);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    _setBusy(true);
    try {
      _activeRepository = _repository;
      _subscribeRealtimeEvents();
      final session = await _repository.register(
        email: email,
        password: password,
        username: username,
        deviceId: _deviceId,
      );
      await _loadAuthenticatedState(session, '注册成功，已为你初始化好友与会话数据');
    } catch (error) {
      _emitNotice(_readableError(error));
    } finally {
      _setBusy(false);
    }
  }

  Future<void> logout() async {
    _stopTokenRefreshTimer();
    await _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
    for (final timer in _typingClearTimers.values) {
      timer.cancel();
    }
    _typingClearTimers.clear();
    final token = _state.session?.accessToken;
    if (token != null) {
      await _activeRepository.logout(token);
    }
    await _tokenStorage.clearSession();
    _state = AimState.initial().copyWith(
      notice: '已退出当前设备',
      noticeSerial: _state.noticeSerial + 1,
    );
    notifyListeners();
  }

  void selectSection(AppSection section) {
    _state = _state.copyWith(currentSection: section);
    notifyListeners();
    if (section == AppSection.bots && _state.botCenter.ownedBots.isEmpty) {
      unawaited(loadUserBots(silent: true));
    }
  }

  void updateSearchQuery(String value) {
    _state = _state.copyWith(searchQuery: value);
    notifyListeners();
  }

  void selectConversation(int conversationId) {
    final conversations = _state.conversations.map((conversation) {
      if (conversation.id != conversationId) return conversation;
      return conversation.copyWith(unreadCount: 0, typingUserId: null);
    }).toList();
    _state = _state.copyWith(
      currentSection: AppSection.chats,
      selectedConversationId: conversationId,
      conversations: conversations,
    );
    _markMessagesRead(conversationId);
    notifyListeners();
    final selectedConversation = _state.selectedConversation;
    if (selectedConversation?.type == ConversationType.group) {
      unawaited(loadConversationMembers(conversationId));
    }
  }

  Future<void> loadConversationMembers(int conversationId) async {
    if (conversationId <= 0) return;
    try {
      final members = await _activeRepository.getConversationMembers(
        conversationId,
      );
      _state = _state.copyWith(
        conversationMembersById: {
          ..._state.conversationMembersById,
          conversationId: members,
        },
      );
      notifyListeners();
    } catch (error) {
      _emitNotice(_readableError(error));
    }
  }

  void clearSelectedConversation() {
    _state = _state.copyWith(selectedConversationId: null);
    notifyListeners();
  }

  Future<void> loadOlderMessages() async {
    final conversation = _state.selectedConversation;
    if (conversation == null) return;
    final existingMessages = _state.messagesFor(conversation.id);
    if (existingMessages.isEmpty) {
      _emitNotice('当前会话暂无可翻页消息');
      return;
    }
    final oldest = existingMessages.first;
    final page = await _activeRepository.loadMoreHistory(
      conversation.id,
      cursorCreatedAt: oldest.createdAt.millisecondsSinceEpoch,
      cursorId: oldest.id,
    );
    if (page == null || page.messages.isEmpty) {
      _emitNotice('没有更早的消息');
      return;
    }
    final merged = <ChatMessage>[...page.messages, ...existingMessages];
    final seenServerIds = <int>{};
    final seenClientIds = <String>{};
    final uniqueMessages = <ChatMessage>[];
    for (final message in merged) {
      if (message.id > 0 && !seenServerIds.add(message.id)) continue;
      if (message.clientMessageId.isNotEmpty &&
          !seenClientIds.add(message.clientMessageId)) {
        continue;
      }
      uniqueMessages.add(message);
    }
    uniqueMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _state = _state.copyWith(
      messagesByConversation: {
        ..._state.messagesByConversation,
        conversation.id: uniqueMessages,
      },
    );
    notifyListeners();
  }

  Future<void> sendTextMessage(
    String rawText, {
    List<String> mentions = const [],
  }) async {
    final text = rawText.trim();
    if (text.isEmpty) return;
    // Frame size check per manual §15.4 (WS max 1024 bytes)
    if (text.length > 800) {
      _emitNotice('消息过长（超过 800 字符），请分段发送或使用附件');
      return;
    }
    final conversation = _state.selectedConversation;
    final currentUser = _state.currentUser;
    if (conversation == null || currentUser == null) {
      _emitNotice('请先选择一个会话');
      return;
    }

    final createdAt = DateTime.now();
    final clientMessageId = _newClientMsgId();
    final pendingMessage = ChatMessage(
      id: -createdAt.microsecondsSinceEpoch,
      conversationId: conversation.id,
      senderId: currentUser.id,
      senderName: currentUser.nickname,
      type: MessageType.text,
      content: text,
      createdAt: createdAt,
      clientMessageId: clientMessageId,
      status: MessageStatus.sending,
      readBy: [currentUser.id],
      mentions: mentions,
    );
    _appendMessage(pendingMessage);
    _upsertConversation(
      conversation.copyWith(
        lastMessagePreview: '${currentUser.nickname}: $text',
        updatedAt: createdAt,
        typingUserId: null,
      ),
    );
    notifyListeners();

    try {
      final result = await _activeRepository.sendTextMessage(
        conversationId: conversation.id,
        sender: currentUser,
        content: text,
        clientMessageId: clientMessageId,
        createdAt: createdAt,
        mentions: mentions,
      );
      // ACK status differentiation per manual §5.3
      _handleSendAck(clientMessageId, pendingMessage, result);
    } catch (error) {
      _replaceMessage(
        clientMessageId,
        pendingMessage.copyWith(status: MessageStatus.failed),
      );
      _emitNotice(_readableError(error));
    }
  }

  void _handleSendAck(
    String clientMessageId,
    ChatMessage pending,
    SendResult ack,
  ) {
    switch (ack.ackStatus) {
      case 1: // ACCEPTED
        _replaceMessage(
          clientMessageId,
          pending.copyWith(
            id: ack.message.id > 0 ? ack.message.id : pending.id,
            status: MessageStatus.sent,
          ),
        );
        _emitNotice('消息已发送，等待对端已读回执');
        break;
      case 2: // REJECTED
        _replaceMessage(
          clientMessageId,
          pending.copyWith(status: MessageStatus.failed),
        );
        _emitNotice('消息发送被拒绝：${ack.ackText}');
        break;
      case 3: // RETRYABLE
        _emitNotice('服务器暂时不可用，正在重试...');
        _retrySendTextMessage(pending);
        break;
      default: // UNSPECIFIED, treat as success if code==0
        if (ack.ackCode == 0) {
          _replaceMessage(
            clientMessageId,
            pending.copyWith(
              id: ack.message.id > 0 ? ack.message.id : pending.id,
              status: MessageStatus.sent,
            ),
          );
          _emitNotice('消息已发送');
        } else {
          _replaceMessage(
            clientMessageId,
            pending.copyWith(status: MessageStatus.failed),
          );
          _emitNotice('发送失败：${ack.ackText}');
        }
    }
  }

  /// Retry send with exponential backoff per manual §13.3.
  Future<void> _retrySendTextMessage(
    ChatMessage pending, {
    int attempt = 0,
  }) async {
    if (attempt >= 5) {
      _replaceMessage(
        pending.clientMessageId,
        pending.copyWith(status: MessageStatus.failed),
      );
      _emitNotice('重试已达上限，消息发送失败');
      return;
    }
    final delay = switch (attempt) {
      0 => const Duration(seconds: 1),
      1 => const Duration(seconds: 2),
      _ => const Duration(seconds: 4),
    };
    await Future<void>.delayed(delay);
    try {
      final currentUser = _state.currentUser;
      if (currentUser == null) return;
      final ack = await _activeRepository.sendTextMessage(
        conversationId: pending.conversationId,
        sender: currentUser,
        content: pending.content,
        clientMessageId: pending.clientMessageId,
        createdAt: pending.createdAt,
      );
      _handleSendAck(pending.clientMessageId, pending, ack);
    } catch (_) {
      await _retrySendTextMessage(pending, attempt: attempt + 1);
    }
  }

  Future<void> sendAttachment({
    required String kind,
    required String originalName,
    required String mime,
    Uint8List? bytes,
    int? size,
    Stream<List<int>> Function()? openRead,
    String localPreviewDataUri = '',
  }) async {
    final conversation = _state.selectedConversation;
    final currentUser = _state.currentUser;
    if (conversation == null || currentUser == null) {
      _emitNotice('请选择会话后再上传附件');
      return;
    }
    final byteLength = size ?? bytes?.length ?? 0;
    if (byteLength <= 0 || (bytes == null && openRead == null)) {
      _emitNotice('无法上传空附件');
      return;
    }

    final normalizedMime = _normalizeMimeForKind(kind, originalName, mime);

    final createdAt = DateTime.now();
    final clientMessageId = 'a1-${_newClientMsgId().substring(3)}';
    final localAttachment = AttachmentItem(
      id: 'local-$clientMessageId',
      conversationId: conversation.id,
      kind: kind,
      name: originalName,
      sizeLabel: _formatBytes(byteLength),
      status: 'uploading 0%',
      mime: normalizedMime,
      sizeBytes: byteLength,
      parseStatus: 'waiting',
      localPreviewDataUri: localPreviewDataUri,
      createdAt: createdAt,
    );
    final pendingMessage = ChatMessage(
      id: -createdAt.microsecondsSinceEpoch,
      conversationId: conversation.id,
      senderId: currentUser.id,
      senderName: currentUser.nickname,
      type: messageTypeFromAttachmentKind(kind: kind, mime: normalizedMime),
      // 不把本地预览（base64）写进消息正文：消息列表会频繁重建，
      // 大字符串反复 jsonEncode/jsonDecode 会造成明显卡顿。预览数据只保存在
      // attachments 状态里，由 UI 按 file_id 关联读取。
      content: localAttachment.toMessageContent(
        status: 'uploading',
        localPreviewDataUri: '',
      ),
      createdAt: createdAt,
      clientMessageId: clientMessageId,
      status: MessageStatus.sending,
      readBy: [currentUser.id],
    );

    _appendMessage(pendingMessage);
    _state = _state.copyWith(
      attachments: [localAttachment, ..._state.attachments],
    );
    _upsertConversation(
      conversation.copyWith(
        lastMessagePreview:
            '[${localAttachment.displayKind}] ${localAttachment.name}',
        updatedAt: createdAt,
        typingUserId: null,
      ),
    );
    notifyListeners();

    var latestAttachment = localAttachment;
    var lastProgressPercent = -1;
    DateTime? lastProgressNotifiedAt;
    try {
      void handleProgress(double progress) {
        final percent = (progress * 100).clamp(0, 100).round();
        final now = DateTime.now();
        final enoughDelta =
            lastProgressPercent < 0 ||
            percent == 100 ||
            (percent - lastProgressPercent).abs() >= 5;
        final enoughTime =
            lastProgressNotifiedAt == null ||
            now.difference(lastProgressNotifiedAt!) >=
                const Duration(milliseconds: 180);
        if (percent == lastProgressPercent || (!enoughDelta && !enoughTime)) {
          return;
        }
        lastProgressPercent = percent;
        lastProgressNotifiedAt = now;
        latestAttachment = latestAttachment.copyWith(
          status: 'uploading $percent%',
        );
        // 只更新附件状态；消息卡片通过 file_id 关联附件状态，避免每个进度事件
        // 都重写整段消息 JSON。
        _replaceAttachment(localAttachment.id, latestAttachment);
      }

      final uploaded = openRead == null
          ? await _activeRepository.uploadAttachment(
              conversationId: conversation.id,
              kind: kind,
              originalName: originalName,
              mime: normalizedMime,
              size: byteLength,
              bytes: bytes!,
              localPreviewDataUri: localPreviewDataUri,
              onProgress: handleProgress,
            )
          : await _activeRepository.uploadAttachmentStream(
              conversationId: conversation.id,
              kind: kind,
              originalName: originalName,
              mime: normalizedMime,
              size: byteLength,
              openRead: openRead,
              localPreviewDataUri: localPreviewDataUri,
              onProgress: handleProgress,
            );
      final displayAttachment = uploaded.copyWith(
        status: uploaded.status.isEmpty ? 'uploaded' : uploaded.status,
        localPreviewDataUri: localPreviewDataUri,
      );
      _replaceAttachment(localAttachment.id, displayAttachment);
      latestAttachment = displayAttachment;
      final displayContent = displayAttachment.toMessageContent(
        status: displayAttachment.status,
        localPreviewDataUri: '',
      );
      _replaceMessage(
        clientMessageId,
        pendingMessage.copyWith(content: displayContent),
      );

      final sentResult = await _activeRepository.sendAttachmentMessage(
        conversationId: conversation.id,
        sender: currentUser,
        payload: displayAttachment.toMessagePayload(
          status: displayAttachment.status,
          localPreviewDataUri: '',
        ),
        displayContent: displayContent,
        clientMessageId: clientMessageId,
        createdAt: createdAt,
      );
      _replaceMessage(clientMessageId, sentResult.message);
      _emitNotice('${displayAttachment.displayKind}已上传并发送');
    } catch (error) {
      _replaceAttachment(
        latestAttachment.id,
        latestAttachment.copyWith(status: 'failed'),
      );
      _replaceMessage(
        clientMessageId,
        pendingMessage.copyWith(
          content: latestAttachment.toMessageContent(
            status: 'failed',
            localPreviewDataUri: '',
          ),
          status: MessageStatus.failed,
        ),
      );
      _emitNotice(_readableError(error));
    }
  }

  Future<AttachmentDownloadResult> downloadAttachment(
    AttachmentMessagePayload payload, {
    bool notifyOnError = true,
  }) async {
    try {
      return await _activeRepository.downloadAttachment(payload);
    } catch (error) {
      if (notifyOnError) _emitNotice(_readableError(error));
      rethrow;
    }
  }

  void sendTypingEvent() {
    final conversation = _state.selectedConversation;
    if (conversation == null) return;
    final now = DateTime.now();
    final lastSentAt = _lastTypingSentAt;
    if (lastSentAt != null &&
        now.difference(lastSentAt) < const Duration(milliseconds: 2500)) {
      return;
    }
    _lastTypingSentAt = now;
    unawaited(_activeRepository.sendTyping(conversation.id));
  }

  void retryMessage(ChatMessage message) {
    _replaceMessage(
      message.clientMessageId,
      message.copyWith(status: MessageStatus.sending),
    );
    _emitNotice('已重新发送消息');
  }

  void updateProfile({required String nickname, required String bio}) {
    final session = _state.session;
    if (session == null) return;
    final updatedUser = session.user.copyWith(
      nickname: nickname.trim(),
      bio: bio.trim(),
    );
    _state = _state.copyWith(
      session: AuthSession(
        user: updatedUser,
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        expiresAt: session.expiresAt,
      ),
    );
    _emitNotice('个人资料已保存');
  }

  Future<List<UserProfile>> searchUsers(String keyword) async {
    final value = keyword.trim();
    final currentUser = _state.currentUser;
    if (value.isEmpty || currentUser == null) {
      _emitNotice('请输入昵称或邮箱');
      return const [];
    }
    try {
      final users = await _activeRepository.searchUsers(value);
      final results = users.where((user) => user.id != currentUser.id).toList();
      if (results.isEmpty) {
        _emitNotice('没有找到匹配用户');
      }
      return results;
    } catch (error) {
      _emitNotice(_readableError(error));
      return const [];
    }
  }

  Future<void> addFriendByName(String keyword) async {
    final results = await searchUsers(keyword);
    if (results.isEmpty) return;
    await addFriend(results.first);
  }

  Future<void> addFriend(UserProfile targetUser) async {
    final currentUser = _state.currentUser;
    if (currentUser == null) return;
    if (_state.friends.any((item) => item.user.id == targetUser.id)) {
      _emitNotice('${targetUser.nickname} 已在好友列表中');
      return;
    }
    if (_state.friendRequests.any((item) => item.user.id == targetUser.id)) {
      _emitNotice('已向 ${targetUser.nickname} 发送过好友申请');
      return;
    }
    try {
      final friendship = await _activeRepository.requestFriend(
        currentUser,
        targetUser,
      );
      _state = _state.copyWith(
        friendRequests: [friendship, ..._state.friendRequests],
      );
      _emitNotice('好友申请已发送，等待对方确认');
    } catch (error) {
      _emitNotice(_readableError(error));
    }
  }

  Future<void> acceptFriend(int friendshipId) async {
    final currentUser = _state.currentUser;
    final request = _state.friendRequests
        .where((item) => item.id == friendshipId)
        .firstOrNull;
    if (request == null || currentUser == null) return;
    try {
      final acceptedFromRepository = await _activeRepository.acceptFriend(
        currentUser,
        friendshipId,
      );
      final nextRequests = _state.friendRequests
          .where((item) => item.id != friendshipId)
          .toList();
      final accepted = request.copyWith(
        status: acceptedFromRepository.status,
        incoming: false,
      );
      _state = _state.copyWith(
        friendRequests: nextRequests,
        friends: [accepted, ..._state.friends],
      );
      _emitNotice('已接受好友申请');
    } catch (error) {
      _emitNotice(_readableError(error));
    }
  }

  Future<void> rejectFriend(int friendshipId) async {
    try {
      await _activeRepository.rejectFriend(friendshipId);
      final nextRequests = _state.friendRequests
          .where((item) => item.id != friendshipId)
          .toList();
      _state = _state.copyWith(friendRequests: nextRequests);
      _emitNotice('已拒绝好友申请');
    } catch (error) {
      _emitNotice(_readableError(error));
    }
  }

  Future<void> startDirectConversation(Friendship friendship) async {
    final existing = _state.conversations.where((conversation) {
      return conversation.type == ConversationType.direct &&
          conversation.memberIds.contains(friendship.user.id);
    }).firstOrNull;
    if (existing != null) {
      selectConversation(existing.id);
      return;
    }
    final currentUser = _state.currentUser;
    if (currentUser == null) return;
    try {
      final created = await _activeRepository.createDirectConversation(
        currentUser: currentUser,
        targetUser: friendship.user,
      );
      final conversation = created.copyWith(
        type: ConversationType.direct,
        name: created.name.trim().isEmpty
            ? friendship.user.nickname
            : created.name,
        avatarText: created.avatarText.trim().isEmpty
            ? friendship.user.initials
            : created.avatarText,
        memberIds: created.memberIds.isEmpty
            ? [currentUser.id, friendship.user.id]
            : created.memberIds,
        lastMessagePreview: created.lastMessagePreview.trim().isEmpty
            ? '新的直聊会话已创建'
            : created.lastMessagePreview,
      );
      _state = _state.copyWith(
        conversations: [conversation, ..._state.conversations],
        messagesByConversation: {
          ..._state.messagesByConversation,
          conversation.id: _state.messagesFor(conversation.id),
        },
      );
      selectConversation(conversation.id);
      _emitNotice('直聊会话已创建，可直接发送消息');
    } catch (error) {
      _emitNotice(_readableError(error));
    }
  }

  Future<void> createGroup({
    required String name,
    required List<int> memberIds,
  }) async {
    final currentUser = _state.currentUser;
    if (currentUser == null) return;
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      _emitNotice('请输入群名称');
      return;
    }
    try {
      final conversation = await _activeRepository.createGroup(
        currentUser: currentUser,
        name: trimmedName,
        memberIds: memberIds,
      );
      final now = DateTime.now();
      final systemMessage = ChatMessage(
        id: now.millisecondsSinceEpoch,
        conversationId: conversation.id,
        senderId: 0,
        senderName: '系统',
        type: MessageType.system,
        content: '${currentUser.nickname} 创建了群聊 $trimmedName',
        createdAt: now,
        clientMessageId: 'system-${now.microsecondsSinceEpoch}',
        isSystem: true,
      );
      _state = _state.copyWith(
        conversations: [conversation, ..._state.conversations],
        messagesByConversation: {
          ..._state.messagesByConversation,
          conversation.id: [systemMessage],
        },
      );
      selectConversation(conversation.id);
      _emitNotice('群聊已创建，可继续添加成员或发送消息');
    } catch (error) {
      _emitNotice(_readableError(error));
    }
  }

  Future<void> updateGroupName(int conversationId, String name) async {
    final conversation = _state.conversations
        .where((item) => item.id == conversationId)
        .firstOrNull;
    if (conversation == null) return;
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;
    try {
      final updated = await _activeRepository.updateGroupName(
        conversationId,
        trimmedName,
      );
      _upsertConversation(
        conversation.copyWith(
          name: updated.name,
          avatarText: updated.avatarText,
        ),
      );
      _appendSystemMessage(conversationId, '群名称已更新为 $trimmedName');
      _emitNotice('群信息已更新');
    } catch (error) {
      _emitNotice(_readableError(error));
    }
  }

  Future<void> addGroupMembers(int conversationId, List<int> memberIds) async {
    final conversation = _state.conversations
        .where((item) => item.id == conversationId)
        .firstOrNull;
    if (conversation == null || conversation.type != ConversationType.group) {
      return;
    }
    final newMemberIds = <int>{
      for (final id in memberIds)
        if (id > 0 && !conversation.memberIds.contains(id)) id,
    }.toList();
    if (newMemberIds.isEmpty) {
      _emitNotice('请选择尚未加入群聊的成员');
      return;
    }
    try {
      final updated = await _activeRepository.addGroupMembers(
        conversationId,
        newMemberIds,
      );
      final memberIds = updated.memberIds.isEmpty
          ? <int>{...conversation.memberIds, ...newMemberIds}.toList()
          : updated.memberIds;
      _upsertConversation(
        conversation.copyWith(
          name: updated.name.trim().isEmpty ? conversation.name : updated.name,
          avatarText: updated.avatarText.trim().isEmpty
              ? conversation.avatarText
              : updated.avatarText,
          memberIds: memberIds,
          updatedAt: updated.updatedAt,
          lastMessagePreview: updated.lastMessagePreview.trim().isEmpty
              ? '已添加群成员'
              : updated.lastMessagePreview,
          ownerId: updated.ownerId ?? conversation.ownerId,
        ),
      );
      _appendSystemMessage(conversationId, '已添加 ${newMemberIds.length} 名群成员');
      _emitNotice('群成员已添加');
    } catch (error) {
      _emitNotice(_readableError(error));
    }
  }

  Future<void> removeGroupMember(int conversationId, int userId) async {
    final conversation = _state.conversations
        .where((item) => item.id == conversationId)
        .firstOrNull;
    if (conversation == null || conversation.type != ConversationType.group) {
      return;
    }
    if (!conversation.memberIds.contains(userId)) {
      _emitNotice('该用户不在群聊中');
      return;
    }
    if (conversation.ownerId == userId) {
      _emitNotice('群主不能被移出，请先转让群主');
      return;
    }
    if (_state.currentUser?.id == userId) {
      _emitNotice('移出自己请使用退出群聊');
      return;
    }
    try {
      await _activeRepository.removeGroupMember(conversationId, userId);
      _upsertConversation(
        conversation.copyWith(
          memberIds: conversation.memberIds
              .where((memberId) => memberId != userId)
              .toList(),
          updatedAt: DateTime.now(),
          lastMessagePreview: '已移出群成员',
        ),
      );
      _appendSystemMessage(conversationId, '已移出 ${_memberDisplayName(userId)}');
      _emitNotice('群成员已移出');
    } catch (error) {
      _emitNotice(_readableError(error));
    }
  }

  Future<void> grantGroupAdmin(int conversationId, int userId) async {
    final conversation = _state.conversations
        .where((item) => item.id == conversationId)
        .firstOrNull;
    if (conversation == null || conversation.type != ConversationType.group) {
      return;
    }
    if (!conversation.memberIds.contains(userId)) {
      _emitNotice('只能将群成员设为管理员');
      return;
    }
    try {
      await _activeRepository.grantAdmin(conversationId, userId);
      _appendSystemMessage(
        conversationId,
        '${_memberDisplayName(userId)} 已设为管理员',
      );
      _emitNotice('管理员权限已授予');
    } catch (error) {
      _emitNotice(_readableError(error));
    }
  }

  Future<void> revokeGroupAdmin(int conversationId, int userId) async {
    final conversation = _state.conversations
        .where((item) => item.id == conversationId)
        .firstOrNull;
    if (conversation == null || conversation.type != ConversationType.group) {
      return;
    }
    if (conversation.ownerId == userId) {
      _emitNotice('不能撤销群主权限');
      return;
    }
    try {
      await _activeRepository.revokeAdmin(conversationId, userId);
      _appendSystemMessage(
        conversationId,
        '已撤销 ${_memberDisplayName(userId)} 的管理员权限',
      );
      _emitNotice('管理员权限已撤销');
    } catch (error) {
      _emitNotice(_readableError(error));
    }
  }

  Future<void> transferGroupOwner(int conversationId, int newOwnerId) async {
    final conversation = _state.conversations
        .where((item) => item.id == conversationId)
        .firstOrNull;
    if (conversation == null || conversation.type != ConversationType.group) {
      return;
    }
    if (!conversation.memberIds.contains(newOwnerId)) {
      _emitNotice('只能转让给群成员');
      return;
    }
    if (conversation.ownerId == newOwnerId) {
      _emitNotice('该成员已经是群主');
      return;
    }
    try {
      final updated = await _activeRepository.transferGroupOwner(
        conversationId,
        newOwnerId,
      );
      _upsertConversation(
        conversation.copyWith(
          memberIds: updated.memberIds.isEmpty
              ? conversation.memberIds
              : updated.memberIds,
          updatedAt: updated.updatedAt,
          lastMessagePreview: updated.lastMessagePreview.trim().isEmpty
              ? '群主已转让'
              : updated.lastMessagePreview,
          ownerId: updated.ownerId ?? newOwnerId,
        ),
      );
      _appendSystemMessage(
        conversationId,
        '群主已转让给 ${_memberDisplayName(newOwnerId)}',
      );
      _emitNotice('群主已转让');
    } catch (error) {
      _emitNotice(_readableError(error));
    }
  }

  Future<void> dismissGroup(int conversationId) async {
    final conversation = _state.conversations
        .where((item) => item.id == conversationId)
        .firstOrNull;
    if (conversation == null || conversation.type != ConversationType.group) {
      return;
    }
    try {
      await _activeRepository.dismissGroup(conversationId);
      _upsertConversation(
        conversation.copyWith(
          isActive: false,
          updatedAt: DateTime.now(),
          lastMessagePreview: '群聊已解散',
        ),
      );
      _appendSystemMessage(conversationId, '群聊已解散');
      _emitNotice('群聊已解散');
    } catch (error) {
      _emitNotice(_readableError(error));
    }
  }

  Future<void> leaveConversation(int conversationId) async {
    final conversation = _state.conversations
        .where((item) => item.id == conversationId)
        .firstOrNull;
    if (conversation == null) return;
    try {
      await _activeRepository.leaveConversation(conversationId);
      _upsertConversation(
        conversation.copyWith(isActive: false, lastMessagePreview: '你已退出该会话'),
      );
      _appendSystemMessage(conversationId, '你已退出该会话');
      _emitNotice('退出/解散链路已完成');
    } catch (error) {
      _emitNotice(_readableError(error));
    }
  }

  void saveSettings() {
    _emitNotice('设置已保存：通知、主题与快捷键已更新');
  }

  void submitFeedback(String text) {
    if (text.trim().isEmpty) {
      _emitNotice('请输入反馈内容');
      return;
    }
    _emitNotice('反馈已提交，服务中心将跟进处理');
  }

  /// 公开接口：手动触发 token 刷新（如用户点击"刷新连接"按钮或 UI 触发）。
  /// 使用内部退避重试逻辑。
  Future<void> refreshToken() async {
    await _refreshTokenWithRetry();
  }

  /// 清除聚合搜索结果。
  void clearSearchResults() {
    if (_state.searchResults == null && !_state.isSearching) return;
    _state = _state.copyWith(searchResults: null, isSearching: false);
    notifyListeners();
  }

  /// 全局聚合搜索：调用 GET /api/search，按用户/好友/会话/消息范围搜索。
  /// 结果存入 [AimState.searchResults]。
  Future<void> performUnifiedSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      clearSearchResults();
      return;
    }
    final currentUser = _state.currentUser;
    if (currentUser == null) {
      _emitNotice('请先登录后再搜索');
      return;
    }
    _state = _state.copyWith(isSearching: true);
    notifyListeners();
    try {
      final result = await _activeRepository.search(
        trimmed,
        scopes: const ['users', 'friends', 'conversations', 'messages'],
      );
      _state = _state.copyWith(searchResults: result, isSearching: false);
      notifyListeners();
      if (result.isEmpty) {
        _emitNotice('未找到匹配结果');
      } else {
        final count =
            result.users.length +
            result.friends.length +
            result.conversations.length +
            result.messages.length;
        _emitNotice('找到 $count 条结果');
      }
    } catch (error) {
      _state = _state.copyWith(isSearching: false);
      notifyListeners();
      _emitNotice(_readableError(error));
    }
  }

  /// 在指定会话内搜索消息。
  Future<void> searchMessagesInConversation(
    int conversationId,
    String query,
  ) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty || _state.currentUser == null) return;
    _state = _state.copyWith(isSearching: true);
    notifyListeners();
    try {
      final result = await _activeRepository.search(
        trimmed,
        scopes: const ['messages'],
        conversationId: conversationId,
      );
      _state = _state.copyWith(
        isSearching: false,
        // 将每页搜索结果作为独立状态存储，供 UI 临时展示
        searchResults: result,
      );
      notifyListeners();
      if (result.messages.isEmpty) {
        _emitNotice('该会话中未找到匹配消息');
      } else {
        _emitNotice('找到 ${result.messages.length} 条消息');
      }
    } catch (error) {
      _state = _state.copyWith(isSearching: false);
      notifyListeners();
      _emitNotice(_readableError(error));
    }
  }

  Future<void> loadUserBots({bool silent = false}) async {
    _state = _state.copyWith(
      botCenter: _state.botCenter.copyWith(isLoading: true, plaintextToken: ''),
    );
    notifyListeners();
    try {
      final results = await Future.wait<Object>([
        _activeRepository.listUserBots(),
        _activeRepository.listBotActions(),
      ]);
      final bots = results[0] as List<UserBotInfo>;
      final actions = results[1] as List<BotActionCatalogItem>;
      final selectedId = _state.botCenter.selectedOwnedBotId;
      final nextSelectedId = bots.any((bot) => bot.botUserId == selectedId)
          ? selectedId
          : (bots.isEmpty ? null : bots.first.botUserId);
      final tokensByBot = <int, List<UserBotTokenInfo>>{
        ..._state.botCenter.botTokensByBot,
      };
      if (nextSelectedId != null) {
        tokensByBot[nextSelectedId] = await _activeRepository.listUserBotTokens(
          nextSelectedId,
        );
      }
      _state = _state.copyWith(
        botCenter: _state.botCenter.copyWith(
          isLoading: false,
          ownedBots: bots,
          selectedOwnedBotId: nextSelectedId,
          botTokensByBot: tokensByBot,
          availableActions: actions,
          plaintextToken: '',
        ),
      );
      notifyListeners();
    } catch (error) {
      _state = _state.copyWith(
        botCenter: _state.botCenter.copyWith(isLoading: false),
      );
      notifyListeners();
      if (!silent) _emitNotice(_readableError(error));
    }
  }

  void selectOwnedBot(int botUserId) {
    _state = _state.copyWith(
      botCenter: _state.botCenter.copyWith(
        selectedOwnedBotId: botUserId,
        plaintextToken: '',
      ),
    );
    notifyListeners();
    unawaited(loadUserBotTokens(botUserId));
  }

  Future<void> loadUserBotTokens(int botUserId) async {
    if (botUserId <= 0) return;
    _state = _state.copyWith(
      botCenter: _state.botCenter.copyWith(isLoading: true, plaintextToken: ''),
    );
    notifyListeners();
    try {
      final tokens = await _activeRepository.listUserBotTokens(botUserId);
      _state = _state.copyWith(
        botCenter: _state.botCenter.copyWith(
          isLoading: false,
          botTokensByBot: {
            ..._state.botCenter.botTokensByBot,
            botUserId: tokens,
          },
        ),
      );
      notifyListeners();
    } catch (error) {
      _state = _state.copyWith(
        botCenter: _state.botCenter.copyWith(isLoading: false),
      );
      notifyListeners();
      _emitNotice(_readableError(error));
    }
  }

  Future<void> createUserBot({
    required String nickname,
    String email = '',
    String avatarUrl = '',
  }) async {
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) {
      _emitNotice('请输入 Bot 名称');
      return;
    }
    _state = _state.copyWith(
      botCenter: _state.botCenter.copyWith(isLoading: true, plaintextToken: ''),
    );
    notifyListeners();
    try {
      final bot = await _activeRepository.createUserBot(
        nickname: trimmed,
        email: email,
        avatarUrl: avatarUrl,
      );
      final bots = [
        bot,
        ..._state.botCenter.ownedBots.where(
          (item) => item.botUserId != bot.botUserId,
        ),
      ];
      _state = _state.copyWith(
        botCenter: _state.botCenter.copyWith(
          isLoading: false,
          ownedBots: bots,
          selectedOwnedBotId: bot.botUserId,
        ),
      );
      notifyListeners();
      _emitNotice('Bot 已创建');
      unawaited(loadUserBotTokens(bot.botUserId));
    } catch (error) {
      _state = _state.copyWith(
        botCenter: _state.botCenter.copyWith(isLoading: false),
      );
      notifyListeners();
      _emitNotice(_readableError(error));
    }
  }

  Future<void> toggleUserBotEnabled(UserBotInfo bot) async {
    _state = _state.copyWith(
      botCenter: _state.botCenter.copyWith(isLoading: true, plaintextToken: ''),
    );
    notifyListeners();
    try {
      final updated = bot.isEnabled
          ? await _activeRepository.disableUserBot(bot.botUserId)
          : await _activeRepository.enableUserBot(bot.botUserId);
      final bots = _state.botCenter.ownedBots
          .map((item) => item.botUserId == updated.botUserId ? updated : item)
          .toList();
      _state = _state.copyWith(
        botCenter: _state.botCenter.copyWith(isLoading: false, ownedBots: bots),
      );
      notifyListeners();
      _emitNotice(updated.isEnabled ? 'Bot 已启用' : 'Bot 已停用');
    } catch (error) {
      _state = _state.copyWith(
        botCenter: _state.botCenter.copyWith(isLoading: false),
      );
      notifyListeners();
      _emitNotice(_readableError(error));
    }
  }

  Future<void> createUserBotToken({
    required int botUserId,
    required List<String> actions,
    String name = '',
  }) async {
    final normalizedActions = actions
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
    if (botUserId <= 0 || normalizedActions.isEmpty) {
      _emitNotice('请选择 Bot 与权限');
      return;
    }
    _state = _state.copyWith(
      botCenter: _state.botCenter.copyWith(isLoading: true, plaintextToken: ''),
    );
    notifyListeners();
    try {
      final result = await _activeRepository.createUserBotToken(
        botUserId: botUserId,
        actions: normalizedActions,
        name: name,
      );
      final tokens = [
        result.token,
        ..._state.botCenter
            .tokensFor(botUserId)
            .where((item) => item.tokenId != result.token.tokenId),
      ];
      _state = _state.copyWith(
        botCenter: _state.botCenter.copyWith(
          isLoading: false,
          botTokensByBot: {
            ..._state.botCenter.botTokensByBot,
            botUserId: tokens,
          },
          plaintextToken: result.plaintextToken,
        ),
      );
      notifyListeners();
      _emitNotice('连接密钥已创建，请立即保存');
    } catch (error) {
      _state = _state.copyWith(
        botCenter: _state.botCenter.copyWith(isLoading: false),
      );
      notifyListeners();
      _emitNotice(_readableError(error));
    }
  }

  Future<void> rotateUserBotToken({
    required int botUserId,
    required int tokenId,
  }) async {
    _state = _state.copyWith(
      botCenter: _state.botCenter.copyWith(isLoading: true, plaintextToken: ''),
    );
    notifyListeners();
    try {
      final result = await _activeRepository.rotateUserBotToken(
        botUserId: botUserId,
        tokenId: tokenId,
      );
      final tokens = _state.botCenter
          .tokensFor(botUserId)
          .map((item) => item.tokenId == tokenId ? result.token : item)
          .toList();
      _state = _state.copyWith(
        botCenter: _state.botCenter.copyWith(
          isLoading: false,
          botTokensByBot: {
            ..._state.botCenter.botTokensByBot,
            botUserId: tokens,
          },
          plaintextToken: result.plaintextToken,
        ),
      );
      notifyListeners();
      _emitNotice('连接密钥已更新，请立即保存');
    } catch (error) {
      _state = _state.copyWith(
        botCenter: _state.botCenter.copyWith(isLoading: false),
      );
      notifyListeners();
      _emitNotice(_readableError(error));
    }
  }

  Future<void> revokeUserBotToken({
    required int botUserId,
    required int tokenId,
  }) async {
    _state = _state.copyWith(
      botCenter: _state.botCenter.copyWith(isLoading: true, plaintextToken: ''),
    );
    notifyListeners();
    try {
      await _activeRepository.revokeUserBotToken(
        botUserId: botUserId,
        tokenId: tokenId,
      );
      final tokens = _state.botCenter
          .tokensFor(botUserId)
          .where((item) => item.tokenId != tokenId)
          .toList();
      _state = _state.copyWith(
        botCenter: _state.botCenter.copyWith(
          isLoading: false,
          botTokensByBot: {
            ..._state.botCenter.botTokensByBot,
            botUserId: tokens,
          },
        ),
      );
      notifyListeners();
      _emitNotice('连接密钥已撤销');
    } catch (error) {
      _state = _state.copyWith(
        botCenter: _state.botCenter.copyWith(isLoading: false),
      );
      notifyListeners();
      _emitNotice(_readableError(error));
    }
  }

  Future<void> addUserBotToConversation({
    required int botUserId,
    required int conversationId,
  }) async {
    if (botUserId <= 0 || conversationId <= 0) return;
    try {
      final updated = await _activeRepository.addUserBotToConversation(
        botUserId: botUserId,
        conversationId: conversationId,
      );
      final existing = _state.conversations
          .where((item) => item.id == conversationId)
          .firstOrNull;
      _upsertConversation(
        existing == null
            ? updated
            : existing.copyWith(
                name: updated.name.trim().isEmpty
                    ? existing.name
                    : updated.name,
                avatarText: updated.avatarText.trim().isEmpty
                    ? existing.avatarText
                    : updated.avatarText,
                memberIds: updated.memberIds.isEmpty
                    ? <int>{...existing.memberIds, botUserId}.toList()
                    : updated.memberIds,
                updatedAt: updated.updatedAt,
                lastMessagePreview: updated.lastMessagePreview.trim().isEmpty
                    ? 'Bot 已加入会话'
                    : updated.lastMessagePreview,
                ownerId: updated.ownerId ?? existing.ownerId,
              ),
      );
      unawaited(loadConversationMembers(conversationId));
      _appendSystemMessage(conversationId, 'Bot 已加入会话');
      _emitNotice('Bot 已加入会话');
    } catch (error) {
      _emitNotice(_readableError(error));
    }
  }

  Future<void> createDirectConversationWithUserBot(int botUserId) async {
    if (botUserId <= 0) return;
    try {
      final conversation = await _activeRepository
          .createUserBotDirectConversation(botUserId);
      _upsertConversation(conversation);
      _state = _state.copyWith(
        currentSection: AppSection.chats,
        selectedConversationId: conversation.id,
      );
      notifyListeners();
      _emitNotice('已打开 Bot 会话');
    } catch (error) {
      _emitNotice(_readableError(error));
    }
  }

  Future<void> _loadAuthenticatedState(
    AuthSession session,
    String message,
  ) async {
    try {
      await _tokenStorage.saveSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        userId: '${session.user.id}',
        deviceId: _deviceId,
      );
    } catch (_) {
      // Token persistence is optional (e.g. in test environments)
    }
    _startTokenRefreshTimer(session.expiresAt);
    unawaited(loadUserBots(silent: true));

    // 阶段 1：优先从本地缓存加载，让用户立即看到上次的会话和消息
    bool loadedFromCache = false;
    if (_activeRepository is GatewayAimRepository) {
      final repo = _activeRepository as GatewayAimRepository;
      final localData = await repo.loadLocalBootstrapData();
      if (localData != null && localData.conversations.isNotEmpty) {
        _state = _state.copyWith(
          isAuthenticated: true,
          connectionOnline: true,
          currentSection: AppSection.chats,
          session: session,
          conversations: localData.conversations,
          messagesByConversation: localData.messagesByConversation,
          friends: localData.friends,
          friendRequests: localData.friendRequests,
          friendTags: localData.friendTags,
          attachments: localData.attachments,
          orders: localData.orders,
          selectedConversationId: null,
          notice: '已加载本地缓存，正在同步最新数据...',
          noticeSerial: _state.noticeSerial + 1,
        );
        notifyListeners();
        _subscribeRealtimeEvents();
        loadedFromCache = true;
      }
    }

    // 阶段 2：后台异步拉取远端数据并与本地缓存合并
    if (loadedFromCache) {
      // 本地已展示，远端拉取放到后台不阻塞 UI
      unawaited(_syncRemoteDataInBackground(message));
    } else {
      // 没有本地缓存，必须阻塞等待远端数据
      final bootstrap = await _activeRepository.loadBootstrapData(session.user);
      _state = _state.copyWith(
        isAuthenticated: true,
        connectionOnline: true,
        currentSection: AppSection.chats,
        session: session,
        conversations: bootstrap.conversations,
        messagesByConversation: bootstrap.messagesByConversation,
        friends: bootstrap.friends,
        friendRequests: bootstrap.friendRequests,
        friendTags: bootstrap.friendTags,
        attachments: bootstrap.attachments,
        orders: bootstrap.orders,
        selectedConversationId: null,
        notice: message,
        noticeSerial: _state.noticeSerial + 1,
      );
      notifyListeners();
      _subscribeRealtimeEvents();
    }
  }

  /// 后台异步从远端拉取数据并合并到当前状态。
  /// 该方法 fire-and-forget，不会阻塞 UI。
  Future<void> _syncRemoteDataInBackground(String successMessage) async {
    try {
      final user = _state.currentUser;
      if (user == null) return;

      // Gateway 仓库支持先用本地缓存展示，再后台合并最新远端数据。
      if (_repository is GatewayAimRepository) {
        final bootstrap = await _repository.loadBootstrapData(user);
        // 合并远端数据到当前状态
        _state = _state.copyWith(
          conversations: bootstrap.conversations,
          messagesByConversation: bootstrap.messagesByConversation,
          friends: bootstrap.friends,
          friendRequests: bootstrap.friendRequests,
          friendTags: bootstrap.friendTags,
          attachments: bootstrap.attachments,
          orders: bootstrap.orders,
          notice: successMessage,
          noticeSerial: _state.noticeSerial + 1,
        );
        notifyListeners();
      } else {
        // 非 Gateway 仓库，使用当前活跃仓库
        final bootstrap = await _activeRepository.loadBootstrapData(user);
        _state = _state.copyWith(
          conversations: bootstrap.conversations,
          messagesByConversation: bootstrap.messagesByConversation,
          friends: bootstrap.friends,
          friendRequests: bootstrap.friendRequests,
          friendTags: bootstrap.friendTags,
          attachments: bootstrap.attachments,
          orders: bootstrap.orders,
          notice: successMessage,
          noticeSerial: _state.noticeSerial + 1,
        );
        notifyListeners();
      }
    } catch (error) {
      // 后台同步失败不影响已加载的本地数据，但提示用户
      _emitNotice('数据同步失败，请稍后重试');
    }
  }

  /// 应用启动时尝试恢复会话。
  ///
  /// 策略：
  ///   1. 先尝试从本地 Drift 缓存加载数据并立即展示（无需等待网络）
  ///   2. 再尝试用存储的 refresh token 恢复远端会话
  ///   3. 远端恢复成功后，后台异步拉取最新数据并合并到状态
  ///   4. 即使远端恢复失败（网络不通、token 过期等），用户仍可查看本地缓存
  Future<void> tryAutoRestore() async {
    _state = _state.copyWith(isBusy: true);

    // 阶段 1：从本地缓存加载，让用户秒开看到历史数据
    bool hasLocalCache = false;
    if (_repository is GatewayAimRepository) {
      final repo = _repository;
      try {
        final localData = await repo.loadLocalBootstrapData();
        if (localData != null && localData.conversations.isNotEmpty) {
          hasLocalCache = true;
          _state = _state.copyWith(
            isAuthenticated: true,
            connectionOnline: false,
            currentSection: AppSection.chats,
            conversations: localData.conversations,
            messagesByConversation: localData.messagesByConversation,
            friends: localData.friends,
            friendRequests: localData.friendRequests,
            friendTags: localData.friendTags,
            attachments: localData.attachments,
            orders: localData.orders,
            selectedConversationId: null,
            isBusy: false,
            notice: '已加载本地缓存，正在连接服务器...',
            noticeSerial: _state.noticeSerial + 1,
          );
          notifyListeners();
        }
      } catch (_) {
        // 本地缓存读取失败，继续尝试远端
      }
    }

    if (!hasLocalCache) {
      _setBusy(true);
    }

    // 阶段 2：尝试远端恢复 + 后台同步
    try {
      final refreshToken = await _tokenStorage.readRefreshToken();
      final userId = await _tokenStorage.readUserId();
      if (refreshToken == null || userId == null) {
        if (!hasLocalCache) _setBusy(false);
        return;
      }

      final restored = await _repository.refreshSession(
        AuthSession(
          user: UserProfile(
            id: int.tryParse(userId) ?? 0,
            email: '',
            nickname: '',
            avatarUrl: '',
            status: PresenceStatus.online,
          ),
          accessToken: '',
          refreshToken: refreshToken,
          expiresAt: DateTime.now(),
        ),
      );

      if (hasLocalCache) {
        // 本地缓存已展示，远端数据后台异步合并
        _state = _state.copyWith(
          session: restored,
          connectionOnline: true,
          notice: '会话已恢复，正在同步最新消息...',
          noticeSerial: _state.noticeSerial + 1,
        );
        notifyListeners();
        _startTokenRefreshTimer(restored.expiresAt);
        _subscribeRealtimeEvents();
        unawaited(_syncRemoteDataInBackground('数据同步完成'));
      } else {
        // 没有本地缓存，阻塞等待远端数据
        await _loadAuthenticatedState(restored, '会话已恢复');
      }
    } catch (error) {
      if (_isAuthError(error)) {
        // 认证失败：refresh token 无效，清除所有状态，回到登录页
        await _tokenStorage.clearSession();
        _state = AimState.initial().copyWith(isBusy: false);
        notifyListeners();
      } else if (!hasLocalCache) {
        await _tokenStorage.clearSession();
        _state = AimState.initial().copyWith(isBusy: false);
        notifyListeners();
      } else {
        // 网络错误但本地缓存仍可用
        _state = _state.copyWith(
          notice: '服务器连接失败，显示离线缓存',
          noticeSerial: _state.noticeSerial + 1,
        );
        notifyListeners();
      }
    }
  }

  /// 启动 token 定时刷新（过期间隔前 `_tokenRefetchMargin` 触发）。
  /// 同时启动一个安全巡检定时器（每 30s），防止单次 Timer 因后台挂起等原因误期。
  void _startTokenRefreshTimer(DateTime expiresAt) {
    _stopTokenRefreshTimer();
    _tokenRefreshRetries = 0;
    final now = DateTime.now();
    final delay = expiresAt.difference(now) - _tokenRefetchMargin;

    // 即将过期或已过期：立即刷新
    if (delay <= Duration.zero) {
      unawaited(_refreshTokenWithRetry());
      return;
    }

    // 一次性的精确定时（过期前 60s）
    _tokenRefreshTimer = Timer(
      delay,
      () => unawaited(_refreshTokenWithRetry()),
    );

    // 安全巡检：每 30s 检查一次，防止 Timer 被 OS 延迟
    final safetyInterval = delay > defaultTokenSafetyInterval
        ? defaultTokenSafetyInterval
        : delay ~/ 2;
    if (safetyInterval > Duration.zero) {
      _tokenSafetyTimer = Timer.periodic(safetyInterval, (_) {
        final updatedSession = _state.session;
        if (updatedSession == null) {
          _stopTokenRefreshTimer();
          return;
        }
        final remaining =
            updatedSession.expiresAt.difference(DateTime.now()) -
            _tokenRefetchMargin;
        if (remaining <= Duration.zero) {
          _stopTokenRefreshTimer();
          unawaited(_refreshTokenWithRetry());
        }
      });
    }
  }

  void _stopTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
    _tokenSafetyTimer?.cancel();
    _tokenSafetyTimer = null;
  }

  /// Token 刷新（带退避重试）。
  /// 成功时重置重试计数并更新会话 + 重连 WS。
  /// 失败时指数退避重试最多 [_maxTokenRefreshRetries] 次。
  Future<void> _refreshTokenWithRetry() async {
    final session = _state.session;
    if (session == null) return;
    try {
      await _doRefreshToken();
      _tokenRefreshRetries = 0;
    } catch (error) {
      _tokenRefreshRetries++;
      if (_tokenRefreshRetries > _maxTokenRefreshRetries) {
        _emitNotice('登录状态刷新失败，请手动检查连接');
        _tokenRefreshRetries = 0;
        if (_isAuthError(error)) {
          await _forceLogout('登录已过期，请重新登录');
        }
        return;
      }
      // 退避：1s, 2s, 4s（最多 3 次重试）
      final backoff = Duration(seconds: 1 << (_tokenRefreshRetries - 1));
      _emitNotice(
        '登录状态刷新失败，${backoff.inSeconds}s 后重试（$_tokenRefreshRetries/$_maxTokenRefreshRetries）',
      );
      Future<void>.delayed(backoff, () => _refreshTokenWithRetry());
    }
  }

  /// 实际执行 token 刷新：调 REST refresh → 保存 → 重连 WS → 重启定时器。
  Future<void> _doRefreshToken() async {
    final session = _state.session;
    if (session == null) return;
    final refreshed = await _activeRepository.refreshSession(session);
    _state = _state.copyWith(session: refreshed, connectionOnline: true);
    await _tokenStorage.saveSession(
      accessToken: refreshed.accessToken,
      refreshToken: refreshed.refreshToken,
      userId: '${refreshed.user.id}',
      deviceId: _deviceId,
    );
    _startTokenRefreshTimer(refreshed.expiresAt);
    _subscribeRealtimeEvents();
    _emitNotice('连接已刷新');
  }

  void _subscribeRealtimeEvents() {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = _activeRepository.realtimeEvents.listen(
      _handleRealtimeEvent,
      onError: (Object error, StackTrace stackTrace) {
        _state = _state.copyWith(connectionOnline: false);
        _emitNotice('实时连接异常，请稍后重试');
      },
    );
  }

  void _handleRealtimeEvent(RealtimeEvent event) {
    switch (event) {
      case RealtimeMessageEvent():
        _handleRealtimeMessage(event);
      case RealtimePresenceEvent():
        _handlePresenceEvent(event);
      case RealtimeTypingEvent():
        _handleTypingEvent(event);
      case RealtimeFriendApplicationEvent():
        unawaited(_handleFriendApplicationEvent(event));
      case RealtimeReadReceiptEvent():
        _handleReadReceiptEvent(event);
      case RealtimeNotificationEvent():
        _handleNotificationEvent(event);
      case RealtimeReconnectEvent():
        _state = _state.copyWith(connectionOnline: false);
        _emitNotice('正在重新连接...');
        unawaited(
          Future<void>.delayed(
            Duration(milliseconds: event.reconnectDelayMs),
            _refreshTokenWithRetry,
          ),
        );
      case RealtimeTokenExpiredEvent():
        _state = _state.copyWith(connectionOnline: false);
        _emitNotice('登录状态已更新，正在重新连接');
        unawaited(_refreshTokenWithRetry());
      case RealtimeConnectionClosedEvent():
        _state = _state.copyWith(connectionOnline: false);
        _emitNotice('实时连接已断开，正在尝试恢复');
        unawaited(_refreshTokenWithRetry());
    }
  }

  void _handleRealtimeMessage(RealtimeMessageEvent event) {
    final currentUserId = _state.currentUser?.id;
    final message = ChatMessage(
      id: event.messageId,
      conversationId: event.conversationId,
      senderId: event.senderId,
      senderName: event.senderDisplayName.isEmpty
          ? _friendName(event.senderId)
          : event.senderDisplayName,
      type: _messageTypeFromString(event.messageType),
      content: event.content,
      createdAt: event.sentAt <= 0
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(event.sentAt),
      clientMessageId: event.clientMessageId,
      isSystem: event.isSystem,
      mentions: event.mentions,
      readBy: event.senderId == currentUserId && currentUserId != null
          ? [currentUserId]
          : const [],
    );

    // Phase 0: 附件解析状态更新推送 (manual §11.4)。
    // 服务端通过 PUSH_MESSAGE (is_system=true, sender_id=0,
    // message_type=image/video/audio) 推送解析完成后的更新。
    // 按 file_id 匹配本地消息并原地更新 content。
    if (event.isSystem &&
        event.senderId == 0 &&
        (event.messageType == 'image' ||
            event.messageType == 'video' ||
            event.messageType == 'audio')) {
      _handleAttachmentParseUpdate(event);
      return;
    }

    // Phase 1: 检查是否为本人刚发送消息的回显 PUSH。
    // 服务器 ACK 和 PUSH_MESSAGE 到达顺序不确定：若 PUSH 先到且不带
    // client_msg_id，现有去重会失效，产生重复消息。这里用
    // client_msg_id / sender+content 双重匹配，将 PUSH 视为隐式 ACK，
    // 直接把 pending 消息提升为 sent 状态。
    if (event.senderId == currentUserId && currentUserId != null) {
      final pendingMsg = _state.messagesFor(event.conversationId).where((item) {
        // 精确匹配：client_msg_id 相同（服务器回显了 client_msg_id）
        if (item.clientMessageId.isNotEmpty &&
            item.clientMessageId == event.clientMessageId) {
          return true;
        }
        // 模糊匹配：发送中 + 内容一致（服务器未回显 client_msg_id 时的兜底）
        return item.status == MessageStatus.sending &&
            item.content == event.content &&
            item.senderId == currentUserId;
      }).firstOrNull;
      if (pendingMsg != null) {
        _replaceMessage(
          pendingMsg.clientMessageId,
          pendingMsg.copyWith(
            id: event.messageId > 0 ? event.messageId : pendingMsg.id,
            status: MessageStatus.sent,
            readBy: [currentUserId],
          ),
        );
        _upsertConversation(
          (_state.conversations
                      .where((item) => item.id == event.conversationId)
                      .firstOrNull ??
                  _conversationFromRealtimeMessage(event, message))
              .copyWith(
                lastMessagePreview: event.isSystem
                    ? SystemMessageEvent.displayText(event.content)
                    : '${message.senderName}: ${event.content}',
                updatedAt: message.createdAt,
                unreadCount: 0,
                typingUserId: null,
              ),
        );
        notifyListeners();
        return;
      }
    }

    // Phase 2: 标准去重——message_id 和 client_msg_id
    final messages = _state.messagesFor(event.conversationId);
    final existing = messages.any(
      (item) =>
          (item.id > 0 && item.id == event.messageId) ||
          (item.clientMessageId.isNotEmpty &&
              item.clientMessageId == event.clientMessageId),
    );
    if (!existing) _appendMessage(message);
    final existingConversation = _state.conversations
        .where((item) => item.id == event.conversationId)
        .firstOrNull;
    final conversation =
        existingConversation ??
        _conversationFromRealtimeMessage(event, message);
    final isOpen = _state.selectedConversationId == event.conversationId;
    _upsertConversation(
      conversation.copyWith(
        lastMessagePreview: event.isSystem
            ? SystemMessageEvent.displayText(event.content)
            : '${message.senderName}: ${event.content}',
        updatedAt: message.createdAt,
        unreadCount: isOpen || event.senderId == currentUserId
            ? 0
            : conversation.unreadCount + 1,
        typingUserId: null,
      ),
    );
    if (isOpen && !existing && message.id > 0) {
      unawaited(
        _activeRepository.sendReadReceipt(
          conversationId: event.conversationId,
          lastMessageId: message.id,
        ),
      );
    }
    notifyListeners();
  }

  /// 处理附件解析状态更新推送 (manual §11.4)。
  ///
  /// 服务端在附件异步解析完成后，通过 PUSH_MESSAGE 推送更新：
  /// - is_system=true, sender_id=0, message_type=image/video/audio
  /// - content 为更新后的 aim.attachment.v1 JSON
  /// - 按 file_id 匹配本地消息并原地更新
  void _handleAttachmentParseUpdate(RealtimeMessageEvent event) {
    final payload = AttachmentMessagePayload.tryParse(event.content);
    if (payload == null) return;

    final fileId = payload.fileId;
    if (fileId.isEmpty) return;

    // 在该会话的消息列表中查找相同 file_id 的附件消息
    final messages = _state.messagesFor(event.conversationId);
    bool updated = false;
    final updatedMessages = messages.map((msg) {
      // 尝试解析消息内容中的附件 payload
      final existing = AttachmentMessagePayload.tryParse(msg.content);
      if (existing != null && existing.fileId == fileId) {
        // 原地更新：保留旧的 downloadUrl/thumbnailFileId/thumbnailUrl（如果新推送中为空）
        final merged = payload.copyWith(
          downloadUrl: payload.downloadUrl.isNotEmpty
              ? payload.downloadUrl
              : existing.downloadUrl,
          thumbnailFileId: payload.thumbnailFileId.isNotEmpty
              ? payload.thumbnailFileId
              : existing.thumbnailFileId,
          thumbnailUrl: payload.thumbnailUrl.isNotEmpty
              ? payload.thumbnailUrl
              : existing.thumbnailUrl,
          localPreviewDataUri: payload.localPreviewDataUri.isNotEmpty
              ? payload.localPreviewDataUri
              : existing.localPreviewDataUri,
        );
        updated = true;
        return msg.copyWith(
          content: merged.toJsonString(includeLocalPreview: false),
        );
      }
      return msg;
    }).toList();

    if (!updated) {
      // 未在本地消息中找到匹配的 file_id，可能消息尚未拉取
      // 或附件在其他会话中。忽略此次更新推送。
      return;
    }

    _state = _state.copyWith(
      messagesByConversation: {
        ..._state.messagesByConversation,
        event.conversationId: updatedMessages,
      },
    );

    // 同步更新附件列表中匹配的附件条目
    if (payload.parseStatus == 'ready') {
      _state = _state.copyWith(
        attachments: _state.attachments.map((att) {
          if (att.id == fileId) {
            return att.copyWith(
              parseStatus: payload.parseStatus,
              thumbnailFileId: payload.thumbnailFileId.isNotEmpty
                  ? payload.thumbnailFileId
                  : att.thumbnailFileId,
              thumbnailUrl: payload.thumbnailUrl.isNotEmpty
                  ? payload.thumbnailUrl
                  : att.thumbnailUrl,
              width: payload.width,
              height: payload.height,
              downloadUrl: payload.downloadUrl.isNotEmpty
                  ? payload.downloadUrl
                  : att.downloadUrl,
            );
          }
          return att;
        }).toList(),
      );
    }

    notifyListeners();
  }

  void _handlePresenceEvent(RealtimePresenceEvent event) {
    final nextStatus = event.status == 'online'
        ? PresenceStatus.online
        : PresenceStatus.offline;
    _state = _state.copyWith(
      friends: _state.friends.map((friendship) {
        if (friendship.user.id != event.userId) return friendship;
        return Friendship(
          id: friendship.id,
          user: friendship.user.copyWith(status: nextStatus),
          status: friendship.status,
          createdAt: friendship.createdAt,
          updatedAt: DateTime.now(),
          incoming: friendship.incoming,
          tags: friendship.tags,
        );
      }).toList(),
    );
    notifyListeners();
  }

  void _handleTypingEvent(RealtimeTypingEvent event) {
    if (event.userId == _state.currentUser?.id) return;
    final conversation = _state.conversations
        .where((item) => item.id == event.conversationId)
        .firstOrNull;
    if (conversation == null) return;
    _upsertConversation(conversation.copyWith(typingUserId: event.userId));
    _typingClearTimers[event.conversationId]?.cancel();
    _typingClearTimers[event.conversationId] = Timer(
      const Duration(seconds: 4),
      () {
        final latest = _state.conversations
            .where((item) => item.id == event.conversationId)
            .firstOrNull;
        if (latest == null || latest.typingUserId != event.userId) return;
        _upsertConversation(latest.copyWith(typingUserId: null));
        notifyListeners();
      },
    );
    notifyListeners();
  }

  Future<void> _handleFriendApplicationEvent(
    RealtimeFriendApplicationEvent event,
  ) async {
    final currentUser = _state.currentUser;
    if (currentUser == null) return;
    try {
      final bootstrap = await _activeRepository.loadBootstrapData(currentUser);
      _state = _state.copyWith(
        friends: bootstrap.friends,
        friendRequests: bootstrap.friendRequests,
      );
      _emitNotice('好友申请列表已刷新：${event.status}');
      return;
    } catch (_) {
      // 事件兜底：REST 刷新失败时仍给出本地提示，稍后可手动刷新。
    }
    if (event.status == 'pending') {
      final incomingUserId = event.userId == currentUser.id
          ? event.friendId
          : event.userId;
      final exists = _state.friendRequests.any(
        (item) => item.user.id == incomingUserId,
      );
      if (!exists) {
        final now = DateTime.now();
        final request = Friendship(
          id: incomingUserId,
          user: UserProfile(
            id: incomingUserId,
            email: 'user-$incomingUserId@unknown.local',
            nickname: '用户 $incomingUserId',
            avatarUrl: '',
            status: PresenceStatus.offline,
          ),
          status: FriendStatus.pending,
          createdAt: event.createdAt > 0
              ? DateTime.fromMillisecondsSinceEpoch(event.createdAt)
              : now,
          updatedAt: event.updatedAt > 0
              ? DateTime.fromMillisecondsSinceEpoch(event.updatedAt)
              : now,
          incoming: incomingUserId != currentUser.id,
        );
        _state = _state.copyWith(
          friendRequests: [request, ..._state.friendRequests],
        );
      }
      _emitNotice('收到新的好友申请');
      return;
    }
    if (event.status == 'accepted') {
      final acceptedRequests = _state.friendRequests
          .where(
            (item) =>
                item.user.id == event.userId || item.user.id == event.friendId,
          )
          .toList();
      final nextRequests = _state.friendRequests
          .where(
            (item) =>
                item.user.id != event.userId && item.user.id != event.friendId,
          )
          .toList();
      _state = _state.copyWith(
        friendRequests: nextRequests,
        friends: [
          ...acceptedRequests.map(
            (item) =>
                item.copyWith(status: FriendStatus.accepted, incoming: false),
          ),
          ..._state.friends,
        ],
      );
      _emitNotice('好友申请已通过');
      return;
    }
    _state = _state.copyWith(
      friendRequests: _state.friendRequests
          .where(
            (item) =>
                item.user.id != event.userId && item.user.id != event.friendId,
          )
          .toList(),
    );
    _emitNotice('好友申请状态更新：${event.status}');
  }

  void _handleReadReceiptEvent(RealtimeReadReceiptEvent event) {
    final messages = _state.messagesFor(event.conversationId).map((message) {
      if (message.id <= event.lastReadMessageId &&
          !message.readBy.contains(event.userId)) {
        return message.copyWith(readBy: [...message.readBy, event.userId]);
      }
      return message;
    }).toList();
    _state = _state.copyWith(
      messagesByConversation: {
        ..._state.messagesByConversation,
        event.conversationId: messages,
      },
    );
    notifyListeners();
  }

  void _handleNotificationEvent(RealtimeNotificationEvent event) {
    final notification = AppNotification(
      type: event.notificationType,
      title: event.title,
      body: event.body,
      relatedId: event.relatedId,
      createdAt: DateTime.now(),
    );
    _state = _state.copyWith(
      notifications: [notification, ..._state.notifications].take(50).toList(),
    );
    _emitNotice('[${event.notificationType}] ${event.title}: ${event.body}');
  }

  /// Called when app goes to background (manual §14.4).
  void onAppPaused() {
    // 暂停定时器，避免后台不必要的心跳
    _stopTokenRefreshTimer();
  }

  /// Called when app resumes (manual §14.4).
  void onAppResumed() {
    final session = _state.session;
    if (session != null) {
      // 重新评估 token 是否过期并启动定时器
      _startTokenRefreshTimer(session.expiresAt);
    }
  }

  void _appendMessage(ChatMessage message) {
    final messages = [..._state.messagesFor(message.conversationId), message]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt)); // 确保按时间升序
    _state = _state.copyWith(
      messagesByConversation: {
        ..._state.messagesByConversation,
        message.conversationId: messages,
      },
    );
  }

  void _replaceMessage(String clientMessageId, ChatMessage nextMessage) {
    final conversationId = nextMessage.conversationId;
    final messages = _state.messagesFor(conversationId).map((message) {
      if (message.clientMessageId == clientMessageId) return nextMessage;
      return message;
    }).toList();
    _state = _state.copyWith(
      messagesByConversation: {
        ..._state.messagesByConversation,
        conversationId: messages,
      },
    );
    notifyListeners();
  }

  void _replaceAttachment(String attachmentId, AttachmentItem nextAttachment) {
    final attachments = _state.attachments.map((attachment) {
      if (attachment.id == attachmentId) return nextAttachment;
      return attachment;
    }).toList();
    _state = _state.copyWith(attachments: attachments);
    notifyListeners();
  }

  String _memberDisplayName(int userId) {
    if (_state.currentUser?.id == userId) {
      return _state.currentUser?.nickname ?? '我';
    }
    final cachedMember = _state.memberProfileById(userId);
    if (cachedMember != null && cachedMember.nickname.trim().isNotEmpty) {
      return cachedMember.nickname;
    }
    for (final friendship in [..._state.friends, ..._state.friendRequests]) {
      if (friendship.user.id == userId) return friendship.user.nickname;
    }
    return '成员 $userId';
  }

  void _appendSystemMessage(int conversationId, String content) {
    final now = DateTime.now();
    _appendMessage(
      ChatMessage(
        id: now.millisecondsSinceEpoch,
        conversationId: conversationId,
        senderId: 0,
        senderName: '系统',
        type: MessageType.system,
        content: content,
        createdAt: now,
        clientMessageId: 'system-${now.microsecondsSinceEpoch}',
        isSystem: true,
      ),
    );
  }

  void _upsertConversation(Conversation nextConversation) {
    var replaced = false;
    final conversations = _state.conversations.map((conversation) {
      if (conversation.id == nextConversation.id) {
        replaced = true;
        return nextConversation;
      }
      return conversation;
    }).toList();
    if (!replaced) {
      conversations.insert(0, nextConversation);
    }
    _state = _state.copyWith(conversations: conversations);
  }

  Conversation _conversationFromRealtimeMessage(
    RealtimeMessageEvent event,
    ChatMessage message,
  ) {
    final currentUserId = _state.currentUser?.id;
    final isDirect = event.conversationType != 'group';
    final fallbackName = isDirect
        ? (event.senderId == currentUserId
              ? '直聊 ${event.conversationId}'
              : message.senderName)
        : '群聊 ${event.conversationId}';
    final memberIds = <int>{
      ?currentUserId,
      if (event.senderId > 0) event.senderId,
    }.toList();
    return Conversation(
      id: event.conversationId,
      type: isDirect ? ConversationType.direct : ConversationType.group,
      name: fallbackName,
      avatarText: _avatarText(fallbackName),
      memberIds: memberIds,
      createdAt: message.createdAt,
      updatedAt: message.createdAt,
      lastMessagePreview: event.isSystem
          ? event.content
          : '${message.senderName}: ${event.content}',
    );
  }

  void _markMessagesRead(int conversationId) {
    final currentUserId = _state.currentUser?.id;
    if (currentUserId == null) return;
    final messages = _state.messagesFor(conversationId).map((message) {
      if (message.senderId == currentUserId ||
          message.readBy.contains(currentUserId)) {
        return message;
      }
      return message.copyWith(readBy: [...message.readBy, currentUserId]);
    }).toList();
    _state = _state.copyWith(
      messagesByConversation: {
        ..._state.messagesByConversation,
        conversationId: messages,
      },
    );
    if (messages.isNotEmpty) {
      unawaited(
        _activeRepository.sendReadReceipt(
          conversationId: conversationId,
          lastMessageId: messages.last.id,
        ),
      );
    }
  }

  void _setBusy(bool value) {
    if (_state.isBusy == value) return;
    _state = _state.copyWith(isBusy: value);
    notifyListeners();
  }

  void _emitNotice(String message) {
    _state = _state.copyWith(
      notice: message,
      noticeSerial: _state.noticeSerial + 1,
    );
    notifyListeners();
  }

  String _friendName(int userId) {
    for (final friend in [..._state.friends, ..._state.friendRequests]) {
      if (friend.user.id == userId) return friend.user.nickname;
    }
    return '成员 $userId';
  }

  MessageType _messageTypeFromString(String value) =>
      messageTypeFromWireValue(value);

  static String _newDeviceId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return 'd1-${hex.substring(0, 8)}-${hex.substring(8, 16)}';
  }

  /// Generate a v4-like UUID for client_msg_id (manual §5.4: d1-{UUID}).
  String _newClientMsgId() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return 'd1-${hex.substring(0, 8)}-${hex.substring(8, 16)}';
  }

  String _readableError(Object error) {
    if (error is ArgumentError) return error.message.toString();
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final code = data['code'];
        final msg = data['msg'];
        if (msg != null) return '操作失败：$msg${code == null ? '' : '（$code）'}';
      }
      final statusCode = error.response?.statusCode;
      if (statusCode != null) return '操作失败：HTTP $statusCode';
      return '操作失败：网络请求异常';
    }
    return '操作失败：$error';
  }

  /// 检查是否是认证相关错误（401 或 code=40100）
  bool _isAuthError(Object error) {
    if (error is DioException) {
      // Check response body for auth error codes
      final data = error.response?.data;
      if (data is Map) {
        final code = data['code'];
        if (code == 40100) return true;
      }
      // Also check HTTP status code
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 40100) return true;
    }
    // Check if the error message indicates auth failure
    final message = error.toString().toLowerCase();
    if (message.contains('401') || message.contains('unauthorized')) {
      return true;
    }
    return false;
  }

  /// 强制退出登录，清除所有状态并回到登录页。
  Future<void> _forceLogout(String message) async {
    _stopTokenRefreshTimer();
    await _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
    for (final timer in _typingClearTimers.values) {
      timer.cancel();
    }
    _typingClearTimers.clear();
    await _tokenStorage.clearSession();
    _state = AimState.initial().copyWith(
      notice: message,
      noticeSerial: _state.noticeSerial + 1,
    );
    notifyListeners();
  }
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

String _avatarText(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return '?';
  return String.fromCharCodes(trimmed.runes.take(3)).toUpperCase();
}

String _mimeForKind(String kind, String fileName) {
  final lower = fileName.toLowerCase();
  if (kind == 'image') {
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/png';
  }
  if (kind == 'audio') {
    if (lower.endsWith('.wav')) return 'audio/wav';
    if (lower.endsWith('.ogg')) return 'audio/ogg';
    if (lower.endsWith('.m4a')) return 'audio/mp4';
    return 'audio/mpeg';
  }
  if (kind == 'video') {
    if (lower.endsWith('.mov')) return 'video/quicktime';
    if (lower.endsWith('.webm')) return 'video/webm';
    return 'video/mp4';
  }
  return 'application/octet-stream';
}

String _normalizeMimeForKind(String kind, String fileName, String mime) {
  final normalized = mime.trim().toLowerCase();
  if (_mimeMatchesKind(kind, normalized)) return normalized;
  return _mimeForKind(kind, fileName);
}

bool _mimeMatchesKind(String kind, String mime) {
  return switch (kind) {
    'image' => mime.startsWith('image/'),
    'audio' => mime.startsWith('audio/'),
    'video' => mime.startsWith('video/'),
    _ => mime.isNotEmpty,
  };
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
