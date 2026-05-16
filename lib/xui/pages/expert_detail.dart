import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/l10n/gen/app_localizations.dart';
import 'package:flutter_application_zhiban/xui/pages/experts.dart';

class ExpertDetailPage extends StatelessWidget {
  final Map item;

  const ExpertDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final title = item['title'] ?? '';
    final content = item['content'] ?? item['summary'] ?? '';
    final date = item['date'] ?? '';
    final compact = MediaQuery.sizeOf(context).width < 600;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
        title: const Text("详情"),
        actions: [
          IconButton(
            icon: const Icon(Icons.image_outlined),
            tooltip: AppLocalizations.of(context)!.generatePoster,
            onPressed: () => showPosterPreview(context, item),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: colorScheme.outlineVariant),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              compact ? 14 : 24,
              compact ? 14 : 24,
              compact ? 14 : 24,
              28 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Container(
              padding: EdgeInsets.all(compact ? 18 : 26),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(compact ? 24 : 32),
                border: Border.all(color: colorScheme.outline, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: compact ? 28 : 36,
                      height: 1.2,
                      letterSpacing: 0,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(date,
                    style: textTheme.bodySmall?.copyWith(fontSize: 13, color: colorScheme.secondary)),
                  Divider(height: 30, color: colorScheme.outlineVariant),
                  Text(content,
                    textAlign: TextAlign.left,
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: compact ? 17 : 18,
                      height: 1.75,
                      letterSpacing: 0,
                      color: colorScheme.onSurface,
                    )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
