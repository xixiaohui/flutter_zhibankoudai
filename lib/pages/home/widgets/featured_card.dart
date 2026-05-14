import 'package:flutter/material.dart';
import '../../../design/colors.dart';
import '../../../design/radius.dart';
import '../../../design/elevation.dart';
import '../../../models/module_config.dart';

class FeaturedCard extends StatelessWidget {
  final ModuleConfig module;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final VoidCallback? onTap;

  const FeaturedCard({
    super.key,
    required this.module,
    required this.textTheme,
    required this.colorScheme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.fromHex(module.color);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.feature),
          border: Border.all(color: colorScheme.outline, width: 0.5),
          boxShadow: AppElevation.card,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.standard),
              ),
              child: Center(child: Text(module.icon, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(height: 10),
            Text(module.name,
              style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurface),
              textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(module.description,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary),
              textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
