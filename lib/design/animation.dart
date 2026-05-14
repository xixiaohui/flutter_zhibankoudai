import 'package:flutter/material.dart';

/// 智伴口袋 — 动效 Token
/// Apple HIG + Material 3 标准

class AppMotion {
  AppMotion._();

  // ── Duration ──
  static const Duration instant = Duration.zero;
  static const Duration micro = Duration(milliseconds: 100);
  static const Duration short = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration long = Duration(milliseconds: 400);

  // ── Easing ──
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeIn = Curves.easeInCubic;
  static const Curve easeStandard = Curves.easeInOut;

  // ── Stagger ──
  static const Duration staggerDelay = Duration(milliseconds: 40);

  // ── Press Feedback ──
  static const double pressScale = 0.98;

  // ── 检查 reduced-motion ──
  static bool isReducedMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// 根据 reduced-motion 自适应 duration
  static Duration adaptive(BuildContext context, Duration duration) {
    return isReducedMotion(context) ? instant : duration;
  }
}
