import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;


class SearchResultPage extends StatefulWidget {
  final String query;

  const SearchResultPage({super.key, required this.query});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  late TextEditingController controller;

  String? result;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.query);
    fetchResult(widget.query);
  }

  //   Future<void> fetchResult(String query) async {
  //     setState(() {
  //       loading = true;
  //       error = null;
  //     });

  //     try {
  //       // 👉 模拟AI请求（后面换成你的API）
  //       await Future.delayed(const Duration(seconds: 2));

  //       final fakeResult = """
  // 【价格趋势分析】

  // 1. 2024年玻璃纤维价格整体上涨约12%
  // 2. 原因：
  //    - 原材料成本上升
  //    - 市场需求增长
  // 3. 预计短期仍将保持上涨趋势

  // 【建议】
  // - 提前备货
  // - 关注上游原材料价格
  // """;

  //       setState(() {
  //         result = fakeResult;
  //         loading = false;
  //       });
  //     } catch (e) {
  //       setState(() {
  //         error = e.toString();
  //         loading = false;
  //       });
  //     }
  //   }

  Future<void> fetchResult(String query) async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final res = await http.post(
        Uri.parse("http://localhost:3000/ai"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"query": query}),
      );

      final data = jsonDecode(res.body);

      setState(() {
        result = data["result"];
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  void onSearch() {
    final q = controller.text.trim();
    if (q.isEmpty) return;
    fetchResult(q);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 分析结果')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 24),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "继续提问...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onSubmitted: (_) => onSearch(),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(onPressed: onSearch, child: const Text("分析")),
      ],
    );
  }

  Widget _buildContent() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text("出错了：$error"));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "问题：${controller.text}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildResultCard(),

          const SizedBox(height: 24),

          _buildSuggestions(),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(result ?? ""),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Wrap(
      children: [ActionChip(label: const Text("示例问题"), onPressed: () {})],
    );
  }
}
