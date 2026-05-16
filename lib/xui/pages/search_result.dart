import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/design/colors.dart';
import 'package:flutter_application_zhiban/design/elevation.dart';
import 'package:http/http.dart' as http;
import '../../l10n/gen/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        foregroundColor: AppColors.clayBlack,
        title: Text(l10n.aiAnalysisResult),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppColors.oatBorder),
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
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              filled: true,
              fillColor: AppColors.pureWhite,
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(color: AppColors.oatBorder, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(color: AppColors.oatBorder, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(color: AppColors.focusRing, width: 2),
              ),
            ),
            onSubmitted: (_) => onSearch(),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.blueberry800,
            foregroundColor: AppColors.pureWhite,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: loading ? null : onSearch,
          child: Text(l10n.analyze),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final l10n = AppLocalizations.of(context)!;
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text(l10n.errorOccurred(error.toString())));
    }

    if (result == null) {
      return Center(
        child: Text(
          l10n.searchPlaceholder,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.warmCharcoal),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.questionPrefix(controller.text),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.oatBorder, width: 1),
              boxShadow: AppElevation.card,
            ),
            padding: const EdgeInsets.all(18),
            child: Text(result ?? "", style: Theme.of(context).textTheme.bodyLarge?.copyWith(letterSpacing: 0)),
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
    return ActionChip(
      backgroundColor: AppColors.pureWhite,
      label: Text(text),
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.blueberry800),
      side: const BorderSide(color: AppColors.oatBorder),
      onPressed: () {
        controller.text = text;
        onSearch();
      },
    );
  }
}
