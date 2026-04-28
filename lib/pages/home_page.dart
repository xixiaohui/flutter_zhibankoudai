import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../models/daily_content.dart';
import '../providers/module_provider.dart';
import '../providers/daily_content_provider.dart';
import '../widgets/daily_card.dart';
import '../widgets/module_grid_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final mp = context.read<ModuleProvider>();
    final cp = context.read<DailyContentProvider>();
    if (mp.modules.isEmpty) await mp.loadModules();
    for (final m in mp.modules) {
      if (cp.getContent(m.id) == null) cp.loadContent(m);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: _header()),

        Consumer2<DailyContentProvider, ModuleProvider>(
          builder: (_, cp, mp, __) {
            if (mp.modules.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
            final fm = mp.modules.first;
            final content = cp.getContent(fm.id);
            return SliverToBoxAdapter(
              child: DailyCard(
                module: fm, content: content,
                isLoading: cp.isLoading(fm.id), isGenerating: cp.isGenerating(fm.id),
                onTap: () => _navigateToDetail(fm.id),
                onRefresh: () => cp.refreshWithAi(fm),
                onShare: () => _navigateToPoster(content),
              ),
            );
          },
        ),

        SliverToBoxAdapter(child: _sectionTitle(context, '更多模块')),

        Consumer<ModuleProvider>(
          builder: (_, provider, __) {
            if (provider.isLoading) return SliverFillRemaining(child: _loadingGrid());
            if (provider.modules.isEmpty) return const SliverFillRemaining(child: Center(child: Text('暂无模块')));
            final others = provider.modules.skip(1).toList();
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) => ModuleGridItem(module: others[i], onTap: () => _navigateToDetail(others[i].id)),
                  childCount: others.length,
                ),
              ),
            );
          },
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ]),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_dateStr(),
          style: const TextStyle(fontSize: 14, color: AppTheme.warmSilver, letterSpacing: -0.14)),
        const SizedBox(height: 8),
        Row(children: [
          const Text('智伴口袋',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: AppTheme.clayBlack, letterSpacing: -0.64)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.lemon400.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(1584),
            ),
            child: const Text('每日更新',
              style: TextStyle(fontSize: 10, color: AppTheme.clayBlack, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 6),
        const Text('您的个人专家知识库',
          style: TextStyle(fontSize: 15, color: AppTheme.warmSilver, letterSpacing: -0.16)),
      ]),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Text(title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.warmCharcoal,
          letterSpacing: 1.08)),
    );
  }

  Widget _loadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: AppTheme.oatLight, borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  String _dateStr() {
    final now = DateTime.now();
    const wd = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return '${now.year}年${now.month}月${now.day}日 ${wd[now.weekday - 1]}';
  }

  void _navigateToDetail(String id) => context.push('/module/$id');
  void _navigateToPoster(DailyContent? c) {
    if (c == null) return;
    context.push(RoutePaths.poster, extra: {
      'content': c.content, 'title': c.title, 'subtitle': c.subtitle, 'categoryIcon': c.categoryIcon,
    });
  }
}