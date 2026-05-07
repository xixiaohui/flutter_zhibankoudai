import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/widgets/content_card.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../models/daily_content.dart';
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

  @override
  Widget build(BuildContext context) {
    final mp = context.read<ModuleProvider>();
    final module = mp.getModuleById(widget.moduleId);

    if (module == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('模块不存在')),
        body: const Center(child: Text('未找到该模块')),
      );
    }

    final mc = AppTheme.fromHex(module.color);

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 200, pinned: true,
          backgroundColor: mc,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(module.name, style: const TextStyle(color: AppTheme.pureWhite, fontWeight: FontWeight.w600)),
            background: Container(
              decoration: BoxDecoration(gradient: LinearGradient(colors: [mc, mc.withValues(alpha: 0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: Center(child: Text(module.icon, style: TextStyle(fontSize: 64, color: AppTheme.pureWhite.withValues(alpha: 0.3)))),
            ),
          ),
        ),
        Consumer<DailyContentProvider>(
          builder: (_, cp, _) {
            final content = cp.getContent(widget.moduleId);
            final isLoading = cp.isLoading(widget.moduleId);
            final isGenerating = cp.isGenerating(widget.moduleId);

            if (isLoading) return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));

            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // 分类标签
                  if (content != null && (content.categoryIcon.isNotEmpty || content.category.isNotEmpty))
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: mc.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppTheme.radiusPill)),
                      child: Text('${content.categoryIcon} ${content.category}', style: TextStyle(color: mc, fontSize: 13)),
                    ),

                  // 内容
                  if (content != null) ...[

                    MarkdownBody(
                      selectable: true, // ⭐ 可复制
                      data: content.content,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          fontSize: 18,
                          height: 1.8,
                          color: AppTheme.clayBlack,
                        ),
                        h1: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        h2: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        strong: const TextStyle(fontWeight: FontWeight.bold),
                        blockquote: TextStyle(
                          color: AppTheme.warmSilver,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                    ContentCard(
                      title: content.title,
                      content: content.content,
                      color: mc,
                      isAi: content.isAiGenerated,
                    ),

                    if (content.title.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.only(left: 16),
                        decoration: BoxDecoration(border: Border(left: BorderSide(color: mc, width: 3))),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(content.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: mc)),
                          if (content.subtitle.isNotEmpty)
                            Text(content.subtitle, style: TextStyle(fontSize: 14, color: mc.withValues(alpha: 0.7))),
                        ]),
                      ),
                    ],

                    if (content.isAiGenerated) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: AppTheme.matcha300.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(AppTheme.radiusPill)),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.auto_awesome, size: 14, color: AppTheme.matcha600),
                          SizedBox(width: 4),
                          Text('AI 生成', style: TextStyle(color: AppTheme.matcha600, fontSize: 12)),
                        ]),
                      ),
                    ],
                  ],

                  if (content == null)
                    const Padding(padding: EdgeInsets.only(top: 40), child: Center(child: Text('暂无内容', style: TextStyle(color: AppTheme.warmSilver)))),

                  const SizedBox(height: 32),

                  // Clay 风格按钮组
                  Row(children: [
                    Expanded(
                      child: _clayButton(
                        label: isGenerating ? '生成中...' : 'AI 换一条',
                        icon: isGenerating ? Icons.hourglass_empty : Icons.refresh,
                        loading: isGenerating,
                        onTap: isGenerating ? null : () => cp.refreshWithAi(module),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _clayOutlined(
                        label: '生成海报',
                        icon: Icons.share,
                        color: mc,
                        onTap: content != null ? () => _navigateToPoster(context, content) : null,
                      ),
                    ),
                  ]),
                ]),
              ),
            );
          },
        ),
      ]),
    );
  }

  Widget _clayButton({required String label, required IconData icon, bool loading = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(color: AppTheme.oatBorder),
          boxShadow: AppTheme.clayShadow,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (loading)
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          else
            Icon(icon, size: 18, color: AppTheme.clayBlack),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppTheme.clayBlack, fontSize: 16, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  Widget _clayOutlined({required String label, required IconData icon, required Color color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusSharp),
          border: Border.all(color: AppTheme.ghostBorder, width: 1),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: AppTheme.clayBlack),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppTheme.clayBlack, fontSize: 16, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  void _navigateToPoster(BuildContext context, DailyContent content) {
    context.push(RoutePaths.poster, extra: {
      'content': content.content, 'title': content.title, 'subtitle': content.subtitle, 'categoryIcon': content.categoryIcon,
    });
  }
}