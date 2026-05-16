import 'package:flutter/material.dart';
import '../../../design/radius.dart';

class MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final void Function(BuildContext context) onTap;

  const MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class MenuGroup extends StatelessWidget {
  final List<MenuItem> items;

  const MenuGroup({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colorScheme.outline, width: 0.5),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final last = e.key == items.length - 1;
          return Column(children: [
            ListTile(
              leading: Icon(e.value.icon, color: colorScheme.onSurface, size: 22),
              title: Text(e.value.title, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: colorScheme.onSurface)),
              subtitle: Text(e.value.subtitle, style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary)),
              trailing: Icon(Icons.chevron_right, size: 20, color: colorScheme.secondary),
              onTap: () => e.value.onTap(context),
            ),
            if (!last) Divider(height: 1, indent: 16, endIndent: 16, color: colorScheme.outlineVariant),
          ]);
        }).toList(),
      ),
    );
  }
}
