import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'gateway_config.dart';
import '../domain/models.dart';

/// Dio interceptor that auto-injects Authorization header and
/// retries on 401 by calling [onTokenExpired] to refresh.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({this.onTokenExpired, String? initialToken})
    : _accessToken = initialToken;

  final Future<String?> Function()? onTokenExpired;
  String? _accessToken;

  /// Update the access token to use for future requests.
  void updateToken(String? token) => _accessToken = token;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 || _isAuthError(err.response?.data)) {
      if (onTokenExpired != null) {
        try {
          final newToken = await onTokenExpired!();
          if (newToken != null && newToken.isNotEmpty) {
            _accessToken = newToken;
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newToken';
            final response = await Dio().fetch<void>(opts);
            return handler.resolve(response);
          }
        } catch (_) {
          // Refresh failed, let original error propagate
        }
      }
    }
    handler.next(err);
  }

  bool _isAuthError(dynamic data) {
    if (data is Map) {
      final code = data['code'];
      return code == 40100;
    }
    return false;
  }
}

class GatewayApiClient {
  GatewayApiClient({
    String? baseUrl,
    Dio? dio,
    AuthInterceptor? interceptor,
    Future<String?> Function()? onTokenExpired,
  }) : _authInterceptor =
           interceptor ?? AuthInterceptor(onTokenExpired: onTokenExpired),
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl ?? GatewayConfig.current.gatewayUrl,
               connectTimeout: const Duration(seconds: 8),
               receiveTimeout: const Duration(seconds: 12),
               contentType: Headers.jsonContentType,
             ),
           ) {
    _dio.interceptors.add(_authInterceptor);
  }

  final AuthInterceptor _authInterceptor;
  final Dio _dio;

  void setAccessToken(String? token) => _authInterceptor.updateToken(token);

  Future<AuthSession> login({
    required String email,
    required String password,
    required String deviceId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/auth/login',
      data: {'email': email, 'password': password, 'device_id': deviceId},
    );
    final body = _body(response.data);
    final userId = _asInt(body['user_id']);
    final accessToken = _asString(body['access_token']);
    final refreshToken = _asString(body['refresh_token']);
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      _asInt(body['expires_at']) * 1000,
    );
    setAccessToken(accessToken);
    final user = await getUserById(userId).catchError((_) {
      return UserProfile(
        id: userId,
        email: email,
        nickname: email.split('@').first,
        avatarUrl: '',
        status: PresenceStatus.online,
      );
    });
    return AuthSession(
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }

  Future<int> register({
    required String email,
    required String password,
    required String username,
    required String deviceId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/auth/register',
      data: {
        'email': email,
        'password': password,
        'username': username,
        'device_id': deviceId,
        'avatar': '',
      },
    );
    return _asInt(_body(response.data)['user_id']);
  }

  Future<AuthSession> refresh(String refreshToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    final body = _body(response.data);
    final accessToken = _asString(body['access_token']);
    setAccessToken(accessToken);
    return AuthSession(
      user: const UserProfile(
        id: 0,
        email: '',
        nickname: '',
        avatarUrl: '',
        status: PresenceStatus.online,
      ),
      accessToken: accessToken,
      refreshToken: _asString(body['refresh_token']),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        _asInt(body['expires_at']) * 1000,
      ),
    );
  }

  Future<void> logout() async {
    await _dio.post<void>('/api/auth/logout');
    setAccessToken(null);
  }

  Future<UserProfile> getUserById(int userId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/users/by-id/$userId',
    );
    final user = _body(response.data)['user'] as Map<String, dynamic>;
    return _userFromJson(user, presence: PresenceStatus.online);
  }

  Future<List<UserProfile>> searchUsers(String keyword) async {
    final encodedKeyword = Uri.encodeComponent(keyword.trim());
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/users/by-name/$encodedKeyword',
    );
    final users = _list(_body(response.data)['users']);
    return users.map((item) => _userListItemFromJson(_asMap(item))).toList();
  }

  Future<Friendship> addFriend(
    UserProfile currentUser,
    int targetUserId,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/users/friends/$targetUserId',
    );
    return _friendshipFromJson(
      currentUser,
      _body(response.data)['friendship'] as Map<String, dynamic>,
    );
  }

  Future<List<Friendship>> listFriends(UserProfile currentUser) async {
    final response = await _dio.get<Map<String, dynamic>>('/api/friends/me');
    return _list(
      _body(response.data)['friends'],
    ).map((item) => _friendshipFromJson(currentUser, _asMap(item))).toList();
  }

  Future<List<Friendship>> listFriendApplications(
    UserProfile currentUser,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/friends/applications',
    );
    return _list(
      _body(response.data)['applications'],
    ).map((item) => _friendshipFromJson(currentUser, _asMap(item))).toList();
  }

  Future<Friendship> acceptFriend(
    UserProfile currentUser,
    int applicationId,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/friends/accept/$applicationId',
    );
    return _friendshipFromJson(
      currentUser,
      _body(response.data)['friendship'] as Map<String, dynamic>,
    );
  }

  Future<Friendship> rejectFriend(
    UserProfile currentUser,
    int applicationId,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/friends/reject/$applicationId',
    );
    return _friendshipFromJson(
      currentUser,
      _body(response.data)['friendship'] as Map<String, dynamic>,
    );
  }

  Future<List<Conversation>> listConversations() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/conversations');
    return _list(
      _body(response.data)['conversations'],
    ).map((item) => _conversationFromJson(_asMap(item))).toList();
  }

  Future<Conversation> createConversation({
    required ConversationType type,
    required String name,
    required List<int> memberIds,
  }) async {
    final payload = type == ConversationType.group
        ? {
            'conversation_type': 'group',
            'member_ids': memberIds,
            'name': name,
            'avatar': '',
          }
        : {
            'conversation_type': 'direct',
            'member_ids': memberIds,
            'avatar': '',
          };
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/conversations',
      data: payload,
    );
    return _conversationFromJson(_body(response.data));
  }

  Future<Conversation> createGroup({
    required String name,
    required List<int> memberIds,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/conversations/group',
      data: {'name': name, 'member_ids': memberIds, 'avatar': ''},
    );
    return _conversationFromJson(_body(response.data));
  }

  Future<ConversationHistoryData> getHistory(
    int conversationId, {
    int limit = 50,
    int? cursorCreatedAt,
    int? cursorId,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit};
    if (cursorCreatedAt != null && cursorCreatedAt > 0) {
      queryParams['cursor_created_at'] = cursorCreatedAt;
    }
    if (cursorId != null && cursorId > 0) {
      queryParams['cursor_id'] = cursorId;
    }
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/conversations/history/$conversationId',
      queryParameters: queryParams,
    );
    final body = _body(response.data);
    final readStates = _list(
      body['read_states'],
    ).map((item) => _readStateFromJson(_asMap(item))).toList();
    final messages =
        _list(
            body['messages'],
          ).map((item) => _messageFromJson(_asMap(item))).toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt)); // 确保按时间升序
    return ConversationHistoryData(
      messages: messages,
      hasMore: body['has_more'] == true,
      nextCursorCreatedAt: _asInt(body['next_cursor_created_at']),
      nextCursorId: _asInt(body['next_cursor_id']),
      readStates: readStates,
    );
  }

  Future<List<UserProfile>> getConversationMembers(int conversationId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/conversations/$conversationId/members',
    );
    return _list(_body(response.data)['members']).map((rawItem) {
      final item = _asMap(rawItem);
      return UserProfile(
        id: _asInt(item['user_id']),
        email: _asString(item['email']),
        nickname: _asString(
          item['display_name'],
          fallback: _asString(item['email']),
        ),
        avatarUrl: _asString(item['avatar']),
        status: PresenceStatus.offline,
      );
    }).toList();
  }

  Future<Conversation> updateGroupInfo(
    int conversationId, {
    String? name,
    String? avatar,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/conversations/$conversationId',
      data: {'name': name, 'avatar': avatar},
    );
    return _conversationFromJson(_body(response.data));
  }

  Future<void> leaveConversation(int conversationId) async {
    await _dio.post<void>('/api/conversations/$conversationId/leave');
  }

  Future<Conversation> addGroupMembers(
    int conversationId,
    List<int> memberIds,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/conversations/$conversationId/members',
      data: {'member_ids': memberIds},
    );
    return _conversationFromJson(_body(response.data));
  }

  Future<void> removeGroupMember(int conversationId, int userId) async {
    await _dio.delete<void>(
      '/api/conversations/$conversationId/members/$userId',
    );
  }

  Future<void> grantAdmin(int conversationId, int userId) async {
    await _dio.post<void>(
      '/api/conversations/$conversationId/members/$userId/admin',
    );
  }

  Future<void> revokeAdmin(int conversationId, int userId) async {
    await _dio.delete<void>(
      '/api/conversations/$conversationId/members/$userId/admin',
    );
  }

  Future<Conversation> transferGroupOwner(
    int conversationId,
    int newOwnerId,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/conversations/$conversationId/owner',
      data: {'user_id': newOwnerId},
    );
    return _conversationFromJson(_body(response.data));
  }

  Future<void> dismissGroup(int conversationId) async {
    await _dio.delete<void>('/api/conversations/$conversationId');
  }

  Future<List<PresenceItem>> getFriendsPresence() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/presence/friends',
    );
    return _list(_body(response.data)['presences']).map((rawItem) {
      final item = _asMap(rawItem);
      return PresenceItem(
        userId: _asInt(item['user_id']),
        status: _asString(item['status'], fallback: 'offline'),
        updatedAt: _dateFromMs(item['updated_at']),
        displayName: _asString(item['display_name']),
      );
    }).toList();
  }

  Future<AttachmentUploadTicket> createAttachmentUploadTicket({
    required int conversationId,
    required String kind,
    required String originalName,
    required String mime,
    required int size,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/attachments/init',
      data: {
        'conversation_id': conversationId,
        'kind': kind,
        'original_name': originalName,
        'mime': mime,
        'size': size,
      },
    );
    final body = _body(response.data);
    return AttachmentUploadTicket(
      attachment: AttachmentItem(
        id: _asString(body['file_id']),
        conversationId: conversationId,
        kind: kind,
        name: originalName,
        sizeLabel: _formatBytes(size),
        status: 'pending',
        mime: mime,
        sizeBytes: size,
      ),
      uploadUrl: _asString(body['upload_url']),
      uploadMethod: _asString(body['upload_method'], fallback: 'PUT'),
      headers: _stringMap(body['headers']),
      expiresAt: _dateFromMs(body['expires_at']),
    );
  }

  Future<AttachmentItem> initAttachmentUpload({
    required int conversationId,
    required String kind,
    required String originalName,
    required String mime,
    required int size,
  }) async {
    return (await createAttachmentUploadTicket(
      conversationId: conversationId,
      kind: kind,
      originalName: originalName,
      mime: mime,
      size: size,
    )).attachment;
  }

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
    return _uploadAttachmentData(
      conversationId: conversationId,
      kind: kind,
      originalName: originalName,
      mime: mime,
      size: size,
      data: bytes,
      localPreviewDataUri: localPreviewDataUri,
      onProgress: onProgress,
    );
  }

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
    return _uploadAttachmentData(
      conversationId: conversationId,
      kind: kind,
      originalName: originalName,
      mime: mime,
      size: size,
      data: openRead(),
      localPreviewDataUri: localPreviewDataUri,
      onProgress: onProgress,
    );
  }

  Future<AttachmentItem> _uploadAttachmentData({
    required int conversationId,
    required String kind,
    required String originalName,
    required String mime,
    required int size,
    required Object data,
    String localPreviewDataUri = '',
    void Function(double progress)? onProgress,
  }) async {
    final ticket = await createAttachmentUploadTicket(
      conversationId: conversationId,
      kind: kind,
      originalName: originalName,
      mime: mime,
      size: size,
    );
    onProgress?.call(0.08);
    final headers = <String, dynamic>{...ticket.headers};
    final hasContentType = headers.keys.any(
      (key) => key.toLowerCase() == Headers.contentTypeHeader,
    );
    if (!hasContentType) {
      headers[Headers.contentTypeHeader] = mime;
    }
    final hasContentLength = headers.keys.any(
      (key) => key.toLowerCase() == Headers.contentLengthHeader,
    );
    if (!hasContentLength && data is Stream<List<int>>) {
      headers[Headers.contentLengthHeader] = size;
    }
    await Dio().requestUri<void>(
      Uri.parse(ticket.uploadUrl),
      data: data,
      options: Options(
        method: ticket.uploadMethod,
        headers: headers,
        responseType: ResponseType.plain,
      ),
      onSendProgress: (sent, total) {
        final denominator = total <= 0 ? size : total;
        if (denominator <= 0) return;
        final ratio = (sent / denominator).clamp(0, 1);
        onProgress?.call((0.08 + ratio * 0.82).toDouble());
      },
    );
    onProgress?.call(0.92);
    final completed = await completeAttachmentUpload(ticket.attachment.id);
    AttachmentDownloadTicket? downloadTicket;
    try {
      downloadTicket = await createAttachmentDownloadTicket(completed.id);
    } catch (_) {
      downloadTicket = null;
    }
    onProgress?.call(1);
    return completed.copyWith(
      downloadUrl: downloadTicket?.url ?? '',
      localPreviewDataUri: localPreviewDataUri,
      sizeBytes: completed.sizeBytes > 0 ? completed.sizeBytes : size,
      sizeLabel: completed.sizeBytes > 0
          ? completed.sizeLabel
          : _formatBytes(size),
    );
  }

  Future<AttachmentItem> getAttachment(String attachmentId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/attachments/$attachmentId',
    );
    return _attachmentFromJson(_body(response.data));
  }

  Future<AttachmentItem> completeAttachmentUpload(String attachmentId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/attachments/$attachmentId/complete',
      data: <String, dynamic>{},
    );
    return _attachmentFromJson(_body(response.data));
  }

  Future<String> getAttachmentDownloadUrl(String attachmentId) async {
    return (await createAttachmentDownloadTicket(attachmentId)).url;
  }

  Future<AttachmentDownloadTicket> createAttachmentDownloadTicket(
    String attachmentId,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/attachments/$attachmentId/download',
    );
    final body = _body(response.data);
    return AttachmentDownloadTicket(
      url: _asString(body['url']),
      headers: _stringMap(body['headers']),
      expiresAt: _dateFromMs(body['expires_at']),
    );
  }

  Future<Uint8List> downloadAttachmentBytes(String attachmentId) async {
    final ticket = await createAttachmentDownloadTicket(attachmentId);
    final response = await Dio().getUri<dynamic>(
      Uri.parse(ticket.url),
      options: Options(
        headers: ticket.headers,
        responseType: ResponseType.bytes,
        followRedirects: true,
      ),
    );
    final data = response.data;
    if (data is Uint8List) return data;
    if (data is List<int>) return Uint8List.fromList(data);
    throw StateError('附件下载响应不是二进制内容');
  }
}

class ConversationHistoryData {
  const ConversationHistoryData({
    required this.messages,
    required this.hasMore,
    required this.nextCursorCreatedAt,
    required this.nextCursorId,
    this.readStates = const [],
  });

  final List<ChatMessage> messages;
  final bool hasMore;
  final int nextCursorCreatedAt;
  final int nextCursorId;
  final List<ReadStateItem> readStates;
}

class ReadStateItem {
  const ReadStateItem({
    required this.userId,
    required this.lastReadMessageId,
    required this.updatedAt,
    this.email,
    this.avatar,
    this.displayName,
  });

  final int userId;
  final int lastReadMessageId;
  final DateTime updatedAt;
  final String? email;
  final String? avatar;
  final String? displayName;
}

class AttachmentUploadTicket {
  const AttachmentUploadTicket({
    required this.attachment,
    required this.uploadUrl,
    required this.uploadMethod,
    required this.headers,
    required this.expiresAt,
  });

  final AttachmentItem attachment;
  final String uploadUrl;
  final String uploadMethod;
  final Map<String, String> headers;
  final DateTime expiresAt;
}

class AttachmentDownloadTicket {
  const AttachmentDownloadTicket({
    required this.url,
    required this.headers,
    required this.expiresAt,
  });

  final String url;
  final Map<String, String> headers;
  final DateTime expiresAt;
}

Map<String, dynamic> _body(Map<String, dynamic>? response) {
  if (response == null) return <String, dynamic>{};
  final code = response['code'];
  if (code != null && code != 0) {
    throw DioException.badResponse(
      statusCode: code is int ? code : 50000,
      requestOptions: RequestOptions(path: ''),
      response: Response(
        requestOptions: RequestOptions(path: ''),
        data: response,
      ),
    );
  }
  final body = response['body'];
  if (body is Map<String, dynamic>) return body;
  if (body is Map) return Map<String, dynamic>.from(body);
  return <String, dynamic>{};
}

UserProfile _userFromJson(
  Map<String, dynamic> json, {
  PresenceStatus presence = PresenceStatus.offline,
}) {
  return UserProfile(
    id: _asInt(json['id']),
    email: _asString(json['email']),
    nickname: _asString(
      json['display_name'],
      fallback: _asString(json['nickname'], fallback: _asString(json['email'])),
    ),
    avatarUrl: _asString(json['avatar']),
    status: presence,
  );
}

UserProfile _userListItemFromJson(Map<String, dynamic> json) {
  return UserProfile(
    id: _asInt(json['id']),
    email: _asString(json['email']),
    nickname: _asString(
      json['display_name'],
      fallback: _asString(json['nickname'], fallback: _asString(json['email'])),
    ),
    avatarUrl: _asString(json['avatar']),
    status: PresenceStatus.offline,
  );
}

Friendship _friendshipFromJson(
  UserProfile currentUser,
  Map<String, dynamic> json,
) {
  final userId = _asInt(json['user_id']);
  final friendId = _asInt(json['friend_id']);
  final peerId = userId == currentUser.id ? friendId : userId;
  final email = _asString(
    json['email'],
    fallback: 'user-$peerId@unknown.local',
  );
  final status = _friendStatus(_asString(json['status']));
  return Friendship(
    id: peerId,
    user: UserProfile(
      id: peerId,
      email: email,
      nickname: _asString(
        json['display_name'],
        fallback: email.split('@').first,
      ),
      avatarUrl: _asString(json['avatar']),
      status: PresenceStatus.offline,
    ),
    status: status,
    createdAt: _dateFromMs(json['created_at']),
    updatedAt: _dateFromMs(json['updated_at']),
    incoming: friendId == currentUser.id && status == FriendStatus.pending,
  );
}

Conversation _conversationFromJson(Map<String, dynamic> json) {
  final id = _asInt(json['conversation_id'], fallback: _asInt(json['id']));
  final name = _asString(
    json['display_name'],
    fallback: _asString(json['name'], fallback: '会话 $id'),
  );
  return Conversation(
    id: id,
    type: _conversationType(_asString(json['conversation_type'])),
    name: name,
    avatarText: _avatarText(name),
    memberIds: _list(json['member_ids']).map((item) => _asInt(item)).toList(),
    createdAt: _dateFromMs(json['created_at']),
    updatedAt: _dateFromMs(
      json['updated_at'],
      fallback: _dateFromMs(json['created_at']),
    ),
    lastMessagePreview: _asString(
      json['last_message_preview'],
      fallback: '点击打开会话',
    ),
    unreadCount: _asInt(json['unread_count']),
    isActive: json['is_active'] != false,
    ownerId: _asInt(json['creator_id']),
  );
}

ChatMessage _messageFromJson(Map<String, dynamic> json) {
  final sender = json['sender_info'] is Map
      ? Map<String, dynamic>.from(json['sender_info'] as Map)
      : <String, dynamic>{};
  return ChatMessage(
    id: _asInt(json['id']),
    conversationId: _asInt(json['conversation_id']),
    senderId: _asInt(json['sender_id']),
    senderName: _asString(
      sender['display_name'],
      fallback: _asString(sender['name'], fallback: '系统'),
    ),
    type: _messageType(_asString(json['message_type'])),
    content: _asString(json['content']),
    createdAt: _dateFromMs(json['created_at']),
    clientMessageId: _asString(json['client_msg_id']),
    isSystem: json['is_system'] == true,
    mentions: _list(json['mentions']).map((item) => '$item').toList(),
    readBy: _list(json['read_details'])
        .map(_asMap)
        .where((item) => item['is_read'] == true)
        .map((item) => _asInt(item['user_id']))
        .toList(),
  );
}

AttachmentItem _attachmentFromJson(Map<String, dynamic> json) {
  final id = _asString(json['file_id'], fallback: _asString(json['id']));
  final size = _asInt(json['size']);
  final kind = _asString(json['kind'], fallback: 'file');
  return AttachmentItem(
    id: id,
    conversationId: _asInt(json['conversation_id']),
    kind: kind,
    name: _asString(json['original_name'], fallback: _asString(json['name'])),
    sizeLabel: _formatBytes(size),
    status: _asString(json['status'], fallback: 'uploaded'),
    mime: _asString(json['mime'], fallback: _defaultMimeForKind(kind)),
    sizeBytes: size,
    parseStatus: _asString(json['parse_status']),
    thumbnailUrl: _asString(json['thumbnail_url']),
    width: _nullableInt(json['width']),
    height: _nullableInt(json['height']),
    durationMs: _nullableInt(json['duration_ms']),
    createdAt: _dateFromMs(json['created_at'], fallback: DateTime.now()),
  );
}

ConversationType _conversationType(String value) {
  return value == 'group' ? ConversationType.group : ConversationType.direct;
}

MessageType _messageType(String value) {
  return switch (value) {
    'image' => MessageType.image,
    'file' || 'audio' || 'video' => MessageType.file,
    'system' => MessageType.system,
    _ => MessageType.text,
  };
}

FriendStatus _friendStatus(String value) {
  return switch (value) {
    'accepted' => FriendStatus.accepted,
    'rejected' => FriendStatus.rejected,
    _ => FriendStatus.pending,
  };
}

ReadStateItem _readStateFromJson(Map<String, dynamic> json) {
  return ReadStateItem(
    userId: _asInt(json['user_id']),
    lastReadMessageId: _asInt(json['last_read_message_id']),
    updatedAt: _dateFromMs(json['updated_at']),
    email: json['email'] as String?,
    avatar: json['avatar'] as String?,
    displayName: json['display_name'] as String?,
  );
}

List<dynamic> _list(dynamic value) {
  if (value is List) return value;
  return const [];
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

Map<String, String> _stringMap(dynamic value) {
  if (value is! Map) return const {};
  return value.map((key, item) => MapEntry('$key', '$item'));
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? fallback;
  if (value is num) return value.toInt();
  return fallback;
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final string = '$value';
  return string.isEmpty ? fallback : string;
}

int? _nullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

DateTime _dateFromMs(dynamic value, {DateTime? fallback}) {
  final ms = _asInt(value);
  if (ms <= 0) return fallback ?? DateTime.now();
  return DateTime.fromMillisecondsSinceEpoch(ms);
}

String _avatarText(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return '?';
  return String.fromCharCodes(trimmed.runes.take(3)).toUpperCase();
}

String _defaultMimeForKind(String kind) {
  return switch (kind) {
    'image' => 'image/png',
    'audio' => 'audio/mpeg',
    'video' => 'video/mp4',
    _ => 'application/octet-stream',
  };
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
