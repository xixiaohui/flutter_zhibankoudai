import 'package:flutter/material.dart';
import '../../../design/radius.dart';
import '../../../l10n/gen/app_localizations.dart';

class HomeHeader extends StatelessWidget {
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const HomeHeader({super.key, required this.textTheme, required this.colorScheme});

  String _dateStr(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final wd = [l10n.weekdayMon, l10n.weekdayTue, l10n.weekdayWed, l10n.weekdayThu, l10n.weekdayFri, l10n.weekdaySat, l10n.weekdaySun];
    return '${now.year}年${now.month}月${now.day}日 ${wd[now.weekday - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_dateStr(context), style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Row(children: [
          Text(l10n.appName, style: textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFf8cc65).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(l10n.dailyUpdate, style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurface)),
          ),
        ]),
        const SizedBox(height: 6),
        Text(l10n.personalKnowledgeBase, style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary)),
      ]),
    );
  }
}
