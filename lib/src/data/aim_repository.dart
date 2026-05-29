import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'gateway_realtime_client.dart';
import '../domain/models.dart';

/// Result of sending a message via repository.
/// Carries both the constructed [message] and ACK status info.
class SendResult {
  const SendResult({
    required this.message,
    this.ackStatus = 0,
    this.ackCode = 0,
    this.ackText = '',
  });

  final ChatMessage message;

  /// 0=UNSPECIFIED, 1=ACCEPTED, 2=REJECTED, 3=RETRYABLE
  final int ackStatus;
  final int ackCode;
  final String ackText;

  bool get isAccepted => ackStatus == 1 || (ackStatus == 0 && ackCode == 0);
  bool get isRejected => ackStatus == 2;
  bool get isRetryable => ackStatus == 3;
}

class HistoryPage {
  const HistoryPage({
    required this.messages,
    required this.hasMore,
    required this.nextCursorCreatedAt,
    required this.nextCursorId,
  });

  final List<ChatMessage> messages;
  final bool hasMore;
  final int nextCursorCreatedAt;
  final int nextCursorId;
}

class AimBootstrapData {
  const AimBootstrapData({
    required this.conversations,
    required this.messagesByConversation,
    required this.friends,
    required this.friendRequests,
    this.friendTags = const [],
    required this.attachments,
    required this.orders,
  });

  final List<Conversation> conversations;
  final Map<int, List<ChatMessage>> messagesByConversation;
  final List<Friendship> friends;
  final List<Friendship> friendRequests;
  final List<FriendTag> friendTags;
  final List<AttachmentItem> attachments;
  final List<ServiceOrder> orders;
}

class AttachmentDownloadResult {
  const AttachmentDownloadResult({
    required this.fileName,
    required this.mime,
    required this.bytes,
    this.sourceUrl = '',
    this.expiresAt,
  });

  final String fileName;
  final String mime;
  final Uint8List bytes;
  final String sourceUrl;
  final DateTime? expiresAt;
}

abstract class AimRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
    required String deviceId,
  });

  Future<AuthSession> register({
    required String email,
    required String password,
    required String username,
    required String deviceId,
  });

  Future<void> logout(String accessToken);

  Future<AimBootstrapData> loadBootstrapData(UserProfile user);

  Stream<RealtimeEvent> get realtimeEvents =>
      const Stream<RealtimeEvent>.empty();

  Future<AuthSession> refreshSession(AuthSession session) async => session;

  Future<SendResult> sendTextMessage({
    required int conversationId,
    required UserProfile sender,
    required String content,
    required String clientMessageId,
    required DateTime createdAt,
  });

  Future<SendResult> sendAttachmentMessage({
    required int conversationId,
    required UserProfile sender,
    required AttachmentMessagePayload payload,
    required String displayContent,
    required String clientMessageId,
    required DateTime createdAt,
  });

  Future<void> sendTyping(int conversationId);

  Future<void> sendReadReceipt({
    required int conversationId,
    required int lastMessageId,
  });

  Future<List<UserProfile>> searchUsers(String keyword);

  Future<List<FriendTag>> listFriendTags() async => const [];

  Future<FriendTag> createFriendTag(String name) =>
      throw UnsupportedError('当前仓库不支持好友标签');

  Future<FriendTag> renameFriendTag(int tagId, String name) =>
      throw UnsupportedError('当前仓库不支持好友标签');

  Future<void> deleteFriendTag(int tagId) async {}

  Future<Friendship> setFriendTags(int friendId, List<int> tagIds) =>
      throw UnsupportedError('当前仓库不支持好友标签');

  Future<Friendship> removeFriendTag(int friendId, int tagId) =>
      throw UnsupportedError('当前仓库不支持好友标签');

  Future<UnifiedSearchResult> search(
    String query, {
    List<String> scopes = const [],
    int? conversationId,
    int? cursorCreatedAt,
    int? cursorId,
    int limit = 20,
  }) async => const UnifiedSearchResult();

  Future<Friendship> requestFriend(
    UserProfile currentUser,
    UserProfile targetUser,
  );

  Future<Friendship> acceptFriend(UserProfile currentUser, int friendshipId);

  Future<void> rejectFriend(int friendshipId);

  Future<Conversation> createDirectConversation({
    required UserProfile currentUser,
    required UserProfile targetUser,
  });

  Future<Conversation> createGroup({
    required UserProfile currentUser,
    required String name,
    required List<int> memberIds,
  });

  Future<Conversation> updateGroupName(int conversationId, String name);

  Future<List<UserProfile>> getConversationMembers(int conversationId);

  Future<Conversation> addGroupMembers(int conversationId, List<int> memberIds);

  Future<void> removeGroupMember(int conversationId, int userId);

  Future<void> grantAdmin(int conversationId, int userId);

  Future<void> revokeAdmin(int conversationId, int userId);

  Future<Conversation> transferGroupOwner(int conversationId, int newOwnerId);

  Future<void> dismissGroup(int conversationId);

  Future<void> leaveConversation(int conversationId);

  /// Load more history with cursor pagination (manual §3.3).
  /// Returns null if no more data, else the next page of messages.
  Future<HistoryPage?> loadMoreHistory(
    int conversationId, {
    required int cursorCreatedAt,
    required int cursorId,
  }) async => null;

  Future<AttachmentItem> initAttachmentUpload({
    required int conversationId,
    required String kind,
    required String originalName,
    required String mime,
    required int size,
  });

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
    onProgress?.call(0);
    final attachment = await initAttachmentUpload(
      conversationId: conversationId,
      kind: kind,
      originalName: originalName,
      mime: mime,
      size: size,
    );
    onProgress?.call(1);
    return attachment.copyWith(
      mime: mime,
      sizeBytes: size,
      status: 'uploaded / parsed',
      localPreviewDataUri: localPreviewDataUri,
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
  }) async {
    final builder = BytesBuilder(copy: false);
    await for (final chunk in openRead()) {
      builder.add(chunk);
    }
    return uploadAttachment(
      conversationId: conversationId,
      kind: kind,
      originalName: originalName,
      mime: mime,
      size: size,
      bytes: builder.takeBytes(),
      localPreviewDataUri: localPreviewDataUri,
      onProgress: onProgress,
    );
  }

  Future<AttachmentDownloadResult> downloadAttachment(
    AttachmentMessagePayload payload,
  ) async {
    final localBytes = _bytesFromDataUri(payload.localPreviewDataUri);
    if (localBytes != null) {
      return AttachmentDownloadResult(
        fileName: payload.name,
        mime: payload.mime,
        bytes: localBytes,
        sourceUrl: payload.downloadUrl,
      );
    }
    throw UnsupportedError('当前仓库不支持附件下载');
  }
}

Uint8List? _bytesFromDataUri(String dataUri) {
  final marker = dataUri.indexOf(',');
  if (marker <= 0 || !dataUri.startsWith('data:')) return null;
  try {
    final meta = dataUri.substring(0, marker).toLowerCase();
    final data = dataUri.substring(marker + 1);
    if (meta.contains(';base64')) return base64Decode(data);
    return Uint8List.fromList(utf8.encode(Uri.decodeComponent(data)));
  } catch (_) {
    return null;
  }
}
