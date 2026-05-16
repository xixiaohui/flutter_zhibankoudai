import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/routes.dart';
import '../design/spacing.dart';
import '../l10n/gen/app_localizations.dart';
import '../providers/locale_provider.dart';
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
  'hotPicks': ['wisdomBag', 'quote', 'joke', 'movie', 'music', 'programming'],
  'finance': ['finance', 'investment', 'stock', 'economics', 'business', 'tax', 'foreignTrade', 'ecommerce', 'futures'],
  'learning': ['english', 'math', 'literature', 'history', 'idiom', 'apple', 'xinStudy', 'liStudy'],
  'lifestyle': ['travel', 'fishing', 'fitness', 'pet', 'fashion', 'outfit', 'beauty', 'floral', 'decoration', 'photography', 'love'],
  'tech': ['tech', 'robotAi', 'softwareArchitect', 'solidityEngineer', 'uiDesigner', 'growth', 'seoExpert', 'xiaohongshuExpert', 'glassFiber', 'resin'],
  'health': ['tcm', 'fortune'],
  'humanities': ['anthropologist', 'geographer', 'historian', 'narratologist', 'psychologist', 'freud'],
  'practical': ['official', 'handling', 'law', 'fashionBrand', 'military', 'news'],
};

String _catName(String key, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  switch (key) {
    case 'hotPicks': return l10n.catHotPicks;
    case 'finance': return l10n.catFinance;
    case 'learning': return l10n.catLearning;
    case 'lifestyle': return l10n.catLifestyle;
    case 'tech': return l10n.catTech;
    case 'health': return l10n.catHealth;
    case 'humanities': return l10n.catHumanities;
    case 'practical': return l10n.catPractical;
    default: return key;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String? _lastLocale;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      context.read<LocaleProvider>().addListener(_onLocaleChange);
    });
  }

  @override
  void dispose() {
    context.read<LocaleProvider>().removeListener(_onLocaleChange);
    super.dispose();
  }

  void _onLocaleChange() => _loadData();

  Future<void> _loadData() async {
    final mp = context.read<ModuleProvider>();
    final cp = context.read<DailyContentProvider>();
    final locale = context.read<LocaleProvider>().languageCode;

    if (mp.modules.isEmpty || _lastLocale != locale) {
      _lastLocale = locale;
      await mp.loadModules(locale: locale);
    }
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
          final slivers = <Widget>[SliverToBoxAdapter(child: HomeHeader(textTheme: textTheme, colorScheme: colorScheme))];
          if (mp.modules.isNotEmpty) {
            final fm = mp.modules.first;
            final content = cp.getContent(fm.id);
            slivers.add(SliverToBoxAdapter(
              child: DailyCard(
                module: fm, content: content,
                isLoading: cp.isLoading(fm.id), isGenerating: cp.isGenerating(fm.id),
                onTap: () => _navigateToDetail(fm.id),
                onRefresh: () => cp.refreshWithAi(fm, locale: context.read<LocaleProvider>().languageCode),
                onShare: () => _navigateToPoster(content),
              ),
            ));
          }
          slivers.add(SliverToBoxAdapter(child: AiFriendCard(textTheme: textTheme, colorScheme: colorScheme)));
          slivers.add(SliverToBoxAdapter(child: AiCareerCard(textTheme: textTheme, colorScheme: colorScheme)));
          final l10n = AppLocalizations.of(context)!;
          slivers.add(SliverToBoxAdapter(child: SectionTitle(l10n.moreModules)));
          if (mp.isLoading) {
            slivers.add(SliverFillRemaining(child: LoadingGrid(colorScheme: colorScheme)));
          } else if (mp.modules.isEmpty) {
            slivers.add(SliverFillRemaining(child: Center(child: Text(l10n.noModule))));
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

    final featuredIds = _moduleCategories['hotPicks']!;
    final featured = featuredIds.map((id) => moduleMap[id]).whereType<ModuleConfig>().toList();
    if (featured.isNotEmpty) {
      slivers.add(SliverToBoxAdapter(
        child: FeaturedRow(items: featured, textTheme: textTheme, colorScheme: colorScheme, onTap: _navigateToDetail),
      ));
      slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 10)));
    }
    for (final entry in _moduleCategories.entries) {
      if (entry.key == 'hotPicks') continue;
      final catModules = entry.value.map((id) => moduleMap[id]).whereType<ModuleConfig>().toList();
      if (catModules.isEmpty) continue;
      slivers.add(SliverToBoxAdapter(
        child: CategoryLabel(title: _catName(entry.key, context), count: catModules.length, textTheme: textTheme, colorScheme: colorScheme),
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
