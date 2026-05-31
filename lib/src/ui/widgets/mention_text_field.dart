import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models.dart';
import '../theme.dart';

// ────────────────────────────────────────────────────────
// 数据模型：Mention 条目
// ────────────────────────────────────────────────────────

/// 一个被追踪的 @提及 条目。
/// [start] / [end] 是在当前纯文本中的字符偏移（含 `@` 前缀）。
@immutable
class MentionEntry {
  const MentionEntry({
    required this.userId,
    required this.displayName,
    required this.start,
    required this.end,
  });

  final String userId;
  final String displayName;

  /// 在 controller.text 中的起始字符偏移（`@` 的位置）。
  final int start;

  /// 在 controller.text 中的结束字符偏移（`@名称` 之后的下一字符位置）。
  final int end;

  /// 展示文本，例如 `@张三`。
  String get text => '@$displayName';

  MentionEntry copyWith({
    String? userId,
    String? displayName,
    int? start,
    int? end,
  }) {
    return MentionEntry(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  /// 从消息内容字符串末尾解析出一个 mention 条目。
  /// 格式要求：原样保留的 `@用户名·(userId)` 紧凑编码。
  static MentionEntry? tryParseCompact(String raw) {
    // 匹配 `@名称·(id)` 格式
    final regex = RegExp(r'@(.+?)·\((.+?)\)$');
    final match = regex.firstMatch(raw);
    if (match == null) return null;
    final name = match.group(1)!;
    final id = match.group(2)!;
    final atPos = raw.length - match.group(0)!.length;
    return MentionEntry(
      userId: id,
      displayName: name,
      start: atPos,
      end: raw.length,
    );
  }

  /// 生成紧凑编码字符串 `@名称·(id)`。
  String toCompact() => '@$displayName·($userId)';
}

// ────────────────────────────────────────────────────────
// 自定义 TextEditingController：追踪 Mention
// ────────────────────────────────────────────────────────

/// 扩展 [TextEditingController]，在文本编辑过程中维护 [MentionEntry] 列表。
/// - 文本中保留 `@用户名` 的可读形式。
/// - 通过 [mentions] 暴露提取出的 userId 数组，供发送时使用。
class MentionTextEditingController extends TextEditingController {
  MentionTextEditingController({super.text});

  final List<MentionEntry> _mentions = [];

  /// 当前有效的 mention 条目（已排序，按起始位置）。
  List<MentionEntry> get mentions => List.unmodifiable(_mentions);

  /// 提取所有 userId 列表，供发送时填入 `mentions` 字段。
  List<String> get mentionIds =>
      _mentions.map((entry) => entry.userId).toList();

  /// 光标所在位置的 mention 条目（若光标位于某个 mention 范围内）。
  MentionEntry? mentionAtCursor() {
    final cursor = selection.baseOffset;
    if (cursor < 0) return null;
    for (final entry in _mentions) {
      if (cursor >= entry.start && cursor <= entry.end) return entry;
    }
    return null;
  }

  // ── 覆盖 value setter，确保外部赋值（如回显）后重建 mention ──

  @override
  set value(TextEditingValue newValue) {
    super.value = newValue;
    _rebuildMentions();
  }

  // ── 公开 API ──

  /// 在当前光标位置插入一个 mention（例如 `@张三`），并记录元数据。
  void insertMention(String userId, String displayName) {
    final cursor = selection.baseOffset;
    final prefix = text.substring(0, cursor);
    final suffix = text.substring(cursor);

    // 找到光标前最近的 `@`（支持模糊搜索，即用户已输入部分字符）
    final atIndex = prefix.lastIndexOf('@');
    final replaceFrom = atIndex >= 0 ? atIndex : cursor;

    final mentionText = '@$displayName ';
    final newText = '${text.substring(0, replaceFrom)}$mentionText$suffix';

    final entry = MentionEntry(
      userId: userId,
      displayName: displayName,
      start: replaceFrom,
      end: replaceFrom + mentionText.length - 1, // 不含尾部空格
    );

    // 调整后续 mention 的偏移
    final delta = newText.length - text.length;
    for (final existing in _mentions) {
      if (existing.start >= replaceFrom) {
        _mentions[_mentions.indexOf(existing)] = existing.copyWith(
          start: existing.start + delta,
          end: existing.end + delta,
        );
      }
    }

    _mentions.add(entry);
    _mentions.sort((a, b) => a.start.compareTo(b.start));

    value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: replaceFrom + mentionText.length,
      ),
    );
    notifyListeners();
  }

  /// 以紧凑编码格式重写整个文本（用于序列化/持久化）。
  /// 例如 `"Hello @张三·(123) ，你好吗"`。
  /// 显示时通过 [fromCompact] 还原。
  String toCompactText() {
    if (_mentions.isEmpty) return text;
    var result = text;
    // 从后往前替换，避免偏移混乱
    final sorted = List<MentionEntry>.from(_mentions)
      ..sort((a, b) => b.start.compareTo(a.start));
    for (final entry in sorted) {
      result = result.replaceRange(entry.start, entry.end, entry.toCompact());
    }
    return result;
  }

  /// 从紧凑编码文本还原显示文本和 mention 列表。
  void fromCompact(String compactText) {
    _mentions.clear();
    final regex = RegExp(r'@(.+?)·\((.+?)\)');
    final matches = regex.allMatches(compactText);
    var displayText = compactText;

    // 从后往前替换，避免偏移混淆
    final reversed = matches.toList().reversed;
    for (final match in reversed) {
      final name = match.group(1)!;
      final id = match.group(2)!;
      final displayMention = '@$name';
      final start = match.start;
      final end = match.end;
      displayText = displayText.replaceRange(start, end, displayMention);
      _mentions.add(
        MentionEntry(
          userId: id,
          displayName: name,
          start: start,
          end: start + displayMention.length,
        ),
      );
    }
    _mentions.sort((a, b) => a.start.compareTo(b.start));
    value = TextEditingValue(
      text: displayText,
      selection: TextSelection.collapsed(offset: displayText.length),
    );
  }

  // ── 内部方法 ──

  /// 触发时机：text 发生变化后，重建 mention 列表。
  /// 使用了启发式匹配：检查已知 mention 的 `@displayName` 是否仍在原位置。
  void _rebuildMentions() {
    final currentText = text;
    final valid = <MentionEntry>[];

    for (final entry in _mentions) {
      final expected = entry.text; // @displayName
      final actual = entry.end <= currentText.length
          ? currentText.substring(entry.start, entry.end)
          : '';
      // 位置处的文本仍完全匹配 → mention 保持有效
      if (actual == expected) {
        valid.add(entry);
      }
    }

    _mentions
      ..clear()
      ..addAll(valid..sort((a, b) => a.start.compareTo(b.start)));
  }
}

// ────────────────────────────────────────────────────────
// Mention 候选用户选择器（Overlay 悬浮框）
// ────────────────────────────────────────────────────────

/// 传递给 [MentionTextField] 的用户列表。
typedef MentionUserProvider = List<UserProfile> Function();

/// Overlay 中显示的用户列表弹窗。
class _MentionOverlay extends StatelessWidget {
  const _MentionOverlay({
    required this.users,
    required this.filter,
    required this.onSelect,
    required this.onDismiss,
    required this.dockRect,
    required this.maxHeight,
  });

  final List<UserProfile> users;
  final String filter; // @ 后面用户已输入的过滤文本
  final ValueChanged<UserProfile> onSelect;
  final VoidCallback onDismiss;
  final Rect dockRect; // 光标/输入框的屏幕坐标，用于锚定
  final double maxHeight;

  List<UserProfile> get _filtered {
    if (filter.isEmpty) return users;
    final lower = filter.toLowerCase();
    return users
        .where(
          (u) =>
              u.nickname.toLowerCase().contains(lower) ||
              u.email.toLowerCase().contains(lower),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    if (filtered.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 水平位置：优先右对齐到输入框，但不能超出屏幕
    final panelWidth = 260.0;
    var left = dockRect.right - panelWidth;
    if (left < 8) left = 8;
    if (left + panelWidth > screenWidth - 8) {
      left = screenWidth - panelWidth - 8;
    }

    // 垂直位置：优先显示在光标上方（如 QQ/微信主流做法），空间不够则下方
    final panelHeight = math.min(
      filtered.length * 56.0 + 16, // 项高56 + padding
      maxHeight,
    );
    final spaceAbove = dockRect.top;
    final spaceBelow = screenHeight - dockRect.bottom;
    double top;
    if (spaceAbove > panelHeight + 16 || spaceAbove > spaceBelow) {
      top = dockRect.top - panelHeight - 8;
    } else {
      top = dockRect.bottom + 8;
    }
    // 确保不超出屏幕
    if (top < 8) top = 8;
    if (top + panelHeight > screenHeight - 8) {
      top = screenHeight - panelHeight - 8;
    }

    return Stack(
      children: [
        // 透明遮罩，点击任意位置关闭
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismiss,
            child: Container(color: Colors.transparent),
          ),
        ),
        Positioned(
          left: left,
          top: top,
          width: panelWidth,
          child: Material(
            elevation: 12,
            borderRadius: BorderRadius.circular(14),
            color: AimColors.panel,
            shadowColor: Colors.black38,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: panelHeight),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final user = filtered[index];
                  return _MentionTile(user: user, onTap: () => onSelect(user));
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MentionTile extends StatelessWidget {
  const _MentionTile({required this.user, required this.onTap});

  final UserProfile user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            // 头像
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AimColors.accentStrong,
                    AimColors.accentStrong.withValues(alpha: 0.55),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                user.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.nickname,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  if (user.email.isNotEmpty)
                    Text(
                      user.email,
                      style: const TextStyle(
                        color: AimColors.muted,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AimColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '提及',
                style: TextStyle(
                  color: AimColors.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// MentionTextField：集成 TextField + Overlay 选择器
// ────────────────────────────────────────────────────────

/// 自带 @提及 功能的文本输入组件。
///
/// 使用方式：
/// ```dart
/// MentionTextField(
///   controller: mentionController,
///   usersProvider: () => users,
///   decoration: InputDecoration(...),
///   onSubmitted: (_) => send(),
///   onChanged: (_) => ...,
/// )
/// ```
///
/// 发送时获取数据：
/// ```dart
/// final content = mentionController.text;      // 含 @用户名
/// final mentionIds = mentionController.mentionIds; // [userId, ...]
/// ```
class MentionTextField extends StatefulWidget {
  const MentionTextField({
    super.key,
    required this.controller,
    required this.usersProvider,
    this.decoration,
    this.hintText,
    this.minLines = 1,
    this.maxLines = 5,
    this.onChanged,
    this.onSubmitted,
    this.isDense = false,
    this.contentPadding,
    this.enabled = true,
  });

  final MentionTextEditingController controller;
  final MentionUserProvider usersProvider;
  final InputDecoration? decoration;
  final String? hintText;
  final int minLines;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool isDense;
  final EdgeInsetsGeometry? contentPadding;
  final bool enabled;

  @override
  State<MentionTextField> createState() => _MentionTextFieldState();
}

class _MentionTextFieldState extends State<MentionTextField> {
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();

  /// @ 符号在文本中的位置（触发 selection 时的偏移）。
  int _triggerAtPos = -1;

  /// 用户输入 `@` 后的过滤文本。
  String _filterText = '';

  /// 最近一次文本值，用于检测变化。
  String _lastText = '';

  MentionTextEditingController get _controller => widget.controller;

  List<UserProfile> get _users => widget.usersProvider();

  @override
  void initState() {
    super.initState();
    _lastText = _controller.text;
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _removeOverlay();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MentionTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      _controller.addListener(_onTextChanged);
      _lastText = _controller.text;
    }
  }

  // ── 文本变化监听 ──

  void _onTextChanged() {
    final currentText = _controller.text;
    final currentCursor = _controller.selection.baseOffset;

    // 检测 @ 触发
    if (_lastText != currentText && currentCursor > 0) {
      final changes = _detectAtTrigger(currentText, currentCursor);
      if (changes.triggered) {
        // 用户刚输入了 @
        _triggerAtPos = changes.atPos;
        _filterText = '';
        _showOverlay();
      } else if (_overlayEntry != null && _triggerAtPos >= 0) {
        // 用户正在过滤：更新过滤文本
        if (currentCursor > _triggerAtPos + 1) {
          _filterText = currentText.substring(
            _triggerAtPos + 1,
            math.min(currentCursor, currentText.length),
          );
          // 如果过滤文本包含空格或 @，关闭 overlay
          if (_filterText.contains(' ') || _filterText.contains('@')) {
            _removeOverlay();
          } else {
            _refreshOverlay();
          }
        } else if (currentCursor <= _triggerAtPos) {
          // 光标移到了 @ 之前，关闭 overlay
          _removeOverlay();
        }
      }
    } else if (_lastText != currentText && currentCursor == 0) {
      _removeOverlay();
    }

    _lastText = currentText;
    widget.onChanged?.call(currentText);
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      // 失去焦点时延迟关闭，让 onTap 有机会触发
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!_focusNode.hasFocus) {
          _removeOverlay();
        }
      });
    }
  }

  _AtTriggerResult _detectAtTrigger(String text, int cursor) {
    // 只检测当前文本比上一次多一个 `@` 字符的情况
    final addedLength = text.length - _lastText.length;
    if (addedLength <= 0 || addedLength > text.length) {
      return const _AtTriggerResult(triggered: false, atPos: -1);
    }

    // 检查最近添加的字符是否为 `@`
    // 对于 IME 输入：通过 TextEditingValue 的 composing 范围判断
    final composing = _controller.value.composing;
    final isComposing = composing.isValid && composing.start < composing.end;

    // 如果正在组合输入（IME），不触发
    if (isComposing) {
      return const _AtTriggerResult(triggered: false, atPos: -1);
    }

    // 检查光标前一个字符是否是 `@`
    final pos = cursor - 1;
    if (pos >= 0 && pos < text.length && text[pos] == '@') {
      // 还要检查这个 @ 是否已经在某个 mention 范围内
      final existing = _controller.mentionAtCursor();
      if (existing != null && pos >= existing.start && pos < existing.end) {
        return const _AtTriggerResult(triggered: false, atPos: -1);
      }
      return _AtTriggerResult(triggered: true, atPos: pos);
    }

    return const _AtTriggerResult(triggered: false, atPos: -1);
  }

  // ── Overlay 管理 ──

  void _showOverlay() {
    _removeOverlay();
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;

    _overlayEntry = OverlayEntry(
      builder: (context) => _buildOverlay(renderBox),
    );
    overlay.insert(_overlayEntry!);
  }

  void _refreshOverlay() {
    if (_overlayEntry == null) return;
    _overlayEntry!.markNeedsBuild();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _triggerAtPos = -1;
    _filterText = '';
  }

  Widget _buildOverlay(RenderBox renderBox) {
    // 获取光标在屏幕上的位置
    final caretOffset = _getCaretScreenOffset(renderBox);

    return _MentionOverlay(
      users: _users,
      filter: _filterText,
      onSelect: _onUserSelected,
      onDismiss: _removeOverlay,
      dockRect: caretOffset,
      maxHeight: 280,
    );
  }

  /// 近似计算光标在屏幕上的矩形区域。
  Rect _getCaretScreenOffset(RenderBox renderBox) {
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    // 使用 TextPainter 估算光标位置
    final text = _controller.text;
    final cursorPos = math.min(_controller.selection.baseOffset, text.length);
    final textBeforeCursor = text.substring(0, cursorPos);

    final textStyle = Theme.of(context).textTheme.bodyMedium;
    final textPainter = TextPainter(
      text: TextSpan(text: textBeforeCursor, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: widget.maxLines,
    )..layout(maxWidth: size.width);
    final caretX = textPainter.width;

    // 估算行号和 Y 偏移
    final lineHeight = textPainter.preferredLineHeight;
    final computedLines = textPainter.computeLineMetrics();
    var lineIndex = computedLines.length - 1;
    if (lineIndex < 0) lineIndex = 0;
    final caretY = lineIndex * lineHeight;

    // 考虑内边距
    final contentPad =
        widget.contentPadding ??
        (widget.isDense
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
            : const EdgeInsets.fromLTRB(12, 8, 12, 8));

    return Rect.fromLTWH(
      offset.dx + contentPad.resolve(TextDirection.ltr).left + caretX,
      offset.dy + contentPad.resolve(TextDirection.ltr).top + caretY,
      1,
      lineHeight,
    );
  }

  void _onUserSelected(UserProfile user) {
    _removeOverlay();
    _controller.insertMention(user.id.toString(), user.nickname);
    _focusNode.requestFocus();
  }

  // ── 键盘事件处理 ──

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (_overlayEntry != null) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        _removeOverlay();
        return KeyEventResult.handled;
      }
      // 上下箭头等由 Overlay 内部的 ListView 自然处理，
      // 按 Enter 选择当前高亮项 → 在 onSelect 中处理
      // 但需要拦截 Enter（如果 overlay 存在时不应该发送消息）
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.numpadEnter) {
        // 选择第一个过滤结果
        final filtered = _getFilteredUsers();
        if (filtered.isNotEmpty) {
          _onUserSelected(filtered.first);
        } else {
          _removeOverlay();
        }
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  List<UserProfile> _getFilteredUsers() {
    if (_filterText.isEmpty) return _users;
    final lower = _filterText.toLowerCase();
    return _users
        .where(
          (u) =>
              u.nickname.toLowerCase().contains(lower) ||
              u.email.toLowerCase().contains(lower),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: _onKeyEvent,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        onChanged: (value) {
          // _onTextChanged 已通过 listener 处理
        },
        onSubmitted: (value) {
          _removeOverlay();
          widget.onSubmitted?.call(value);
        },
        decoration:
            widget.decoration ??
            InputDecoration(
              hintText: widget.hintText ?? '输入消息...',
              isDense: widget.isDense,
              contentPadding: widget.contentPadding,
            ),
      ),
    );
  }
}

// ── 辅助类型 ──

class _AtTriggerResult {
  const _AtTriggerResult({required this.triggered, required this.atPos});
  final bool triggered;
  final int atPos;
}

// ────────────────────────────────────────────────────────
// 便捷提供器：从 AimState 提取 Mention 候选用户
// ────────────────────────────────────────────────────────

/// 从当前会话和好友列表中组装 Mention 候选用户列表。
/// 优先展示当前会话的成员，然后是好友列表。
List<UserProfile> mentionCandidatesFromState(AimState state) {
  final seen = <int>{};
  final results = <UserProfile>[];

  // 排除自己
  final selfId = state.currentUser?.id;

  // 1. 当前会话的成员
  final conversation = state.selectedConversation;
  if (conversation != null) {
    final cachedMembers = {
      for (final member in state.membersForConversation(conversation.id))
        member.id: member,
    };
    for (final memberId in conversation.memberIds) {
      if (memberId == selfId || !seen.add(memberId)) continue;
      final cachedMember = cachedMembers[memberId];
      if (cachedMember != null) {
        results.add(cachedMember);
        continue;
      }
      // 成员详情未加载完成时，回退到好友列表。
      final friend = state.friends
          .where((f) => f.user.id == memberId)
          .firstOrNull;
      if (friend != null) {
        results.add(friend.user);
      }
    }
  }

  // 2. 好友列表中未加入会话的成员
  for (final friendship in state.friends) {
    if (friendship.status != FriendStatus.accepted) continue;
    if (friendship.user.id == selfId) continue;
    if (seen.add(friendship.user.id)) {
      results.add(friendship.user);
    }
  }

  return results;
}
