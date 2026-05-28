import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../aim_controller.dart';
import '../domain/models.dart';
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
          final compact = constraints.maxWidth < 920;
          final form = _AuthForm(
            mode: _mode,
            isBusy: state.isBusy,
            emailController: _emailController,
            passwordController: _passwordController,
            usernameController: _usernameController,
            onModeChanged: (mode) => setState(() => _mode = mode),
            onSubmit: () => _submit(controller),
          );
          final intro = const _AuthIntro();
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
                    horizontal: compact ? 20 : 56,
                    vertical: 32,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: compact
                        ? Column(
                            children: [intro, const SizedBox(height: 24), form],
                          )
                        : Row(
                            children: [
                              Expanded(child: intro),
                              const SizedBox(width: 48),
                              SizedBox(width: 430, child: form),
                            ],
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
  const _AuthIntro();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AimColors.accentStrong,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AimColors.accentStrong.withValues(alpha: 0.32),
                    blurRadius: 32,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: const Icon(
                Icons.forum_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'AIM Desktop',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 38),
        Text(
          '更轻松地聊天、协作与管理联系人',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          '清晰的桌面端聊天体验，支持会话搜索、好友申请、群聊管理、文件收发、通知、设置与反馈等常用流程。',
          style: TextStyle(color: AimColors.muted, fontSize: 16, height: 1.7),
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            StatusPill(label: '快速登录', icon: Icons.login_rounded),
            StatusPill(label: '实时消息', icon: Icons.sync_rounded),
            StatusPill(label: '深色主题', icon: Icons.dark_mode_rounded),
            StatusPill(label: '稳定同步', icon: Icons.hub_rounded),
          ],
        ),
        const SizedBox(height: 34),
        const _FlowPreview(),
      ],
    );
  }
}

class _FlowPreview extends StatelessWidget {
  const _FlowPreview();

  @override
  Widget build(BuildContext context) {
    final flows = [
      (Icons.login_rounded, '登录 / 注册', '安全进入你的账号'),
      (Icons.chat_bubble_rounded, '会话主页', '搜索、未读提醒与输入状态'),
      (Icons.send_rounded, '消息收发', '文本、图片与文件发送'),
      (Icons.groups_rounded, '好友与群', '申请、处理、建群、成员管理'),
    ];
    return AimPanel(
      color: AimColors.panel.withValues(alpha: 0.72),
      child: Column(
        children: [
          for (final (index, flow) in flows.indexed) ...[
            _FlowRow(icon: flow.$1, title: flow.$2, subtitle: flow.$3),
            if (index != flows.length - 1) const Divider(height: 24),
          ],
        ],
      ),
    );
  }
}

class _FlowRow extends StatelessWidget {
  const _FlowRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AimColors.accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AimColors.accent),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: AimColors.muted, fontSize: 13),
              ),
            ],
          ),
        ),
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
