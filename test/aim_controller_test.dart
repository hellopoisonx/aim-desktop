import 'dart:typed_data';

import 'package:aim_desktop/src/aim_controller.dart';
import 'package:aim_desktop/src/data/gateway_realtime_client.dart';
import 'package:aim_desktop/src/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_aim_repository.dart';

void main() {
  test('控制器覆盖认证、聊天、好友、群组与附件链路', () async {
    final repository = FakeAimRepository();
    final controller = AimController(
      repository: repository,
      tokenStorage: MemoryTokenStorage(),
    );
    addTearDown(controller.dispose);

    await controller.login(email: 'user@example.test', password: 'secret1234');
    expect(controller.state.isAuthenticated, isTrue);
    expect(controller.state.conversations, isNotEmpty);

    controller.selectConversation(501);
    await controller.sendTextMessage('控制器链路测试消息');
    expect(controller.state.messagesFor(501).last.content, '控制器链路测试消息');
    expect(controller.state.messagesFor(501).last.isFailed, isFalse);

    final searchResults = await controller.searchUsers('NewFriend');
    expect(searchResults, isNotEmpty);
    expect(searchResults.first.nickname, 'NewFriend');

    await controller.addFriend(searchResults.first);
    final request = controller.state.friendRequests.first;
    expect(request.user.nickname, 'NewFriend');

    await controller.acceptFriend(request.id);
    expect(
      controller.state.friends.any((item) => item.user.nickname == 'NewFriend'),
      isTrue,
    );

    final newFriendship = controller.state.friends.firstWhere(
      (item) => item.user.nickname == 'NewFriend',
    );
    await controller.startDirectConversation(newFriendship);
    expect(controller.state.selectedConversation?.name, 'NewFriend');
    expect(
      controller.state.selectedConversation?.memberIds.contains(
        newFriendship.user.id,
      ),
      isTrue,
    );

    final memberIds = controller.state.friends
        .take(2)
        .map((item) => item.user.id)
        .toList();
    await controller.createGroup(name: '测试群聊', memberIds: memberIds);
    final group = controller.state.selectedConversation!;
    expect(group.name, '测试群聊');

    final invitee = controller.state.friends.firstWhere(
      (item) => !group.memberIds.contains(item.user.id),
    );
    await controller.addGroupMembers(group.id, [invitee.user.id]);
    expect(
      controller.state.selectedConversation?.memberIds.contains(
        invitee.user.id,
      ),
      isTrue,
    );

    await controller.grantGroupAdmin(group.id, invitee.user.id);
    expect(controller.state.notice, '管理员权限已授予');

    await controller.revokeGroupAdmin(group.id, invitee.user.id);
    expect(controller.state.notice, '管理员权限已撤销');

    await controller.transferGroupOwner(group.id, invitee.user.id);
    expect(controller.state.selectedConversation?.ownerId, invitee.user.id);

    await controller.removeGroupMember(group.id, memberIds.first);
    expect(
      controller.state.selectedConversation?.memberIds.contains(
        memberIds.first,
      ),
      isFalse,
    );

    await controller.sendAttachment(
      kind: 'image',
      originalName: 'screenshot.png',
      mime: 'image/png',
      bytes: Uint8List(16),
      size: 16,
    );
    expect(controller.state.attachments.first.name, 'screenshot.png');

    await controller.updateGroupName(group.id, '改名后的群聊');
    expect(controller.state.selectedConversation?.name, '改名后的群聊');

    await controller.dismissGroup(group.id);
    expect(controller.state.selectedConversation?.isActive, isFalse);

    await repository.close();
  });

  test('收到新会话消息时刷新左侧会话列表', () async {
    final repository = FakeAimRepository();
    final controller = AimController(
      repository: repository,
      tokenStorage: MemoryTokenStorage(),
    );
    addTearDown(controller.dispose);

    await controller.login(email: 'user@example.test', password: 'secret1234');
    final beforeCount = controller.state.conversations.length;

    repository.emit(
      RealtimeMessageEvent(
        messageId: 99001,
        conversationId: 990,
        messageType: 'text',
        content: '新会话消息',
        senderId: 3001,
        sentAt: DateTime.now().millisecondsSinceEpoch,
        conversationType: 'direct',
        clientMessageId: 'push-new-conversation-1',
        isSystem: false,
        senderDisplayName: '新用户',
        mentions: const [],
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.conversations.length, beforeCount + 1);
    expect(controller.state.conversations.first.id, 990);
    expect(
      controller.state.conversations.first.lastMessagePreview,
      '新用户: 新会话消息',
    );
    expect(controller.state.messagesFor(990).last.content, '新会话消息');

    await repository.close();
  });

  test('消息去重：重复推送同一 message_id 不追加', () async {
    final repository = FakeAimRepository();
    final controller = AimController(
      repository: repository,
      tokenStorage: MemoryTokenStorage(),
    );
    addTearDown(controller.dispose);
    await controller.login(email: 'user@example.test', password: 'secret1234');

    repository.emit(
      RealtimeMessageEvent(
        messageId: 99002,
        conversationId: 502,
        messageType: 'text',
        content: '第一条消息',
        senderId: 2001,
        sentAt: DateTime.now().millisecondsSinceEpoch,
        conversationType: 'direct',
        clientMessageId: 'push-dedup-1',
        isSystem: false,
        senderDisplayName: 'Alice',
        mentions: const [],
      ),
    );
    await Future<void>.delayed(Duration.zero);
    final count1 = controller.state.messagesFor(502).length;

    repository.emit(
      RealtimeMessageEvent(
        messageId: 99002,
        conversationId: 502,
        messageType: 'text',
        content: '第一条消息',
        senderId: 2001,
        sentAt: DateTime.now().millisecondsSinceEpoch,
        conversationType: 'direct',
        clientMessageId: 'push-dedup-1',
        isSystem: false,
        senderDisplayName: 'Alice',
        mentions: const [],
      ),
    );
    await Future<void>.delayed(Duration.zero);
    final count2 = controller.state.messagesFor(502).length;

    expect(count2, count1, reason: '重复推送不应增加消息数');
    await repository.close();
  });

  test('ACK 状态映射：accepted 处理正确', () async {
    final repository = FakeAimRepository();
    final controller = AimController(
      repository: repository,
      tokenStorage: MemoryTokenStorage(),
    );
    addTearDown(controller.dispose);
    await controller.login(email: 'user@example.test', password: 'secret1234');
    controller.selectConversation(501);

    await controller.sendTextMessage('ACK 测试消息');
    final messages = controller.state.messagesFor(501);
    final last = messages.lastWhere((m) => m.content == 'ACK 测试消息');
    expect(last.status, MessageStatus.sent);
    expect(last.isFailed, isFalse);

    await repository.close();
  });

  test('client_msg_id 格式符合 d1-UUID 规范', () async {
    final repository = FakeAimRepository();
    final controller = AimController(
      repository: repository,
      tokenStorage: MemoryTokenStorage(),
    );
    addTearDown(controller.dispose);
    await controller.login(email: 'user@example.test', password: 'secret1234');
    controller.selectConversation(501);
    await controller.sendTextMessage('格式测试消息');

    final lastMsg = controller.state.messagesFor(501).last;
    expect(lastMsg.clientMessageId.startsWith('d1-'), isTrue);
    expect(lastMsg.clientMessageId.length, greaterThan(10));

    await repository.close();
  });

  test('系统消息解析正确', () async {
    final repository = FakeAimRepository();
    final controller = AimController(
      repository: repository,
      tokenStorage: MemoryTokenStorage(),
    );
    addTearDown(controller.dispose);
    await controller.login(email: 'user@example.test', password: 'secret1234');

    repository.emit(
      RealtimeMessageEvent(
        messageId: 99003,
        conversationId: 501,
        messageType: 'system',
        content: '{"event":"member_joined"}',
        senderId: 0,
        sentAt: DateTime.now().millisecondsSinceEpoch,
        conversationType: 'group',
        clientMessageId: '',
        isSystem: true,
        senderDisplayName: '系统',
        mentions: const [],
      ),
    );
    await Future<void>.delayed(Duration.zero);

    final conv = controller.state.conversations.firstWhere((c) => c.id == 501);
    expect(conv.lastMessagePreview, '新成员加入群聊');
    await repository.close();
  });

  test('Bot 管理中心保留用户侧 Bot 与连接密钥管理', () async {
    final repository = FakeAimRepository();
    final storage = MemoryTokenStorage();
    final controller = AimController(
      repository: repository,
      tokenStorage: storage,
    );
    addTearDown(controller.dispose);
    await controller.login(email: 'user@example.test', password: 'secret1234');

    await controller.loadUserBots();
    expect(controller.state.botCenter.ownedBots, isNotEmpty);
    final ownedBot = controller.state.botCenter.ownedBots.first;

    await controller.createUserBotToken(
      botUserId: ownedBot.botUserId,
      actions: const ['bot.self.read', 'bot.message.send'],
      name: '测试密钥',
    );
    expect(controller.state.botCenter.plaintextToken, 'aim_bot_created_token');
    expect(
      controller.state.botCenter.tokensFor(ownedBot.botUserId),
      isNotEmpty,
    );

    await controller.rotateUserBotToken(
      botUserId: ownedBot.botUserId,
      tokenId: controller.state.botCenter
          .tokensFor(ownedBot.botUserId)
          .first
          .tokenId,
    );
    expect(controller.state.botCenter.plaintextToken, 'aim_bot_rotated_token');

    final group = controller.state.conversations.firstWhere(
      (conversation) => conversation.type == ConversationType.group,
    );
    await controller.addUserBotToConversation(
      botUserId: ownedBot.botUserId,
      conversationId: group.id,
    );
    final updatedGroup = controller.state.conversations.firstWhere(
      (conversation) => conversation.id == group.id,
    );
    expect(updatedGroup.memberIds, contains(ownedBot.botUserId));
    expect(controller.state.notice, 'Bot 已加入会话');

    await repository.close();
  });
}
