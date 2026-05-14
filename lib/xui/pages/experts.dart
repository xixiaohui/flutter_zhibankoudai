import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/xui/pages/expert_detail.dart';
import 'package:flutter_application_zhiban/xui/pages/poster_preview.dart';
import 'package:flutter_application_zhiban/xui/utils/module.dart';
import 'package:flutter_application_zhiban/xui/x_design.dart' as xui;
import 'package:http/http.dart' as http;

class ExpertsPage extends StatefulWidget {
  final String collectionName;

  const ExpertsPage({
    super.key,
    required this.collectionName,
  });

  @override
  State<ExpertsPage> createState() => _ExpertsPageState();
}

class _ExpertsPageState extends State<ExpertsPage> {
  static const baseUrl = "https://www.xclaw.living/api/hunyuan";

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
        Uri.parse(
          '$baseUrl/experts?collection=${Uri.encodeComponent(widget.collectionName)}&page=$page&limit=8',
        ),
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
      debugPrint("Fetch experts failed: $e");
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
    final module = findModuleByCollection(widget.collectionName);
    final title = module?.name ?? widget.collectionName;

    return Scaffold(
      backgroundColor: xui.XuiTheme.warmCream,
      appBar: AppBar(
        backgroundColor: xui.XuiTheme.pureWhite,
        elevation: 0,
        foregroundColor: xui.XuiTheme.clayBlack,
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: xui.XuiTheme.oatBorder),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchData(isRefresh: true),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 720 ? 2 : 1;

            return GridView.builder(
              controller: _controller,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                columns == 1 ? 14 : 18,
                14,
                columns == 1 ? 14 : 18,
                24 + MediaQuery.paddingOf(context).bottom,
              ),
              itemCount: _list.length + 1,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: columns == 1 ? 1.85 : 1.45,
              ),
              itemBuilder: (context, index) {
                if (index < _list.length) {
                  return _ExpertCard(item: _list[index]);
                }
                return _LoadMoreTile(
                  isLoading: isLoading,
                  hasMore: hasMore,
                  onPressed: _fetchData,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ExpertCard extends StatelessWidget {
  final Map item;

  const _ExpertCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final title = item['title'] ?? '';
    final content = item['content'] ?? item['summary'] ?? '';
    final date = item['date'] ?? '';
    final isAI = item['isAIGenerated'] ?? false;

    return xui.ClayContainer(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ExpertDetailPage(item: item)),
        );
      },
      borderRadius: 22,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isAI)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: xui.XuiTheme.pomegranate400.withValues(alpha: 0.08),
                    border: Border.all(color: xui.XuiTheme.pomegranate400),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    "AI解读",
                    style: xui.XuiTheme.bodyStd().copyWith(
                          color: xui.XuiTheme.pomegranate400,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              const Spacer(),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.image_outlined, size: 20),
                tooltip: "生成海报",
                onPressed: () => showPosterPreview(context, item),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: xui.XuiTheme.featureTitle().copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: xui.XuiTheme.bodyStd().copyWith(
                    height: 1.55,
                    color: xui.XuiTheme.darkCharcoal,
                    fontFamily: "NotoSerifSC",
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: xui.XuiTheme.bodyStd().copyWith(
                        fontSize: 12,
                        color: xui.XuiTheme.warmSilver,
                      ),
                ),
              ),
              const Icon(Icons.chevron_right, color: xui.XuiTheme.warmSilver),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadMoreTile extends StatelessWidget {
  final bool isLoading;
  final bool hasMore;
  final VoidCallback onPressed;

  const _LoadMoreTile({
    required this.isLoading,
    required this.hasMore,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!hasMore) {
      return Center(
        child: Text(
          "没有更多数据",
          style: xui.XuiTheme.bodyStd().copyWith(color: xui.XuiTheme.warmSilver),
        ),
      );
    }

    return Center(
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: xui.XuiTheme.lemon500,
          foregroundColor: xui.XuiTheme.clayBlack,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text("加载更多"),
      ),
    );
  }
}

void showPosterPreview(BuildContext context, Map item) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: xui.XuiTheme.pureWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => PosterPreview(item: item),
  );
}
