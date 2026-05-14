import 'package:flutter/material.dart';
import '../design/radius.dart';
import '../design/elevation.dart';

class ContentCard extends StatelessWidget {
  final String title;
  final String content;
  final Color color;
  final bool isAi;

  const ContentCard({
    super.key,
    required this.title,
    required this.content,
    required this.color,
    this.isAi = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final paragraphs = content.split('\n\n');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.feature),
        boxShadow: AppElevation.card,
        border: Border.all(color: colorScheme.outline, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (title.isNotEmpty) ...[
          Text(title, style: textTheme.titleLarge?.copyWith(color: color, height: 1.4)),
          const SizedBox(height: 16),
        ],
        ...paragraphs.map((p) => _buildBlock(p, textTheme, colorScheme)),
        const SizedBox(height: 12),
        if (isAi)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF84e7a5).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF078a52)),
              const SizedBox(width: 4),
              Text('AI生成', style: textTheme.labelSmall?.copyWith(color: const Color(0xFF078a52))),
            ]),
          ),
      ]),
    );
  }

  Widget _buildBlock(String text, TextTheme textTheme, ColorScheme colorScheme) {
    final isDialogue = text.contains('：') || text.contains(':');

    if (isDialogue) {
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text.trim(), style: textTheme.bodyLarge?.copyWith(height: 1.7, color: colorScheme.onSurface)),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(text.trim(), style: textTheme.bodyLarge?.copyWith(height: 1.8, color: colorScheme.onSurface)),
    );
  }
}
