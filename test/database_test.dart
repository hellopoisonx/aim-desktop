import 'package:aim_desktop/src/data/database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AimLocalDatabase db;

  setUp(() {
    db = AimLocalDatabase.test();
  });

  tearDown(() async {
    await db.close();
  });

  test('local_messages 表可插入和查询', () async {
    final entry = LocalMessagesCompanion(
      messageId: const Value(10001),
      conversationId: const Value(501),
      senderId: const Value(2001),
      senderName: const Value('Alice'),
      messageType: const Value('text'),
      content: const Value('测试消息'),
      createdAt: Value(DateTime.now()),
      localStatus: const Value(0),
    );

    await db.into(db.localMessages).insertOnConflictUpdate(entry);

    final rows = await (db.select(
      db.localMessages,
    )..where((tbl) => tbl.messageId.equals(10001))).get();
    expect(rows.length, 1);
    expect(rows.first.content, '测试消息');
    expect(rows.first.messageType, 'text');
  });

  test('local_messages 去重（主键冲突 upsert）', () async {
    final entry1 = LocalMessagesCompanion(
      messageId: const Value(10002),
      conversationId: const Value(501),
      senderId: const Value(2001),
      senderName: const Value('Alice'),
      messageType: const Value('text'),
      content: const Value('原始'),
      createdAt: Value(DateTime.now()),
      localStatus: const Value(0),
    );

    final entry2 = LocalMessagesCompanion(
      messageId: const Value(10002),
      conversationId: const Value(501),
      senderId: const Value(2001),
      senderName: const Value('Alice'),
      messageType: const Value('text'),
      content: const Value('更新后的内容'),
      createdAt: Value(DateTime.now()),
      localStatus: const Value(1),
    );

    await db.into(db.localMessages).insertOnConflictUpdate(entry1);
    await db.into(db.localMessages).insertOnConflictUpdate(entry2);

    final rows = await (db.select(
      db.localMessages,
    )..where((tbl) => tbl.messageId.equals(10002))).get();
    expect(rows.length, 1);
    expect(rows.first.content, '更新后的内容');
  });

  test('local_conversations 可插入和查询', () async {
    final entry = LocalConversationsCompanion(
      conversationId: const Value(501),
      conversationType: const Value('direct'),
      name: const Value('AIM Demo'),
      avatarText: const Value('AD'),
      memberIdsJson: const Value('[]'),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    await db.into(db.localConversations).insertOnConflictUpdate(entry);

    final rows = await (db.select(
      db.localConversations,
    )..where((tbl) => tbl.conversationId.equals(501))).get();
    expect(rows.length, 1);
    expect(rows.first.name, 'AIM Demo');
  });

  test('local_read_states 可插入和查询', () async {
    final entry = LocalReadStatesCompanion(
      conversationId: const Value(501),
      userId: const Value(2001),
      lastReadMessageId: const Value(90005),
      updatedAt: Value(DateTime.now()),
    );

    await db.into(db.localReadStates).insertOnConflictUpdate(entry);

    final rows = await (db.select(
      db.localReadStates,
    )..where((tbl) => tbl.conversationId.equals(501))).get();
    expect(rows.length, 1);
    expect(rows.first.lastReadMessageId, 90005);
  });

  test('local_read_states 以 conversation_id + user_id 作为复合主键', () async {
    final now = DateTime.now();
    await db
        .into(db.localReadStates)
        .insertOnConflictUpdate(
          LocalReadStatesCompanion(
            conversationId: const Value(501),
            userId: const Value(2001),
            lastReadMessageId: const Value(90005),
            updatedAt: Value(now),
          ),
        );
    await db
        .into(db.localReadStates)
        .insertOnConflictUpdate(
          LocalReadStatesCompanion(
            conversationId: const Value(501),
            userId: const Value(2002),
            lastReadMessageId: const Value(90003),
            updatedAt: Value(now),
          ),
        );
    await db
        .into(db.localReadStates)
        .insertOnConflictUpdate(
          LocalReadStatesCompanion(
            conversationId: const Value(501),
            userId: const Value(2001),
            lastReadMessageId: const Value(90006),
            updatedAt: Value(now),
          ),
        );

    final rows = await (db.select(
      db.localReadStates,
    )..where((tbl) => tbl.conversationId.equals(501))).get();
    expect(rows.length, 2);
    expect(
      rows.firstWhere((row) => row.userId == 2001).lastReadMessageId,
      90006,
    );
  });
}
