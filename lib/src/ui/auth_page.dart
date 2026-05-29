import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../aim_controller.dart';
import '../domain/models.dart';
import 'responsive.dart';
import 'theme.dart';
import 'widgets/shared_widgets.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  AuthMode _mode = AuthMode.login;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(aimControllerProvider, (previous, next) {
      final state = next.state;
      if (state.notice != null &&
          previous?.state.noticeSerial != state.noticeSerial) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.notice!)));
      }
    });

    final controller = ref.watch(aimControllerProvider);
    final state = controller.state;
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isDesktop = Breakpoints.isDesktop(width);
          final isMobile = Breakpoints.isMobile(width);
          final form = _AuthForm(
            mode: _mode,
            isBusy: state.isBusy,
            emailController: _emailController,
            passwordController: _passwordController,
            usernameController: _usernameController,
            onModeChanged: (mode) => setState(() => _mode = mode),
            onSubmit: () => _submit(controller),
          );
          final intro = _AuthIntro(compact: isMobile);
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0C1320),
                  Color(0xFF152338),
                  Color(0xFF0B111B),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : (isDesktop ? 56 : 32),
                    vertical: isMobile ? 20 : 32,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: isDesktop
                        ? Row(
                            children: [
                              Expanded(child: intro),
                              const SizedBox(width: 48),
                              SizedBox(width: 430, child: form),
                            ],
                          )
                        : Column(
                            children: [intro, const SizedBox(height: 24), form],
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _submit(AimController controller) {
    if (_mode == AuthMode.login) {
      controller.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      return;
    }
    controller.register(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
    );
  }
}

class _AuthIntro extends StatelessWidget {
  const _AuthIntro({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: compact ? 48 : 56,
              height: compact ? 48 : 56,
              decoration: BoxDecoration(
                color: AimColors.accentStrong,
                borderRadius: BorderRadius.circular(compact ? 14 : 18),
                boxShadow: [
                  BoxShadow(
                    color: AimColors.accentStrong.withValues(alpha: 0.32),
                    blurRadius: 32,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Icon(
                Icons.forum_rounded,
                color: Colors.white,
                size: compact ? 24 : 30,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'AIM',
              style: TextStyle(
                fontSize: compact ? 24 : 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 20 : 38),
      ],
    );
  }
}


class _AuthForm extends StatelessWidget {
  const _AuthForm({
    required this.mode,
    required this.isBusy,
    required this.emailController,
    required this.passwordController,
    required this.usernameController,
    required this.onModeChanged,
    required this.onSubmit,
  });

  final AuthMode mode;
  final bool isBusy;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController usernameController;
  final ValueChanged<AuthMode> onModeChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isRegister = mode == AuthMode.register;
    return AimPanel(
      padding: const EdgeInsets.all(28),
      color: AimColors.panel.withValues(alpha: 0.9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isRegister ? '创建 AIM 账号' : '欢迎回来',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            isRegister ? '注册后会自动进入主页。' : '登录后进入会话主页。',
            style: const TextStyle(color: AimColors.muted),
          ),
          const SizedBox(height: 22),
          SegmentedButton<AuthMode>(
            segments: const [
              ButtonSegment(
                value: AuthMode.login,
                label: Text('登录'),
                icon: Icon(Icons.login_rounded),
              ),
              ButtonSegment(
                value: AuthMode.register,
                label: Text('注册'),
                icon: Icon(Icons.person_add_rounded),
              ),
            ],
            selected: {mode},
            onSelectionChanged: isBusy
                ? null
                : (values) => onModeChanged(values.first),
          ),
          const SizedBox(height: 22),
          if (isRegister) ...[
            TextField(
              key: const Key('auth_username'),
              controller: usernameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: '昵称',
                hintText: '例如：Alice',
                prefixIcon: Icon(Icons.badge_rounded),
              ),
            ),
            const SizedBox(height: 14),
          ],
          TextField(
            key: const Key('auth_email'),
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: '邮箱',
              hintText: 'name@example.com',
              prefixIcon: Icon(Icons.mail_rounded),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            key: const Key('auth_password'),
            controller: passwordController,
            obscureText: true,
            onSubmitted: (_) => isBusy ? null : onSubmit(),
            decoration: const InputDecoration(
              labelText: '密码',
              hintText: '至少 8 位',
              prefixIcon: Icon(Icons.lock_rounded),
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            key: const Key('auth_submit'),
            onPressed: isBusy ? null : onSubmit,
            icon: isBusy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    isRegister
                        ? Icons.person_add_alt_1_rounded
                        : Icons.arrow_forward_rounded,
                  ),
            label: Text(isRegister ? '注册并进入' : '登录'),
          ),
        ],
      ),
    );
  }
}
