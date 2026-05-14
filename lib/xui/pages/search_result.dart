import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchResultPage extends StatefulWidget {
  final String query;

  const SearchResultPage({super.key, required this.query});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  late final TextEditingController controller;

  String? result;
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.query);
    final query = widget.query.trim();
    if (query.isNotEmpty) {
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
      result = null;
    });

    try {
      final res = await http.post(
        Uri.parse("https://www.xclaw.living/api/hunyuan/ai"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"query": query}),
      );

      final data = jsonDecode(res.body);
      if (!mounted) return;
      setState(() {
        result = data["result"]?.toString() ?? "";
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  void onSearch() {
    final query = controller.text.trim();
    if (query.isEmpty) return;
    fetchResult(query);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
        title: const Text('AI 分析结果'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: colorScheme.outlineVariant),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: _buildSearchBar(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "继续提问...",
              hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              prefixIcon: Icon(Icons.search, color: colorScheme.secondary),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide(color: colorScheme.outline, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide(color: colorScheme.outline, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
            ),
            onSubmitted: (_) => onSearch(),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: loading ? null : onSearch,
          child: const Text("分析"),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text("出错了：$error", style: textTheme.bodyMedium?.copyWith(color: colorScheme.error)));
    }

    if (result == null) {
      return Center(
        child: Text("请输入问题并点击分析",
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary)),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("问题：${controller.text}",
            style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: colorScheme.outline, width: 0.5),
            ),
            padding: const EdgeInsets.all(18),
            child: Text(result ?? "",
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface, letterSpacing: 0)),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _suggestion("玻璃纤维价格趋势"),
              _suggestion("FRP耐腐蚀吗？"),
              _suggestion("树脂怎么选？"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _suggestion(String text) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ActionChip(
      backgroundColor: colorScheme.surfaceContainerHighest,
      label: Text(text),
      labelStyle: textTheme.labelMedium?.copyWith(color: colorScheme.primary),
      side: BorderSide(color: colorScheme.outline),
      onPressed: () {
        controller.text = text;
        onSearch();
      },
    );
  }
}
