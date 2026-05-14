import 'package:flutter/material.dart';
import '../design/radius.dart';
import '../design/spacing.dart';
import '../models/module_config.dart';

/// Bento Grid 风格模块网格项
class ModuleGridItem extends StatelessWidget {
  final ModuleConfig module;
  final VoidCallback? onTap;

  const ModuleGridItem({super.key, required this.module, this.onTap});

  static Color _fromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final moduleColor = _fromHex(module.color);

    return Semantics(
      label: '${module.name}模块',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: colorScheme.outline, width: 0.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: moduleColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.standard),
                ),
                child: Center(
                  child: Text(module.icon, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                module.name,
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                module.description,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
