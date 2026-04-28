import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Clay 风格大写标题标签
class SectionTitle extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry? padding;

  const SectionTitle(this.title, {super.key, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.warmCharcoal,
          letterSpacing: 1.08,
        ),
      ),
    );
  }
}
