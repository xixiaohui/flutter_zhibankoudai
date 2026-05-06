

import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/xui/x_design.dart' as xui;

import 'search_result.dart' show SearchResultPage;

class AiHeroSection extends StatefulWidget {
  const AiHeroSection({super.key});

  @override
  State<AiHeroSection> createState() => _AiHeroSectionState();
}

class _AiHeroSectionState extends State<AiHeroSection> {
  final TextEditingController controller = TextEditingController();

  void onSearch() async {
    final query = controller.text.trim();
    if (query.isEmpty) return;

    // 👉 后续接 AI API
    print("用户输入: $query");

    // 示例
    // final result = await fetchAiResult(query);

    // print(result);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultPage(query: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: const LinearGradient(
          colors: [
            xui.XuiTheme.slushie500,
            xui.XuiTheme.ube300,
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            '材料 AI 智能助手',
            style: xui.XuiTheme.sectionHeading().copyWith(color: xui.XuiTheme.pureWhite),
          ),
          const SizedBox(height: 16),
          Text(
            '输入问题，获取材料数据与分析结果',
            style: xui.XuiTheme.bodyLarge().copyWith(color: xui.XuiTheme.pureWhite),
          ),
          const SizedBox(height: 40),

          // 👇 AI输入框
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: xui.XuiTheme.inputDecoration(
                      hintText: "请输入材料、价格、应用场景...",
                    ).copyWith(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: xui.XuiTheme.oatBorder, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: xui.XuiTheme.oatBorder, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: xui.XuiTheme.focusRing, width: 2),
                      ),
                    ),
                    onSubmitted: (_) => onSearch(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: xui.XuiTheme.blueberry800,
                    foregroundColor: xui.XuiTheme.pureWhite,
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onSearch,
                  child: const Text("分析"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 👇 推荐问题
          Wrap(
            spacing: 12,
            children: [
              _buildSuggestion("玻璃纤维价格趋势"),
              _buildSuggestion("FRP格栅有哪些规格"),
              _buildSuggestion("短切纤维用途"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSuggestion(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        controller.text = text;
        onSearch();
      },
    );
  }
  
  Future<Object?> fetchAiResult(String query) async {
    return null;
  }
}