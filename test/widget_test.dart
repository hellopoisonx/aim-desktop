import 'package:aim_desktop/src/aim_app.dart';
import 'package:aim_desktop/src/aim_controller.dart';
import 'package:aim_desktop/src/domain/models.dart';
import 'package:aim_desktop/src/ui/widgets/mention_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_aim_repository.dart';

void main() {
  testWidgets('登录页不包含内置账号入口', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeAimRepository();
    addTearDown(repository.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aimControllerProvider.overrideWith(
            (ref) => AimController(
              repository: repository,
              tokenStorage: MemoryTokenStorage(),
            ),
          ),
        ],
        child: const AimDesktopApp(autoRestore: false),
      ),
    );

    expect(find.text('欢迎回来'), findsOneWidget);
    expect(find.byKey(const Key('demo_login')), findsNothing);
  });

  testWidgets('用户登录后可以进入会话并发送消息', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeAimRepository();
    final controller = AimController(
      repository: repository,
      tokenStorage: MemoryTokenStorage(),
    );
    addTearDown(repository.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [aimControllerProvider.overrideWith((ref) => controller)],
        child: const AimDesktopApp(autoRestore: false),
      ),
    );

    await controller.login(email: 'user@example.test', password: 'secret1234');
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(controller.state.isAuthenticated, isTrue);
    expect(find.text('选择一个会话开始聊天'), findsOneWidget);
    expect(find.text('AIM 研发群'), findsOneWidget);

    await tester.tap(find.byKey(const Key('conversation_501')));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('输入消息...'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('message_input')), '这是一条测试消息');
    await tester.tap(find.byKey(const Key('send_message')));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('这是一条测试消息'), findsOneWidget);
  });

  testWidgets('Bot 管理中心展示用户侧 Bot 与连接密钥管理', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeAimRepository();
    final controller = AimController(
      repository: repository,
      tokenStorage: MemoryTokenStorage(),
    );
    addTearDown(repository.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [aimControllerProvider.overrideWith((ref) => controller)],
        child: const AimDesktopApp(autoRestore: false),
      ),
    );

    await controller.login(email: 'user@example.test', password: 'secret1234');
    controller.selectSection(AppSection.bots);
    await tester.pumpAndSettle();

    expect(find.text('Bot 管理中心'), findsOneWidget);
    expect(find.text('我的 Bot'), findsOneWidget);
    expect(find.text('AIM 测试 Bot · 启用'), findsOneWidget);
    expect(find.text('生成连接密钥'), findsOneWidget);
    expect(find.text('开启直聊'), findsOneWidget);
    expect(find.text('加入群聊'), findsOneWidget);
  });

  testWidgets('进入群聊会拉取成员详情并让 @ 候选包含 Bot', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeAimRepository();
    final controller = AimController(
      repository: repository,
      tokenStorage: MemoryTokenStorage(),
    );
    addTearDown(repository.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [aimControllerProvider.overrideWith((ref) => controller)],
        child: const AimDesktopApp(autoRestore: false),
      ),
    );

    await controller.login(email: 'user@example.test', password: 'secret1234');
    await controller.loadUserBots();
    await controller.addGroupMembers(501, [9000000001]);
    repository.conversationMembersRequestCount = 0;
    controller.selectConversation(501);
    await tester.pumpAndSettle();

    expect(repository.conversationMembersRequestCount, 1);
    expect(
      mentionCandidatesFromState(controller.state).map((user) => user.nickname),
      contains('AIM 测试 Bot'),
    );

    repository.conversationMembersRequestCount = 0;
    await tester.tap(find.byTooltip('会话信息'));
    await tester.pumpAndSettle();

    expect(repository.conversationMembersRequestCount, 1);
    expect(find.text('AIM 测试 Bot'), findsOneWidget);
  });
}
