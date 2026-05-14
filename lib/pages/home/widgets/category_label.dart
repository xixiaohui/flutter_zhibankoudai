import 'package:flutter/material.dart';
import '../../../design/radius.dart';

class CategoryLabel extends StatelessWidget {
  final String title;
  final int count;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const CategoryLabel({
    super.key,
    required this.title,
    required this.count,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: Row(children: [
        Text(title, style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text('$count', style: textTheme.labelSmall?.copyWith(color: colorScheme.secondary)),
        ),
      ]),
    );
  }
}
