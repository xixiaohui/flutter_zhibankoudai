import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/xui/pages/collections_page.dart';

import 'ai_hero.dart' show AiHeroSection;
import 'experts.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('智伴口袋'),
        actions: [
          TextButton(onPressed: () {}, child: const Text("登录")),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            AiHeroSection(),
            SectionContainer(child: BusinessSection()),
            SectionContainer(child: StatsSection()),
            SectionContainer(child: HotSearchSection()),
            SectionContainer(child: FeaturesSection()),
            SectionContainer(child: StepsSection()),
            SectionContainer(child: CasesSection()),
            FooterSection(),
          ],
        ),
      ),
    );
  }
}

// 通用容器（统一间距 + 最大宽度）
class SectionContainer extends StatelessWidget {
  final Widget child;

  const SectionContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: child,
        ),
      ),
    );
  }
}

// ================== Business ==================
class BusinessSection extends StatelessWidget {
  const BusinessSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: const [
        BusinessCard(icon: Icons.search, title: "材料查询", desc: "快速查找产品"),
        BusinessCard(icon: Icons.show_chart, title: "价格趋势", desc: "历史数据分析"),
        BusinessCard(icon: Icons.smart_toy, title: "AI助手", desc: "智能分析推荐"),
      ],
    );
  }
}

class BusinessCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String desc;

  const BusinessCard({
    super.key,
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  State<BusinessCard> createState() => _BusinessCardState();
}

class _BusinessCardState extends State<BusinessCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 260,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: hover
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: hover
              ? [const BoxShadow(blurRadius: 20, color: Colors.black12)]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(widget.icon, size: 40),
            const SizedBox(height: 16),
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(widget.desc),
          ],
        ),
      ),
    );
  }
}

// ================== Stats ==================
class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 40,
      alignment: WrapAlignment.center,
      children: const [
        _StatItem("1000+", "材料数据"),
        _StatItem("50+", "供应商"),
        _StatItem("10万+", "查询次数"),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}

// ================== Hot Search ==================
class HotSearchSection extends StatelessWidget {
  const HotSearchSection({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      "玻璃纤维价格趋势",
      "FRP格栅规格",
      "短切纤维用途",
      "环氧树脂配比",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("热门搜索", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          children: items.map((e) {
            return ActionChip(label: Text(e), onPressed: () {});
          }).toList(),
        ),
      ],
    );
  }
}

// ================== Features ==================
class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: const [
        _FeatureItem(Icons.smart_toy, "AI分析", "自动分析数据"),
        _FeatureItem(Icons.search, "快速查询", "毫秒级响应"),
        _FeatureItem(Icons.show_chart, "趋势预测", "价格分析"),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _FeatureItem(this.icon, this.title, this.desc);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Column(
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(desc),
        ],
      ),
    );
  }
}

// ================== Steps ==================
class StepsSection extends StatelessWidget {
  const StepsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, // ⭐ 关键：不撑满高度
        children: const [
          _StepItem("1", "输入问题"),
          _StepItem("2", "AI分析"),
          _StepItem("3", "获取结果"),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String step;
  final String text;

  const _StepItem(this.step, this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250, // ⭐ 控制整体宽度（更像卡片）
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(child: Text(step)),
        title: Text(
          text,
          textAlign: TextAlign.center, // ⭐ 文本居中
        ),
      ),
    );
  }
}

// ================== Cases ==================
class CasesSection extends StatelessWidget {
  const CasesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("应用场景"),
        SizedBox(height: 16),
        _CaseItem("外贸询盘", "自动生成英文回复"),
        _CaseItem("采购分析", "价格趋势判断"),
      ],
    );
  }
}

class _CaseItem extends StatelessWidget {
  final String title;
  final String desc;

  const _CaseItem(this.title, this.desc);

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(title), subtitle: Text(desc));
  }
}

// ================== Footer ==================
class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      color: colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          Wrap(
            spacing: 40,
            children: [
              Text("智伴口袋"),
              Text("产品"),
              Text("资源"),
              Text("公司"),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExpertsPage(collectionName: "dailyAnthropologists",),
                    ),
                  );
                },
                child: const Text("进入专家列表"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CollectionsPage(),
                    ),
                  );
                },
                child: const Text("所有助理"),
              )
            ],
          ),
          const SizedBox(height: 20),
          const Text("© 2026 智伴口袋"),
          
        ],
      ),
    );
  }
}


