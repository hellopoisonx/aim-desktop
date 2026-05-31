import 'dart:convert';

enum AuthMode { login, register }

enum AppSection {
  chats,
  profile,
  friends,
  friendRequests,
  groups,
  bots,
  attachments,
  services,
  settings,
  feedback,
}

enum ConversationType { direct, group }

enum MessageType { text, image, video, audio, file, system }

enum MessageStatus { received, sending, sent, failed }

MessageType messageTypeFromWireValue(String value) {
  return switch (value) {
    'image' => MessageType.image,
    'video' => MessageType.video,
    'audio' => MessageType.audio,
    'file' => MessageType.file,
    'system' => MessageType.system,
    _ => MessageType.text,
  };
}

String messageTypeToWireValue(MessageType type) {
  return switch (type) {
    MessageType.image => 'image',
    MessageType.video => 'video',
    MessageType.audio => 'audio',
    MessageType.file => 'file',
    MessageType.system => 'system',
    MessageType.text => 'text',
  };
}

MessageType messageTypeFromAttachmentKind({
  required String kind,
  String mime = '',
}) {
  final normalizedKind = kind.trim().toLowerCase();
  final normalizedMime = mime.trim().toLowerCase();
  return switch (normalizedKind) {
    'image' => MessageType.image,
    'video' => MessageType.video,
    'audio' => MessageType.audio,
    'file' => MessageType.file,
    _ when normalizedMime.startsWith('image/') => MessageType.image,
    _ when normalizedMime.startsWith('video/') => MessageType.video,
    _ when normalizedMime.startsWith('audio/') => MessageType.audio,
    _ => MessageType.file,
  };
}

MessageType messageTypeFromAttachmentPayload(AttachmentMessagePayload payload) {
  return messageTypeFromAttachmentKind(kind: payload.kind, mime: payload.mime);
}

enum FriendStatus { pending, accepted, rejected }

enum PresenceStatus { online, offline }

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.nickname,
    required this.avatarUrl,
    required this.status,
    this.bio = '',
  });

  final int id;
  final String email;
  final String nickname;
  final String avatarUrl;
  final PresenceStatus status;
  final String bio;

  String get initials {
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) return '?';
    final codes = trimmed.runes.take(2).toList();
    return String.fromCharCodes(codes).toUpperCase();
  }

  UserProfile copyWith({
    String? email,
    String? nickname,
    String? avatarUrl,
    PresenceStatus? status,
    String? bio,
  }) {
    return UserProfile(
      id: id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      bio: bio ?? this.bio,
    );
  }
}

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  final UserProfile user;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
}

class Conversation {
  const Conversation({
    required this.id,
    required this.type,
    required this.name,
    required this.avatarText,
    required this.memberIds,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessagePreview = '',
    this.unreadCount = 0,
    this.typingUserId,
    this.isMuted = false,
    this.isPinned = false,
    this.isActive = true,
    this.ownerId,
  });

  final int id;
  final ConversationType type;
  final String name;
  final String avatarText;
  final List<int> memberIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String lastMessagePreview;
  final int unreadCount;
  final int? typingUserId;
  final bool isMuted;
  final bool isPinned;
  final bool isActive;
  final int? ownerId;

  String get typeLabel => type == ConversationType.group ? '群聊' : '直聊';

  Conversation copyWith({
    ConversationType? type,
    String? name,
    String? avatarText,
    List<int>? memberIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessagePreview,
    int? unreadCount,
    Object? typingUserId = _unset,
    bool? isMuted,
    bool? isPinned,
    bool? isActive,
    int? ownerId,
  }) {
    return Conversation(
      id: id,
      type: type ?? this.type,
      name: name ?? this.name,
      avatarText: avatarText ?? this.avatarText,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      unreadCount: unreadCount ?? this.unreadCount,
      typingUserId: typingUserId == _unset
          ? this.typingUserId
          : typingUserId as int?,
      isMuted: isMuted ?? this.isMuted,
      isPinned: isPinned ?? this.isPinned,
      isActive: isActive ?? this.isActive,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.type,
    required this.content,
    required this.createdAt,
    required this.clientMessageId,
    this.status = MessageStatus.received,
    this.isSystem = false,
    this.mentions = const [],
    this.readBy = const [],
  });

  final int id;
  final int conversationId;
  final int senderId;
  final String senderName;
  final MessageType type;
  final String content;
  final DateTime createdAt;
  final String clientMessageId;
  final MessageStatus status;
  final bool isSystem;
  final List<String> mentions;
  final List<int> readBy;

  bool get isPending => status == MessageStatus.sending;
  bool get isFailed => status == MessageStatus.failed;

  ChatMessage copyWith({
    int? id,
    String? content,
    MessageStatus? status,
    List<String>? mentions,
    List<int>? readBy,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      type: type,
      content: content ?? this.content,
      createdAt: createdAt,
      clientMessageId: clientMessageId,
      status: status ?? this.status,
      isSystem: isSystem,
      mentions: mentions ?? this.mentions,
      readBy: readBy ?? this.readBy,
    );
  }
}

class FriendTag {
  const FriendTag({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int userId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  FriendTag copyWith({String? name, DateTime? updatedAt}) {
    return FriendTag(
      id: id,
      userId: userId,
      name: name ?? this.name,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Friendship {
  const Friendship({
    required this.id,
    required this.user,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.incoming = false,
    this.tags = const [],
  });

  /// 对端用户 ID（好友申请接口不返回单独关系 ID，客户端以对端用户 ID 作为操作标识）。
  final int id;
  final UserProfile user;
  final FriendStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool incoming;
  final List<FriendTag> tags;

  Friendship copyWith({
    FriendStatus? status,
    bool? incoming,
    List<FriendTag>? tags,
    DateTime? updatedAt,
  }) {
    return Friendship(
      id: id,
      user: user,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      incoming: incoming ?? this.incoming,
      tags: tags ?? this.tags,
    );
  }
}

class AttachmentItem {
  const AttachmentItem({
    required this.id,
    required this.conversationId,
    required this.kind,
    required this.name,
    required this.sizeLabel,
    required this.status,
    this.mime = 'application/octet-stream',
    this.sizeBytes = 0,
    this.parseStatus = '',
    this.downloadUrl = '',
    this.thumbnailFileId = '',
    this.thumbnailUrl = '',
    this.localPreviewDataUri = '',
    this.width,
    this.height,
    this.durationMs,
    this.createdAt,
  });

  final String id;
  final int conversationId;
  final String kind;
  final String name;
  final String sizeLabel;
  final String status;
  final String mime;
  final int sizeBytes;
  final String parseStatus;
  final String downloadUrl;

  /// 缩略图 object_key / file_id，用于通过附件下载接口换取临时 URL。
  final String thumbnailFileId;

  /// 缩略图临时下载 URL（有有效期，可为空）。
  final String thumbnailUrl;
  final String localPreviewDataUri;
  final int? width;
  final int? height;
  final int? durationMs;
  final DateTime? createdAt;

  bool get isImage => kind == 'image' || mime.startsWith('image/');
  bool get isAudio => kind == 'audio' || mime.startsWith('audio/');
  bool get isVideo => kind == 'video' || mime.startsWith('video/');

  String get displayKind {
    if (isImage) return '图片';
    if (isAudio) return '音频';
    if (isVideo) return '视频';
    return '附件';
  }

  AttachmentItem copyWith({
    String? id,
    int? conversationId,
    String? kind,
    String? name,
    String? sizeLabel,
    String? status,
    String? mime,
    int? sizeBytes,
    String? parseStatus,
    String? downloadUrl,
    String? thumbnailFileId,
    String? thumbnailUrl,
    String? localPreviewDataUri,
    int? width,
    int? height,
    int? durationMs,
    DateTime? createdAt,
  }) {
    return AttachmentItem(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      sizeLabel: sizeLabel ?? this.sizeLabel,
      status: status ?? this.status,
      mime: mime ?? this.mime,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      parseStatus: parseStatus ?? this.parseStatus,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      thumbnailFileId: thumbnailFileId ?? this.thumbnailFileId,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      localPreviewDataUri: localPreviewDataUri ?? this.localPreviewDataUri,
      width: width ?? this.width,
      height: height ?? this.height,
      durationMs: durationMs ?? this.durationMs,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  AttachmentMessagePayload toMessagePayload({
    String? localPreviewDataUri,
    String? status,
  }) {
    return AttachmentMessagePayload(
      fileId: id,
      conversationId: conversationId,
      kind: kind,
      name: name,
      mime: mime,
      sizeBytes: sizeBytes,
      sizeLabel: sizeLabel,
      status: status ?? this.status,
      parseStatus: parseStatus,
      downloadUrl: downloadUrl,
      thumbnailFileId: thumbnailFileId,
      thumbnailUrl: thumbnailUrl,
      localPreviewDataUri: localPreviewDataUri ?? this.localPreviewDataUri,
      width: width,
      height: height,
      durationMs: durationMs,
    );
  }

  String toMessageContent({String? localPreviewDataUri, String? status}) {
    return toMessagePayload(
      localPreviewDataUri: localPreviewDataUri,
      status: status,
    ).toJsonString();
  }
}

class AttachmentMessagePayload {
  const AttachmentMessagePayload({
    required this.fileId,
    required this.conversationId,
    required this.kind,
    required this.name,
    required this.mime,
    required this.sizeBytes,
    required this.sizeLabel,
    required this.status,
    this.schema = 'aim.attachment.v1',
    this.parseStatus = '',
    this.downloadUrl = '',
    this.thumbnailFileId = '',
    this.thumbnailUrl = '',
    this.localPreviewDataUri = '',
    this.width,
    this.height,
    this.durationMs,
    this.metadata = const {},
  });

  final String schema;
  final String fileId;
  final int conversationId;
  final String kind;
  final String name;
  final String mime;
  final int sizeBytes;
  final String sizeLabel;
  final String status;
  final String parseStatus;
  final String downloadUrl;

  /// 缩略图的 file_id，用于通过 GET /api/attachments/:id/download 下载缩略图。
  final String thumbnailFileId;

  /// 从附件下载接口获取的缩略图临时下载 URL（有有效期）。
  final String thumbnailUrl;
  final String localPreviewDataUri;
  final int? width;
  final int? height;
  final int? durationMs;

  /// 附件附加元数据（如 {"format": "png"}）。
  final Map<String, dynamic> metadata;

  bool get isImage => kind == 'image' || mime.startsWith('image/');
  bool get isAudio => kind == 'audio' || mime.startsWith('audio/');
  bool get isVideo => kind == 'video' || mime.startsWith('video/');

  String get displayKind {
    if (isImage) return '图片';
    if (isAudio) return '音频';
    if (isVideo) return '视频';
    return '附件';
  }

  String get bestPreviewUrl {
    if (thumbnailUrl.isNotEmpty) return thumbnailUrl;
    return downloadUrl;
  }

  factory AttachmentMessagePayload.fromJson(Map<String, dynamic> json) {
    final original = _jsonMap(json['original']);
    final size = _jsonInt(
      original['size'],
      fallback: _jsonInt(json['size'], fallback: _jsonInt(json['size_bytes'])),
    );
    final name = _jsonString(
      original['name'],
      fallback: _jsonString(
        json['name'],
        fallback: _jsonString(json['original_name'], fallback: '未命名附件'),
      ),
    );
    final mime = _jsonString(
      original['mime'],
      fallback: _jsonString(json['mime'], fallback: 'application/octet-stream'),
    );
    // §11.2/§11.4: thumbnail_file_id 是服务端推送的缩略图 object key，
    // 需要单独调用 GET /api/attachments/:id/download 获取临时下载 URL。
    final rawThumbnailFileId = _jsonString(
      json['thumbnail_file_id'],
      fallback: _jsonString(json['thumbnail_object_key']),
    );
    final rawThumbnailUrl = _jsonString(json['thumbnail_url']);
    final thumbnailFileId = rawThumbnailFileId.isNotEmpty
        ? rawThumbnailFileId
        : (_looksLikeUrl(rawThumbnailUrl) ? '' : rawThumbnailUrl);
    final thumbnailUrl = _looksLikeUrl(rawThumbnailUrl) ? rawThumbnailUrl : '';
    return AttachmentMessagePayload(
      schema: _jsonString(json['schema'], fallback: 'aim.attachment.v1'),
      fileId: _jsonString(json['file_id'], fallback: _jsonString(json['id'])),
      conversationId: _jsonInt(json['conversation_id']),
      kind: _jsonString(json['kind'], fallback: 'file'),
      name: name,
      mime: mime,
      sizeBytes: size,
      sizeLabel: _jsonString(
        json['size_label'],
        fallback: size > 0 ? _formatBytes(size) : '-',
      ),
      status: _jsonString(json['status'], fallback: 'ready'),
      parseStatus: _jsonString(json['parse_status'], fallback: 'pending'),
      downloadUrl: _jsonString(
        json['download_url'],
        fallback: _jsonString(json['url']),
      ),
      thumbnailFileId: thumbnailFileId,
      thumbnailUrl: thumbnailUrl,
      localPreviewDataUri: _jsonString(json['local_preview_data_uri']),
      width: _nullableJsonInt(json['width']),
      height: _nullableJsonInt(json['height']),
      durationMs: _nullableJsonInt(json['duration_ms']),
      metadata: _jsonMap(json['metadata']),
    );
  }

  static AttachmentMessagePayload? tryParse(String content) {
    final trimmed = content.trim();
    if (!trimmed.startsWith('{')) return null;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is! Map) return null;
      final json = Map<String, dynamic>.from(decoded);
      final schema = _jsonString(json['schema']);
      if (schema.isNotEmpty && schema != 'aim.attachment.v1') return null;
      if (!json.containsKey('file_id') && !json.containsKey('id')) return null;
      return AttachmentMessagePayload.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  AttachmentMessagePayload copyWith({
    String? status,
    String? parseStatus,
    String? downloadUrl,
    String? thumbnailFileId,
    String? thumbnailUrl,
    String? localPreviewDataUri,
    Map<String, dynamic>? metadata,
  }) {
    return AttachmentMessagePayload(
      schema: schema,
      fileId: fileId,
      conversationId: conversationId,
      kind: kind,
      name: name,
      mime: mime,
      sizeBytes: sizeBytes,
      sizeLabel: sizeLabel,
      status: status ?? this.status,
      parseStatus: parseStatus ?? this.parseStatus,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      thumbnailFileId: thumbnailFileId ?? this.thumbnailFileId,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      localPreviewDataUri: localPreviewDataUri ?? this.localPreviewDataUri,
      width: width,
      height: height,
      durationMs: durationMs,
      metadata: metadata ?? this.metadata,
    );
  }

  /// 序列化为符合 aim.attachment.v1 schema 的 JSON 对象。
  /// [includeLocalPreview] 控制是否写入本地预览 data URI。
  /// [includeClientFields] 控制是否写入客户端展示/缓存字段；发送到服务端时应为 false。
  Map<String, dynamic> toJson({
    bool includeLocalPreview = true,
    bool includeClientFields = true,
  }) {
    final effectiveParseStatus = parseStatus.trim().isEmpty
        ? 'pending'
        : parseStatus.trim();
    return <String, dynamic>{
      'schema': schema,
      'file_id': fileId,
      'kind': kind,
      'original': <String, dynamic>{
        'name': name,
        'mime': mime,
        'size': sizeBytes,
      },
      'parse_status': effectiveParseStatus,
      if (thumbnailFileId.isNotEmpty) 'thumbnail_file_id': thumbnailFileId,
      if (durationMs != null) 'duration_ms': durationMs,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (metadata.isNotEmpty) 'metadata': metadata,
      if (includeClientFields) ...{
        if (conversationId > 0) 'conversation_id': conversationId,
        if (status.isNotEmpty) 'status': status,
        if (sizeLabel.isNotEmpty) 'size_label': sizeLabel,
        if (downloadUrl.isNotEmpty) 'download_url': downloadUrl,
        if (includeLocalPreview && localPreviewDataUri.isNotEmpty)
          'local_preview_data_uri': localPreviewDataUri,
      },
    };
  }

  String toJsonString({
    bool includeLocalPreview = true,
    bool includeClientFields = true,
  }) {
    return jsonEncode(
      toJson(
        includeLocalPreview: includeLocalPreview,
        includeClientFields: includeClientFields,
      ),
    );
  }
}

class PresenceItem {
  const PresenceItem({
    required this.userId,
    required this.status,
    required this.updatedAt,
    this.displayName = '',
  });

  final int userId;
  final String status;
  final DateTime updatedAt;
  final String displayName;
}

class AppNotification {
  const AppNotification({
    required this.type,
    required this.title,
    required this.body,
    required this.relatedId,
    required this.createdAt,
  });

  final String type;
  final String title;
  final String body;
  final int relatedId;
  final DateTime createdAt;
}

class SearchUserResult {
  const SearchUserResult({required this.user, required this.snippet});

  final UserProfile user;
  final String snippet;
}

class SearchFriendResult {
  const SearchFriendResult({
    required this.friendship,
    required this.user,
    required this.snippet,
  });

  final Friendship friendship;
  final UserProfile user;
  final String snippet;
}

class SearchConversationResult {
  const SearchConversationResult({
    required this.conversation,
    required this.snippet,
  });

  final Conversation conversation;
  final String snippet;
}

class SearchMessageResult {
  const SearchMessageResult({required this.message, required this.snippet});

  final ChatMessage message;
  final String snippet;
}

class UnifiedSearchResult {
  const UnifiedSearchResult({
    this.users = const [],
    this.friends = const [],
    this.conversations = const [],
    this.messages = const [],
    this.nextCursorCreatedAt = 0,
    this.nextCursorId = 0,
    this.hasMore = false,
  });

  final List<SearchUserResult> users;
  final List<SearchFriendResult> friends;
  final List<SearchConversationResult> conversations;
  final List<SearchMessageResult> messages;
  final int nextCursorCreatedAt;
  final int nextCursorId;
  final bool hasMore;

  bool get isEmpty =>
      users.isEmpty &&
      friends.isEmpty &&
      conversations.isEmpty &&
      messages.isEmpty;
}

class UserBotInfo {
  const UserBotInfo({
    required this.botUserId,
    required this.ownerUserId,
    required this.email,
    required this.nickname,
    required this.avatarUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int botUserId;
  final int ownerUserId;
  final String email;
  final String nickname;
  final String avatarUrl;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isEnabled => status == 1;

  String get statusLabel => isEnabled ? '启用' : '停用';

  String get initials {
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) return 'BOT';
    return String.fromCharCodes(trimmed.runes.take(3)).toUpperCase();
  }
}

class UserBotTokenInfo {
  const UserBotTokenInfo({
    required this.tokenId,
    required this.botUserId,
    required this.name,
    required this.actions,
    required this.expiresAt,
    required this.revokedAt,
    required this.createdAt,
  });

  final int tokenId;
  final int botUserId;
  final String name;
  final List<String> actions;
  final DateTime? expiresAt;
  final DateTime? revokedAt;
  final DateTime createdAt;

  bool get isRevoked => revokedAt != null;
  bool get neverExpires => expiresAt == null;
}

class UserBotTokenIssueResult {
  const UserBotTokenIssueResult({
    required this.token,
    required this.plaintextToken,
  });

  final UserBotTokenInfo token;

  /// 明文连接密钥仅在创建或轮换后返回一次。
  final String plaintextToken;
}

class BotActionCatalogItem {
  const BotActionCatalogItem({
    required this.id,
    required this.action,
    required this.description,
  });

  final int id;
  final String action;
  final String description;
}

class BotCenterState {
  const BotCenterState({
    this.isLoading = false,
    this.ownedBots = const [],
    this.selectedOwnedBotId,
    this.botTokensByBot = const {},
    this.availableActions = const [],
    this.plaintextToken = '',
  });

  final bool isLoading;
  final List<UserBotInfo> ownedBots;
  final int? selectedOwnedBotId;
  final Map<int, List<UserBotTokenInfo>> botTokensByBot;
  final List<BotActionCatalogItem> availableActions;
  final String plaintextToken;

  UserBotInfo? get selectedOwnedBot {
    final selectedId = selectedOwnedBotId;
    if (selectedId == null) return null;
    for (final bot in ownedBots) {
      if (bot.botUserId == selectedId) return bot;
    }
    return null;
  }

  List<BotActionCatalogItem> get tokenActionOptions {
    if (availableActions.isEmpty) {
      return const [
        BotActionCatalogItem(
          id: 0,
          action: 'bot.self.read',
          description: '查看 Bot 身份',
        ),
        BotActionCatalogItem(
          id: 0,
          action: 'bot.conversation.list',
          description: '查看 Bot 会话',
        ),
        BotActionCatalogItem(
          id: 0,
          action: 'bot.conversation.history',
          description: '查看会话历史',
        ),
        BotActionCatalogItem(
          id: 0,
          action: 'bot.message.send',
          description: '发送消息',
        ),
      ];
    }
    return availableActions;
  }

  List<UserBotTokenInfo> tokensFor(int botUserId) {
    return botTokensByBot[botUserId] ?? const [];
  }

  BotCenterState copyWith({
    bool? isLoading,
    List<UserBotInfo>? ownedBots,
    Object? selectedOwnedBotId = _unset,
    Map<int, List<UserBotTokenInfo>>? botTokensByBot,
    List<BotActionCatalogItem>? availableActions,
    String? plaintextToken,
  }) {
    return BotCenterState(
      isLoading: isLoading ?? this.isLoading,
      ownedBots: ownedBots ?? this.ownedBots,
      selectedOwnedBotId: selectedOwnedBotId == _unset
          ? this.selectedOwnedBotId
          : selectedOwnedBotId as int?,
      botTokensByBot: botTokensByBot ?? this.botTokensByBot,
      availableActions: availableActions ?? this.availableActions,
      plaintextToken: plaintextToken ?? this.plaintextToken,
    );
  }
}

class ServiceOrder {
  const ServiceOrder({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final String status;
  final DateTime updatedAt;
}

class AimState {
  const AimState({
    required this.isAuthenticated,
    required this.isBusy,
    required this.connectionOnline,
    required this.currentSection,
    required this.searchQuery,
    required this.conversations,
    required this.messagesByConversation,
    required this.friends,
    required this.friendRequests,
    required this.friendTags,
    required this.attachments,
    required this.orders,
    required this.notifications,
    required this.conversationMembersById,
    required this.botCenter,
    this.session,
    this.selectedConversationId,
    this.notice,
    this.noticeSerial = 0,
    this.searchResults,
    this.isSearching = false,
  });

  factory AimState.initial() {
    return const AimState(
      isAuthenticated: false,
      isBusy: false,
      connectionOnline: false,
      currentSection: AppSection.chats,
      searchQuery: '',
      conversations: [],
      messagesByConversation: {},
      friends: [],
      friendRequests: [],
      friendTags: [],
      attachments: [],
      orders: [],
      notifications: [],
      conversationMembersById: {},
      botCenter: BotCenterState(),
    );
  }

  final bool isAuthenticated;
  final bool isBusy;
  final bool connectionOnline;
  final AppSection currentSection;
  final String searchQuery;
  final List<Conversation> conversations;
  final Map<int, List<ChatMessage>> messagesByConversation;
  final List<Friendship> friends;
  final List<Friendship> friendRequests;
  final List<FriendTag> friendTags;
  final List<AttachmentItem> attachments;
  final List<ServiceOrder> orders;
  final List<AppNotification> notifications;
  final Map<int, List<UserProfile>> conversationMembersById;
  final BotCenterState botCenter;
  final AuthSession? session;
  final int? selectedConversationId;
  final String? notice;
  final int noticeSerial;

  /// 全局聚合搜索结果（null = 尚未搜索或已清除）。
  final UnifiedSearchResult? searchResults;

  /// 是否正在执行聚合搜索。
  final bool isSearching;

  UserProfile? get currentUser => session?.user;

  Conversation? get selectedConversation {
    final selectedId = selectedConversationId;
    if (selectedId == null) return null;
    for (final conversation in conversations) {
      if (conversation.id == selectedId) return conversation;
    }
    return null;
  }

  List<ChatMessage> messagesFor(int conversationId) {
    return messagesByConversation[conversationId] ?? const [];
  }

  List<UserProfile> membersForConversation(int conversationId) {
    return conversationMembersById[conversationId] ?? const [];
  }

  UserProfile? memberProfileById(int userId) {
    for (final members in conversationMembersById.values) {
      for (final member in members) {
        if (member.id == userId) return member;
      }
    }
    return null;
  }

  List<Conversation> get filteredConversations {
    final keyword = searchQuery.trim().toLowerCase();
    final sorted = [...conversations]
      ..sort((a, b) {
        if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
    if (keyword.isEmpty) return sorted;
    return sorted.where((conversation) {
      return conversation.name.toLowerCase().contains(keyword) ||
          conversation.lastMessagePreview.toLowerCase().contains(keyword);
    }).toList();
  }

  List<Friendship> get filteredFriends {
    final keyword = searchQuery.trim().toLowerCase();
    final sorted = [...friends]
      ..sort((a, b) => a.user.nickname.compareTo(b.user.nickname));
    if (keyword.isEmpty) return sorted;
    return sorted.where((friendship) {
      final user = friendship.user;
      return user.nickname.toLowerCase().contains(keyword) ||
          user.email.toLowerCase().contains(keyword) ||
          friendship.tags.any(
            (tag) => tag.name.toLowerCase().contains(keyword),
          );
    }).toList();
  }

  int get totalUnread =>
      conversations.fold(0, (sum, item) => sum + item.unreadCount);

  AimState copyWith({
    bool? isAuthenticated,
    bool? isBusy,
    bool? connectionOnline,
    AppSection? currentSection,
    String? searchQuery,
    List<Conversation>? conversations,
    Map<int, List<ChatMessage>>? messagesByConversation,
    List<Friendship>? friends,
    List<Friendship>? friendRequests,
    List<FriendTag>? friendTags,
    List<AttachmentItem>? attachments,
    List<ServiceOrder>? orders,
    List<AppNotification>? notifications,
    Map<int, List<UserProfile>>? conversationMembersById,
    BotCenterState? botCenter,
    AuthSession? session,
    Object? selectedConversationId = _unset,
    Object? notice = _unset,
    int? noticeSerial,
    Object? searchResults = _unset,
    bool? isSearching,
  }) {
    return AimState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isBusy: isBusy ?? this.isBusy,
      connectionOnline: connectionOnline ?? this.connectionOnline,
      currentSection: currentSection ?? this.currentSection,
      searchQuery: searchQuery ?? this.searchQuery,
      conversations: conversations ?? this.conversations,
      messagesByConversation:
          messagesByConversation ?? this.messagesByConversation,
      friends: friends ?? this.friends,
      friendRequests: friendRequests ?? this.friendRequests,
      friendTags: friendTags ?? this.friendTags,
      attachments: attachments ?? this.attachments,
      orders: orders ?? this.orders,
      notifications: notifications ?? this.notifications,
      conversationMembersById:
          conversationMembersById ?? this.conversationMembersById,
      botCenter: botCenter ?? this.botCenter,
      session: session ?? this.session,
      selectedConversationId: selectedConversationId == _unset
          ? this.selectedConversationId
          : selectedConversationId as int?,
      notice: notice == _unset ? this.notice : notice as String?,
      noticeSerial: noticeSerial ?? this.noticeSerial,
      searchResults: searchResults == _unset
          ? this.searchResults
          : searchResults as UnifiedSearchResult?,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

Map<String, dynamic> _jsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

String _jsonString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final string = '$value';
  return string.isEmpty ? fallback : string;
}

bool _looksLikeUrl(String value) {
  final lower = value.toLowerCase();
  return lower.startsWith('http://') ||
      lower.startsWith('https://') ||
      lower.startsWith('data:');
}

int _jsonInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

int? _nullableJsonInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

List<dynamic> _jsonList(dynamic value) {
  if (value is List) return value;
  return const [];
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

/// System message event types per manual §12.2.
class SystemMessageEvent {
  const SystemMessageEvent._();

  /// Parse a system message content JSON string into a human-readable description.
  static String displayText(String content) {
    try {
      final json = jsonDecode(content);
      if (json is! Map) return content;
      final event = json['event'] as String? ?? '';
      final targets = _jsonList(json['target_user_ids']);
      final targetText = targets.isEmpty ? '' : '（${targets.length} 人）';
      final operator = _jsonInt(json['operator_id']);
      final operatorText = operator > 0 ? '操作者 $operator：' : '';
      return switch (event) {
        'member_joined' => '$operatorText新成员加入群聊$targetText',
        'member_left' => '$operatorText成员退出群聊',
        'member_removed' => '$operatorText成员被移出群聊$targetText',
        'group_renamed' => '$operatorText群名称已更改',
        'group_avatar_changed' => '$operatorText群头像已更改',
        'group_dismissed' => '$operatorText群聊已解散',
        _ => content,
      };
    } catch (_) {
      return content;
    }
  }
}

const Object _unset = Object();
