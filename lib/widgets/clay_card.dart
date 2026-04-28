import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Clay 风格通用卡片容器
class ClayCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Border? border;

  const ClayCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 24,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(color: AppTheme.oatBorder, width: 1),
        boxShadow: AppTheme.clayShadow,
      ),
      child: child,
    );
  }
}
