import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/xui/pages/experts.dart';
import 'package:flutter_application_zhiban/design/colors.dart';
import 'package:flutter_application_zhiban/xui/utils/module.dart';
import 'package:flutter_application_zhiban/xui/x_design.dart' show ClayContainer;
import 'package:http/http.dart' as http;

class CollectionsListPage extends StatefulWidget {
  const CollectionsListPage({super.key});

  @override
  State<CollectionsListPage> createState() => _CollectionsListPageState();
}

class _CollectionsListPageState extends State<CollectionsListPage> {
  final List<dynamic> _list = [];
  final ScrollController _controller = ScrollController();

  int page = 1;
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _controller.addListener(() {
      if (!mounted || isLoading || !hasMore) return;
      if (_controller.position.pixels >= _controller.position.maxScrollExtent - 240) {
        _fetchData();
      }
    });
  }

  Future<void> _fetchData({bool isRefresh = false}) async {
    if (isLoading) return;

    setState(() => isLoading = true);
    if (isRefresh) {
      page = 1;
      _list.clear();
      hasMore = true;
    }

    try {
      final res = await http.get(
        Uri.parse('https://www.xclaw.living/api/hunyuan/meta?page=$page&limit=12'),
      );
      if (!mounted) return;

      final jsonData = json.decode(res.body);
      final List data = jsonData['data'] ?? [];
      setState(() {
        _list.addAll(data);
        hasMore = jsonData['hasMore'] ?? false;
        if (hasMore) page++;
      });
    } catch (e) {
      debugPrint("Fetch collections failed: $e");
    }

    if (mounted) setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        foregroundColor: AppColors.clayBlack,
        title: const Text("助手列表"),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppColors.oatBorder),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchData(isRefresh: true),
        child: ListView.builder(
          controller: _controller,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            14,
            14,
            14,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          itemCount: _list.length + 1,
          itemBuilder: (context, index) {
            if (index < _list.length) {
              final item = _list[index];
              return _CollectionRow(collection: item['name'] ?? '');
            }
            return _LoadMoreRow(
              isLoading: isLoading,
              hasMore: hasMore,
              onPressed: _fetchData,
            );
          },
        ),
      ),
    );
  }
}

class _CollectionRow extends StatelessWidget {
  final String collection;

  const _CollectionRow({required this.collection});

  @override
  Widget build(BuildContext context) {
    final module = findModuleByCollection(collection);
    final name = module?.name ?? collection;
    final icon = module?.icon ?? "📁";
    final slogan = module?.slogan ?? "点击查看该数据集";
    final colors = module?.colors;
    final accent = colors != null ? AppColors.fromHex(colors.accent) : AppColors.slushie800;
    final textColor = colors != null ? AppColors.fromHex(colors.text) : AppColors.clayBlack;
    final subTextColor = colors != null ? AppColors.fromHex(colors.textSecondary) : AppColors.warmCharcoal;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClayContainer(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ExpertsPage(collectionName: collection)),
        ),
        borderRadius: 22,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17, color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    slogan,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13, color: subTextColor),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.warmSilver),
          ],
        ),
      ),
    );
  }
}

class _LoadMoreRow extends StatelessWidget {
  final bool isLoading;
  final bool hasMore;
  final VoidCallback onPressed;

  const _LoadMoreRow({
    required this.isLoading,
    required this.hasMore,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(18),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.all(18),
        child: Center(child: Text("没有更多数据", style: Theme.of(context).textTheme.bodyMedium)),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(18),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.lemon500,
          foregroundColor: AppColors.clayBlack,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text("加载更多"),
      ),
    );
  }
}
