import 'package:flutter/material.dart';

/// 智伴口袋 — 语义颜色 Token
/// Knowledge Base / AI 知识产品调色板
/// Light & Dark 双模式

class AppColors {
  AppColors._();

  // ── Light Mode ──
  static const Color primary = Color(0xFF475569);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF64748B);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF2563EB);
  static const Color onAccent = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color foreground = Color(0xFF1E293B);
  static const Color muted = Color(0xFFEAEFF3);
  static const Color mutedForeground = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color destructive = Color(0xFFDC2626);
  static const Color onDestructive = Color(0xFFFFFFFF);

  // ── Dark Mode ──
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkForeground = Color(0xFFF8FAFC);
  static const Color darkMuted = Color(0xFF1E293B);
  static const Color darkMutedForeground = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color darkBorderVisible = Color(0xFF334155);

  // ── Semantic ──
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF2563EB);

  // ── Light ColorScheme ──
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    secondary: secondary,
    onSecondary: onSecondary,
    tertiary: accent,
    onTertiary: onAccent,
    error: destructive,
    onError: onDestructive,
    surface: surface,
    onSurface: foreground,
    surfaceContainerHighest: surfaceVariant,
    outline: border,
    outlineVariant: muted,
  );

  // ── Dark ColorScheme ──
  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF94A3B8),
    onPrimary: Color(0xFF1E293B),
    secondary: Color(0xFF94A3B8),
    onSecondary: Color(0xFF1E293B),
    tertiary: Color(0xFF60A5FA),
    onTertiary: Color(0xFF1E293B),
    error: Color(0xFFFCA5A5),
    onError: Color(0xFF1E293B),
    surface: darkSurface,
    onSurface: darkForeground,
    surfaceContainerHighest: darkSurfaceVariant,
    outline: darkBorderVisible,
    outlineVariant: darkMuted,
  );
}
