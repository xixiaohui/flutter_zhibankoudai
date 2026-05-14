import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/routes.dart';
import '../design/radius.dart';
import '../design/spacing.dart';
import '../design/colors.dart';
import '../design/elevation.dart';
import '../models/daily_content.dart';
import '../models/module_config.dart';
import '../providers/module_provider.dart';
import '../providers/daily_content_provider.dart';
import '../widgets/daily_card.dart';
import '../widgets/module_grid_item.dart';

const Map<String, List<String>> _moduleCategories = {
  '热门精选': ['wisdomBag', 'quote', 'joke', 'movie', 'music', 'programming'],
  '财经商业': ['finance', 'investment', 'stock', 'economics', 'business', 'tax', 'foreignTrade', 'ecommerce', 'futures'],
  '学习成长': ['english', 'math', 'literature', 'history', 'idiom', 'apple', 'xinStudy', 'liStudy'],
  '生活休闲': ['travel', 'fishing', 'fitness', 'pet', 'fashion', 'outfit', 'beauty', 'floral', 'decoration', 'photography', 'love'],
  '科技设计': ['tech', 'robotAi', 'softwareArchitect', 'solidityEngineer', 'uiDesigner', 'growth', 'seoExpert', 'xiaohongshuExpert', 'glassFiber', 'resin'],
  '健康养生': ['tcm', 'fortune'],
  '人文社科': ['anthropologist', 'geographer', 'historian', 'narratologist', 'psychologist', 'freud'],
  '实用资讯': ['official', 'handling', 'law', 'fashionBrand', 'military', 'news'],
};

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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: Consumer2<ModuleProvider, DailyContentProvider>(
        builder: (_, mp, cp, __) {
          final slivers = <Widget>[
            SliverToBoxAdapter(child: _header(textTheme, colorScheme)),
          ];

          if (mp.modules.isNotEmpty) {
            final fm = mp.modules.first;
            final content = cp.getContent(fm.id);
            slivers.add(SliverToBoxAdapter(
              child: DailyCard(
                module: fm,
                content: content,
                isLoading: cp.isLoading(fm.id),
                isGenerating: cp.isGenerating(fm.id),
                onTap: () => _navigateToDetail(fm.id),
                onRefresh: () => cp.refreshWithAi(fm),
                onShare: () => _navigateToPoster(content),
              ),
            ));
          }

          slivers.add(SliverToBoxAdapter(child: _aiFriendCard(context, textTheme, colorScheme)));
          slivers.add(SliverToBoxAdapter(child: _aiCareerCard(context, textTheme, colorScheme)));
          slivers.add(SliverToBoxAdapter(child: _sectionTitle(textTheme, colorScheme, '更多模块')));

          if (mp.isLoading) {
            slivers.add(SliverFillRemaining(child: _loadingGrid(colorScheme)));
          } else if (mp.modules.isEmpty) {
            slivers.add(const SliverFillRemaining(child: Center(child: Text('暂无模块'))));
          } else {
            slivers.addAll(_buildModuleSections(mp.modules.skip(1).toList(), textTheme, colorScheme));
          }

          return CustomScrollView(slivers: slivers);
        },
      ),
    );
  }

  List<Widget> _buildModuleSections(List<ModuleConfig> modules, TextTheme textTheme, ColorScheme colorScheme) {
    final moduleMap = <String, ModuleConfig>{for (final m in modules) m.id: m};
    final slivers = <Widget>[];

    final featuredIds = _moduleCategories['热门精选']!;
    final featured = featuredIds.map((id) => moduleMap[id]).whereType<ModuleConfig>().toList();
    if (featured.isNotEmpty) {
      slivers.add(SliverToBoxAdapter(child: _buildFeaturedRow(featured, textTheme, colorScheme)));
      slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 10)));
    }

    for (final entry in _moduleCategories.entries) {
      if (entry.key == '热门精选') continue;
      final catModules = entry.value.map((id) => moduleMap[id]).whereType<ModuleConfig>().toList();
      if (catModules.isEmpty) continue;

      slivers.add(SliverToBoxAdapter(child: _categoryLabel(entry.key, catModules.length, textTheme, colorScheme)));
      slivers.add(SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          delegate: SliverChildBuilderDelegate(
            (_, i) => ModuleGridItem(
              module: catModules[i],
              onTap: () => _navigateToDetail(catModules[i].id),
            ),
            childCount: catModules.length,
          ),
        ),
      ));
      slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 20)));
    }

    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 80)));
    return slivers;
  }

  Widget _buildFeaturedRow(List<ModuleConfig> items, TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
          child: Row(children: [
            const Text('🔥 ', style: TextStyle(fontSize: 14)),
            Text('热门精选', style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.0,
            )),
          ]),
        ),
        SizedBox(
          height: 157,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _featuredCard(items[i], textTheme, colorScheme),
          ),
        ),
      ],
    );
  }

  Widget _featuredCard(ModuleConfig m, TextTheme textTheme, ColorScheme colorScheme) {
    final c = AppColors.fromHex(m.color);
    return GestureDetector(
      onTap: () => _navigateToDetail(m.id),
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.feature),
          border: Border.all(color: colorScheme.outline, width: 0.5),
          boxShadow: AppElevation.card,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.standard),
              ),
              child: Center(child: Text(m.icon, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(height: 10),
            Text(m.name,
              style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurface),
              textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(m.description,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary),
              textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _categoryLabel(String title, int count, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: Row(children: [
        Text(title, style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text('$count', style: textTheme.labelSmall?.copyWith(color: colorScheme.secondary)),
        ),
      ]),
    );
  }

  Widget _aiFriendCard(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GestureDetector(
        onTap: () => context.push('/ai-friend'),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF5F5), Color(0xFFFFF0E8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.feature),
            border: Border.all(color: const Color(0x33FF9A9E)),
            boxShadow: AppElevation.card,
          ),
          child: Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x33FF9A9E), blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: const Center(child: Text('🧸', style: TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('情感陪伴', style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text('和"小智"聊聊天，分享你的心情',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              ]),
            ),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_forward_rounded, size: 18, color: colorScheme.onSurfaceVariant),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _aiCareerCard(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GestureDetector(
        onTap: () => context.push('/career'),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF0F4FF), Color(0xFFEDE9FE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.feature),
            border: Border.all(color: const Color(0x336366F1)),
            boxShadow: AppElevation.card,
          ),
          child: Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x336366F1), blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: const Center(child: Text('💼', style: TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('领域专家', style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text('与180+行业专家深度对话，获取专业见解',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              ]),
            ),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_forward_rounded, size: 18, color: colorScheme.onSurfaceVariant),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _header(TextTheme textTheme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_dateStr(), style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Row(children: [
          Text('智伴口袋', style: textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFf8cc65).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text('每日更新', style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurface)),
          ),
        ]),
        const SizedBox(height: 6),
        Text('您的个人专家知识库', style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary)),
      ]),
    );
  }

  Widget _sectionTitle(TextTheme textTheme, ColorScheme colorScheme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Text(title, style: textTheme.labelMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 1.0,
      )),
    );
  }

  Widget _loadingGrid(ColorScheme colorScheme) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => Container(
        decoration: BoxDecoration(
          color: colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(AppRadius.feature),
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
    context.push(RoutePaths.poster, extra: c);
  }
}
