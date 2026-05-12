import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../models/daily_content.dart';
import '../models/module_config.dart';
import '../providers/module_provider.dart';
import '../providers/daily_content_provider.dart';
import '../widgets/daily_card.dart';
import '../widgets/module_grid_item.dart';
import '../xui/x_design.dart';

/// 模块分类映射 — 每个模块归属于一个展示分组
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
    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      body: Consumer2<ModuleProvider, DailyContentProvider>(
        builder: (_, mp, cp, _) {
          final slivers = <Widget>[
            SliverToBoxAdapter(child: _header()),
          ];

          // Hero card — 第一个模块
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

          slivers.add(SliverToBoxAdapter(child: _aiFriendCard(context)));
          slivers.add(SliverToBoxAdapter(child: _aiCareerCard(context)));
          slivers.add(SliverToBoxAdapter(child: _sectionTitle(context, '更多模块')));

          if (mp.isLoading) {
            slivers.add(SliverFillRemaining(child: _loadingGrid()));
          } else if (mp.modules.isEmpty) {
            slivers.add(const SliverFillRemaining(child: Center(child: Text('暂无模块'))));
          } else {
            slivers.addAll(_buildModuleSections(mp.modules.skip(1).toList()));
          }

          return CustomScrollView(slivers: slivers);
        },
      )
    );
  }

  // ========== 模块分类区域构建 ==========

  List<Widget> _buildModuleSections(List<ModuleConfig> modules) {
    final moduleMap = <String, ModuleConfig>{for (final m in modules) m.id: m};
    final slivers = <Widget>[];

    // ── 横向滚动「热门精选」 ──
    final featuredIds = _moduleCategories['热门精选']!;
    final featured = featuredIds.map((id) => moduleMap[id]).whereType<ModuleConfig>().toList();
    if (featured.isNotEmpty) {
      slivers.add(SliverToBoxAdapter(child: _buildFeaturedRow(featured)));
      slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 10)));
    }

    // ── 各分类模块网格 ──
    for (final entry in _moduleCategories.entries) {
      // 热门精选已在上方横向展示，这里跳过
      if (entry.key == '热门精选') continue;

      final catModules = entry.value
          .map((id) => moduleMap[id])
          .whereType<ModuleConfig>()
          .toList();
      if (catModules.isEmpty) continue;

      slivers.add(SliverToBoxAdapter(
        child: _categoryLabel(entry.key, catModules.length),
      ));
      slivers.add(SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
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

  // ── 横向滚动热门卡片行 ──
  Widget _buildFeaturedRow(List<ModuleConfig> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
          child: Row(children: [
            const Text('🔥 ', style: TextStyle(fontSize: 14)),
            Text('热门精选'.toUpperCase(), style: XuiTheme.uppercaseLabel()),
          ]),
        ),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _featuredCard(items[i]),
          ),
        ),
      ],
    );
  }

  Widget _featuredCard(ModuleConfig m) {
    final c = AppTheme.fromHex(m.color);
    return GestureDetector(
      onTap: () => _navigateToDetail(m.id),
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusFeature),
          border: Border.all(color: AppTheme.oatBorder, width: 1),
          boxShadow: AppTheme.clayShadow,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              ),
              child: Center(child: Text(m.icon, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(height: 10),
            Text(m.name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.clayBlack),
              textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(
              m.description,
              style: const TextStyle(fontSize: 9, color: AppTheme.warmSilver),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── 分类标签 ──
  Widget _categoryLabel(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: Row(children: [
        Text(title, style: XuiTheme.cardHeading().copyWith(fontSize: 16)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.oatLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          ),
          child: Text('$count', style: XuiTheme.badge()),
        ),
      ]),
    );
  }

  // ========== AI 情感陪伴卡片 ==========

  Widget _aiFriendCard(BuildContext context) {
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
            borderRadius: BorderRadius.circular(AppTheme.radiusFeature),
            border: Border.all(color: const Color(0x33FF9A9E)),
            boxShadow: AppTheme.clayShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Color(0x33FF9A9E), blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: const Center(child: Text('🧸', style: TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('情感陪伴',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.clayBlack)),
                    const SizedBox(height: 4),
                    Text('和"小智"聊聊天，分享你的心情',
                      style: XuiTheme.caption()),
                  ],
                ),
              ),
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_forward_rounded, size: 18, color: AppTheme.warmCharcoal),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== AI 职业专家卡片 ==========

  Widget _aiCareerCard(BuildContext context) {
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
            borderRadius: BorderRadius.circular(AppTheme.radiusFeature),
            border: Border.all(color: const Color(0x336366F1)),
            boxShadow: AppTheme.clayShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Color(0x336366F1), blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: const Center(child: Text('💼', style: TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('领域专家',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.clayBlack)),
                    const SizedBox(height: 4),
                    Text('与180+行业专家深度对话，获取专业见解',
                      style: XuiTheme.caption()),
                  ],
                ),
              ),
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_forward_rounded, size: 18, color: AppTheme.warmCharcoal),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== 原有部件 ==========

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_dateStr(), style: XuiTheme.caption()),
        const SizedBox(height: 8),
        Row(children: [
          Text('智伴口袋', style: XuiTheme.cardHeading()),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.lemon400.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            ),
            child: Text('每日更新', style: XuiTheme.badge()),
          ),
        ]),
        const SizedBox(height: 6),
        Text('您的个人专家知识库', style: XuiTheme.navLink()),
      ]),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Text(title.toUpperCase(), style: XuiTheme.uppercaseLabel()),
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
      itemBuilder: (_, _) => Container(
        decoration: BoxDecoration(
          color: AppTheme.oatLight, borderRadius: BorderRadius.circular(AppTheme.radiusFeature),
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
