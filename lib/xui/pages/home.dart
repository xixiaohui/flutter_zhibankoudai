import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/design/colors.dart';
import 'package:flutter_application_zhiban/design/typography.dart';
import 'package:flutter_application_zhiban/design/elevation.dart';
import 'package:flutter_application_zhiban/xui/pages/ai_chat_page.dart';
import 'package:flutter_application_zhiban/xui/pages/collections_grid.dart';
import 'package:flutter_application_zhiban/xui/pages/collections_list.dart';
import 'package:flutter_application_zhiban/xui/pages/search_result.dart';
import 'package:flutter_application_zhiban/widgets/clay_container.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final maxWidth = width >= 900 ? 960.0 : double.infinity;

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        centerTitle: true,
        elevation: 0,
        foregroundColor: AppColors.clayBlack,
        title: const Text("智伴口袋"),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppColors.oatBorder),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: const [
              SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(child: HeroSection()),
              SliverToBoxAdapter(child: SizedBox(height: 14)),
              AiEntrySliver(),
              SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(child: SectionTitle("快捷入口")),
              QuickGridSliver(),
              SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(child: SectionTitle("热门问题")),
              HotGridSliver(),
              SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(child: SectionTitle("行情趋势")),
              MarketGridSliver(),
              SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(child: SectionTitle("推荐功能")),
              FeatureGridSliver(),
              SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(child: SectionTitle("智能助手")),
              AssistantGridSliver(),
              SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(child: SectionTitle("其他助手")),
              OtherAssistantGridSliver(),
              SliverToBoxAdapter(child: SizedBox(height: 84)),
            ],
          ),
        ),
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final compact = _isCompact(context);

    return Padding(
      padding: _pagePadding(context),
      child: Container(
        padding: EdgeInsets.all(compact ? 18 : 24),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(compact ? 28 : 36),
          border: Border.all(color: AppColors.oatBorder, width: 1),
          boxShadow: AppElevation.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "复合材料AI助手",
              style: AppTypography.textTheme.headlineLarge?.copyWith(
                    fontSize: compact ? 34 : 48,
                    height: 1.12,
                    letterSpacing: 0,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "AI分析 · 材料查询 · 行情洞察",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: compact ? 15 : 18,
                    letterSpacing: 0,
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
      MaterialPageRoute(
        builder: (_) => SearchResultPage(query: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,

      // 👉 用户点击键盘搜索
      onSubmitted: (_) => _goSearch(),

      decoration: InputDecoration(
        hintText: "请输入问题，例如：玻璃纤维的价格？",
        filled: true,
        fillColor: AppColors.pureWhite,
        prefixIcon: const Icon(Icons.search),

        // 👉 加一个搜索按钮（推荐）
        suffixIcon: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: _goSearch,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide:
              const BorderSide(color: AppColors.oatBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.focusRing, width: 2),
        ),
      ),
    );
  }
}

class QuickGridSliver extends StatelessWidget {
  const QuickGridSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _HomeAction("AI分析", Icons.smart_toy, const AiChatPage()),
      _HomeAction("材料查询", Icons.search, const CollectionsGridPage()),
      _HomeAction("价格趋势", Icons.show_chart, const AiChatPage()),
      _HomeAction("供应商", Icons.business, const CollectionsListPage()),
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

class HotGridSliver extends StatelessWidget {
  const HotGridSliver({super.key});

  @override
  Widget build(BuildContext context) {
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
          ClayContainer(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SearchResultPage(query: text)),
            ),
            borderRadius: 24,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 15),
              ),
            ),
          ),
      ],
    );
  }
}

class MarketGridSliver extends StatelessWidget {
  const MarketGridSliver({super.key});

  @override
  Widget build(BuildContext context) {
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
          ClayContainer(
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
                  color: item.$3 == "上涨"
                      ? AppColors.lemon700
                      : AppColors.warmSilver,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.$1, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17)),
                      const SizedBox(height: 4),
                      Text(item.$2, style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                ),
                Text(item.$3, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.warmCharcoal)),
              ],
            ),
          ),
      ],
    );
  }
}

class FeatureGridSliver extends StatelessWidget {
  const FeatureGridSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _HomeAction("AI助手", Icons.smart_toy, const AiChatPage()),
      _HomeAction("趋势分析", Icons.auto_graph, const AiChatPage()),
      _HomeAction("材料数据库", Icons.storage, const CollectionsGridPage()),
      _HomeAction("报价工具", Icons.calculate, const AiChatPage()),
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

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(_horizontalInset(context), 0, _horizontalInset(context), 10),
      child: Text(title, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class AssistantGridSliver extends StatelessWidget {
  const AssistantGridSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _AssistantItem(
        title: "AI材料助手",
        desc: "智能分析材料问题",
        icon: Icons.smart_toy,
        page: const AiChatPage(),
      ),
      _AssistantItem(
        title: "行情分析助手",
        desc: "价格趋势与市场分析",
        icon: Icons.auto_graph,
        page: const AiChatPage(),
      ),
    ];

    return _AssistantGrid(items: items);
  }
}

class OtherAssistantGridSliver extends StatelessWidget {
  const OtherAssistantGridSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _AssistantItem(
        title: "报价助手",
        desc: "成本估算与报价生成",
        icon: Icons.calculate,
        page: const AiChatPage(),
      ),
      _AssistantItem(
        title: "外贸助手",
        desc: "英文回复与客户沟通",
        icon: Icons.language,
        page: const AiChatPage(),
      ),
      _AssistantItem(
        title: "我的助手",
        desc: "云端助手瀑布流",
        icon: Icons.grid_3x3,
        page: const CollectionsGridPage(),
      ),
      _AssistantItem(
        title: "助手列表",
        desc: "云端助手列表",
        icon: Icons.list,
        page: const CollectionsListPage(),
      ),
    ];

    return _AssistantGrid(items: items);
  }
}

class _AssistantGrid extends StatelessWidget {
  final List<_AssistantItem> items;

  const _AssistantGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return _AdaptiveGridSliver(
      maxTileWidth: 390,
      minColumns: 1,
      childAspectRatio: _isCompact(context) ? 2.9 : 2.6,
      children: [
        for (final item in items)
          ClayContainer(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => item.page),
            ),
            borderRadius: 24,
            padding: const EdgeInsets.all(16),
            color: AppColors.pureWhite,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.slushie500.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(item.icon, color: AppColors.blueberry800),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17)),
                      const SizedBox(height: 4),
                      Text(
                        item.desc,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.warmCharcoal),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.warmSilver),
              ],
            ),
          ),
      ],
    );
  }
}

class AiEntrySliver extends StatelessWidget {
  const AiEntrySliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: _pagePadding(context),
        child: ClayContainer(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AiChatPage()),
          ),
          borderRadius: 24,
          padding: const EdgeInsets.all(18),
          color: AppColors.slushie500,
          child: Row(
            children: [
              const Icon(Icons.smart_toy, size: 36, color: AppColors.pureWhite),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "AI材料助手",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.pureWhite),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "材料问题 · 行情趋势 · 采购建议",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.pureWhite, height: 1.35),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.pureWhite),
            ],
          ),
        ),
      ),
    );
  }
}

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

class _IconTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _IconTile({required this.title, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      onTap: onTap,
      borderRadius: 22,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.slushie800, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

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

  const _AssistantItem({
    required this.title,
    required this.desc,
    required this.icon,
    required this.page,
  });
}


bool _isCompact(BuildContext context) => MediaQuery.sizeOf(context).width < 600;

double _horizontalInset(BuildContext context) => _isCompact(context) ? 14 : 18;

EdgeInsets _pagePadding(BuildContext context) {
  final horizontal = _horizontalInset(context);
  return EdgeInsets.symmetric(horizontal: horizontal);
}
