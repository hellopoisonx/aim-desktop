import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

class JsonStringListConverter extends TypeConverter<List<String>, String> {
  const JsonStringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const [];
    final decoded = jsonDecode(fromDb);
    if (decoded is! List) return const [];
    return decoded.map((item) => '$item').toList();
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

class JsonIntListConverter extends TypeConverter<List<int>, String> {
  const JsonIntListConverter();

  @override
  List<int> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const [];
    final decoded = jsonDecode(fromDb);
    if (decoded is! List) return const [];
    return decoded
        .map((item) => int.tryParse('$item') ?? 0)
        .where((item) => item > 0)
        .toList();
  }

  @override
  String toSql(List<int> value) => jsonEncode(value);
}

class JsonMapConverter extends TypeConverter<Map<String, dynamic>, String> {
  const JsonMapConverter();

  @override
  Map<String, dynamic> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const <String, dynamic>{};
    final decoded = jsonDecode(fromDb);
    if (decoded is! Map) return const <String, dynamic>{};
    return Map<String, dynamic>.from(decoded);
  }

  @override
  String toSql(Map<String, dynamic> value) => jsonEncode(value);
}

class NullableJsonMapConverter
    extends TypeConverter<Map<String, dynamic>?, String?> {
  const NullableJsonMapConverter();

  @override
  Map<String, dynamic>? fromSql(String? fromDb) {
    if (fromDb == null || fromDb.isEmpty) return null;
    final decoded = jsonDecode(fromDb);
    if (decoded is! Map) return null;
    return Map<String, dynamic>.from(decoded);
  }

  @override
  String? toSql(Map<String, dynamic>? value) {
    if (value == null) return null;
    return jsonEncode(value);
  }
}

@DataClassName('LocalMessageEntry')
@TableIndex(
  name: 'idx_local_messages_conversation_time',
  columns: {#conversationId, #createdAt},
)
@TableIndex(
  name: 'idx_local_messages_client_msg',
  columns: {#clientMsgId},
  unique: true,
)
class LocalMessages extends Table {
  IntColumn get messageId => integer()();

  TextColumn get clientMsgId => text().nullable().unique()();

  IntColumn get conversationId => integer()();

  IntColumn get senderId => integer()();

  TextColumn get senderName => text().withDefault(const Constant(''))();

  TextColumn get senderDisplayName => text().withDefault(const Constant(''))();

  TextColumn get senderEmail => text().withDefault(const Constant(''))();

  TextColumn get messageType => text()();

  TextColumn get content => text()();

  DateTimeColumn get createdAt => dateTime()();

  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();

  TextColumn get mentionsJson => text().withDefault(const Constant('[]'))();

  TextColumn get readByJson => text().withDefault(const Constant('[]'))();

  IntColumn get localStatus => integer().withDefault(const Constant(0))();

  BoolColumn get createdLocally =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get syncedAt => dateTime().nullable()();

  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {messageId};
}

@DataClassName('LocalReadStateEntry')
class LocalReadStates extends Table {
  IntColumn get conversationId => integer()();

  IntColumn get userId => integer()();

  IntColumn get lastReadMessageId => integer()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {conversationId, userId};
}

@DataClassName('LocalConversationEntry')
class LocalConversations extends Table {
  IntColumn get conversationId => integer()();

  IntColumn get ownerId => integer().nullable()();

  TextColumn get conversationType => text()();

  TextColumn get name => text()();

  TextColumn get avatarText => text().withDefault(const Constant(''))();

  TextColumn get memberIdsJson => text().withDefault(const Constant('[]'))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  TextColumn get lastMessagePreview => text().withDefault(const Constant(''))();

  IntColumn get unreadCount => integer().withDefault(const Constant(0))();

  IntColumn get typingUserId => integer().nullable()();

  BoolColumn get isMuted => boolean().withDefault(const Constant(false))();

  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  TextColumn get extraJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {conversationId};
}

@DataClassName('LocalAttachmentEntry')
class LocalAttachments extends Table {
  TextColumn get attachmentId => text()();

  IntColumn get conversationId => integer()();

  TextColumn get kind => text()();

  TextColumn get name => text()();

  TextColumn get mime => text()();

  IntColumn get sizeBytes => integer()();

  TextColumn get sizeLabel => text()();

  TextColumn get status => text()();

  TextColumn get parseStatus => text().withDefault(const Constant(''))();

  TextColumn get downloadUrl => text().withDefault(const Constant(''))();

  TextColumn get thumbnailUrl => text().withDefault(const Constant(''))();

  TextColumn get localPreviewDataUri =>
      text().withDefault(const Constant(''))();

  IntColumn get width => integer().nullable()();

  IntColumn get height => integer().nullable()();

  IntColumn get durationMs => integer().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {attachmentId};
}

@DriftDatabase(
  tables: [
    LocalMessages,
    LocalReadStates,
    LocalConversations,
    LocalAttachments,
  ],
)
class AimLocalDatabase extends _$AimLocalDatabase {
  AimLocalDatabase() : super(_openConnection());

  /// Test constructor that uses an in-memory database.
  factory AimLocalDatabase.test() {
    return AimLocalDatabase._internal(
      DatabaseConnection(NativeDatabase.memory()),
    );
  }

  AimLocalDatabase._internal(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // v2 aligns read states with the server schema:
        // PRIMARY KEY (conversation_id, user_id). The table only caches
        // server-authoritative cursors, so dropping stale v1 rows is safe.
        await m.deleteTable('local_read_states');
        await m.createTable(localReadStates);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
      await customStatement('PRAGMA synchronous = NORMAL');
    },
  );
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'aim_desktop_cache',
    native: const DriftNativeOptions(shareAcrossIsolates: true),
  );
}
