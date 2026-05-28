import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_selector/file_selector.dart';

import '../aim_controller.dart';
import '../data/aim_repository.dart';
import '../domain/models.dart';
import 'theme.dart';
import 'widgets/shared_widgets.dart';

class WorkspacePage extends ConsumerStatefulWidget {
  const WorkspacePage({super.key});

  @override
  ConsumerState<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends ConsumerState<WorkspacePage> {
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
      drawer: _AppDrawer(controller: controller, state: state),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 920;
          if (wide) {
            return Row(
              children: [
                SizedBox(
                  width: 360,
                  child: _ConversationSidebar(
                    controller: controller,
                    state: state,
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: _MainContent(controller: controller, state: state),
                ),
              ],
            );
          }
          final showConversationList =
              state.currentSection == AppSection.chats &&
              state.selectedConversationId == null;
          return showConversationList
              ? _ConversationSidebar(controller: controller, state: state)
              : _MainContent(
                  controller: controller,
                  state: state,
                  compact: true,
                );
        },
      ),
    );
  }
}

class _ConversationSidebar extends StatelessWidget {
  const _ConversationSidebar({required this.controller, required this.state});

  final AimController controller;
  final AimState state;

  @override
  Widget build(BuildContext context) {
    final conversations = state.filteredConversations;
    return Container(
      color: AimColors.rail,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    key: const Key('open_drawer'),
                    tooltip: '打开菜单',
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.menu_rounded),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      key: const Key('conversation_search'),
                      onChanged: controller.updateSearchQuery,
                      decoration: const InputDecoration(
                        hintText: '搜索',
                        prefixIcon: Icon(Icons.search_rounded),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    tooltip: '新建群聊',
                    onPressed: () =>
                        _showCreateGroupDialog(context, controller, state),
                    icon: const Icon(Icons.add_comment_rounded),
                  ),
                ],
              ),
            ),
            _ConnectionStrip(state: state, controller: controller),
            Expanded(
              child: conversations.isEmpty
                  ? const EmptyState(
                      icon: Icons.search_off_rounded,
                      title: '没有匹配的会话',
                      subtitle: '试试输入群名、好友昵称或消息关键词。',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 16),
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        return _ConversationTile(
                          conversation: conversation,
                          selected:
                              conversation.id == state.selectedConversationId,
                          typingName: conversation.typingUserId == null
                              ? null
                              : _displayName(state, conversation.typingUserId!),
                          onTap: () =>
                              controller.selectConversation(conversation.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionStrip extends StatelessWidget {
  const _ConnectionStrip({required this.state, required this.controller});

  final AimState state;
  final AimController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: state.connectionOnline
              ? AimColors.success.withValues(alpha: 0.12)
              : AimColors.warning.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: state.connectionOnline
                ? AimColors.success.withValues(alpha: 0.34)
                : AimColors.warning.withValues(alpha: 0.34),
          ),
        ),
        child: Row(
          children: [
            Icon(
              state.connectionOnline
                  ? Icons.cloud_done_rounded
                  : Icons.cloud_off_rounded,
              size: 18,
              color: state.connectionOnline
                  ? AimColors.success
                  : AimColors.warning,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                state.connectionOnline ? '已连接' : '离线模式 · 自动重连中',
                style: TextStyle(
                  color: state.connectionOnline
                      ? AimColors.success
                      : AimColors.warning,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.selected,
    required this.onTap,
    this.typingName,
  });

  final Conversation conversation;
  final bool selected;
  final VoidCallback onTap;
  final String? typingName;

  @override
  Widget build(BuildContext context) {
    final preview = typingName == null
        ? conversation.lastMessagePreview
        : '$typingName 正在输入';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: selected ? AimColors.panelAlt : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          key: Key('conversation_${conversation.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                AvatarCircle(
                  label: conversation.avatarText,
                  size: 48,
                  background: conversation.isPinned
                      ? AimColors.accentStrong
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            formatShortTime(conversation.updatedAt),
                            style: const TextStyle(
                              color: AimColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          if (conversation.isPinned) ...[
                            const Icon(
                              Icons.push_pin_rounded,
                              size: 14,
                              color: AimColors.accent,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              preview,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: typingName == null
                                    ? AimColors.muted
                                    : AimColors.accent,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (conversation.unreadCount > 0) ...[
                  const SizedBox(width: 10),
                  Container(
                    constraints: const BoxConstraints(minWidth: 24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AimColors.accentStrong,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${conversation.unreadCount}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent({
    required this.controller,
    required this.state,
    this.compact = false,
  });

  final AimController controller;
  final AimState state;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (state.currentSection == AppSection.chats) {
      final conversation = state.selectedConversation;
      if (conversation == null) {
        return const _ChatEmptyState();
      }
      return _ChatPane(
        controller: controller,
        state: state,
        conversation: conversation,
        compact: compact,
      );
    }
    return _SectionContent(
      controller: controller,
      state: state,
      compact: compact,
    );
  }
}

class _ChatEmptyState extends StatelessWidget {
  const _ChatEmptyState();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AimColors.scaffold,
      child: EmptyState(
        icon: Icons.chat_bubble_outline_rounded,
        title: '选择一个会话开始聊天',
        subtitle: '从左侧选择一个会话，或通过菜单创建群聊、添加好友并发起直聊。',
      ),
    );
  }
}

class _ChatPane extends StatefulWidget {
  const _ChatPane({
    required this.controller,
    required this.state,
    required this.conversation,
    required this.compact,
  });

  final AimController controller;
  final AimState state;
  final Conversation conversation;
  final bool compact;

  @override
  State<_ChatPane> createState() => _ChatPaneState();
}

class _ChatPaneState extends State<_ChatPane> {
  final _messageController = TextEditingController();
  late final ScrollController _scrollController;
  final Map<int, double> _scrollPositions = {};
  int _lastMessageCount = 0;
  bool _initialScrollDone = false;
  bool _showScrollToTop = false;
  bool _isNearBottom = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _afterFirstBuild();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _saveCurrentPosition();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ChatPane oldWidget) {
    super.didUpdateWidget(oldWidget);

    final conversationChanged =
        oldWidget.conversation.id != widget.conversation.id;

    if (conversationChanged) {
      _saveCurrentPosition();
      _initialScrollDone = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreOrScrollToBottom();
        _initialScrollDone = true;
        _lastMessageCount =
            widget.state.messagesFor(widget.conversation.id).length;
      });
      return;
    }

    final currentMessages = widget.state.messagesFor(widget.conversation.id);
    final newCount = currentMessages.length;

    if (!_initialScrollDone) {
      _initialScrollDone = true;
      _lastMessageCount = newCount;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreOrScrollToBottom();
      });
      return;
    }

    if (newCount > _lastMessageCount && _scrollController.hasClients) {
      _lastMessageCount = newCount;
      if (_isNearBottom) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } else {
      _lastMessageCount = newCount;
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final pixels = position.pixels;
    final max = position.maxScrollExtent;

    final showTop = pixels > 300;
    final nearBottom = max - pixels < 100;

    if (showTop != _showScrollToTop || nearBottom != _isNearBottom) {
      setState(() {
        _showScrollToTop = showTop;
        _isNearBottom = nearBottom;
      });
    }
  }

  void _saveCurrentPosition() {
    if (_scrollController.hasClients) {
      _scrollPositions[widget.conversation.id] =
          _scrollController.position.pixels;
    }
  }

  void _restoreOrScrollToBottom() {
    if (!_scrollController.hasClients) return;
    final saved = _scrollPositions[widget.conversation.id];
    if (saved != null) {
      final max = _scrollController.position.maxScrollExtent;
      _scrollController.jumpTo(saved.clamp(0.0, max));
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _afterFirstBuild() {
    _restoreOrScrollToBottom();
    _initialScrollDone = true;
    _lastMessageCount =
        widget.state.messagesFor(widget.conversation.id).length;
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.state.messagesFor(widget.conversation.id);
    final pinned = messages.where((message) => message.isSystem).firstOrNull;
    return Container(
      color: AimColors.scaffold,
      child: SafeArea(
        child: Column(
          children: [
            _ChatHeader(
              controller: widget.controller,
              state: widget.state,
              conversation: widget.conversation,
              compact: widget.compact,
            ),
            if (pinned != null) _PinnedMessage(message: pinned),
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    key: Key('message_list_${widget.conversation.id}'),
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                    itemCount: messages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Center(
                            child: TextButton.icon(
                              onPressed: widget.controller.loadOlderMessages,
                              icon: const Icon(Icons.history_rounded, size: 18),
                              label: const Text('加载更早消息'),
                            ),
                          ),
                        );
                      }
                      final message = messages[index - 1];
                      return _MessageBubble(
                        controller: widget.controller,
                        message: message,
                        isMine:
                            message.senderId == widget.state.currentUser?.id,
                        onRetry: () => widget.controller.retryMessage(message),
                      );
                    },
                  ),
                  if (_showScrollToTop || !_isNearBottom)
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_showScrollToTop)
                            _ScrollFAB(
                              icon: Icons.keyboard_arrow_up_rounded,
                              tooltip: '回到顶部',
                              onPressed: _scrollToTop,
                            ),
                          if (!_isNearBottom) ...[
                            if (_showScrollToTop) const SizedBox(height: 8),
                            _ScrollFAB(
                              icon: Icons.keyboard_arrow_down_rounded,
                              tooltip: '回到底部',
                              onPressed: _scrollToBottom,
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
            _Composer(
              controller: widget.controller,
              textController: _messageController,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrollFAB extends StatelessWidget {
  const _ScrollFAB({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AimColors.panel.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(999),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Tooltip(
            message: tooltip,
            child: Icon(icon, size: 24, color: AimColors.muted),
          ),
        ),
      ),
    );
  }
}
class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.controller,
    required this.state,
    required this.conversation,
    required this.compact,
  });

  final AimController controller;
  final AimState state;
  final Conversation conversation;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      decoration: const BoxDecoration(
        color: AimColors.panel,
        border: Border(bottom: BorderSide(color: AimColors.divider)),
      ),
      child: Row(
        children: [
          if (compact) ...[
            IconButton(
              tooltip: '返回会话列表',
              onPressed: controller.clearSelectedConversation,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 4),
          ],
          AvatarCircle(label: conversation.avatarText, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        conversation.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusPill(
                      label: conversation.typeLabel,
                      color: AimColors.success,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${conversation.memberIds.length} 位成员 · ${conversation.isActive ? '正常' : '已归档'}',
                  style: const TextStyle(color: AimColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: '搜索聊天记录',
            onPressed: () => _showNotice(context, '聊天记录搜索功能即将推出'),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: '会话信息',
            onPressed: () => _showConversationInfoDialog(
              context,
              controller,
              state,
              conversation,
            ),
            icon: const Icon(Icons.info_outline_rounded),
          ),
          PopupMenuButton<String>(
            tooltip: '更多操作',
            onSelected: (value) {
              switch (value) {
                case 'token':
                  controller.refreshToken();
                case 'leave':
                  controller.leaveConversation(conversation.id);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'token', child: Text('刷新连接')),
              PopupMenuItem(value: 'leave', child: Text('退出/解散会话')),
            ],
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
    );
  }
}

class _PinnedMessage extends StatelessWidget {
  const _PinnedMessage({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AimColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: AimColors.accent, width: 4),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.push_pin_rounded, size: 18, color: AimColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AimColors.text, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.controller,
    required this.message,
    required this.isMine,
    required this.onRetry,
  });

  final AimController controller;
  final ChatMessage message;
  final bool isMine;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (message.isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: StatusPill(
            label: message.content,
            icon: Icons.campaign_rounded,
          ),
        ),
      );
    }

    final bubbleColor = isMine ? AimColors.bubbleMine : AimColors.bubble;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: isMine
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMine) ...[
              AvatarCircle(label: _initials(message.senderName), size: 36),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isMine
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.senderName,
                        style: const TextStyle(
                          color: AimColors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (!isMine) ...[
                        const SizedBox(width: 6),
                        const StatusPill(
                          label: '管理员',
                          color: AimColors.success,
                        ),
                      ],
                      const SizedBox(width: 8),
                      Text(
                        formatClock(message.createdAt),
                        style: const TextStyle(
                          color: AimColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onLongPress: () => _showMessageActions(context, message),
                    onSecondaryTapDown: (_) =>
                        _showMessageActions(context, message),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isMine ? 18 : 5),
                          bottomRight: Radius.circular(isMine ? 5 : 18),
                        ),
                      ),
                      child: _MessageContent(
                        controller: controller,
                        message: message,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  _MessageStatus(message: message, onRetry: onRetry),
                ],
              ),
            ),
            if (isMine) ...[
              const SizedBox(width: 10),
              AvatarCircle(
                label: _initials(message.senderName),
                size: 36,
                background: AimColors.accentStrong,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MessageContent extends StatelessWidget {
  const _MessageContent({required this.controller, required this.message});

  final AimController controller;
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final attachment = AttachmentMessagePayload.tryParse(message.content);
    return switch (message.type) {
      MessageType.text => SelectableText(
        message.content,
        style: const TextStyle(height: 1.45),
      ),
      MessageType.image =>
        attachment == null
            ? _LegacyImageContent(content: message.content)
            : _AttachmentMessageCard(
                controller: controller,
                payload: attachment,
              ),
      MessageType.file =>
        attachment == null
            ? _LegacyFileContent(name: message.content)
            : _AttachmentMessageCard(
                controller: controller,
                payload: attachment,
              ),
      MessageType.system => Text(message.content),
    };
  }
}

class _LegacyImageContent extends StatelessWidget {
  const _LegacyImageContent({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    if (content.startsWith('emote://')) {
      return const SizedBox(
        width: 180,
        height: 118,
        child: Center(child: Text('🐧', style: TextStyle(fontSize: 58))),
      );
    }
    return _AttachmentPreviewFrame(
      width: 180,
      height: 118,
      child: const Icon(Icons.broken_image_rounded, color: AimColors.muted),
    );
  }
}

class _LegacyFileContent extends StatelessWidget {
  const _LegacyFileContent({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.insert_drive_file_rounded, color: AimColors.accent),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _AttachmentMessageCard extends StatelessWidget {
  const _AttachmentMessageCard({
    required this.controller,
    required this.payload,
  });

  final AimController controller;
  final AttachmentMessagePayload payload;

  @override
  Widget build(BuildContext context) {
    final effectivePayload = _payloadWithLocalAttachmentState(
      controller,
      payload,
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (effectivePayload.isImage) ...[
            _AttachmentImage(
              controller: controller,
              payload: effectivePayload,
              width: 280,
              height: 180,
            ),
            const SizedBox(height: 10),
          ],
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!effectivePayload.isImage)
                _AttachmentKindIcon(payload: effectivePayload),
              if (!effectivePayload.isImage) const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      effectivePayload.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusPill(
                          label: effectivePayload.displayKind,
                          icon: _iconForPayload(effectivePayload),
                        ),
                        StatusPill(
                          label: effectivePayload.sizeLabel,
                          color: AimColors.muted,
                        ),
                        StatusPill(
                          label: _attachmentStatusLabel(effectivePayload),
                          color: _attachmentStatusColor(
                            effectivePayload.status,
                          ),
                        ),
                        if (_attachmentParseStatusLabel(
                              effectivePayload.parseStatus,
                            ) !=
                            null)
                          StatusPill(
                            label: _attachmentParseStatusLabel(
                              effectivePayload.parseStatus,
                            )!,
                            color: _attachmentParseStatusColor(
                              effectivePayload.parseStatus,
                            ),
                          ),
                      ],
                    ),
                    if (effectivePayload.isAudio ||
                        effectivePayload.isVideo) ...[
                      const SizedBox(height: 10),
                      _MediaHint(payload: effectivePayload),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showAttachmentPreviewDialog(
                  context,
                  controller,
                  effectivePayload,
                ),
                icon: const Icon(Icons.visibility_rounded, size: 18),
                label: const Text('预览'),
              ),
              FilledButton.icon(
                onPressed: () =>
                    _downloadAttachment(context, controller, effectivePayload),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('下载'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

AttachmentMessagePayload _payloadWithLocalAttachmentState(
  AimController controller,
  AttachmentMessagePayload payload,
) {
  for (final attachment in controller.state.attachments) {
    if (attachment.id != payload.fileId) continue;
    return payload.copyWith(
      status: attachment.status,
      parseStatus: attachment.parseStatus,
      downloadUrl: attachment.downloadUrl,
      thumbnailUrl: attachment.thumbnailUrl,
      localPreviewDataUri: attachment.localPreviewDataUri,
    );
  }
  return payload;
}

class _AttachmentKindIcon extends StatelessWidget {
  const _AttachmentKindIcon({required this.payload});

  final AttachmentMessagePayload payload;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AimColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AimColors.accent.withValues(alpha: 0.24)),
      ),
      child: Icon(_iconForPayload(payload), color: AimColors.accent),
    );
  }
}

class _MediaHint extends StatelessWidget {
  const _MediaHint({required this.payload});

  final AttachmentMessagePayload payload;

  @override
  Widget build(BuildContext context) {
    final label = payload.isAudio ? '音频文件已准备好，可下载后播放' : '视频文件已准备好，可下载后播放';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AimColors.scaffold,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AimColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            payload.isAudio
                ? Icons.graphic_eq_rounded
                : Icons.play_circle_rounded,
            size: 18,
            color: AimColors.accent,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(color: AimColors.muted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentImage extends StatelessWidget {
  const _AttachmentImage({
    required this.payload,
    this.controller,
    this.width = 180,
    this.height = 118,
  });

  final AttachmentMessagePayload payload;
  final AimController? controller;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final local = payload.localPreviewDataUri;
    if (local.startsWith('emote://')) {
      return _AttachmentPreviewFrame(
        width: width,
        height: height,
        child: const Text('🐧', style: TextStyle(fontSize: 58)),
      );
    }
    if (local.startsWith('data:')) {
      final bytes = _bytesFromDataUri(local);
      if (bytes != null) {
        return _AttachmentPreviewFrame(
          width: width,
          height: height,
          padding: EdgeInsets.zero,
          child: Image.memory(bytes, fit: BoxFit.cover),
        );
      }
    }
    final url = payload.bestPreviewUrl;
    if (url.startsWith('emote://')) {
      return _AttachmentPreviewFrame(
        width: width,
        height: height,
        child: const Text('🐧', style: TextStyle(fontSize: 58)),
      );
    }
    if (controller != null && payload.fileId.isNotEmpty) {
      return _AuthorizedImagePreview(
        controller: controller!,
        payload: payload,
        width: width,
        height: height,
      );
    }
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return _AttachmentPreviewFrame(
        width: width,
        height: height,
        padding: EdgeInsets.zero,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.broken_image_rounded, color: AimColors.muted),
          ),
        ),
      );
    }
    return _AttachmentPreviewFrame(
      width: width,
      height: height,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_rounded, size: 42, color: AimColors.accent),
          SizedBox(height: 8),
          Text('图片待下载', style: TextStyle(color: AimColors.muted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _AuthorizedImagePreview extends StatefulWidget {
  const _AuthorizedImagePreview({
    required this.controller,
    required this.payload,
    required this.width,
    required this.height,
  });

  final AimController controller;
  final AttachmentMessagePayload payload;
  final double width;
  final double height;

  @override
  State<_AuthorizedImagePreview> createState() =>
      _AuthorizedImagePreviewState();
}

class _AuthorizedImagePreviewState extends State<_AuthorizedImagePreview> {
  late Future<AttachmentDownloadResult> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.controller.downloadAttachment(
      widget.payload,
      notifyOnError: false,
    );
  }

  @override
  void didUpdateWidget(covariant _AuthorizedImagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.payload.fileId != widget.payload.fileId) {
      _future = widget.controller.downloadAttachment(
        widget.payload,
        notifyOnError: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AttachmentDownloadResult>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _AttachmentPreviewFrame(
            width: widget.width,
            height: widget.height,
            padding: EdgeInsets.zero,
            child: Image.memory(snapshot.data!.bytes, fit: BoxFit.cover),
          );
        }
        if (snapshot.hasError) {
          return _AttachmentPreviewFrame(
            width: widget.width,
            height: widget.height,
            child: const Icon(
              Icons.broken_image_rounded,
              color: AimColors.muted,
            ),
          );
        }
        return _AttachmentPreviewFrame(
          width: widget.width,
          height: widget.height,
          child: const SizedBox.square(
            dimension: 26,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        );
      },
    );
  }
}

class _AttachmentPreviewFrame extends StatelessWidget {
  const _AttachmentPreviewFrame({
    required this.child,
    this.width = 180,
    this.height = 118,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        padding: padding,
        decoration: BoxDecoration(
          color: AimColors.scaffold,
          border: Border.all(color: AimColors.divider),
        ),
        child: child,
      ),
    );
  }
}

IconData _iconForPayload(AttachmentMessagePayload payload) {
  if (payload.isImage) return Icons.image_rounded;
  if (payload.isAudio) return Icons.audiotrack_rounded;
  if (payload.isVideo) return Icons.movie_rounded;
  return Icons.insert_drive_file_rounded;
}

String _attachmentStatusLabel(AttachmentMessagePayload payload) {
  final status = payload.status.trim().toLowerCase();
  if (status.isEmpty || status == 'ready') return '待处理';
  if (status.startsWith('uploading')) {
    return status.replaceFirst('uploading', '上传中');
  }
  if (status == 'failed') return '失败';
  if (status.contains('uploaded')) return '已上传';
  return '处理中';
}

String? _attachmentParseStatusLabel(String status) {
  final value = status.trim().toLowerCase();
  if (value.isEmpty) return null;
  if (value == 'pending' || value == 'waiting') return '等待处理';
  if (value.contains('fail') || value.contains('error')) return '处理失败';
  if (value.contains('complete') ||
      value.contains('done') ||
      value.contains('success') ||
      value == 'parsed') {
    return '已处理';
  }
  return '处理中';
}

Color _attachmentParseStatusColor(String status) {
  final value = status.trim().toLowerCase();
  if (value.contains('fail') || value.contains('error')) {
    return AimColors.danger;
  }
  if (value == 'pending' || value == 'waiting') return AimColors.warning;
  if (value.contains('complete') ||
      value.contains('done') ||
      value.contains('success') ||
      value == 'parsed') {
    return AimColors.success;
  }
  return AimColors.warning;
}

Color _attachmentStatusColor(String status) {
  final value = status.trim().toLowerCase();
  if (value.startsWith('uploading')) return AimColors.warning;
  if (value == 'failed') return AimColors.danger;
  if (value.contains('uploaded')) return AimColors.success;
  return AimColors.warning;
}

final Map<String, Uint8List> _dataUriBytesCache = {};

Uint8List? _bytesFromDataUri(String uri) {
  final cached = _dataUriBytesCache[uri];
  if (cached != null) return cached;
  final comma = uri.indexOf(',');
  if (comma < 0) return null;
  final meta = uri.substring(0, comma);
  final payload = uri.substring(comma + 1);
  if (!meta.endsWith(';base64')) return null;
  try {
    final bytes = base64Decode(payload);
    _dataUriBytesCache[uri] = bytes;
    return bytes;
  } catch (_) {
    return null;
  }
}

class _MessageStatus extends StatelessWidget {
  const _MessageStatus({required this.message, required this.onRetry});

  final ChatMessage message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (message.status) {
      MessageStatus.received => ('已接收', AimColors.muted, Icons.done_rounded),
      MessageStatus.sending => (
        '发送中',
        AimColors.warning,
        Icons.access_time_rounded,
      ),
      MessageStatus.sent => (
        message.readBy.isEmpty ? '已发送' : '已读 ${message.readBy.length}',
        AimColors.muted,
        Icons.done_all_rounded,
      ),
      MessageStatus.failed => (
        '发送失败，点击重试',
        AimColors.danger,
        Icons.error_outline_rounded,
      ),
    };
    return InkWell(
      onTap: message.status == MessageStatus.failed ? onRetry : null,
      borderRadius: BorderRadius.circular(999),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.textController});

  final AimController controller;
  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      decoration: const BoxDecoration(
        color: AimColors.panel,
        border: Border(top: BorderSide(color: AimColors.divider)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: '选择文件并上传',
            onPressed: () => _pickAndSend(context, 'file'),
            icon: const Icon(Icons.attach_file_rounded),
          ),
          IconButton(
            tooltip: '选择图片并上传',
            onPressed: () => _pickAndSend(context, 'image'),
            icon: const Icon(Icons.image_rounded),
          ),
          IconButton(
            tooltip: '选择音频并上传',
            onPressed: () => _pickAndSend(context, 'audio'),
            icon: const Icon(Icons.mic_rounded),
          ),
          IconButton(
            tooltip: '选择视频并上传',
            onPressed: () => _pickAndSend(context, 'video'),
            icon: const Icon(Icons.videocam_rounded),
          ),
          Expanded(
            child: TextField(
              key: const Key('message_input'),
              controller: textController,
              minLines: 1,
              maxLines: 5,
              onChanged: (_) => controller.sendTypingEvent(),
              onSubmitted: (_) => _send(),
              decoration: const InputDecoration(
                hintText: '输入消息...',
                prefixIcon: Icon(Icons.edit_rounded),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            tooltip: '表情',
            onPressed: () {
              textController.text = '${textController.text} 😊';
              textController.selection = TextSelection.collapsed(
                offset: textController.text.length,
              );
            },
            icon: const Icon(Icons.emoji_emotions_rounded),
          ),
          FilledButton.icon(
            key: const Key('send_message'),
            onPressed: _send,
            icon: const Icon(Icons.send_rounded),
            label: const Text('发送'),
          ),
        ],
      ),
    );
  }

  void _send() {
    final text = textController.text;
    textController.clear();
    controller.sendTextMessage(text);
  }

  Future<void> _pickAndSend(BuildContext context, String kind) async {
    try {
      final file = await openFile(
        acceptedTypeGroups: [_typeGroupForKind(kind)],
      );
      if (file == null) return;
      final size = await file.length();
      final mime = _normalizeMimeForKind(kind, file.name, file.mimeType);
      Uint8List? bytes;
      var localPreview = '';
      if (kind == 'image' && size <= _maxInlinePreviewBytes) {
        bytes = await file.readAsBytes();
        localPreview = _dataUri(mime, bytes);
      }
      await controller.sendAttachment(
        kind: kind,
        originalName: file.name,
        mime: mime,
        size: size,
        bytes: bytes,
        openRead: bytes == null ? () => file.openRead() : null,
        localPreviewDataUri: localPreview,
      );
    } catch (error) {
      if (!context.mounted) return;
      _showNotice(context, '附件读取失败：$error');
    }
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.controller, required this.state});

  final AimController controller;
  final AimState state;

  @override
  Widget build(BuildContext context) {
    final user = state.currentUser;
    return Drawer(
      backgroundColor: AimColors.rail,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  AvatarCircle(
                    label: user?.initials ?? '?',
                    size: 58,
                    online: state.connectionOnline,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.nickname ?? '未登录',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AimColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  _DrawerTile(
                    section: AppSection.chats,
                    current: state.currentSection,
                    icon: Icons.chat_rounded,
                    label: '会话',
                    badge: state.totalUnread == 0
                        ? null
                        : '${state.totalUnread}',
                    onTap: () => _select(context, AppSection.chats),
                  ),
                  _DrawerTile(
                    section: AppSection.profile,
                    current: state.currentSection,
                    icon: Icons.person_rounded,
                    label: '个人中心',
                    onTap: () => _select(context, AppSection.profile),
                  ),
                  _DrawerTile(
                    section: AppSection.friends,
                    current: state.currentSection,
                    icon: Icons.people_alt_rounded,
                    label: '好友管理',
                    onTap: () => _select(context, AppSection.friends),
                  ),
                  _DrawerTile(
                    section: AppSection.friendRequests,
                    current: state.currentSection,
                    icon: Icons.mark_email_unread_rounded,
                    label: '好友申请',
                    badge: state.friendRequests.isEmpty
                        ? null
                        : '${state.friendRequests.length}',
                    onTap: () => _select(context, AppSection.friendRequests),
                  ),
                  _DrawerTile(
                    section: AppSection.groups,
                    current: state.currentSection,
                    icon: Icons.groups_rounded,
                    label: '群组管理',
                    onTap: () => _select(context, AppSection.groups),
                  ),
                  const Divider(height: 26),
                  _DrawerTile(
                    section: AppSection.settings,
                    current: state.currentSection,
                    icon: Icons.settings_rounded,
                    label: '设置',
                    onTap: () => _select(context, AppSection.settings),
                  ),
                  _DrawerTile(
                    section: AppSection.feedback,
                    current: state.currentSection,
                    icon: Icons.help_rounded,
                    label: '帮助与反馈',
                    onTap: () => _select(context, AppSection.feedback),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: controller.logout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('退出登录'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _select(BuildContext context, AppSection section) {
    controller.selectSection(section);
    Navigator.of(context).maybePop();
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.section,
    required this.current,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });

  final AppSection section;
  final AppSection current;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final selected = section == current;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: ListTile(
        selected: selected,
        selectedTileColor: AimColors.panelAlt,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(
          icon,
          color: selected ? AimColors.accent : AimColors.muted,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        trailing: badge == null
            ? null
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AimColors.accentStrong,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
        onTap: onTap,
      ),
    );
  }
}

class _SectionContent extends StatelessWidget {
  const _SectionContent({
    required this.controller,
    required this.state,
    required this.compact,
  });

  final AimController controller;
  final AimState state;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AimColors.scaffold,
      child: SafeArea(
        child: Column(
          children: [
            _SectionTopBar(
              title: _sectionTitle(state.currentSection),
              subtitle: _sectionSubtitle(state.currentSection),
              compact: compact,
              onBack: () => controller.selectSection(AppSection.chats),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: switch (state.currentSection) {
                      AppSection.profile => _ProfileSection(
                        controller: controller,
                        state: state,
                      ),
                      AppSection.friends => _FriendsSection(
                        controller: controller,
                        state: state,
                      ),
                      AppSection.friendRequests => _FriendRequestsSection(
                        controller: controller,
                        state: state,
                      ),
                      AppSection.groups => _GroupsSection(
                        controller: controller,
                        state: state,
                      ),
                      AppSection.settings => _SettingsSection(
                        controller: controller,
                      ),
                      AppSection.feedback => _FeedbackSection(
                        controller: controller,
                      ),
                      _ => const SizedBox.shrink(),
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTopBar extends StatelessWidget {
  const _SectionTopBar({
    required this.title,
    required this.subtitle,
    required this.compact,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final bool compact;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: const BoxDecoration(
        color: AimColors.panel,
        border: Border(bottom: BorderSide(color: AimColors.divider)),
      ),
      child: Row(
        children: [
          if (compact) ...[
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: SectionTitle(title: title, subtitle: subtitle),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.controller, required this.state});

  final AimController controller;
  final AimState state;

  @override
  Widget build(BuildContext context) {
    final user = state.currentUser;
    if (user == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AimPanel(
          child: Row(
            children: [
              AvatarCircle(
                label: user.initials,
                size: 82,
                online: state.connectionOnline,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nickname,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.email,
                      style: const TextStyle(color: AimColors.muted),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        StatusPill(label: '我的账号', icon: Icons.tag_rounded),
                        StatusPill(
                          label: state.connectionOnline ? '在线' : '离线',
                          color: state.connectionOnline
                              ? AimColors.success
                              : AimColors.warning,
                        ),
                        const StatusPill(
                          label: '桌面端设备',
                          icon: Icons.desktop_windows_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => _showProfileDialog(context, controller, user),
                icon: const Icon(Icons.edit_rounded),
                label: const Text('编辑资料'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        AimPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: '登录与连接状态',
                subtitle: '查看当前登录状态和实时连接情况。',
              ),
              const SizedBox(height: 16),
              _InfoRow(
                label: '登录状态有效期',
                value:
                    state.session?.expiresAt
                        .toLocal()
                        .toString()
                        .split('.')
                        .first ??
                    '-',
              ),
              _InfoRow(
                label: '实时连接',
                value: state.connectionOnline ? '已连接' : '已断开，等待重连',
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: controller.refreshToken,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('刷新连接'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FriendsSection extends StatelessWidget {
  const _FriendsSection({required this.controller, required this.state});

  final AimController controller;
  final AimState state;

  @override
  Widget build(BuildContext context) {
    return AimPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: '好友列表',
            subtitle: '查看好友资料与在线状态。',
            trailing: FilledButton.icon(
              onPressed: () => _showAddFriendDialog(context, controller),
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('添加好友'),
            ),
          ),
          const SizedBox(height: 16),
          for (final friendship in state.friends) ...[
            _FriendTile(
              friendship: friendship,
              trailing: FilledButton.tonalIcon(
                onPressed: () => controller.startDirectConversation(friendship),
                icon: const Icon(Icons.chat_rounded),
                label: const Text('发起聊天'),
              ),
            ),
            const Divider(height: 18),
          ],
        ],
      ),
    );
  }
}

class _FriendRequestsSection extends StatelessWidget {
  const _FriendRequestsSection({required this.controller, required this.state});

  final AimController controller;
  final AimState state;

  @override
  Widget build(BuildContext context) {
    if (state.friendRequests.isEmpty) {
      return const EmptyState(
        icon: Icons.mark_email_read_rounded,
        title: '暂无好友申请',
        subtitle: '收到新的好友申请后，会显示在这里。',
      );
    }
    return AimPanel(
      child: Column(
        children: [
          const SectionTitle(
            title: '好友申请',
            subtitle: '可接受或拒绝收到的申请，也能查看自己发出的申请。',
          ),
          const SizedBox(height: 16),
          for (final friendship in state.friendRequests) ...[
            _FriendTile(
              friendship: friendship,
              trailing: Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () => controller.rejectFriend(friendship.id),
                    child: const Text('拒绝'),
                  ),
                  FilledButton(
                    onPressed: () => controller.acceptFriend(friendship.id),
                    child: const Text('接受'),
                  ),
                ],
              ),
            ),
            const Divider(height: 18),
          ],
        ],
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({required this.friendship, required this.trailing});

  final Friendship friendship;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AvatarCircle(
          label: friendship.user.initials,
          size: 48,
          online: friendship.user.status == PresenceStatus.online,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                friendship.user.nickname,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                friendship.user.email,
                style: const TextStyle(color: AimColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 6),
              StatusPill(
                label: friendStatusLabel(friendship.status),
                color: friendship.status == FriendStatus.pending
                    ? AimColors.warning
                    : AimColors.success,
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }
}

class _GroupsSection extends StatelessWidget {
  const _GroupsSection({required this.controller, required this.state});

  final AimController controller;
  final AimState state;

  @override
  Widget build(BuildContext context) {
    final groups = state.conversations
        .where((item) => item.type == ConversationType.group)
        .toList();
    return AimPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: '群组管理',
            subtitle: '创建群聊、查看成员、更新群信息或退出群聊。',
            trailing: FilledButton.icon(
              onPressed: () =>
                  _showCreateGroupDialog(context, controller, state),
              icon: const Icon(Icons.group_add_rounded),
              label: const Text('创建群聊'),
            ),
          ),
          const SizedBox(height: 16),
          for (final group in groups) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: AvatarCircle(label: group.avatarText, size: 48),
              title: Text(
                group.name,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                '${group.memberIds.length} 位成员 · ${group.isActive ? '正常' : '已归档'}',
              ),
              trailing: Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () => _showConversationInfoDialog(
                      context,
                      controller,
                      state,
                      group,
                    ),
                    child: const Text('管理'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => controller.selectConversation(group.id),
                    child: const Text('打开'),
                  ),
                ],
              ),
            ),
            const Divider(height: 18),
          ],
        ],
      ),
    );
  }
}

class _SettingsSection extends StatefulWidget {
  const _SettingsSection({required this.controller});

  final AimController controller;

  @override
  State<_SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<_SettingsSection> {
  bool _desktopNotifications = true;
  bool _compactMode = false;
  bool _enterToSend = true;

  @override
  Widget build(BuildContext context) {
    return AimPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '设置', subtitle: '通知、外观、快捷键与连接策略。'),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _desktopNotifications,
            onChanged: (value) => setState(() => _desktopNotifications = value),
            title: const Text('桌面通知'),
            subtitle: const Text('收到新消息、好友申请与系统通知时提示。'),
          ),
          SwitchListTile(
            value: _compactMode,
            onChanged: (value) => setState(() => _compactMode = value),
            title: const Text('紧凑会话列表'),
            subtitle: const Text('缩小会话项高度以展示更多消息。'),
          ),
          SwitchListTile(
            value: _enterToSend,
            onChanged: (value) => setState(() => _enterToSend = value),
            title: const Text('Enter 发送，Shift+Enter 换行'),
            subtitle: const Text('桌面端键盘快捷键策略。'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: widget.controller.saveSettings,
            icon: const Icon(Icons.save_rounded),
            label: const Text('保存设置'),
          ),
        ],
      ),
    );
  }
}

class _FeedbackSection extends StatefulWidget {
  const _FeedbackSection({required this.controller});

  final AimController controller;

  @override
  State<_FeedbackSection> createState() => _FeedbackSectionState();
}

class _FeedbackSectionState extends State<_FeedbackSection> {
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AimPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '帮助与反馈', subtitle: '提交问题、建议或故障信息。'),
          const SizedBox(height: 16),
          TextField(
            controller: _feedbackController,
            minLines: 6,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: '请描述你遇到的问题，例如：发送消息失败、无法连接、附件无法下载...',
              alignLabelWithHint: true,
              labelText: '反馈内容',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              widget.controller.submitFeedback(_feedbackController.text);
              _feedbackController.clear();
            },
            icon: const Icon(Icons.send_rounded),
            label: const Text('提交反馈'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: const TextStyle(color: AimColors.muted)),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}

void _showCreateGroupDialog(
  BuildContext context,
  AimController controller,
  AimState state,
) {
  final nameController = TextEditingController(text: '新的 AIM 群聊');
  final selectedIds = <int>{
    for (final friend in state.friends.take(2)) friend.user.id,
  };
  showDialog<void>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('创建群聊'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '群名称',
                      prefixIcon: Icon(Icons.groups_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '选择成员',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final friend in state.friends)
                    CheckboxListTile(
                      value: selectedIds.contains(friend.user.id),
                      onChanged: (value) {
                        setDialogState(() {
                          if (value ?? false) {
                            selectedIds.add(friend.user.id);
                          } else {
                            selectedIds.remove(friend.user.id);
                          }
                        });
                      },
                      title: Text(friend.user.nickname),
                      subtitle: Text(friend.user.email),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () {
                  controller.createGroup(
                    name: nameController.text,
                    memberIds: selectedIds.toList(),
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('创建'),
              ),
            ],
          );
        },
      );
    },
  );
}

void _showAddFriendDialog(BuildContext context, AimController controller) {
  showDialog<void>(
    context: context,
    builder: (context) => _AddFriendDialog(controller: controller),
  );
}

class _AddFriendDialog extends StatefulWidget {
  const _AddFriendDialog({required this.controller});

  final AimController controller;

  @override
  State<_AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<_AddFriendDialog> {
  final _keywordController = TextEditingController();
  List<UserProfile> _results = const [];
  bool _searched = false;
  bool _searching = false;
  bool _sendingUserId(int userId) => _sendingIds.contains(userId);
  final Set<int> _sendingIds = {};

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final keyword = _keywordController.text.trim();
    if (keyword.isEmpty) return;
    setState(() {
      _searching = true;
      _searched = true;
    });
    final results = await widget.controller.searchUsers(keyword);
    if (!mounted) return;
    setState(() {
      _results = results;
      _searching = false;
    });
  }

  Future<void> _sendRequest(UserProfile user) async {
    setState(() => _sendingIds.add(user.id));
    await widget.controller.addFriend(user);
    if (!mounted) return;
    setState(() => _sendingIds.remove(user.id));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加好友'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('user_search_input'),
                    controller: _keywordController,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: const InputDecoration(
                      labelText: '搜索用户',
                      hintText: '输入昵称，例如：Alice / 陈同学',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  key: const Key('user_search_button'),
                  onPressed: _searching ? null : _search,
                  icon: _searching
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search_rounded),
                  label: const Text('搜索'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: _buildResults(context),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
      ],
    );
  }

  Widget _buildResults(BuildContext context) {
    if (_searching) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_searched) {
      return const EmptyState(
        icon: Icons.manage_search_rounded,
        title: '搜索用户并发送好友申请',
        subtitle: '输入昵称搜索，选择目标用户后发起申请。',
      );
    }
    if (_results.isEmpty) {
      return const EmptyState(
        icon: Icons.person_search_rounded,
        title: '没有找到匹配用户',
        subtitle: '请检查昵称关键词后重试。',
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      itemCount: _results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = _results[index];
        final sending = _sendingUserId(user.id);
        return ListTile(
          key: Key('user_search_result_${user.id}'),
          contentPadding: EdgeInsets.zero,
          leading: AvatarCircle(
            label: user.initials,
            size: 40,
            online: user.status == PresenceStatus.online,
          ),
          title: Text(user.nickname),
          subtitle: Text(user.email),
          trailing: FilledButton.tonalIcon(
            onPressed: sending ? null : () => _sendRequest(user),
            icon: sending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.person_add_rounded),
            label: const Text('发送申请'),
          ),
        );
      },
    );
  }
}

void _showProfileDialog(
  BuildContext context,
  AimController controller,
  UserProfile user,
) {
  final nicknameController = TextEditingController(text: user.nickname);
  final bioController = TextEditingController(text: user.bio);
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('编辑个人资料'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nicknameController,
              decoration: const InputDecoration(
                labelText: '昵称',
                prefixIcon: Icon(Icons.badge_rounded),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: bioController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: '个人简介',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            controller.updateProfile(
              nickname: nicknameController.text,
              bio: bioController.text,
            );
            Navigator.of(context).pop();
          },
          child: const Text('保存'),
        ),
      ],
    ),
  );
}

void _showConversationInfoDialog(
  BuildContext context,
  AimController controller,
  AimState state,
  Conversation conversation,
) {
  final nameController = TextEditingController(text: conversation.name);
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        conversation.type == ConversationType.group ? '群聊信息' : '会话信息',
      ),
      content: SizedBox(
        width: 540,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.72,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AvatarCircle(label: conversation.avatarText, size: 58),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        enabled: conversation.type == ConversationType.group,
                        decoration: const InputDecoration(labelText: '会话名称'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '成员 (${conversation.memberIds.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (conversation.type == ConversationType.group)
                      FilledButton.tonalIcon(
                        onPressed: () => _showAddGroupMembersDialog(
                          context,
                          controller,
                          state,
                          conversation,
                        ),
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: const Text('添加成员'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (conversation.ownerId != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: StatusPill(
                      label: '群主：${_displayName(state, conversation.ownerId!)}',
                      icon: Icons.workspace_premium_rounded,
                      color: AimColors.accent,
                    ),
                  ),
                if (conversation.memberIds.isEmpty)
                  const Text('暂无成员信息', style: TextStyle(color: AimColors.muted))
                else
                  Column(
                    children: [
                      for (final id in conversation.memberIds)
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: AimColors.panelAlt,
                          child: ListTile(
                            dense: true,
                            leading: AvatarCircle(
                              label: _initials(_displayName(state, id)),
                              size: 36,
                            ),
                            title: Text(_displayName(state, id)),
                            subtitle: Text(_memberRoleText(conversation, id)),
                            trailing:
                                conversation.type == ConversationType.group
                                ? PopupMenuButton<String>(
                                    tooltip: '成员操作',
                                    onSelected: (action) {
                                      Navigator.of(context).pop();
                                      switch (action) {
                                        case 'remove':
                                          controller.removeGroupMember(
                                            conversation.id,
                                            id,
                                          );
                                        case 'grantAdmin':
                                          controller.grantGroupAdmin(
                                            conversation.id,
                                            id,
                                          );
                                        case 'revokeAdmin':
                                          controller.revokeGroupAdmin(
                                            conversation.id,
                                            id,
                                          );
                                        case 'transferOwner':
                                          controller.transferGroupOwner(
                                            conversation.id,
                                            id,
                                          );
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem<String>(
                                        value: 'remove',
                                        enabled:
                                            conversation.ownerId != id &&
                                            state.currentUser?.id != id,
                                        child: const Text('移出群聊'),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'grantAdmin',
                                        child: Text('设为管理员'),
                                      ),
                                      PopupMenuItem<String>(
                                        value: 'revokeAdmin',
                                        enabled: conversation.ownerId != id,
                                        child: const Text('撤销管理员'),
                                      ),
                                      PopupMenuItem<String>(
                                        value: 'transferOwner',
                                        enabled: conversation.ownerId != id,
                                        child: const Text('转让群主'),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 16),
                const Text(
                  '你可以在这里添加或移除成员、设置管理员、转让群主、退出或解散群聊。',
                  style: TextStyle(color: AimColors.muted, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
        if (conversation.type == ConversationType.group)
          TextButton(
            onPressed: () {
              controller.leaveConversation(conversation.id);
              Navigator.of(context).pop();
            },
            child: const Text('退出群聊'),
          ),
        if (conversation.type == ConversationType.group)
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AimColors.danger),
            onPressed: () {
              controller.dismissGroup(conversation.id);
              Navigator.of(context).pop();
            },
            child: const Text('解散群聊'),
          ),
        if (conversation.type == ConversationType.group)
          FilledButton(
            onPressed: () {
              controller.updateGroupName(conversation.id, nameController.text);
              Navigator.of(context).pop();
            },
            child: const Text('保存'),
          ),
      ],
    ),
  );
}

void _showAddGroupMembersDialog(
  BuildContext context,
  AimController controller,
  AimState state,
  Conversation conversation,
) {
  final candidates = state.friends
      .where(
        (friendship) =>
            friendship.status == FriendStatus.accepted &&
            !conversation.memberIds.contains(friendship.user.id),
      )
      .toList();
  final selectedIds = <int>{};
  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('添加群成员'),
        content: SizedBox(
          width: 420,
          child: candidates.isEmpty
              ? const Text(
                  '没有可添加的好友。请先添加好友，或确认好友尚未加入当前群聊。',
                  style: TextStyle(color: AimColors.muted, height: 1.5),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final friendship in candidates)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: selectedIds.contains(friendship.user.id),
                        onChanged: (checked) {
                          setState(() {
                            if (checked ?? false) {
                              selectedIds.add(friendship.user.id);
                            } else {
                              selectedIds.remove(friendship.user.id);
                            }
                          });
                        },
                        secondary: AvatarCircle(
                          label: friendship.user.initials,
                          size: 34,
                        ),
                        title: Text(friendship.user.nickname),
                        subtitle: Text(friendship.user.email),
                      ),
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: selectedIds.isEmpty
                ? null
                : () {
                    controller.addGroupMembers(
                      conversation.id,
                      selectedIds.toList(),
                    );
                    Navigator.of(context).pop();
                  },
            child: const Text('添加'),
          ),
        ],
      ),
    ),
  );
}

String _memberRoleText(Conversation conversation, int userId) {
  if (conversation.ownerId == userId) return '群主';
  return '成员';
}

void _showMessageActions(BuildContext context, ChatMessage message) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AimColors.panel,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.reply_rounded),
              title: const Text('回复'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: const Text('复制'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.forward_rounded),
              title: const Text('转发'),
              onTap: () => Navigator.pop(context),
            ),
            if (!message.isSystem)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: const Text('撤回/删除'),
                onTap: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _downloadAttachment(
  BuildContext context,
  AimController controller,
  AttachmentMessagePayload payload,
) async {
  final suggestedName = _safeFileName(payload.name);
  final location = await getSaveLocation(
    acceptedTypeGroups: [_typeGroupForKind(payload.kind)],
    suggestedName: suggestedName,
    confirmButtonText: '下载',
  );
  if (location == null) return;
  if (!context.mounted) return;
  _showNotice(context, '正在准备下载...');
  try {
    final result = await controller.downloadAttachment(payload);
    final fileName = _safeFileName(result.fileName);
    final file = XFile.fromData(
      result.bytes,
      name: fileName,
      mimeType: result.mime,
      length: result.bytes.length,
    );
    await file.saveTo(location.path);
    if (!context.mounted) return;
    _showNotice(context, '附件已保存：$fileName');
  } catch (error) {
    if (!context.mounted) return;
    _showNotice(context, '附件下载失败：$error');
  }
}

void _showAttachmentPreviewDialog(
  BuildContext context,
  AimController controller,
  AttachmentMessagePayload payload,
) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(payload.name),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: payload.isImage
                  ? _AttachmentImage(
                      controller: controller,
                      payload: payload,
                      width: 520,
                      height: 320,
                    )
                  : _AttachmentPreviewPlaceholder(payload: payload),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusPill(label: payload.displayKind),
                StatusPill(label: payload.sizeLabel, color: AimColors.muted),
                StatusPill(
                  label: _attachmentStatusLabel(payload),
                  color: _attachmentStatusColor(payload.status),
                ),
                if (_attachmentParseStatusLabel(payload.parseStatus) != null)
                  StatusPill(
                    label: _attachmentParseStatusLabel(payload.parseStatus)!,
                    color: _attachmentParseStatusColor(payload.parseStatus),
                  ),
              ],
            ),
            if (!payload.isImage) ...[
              const SizedBox(height: 12),
              const Text(
                '请下载后使用本地应用打开音频、视频或其他文件。',
                style: TextStyle(color: AimColors.muted),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('关闭'),
        ),
        FilledButton.icon(
          onPressed: () =>
              _downloadAttachment(dialogContext, controller, payload),
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text('下载'),
        ),
      ],
    ),
  );
}

class _AttachmentPreviewPlaceholder extends StatelessWidget {
  const _AttachmentPreviewPlaceholder({required this.payload});

  final AttachmentMessagePayload payload;

  @override
  Widget build(BuildContext context) {
    return _AttachmentPreviewFrame(
      width: 220,
      height: 150,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconForPayload(payload), size: 54, color: AimColors.accent),
          const SizedBox(height: 10),
          Text(
            payload.displayKind,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

String _safeFileName(String name) {
  final trimmed = name.trim().isEmpty ? 'attachment.bin' : name.trim();
  final sanitized = trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  return sanitized.length > 120 ? sanitized.substring(0, 120) : sanitized;
}

void _showNotice(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

String _sectionTitle(AppSection section) {
  return switch (section) {
    AppSection.chats => '会话',
    AppSection.profile => '个人中心',
    AppSection.friends => '好友管理',
    AppSection.friendRequests => '好友申请',
    AppSection.groups => '群组管理',
    AppSection.settings => '设置',
    AppSection.feedback => '帮助与反馈',
    _ => '',
  };
}

String _sectionSubtitle(AppSection section) {
  return switch (section) {
    AppSection.chats => '聊天主页',
    AppSection.profile => '查看与维护当前账号资料。',
    AppSection.friends => '搜索用户、发送好友申请、发起直聊。',
    AppSection.friendRequests => '处理收到或发出的好友申请。',
    AppSection.groups => '创建群聊、管理成员和群资料。',
    AppSection.settings => '通知、快捷键、外观与连接策略。',
    AppSection.feedback => '帮助中心、问题反馈和状态上报。',
    _ => '',
  };
}

const int _maxInlinePreviewBytes = 512 * 1024;

XTypeGroup _typeGroupForKind(String kind) {
  return switch (kind) {
    'image' => const XTypeGroup(
      label: '图片',
      extensions: ['png', 'jpg', 'jpeg', 'gif', 'webp'],
      mimeTypes: ['image/png', 'image/jpeg', 'image/gif', 'image/webp'],
    ),
    'audio' => const XTypeGroup(
      label: '音频',
      extensions: ['mp3', 'wav', 'ogg', 'm4a'],
      mimeTypes: ['audio/mpeg', 'audio/wav', 'audio/ogg', 'audio/mp4'],
    ),
    'video' => const XTypeGroup(
      label: '视频',
      extensions: ['mp4', 'mov', 'webm'],
      mimeTypes: ['video/mp4', 'video/quicktime', 'video/webm'],
    ),
    _ => const XTypeGroup(label: '附件'),
  };
}

String _guessMimeType(String fileName, String kind) {
  final lower = fileName.toLowerCase();
  if (kind == 'image') {
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/png';
  }
  if (kind == 'audio') {
    if (lower.endsWith('.wav')) return 'audio/wav';
    if (lower.endsWith('.ogg')) return 'audio/ogg';
    if (lower.endsWith('.m4a')) return 'audio/mp4';
    return 'audio/mpeg';
  }
  if (kind == 'video') {
    if (lower.endsWith('.mov')) return 'video/quicktime';
    if (lower.endsWith('.webm')) return 'video/webm';
    return 'video/mp4';
  }
  return 'application/octet-stream';
}

String _normalizeMimeForKind(String kind, String fileName, String? mime) {
  final normalized = mime?.trim().toLowerCase() ?? '';
  if (_mimeMatchesKind(kind, normalized)) return normalized;
  return _guessMimeType(fileName, kind);
}

bool _mimeMatchesKind(String kind, String mime) {
  return switch (kind) {
    'image' => mime.startsWith('image/'),
    'audio' => mime.startsWith('audio/'),
    'video' => mime.startsWith('video/'),
    _ => mime.isNotEmpty,
  };
}

String _dataUri(String mime, Uint8List bytes) {
  return 'data:$mime;base64,${base64Encode(bytes)}';
}

String _displayName(AimState state, int userId) {
  if (state.currentUser?.id == userId) {
    return state.currentUser?.nickname ?? '我';
  }
  for (final friendship in [...state.friends, ...state.friendRequests]) {
    if (friendship.user.id == userId) return friendship.user.nickname;
  }
  return '成员 $userId';
}

String _initials(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '?';
  return String.fromCharCodes(trimmed.runes.take(2)).toUpperCase();
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
