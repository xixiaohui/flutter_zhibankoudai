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
  static const Color darkBorderVisible = Color(0xFF525a69);

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

  /// Parse hex color string (with or without #, supports 6 or 7 char hex)
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // ── Extended Palette (migrated from legacy AppTheme) ──
  static const Color matcha300 = Color(0xFF84e7a5);
  static const Color matcha600 = Color(0xFF078a52);
  static const Color matcha800 = Color(0xFF02492a);
  static const Color slushie500 = Color(0xFF3bd3fd);
  static const Color slushie800 = Color(0xFF0089ad);
  static const Color lemon400 = Color(0xFFf8cc65);
  static const Color lemon500 = Color(0xFFfbbd41);
  static const Color lemon700 = Color(0xFFd08a11);
  static const Color lemon800 = Color(0xFF9d6a09);
  static const Color ube100 = Color(0xFFE9E2FF);
  static const Color ube200 = Color(0xFFD8CBFF);
  static const Color ube300 = Color(0xFFc1b0ff);
  static const Color ube800 = Color(0xFF43089f);
  static const Color ube900 = Color(0xFF32037d);
  static const Color pomegranate400 = Color(0xFFfc7981);
  static const Color blueberry800 = Color(0xFF01418d);
  static const Color oatBorder = Color(0xFFdad4c8);
  static const Color oatLight = Color(0xFFeee9df);
  static const Color warmSilver = Color(0xFF9f9b93);
  static const Color warmCharcoal = Color(0xFF55534e);
  static const Color darkCharcoal = Color(0xFF333333);
  static const Color lightFrost = Color(0xFFeff1f3);
  static const Color focusRing = Color(0xFF146EF5);
  static const Color ghostBorder = Color(0xFF717989);
  static const Color dragonfruit = Color(0xFFfc7981);
  static const Color badgeBlueBg = Color(0xFFf0f8ff);
  static const Color badgeBlueText = Color(0xFF3859f9);

  // ── Semantic aliases (backward compatibility with legacy code) ──
  static const Color pureWhite = surface;
  static const Color warmCream = background;
  static const Color clayBlack = foreground;
}
