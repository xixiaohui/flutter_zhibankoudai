import 'package:flutter/material.dart';

/// 智伴口袋设计系统 (基于 Clay 启发)
class AppTheme {
  AppTheme._();

  // ── 背景 ──
  static const Color warmCream = Color(0xFFfaf9f7); // 温暖米色页底
  static const Color pureWhite = Color(0xFFFFFFFF);

  // ── 线条 ──
  static const Color oatBorder = Color(0xFFdad4c8);
  static const Color oatLight = Color(0xFFeee9df);
  static const Color coolBorder = Color(0xFFe6e8ec);

  // ── 文字 ──
  static const Color clayBlack = Color(0xFF000000);
  static const Color warmSilver = Color(0xFF9f9b93);
  static const Color warmCharcoal = Color(0xFF55534e);
  static const Color darkCharcoal = Color(0xFF333333);

  // ── Swatch 调色板 ──
  static const Color matcha300 = Color(0xFF84e7a5);
  static const Color matcha600 = Color(0xFF078a52);
  static const Color matcha800 = Color(0xFF02492a);

  static const Color slushie500 = Color(0xFF3bd3fd);
  static const Color slushie800 = Color(0xFF0089ad);

  static const Color lemon400 = Color(0xFFf8cc65);
  static const Color lemon500 = Color(0xFFfbbd41);
  static const Color lemon700 = Color(0xFFd08a11);
  static const Color lemon800 = Color(0xFF9d6a09);

  static const Color ube300 = Color(0xFFc1b0ff);
  static const Color ube800 = Color(0xFF43089f);
  static const Color ube900 = Color(0xFF32037d);

  static const Color pomegranate400 = Color(0xFFfc7981);
  static const Color blueberry800 = Color(0xFF01418d);

  // ── 扩展色板 (DESIGN.md section 2) ──
  static const Color dragonfruit = Color(0xFFfc7981); // alias to pomegranate400
  static const Color darkBorder = Color(0xFF525a69);
  static const Color lightFrost = Color(0xFFeff1f3);
  static const Color badgeBlueBg = Color(0xFFf0f8ff);
  static const Color badgeBlueText = Color(0xFF3859f9);
  static const Color focusRing = Color(0xFF146EF5);
  static const Color ghostBorder = Color(0xFF717989);

  // ── Border Radius Scale (DESIGN.md section 5) ──
  static const double radiusSharp = 4;
  static const double radiusStandard = 8;
  static const double radiusBadge = 11;
  static const double radiusCard = 12;
  static const double radiusFeature = 24;
  static const double radiusSection = 40;
  static const double radiusPill = 1584;

  // ── Spacing Scale (8px base, DESIGN.md section 5) ──
  static const double space1 = 1;
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space6 = 6.4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space12_8 = 12.8;
  static const double space16 = 16;
  static const double space18 = 18;
  static const double space20 = 20;
  static const double space24 = 24;

  // ── 阴影（Clay 三层签名阴影） ──
  static List<BoxShadow> get clayShadow => const [
        BoxShadow(
          color: Color(0x1A000000), // rgba(0,0,0,0.1)
          blurRadius: 1,
          offset: Offset(0, 1),
        ),
        BoxShadow(
          color: Color(0x0A000000), // rgba(0,0,0,0.04)
          blurRadius: 1,
          offset: Offset(0, -1),
        ),
        BoxShadow(
          color: Color(0x0D000000), // rgba(0,0,0,0.05)
          blurRadius: 1,
          offset: Offset(0, -0.5),
        ),
      ];

  static List<BoxShadow> get clayShadowInset => const [
        BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 1,
          offset: Offset(0, 1),
        ),
      ];

  // ── 主题 ──
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: warmCream,
      colorScheme: ColorScheme.light(
        primary: clayBlack,
        secondary: warmSilver,
        surface: pureWhite,
        onSurface: clayBlack,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: clayBlack),
        titleTextStyle: TextStyle(
          color: clayBlack,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: pureWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: oatBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: pureWhite,
          foregroundColor: clayBlack,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: clayBlack,
          side: const BorderSide(color: ghostBorder, width: 1),
          padding: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: pureWhite,
        selectedItemColor: clayBlack,
        unselectedItemColor: warmSilver,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: oatLight,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// 简约深色适配
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1a1a2e),
      colorScheme: ColorScheme.dark(
        primary: Colors.white,
        secondary: warmSilver,
        surface: const Color(0xFF16213e),
        onSurface: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF16213e),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF525a69), width: 1),
        ),
      ),
    );
  }

  /// 十六进制转 Color
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}