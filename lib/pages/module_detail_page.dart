import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/daily_content.dart';
import '../providers/module_provider.dart';
import '../providers/daily_content_provider.dart';
import '../config/routes.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadContent();
    });
  }

  Future<void> _loadContent() async {
    final moduleProvider = context.read<ModuleProvider>();
    final contentProvider = context.read<DailyContentProvider>();
    final module = moduleProvider.getModuleById(widget.moduleId);
    if (module != null && contentProvider.getContent(widget.moduleId) == null) {
      contentProvider.loadContent(module);
    }
  }

  @override
  Widget build(BuildContext context) {
    final moduleProvider = context.read<ModuleProvider>();
    final module = moduleProvider.getModuleById(widget.moduleId);

    if (module == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('模块不存在')),
        body: const Center(child: Text('未找到该模块')),
      );
    }

    final moduleColor = AppTheme.fromHex(module.color);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 自定义AppBar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: moduleColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                module.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [moduleColor, moduleColor.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    module.icon,
                    style: TextStyle(fontSize: 64, color: Colors.white.withValues(alpha: 0.3)),
                  ),
                ),
              ),
            ),
          ),

          // 内容区域
          Consumer<DailyContentProvider>(
            builder: (context, contentProvider, _) {
              final content = contentProvider.getContent(widget.moduleId);
              final isLoading = contentProvider.isLoading(widget.moduleId);
              final isGenerating = contentProvider.isGenerating(widget.moduleId);

              if (isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (content == null) {
                return const SliverFillRemaining(
                  child: Center(child: Text('暂无内容')),
                );
              }

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 分类标签
                      if (content.categoryIcon.isNotEmpty || content.category.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: moduleColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${content.categoryIcon} ${content.category}',
                            style: TextStyle(color: moduleColor, fontSize: 13),
                          ),
                        ),

                      // 主要内容
                      Text(
                        content.content,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          height: 1.8,
                        ),
                      ),

                      // 标题/副标题
                      if (content.title.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.only(left: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: moduleColor, width: 3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                content.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: moduleColor,
                                ),
                              ),
                              if (content.subtitle.isNotEmpty)
                                Text(
                                  content.subtitle,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: moduleColor.withValues(alpha: 0.7),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],

                      // AI生成标识
                      if (content.isAiGenerated) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome, size: 14, color: AppTheme.primaryColor),
                              SizedBox(width: 4),
                              Text(
                                'AI 生成内容',
                                style: TextStyle(color: AppTheme.primaryColor, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // 操作按钮
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: isGenerating
                                  ? null
                                  : () => contentProvider.refreshWithAi(module),
                              icon: isGenerating
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.refresh, size: 18),
                              label: Text(isGenerating ? '生成中...' : 'AI 换一条'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _navigateToPoster(context, content),
                              icon: const Icon(Icons.share, size: 18),
                              label: const Text('生成海报'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: moduleColor,
                                side: BorderSide(color: moduleColor),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _navigateToPoster(BuildContext context, DailyContent content) {
    context.push(RoutePaths.poster, extra: {
      'content': content.content,
      'title': content.title,
      'subtitle': content.subtitle,
      'categoryIcon': content.categoryIcon,
    });
  }
}