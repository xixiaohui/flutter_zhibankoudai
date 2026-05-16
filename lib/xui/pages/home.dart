import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/l10n/gen/app_localizations.dart';
import 'package:flutter_application_zhiban/xui/pages/ai_chat_page.dart';
import 'package:flutter_application_zhiban/xui/pages/collections_grid.dart';
import 'package:flutter_application_zhiban/xui/pages/collections_list.dart';
import 'package:flutter_application_zhiban/xui/pages/search_result.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final maxWidth = width >= 900 ? 960.0 : double.infinity;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        centerTitle: true,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
        title: Text(AppLocalizations.of(context)!.appName),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: colorScheme.outlineVariant),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              const SliverToBoxAdapter(child: HeroSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              const AiEntrySliver(),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(child: _SectionTitle(AppLocalizations.of(context)!.quickEntry)),
              const QuickGridSliver(),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(child: _SectionTitle(AppLocalizations.of(context)!.hotQuestions)),
              const HotGridSliver(),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(child: _SectionTitle(AppLocalizations.of(context)!.marketTrends)),
              const MarketGridSliver(),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(child: _SectionTitle(AppLocalizations.of(context)!.recommendedFeatures)),
              const FeatureGridSliver(),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(child: _SectionTitle(AppLocalizations.of(context)!.smartAssistant)),
              const AssistantGridSliver(),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(child: _SectionTitle(AppLocalizations.of(context)!.otherAssistants)),
              const OtherAssistantGridSliver(),
              const SliverToBoxAdapter(child: SizedBox(height: 84)),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════ Section Title ═══════

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(_horizontalInset(context), 0, _horizontalInset(context), 10),
      child: Text(title, style: textTheme.labelMedium?.copyWith(
        color: colorScheme.secondary,
        letterSpacing: 1.0,
        fontWeight: FontWeight.w600,
      )),
    );
  }
}

// ═══════ Hero Section ═══════

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final compact = _isCompact(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: _pagePadding(context),
      child: Container(
        padding: EdgeInsets.all(compact ? 18 : 24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(compact ? 28 : 36),
          border: Border.all(color: colorScheme.outline, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.compositeMaterialAiAssistant,
              style: textTheme.displaySmall?.copyWith(
                fontSize: compact ? 34 : 48,
                height: 1.12,
                letterSpacing: 0,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.aiAnalysisMaterial,
              style: textTheme.titleMedium?.copyWith(
                fontSize: compact ? 15 : 18,
                letterSpacing: 0,
                color: colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 16),
            const SearchSection(),
          ],
        ),
      ),
    );
  }
}

// ═══════ Search Section ═══════

class SearchSection extends StatefulWidget {
  const SearchSection({super.key});

  @override
  State<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  final TextEditingController _controller = TextEditingController();

  void _goSearch() {
    final query = _controller.text.trim();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SearchResultPage(query: query)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      onSubmitted: (_) => _goSearch(),
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.materialQuestion,
        hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        prefixIcon: Icon(Icons.search, color: colorScheme.secondary),
        suffixIcon: IconButton(
          icon: Icon(Icons.arrow_forward, color: colorScheme.secondary),
          onPressed: _goSearch,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}

// ═══════ Quick Grid ═══════

class QuickGridSliver extends StatelessWidget {
  const QuickGridSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      _HomeAction(l10n.aiAnalysis, Icons.smart_toy, const AiChatPage()),
      _HomeAction(l10n.materialQuery, Icons.search, const CollectionsGridPage()),
      _HomeAction(l10n.priceTrend, Icons.show_chart, const AiChatPage()),
      _HomeAction(l10n.supplier, Icons.business, const CollectionsListPage()),
    ];

    return _AdaptiveGridSliver(
      maxTileWidth: 176,
      childAspectRatio: _isCompact(context) ? 1.12 : 1.18,
      children: [
        for (final item in items)
          _IconTile(
            title: item.title,
            icon: item.icon,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => item.page),
            ),
          ),
      ],
    );
  }
}

// ═══════ Hot Grid ═══════

class HotGridSliver extends StatelessWidget {
  const HotGridSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final items = [
      "玻璃钢为什么发白？",
      "FRP耐腐蚀吗？",
      "玻纤涨价原因",
      "树脂怎么选？",
    ];

    return _AdaptiveGridSliver(
      maxTileWidth: 260,
      minColumns: 1,
      childAspectRatio: _isCompact(context) ? 3.2 : 2.5,
      children: [
        for (final text in items)
          _ThemedCard(
            borderRadius: 24,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SearchResultPage(query: text)),
            ),
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(fontSize: 15, color: colorScheme.onSurface),
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════ Market Grid ═══════

class MarketGridSliver extends StatelessWidget {
  const MarketGridSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final items = [
      ("玻璃纤维纱", "¥4000-5200", "上涨", Icons.trending_up),
      ("不饱和树脂", "¥9000-11000", "平稳", Icons.trending_flat),
    ];

    return _AdaptiveGridSliver(
      maxTileWidth: 260,
      minColumns: 1,
      childAspectRatio: _isCompact(context) ? 2.35 : 1.9,
      children: [
        for (final item in items)
          _ThemedCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(16),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SearchResultPage(query: '${item.$1}价格趋势')),
            ),
            child: Row(
              children: [
                Icon(
                  item.$4,
                  color: item.$3 == "上涨" ? Colors.amber : colorScheme.secondary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.$1, style: textTheme.titleSmall?.copyWith(fontSize: 17, color: colorScheme.onSurface)),
                      const SizedBox(height: 4),
                      Text(item.$2, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface)),
                    ],
                  ),
                ),
                Text(item.$3, style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary)),
              ],
            ),
          ),
      ],
    );
  }
}

// ═══════ Feature Grid ═══════

class FeatureGridSliver extends StatelessWidget {
  const FeatureGridSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      _HomeAction(l10n.smartAssistant, Icons.smart_toy, const AiChatPage()),
      _HomeAction(l10n.trendAnalysis, Icons.auto_graph, const AiChatPage()),
      _HomeAction(l10n.materialDatabase, Icons.storage, const CollectionsGridPage()),
      _HomeAction(l10n.quoteTool, Icons.calculate, const AiChatPage()),
    ];

    return _AdaptiveGridSliver(
      maxTileWidth: 176,
      childAspectRatio: _isCompact(context) ? 1.18 : 1.25,
      children: [
        for (final item in items)
          _IconTile(
            title: item.title,
            icon: item.icon,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => item.page),
            ),
          ),
      ],
    );
  }
}

// ═══════ Assistant Grid ═══════

class AssistantGridSliver extends StatelessWidget {
  const AssistantGridSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      _AssistantItem(title: l10n.aiMaterialAssistant, desc: l10n.smartAnalysisMaterial, icon: Icons.smart_toy, page: const AiChatPage()),
      _AssistantItem(title: l10n.marketAnalysisAssistant, desc: l10n.marketAnalysisDesc, icon: Icons.auto_graph, page: const AiChatPage()),
    ];
    return _AssistantGrid(items: items);
  }
}

class OtherAssistantGridSliver extends StatelessWidget {
  const OtherAssistantGridSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      _AssistantItem(title: l10n.quoteAssistant, desc: l10n.quoteAssistantDesc, icon: Icons.calculate, page: const AiChatPage()),
      _AssistantItem(title: l10n.tradeAssistant, desc: l10n.tradeAssistantDesc, icon: Icons.language, page: const AiChatPage()),
      _AssistantItem(title: l10n.myAssistant, desc: l10n.cloudAssistantWaterfall, icon: Icons.grid_3x3, page: const CollectionsGridPage()),
      _AssistantItem(title: l10n.assistantList, desc: l10n.cloudAssistantList, icon: Icons.list, page: const CollectionsListPage()),
    ];
    return _AssistantGrid(items: items);
  }
}

class _AssistantGrid extends StatelessWidget {
  final List<_AssistantItem> items;
  const _AssistantGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return _AdaptiveGridSliver(
      maxTileWidth: 390,
      minColumns: 1,
      childAspectRatio: _isCompact(context) ? 2.9 : 2.6,
      children: [
        for (final item in items)
          _ThemedCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(16),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => item.page),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(item.icon, color: colorScheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: textTheme.titleSmall?.copyWith(fontSize: 17, color: colorScheme.onSurface)),
                      const SizedBox(height: 4),
                      Text(item.desc, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: colorScheme.secondary),
              ],
            ),
          ),
      ],
    );
  }
}

// ═══════ AI Entry Card (colored — keeps brand color) ═══════

class AiEntrySliver extends StatelessWidget {
  const AiEntrySliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: _pagePadding(context),
        child: _ThemedCard(
          borderRadius: 24,
          padding: const EdgeInsets.all(18),
          color: const Color(0xFF3bd3fd),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AiChatPage()),
          ),
          child: Row(
            children: [
              const Icon(Icons.smart_toy, size: 36, color: Colors.white),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.aiMaterialAssistant,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(AppLocalizations.of(context)!.aiMaterialAssistantDesc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, height: 1.35)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════ Reusable themed card (replaces ClayContainer for non-interactive surfaces) ═══════

class _ThemedCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const _ThemedCard({
    required this.child,
    this.onTap,
    this.borderRadius = 24,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final deco = BoxDecoration(
      color: color ?? colorScheme.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: colorScheme.outline, width: 0.5),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: Container(padding: padding, decoration: deco, child: child),
      );
    }
    return Container(padding: padding, decoration: deco, child: child);
  }
}

// ═══════ Adaptive Grid ═══════

class _AdaptiveGridSliver extends StatelessWidget {
  final List<Widget> children;
  final double maxTileWidth;
  final double childAspectRatio;
  final int minColumns;

  const _AdaptiveGridSliver({
    required this.children,
    required this.maxTileWidth,
    required this.childAspectRatio,
    this.minColumns = 2,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - _horizontalInset(context) * 2;
    final columns = (width / maxTileWidth).floor().clamp(minColumns, 4).toInt();

    return SliverPadding(
      padding: _pagePadding(context),
      sliver: SliverGrid(
        delegate: SliverChildListDelegate(children),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
        ),
      ),
    );
  }
}

// ═══════ Icon Tile ═══════

class _IconTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _IconTile({required this.title, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return _ThemedCard(
      borderRadius: 22,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: colorScheme.primary, size: 28),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: textTheme.labelLarge?.copyWith(fontSize: 16, color: colorScheme.onSurface)),
        ],
      ),
    );
  }
}

// ═══════ Data Classes ═══════

class _HomeAction {
  final String title;
  final IconData icon;
  final Widget page;
  const _HomeAction(this.title, this.icon, this.page);
}

class _AssistantItem {
  final String title;
  final String desc;
  final IconData icon;
  final Widget page;
  const _AssistantItem({required this.title, required this.desc, required this.icon, required this.page});
}

// ═══════ Helpers ═══════

bool _isCompact(BuildContext context) => MediaQuery.sizeOf(context).width < 600;

double _horizontalInset(BuildContext context) => _isCompact(context) ? 14 : 18;

EdgeInsets _pagePadding(BuildContext context) {
  final horizontal = _horizontalInset(context);
  return EdgeInsets.symmetric(horizontal: horizontal);
}
