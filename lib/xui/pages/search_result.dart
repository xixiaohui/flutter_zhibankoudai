import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/xui/x_design.dart' as xui;

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
    final query = widget.query.trim();
    if (query.isEmpty) {
      loading = false;
    } else {
      fetchResult(query);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  Future<void> fetchResult(String query) async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final res = await http.post(
        Uri.parse("https://www.xclaw.living/api/hunyuan/ai"),
        headers: {
          "Content-Type": "application/json"
        },
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
      backgroundColor: xui.XuiTheme.warmCream,
      appBar: AppBar(
        backgroundColor: xui.XuiTheme.pureWhite,
        elevation: 0,
        foregroundColor: xui.XuiTheme.clayBlack,
        title: const Text('AI 查询'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: xui.XuiTheme.oatBorder),
        ),
      ),
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
            decoration: xui.XuiTheme.inputDecoration(
              hintText: "输入您的问题...",
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
                borderSide: const BorderSide(color: Color(0xFF146EF5), width: 2),
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          onPressed: onSearch,
          child: const Text("分析"),
        ),
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

    if (result == null) {
      return const Center(child: Text("请输入问题并点击分析"));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "分析结果",
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
    return Container(
      decoration: xui.XuiTheme.cardDecoration(radius: 24, color: xui.XuiTheme.pureWhite),
      padding: const EdgeInsets.all(24),
      child: Text(result ?? "", style: xui.XuiTheme.body()),
    );
  }

  Widget _buildSuggestions() {
    return Wrap(
      spacing: 12,
      children: [
        ActionChip(
          backgroundColor: xui.XuiTheme.pureWhite,
          label: const Text("复合材料"),
          labelStyle: xui.XuiTheme.bodyStd().copyWith(color: xui.XuiTheme.blueberry800),
          side: const BorderSide(color: xui.XuiTheme.oatBorder),
          onPressed: () {},
        )
      ],
    );
  }
}
