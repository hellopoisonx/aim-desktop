import 'package:aim_desktop/src/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttachmentMessagePayload', () {
    test('按最新 aim.attachment.v1 schema 解析 thumbnail_file_id', () {
      final payload = AttachmentMessagePayload.tryParse('''
{
  "schema": "aim.attachment.v1",
  "file_id": "att_abc123",
  "kind": "image",
  "original": {
    "name": "photo.jpg",
    "mime": "image/jpeg",
    "size": 2048576
  },
  "thumbnail_file_id": "attachments/derived/att_abc123/thumbnail.png",
  "parse_status": "ready",
  "width": 1920,
  "height": 1080,
  "metadata": {"format": "png"}
}
''');

      expect(payload, isNotNull);
      expect(
        payload!.thumbnailFileId,
        'attachments/derived/att_abc123/thumbnail.png',
      );
      expect(payload.thumbnailUrl, isEmpty);
      expect(payload.width, 1920);
      expect(payload.metadata['format'], 'png');
      expect(
        payload.toJson(includeLocalPreview: false),
        containsPair('thumbnail_file_id', payload.thumbnailFileId),
      );
      expect(
        payload.toJson(includeLocalPreview: false),
        isNot(contains('thumbnail_url')),
      );
    });

    test('兼容旧 thumbnail_url：URL 与 object key 分开处理', () {
      final urlPayload = AttachmentMessagePayload.fromJson({
        'schema': 'aim.attachment.v1',
        'file_id': 'att_url',
        'kind': 'image',
        'original': {'name': 'url.png', 'mime': 'image/png', 'size': 10},
        'thumbnail_url': 'https://cdn.example.test/thumb.png',
      });
      expect(urlPayload.thumbnailFileId, isEmpty);
      expect(urlPayload.thumbnailUrl, 'https://cdn.example.test/thumb.png');

      final keyPayload = AttachmentMessagePayload.fromJson({
        'schema': 'aim.attachment.v1',
        'file_id': 'att_key',
        'kind': 'image',
        'original': {'name': 'key.png', 'mime': 'image/png', 'size': 10},
        'thumbnail_url': 'attachments/derived/att_key/thumbnail.png',
      });
      expect(
        keyPayload.thumbnailFileId,
        'attachments/derived/att_key/thumbnail.png',
      );
      expect(keyPayload.thumbnailUrl, isEmpty);
    });
  });

  test('AttachmentItem 转消息 payload 时保留 thumbnailFileId 与临时 URL', () {
    const item = AttachmentItem(
      id: 'att_abc123',
      conversationId: 501,
      kind: 'image',
      name: 'photo.jpg',
      sizeLabel: '2.0 MB',
      status: 'uploaded',
      mime: 'image/jpeg',
      sizeBytes: 2048576,
      parseStatus: 'ready',
      thumbnailFileId: 'attachments/derived/att_abc123/thumbnail.png',
      thumbnailUrl: 'https://cdn.example.test/thumb.png',
    );

    final payload = item.toMessagePayload();
    expect(payload.thumbnailFileId, item.thumbnailFileId);
    expect(payload.thumbnailUrl, item.thumbnailUrl);
  });
}
