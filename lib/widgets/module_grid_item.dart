import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/module_config.dart';

/// ModuleGridItem — Clay 风格网格项
class ModuleGridItem extends StatelessWidget {
  final ModuleConfig module;
  final VoidCallback? onTap;

  const ModuleGridItem({super.key, required this.module, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.fromHex(module.color);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusFeature),
          border: Border.all(color: AppTheme.oatBorder, width: 1),
          boxShadow: AppTheme.clayShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              ),
              child: Center(child: Text(module.icon, style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(height: 10),
            Text(module.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.clayBlack),
              textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(module.description,
              style: const TextStyle(fontSize: 9, color: AppTheme.warmSilver),
              textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}