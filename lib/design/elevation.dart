import 'package:flutter/material.dart';

/// 智伴口袋 — 阴影 / Elevation 层级

class AppElevation {
  AppElevation._();

  /// Level 0 — 平坦，无阴影
  static List<BoxShadow> get none => [];

  /// Level 1 — 默认卡片 (2% opacity)
  static List<BoxShadow> get card => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.02),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  /// Level 2 — 悬浮卡片 (4% opacity)
  static List<BoxShadow> get raised => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  /// Level 3 — Modal / Sheet (8% opacity + scrim)
  static List<BoxShadow> get modal => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  /// Scrim for modals (40% black)
  static Color get scrim => const Color(0xFF000000).withValues(alpha: 0.4);

  /// Material elevation values
  static const double elevationNone = 0.0;
  static const double elevationCard = 0.5;
  static const double elevationRaised = 2.0;
  static const double elevationModal = 8.0;
}
