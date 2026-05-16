import 'package:flutter/material.dart';
import '../../../models/module_config.dart';
import 'featured_card.dart';

class FeaturedRow extends StatelessWidget {
  final List<ModuleConfig> items;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final void Function(String moduleId) onTap;

  const FeaturedRow({
    super.key,
    required this.items,
    required this.textTheme,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
          child: Row(children: [
            const Text('🔥 ', style: TextStyle(fontSize: 14)),
            Text('热门精选', style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.0,
            )),
          ]),
        ),
        SizedBox(
          height: 157,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => FeaturedCard(
              module: items[i],
              textTheme: textTheme,
              colorScheme: colorScheme,
              onTap: () => onTap(items[i].id),
            ),
          ),
        ),
      ],
    );
  }
}
