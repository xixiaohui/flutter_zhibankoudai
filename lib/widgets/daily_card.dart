import 'package:flutter/material.dart';
import '../design/radius.dart';
import '../design/colors.dart';
import '../design/spacing.dart';
import '../l10n/gen/app_localizations.dart';
import '../models/daily_content.dart';
import '../models/module_config.dart';
import 'skeleton_loader.dart';

class DailyCard extends StatelessWidget {
  final ModuleConfig module;
  final DailyContent? content;
  final bool isLoading;
  final bool isGenerating;
  final VoidCallback? onTap;
  final VoidCallback? onRefresh;
  final VoidCallback? onShare;

  const DailyCard({
    super.key,
    required this.module,
    this.content,
    this.isLoading = false,
    this.isGenerating = false,
    this.onTap,
    this.onRefresh,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final moduleColor = AppColors.fromHex(module.color);
    final useDarkText = moduleColor.computeLuminance() > 0.5;
    final fg = useDarkText ? Colors.black : Colors.white;

    return Semantics(
      label: '${module.name}每日内容卡片',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: moduleColor.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(AppRadius.feature),
            border: Border.all(
              color: moduleColor.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.feature),
            child: Stack(
              children: [
                Positioned(
                  right: -16,
                  top: -16,
                  child: Text(
                    module.icon,
                    style: TextStyle(
                      fontSize: 72,
                      color: fg.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(
                        icon: module.icon,
                        name: module.name,
                        isGenerating: isGenerating,
                        fg: fg,
                        textTheme: textTheme,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _Body(
                        isLoading: isLoading,
                        content: content,
                        fg: fg,
                        textTheme: textTheme,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _Footer(
                        fg: fg,
                        textTheme: textTheme,
                        onRefresh: onRefresh,
                        onShare: onShare,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String icon;
  final String name;
  final bool isGenerating;
  final Color fg;
  final TextTheme textTheme;

  const _Header({
    required this.icon,
    required this.name,
    required this.isGenerating,
    required this.fg,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: fg.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(name, style: textTheme.labelMedium?.copyWith(color: fg)),
          ]),
        ),
        const Spacer(),
        if (isGenerating)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  final bool isLoading;
  final DailyContent? content;
  final Color fg;
  final TextTheme textTheme;

  const _Body({
    required this.isLoading,
    required this.content,
    required this.fg,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const SkeletonParagraph(lines: 4);

    final c = content;
    if (c == null || c.content.isEmpty) {
      return Text(
        AppLocalizations.of(context)!.noContent,
        style: textTheme.bodyLarge?.copyWith(color: fg.withValues(alpha: 0.6)),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (c.categoryIcon.isNotEmpty || c.category.isNotEmpty)
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: fg.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            '${c.categoryIcon} ${c.category}',
            style: textTheme.labelSmall?.copyWith(color: fg),
          ),
        ),
      Text(
        c.content,
        style: textTheme.bodyLarge?.copyWith(color: fg, height: 1.6),
        maxLines: 7,
        overflow: TextOverflow.ellipsis,
      ),
      if (c.title.isNotEmpty) ...[
        const SizedBox(height: 10),
        Text(
          '— ${c.title}',
          style: textTheme.bodyMedium?.copyWith(
            color: fg.withValues(alpha: 0.75),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
      if (c.subtitle.isNotEmpty) ...[
        const SizedBox(height: 2),
        Text(
          c.subtitle,
          style: textTheme.bodySmall?.copyWith(color: fg.withValues(alpha: 0.55)),
        ),
      ],
      if (c.isAiGenerated) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: fg.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.auto_awesome, size: 11, color: fg),
            const SizedBox(width: 3),
            Text(AppLocalizations.of(context)!.aiGenerate, style: textTheme.labelSmall?.copyWith(color: fg)),
          ]),
        ),
      ],
    ]);
  }
}

class _Footer extends StatelessWidget {
  final Color fg;
  final TextTheme textTheme;
  final VoidCallback? onRefresh;
  final VoidCallback? onShare;

  const _Footer({
    required this.fg,
    required this.textTheme,
    this.onRefresh,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      _ActionBtn(icon: Icons.refresh, label: AppLocalizations.of(context)!.refreshLabel, fg: fg, textTheme: textTheme, onTap: onRefresh),
      const SizedBox(width: 12),
      _ActionBtn(icon: Icons.share, label: AppLocalizations.of(context)!.share, fg: fg, textTheme: textTheme, onTap: onShare),
    ]);
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color fg;
  final TextTheme textTheme;
  final VoidCallback? onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.fg,
    required this.textTheme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: fg.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(label, style: textTheme.labelSmall?.copyWith(color: fg)),
        ]),
      ),
    );
  }
}
