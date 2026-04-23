
//基础层（Design System 设计系统）

import 'package:flutter/material.dart';

class AppColors {
  static const primary = 0xFF007AFF;
  static const secondary = 0xFF5856D6;
  static const background = 0xFFFFFFFF;
  static const textPrimary = 0xFF000000;
  static const textSecondary = 0xFF8E8E93;
}

class AppTextStyles {
  static const title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold
  );

  static const body = TextStyle(
    fontSize: 16,
  );
}

class AppSpacing {
  static const small = 8.0;
  static const medium = 16.0;
  static const large = 32.0;
}

class AppTheme {
  static Color fromHex(String hexString) => Color(int.parse(hexString, radix: 16));
}