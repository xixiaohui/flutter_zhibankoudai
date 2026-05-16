import 'package:flutter/material.dart';
import '../../../models/field_metadata.dart';

class MetadataSection extends StatelessWidget {
  final Map<String, dynamic> extra;
  final Color accentColor;

  const MetadataSection({
    super.key,
    required this.extra,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final rows = <Widget>[];
    extra.forEach((key, value) {
      if (FieldMetadata.skip(key)) return;
      final str = value?.toString() ?? '';
      if (str.isEmpty) return;

      final icon = FieldMetadata.icon(key);
      final label = FieldMetadata.label(key);

      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 16, color: accentColor),
          const SizedBox(width: 8),
          Text('$label：', style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary)),
          Expanded(child: Text(str, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface, height: 1.5))),
        ]),
      ));
    });

    if (rows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withValues(alpha: 0.12)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows),
      ),
    );
  }
}
