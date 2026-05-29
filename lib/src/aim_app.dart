import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'aim_controller.dart';
import 'ui/auth_page.dart';
import 'ui/theme.dart';
import 'ui/workspace_page.dart';

class AimDesktopApp extends ConsumerStatefulWidget {
  const AimDesktopApp({super.key, this.autoRestore = true});

  final bool autoRestore;

  @override
  ConsumerState<AimDesktopApp> createState() => _AimDesktopAppState();
}

class _AimDesktopAppState extends ConsumerState<AimDesktopApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.autoRestore) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(aimControllerProvider).tryAutoRestore();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = ref.read(aimControllerProvider);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        controller.onAppPaused();
        break;
      case AppLifecycleState.resumed:
        controller.onAppResumed();
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aimControllerProvider).state;
    return MaterialApp(
      title: 'AIM',
      debugShowCheckedModeBanner: false,
      theme: AimTheme.dark(),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        child: state.isAuthenticated ? const WorkspacePage() : const AuthPage(),
      ),
    );
  }
}
