library;

/// 智伴口袋 — 间距系统
/// 4dp / 8dp 增量 (Material 3 标准)

class AppSpacing {
  AppSpacing._();

  // ── 基础增量 ──
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // ── 语义别名 ──
  static const double screenHorizontal = 16.0;
  static const double cardPadding = 16.0;
  static const double cardGap = 12.0;
  static const double itemGap = 8.0;
  static const double sectionGap = 24.0;
  static const double listItemInner = 12.0;
  static const double buttonVertical = 14.0;
  static const double buttonHorizontal = 24.0;
  static const double iconPadding = 8.0;
  static const double bottomNavPadding = 12.0;
}
