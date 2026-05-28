// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $LocalMessagesTable extends LocalMessages
    with TableInfo<$LocalMessagesTable, LocalMessageEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<int> messageId = GeneratedColumn<int>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientMsgIdMeta = const VerificationMeta(
    'clientMsgId',
  );
  @override
  late final GeneratedColumn<String> clientMsgId = GeneratedColumn<String>(
    'client_msg_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<int> senderId = GeneratedColumn<int>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderNameMeta = const VerificationMeta(
    'senderName',
  );
  @override
  late final GeneratedColumn<String> senderName = GeneratedColumn<String>(
    'sender_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _senderDisplayNameMeta = const VerificationMeta(
    'senderDisplayName',
  );
  @override
  late final GeneratedColumn<String> senderDisplayName =
      GeneratedColumn<String>(
        'sender_display_name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _senderEmailMeta = const VerificationMeta(
    'senderEmail',
  );
  @override
  late final GeneratedColumn<String> senderEmail = GeneratedColumn<String>(
    'sender_email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _messageTypeMeta = const VerificationMeta(
    'messageType',
  );
  @override
  late final GeneratedColumn<String> messageType = GeneratedColumn<String>(
    'message_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _mentionsJsonMeta = const VerificationMeta(
    'mentionsJson',
  );
  @override
  late final GeneratedColumn<String> mentionsJson = GeneratedColumn<String>(
    'mentions_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _readByJsonMeta = const VerificationMeta(
    'readByJson',
  );
  @override
  late final GeneratedColumn<String> readByJson = GeneratedColumn<String>(
    'read_by_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _localStatusMeta = const VerificationMeta(
    'localStatus',
  );
  @override
  late final GeneratedColumn<int> localStatus = GeneratedColumn<int>(
    'local_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdLocallyMeta = const VerificationMeta(
    'createdLocally',
  );
  @override
  late final GeneratedColumn<bool> createdLocally = GeneratedColumn<bool>(
    'created_locally',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("created_locally" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    messageId,
    clientMsgId,
    conversationId,
    senderId,
    senderName,
    senderDisplayName,
    senderEmail,
    messageType,
    content,
    createdAt,
    isSystem,
    mentionsJson,
    readByJson,
    localStatus,
    createdLocally,
    syncedAt,
    metadataJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalMessageEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    }
    if (data.containsKey('client_msg_id')) {
      context.handle(
        _clientMsgIdMeta,
        clientMsgId.isAcceptableOrUnknown(
          data['client_msg_id']!,
          _clientMsgIdMeta,
        ),
      );
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('sender_name')) {
      context.handle(
        _senderNameMeta,
        senderName.isAcceptableOrUnknown(data['sender_name']!, _senderNameMeta),
      );
    }
    if (data.containsKey('sender_display_name')) {
      context.handle(
        _senderDisplayNameMeta,
        senderDisplayName.isAcceptableOrUnknown(
          data['sender_display_name']!,
          _senderDisplayNameMeta,
        ),
      );
    }
    if (data.containsKey('sender_email')) {
      context.handle(
        _senderEmailMeta,
        senderEmail.isAcceptableOrUnknown(
          data['sender_email']!,
          _senderEmailMeta,
        ),
      );
    }
    if (data.containsKey('message_type')) {
      context.handle(
        _messageTypeMeta,
        messageType.isAcceptableOrUnknown(
          data['message_type']!,
          _messageTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_messageTypeMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('mentions_json')) {
      context.handle(
        _mentionsJsonMeta,
        mentionsJson.isAcceptableOrUnknown(
          data['mentions_json']!,
          _mentionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('read_by_json')) {
      context.handle(
        _readByJsonMeta,
        readByJson.isAcceptableOrUnknown(
          data['read_by_json']!,
          _readByJsonMeta,
        ),
      );
    }
    if (data.containsKey('local_status')) {
      context.handle(
        _localStatusMeta,
        localStatus.isAcceptableOrUnknown(
          data['local_status']!,
          _localStatusMeta,
        ),
      );
    }
    if (data.containsKey('created_locally')) {
      context.handle(
        _createdLocallyMeta,
        createdLocally.isAcceptableOrUnknown(
          data['created_locally']!,
          _createdLocallyMeta,
        ),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {messageId};
  @override
  LocalMessageEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMessageEntry(
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}message_id'],
      )!,
      clientMsgId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_msg_id'],
      ),
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conversation_id'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sender_id'],
      )!,
      senderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_name'],
      )!,
      senderDisplayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_display_name'],
      )!,
      senderEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_email'],
      )!,
      messageType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_type'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      mentionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mentions_json'],
      )!,
      readByJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}read_by_json'],
      )!,
      localStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_status'],
      )!,
      createdLocally: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}created_locally'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      )!,
    );
  }

  @override
  $LocalMessagesTable createAlias(String alias) {
    return $LocalMessagesTable(attachedDatabase, alias);
  }
}

class LocalMessageEntry extends DataClass
    implements Insertable<LocalMessageEntry> {
  final int messageId;
  final String? clientMsgId;
  final int conversationId;
  final int senderId;
  final String senderName;
  final String senderDisplayName;
  final String senderEmail;
  final String messageType;
  final String content;
  final DateTime createdAt;
  final bool isSystem;
  final String mentionsJson;
  final String readByJson;
  final int localStatus;
  final bool createdLocally;
  final DateTime? syncedAt;
  final String metadataJson;
  const LocalMessageEntry({
    required this.messageId,
    this.clientMsgId,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderDisplayName,
    required this.senderEmail,
    required this.messageType,
    required this.content,
    required this.createdAt,
    required this.isSystem,
    required this.mentionsJson,
    required this.readByJson,
    required this.localStatus,
    required this.createdLocally,
    this.syncedAt,
    required this.metadataJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['message_id'] = Variable<int>(messageId);
    if (!nullToAbsent || clientMsgId != null) {
      map['client_msg_id'] = Variable<String>(clientMsgId);
    }
    map['conversation_id'] = Variable<int>(conversationId);
    map['sender_id'] = Variable<int>(senderId);
    map['sender_name'] = Variable<String>(senderName);
    map['sender_display_name'] = Variable<String>(senderDisplayName);
    map['sender_email'] = Variable<String>(senderEmail);
    map['message_type'] = Variable<String>(messageType);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_system'] = Variable<bool>(isSystem);
    map['mentions_json'] = Variable<String>(mentionsJson);
    map['read_by_json'] = Variable<String>(readByJson);
    map['local_status'] = Variable<int>(localStatus);
    map['created_locally'] = Variable<bool>(createdLocally);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['metadata_json'] = Variable<String>(metadataJson);
    return map;
  }

  LocalMessagesCompanion toCompanion(bool nullToAbsent) {
    return LocalMessagesCompanion(
      messageId: Value(messageId),
      clientMsgId: clientMsgId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientMsgId),
      conversationId: Value(conversationId),
      senderId: Value(senderId),
      senderName: Value(senderName),
      senderDisplayName: Value(senderDisplayName),
      senderEmail: Value(senderEmail),
      messageType: Value(messageType),
      content: Value(content),
      createdAt: Value(createdAt),
      isSystem: Value(isSystem),
      mentionsJson: Value(mentionsJson),
      readByJson: Value(readByJson),
      localStatus: Value(localStatus),
      createdLocally: Value(createdLocally),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      metadataJson: Value(metadataJson),
    );
  }

  factory LocalMessageEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMessageEntry(
      messageId: serializer.fromJson<int>(json['messageId']),
      clientMsgId: serializer.fromJson<String?>(json['clientMsgId']),
      conversationId: serializer.fromJson<int>(json['conversationId']),
      senderId: serializer.fromJson<int>(json['senderId']),
      senderName: serializer.fromJson<String>(json['senderName']),
      senderDisplayName: serializer.fromJson<String>(json['senderDisplayName']),
      senderEmail: serializer.fromJson<String>(json['senderEmail']),
      messageType: serializer.fromJson<String>(json['messageType']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      mentionsJson: serializer.fromJson<String>(json['mentionsJson']),
      readByJson: serializer.fromJson<String>(json['readByJson']),
      localStatus: serializer.fromJson<int>(json['localStatus']),
      createdLocally: serializer.fromJson<bool>(json['createdLocally']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageId': serializer.toJson<int>(messageId),
      'clientMsgId': serializer.toJson<String?>(clientMsgId),
      'conversationId': serializer.toJson<int>(conversationId),
      'senderId': serializer.toJson<int>(senderId),
      'senderName': serializer.toJson<String>(senderName),
      'senderDisplayName': serializer.toJson<String>(senderDisplayName),
      'senderEmail': serializer.toJson<String>(senderEmail),
      'messageType': serializer.toJson<String>(messageType),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isSystem': serializer.toJson<bool>(isSystem),
      'mentionsJson': serializer.toJson<String>(mentionsJson),
      'readByJson': serializer.toJson<String>(readByJson),
      'localStatus': serializer.toJson<int>(localStatus),
      'createdLocally': serializer.toJson<bool>(createdLocally),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'metadataJson': serializer.toJson<String>(metadataJson),
    };
  }

  LocalMessageEntry copyWith({
    int? messageId,
    Value<String?> clientMsgId = const Value.absent(),
    int? conversationId,
    int? senderId,
    String? senderName,
    String? senderDisplayName,
    String? senderEmail,
    String? messageType,
    String? content,
    DateTime? createdAt,
    bool? isSystem,
    String? mentionsJson,
    String? readByJson,
    int? localStatus,
    bool? createdLocally,
    Value<DateTime?> syncedAt = const Value.absent(),
    String? metadataJson,
  }) => LocalMessageEntry(
    messageId: messageId ?? this.messageId,
    clientMsgId: clientMsgId.present ? clientMsgId.value : this.clientMsgId,
    conversationId: conversationId ?? this.conversationId,
    senderId: senderId ?? this.senderId,
    senderName: senderName ?? this.senderName,
    senderDisplayName: senderDisplayName ?? this.senderDisplayName,
    senderEmail: senderEmail ?? this.senderEmail,
    messageType: messageType ?? this.messageType,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
    isSystem: isSystem ?? this.isSystem,
    mentionsJson: mentionsJson ?? this.mentionsJson,
    readByJson: readByJson ?? this.readByJson,
    localStatus: localStatus ?? this.localStatus,
    createdLocally: createdLocally ?? this.createdLocally,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    metadataJson: metadataJson ?? this.metadataJson,
  );
  LocalMessageEntry copyWithCompanion(LocalMessagesCompanion data) {
    return LocalMessageEntry(
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      clientMsgId: data.clientMsgId.present
          ? data.clientMsgId.value
          : this.clientMsgId,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      senderName: data.senderName.present
          ? data.senderName.value
          : this.senderName,
      senderDisplayName: data.senderDisplayName.present
          ? data.senderDisplayName.value
          : this.senderDisplayName,
      senderEmail: data.senderEmail.present
          ? data.senderEmail.value
          : this.senderEmail,
      messageType: data.messageType.present
          ? data.messageType.value
          : this.messageType,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      mentionsJson: data.mentionsJson.present
          ? data.mentionsJson.value
          : this.mentionsJson,
      readByJson: data.readByJson.present
          ? data.readByJson.value
          : this.readByJson,
      localStatus: data.localStatus.present
          ? data.localStatus.value
          : this.localStatus,
      createdLocally: data.createdLocally.present
          ? data.createdLocally.value
          : this.createdLocally,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMessageEntry(')
          ..write('messageId: $messageId, ')
          ..write('clientMsgId: $clientMsgId, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('senderName: $senderName, ')
          ..write('senderDisplayName: $senderDisplayName, ')
          ..write('senderEmail: $senderEmail, ')
          ..write('messageType: $messageType, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSystem: $isSystem, ')
          ..write('mentionsJson: $mentionsJson, ')
          ..write('readByJson: $readByJson, ')
          ..write('localStatus: $localStatus, ')
          ..write('createdLocally: $createdLocally, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('metadataJson: $metadataJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    messageId,
    clientMsgId,
    conversationId,
    senderId,
    senderName,
    senderDisplayName,
    senderEmail,
    messageType,
    content,
    createdAt,
    isSystem,
    mentionsJson,
    readByJson,
    localStatus,
    createdLocally,
    syncedAt,
    metadataJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMessageEntry &&
          other.messageId == this.messageId &&
          other.clientMsgId == this.clientMsgId &&
          other.conversationId == this.conversationId &&
          other.senderId == this.senderId &&
          other.senderName == this.senderName &&
          other.senderDisplayName == this.senderDisplayName &&
          other.senderEmail == this.senderEmail &&
          other.messageType == this.messageType &&
          other.content == this.content &&
          other.createdAt == this.createdAt &&
          other.isSystem == this.isSystem &&
          other.mentionsJson == this.mentionsJson &&
          other.readByJson == this.readByJson &&
          other.localStatus == this.localStatus &&
          other.createdLocally == this.createdLocally &&
          other.syncedAt == this.syncedAt &&
          other.metadataJson == this.metadataJson);
}

class LocalMessagesCompanion extends UpdateCompanion<LocalMessageEntry> {
  final Value<int> messageId;
  final Value<String?> clientMsgId;
  final Value<int> conversationId;
  final Value<int> senderId;
  final Value<String> senderName;
  final Value<String> senderDisplayName;
  final Value<String> senderEmail;
  final Value<String> messageType;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<bool> isSystem;
  final Value<String> mentionsJson;
  final Value<String> readByJson;
  final Value<int> localStatus;
  final Value<bool> createdLocally;
  final Value<DateTime?> syncedAt;
  final Value<String> metadataJson;
  const LocalMessagesCompanion({
    this.messageId = const Value.absent(),
    this.clientMsgId = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.senderName = const Value.absent(),
    this.senderDisplayName = const Value.absent(),
    this.senderEmail = const Value.absent(),
    this.messageType = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.mentionsJson = const Value.absent(),
    this.readByJson = const Value.absent(),
    this.localStatus = const Value.absent(),
    this.createdLocally = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.metadataJson = const Value.absent(),
  });
  LocalMessagesCompanion.insert({
    this.messageId = const Value.absent(),
    this.clientMsgId = const Value.absent(),
    required int conversationId,
    required int senderId,
    this.senderName = const Value.absent(),
    this.senderDisplayName = const Value.absent(),
    this.senderEmail = const Value.absent(),
    required String messageType,
    required String content,
    required DateTime createdAt,
    this.isSystem = const Value.absent(),
    this.mentionsJson = const Value.absent(),
    this.readByJson = const Value.absent(),
    this.localStatus = const Value.absent(),
    this.createdLocally = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.metadataJson = const Value.absent(),
  }) : conversationId = Value(conversationId),
       senderId = Value(senderId),
       messageType = Value(messageType),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<LocalMessageEntry> custom({
    Expression<int>? messageId,
    Expression<String>? clientMsgId,
    Expression<int>? conversationId,
    Expression<int>? senderId,
    Expression<String>? senderName,
    Expression<String>? senderDisplayName,
    Expression<String>? senderEmail,
    Expression<String>? messageType,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSystem,
    Expression<String>? mentionsJson,
    Expression<String>? readByJson,
    Expression<int>? localStatus,
    Expression<bool>? createdLocally,
    Expression<DateTime>? syncedAt,
    Expression<String>? metadataJson,
  }) {
    return RawValuesInsertable({
      if (messageId != null) 'message_id': messageId,
      if (clientMsgId != null) 'client_msg_id': clientMsgId,
      if (conversationId != null) 'conversation_id': conversationId,
      if (senderId != null) 'sender_id': senderId,
      if (senderName != null) 'sender_name': senderName,
      if (senderDisplayName != null) 'sender_display_name': senderDisplayName,
      if (senderEmail != null) 'sender_email': senderEmail,
      if (messageType != null) 'message_type': messageType,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (isSystem != null) 'is_system': isSystem,
      if (mentionsJson != null) 'mentions_json': mentionsJson,
      if (readByJson != null) 'read_by_json': readByJson,
      if (localStatus != null) 'local_status': localStatus,
      if (createdLocally != null) 'created_locally': createdLocally,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (metadataJson != null) 'metadata_json': metadataJson,
    });
  }

  LocalMessagesCompanion copyWith({
    Value<int>? messageId,
    Value<String?>? clientMsgId,
    Value<int>? conversationId,
    Value<int>? senderId,
    Value<String>? senderName,
    Value<String>? senderDisplayName,
    Value<String>? senderEmail,
    Value<String>? messageType,
    Value<String>? content,
    Value<DateTime>? createdAt,
    Value<bool>? isSystem,
    Value<String>? mentionsJson,
    Value<String>? readByJson,
    Value<int>? localStatus,
    Value<bool>? createdLocally,
    Value<DateTime?>? syncedAt,
    Value<String>? metadataJson,
  }) {
    return LocalMessagesCompanion(
      messageId: messageId ?? this.messageId,
      clientMsgId: clientMsgId ?? this.clientMsgId,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderDisplayName: senderDisplayName ?? this.senderDisplayName,
      senderEmail: senderEmail ?? this.senderEmail,
      messageType: messageType ?? this.messageType,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isSystem: isSystem ?? this.isSystem,
      mentionsJson: mentionsJson ?? this.mentionsJson,
      readByJson: readByJson ?? this.readByJson,
      localStatus: localStatus ?? this.localStatus,
      createdLocally: createdLocally ?? this.createdLocally,
      syncedAt: syncedAt ?? this.syncedAt,
      metadataJson: metadataJson ?? this.metadataJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageId.present) {
      map['message_id'] = Variable<int>(messageId.value);
    }
    if (clientMsgId.present) {
      map['client_msg_id'] = Variable<String>(clientMsgId.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<int>(senderId.value);
    }
    if (senderName.present) {
      map['sender_name'] = Variable<String>(senderName.value);
    }
    if (senderDisplayName.present) {
      map['sender_display_name'] = Variable<String>(senderDisplayName.value);
    }
    if (senderEmail.present) {
      map['sender_email'] = Variable<String>(senderEmail.value);
    }
    if (messageType.present) {
      map['message_type'] = Variable<String>(messageType.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (mentionsJson.present) {
      map['mentions_json'] = Variable<String>(mentionsJson.value);
    }
    if (readByJson.present) {
      map['read_by_json'] = Variable<String>(readByJson.value);
    }
    if (localStatus.present) {
      map['local_status'] = Variable<int>(localStatus.value);
    }
    if (createdLocally.present) {
      map['created_locally'] = Variable<bool>(createdLocally.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMessagesCompanion(')
          ..write('messageId: $messageId, ')
          ..write('clientMsgId: $clientMsgId, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('senderName: $senderName, ')
          ..write('senderDisplayName: $senderDisplayName, ')
          ..write('senderEmail: $senderEmail, ')
          ..write('messageType: $messageType, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSystem: $isSystem, ')
          ..write('mentionsJson: $mentionsJson, ')
          ..write('readByJson: $readByJson, ')
          ..write('localStatus: $localStatus, ')
          ..write('createdLocally: $createdLocally, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('metadataJson: $metadataJson')
          ..write(')'))
        .toString();
  }
}

class $LocalReadStatesTable extends LocalReadStates
    with TableInfo<$LocalReadStatesTable, LocalReadStateEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalReadStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastReadMessageIdMeta = const VerificationMeta(
    'lastReadMessageId',
  );
  @override
  late final GeneratedColumn<int> lastReadMessageId = GeneratedColumn<int>(
    'last_read_message_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    conversationId,
    userId,
    lastReadMessageId,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_read_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalReadStateEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('last_read_message_id')) {
      context.handle(
        _lastReadMessageIdMeta,
        lastReadMessageId.isAcceptableOrUnknown(
          data['last_read_message_id']!,
          _lastReadMessageIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastReadMessageIdMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {conversationId};
  @override
  LocalReadStateEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalReadStateEntry(
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conversation_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      lastReadMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_read_message_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalReadStatesTable createAlias(String alias) {
    return $LocalReadStatesTable(attachedDatabase, alias);
  }
}

class LocalReadStateEntry extends DataClass
    implements Insertable<LocalReadStateEntry> {
  final int conversationId;
  final int userId;
  final int lastReadMessageId;
  final DateTime updatedAt;
  const LocalReadStateEntry({
    required this.conversationId,
    required this.userId,
    required this.lastReadMessageId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['conversation_id'] = Variable<int>(conversationId);
    map['user_id'] = Variable<int>(userId);
    map['last_read_message_id'] = Variable<int>(lastReadMessageId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalReadStatesCompanion toCompanion(bool nullToAbsent) {
    return LocalReadStatesCompanion(
      conversationId: Value(conversationId),
      userId: Value(userId),
      lastReadMessageId: Value(lastReadMessageId),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalReadStateEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalReadStateEntry(
      conversationId: serializer.fromJson<int>(json['conversationId']),
      userId: serializer.fromJson<int>(json['userId']),
      lastReadMessageId: serializer.fromJson<int>(json['lastReadMessageId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'conversationId': serializer.toJson<int>(conversationId),
      'userId': serializer.toJson<int>(userId),
      'lastReadMessageId': serializer.toJson<int>(lastReadMessageId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalReadStateEntry copyWith({
    int? conversationId,
    int? userId,
    int? lastReadMessageId,
    DateTime? updatedAt,
  }) => LocalReadStateEntry(
    conversationId: conversationId ?? this.conversationId,
    userId: userId ?? this.userId,
    lastReadMessageId: lastReadMessageId ?? this.lastReadMessageId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalReadStateEntry copyWithCompanion(LocalReadStatesCompanion data) {
    return LocalReadStateEntry(
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      userId: data.userId.present ? data.userId.value : this.userId,
      lastReadMessageId: data.lastReadMessageId.present
          ? data.lastReadMessageId.value
          : this.lastReadMessageId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalReadStateEntry(')
          ..write('conversationId: $conversationId, ')
          ..write('userId: $userId, ')
          ..write('lastReadMessageId: $lastReadMessageId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(conversationId, userId, lastReadMessageId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalReadStateEntry &&
          other.conversationId == this.conversationId &&
          other.userId == this.userId &&
          other.lastReadMessageId == this.lastReadMessageId &&
          other.updatedAt == this.updatedAt);
}

class LocalReadStatesCompanion extends UpdateCompanion<LocalReadStateEntry> {
  final Value<int> conversationId;
  final Value<int> userId;
  final Value<int> lastReadMessageId;
  final Value<DateTime> updatedAt;
  const LocalReadStatesCompanion({
    this.conversationId = const Value.absent(),
    this.userId = const Value.absent(),
    this.lastReadMessageId = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LocalReadStatesCompanion.insert({
    this.conversationId = const Value.absent(),
    required int userId,
    required int lastReadMessageId,
    required DateTime updatedAt,
  }) : userId = Value(userId),
       lastReadMessageId = Value(lastReadMessageId),
       updatedAt = Value(updatedAt);
  static Insertable<LocalReadStateEntry> custom({
    Expression<int>? conversationId,
    Expression<int>? userId,
    Expression<int>? lastReadMessageId,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (conversationId != null) 'conversation_id': conversationId,
      if (userId != null) 'user_id': userId,
      if (lastReadMessageId != null) 'last_read_message_id': lastReadMessageId,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LocalReadStatesCompanion copyWith({
    Value<int>? conversationId,
    Value<int>? userId,
    Value<int>? lastReadMessageId,
    Value<DateTime>? updatedAt,
  }) {
    return LocalReadStatesCompanion(
      conversationId: conversationId ?? this.conversationId,
      userId: userId ?? this.userId,
      lastReadMessageId: lastReadMessageId ?? this.lastReadMessageId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (lastReadMessageId.present) {
      map['last_read_message_id'] = Variable<int>(lastReadMessageId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalReadStatesCompanion(')
          ..write('conversationId: $conversationId, ')
          ..write('userId: $userId, ')
          ..write('lastReadMessageId: $lastReadMessageId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalConversationsTable extends LocalConversations
    with TableInfo<$LocalConversationsTable, LocalConversationEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<int> ownerId = GeneratedColumn<int>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conversationTypeMeta = const VerificationMeta(
    'conversationType',
  );
  @override
  late final GeneratedColumn<String> conversationType = GeneratedColumn<String>(
    'conversation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarTextMeta = const VerificationMeta(
    'avatarText',
  );
  @override
  late final GeneratedColumn<String> avatarText = GeneratedColumn<String>(
    'avatar_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _memberIdsJsonMeta = const VerificationMeta(
    'memberIdsJson',
  );
  @override
  late final GeneratedColumn<String> memberIdsJson = GeneratedColumn<String>(
    'member_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastMessagePreviewMeta =
      const VerificationMeta('lastMessagePreview');
  @override
  late final GeneratedColumn<String> lastMessagePreview =
      GeneratedColumn<String>(
        'last_message_preview',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _unreadCountMeta = const VerificationMeta(
    'unreadCount',
  );
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
    'unread_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _typingUserIdMeta = const VerificationMeta(
    'typingUserId',
  );
  @override
  late final GeneratedColumn<int> typingUserId = GeneratedColumn<int>(
    'typing_user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isMutedMeta = const VerificationMeta(
    'isMuted',
  );
  @override
  late final GeneratedColumn<bool> isMuted = GeneratedColumn<bool>(
    'is_muted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_muted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _extraJsonMeta = const VerificationMeta(
    'extraJson',
  );
  @override
  late final GeneratedColumn<String> extraJson = GeneratedColumn<String>(
    'extra_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    conversationId,
    ownerId,
    conversationType,
    name,
    avatarText,
    memberIdsJson,
    createdAt,
    updatedAt,
    lastMessagePreview,
    unreadCount,
    typingUserId,
    isMuted,
    isPinned,
    isActive,
    extraJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalConversationEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('conversation_type')) {
      context.handle(
        _conversationTypeMeta,
        conversationType.isAcceptableOrUnknown(
          data['conversation_type']!,
          _conversationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationTypeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar_text')) {
      context.handle(
        _avatarTextMeta,
        avatarText.isAcceptableOrUnknown(data['avatar_text']!, _avatarTextMeta),
      );
    }
    if (data.containsKey('member_ids_json')) {
      context.handle(
        _memberIdsJsonMeta,
        memberIdsJson.isAcceptableOrUnknown(
          data['member_ids_json']!,
          _memberIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_message_preview')) {
      context.handle(
        _lastMessagePreviewMeta,
        lastMessagePreview.isAcceptableOrUnknown(
          data['last_message_preview']!,
          _lastMessagePreviewMeta,
        ),
      );
    }
    if (data.containsKey('unread_count')) {
      context.handle(
        _unreadCountMeta,
        unreadCount.isAcceptableOrUnknown(
          data['unread_count']!,
          _unreadCountMeta,
        ),
      );
    }
    if (data.containsKey('typing_user_id')) {
      context.handle(
        _typingUserIdMeta,
        typingUserId.isAcceptableOrUnknown(
          data['typing_user_id']!,
          _typingUserIdMeta,
        ),
      );
    }
    if (data.containsKey('is_muted')) {
      context.handle(
        _isMutedMeta,
        isMuted.isAcceptableOrUnknown(data['is_muted']!, _isMutedMeta),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('extra_json')) {
      context.handle(
        _extraJsonMeta,
        extraJson.isAcceptableOrUnknown(data['extra_json']!, _extraJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {conversationId};
  @override
  LocalConversationEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalConversationEntry(
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conversation_id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}owner_id'],
      ),
      conversationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_type'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      avatarText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_text'],
      )!,
      memberIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_ids_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastMessagePreview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message_preview'],
      )!,
      unreadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unread_count'],
      )!,
      typingUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}typing_user_id'],
      ),
      isMuted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_muted'],
      )!,
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      extraJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extra_json'],
      )!,
    );
  }

  @override
  $LocalConversationsTable createAlias(String alias) {
    return $LocalConversationsTable(attachedDatabase, alias);
  }
}

class LocalConversationEntry extends DataClass
    implements Insertable<LocalConversationEntry> {
  final int conversationId;
  final int? ownerId;
  final String conversationType;
  final String name;
  final String avatarText;
  final String memberIdsJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String lastMessagePreview;
  final int unreadCount;
  final int? typingUserId;
  final bool isMuted;
  final bool isPinned;
  final bool isActive;
  final String extraJson;
  const LocalConversationEntry({
    required this.conversationId,
    this.ownerId,
    required this.conversationType,
    required this.name,
    required this.avatarText,
    required this.memberIdsJson,
    required this.createdAt,
    required this.updatedAt,
    required this.lastMessagePreview,
    required this.unreadCount,
    this.typingUserId,
    required this.isMuted,
    required this.isPinned,
    required this.isActive,
    required this.extraJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['conversation_id'] = Variable<int>(conversationId);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<int>(ownerId);
    }
    map['conversation_type'] = Variable<String>(conversationType);
    map['name'] = Variable<String>(name);
    map['avatar_text'] = Variable<String>(avatarText);
    map['member_ids_json'] = Variable<String>(memberIdsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['last_message_preview'] = Variable<String>(lastMessagePreview);
    map['unread_count'] = Variable<int>(unreadCount);
    if (!nullToAbsent || typingUserId != null) {
      map['typing_user_id'] = Variable<int>(typingUserId);
    }
    map['is_muted'] = Variable<bool>(isMuted);
    map['is_pinned'] = Variable<bool>(isPinned);
    map['is_active'] = Variable<bool>(isActive);
    map['extra_json'] = Variable<String>(extraJson);
    return map;
  }

  LocalConversationsCompanion toCompanion(bool nullToAbsent) {
    return LocalConversationsCompanion(
      conversationId: Value(conversationId),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      conversationType: Value(conversationType),
      name: Value(name),
      avatarText: Value(avatarText),
      memberIdsJson: Value(memberIdsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastMessagePreview: Value(lastMessagePreview),
      unreadCount: Value(unreadCount),
      typingUserId: typingUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(typingUserId),
      isMuted: Value(isMuted),
      isPinned: Value(isPinned),
      isActive: Value(isActive),
      extraJson: Value(extraJson),
    );
  }

  factory LocalConversationEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalConversationEntry(
      conversationId: serializer.fromJson<int>(json['conversationId']),
      ownerId: serializer.fromJson<int?>(json['ownerId']),
      conversationType: serializer.fromJson<String>(json['conversationType']),
      name: serializer.fromJson<String>(json['name']),
      avatarText: serializer.fromJson<String>(json['avatarText']),
      memberIdsJson: serializer.fromJson<String>(json['memberIdsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastMessagePreview: serializer.fromJson<String>(
        json['lastMessagePreview'],
      ),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      typingUserId: serializer.fromJson<int?>(json['typingUserId']),
      isMuted: serializer.fromJson<bool>(json['isMuted']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      extraJson: serializer.fromJson<String>(json['extraJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'conversationId': serializer.toJson<int>(conversationId),
      'ownerId': serializer.toJson<int?>(ownerId),
      'conversationType': serializer.toJson<String>(conversationType),
      'name': serializer.toJson<String>(name),
      'avatarText': serializer.toJson<String>(avatarText),
      'memberIdsJson': serializer.toJson<String>(memberIdsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastMessagePreview': serializer.toJson<String>(lastMessagePreview),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'typingUserId': serializer.toJson<int?>(typingUserId),
      'isMuted': serializer.toJson<bool>(isMuted),
      'isPinned': serializer.toJson<bool>(isPinned),
      'isActive': serializer.toJson<bool>(isActive),
      'extraJson': serializer.toJson<String>(extraJson),
    };
  }

  LocalConversationEntry copyWith({
    int? conversationId,
    Value<int?> ownerId = const Value.absent(),
    String? conversationType,
    String? name,
    String? avatarText,
    String? memberIdsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessagePreview,
    int? unreadCount,
    Value<int?> typingUserId = const Value.absent(),
    bool? isMuted,
    bool? isPinned,
    bool? isActive,
    String? extraJson,
  }) => LocalConversationEntry(
    conversationId: conversationId ?? this.conversationId,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    conversationType: conversationType ?? this.conversationType,
    name: name ?? this.name,
    avatarText: avatarText ?? this.avatarText,
    memberIdsJson: memberIdsJson ?? this.memberIdsJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
    unreadCount: unreadCount ?? this.unreadCount,
    typingUserId: typingUserId.present ? typingUserId.value : this.typingUserId,
    isMuted: isMuted ?? this.isMuted,
    isPinned: isPinned ?? this.isPinned,
    isActive: isActive ?? this.isActive,
    extraJson: extraJson ?? this.extraJson,
  );
  LocalConversationEntry copyWithCompanion(LocalConversationsCompanion data) {
    return LocalConversationEntry(
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      conversationType: data.conversationType.present
          ? data.conversationType.value
          : this.conversationType,
      name: data.name.present ? data.name.value : this.name,
      avatarText: data.avatarText.present
          ? data.avatarText.value
          : this.avatarText,
      memberIdsJson: data.memberIdsJson.present
          ? data.memberIdsJson.value
          : this.memberIdsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastMessagePreview: data.lastMessagePreview.present
          ? data.lastMessagePreview.value
          : this.lastMessagePreview,
      unreadCount: data.unreadCount.present
          ? data.unreadCount.value
          : this.unreadCount,
      typingUserId: data.typingUserId.present
          ? data.typingUserId.value
          : this.typingUserId,
      isMuted: data.isMuted.present ? data.isMuted.value : this.isMuted,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      extraJson: data.extraJson.present ? data.extraJson.value : this.extraJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalConversationEntry(')
          ..write('conversationId: $conversationId, ')
          ..write('ownerId: $ownerId, ')
          ..write('conversationType: $conversationType, ')
          ..write('name: $name, ')
          ..write('avatarText: $avatarText, ')
          ..write('memberIdsJson: $memberIdsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastMessagePreview: $lastMessagePreview, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('typingUserId: $typingUserId, ')
          ..write('isMuted: $isMuted, ')
          ..write('isPinned: $isPinned, ')
          ..write('isActive: $isActive, ')
          ..write('extraJson: $extraJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    conversationId,
    ownerId,
    conversationType,
    name,
    avatarText,
    memberIdsJson,
    createdAt,
    updatedAt,
    lastMessagePreview,
    unreadCount,
    typingUserId,
    isMuted,
    isPinned,
    isActive,
    extraJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalConversationEntry &&
          other.conversationId == this.conversationId &&
          other.ownerId == this.ownerId &&
          other.conversationType == this.conversationType &&
          other.name == this.name &&
          other.avatarText == this.avatarText &&
          other.memberIdsJson == this.memberIdsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastMessagePreview == this.lastMessagePreview &&
          other.unreadCount == this.unreadCount &&
          other.typingUserId == this.typingUserId &&
          other.isMuted == this.isMuted &&
          other.isPinned == this.isPinned &&
          other.isActive == this.isActive &&
          other.extraJson == this.extraJson);
}

class LocalConversationsCompanion
    extends UpdateCompanion<LocalConversationEntry> {
  final Value<int> conversationId;
  final Value<int?> ownerId;
  final Value<String> conversationType;
  final Value<String> name;
  final Value<String> avatarText;
  final Value<String> memberIdsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> lastMessagePreview;
  final Value<int> unreadCount;
  final Value<int?> typingUserId;
  final Value<bool> isMuted;
  final Value<bool> isPinned;
  final Value<bool> isActive;
  final Value<String> extraJson;
  const LocalConversationsCompanion({
    this.conversationId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.conversationType = const Value.absent(),
    this.name = const Value.absent(),
    this.avatarText = const Value.absent(),
    this.memberIdsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastMessagePreview = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.typingUserId = const Value.absent(),
    this.isMuted = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.isActive = const Value.absent(),
    this.extraJson = const Value.absent(),
  });
  LocalConversationsCompanion.insert({
    this.conversationId = const Value.absent(),
    this.ownerId = const Value.absent(),
    required String conversationType,
    required String name,
    this.avatarText = const Value.absent(),
    this.memberIdsJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.lastMessagePreview = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.typingUserId = const Value.absent(),
    this.isMuted = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.isActive = const Value.absent(),
    this.extraJson = const Value.absent(),
  }) : conversationType = Value(conversationType),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalConversationEntry> custom({
    Expression<int>? conversationId,
    Expression<int>? ownerId,
    Expression<String>? conversationType,
    Expression<String>? name,
    Expression<String>? avatarText,
    Expression<String>? memberIdsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? lastMessagePreview,
    Expression<int>? unreadCount,
    Expression<int>? typingUserId,
    Expression<bool>? isMuted,
    Expression<bool>? isPinned,
    Expression<bool>? isActive,
    Expression<String>? extraJson,
  }) {
    return RawValuesInsertable({
      if (conversationId != null) 'conversation_id': conversationId,
      if (ownerId != null) 'owner_id': ownerId,
      if (conversationType != null) 'conversation_type': conversationType,
      if (name != null) 'name': name,
      if (avatarText != null) 'avatar_text': avatarText,
      if (memberIdsJson != null) 'member_ids_json': memberIdsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastMessagePreview != null)
        'last_message_preview': lastMessagePreview,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (typingUserId != null) 'typing_user_id': typingUserId,
      if (isMuted != null) 'is_muted': isMuted,
      if (isPinned != null) 'is_pinned': isPinned,
      if (isActive != null) 'is_active': isActive,
      if (extraJson != null) 'extra_json': extraJson,
    });
  }

  LocalConversationsCompanion copyWith({
    Value<int>? conversationId,
    Value<int?>? ownerId,
    Value<String>? conversationType,
    Value<String>? name,
    Value<String>? avatarText,
    Value<String>? memberIdsJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? lastMessagePreview,
    Value<int>? unreadCount,
    Value<int?>? typingUserId,
    Value<bool>? isMuted,
    Value<bool>? isPinned,
    Value<bool>? isActive,
    Value<String>? extraJson,
  }) {
    return LocalConversationsCompanion(
      conversationId: conversationId ?? this.conversationId,
      ownerId: ownerId ?? this.ownerId,
      conversationType: conversationType ?? this.conversationType,
      name: name ?? this.name,
      avatarText: avatarText ?? this.avatarText,
      memberIdsJson: memberIdsJson ?? this.memberIdsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      unreadCount: unreadCount ?? this.unreadCount,
      typingUserId: typingUserId ?? this.typingUserId,
      isMuted: isMuted ?? this.isMuted,
      isPinned: isPinned ?? this.isPinned,
      isActive: isActive ?? this.isActive,
      extraJson: extraJson ?? this.extraJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<int>(ownerId.value);
    }
    if (conversationType.present) {
      map['conversation_type'] = Variable<String>(conversationType.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatarText.present) {
      map['avatar_text'] = Variable<String>(avatarText.value);
    }
    if (memberIdsJson.present) {
      map['member_ids_json'] = Variable<String>(memberIdsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastMessagePreview.present) {
      map['last_message_preview'] = Variable<String>(lastMessagePreview.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (typingUserId.present) {
      map['typing_user_id'] = Variable<int>(typingUserId.value);
    }
    if (isMuted.present) {
      map['is_muted'] = Variable<bool>(isMuted.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (extraJson.present) {
      map['extra_json'] = Variable<String>(extraJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalConversationsCompanion(')
          ..write('conversationId: $conversationId, ')
          ..write('ownerId: $ownerId, ')
          ..write('conversationType: $conversationType, ')
          ..write('name: $name, ')
          ..write('avatarText: $avatarText, ')
          ..write('memberIdsJson: $memberIdsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastMessagePreview: $lastMessagePreview, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('typingUserId: $typingUserId, ')
          ..write('isMuted: $isMuted, ')
          ..write('isPinned: $isPinned, ')
          ..write('isActive: $isActive, ')
          ..write('extraJson: $extraJson')
          ..write(')'))
        .toString();
  }
}

class $LocalAttachmentsTable extends LocalAttachments
    with TableInfo<$LocalAttachmentsTable, LocalAttachmentEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _attachmentIdMeta = const VerificationMeta(
    'attachmentId',
  );
  @override
  late final GeneratedColumn<String> attachmentId = GeneratedColumn<String>(
    'attachment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeMeta = const VerificationMeta('mime');
  @override
  late final GeneratedColumn<String> mime = GeneratedColumn<String>(
    'mime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeLabelMeta = const VerificationMeta(
    'sizeLabel',
  );
  @override
  late final GeneratedColumn<String> sizeLabel = GeneratedColumn<String>(
    'size_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parseStatusMeta = const VerificationMeta(
    'parseStatus',
  );
  @override
  late final GeneratedColumn<String> parseStatus = GeneratedColumn<String>(
    'parse_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _downloadUrlMeta = const VerificationMeta(
    'downloadUrl',
  );
  @override
  late final GeneratedColumn<String> downloadUrl = GeneratedColumn<String>(
    'download_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _localPreviewDataUriMeta =
      const VerificationMeta('localPreviewDataUri');
  @override
  late final GeneratedColumn<String> localPreviewDataUri =
      GeneratedColumn<String>(
        'local_preview_data_uri',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    attachmentId,
    conversationId,
    kind,
    name,
    mime,
    sizeBytes,
    sizeLabel,
    status,
    parseStatus,
    downloadUrl,
    thumbnailUrl,
    localPreviewDataUri,
    width,
    height,
    durationMs,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAttachmentEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('attachment_id')) {
      context.handle(
        _attachmentIdMeta,
        attachmentId.isAcceptableOrUnknown(
          data['attachment_id']!,
          _attachmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attachmentIdMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('mime')) {
      context.handle(
        _mimeMeta,
        mime.isAcceptableOrUnknown(data['mime']!, _mimeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('size_label')) {
      context.handle(
        _sizeLabelMeta,
        sizeLabel.isAcceptableOrUnknown(data['size_label']!, _sizeLabelMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeLabelMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('parse_status')) {
      context.handle(
        _parseStatusMeta,
        parseStatus.isAcceptableOrUnknown(
          data['parse_status']!,
          _parseStatusMeta,
        ),
      );
    }
    if (data.containsKey('download_url')) {
      context.handle(
        _downloadUrlMeta,
        downloadUrl.isAcceptableOrUnknown(
          data['download_url']!,
          _downloadUrlMeta,
        ),
      );
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('local_preview_data_uri')) {
      context.handle(
        _localPreviewDataUriMeta,
        localPreviewDataUri.isAcceptableOrUnknown(
          data['local_preview_data_uri']!,
          _localPreviewDataUriMeta,
        ),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {attachmentId};
  @override
  LocalAttachmentEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAttachmentEntry(
      attachmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conversation_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      mime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      sizeLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}size_label'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      parseStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parse_status'],
      )!,
      downloadUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}download_url'],
      )!,
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      )!,
      localPreviewDataUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_preview_data_uri'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalAttachmentsTable createAlias(String alias) {
    return $LocalAttachmentsTable(attachedDatabase, alias);
  }
}

class LocalAttachmentEntry extends DataClass
    implements Insertable<LocalAttachmentEntry> {
  final String attachmentId;
  final int conversationId;
  final String kind;
  final String name;
  final String mime;
  final int sizeBytes;
  final String sizeLabel;
  final String status;
  final String parseStatus;
  final String downloadUrl;
  final String thumbnailUrl;
  final String localPreviewDataUri;
  final int? width;
  final int? height;
  final int? durationMs;
  final DateTime createdAt;
  const LocalAttachmentEntry({
    required this.attachmentId,
    required this.conversationId,
    required this.kind,
    required this.name,
    required this.mime,
    required this.sizeBytes,
    required this.sizeLabel,
    required this.status,
    required this.parseStatus,
    required this.downloadUrl,
    required this.thumbnailUrl,
    required this.localPreviewDataUri,
    this.width,
    this.height,
    this.durationMs,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['attachment_id'] = Variable<String>(attachmentId);
    map['conversation_id'] = Variable<int>(conversationId);
    map['kind'] = Variable<String>(kind);
    map['name'] = Variable<String>(name);
    map['mime'] = Variable<String>(mime);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['size_label'] = Variable<String>(sizeLabel);
    map['status'] = Variable<String>(status);
    map['parse_status'] = Variable<String>(parseStatus);
    map['download_url'] = Variable<String>(downloadUrl);
    map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    map['local_preview_data_uri'] = Variable<String>(localPreviewDataUri);
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return LocalAttachmentsCompanion(
      attachmentId: Value(attachmentId),
      conversationId: Value(conversationId),
      kind: Value(kind),
      name: Value(name),
      mime: Value(mime),
      sizeBytes: Value(sizeBytes),
      sizeLabel: Value(sizeLabel),
      status: Value(status),
      parseStatus: Value(parseStatus),
      downloadUrl: Value(downloadUrl),
      thumbnailUrl: Value(thumbnailUrl),
      localPreviewDataUri: Value(localPreviewDataUri),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      createdAt: Value(createdAt),
    );
  }

  factory LocalAttachmentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAttachmentEntry(
      attachmentId: serializer.fromJson<String>(json['attachmentId']),
      conversationId: serializer.fromJson<int>(json['conversationId']),
      kind: serializer.fromJson<String>(json['kind']),
      name: serializer.fromJson<String>(json['name']),
      mime: serializer.fromJson<String>(json['mime']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      sizeLabel: serializer.fromJson<String>(json['sizeLabel']),
      status: serializer.fromJson<String>(json['status']),
      parseStatus: serializer.fromJson<String>(json['parseStatus']),
      downloadUrl: serializer.fromJson<String>(json['downloadUrl']),
      thumbnailUrl: serializer.fromJson<String>(json['thumbnailUrl']),
      localPreviewDataUri: serializer.fromJson<String>(
        json['localPreviewDataUri'],
      ),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'attachmentId': serializer.toJson<String>(attachmentId),
      'conversationId': serializer.toJson<int>(conversationId),
      'kind': serializer.toJson<String>(kind),
      'name': serializer.toJson<String>(name),
      'mime': serializer.toJson<String>(mime),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'sizeLabel': serializer.toJson<String>(sizeLabel),
      'status': serializer.toJson<String>(status),
      'parseStatus': serializer.toJson<String>(parseStatus),
      'downloadUrl': serializer.toJson<String>(downloadUrl),
      'thumbnailUrl': serializer.toJson<String>(thumbnailUrl),
      'localPreviewDataUri': serializer.toJson<String>(localPreviewDataUri),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'durationMs': serializer.toJson<int?>(durationMs),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalAttachmentEntry copyWith({
    String? attachmentId,
    int? conversationId,
    String? kind,
    String? name,
    String? mime,
    int? sizeBytes,
    String? sizeLabel,
    String? status,
    String? parseStatus,
    String? downloadUrl,
    String? thumbnailUrl,
    String? localPreviewDataUri,
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    DateTime? createdAt,
  }) => LocalAttachmentEntry(
    attachmentId: attachmentId ?? this.attachmentId,
    conversationId: conversationId ?? this.conversationId,
    kind: kind ?? this.kind,
    name: name ?? this.name,
    mime: mime ?? this.mime,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    sizeLabel: sizeLabel ?? this.sizeLabel,
    status: status ?? this.status,
    parseStatus: parseStatus ?? this.parseStatus,
    downloadUrl: downloadUrl ?? this.downloadUrl,
    thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    localPreviewDataUri: localPreviewDataUri ?? this.localPreviewDataUri,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalAttachmentEntry copyWithCompanion(LocalAttachmentsCompanion data) {
    return LocalAttachmentEntry(
      attachmentId: data.attachmentId.present
          ? data.attachmentId.value
          : this.attachmentId,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      kind: data.kind.present ? data.kind.value : this.kind,
      name: data.name.present ? data.name.value : this.name,
      mime: data.mime.present ? data.mime.value : this.mime,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      sizeLabel: data.sizeLabel.present ? data.sizeLabel.value : this.sizeLabel,
      status: data.status.present ? data.status.value : this.status,
      parseStatus: data.parseStatus.present
          ? data.parseStatus.value
          : this.parseStatus,
      downloadUrl: data.downloadUrl.present
          ? data.downloadUrl.value
          : this.downloadUrl,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      localPreviewDataUri: data.localPreviewDataUri.present
          ? data.localPreviewDataUri.value
          : this.localPreviewDataUri,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAttachmentEntry(')
          ..write('attachmentId: $attachmentId, ')
          ..write('conversationId: $conversationId, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('mime: $mime, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('sizeLabel: $sizeLabel, ')
          ..write('status: $status, ')
          ..write('parseStatus: $parseStatus, ')
          ..write('downloadUrl: $downloadUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('localPreviewDataUri: $localPreviewDataUri, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('durationMs: $durationMs, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    attachmentId,
    conversationId,
    kind,
    name,
    mime,
    sizeBytes,
    sizeLabel,
    status,
    parseStatus,
    downloadUrl,
    thumbnailUrl,
    localPreviewDataUri,
    width,
    height,
    durationMs,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAttachmentEntry &&
          other.attachmentId == this.attachmentId &&
          other.conversationId == this.conversationId &&
          other.kind == this.kind &&
          other.name == this.name &&
          other.mime == this.mime &&
          other.sizeBytes == this.sizeBytes &&
          other.sizeLabel == this.sizeLabel &&
          other.status == this.status &&
          other.parseStatus == this.parseStatus &&
          other.downloadUrl == this.downloadUrl &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.localPreviewDataUri == this.localPreviewDataUri &&
          other.width == this.width &&
          other.height == this.height &&
          other.durationMs == this.durationMs &&
          other.createdAt == this.createdAt);
}

class LocalAttachmentsCompanion extends UpdateCompanion<LocalAttachmentEntry> {
  final Value<String> attachmentId;
  final Value<int> conversationId;
  final Value<String> kind;
  final Value<String> name;
  final Value<String> mime;
  final Value<int> sizeBytes;
  final Value<String> sizeLabel;
  final Value<String> status;
  final Value<String> parseStatus;
  final Value<String> downloadUrl;
  final Value<String> thumbnailUrl;
  final Value<String> localPreviewDataUri;
  final Value<int?> width;
  final Value<int?> height;
  final Value<int?> durationMs;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalAttachmentsCompanion({
    this.attachmentId = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.kind = const Value.absent(),
    this.name = const Value.absent(),
    this.mime = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.sizeLabel = const Value.absent(),
    this.status = const Value.absent(),
    this.parseStatus = const Value.absent(),
    this.downloadUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.localPreviewDataUri = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAttachmentsCompanion.insert({
    required String attachmentId,
    required int conversationId,
    required String kind,
    required String name,
    required String mime,
    required int sizeBytes,
    required String sizeLabel,
    required String status,
    this.parseStatus = const Value.absent(),
    this.downloadUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.localPreviewDataUri = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.durationMs = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : attachmentId = Value(attachmentId),
       conversationId = Value(conversationId),
       kind = Value(kind),
       name = Value(name),
       mime = Value(mime),
       sizeBytes = Value(sizeBytes),
       sizeLabel = Value(sizeLabel),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<LocalAttachmentEntry> custom({
    Expression<String>? attachmentId,
    Expression<int>? conversationId,
    Expression<String>? kind,
    Expression<String>? name,
    Expression<String>? mime,
    Expression<int>? sizeBytes,
    Expression<String>? sizeLabel,
    Expression<String>? status,
    Expression<String>? parseStatus,
    Expression<String>? downloadUrl,
    Expression<String>? thumbnailUrl,
    Expression<String>? localPreviewDataUri,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? durationMs,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (attachmentId != null) 'attachment_id': attachmentId,
      if (conversationId != null) 'conversation_id': conversationId,
      if (kind != null) 'kind': kind,
      if (name != null) 'name': name,
      if (mime != null) 'mime': mime,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (sizeLabel != null) 'size_label': sizeLabel,
      if (status != null) 'status': status,
      if (parseStatus != null) 'parse_status': parseStatus,
      if (downloadUrl != null) 'download_url': downloadUrl,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (localPreviewDataUri != null)
        'local_preview_data_uri': localPreviewDataUri,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (durationMs != null) 'duration_ms': durationMs,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAttachmentsCompanion copyWith({
    Value<String>? attachmentId,
    Value<int>? conversationId,
    Value<String>? kind,
    Value<String>? name,
    Value<String>? mime,
    Value<int>? sizeBytes,
    Value<String>? sizeLabel,
    Value<String>? status,
    Value<String>? parseStatus,
    Value<String>? downloadUrl,
    Value<String>? thumbnailUrl,
    Value<String>? localPreviewDataUri,
    Value<int?>? width,
    Value<int?>? height,
    Value<int?>? durationMs,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalAttachmentsCompanion(
      attachmentId: attachmentId ?? this.attachmentId,
      conversationId: conversationId ?? this.conversationId,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      mime: mime ?? this.mime,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      sizeLabel: sizeLabel ?? this.sizeLabel,
      status: status ?? this.status,
      parseStatus: parseStatus ?? this.parseStatus,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      localPreviewDataUri: localPreviewDataUri ?? this.localPreviewDataUri,
      width: width ?? this.width,
      height: height ?? this.height,
      durationMs: durationMs ?? this.durationMs,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (attachmentId.present) {
      map['attachment_id'] = Variable<String>(attachmentId.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (mime.present) {
      map['mime'] = Variable<String>(mime.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (sizeLabel.present) {
      map['size_label'] = Variable<String>(sizeLabel.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (parseStatus.present) {
      map['parse_status'] = Variable<String>(parseStatus.value);
    }
    if (downloadUrl.present) {
      map['download_url'] = Variable<String>(downloadUrl.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (localPreviewDataUri.present) {
      map['local_preview_data_uri'] = Variable<String>(
        localPreviewDataUri.value,
      );
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAttachmentsCompanion(')
          ..write('attachmentId: $attachmentId, ')
          ..write('conversationId: $conversationId, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('mime: $mime, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('sizeLabel: $sizeLabel, ')
          ..write('status: $status, ')
          ..write('parseStatus: $parseStatus, ')
          ..write('downloadUrl: $downloadUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('localPreviewDataUri: $localPreviewDataUri, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('durationMs: $durationMs, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AimLocalDatabase extends GeneratedDatabase {
  _$AimLocalDatabase(QueryExecutor e) : super(e);
  $AimLocalDatabaseManager get managers => $AimLocalDatabaseManager(this);
  late final $LocalMessagesTable localMessages = $LocalMessagesTable(this);
  late final $LocalReadStatesTable localReadStates = $LocalReadStatesTable(
    this,
  );
  late final $LocalConversationsTable localConversations =
      $LocalConversationsTable(this);
  late final $LocalAttachmentsTable localAttachments = $LocalAttachmentsTable(
    this,
  );
  late final Index idxLocalMessagesConversationTime = Index(
    'idx_local_messages_conversation_time',
    'CREATE INDEX idx_local_messages_conversation_time ON local_messages (conversation_id, created_at)',
  );
  late final Index idxLocalMessagesClientMsg = Index(
    'idx_local_messages_client_msg',
    'CREATE UNIQUE INDEX idx_local_messages_client_msg ON local_messages (client_msg_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localMessages,
    localReadStates,
    localConversations,
    localAttachments,
    idxLocalMessagesConversationTime,
    idxLocalMessagesClientMsg,
  ];
}

typedef $$LocalMessagesTableCreateCompanionBuilder =
    LocalMessagesCompanion Function({
      Value<int> messageId,
      Value<String?> clientMsgId,
      required int conversationId,
      required int senderId,
      Value<String> senderName,
      Value<String> senderDisplayName,
      Value<String> senderEmail,
      required String messageType,
      required String content,
      required DateTime createdAt,
      Value<bool> isSystem,
      Value<String> mentionsJson,
      Value<String> readByJson,
      Value<int> localStatus,
      Value<bool> createdLocally,
      Value<DateTime?> syncedAt,
      Value<String> metadataJson,
    });
typedef $$LocalMessagesTableUpdateCompanionBuilder =
    LocalMessagesCompanion Function({
      Value<int> messageId,
      Value<String?> clientMsgId,
      Value<int> conversationId,
      Value<int> senderId,
      Value<String> senderName,
      Value<String> senderDisplayName,
      Value<String> senderEmail,
      Value<String> messageType,
      Value<String> content,
      Value<DateTime> createdAt,
      Value<bool> isSystem,
      Value<String> mentionsJson,
      Value<String> readByJson,
      Value<int> localStatus,
      Value<bool> createdLocally,
      Value<DateTime?> syncedAt,
      Value<String> metadataJson,
    });

class $$LocalMessagesTableFilterComposer
    extends Composer<_$AimLocalDatabase, $LocalMessagesTable> {
  $$LocalMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientMsgId => $composableBuilder(
    column: $table.clientMsgId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderDisplayName => $composableBuilder(
    column: $table.senderDisplayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderEmail => $composableBuilder(
    column: $table.senderEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mentionsJson => $composableBuilder(
    column: $table.mentionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get readByJson => $composableBuilder(
    column: $table.readByJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localStatus => $composableBuilder(
    column: $table.localStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get createdLocally => $composableBuilder(
    column: $table.createdLocally,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalMessagesTableOrderingComposer
    extends Composer<_$AimLocalDatabase, $LocalMessagesTable> {
  $$LocalMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientMsgId => $composableBuilder(
    column: $table.clientMsgId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderDisplayName => $composableBuilder(
    column: $table.senderDisplayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderEmail => $composableBuilder(
    column: $table.senderEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mentionsJson => $composableBuilder(
    column: $table.mentionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get readByJson => $composableBuilder(
    column: $table.readByJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localStatus => $composableBuilder(
    column: $table.localStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get createdLocally => $composableBuilder(
    column: $table.createdLocally,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalMessagesTableAnnotationComposer
    extends Composer<_$AimLocalDatabase, $LocalMessagesTable> {
  $$LocalMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get clientMsgId => $composableBuilder(
    column: $table.clientMsgId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderDisplayName => $composableBuilder(
    column: $table.senderDisplayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderEmail => $composableBuilder(
    column: $table.senderEmail,
    builder: (column) => column,
  );

  GeneratedColumn<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<String> get mentionsJson => $composableBuilder(
    column: $table.mentionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get readByJson => $composableBuilder(
    column: $table.readByJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localStatus => $composableBuilder(
    column: $table.localStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get createdLocally => $composableBuilder(
    column: $table.createdLocally,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );
}

class $$LocalMessagesTableTableManager
    extends
        RootTableManager<
          _$AimLocalDatabase,
          $LocalMessagesTable,
          LocalMessageEntry,
          $$LocalMessagesTableFilterComposer,
          $$LocalMessagesTableOrderingComposer,
          $$LocalMessagesTableAnnotationComposer,
          $$LocalMessagesTableCreateCompanionBuilder,
          $$LocalMessagesTableUpdateCompanionBuilder,
          (
            LocalMessageEntry,
            BaseReferences<
              _$AimLocalDatabase,
              $LocalMessagesTable,
              LocalMessageEntry
            >,
          ),
          LocalMessageEntry,
          PrefetchHooks Function()
        > {
  $$LocalMessagesTableTableManager(
    _$AimLocalDatabase db,
    $LocalMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> messageId = const Value.absent(),
                Value<String?> clientMsgId = const Value.absent(),
                Value<int> conversationId = const Value.absent(),
                Value<int> senderId = const Value.absent(),
                Value<String> senderName = const Value.absent(),
                Value<String> senderDisplayName = const Value.absent(),
                Value<String> senderEmail = const Value.absent(),
                Value<String> messageType = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<String> mentionsJson = const Value.absent(),
                Value<String> readByJson = const Value.absent(),
                Value<int> localStatus = const Value.absent(),
                Value<bool> createdLocally = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
              }) => LocalMessagesCompanion(
                messageId: messageId,
                clientMsgId: clientMsgId,
                conversationId: conversationId,
                senderId: senderId,
                senderName: senderName,
                senderDisplayName: senderDisplayName,
                senderEmail: senderEmail,
                messageType: messageType,
                content: content,
                createdAt: createdAt,
                isSystem: isSystem,
                mentionsJson: mentionsJson,
                readByJson: readByJson,
                localStatus: localStatus,
                createdLocally: createdLocally,
                syncedAt: syncedAt,
                metadataJson: metadataJson,
              ),
          createCompanionCallback:
              ({
                Value<int> messageId = const Value.absent(),
                Value<String?> clientMsgId = const Value.absent(),
                required int conversationId,
                required int senderId,
                Value<String> senderName = const Value.absent(),
                Value<String> senderDisplayName = const Value.absent(),
                Value<String> senderEmail = const Value.absent(),
                required String messageType,
                required String content,
                required DateTime createdAt,
                Value<bool> isSystem = const Value.absent(),
                Value<String> mentionsJson = const Value.absent(),
                Value<String> readByJson = const Value.absent(),
                Value<int> localStatus = const Value.absent(),
                Value<bool> createdLocally = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
              }) => LocalMessagesCompanion.insert(
                messageId: messageId,
                clientMsgId: clientMsgId,
                conversationId: conversationId,
                senderId: senderId,
                senderName: senderName,
                senderDisplayName: senderDisplayName,
                senderEmail: senderEmail,
                messageType: messageType,
                content: content,
                createdAt: createdAt,
                isSystem: isSystem,
                mentionsJson: mentionsJson,
                readByJson: readByJson,
                localStatus: localStatus,
                createdLocally: createdLocally,
                syncedAt: syncedAt,
                metadataJson: metadataJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AimLocalDatabase,
      $LocalMessagesTable,
      LocalMessageEntry,
      $$LocalMessagesTableFilterComposer,
      $$LocalMessagesTableOrderingComposer,
      $$LocalMessagesTableAnnotationComposer,
      $$LocalMessagesTableCreateCompanionBuilder,
      $$LocalMessagesTableUpdateCompanionBuilder,
      (
        LocalMessageEntry,
        BaseReferences<
          _$AimLocalDatabase,
          $LocalMessagesTable,
          LocalMessageEntry
        >,
      ),
      LocalMessageEntry,
      PrefetchHooks Function()
    >;
typedef $$LocalReadStatesTableCreateCompanionBuilder =
    LocalReadStatesCompanion Function({
      Value<int> conversationId,
      required int userId,
      required int lastReadMessageId,
      required DateTime updatedAt,
    });
typedef $$LocalReadStatesTableUpdateCompanionBuilder =
    LocalReadStatesCompanion Function({
      Value<int> conversationId,
      Value<int> userId,
      Value<int> lastReadMessageId,
      Value<DateTime> updatedAt,
    });

class $$LocalReadStatesTableFilterComposer
    extends Composer<_$AimLocalDatabase, $LocalReadStatesTable> {
  $$LocalReadStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastReadMessageId => $composableBuilder(
    column: $table.lastReadMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalReadStatesTableOrderingComposer
    extends Composer<_$AimLocalDatabase, $LocalReadStatesTable> {
  $$LocalReadStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastReadMessageId => $composableBuilder(
    column: $table.lastReadMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalReadStatesTableAnnotationComposer
    extends Composer<_$AimLocalDatabase, $LocalReadStatesTable> {
  $$LocalReadStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get lastReadMessageId => $composableBuilder(
    column: $table.lastReadMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalReadStatesTableTableManager
    extends
        RootTableManager<
          _$AimLocalDatabase,
          $LocalReadStatesTable,
          LocalReadStateEntry,
          $$LocalReadStatesTableFilterComposer,
          $$LocalReadStatesTableOrderingComposer,
          $$LocalReadStatesTableAnnotationComposer,
          $$LocalReadStatesTableCreateCompanionBuilder,
          $$LocalReadStatesTableUpdateCompanionBuilder,
          (
            LocalReadStateEntry,
            BaseReferences<
              _$AimLocalDatabase,
              $LocalReadStatesTable,
              LocalReadStateEntry
            >,
          ),
          LocalReadStateEntry,
          PrefetchHooks Function()
        > {
  $$LocalReadStatesTableTableManager(
    _$AimLocalDatabase db,
    $LocalReadStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalReadStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalReadStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalReadStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> conversationId = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<int> lastReadMessageId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LocalReadStatesCompanion(
                conversationId: conversationId,
                userId: userId,
                lastReadMessageId: lastReadMessageId,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> conversationId = const Value.absent(),
                required int userId,
                required int lastReadMessageId,
                required DateTime updatedAt,
              }) => LocalReadStatesCompanion.insert(
                conversationId: conversationId,
                userId: userId,
                lastReadMessageId: lastReadMessageId,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalReadStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AimLocalDatabase,
      $LocalReadStatesTable,
      LocalReadStateEntry,
      $$LocalReadStatesTableFilterComposer,
      $$LocalReadStatesTableOrderingComposer,
      $$LocalReadStatesTableAnnotationComposer,
      $$LocalReadStatesTableCreateCompanionBuilder,
      $$LocalReadStatesTableUpdateCompanionBuilder,
      (
        LocalReadStateEntry,
        BaseReferences<
          _$AimLocalDatabase,
          $LocalReadStatesTable,
          LocalReadStateEntry
        >,
      ),
      LocalReadStateEntry,
      PrefetchHooks Function()
    >;
typedef $$LocalConversationsTableCreateCompanionBuilder =
    LocalConversationsCompanion Function({
      Value<int> conversationId,
      Value<int?> ownerId,
      required String conversationType,
      required String name,
      Value<String> avatarText,
      Value<String> memberIdsJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String> lastMessagePreview,
      Value<int> unreadCount,
      Value<int?> typingUserId,
      Value<bool> isMuted,
      Value<bool> isPinned,
      Value<bool> isActive,
      Value<String> extraJson,
    });
typedef $$LocalConversationsTableUpdateCompanionBuilder =
    LocalConversationsCompanion Function({
      Value<int> conversationId,
      Value<int?> ownerId,
      Value<String> conversationType,
      Value<String> name,
      Value<String> avatarText,
      Value<String> memberIdsJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> lastMessagePreview,
      Value<int> unreadCount,
      Value<int?> typingUserId,
      Value<bool> isMuted,
      Value<bool> isPinned,
      Value<bool> isActive,
      Value<String> extraJson,
    });

class $$LocalConversationsTableFilterComposer
    extends Composer<_$AimLocalDatabase, $LocalConversationsTable> {
  $$LocalConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conversationType => $composableBuilder(
    column: $table.conversationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarText => $composableBuilder(
    column: $table.avatarText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberIdsJson => $composableBuilder(
    column: $table.memberIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessagePreview => $composableBuilder(
    column: $table.lastMessagePreview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get typingUserId => $composableBuilder(
    column: $table.typingUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMuted => $composableBuilder(
    column: $table.isMuted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extraJson => $composableBuilder(
    column: $table.extraJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalConversationsTableOrderingComposer
    extends Composer<_$AimLocalDatabase, $LocalConversationsTable> {
  $$LocalConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conversationType => $composableBuilder(
    column: $table.conversationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarText => $composableBuilder(
    column: $table.avatarText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberIdsJson => $composableBuilder(
    column: $table.memberIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessagePreview => $composableBuilder(
    column: $table.lastMessagePreview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get typingUserId => $composableBuilder(
    column: $table.typingUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMuted => $composableBuilder(
    column: $table.isMuted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extraJson => $composableBuilder(
    column: $table.extraJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalConversationsTableAnnotationComposer
    extends Composer<_$AimLocalDatabase, $LocalConversationsTable> {
  $$LocalConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get conversationType => $composableBuilder(
    column: $table.conversationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatarText => $composableBuilder(
    column: $table.avatarText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memberIdsJson => $composableBuilder(
    column: $table.memberIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get lastMessagePreview => $composableBuilder(
    column: $table.lastMessagePreview,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get typingUserId => $composableBuilder(
    column: $table.typingUserId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isMuted =>
      $composableBuilder(column: $table.isMuted, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get extraJson =>
      $composableBuilder(column: $table.extraJson, builder: (column) => column);
}

class $$LocalConversationsTableTableManager
    extends
        RootTableManager<
          _$AimLocalDatabase,
          $LocalConversationsTable,
          LocalConversationEntry,
          $$LocalConversationsTableFilterComposer,
          $$LocalConversationsTableOrderingComposer,
          $$LocalConversationsTableAnnotationComposer,
          $$LocalConversationsTableCreateCompanionBuilder,
          $$LocalConversationsTableUpdateCompanionBuilder,
          (
            LocalConversationEntry,
            BaseReferences<
              _$AimLocalDatabase,
              $LocalConversationsTable,
              LocalConversationEntry
            >,
          ),
          LocalConversationEntry,
          PrefetchHooks Function()
        > {
  $$LocalConversationsTableTableManager(
    _$AimLocalDatabase db,
    $LocalConversationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalConversationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> conversationId = const Value.absent(),
                Value<int?> ownerId = const Value.absent(),
                Value<String> conversationType = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> avatarText = const Value.absent(),
                Value<String> memberIdsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> lastMessagePreview = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<int?> typingUserId = const Value.absent(),
                Value<bool> isMuted = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> extraJson = const Value.absent(),
              }) => LocalConversationsCompanion(
                conversationId: conversationId,
                ownerId: ownerId,
                conversationType: conversationType,
                name: name,
                avatarText: avatarText,
                memberIdsJson: memberIdsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastMessagePreview: lastMessagePreview,
                unreadCount: unreadCount,
                typingUserId: typingUserId,
                isMuted: isMuted,
                isPinned: isPinned,
                isActive: isActive,
                extraJson: extraJson,
              ),
          createCompanionCallback:
              ({
                Value<int> conversationId = const Value.absent(),
                Value<int?> ownerId = const Value.absent(),
                required String conversationType,
                required String name,
                Value<String> avatarText = const Value.absent(),
                Value<String> memberIdsJson = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String> lastMessagePreview = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<int?> typingUserId = const Value.absent(),
                Value<bool> isMuted = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> extraJson = const Value.absent(),
              }) => LocalConversationsCompanion.insert(
                conversationId: conversationId,
                ownerId: ownerId,
                conversationType: conversationType,
                name: name,
                avatarText: avatarText,
                memberIdsJson: memberIdsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastMessagePreview: lastMessagePreview,
                unreadCount: unreadCount,
                typingUserId: typingUserId,
                isMuted: isMuted,
                isPinned: isPinned,
                isActive: isActive,
                extraJson: extraJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalConversationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AimLocalDatabase,
      $LocalConversationsTable,
      LocalConversationEntry,
      $$LocalConversationsTableFilterComposer,
      $$LocalConversationsTableOrderingComposer,
      $$LocalConversationsTableAnnotationComposer,
      $$LocalConversationsTableCreateCompanionBuilder,
      $$LocalConversationsTableUpdateCompanionBuilder,
      (
        LocalConversationEntry,
        BaseReferences<
          _$AimLocalDatabase,
          $LocalConversationsTable,
          LocalConversationEntry
        >,
      ),
      LocalConversationEntry,
      PrefetchHooks Function()
    >;
typedef $$LocalAttachmentsTableCreateCompanionBuilder =
    LocalAttachmentsCompanion Function({
      required String attachmentId,
      required int conversationId,
      required String kind,
      required String name,
      required String mime,
      required int sizeBytes,
      required String sizeLabel,
      required String status,
      Value<String> parseStatus,
      Value<String> downloadUrl,
      Value<String> thumbnailUrl,
      Value<String> localPreviewDataUri,
      Value<int?> width,
      Value<int?> height,
      Value<int?> durationMs,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LocalAttachmentsTableUpdateCompanionBuilder =
    LocalAttachmentsCompanion Function({
      Value<String> attachmentId,
      Value<int> conversationId,
      Value<String> kind,
      Value<String> name,
      Value<String> mime,
      Value<int> sizeBytes,
      Value<String> sizeLabel,
      Value<String> status,
      Value<String> parseStatus,
      Value<String> downloadUrl,
      Value<String> thumbnailUrl,
      Value<String> localPreviewDataUri,
      Value<int?> width,
      Value<int?> height,
      Value<int?> durationMs,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalAttachmentsTableFilterComposer
    extends Composer<_$AimLocalDatabase, $LocalAttachmentsTable> {
  $$LocalAttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get attachmentId => $composableBuilder(
    column: $table.attachmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sizeLabel => $composableBuilder(
    column: $table.sizeLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parseStatus => $composableBuilder(
    column: $table.parseStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get downloadUrl => $composableBuilder(
    column: $table.downloadUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPreviewDataUri => $composableBuilder(
    column: $table.localPreviewDataUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAttachmentsTableOrderingComposer
    extends Composer<_$AimLocalDatabase, $LocalAttachmentsTable> {
  $$LocalAttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get attachmentId => $composableBuilder(
    column: $table.attachmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sizeLabel => $composableBuilder(
    column: $table.sizeLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parseStatus => $composableBuilder(
    column: $table.parseStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get downloadUrl => $composableBuilder(
    column: $table.downloadUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPreviewDataUri => $composableBuilder(
    column: $table.localPreviewDataUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAttachmentsTableAnnotationComposer
    extends Composer<_$AimLocalDatabase, $LocalAttachmentsTable> {
  $$LocalAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get attachmentId => $composableBuilder(
    column: $table.attachmentId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get mime =>
      $composableBuilder(column: $table.mime, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get sizeLabel =>
      $composableBuilder(column: $table.sizeLabel, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get parseStatus => $composableBuilder(
    column: $table.parseStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get downloadUrl => $composableBuilder(
    column: $table.downloadUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPreviewDataUri => $composableBuilder(
    column: $table.localPreviewDataUri,
    builder: (column) => column,
  );

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalAttachmentsTableTableManager
    extends
        RootTableManager<
          _$AimLocalDatabase,
          $LocalAttachmentsTable,
          LocalAttachmentEntry,
          $$LocalAttachmentsTableFilterComposer,
          $$LocalAttachmentsTableOrderingComposer,
          $$LocalAttachmentsTableAnnotationComposer,
          $$LocalAttachmentsTableCreateCompanionBuilder,
          $$LocalAttachmentsTableUpdateCompanionBuilder,
          (
            LocalAttachmentEntry,
            BaseReferences<
              _$AimLocalDatabase,
              $LocalAttachmentsTable,
              LocalAttachmentEntry
            >,
          ),
          LocalAttachmentEntry,
          PrefetchHooks Function()
        > {
  $$LocalAttachmentsTableTableManager(
    _$AimLocalDatabase db,
    $LocalAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> attachmentId = const Value.absent(),
                Value<int> conversationId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> mime = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String> sizeLabel = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> parseStatus = const Value.absent(),
                Value<String> downloadUrl = const Value.absent(),
                Value<String> thumbnailUrl = const Value.absent(),
                Value<String> localPreviewDataUri = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAttachmentsCompanion(
                attachmentId: attachmentId,
                conversationId: conversationId,
                kind: kind,
                name: name,
                mime: mime,
                sizeBytes: sizeBytes,
                sizeLabel: sizeLabel,
                status: status,
                parseStatus: parseStatus,
                downloadUrl: downloadUrl,
                thumbnailUrl: thumbnailUrl,
                localPreviewDataUri: localPreviewDataUri,
                width: width,
                height: height,
                durationMs: durationMs,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String attachmentId,
                required int conversationId,
                required String kind,
                required String name,
                required String mime,
                required int sizeBytes,
                required String sizeLabel,
                required String status,
                Value<String> parseStatus = const Value.absent(),
                Value<String> downloadUrl = const Value.absent(),
                Value<String> thumbnailUrl = const Value.absent(),
                Value<String> localPreviewDataUri = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalAttachmentsCompanion.insert(
                attachmentId: attachmentId,
                conversationId: conversationId,
                kind: kind,
                name: name,
                mime: mime,
                sizeBytes: sizeBytes,
                sizeLabel: sizeLabel,
                status: status,
                parseStatus: parseStatus,
                downloadUrl: downloadUrl,
                thumbnailUrl: thumbnailUrl,
                localPreviewDataUri: localPreviewDataUri,
                width: width,
                height: height,
                durationMs: durationMs,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AimLocalDatabase,
      $LocalAttachmentsTable,
      LocalAttachmentEntry,
      $$LocalAttachmentsTableFilterComposer,
      $$LocalAttachmentsTableOrderingComposer,
      $$LocalAttachmentsTableAnnotationComposer,
      $$LocalAttachmentsTableCreateCompanionBuilder,
      $$LocalAttachmentsTableUpdateCompanionBuilder,
      (
        LocalAttachmentEntry,
        BaseReferences<
          _$AimLocalDatabase,
          $LocalAttachmentsTable,
          LocalAttachmentEntry
        >,
      ),
      LocalAttachmentEntry,
      PrefetchHooks Function()
    >;

class $AimLocalDatabaseManager {
  final _$AimLocalDatabase _db;
  $AimLocalDatabaseManager(this._db);
  $$LocalMessagesTableTableManager get localMessages =>
      $$LocalMessagesTableTableManager(_db, _db.localMessages);
  $$LocalReadStatesTableTableManager get localReadStates =>
      $$LocalReadStatesTableTableManager(_db, _db.localReadStates);
  $$LocalConversationsTableTableManager get localConversations =>
      $$LocalConversationsTableTableManager(_db, _db.localConversations);
  $$LocalAttachmentsTableTableManager get localAttachments =>
      $$LocalAttachmentsTableTableManager(_db, _db.localAttachments);
}
