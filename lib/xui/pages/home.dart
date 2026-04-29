import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/xui/x_design.dart' as xui;
import 'package:flutter_application_zhiban/xui/pages/ai_chat_page.dart';
import 'package:flutter_application_zhiban/xui/pages/collections_grid.dart';
import 'package:flutter_application_zhiban/xui/pages/collections_list.dart';
import 'package:flutter_application_zhiban/xui/pages/search_result.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > 1000;

  @override
  Widget build(BuildContext context) {
    final desktop = isDesktop(context);

    return Scaffold(
      backgroundColor: xui.XuiTheme.warmCream,
      appBar: AppBar(
        backgroundColor: xui.XuiTheme.pureWhite,
        centerTitle: true,
        elevation: 0,
        foregroundColor: xui.XuiTheme.clayBlack,
        title: const Text("智伴口袋"),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: xui.XuiTheme.oatBorder),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: desktop ? 1200 : double.infinity,
          ),
          child: CustomScrollView(
            slivers: const [
              SliverToBoxAdapter(child: SizedBox(height: 16)),

              /// Hero
              SliverToBoxAdapter(child: HeroSection()),
              SliverToBoxAdapter(child: SizedBox(height: 16)),


              /// 🔥 新增这里
              AiEntrySliver(),
              SliverToBoxAdapter(child: SizedBox(height: 24)),
              /// 快捷入口
              QuickGridSliver(),
              SliverToBoxAdapter(child: SizedBox(height: 24)),

              /// 热门
              SliverToBoxAdapter(child: SectionTitle("热门问题")),
              HotGridSliver(),
              SliverToBoxAdapter(child: SizedBox(height: 24)),

              /// 行情
              SliverToBoxAdapter(child: SectionTitle("行情趋势")),
              MarketGridSliver(),
              SliverToBoxAdapter(child: SizedBox(height: 24)),

              /// 功能
              SliverToBoxAdapter(child: SectionTitle("推荐功能")),
              FeatureGridSliver(),
              SliverToBoxAdapter(child: SizedBox(height: 24)),

              /// 我的助手
              SliverToBoxAdapter(child: SectionTitle("智能助手")),
              AssistantGridSliver(),
              SliverToBoxAdapter(child: SizedBox(height: 24)),

              SliverToBoxAdapter(child: SectionTitle("其他助手")),
              OtherAssistantGridSliver(),
              SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }
}



////////////////////////////////////////////////////////////
/// 🧠 Hero
////////////////////////////////////////////////////////////
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: xui.XuiTheme.cardDecoration(radius: 40, color: xui.XuiTheme.pureWhite),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("复合材料智能助手", style: xui.XuiTheme.displayHero()),
            const SizedBox(height: 8),
            Text("AI分析 · 材料查询 · 行情洞察", style: xui.XuiTheme.subHeading()),
            const SizedBox(height: 16),
            const SearchSection(),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// 🔍 搜索
////////////////////////////////////////////////////////////
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

      decoration: xui.XuiTheme.inputDecoration(
        hintText: "请输入问题，例如：玻璃纤维的价格？",
      ).copyWith(
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
              const BorderSide(color: xui.XuiTheme.oatBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF146EF5), width: 2),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ⚡ 快捷入口
////////////////////////////////////////////////////////////
class QuickGridSliver extends StatelessWidget {
  const QuickGridSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ("AI分析", Icons.smart_toy),
      ("材料查询", Icons.search),
      ("价格趋势", Icons.show_chart),
      ("供应商", Icons.business),
    ];

    final count = _getGridCount(context);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final item = items[i];
            return _GridItem(title: item.$1, icon: item.$2);
          },
          childCount: items.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: count > items.length ? items.length : count,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// 🔥 热门
////////////////////////////////////////////////////////////
class HotGridSliver extends StatelessWidget {
  const HotGridSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      "格栅为什么发白？",
      "FRP耐腐蚀吗？",
      "玻纤涨价原因",
      "树脂怎么选？",
    ];

    final count = _getGridCount(context);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, i) => xui.ClayContainer(
            borderRadius: 24,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Center(
              child: Text(items[i],
                  textAlign: TextAlign.center,
                  style: xui.XuiTheme.body()),
            ),
          ),
          childCount: items.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: count,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.8,
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// 📈 行情
////////////////////////////////////////////////////////////
class MarketGridSliver extends StatelessWidget {
  const MarketGridSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ("玻璃纤维纱", "¥4000-5200", "上涨"),
      ("不饱和树脂", "¥9000-11000", "平稳"),
    ];

    final count = _getGridCount(context);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, i) {
            final item = items[i];
            final isUp = item.$3 == "上涨";

            return xui.ClayContainer(
              borderRadius: 24,
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.$1, style: xui.XuiTheme.featureTitle()),
                  const SizedBox(height: 8),
                  Text(item.$2, style: xui.XuiTheme.cardHeading()),
                  const SizedBox(height: 8),
                  Icon(
                    isUp ? Icons.trending_up : Icons.trending_flat,
                    color: isUp ? xui.XuiTheme.lemon700 : xui.XuiTheme.warmSilver,
                  ),
                  Text(item.$3, style: xui.XuiTheme.body()),
                ],
              ),
            );
          },
          childCount: items.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: count,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// 🧩 功能
////////////////////////////////////////////////////////////
class FeatureGridSliver extends StatelessWidget {
  const FeatureGridSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ("AI助手", Icons.smart_toy),
      ("趋势分析", Icons.auto_graph),
      ("材料数据库", Icons.storage),
      ("报价工具", Icons.calculate),
    ];

    final count = _getGridCount(context);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, i) {
            final item = items[i];
            return xui.ClayContainer(
              borderRadius: 24,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              color: xui.XuiTheme.pureWhite,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.$2, color: xui.XuiTheme.blueberry800),
                  const SizedBox(height: 8),
                  Text(item.$1, style: xui.XuiTheme.featureTitle()),
                ],
              ),
            );
          },
          childCount: items.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: count,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// 🧱 标题
////////////////////////////////////////////////////////////
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(
        title.toUpperCase(),
        style: xui.XuiTheme.uppercaseLabel(),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// Grid Item
////////////////////////////////////////////////////////////
class _GridItem extends StatelessWidget {
  final String title;
  final IconData icon;

  const _GridItem({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return xui.ClayContainer(
      onTap: () {
        debugPrint("点击: $title");
      },
      borderRadius: 24,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: xui.XuiTheme.slushie800),
          const SizedBox(height: 8),
          Text(title, style: xui.XuiTheme.featureTitle()),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// 📐 响应式列数
////////////////////////////////////////////////////////////
int _getGridCount(BuildContext context) {
  final width = MediaQuery.of(context).size.width;

  if (width > 1200) return 4;
  if (width > 800) return 3;
  return 2;
}


class AssistantGridSliver extends StatelessWidget {
  const AssistantGridSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _AssistantItem(
        title: "AI材料助手",
        desc: "智能分析问题",
        icon: Icons.smart_toy,
        page: const AiChatPage(),
      ),
      _AssistantItem(
        title: "行情分析助手",
        desc: "价格趋势 + 市场分析",
        icon: Icons.auto_graph,
        page: const MarketAiPage(),
      ),
    ];

    final count = _getGridCount(context);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final item = items[i];

            return xui.ClayContainer(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item.page),
                );
              },
              borderRadius: 24,
              padding: const EdgeInsets.all(20),
              color: xui.XuiTheme.pureWhite,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.icon, size: 32, color: xui.XuiTheme.blueberry800),
                  const SizedBox(height: 12),
                  Text(item.title, style: xui.XuiTheme.featureTitle()),
                  const SizedBox(height: 6),
                  Text(item.desc, style: xui.XuiTheme.bodyStd()),
                ],
              ),
            );
          },
          childCount: items.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: count,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
        ),
      ),
    );
  }
}

class _AssistantItem {
  final String title;
  final String desc;
  final IconData icon;
  final Widget page;

  _AssistantItem({
    required this.title,
    required this.desc,
    required this.icon,
    required this.page,
  });
}

class MarketAiPage extends StatelessWidget {
  const MarketAiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("行情分析助手")),
      body: const Center(child: Text("行情 AI 分析页面")),
    );
  }
}


class OtherAssistantGridSliver extends StatelessWidget {
  const OtherAssistantGridSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _AssistantItem(
        title: "报价助手",
        desc: "成本估算 / 报价生成",
        icon: Icons.calculate,
        page: const QuoteAiPage(),
      ),
      _AssistantItem(
        title: "外贸助手",
        desc: "英文回复 / 客户沟通",
        icon: Icons.language,
        page: const TradeAiPage(),
      ),
       _AssistantItem(
        title: "我的助手Grid",
        desc: "云端助手",
        icon: Icons.grid_3x3,
        page: const CollectionsGridPage(),
      ),
       _AssistantItem(
        title: "我的助手List",
        desc: "云端助手",
        icon: Icons.list,
        page: const CollectionsListPage(),
      ),
    ];

    final count = _getGridCount(context);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final item = items[i];

            return xui.ClayContainer(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item.page),
                );
              },
              borderRadius: 24,
              padding: const EdgeInsets.all(20),
              color: xui.XuiTheme.pureWhite,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.icon, size: 28, color: xui.XuiTheme.matcha800),
                  const SizedBox(height: 12),
                  Text(item.title, style: xui.XuiTheme.featureTitle()),
                  const SizedBox(height: 6),
                  Text(item.desc, style: xui.XuiTheme.bodyStd()),
                ],
              ),
            );
          },
          childCount: items.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: count,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
        ),
      ),
    );
  }
}


class QuoteAiPage extends StatelessWidget {
  const QuoteAiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("报价助手")),
      body: const Center(child: Text("报价生成 / 成本分析")),
    );
  }
}

class TradeAiPage extends StatelessWidget {
  const TradeAiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("外贸助手")),
      body: const Center(child: Text("外贸询盘回复 / 英文生成")),
    );
  }
}

/// 进入AI聊天页面
class AiEntrySliver extends StatelessWidget {
  const AiEntrySliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
child: xui.ClayContainer(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AiChatPage(),
                ),
              );
            },
            borderRadius: 24,
            padding: const EdgeInsets.all(20),
            color: xui.XuiTheme.slushie500,
            child: Row(
              children: [
                const Icon(Icons.smart_toy, size: 40, color: Colors.white),
                const SizedBox(width: 16),

                /// 文本
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "AI材料助手",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "智能分析材料问题 · 行情趋势 · 采购建议",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const Icon(Icons.arrow_forward_ios, color: Colors.white),
              ],
            ),
          ),
        ),
      );
  }
}