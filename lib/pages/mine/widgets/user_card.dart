import 'package:flutter/material.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../design/radius.dart';

class UserCard extends StatelessWidget {
  const UserCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF43089f),
        borderRadius: BorderRadius.circular(AppRadius.feature),
      ),
      child: Row(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: const Icon(Icons.person, size: 32, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.userCardName, style: textTheme.titleLarge?.copyWith(color: Colors.white)),
            const SizedBox(height: 4),
            Text(l10n.aboutSlogan, style: textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.7))),
          ]),
        ),
        Icon(Icons.edit, color: Colors.white.withValues(alpha: 0.5), size: 20),
      ]),
    );
  }
}
