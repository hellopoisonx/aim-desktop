/// 响应式断点与辅助函数。
///
/// - 移动端：< 600px — 底部导航栏，全屏切换
/// - 平板端：600–920px — NavigationRail 侧边导航
/// - 桌面端：>= 920px — 侧边栏 + 内容区并排
class Breakpoints {
  Breakpoints._();

  /// 移动端最大宽度（不含）。
  static const double mobile = 600;

  /// 平板端最大宽度（不含）。
  static const double tablet = 920;

  /// 当前宽度是否属于移动端。
  static bool isMobile(double width) => width < mobile;

  /// 当前宽度是否属于平板端。
  static bool isTablet(double width) => width >= mobile && width < tablet;

  /// 当前宽度是否属于桌面端。
  static bool isDesktop(double width) => width >= tablet;
}

/// 根据宽度返回合适的侧边栏宽度。
double sidebarWidth(double maxWidth) {
  if (Breakpoints.isMobile(maxWidth)) return maxWidth;
  if (Breakpoints.isTablet(maxWidth)) return 300;
  return 360;
}

/// 消息气泡最大宽度。
double messageBubbleMaxWidth(double maxWidth) {
  if (Breakpoints.isMobile(maxWidth)) return maxWidth * 0.85;
  if (Breakpoints.isTablet(maxWidth)) return 480;
  return 560;
}
