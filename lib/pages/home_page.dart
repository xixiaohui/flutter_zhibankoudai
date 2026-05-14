import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/routes.dart';
import '../design/spacing.dart';
import '../models/daily_content.dart';
import '../models/module_config.dart';
import '../providers/module_provider.dart';
import '../providers/daily_content_provider.dart';
import '../widgets/daily_card.dart';
import '../widgets/module_grid_item.dart';
import '../widgets/section_title.dart';
import 'home/widgets/home_header.dart';
import 'home/widgets/featured_row.dart';
import 'home/widgets/promo_cards.dart';
import 'home/widgets/category_label.dart';
import 'home/widgets/loading_grid.dart';

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
    for (final m in mp.modules) { if (cp.getContent(m.id) == null) cp.loadContent(m); }
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
          final slivers = <Widget>[SliverToBoxAdapter(child: HomeHeader(textTheme: textTheme, colorScheme: colorScheme))];
          if (mp.modules.isNotEmpty) {
            final fm = mp.modules.first;
            final content = cp.getContent(fm.id);
            slivers.add(SliverToBoxAdapter(
              child: DailyCard(
                module: fm, content: content,
                isLoading: cp.isLoading(fm.id), isGenerating: cp.isGenerating(fm.id),
                onTap: () => _navigateToDetail(fm.id),
                onRefresh: () => cp.refreshWithAi(fm),
                onShare: () => _navigateToPoster(content),
              ),
            ));
          }
          slivers.add(SliverToBoxAdapter(child: AiFriendCard(textTheme: textTheme, colorScheme: colorScheme)));
          slivers.add(SliverToBoxAdapter(child: AiCareerCard(textTheme: textTheme, colorScheme: colorScheme)));
          slivers.add(SliverToBoxAdapter(child: const SectionTitle('更多模块')));
          if (mp.isLoading) {
            slivers.add(SliverFillRemaining(child: LoadingGrid(colorScheme: colorScheme)));
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
      slivers.add(SliverToBoxAdapter(
        child: FeaturedRow(items: featured, textTheme: textTheme, colorScheme: colorScheme, onTap: _navigateToDetail),
      ));
      slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 10)));
    }
    for (final entry in _moduleCategories.entries) {
      if (entry.key == '热门精选') continue;
      final catModules = entry.value.map((id) => moduleMap[id]).whereType<ModuleConfig>().toList();
      if (catModules.isEmpty) continue;
      slivers.add(SliverToBoxAdapter(
        child: CategoryLabel(title: entry.key, count: catModules.length, textTheme: textTheme, colorScheme: colorScheme),
      ));
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

  void _navigateToDetail(String id) => context.push('/module/$id');

  void _navigateToPoster(DailyContent? c) {
    if (c == null) return;
    context.push(RoutePaths.poster, extra: c);
  }
}
