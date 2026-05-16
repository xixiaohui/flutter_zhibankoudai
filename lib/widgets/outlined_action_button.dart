import 'package:flutter/material.dart';
import '../design/radius.dart';

class OutlinedActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const OutlinedActionButton({
    super.key,
    required this.label,
    required this.icon,
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
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.standard),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: colorScheme.onSurface),
          const SizedBox(width: 6),
          Text(label, style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurface)),
        ]),
      ),
    );
  }
}
