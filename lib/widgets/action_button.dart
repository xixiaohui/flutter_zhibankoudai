import 'package:flutter/material.dart';
import '../design/radius.dart';
import '../design/elevation.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback? onTap;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.loading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: colorScheme.outline, width: 0.5),
          boxShadow: AppElevation.card,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (loading)
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          else
            Icon(icon, size: 18, color: colorScheme.onSurface),
          const SizedBox(width: 6),
          Text(label, style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurface)),
        ]),
      ),
    );
  }
}
