import 'package:flutter/material.dart';
import '../../../config/constants.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../design/radius.dart';

class AboutDialog extends StatelessWidget {
  const AboutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      title: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF43089f),
            borderRadius: BorderRadius.circular(AppRadius.standard),
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 12),
        const Text(AppConstants.appName),
      ]),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.aboutSlogan, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 16),
        _AboutRow(l10n.aboutVersionLabel, AppConstants.appVersion),
        _AboutRow(l10n.aboutBuildLabel, l10n.aboutBuildValue),
        _AboutRow(l10n.aboutDesignLabel, l10n.aboutDesignValue),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.aboutGotIt)),
      ],
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;

  const _AboutRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(width: 60, child: Text(label, style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary))),
        Expanded(child: Text(value, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface))),
      ]),
    );
  }
}
