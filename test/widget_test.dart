import 'package:aim_desktop/src/aim_app.dart';
import 'package:aim_desktop/src/aim_controller.dart';
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
}
