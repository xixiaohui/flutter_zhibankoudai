import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/widgets/content_card.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../config/routes.dart';
import '../design/radius.dart';
import '../design/elevation.dart';
import '../models/daily_content.dart';
import '../models/field_metadata.dart';
import '../providers/module_provider.dart';
import '../providers/daily_content_provider.dart';

class ModuleDetailPage extends StatefulWidget {
  final String moduleId;
  const ModuleDetailPage({super.key, required this.moduleId});

  @override
  State<ModuleDetailPage> createState() => _ModuleDetailPageState();
}

class _ModuleDetailPageState extends State<ModuleDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final mp = context.read<ModuleProvider>();
    final cp = context.read<DailyContentProvider>();
    final m = mp.getModuleById(widget.moduleId);
    if (m != null && cp.getContent(widget.moduleId) == null) cp.loadContent(m);
  }

  static Color _fromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final mp = context.read<ModuleProvider>();
    final module = mp.getModuleById(widget.moduleId);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (module == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('模块不存在')),
        body: const Center(child: Text('未找到该模块')),
      );
    }

    final mc = _fromHex(module.color);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: mc,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(module.name, style: textTheme.titleMedium?.copyWith(color: Colors.white)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [mc, mc.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(module.icon, style: TextStyle(fontSize: 64, color: Colors.white.withValues(alpha: 0.3))),
                ),
              ),
            ),
          ),
          Consumer<DailyContentProvider>(
            builder: (_, cp, _) {
              final content = cp.getContent(widget.moduleId);
              final isLoading = cp.isLoading(widget.moduleId);
              final isGenerating = cp.isGenerating(widget.moduleId);

              if (isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (content != null && (content.categoryIcon.isNotEmpty || content.category.isNotEmpty))
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: mc.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text('${content.categoryIcon} ${content.category}',
                          style: textTheme.labelMedium?.copyWith(color: mc)),
                      ),

                    if (content != null) ...[
                      MarkdownBody(
                        selectable: true,
                        data: content.content,
                        styleSheet: MarkdownStyleSheet(
                          p: textTheme.bodyLarge?.copyWith(height: 1.8, color: colorScheme.onSurface),
                          h1: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface),
                          h2: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
                          strong: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                          blockquote: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.secondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),

                      if (content.title.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.only(left: 16),
                          decoration: BoxDecoration(
                            border: Border(left: BorderSide(color: mc, width: 3)),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(content.title, style: textTheme.titleSmall?.copyWith(color: mc)),
                            if (content.subtitle.isNotEmpty)
                              Text(content.subtitle,
                                style: textTheme.bodySmall?.copyWith(color: mc.withValues(alpha: 0.7))),
                          ]),
                        ),
                      ],

                      if (content.extra.isNotEmpty) _buildMetadataSection(content.extra, mc, textTheme, colorScheme),

                      if (content.isAiGenerated) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF84e7a5).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.auto_awesome, size: 14, color: const Color(0xFF078a52)),
                            const SizedBox(width: 4),
                            Text('AI 生成', style: textTheme.labelSmall?.copyWith(color: const Color(0xFF078a52))),
                          ]),
                        ),
                      ],
                    ],

                    if (content == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Center(child: Text('暂无内容', style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary))),
                      ),

                    const SizedBox(height: 32),

                    Row(children: [
                      Expanded(
                        child: _actionButton(
                          label: isGenerating ? '生成中...' : 'AI 换一条',
                          icon: isGenerating ? Icons.hourglass_empty : Icons.refresh,
                          loading: isGenerating,
                          onTap: isGenerating ? null : () => cp.refreshWithAi(module),
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _outlinedButton(
                          label: '生成海报',
                          icon: Icons.share,
                          onTap: content != null ? () => _navigateToPoster(context, content) : null,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                      ),
                    ]),

                    const SizedBox(height: 32),
                    if (content != null)
                      ContentCard(
                        title: content.title,
                        content: content.content,
                        color: mc,
                        isAi: content.isAiGenerated,
                      ),
                  ]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection(Map<String, dynamic> extra, Color mc, TextTheme textTheme, ColorScheme colorScheme) {
    final rows = <Widget>[];
    extra.forEach((key, value) {
      if (FieldMetadata.skip(key)) return;
      final str = value?.toString() ?? '';
      if (str.isEmpty) return;

      final icon = FieldMetadata.icon(key);
      final label = FieldMetadata.label(key);

      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 16, color: mc),
          const SizedBox(width: 8),
          Text('$label：', style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary)),
          Expanded(child: Text(str, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface, height: 1.5))),
        ]),
      ));
    });

    if (rows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: mc.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: mc.withValues(alpha: 0.12)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    bool loading = false,
    VoidCallback? onTap,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
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

  Widget _outlinedButton({
    required String label,
    required IconData icon,
    VoidCallback? onTap,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
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

  void _navigateToPoster(BuildContext context, DailyContent content) {
    context.push(RoutePaths.poster, extra: content);
  }
}
