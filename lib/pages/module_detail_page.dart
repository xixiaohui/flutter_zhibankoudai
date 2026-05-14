import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/widgets/content_card.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../config/routes.dart';
import '../design/radius.dart';
import '../design/colors.dart';
import '../models/daily_content.dart';
import '../providers/module_provider.dart';
import '../providers/daily_content_provider.dart';
import '../widgets/action_button.dart';
import '../widgets/outlined_action_button.dart';
import 'module_detail/widgets/metadata_section.dart';

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

    final mc = AppColors.fromHex(module.color);

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
            builder: (_, cp, __) {
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

                      if (content.extra.isNotEmpty) MetadataSection(extra: content.extra, accentColor: mc),

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
                        child: ActionButton(
                          label: isGenerating ? '生成中...' : 'AI 换一条',
                          icon: isGenerating ? Icons.hourglass_empty : Icons.refresh,
                          loading: isGenerating,
                          onTap: isGenerating ? null : () => cp.refreshWithAi(module),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedActionButton(
                          label: '生成海报',
                          icon: Icons.share,
                          onTap: content != null ? () => _navigateToPoster(context, content) : null,
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


  void _navigateToPoster(BuildContext context, DailyContent content) {
    context.push(RoutePaths.poster, extra: content);
  }
}
