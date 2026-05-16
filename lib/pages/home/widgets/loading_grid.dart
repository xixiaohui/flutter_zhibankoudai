import 'package:flutter/material.dart';
import '../../../design/radius.dart';

class LoadingGrid extends StatelessWidget {
  final ColorScheme colorScheme;

  const LoadingGrid({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => Container(
        decoration: BoxDecoration(
          color: colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(AppRadius.feature),
        ),
      ),
    );
  }
}
