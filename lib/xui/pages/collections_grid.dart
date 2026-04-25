import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_application_zhiban/xui/pages/experts.dart';
import 'package:flutter_application_zhiban/xui/utils/module.dart';
import 'package:http/http.dart' as http;

class CollectionsGridPage extends StatefulWidget {
  const CollectionsGridPage({super.key});

  @override
  State<CollectionsGridPage> createState() => _CollectionsGridPageState();
}

class _CollectionsGridPageState extends State<CollectionsGridPage> {
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

      if (_controller.position.pixels >
          _controller.position.maxScrollExtent - 200) {
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
        Uri.parse('http://127.0.0.1:3000/api/meta?page=$page&limit=10'),
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
      debugPrint("请求异常: $e");
    }

    if (mounted) setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 1400) return 6;
    if (width > 1000) return 4;
    if (width > 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("数据库列表")),

      body: RefreshIndicator(
        onRefresh: () => _fetchData(isRefresh: true),

        child: MasonryGridView.count(
          controller: _controller,
          physics: const AlwaysScrollableScrollPhysics(),
          crossAxisCount: _getCrossAxisCount(context),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          padding: const EdgeInsets.all(12),
          itemCount: _list.length + 1,

          itemBuilder: (context, index) {
            if (index < _list.length) {
              final item = _list[index];
              return _CollectionItem(name: item['name']);
            }

            // 底部状态
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!hasMore) {
              return const Center(child: Text("没有更多数据"));
            }

            return ElevatedButton(
              onPressed: _fetchData,
              child: const Text("加载更多"),
            );
          },
        ),
      ),
    );
  }
}

class _CollectionItem extends StatefulWidget {
  final String name;

  const _CollectionItem({required this.name});

  @override
  State<_CollectionItem> createState() => _CollectionItemState();
}


class _CollectionItemState extends State<_CollectionItem> {
  bool isHover = false;

  // ⭐ 固定高度（关键！避免抖动）
  late final double dynamicHeight;

  @override
  void initState() {
    super.initState();

    // ⭐ 每个卡片只生成一次高度
    dynamicHeight = 120 + Random().nextInt(80).toDouble();
  }

  Color hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Module? findModuleByCollection(String collection) {
    try {
      return defaultModuleConfig.modules.firstWhere(
        (m) => m.collection == collection,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    final module = findModuleByCollection(widget.name);

    final name = module?.name ?? widget.name;
    final icon = module?.icon ?? '📁';
    final slogan = module?.slogan ?? "点击查看该数据集合";

    final colors = module?.colors;

    final gradientStart = colors != null
        ? hexToColor(colors.gradientStart)
        : Colors.white;

    final gradientEnd = colors != null
        ? hexToColor(colors.gradientEnd)
        : Colors.blue.shade50;

    final textColor = colors != null ? hexToColor(colors.text) : Colors.black;
    final subTextColor =
        colors != null ? hexToColor(colors.textSecondary) : Colors.grey;

    final accentColor =
        colors != null ? hexToColor(colors.accent) : Colors.blue;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExpertsPage(
              collectionName: widget.name,
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120), // ⭐ 更快更稳
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStart, gradientEnd],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              // ⭐ 只轻微变化，不要大幅
              color: Colors.black.withOpacity(isHover ? 0.08 : 0.04),
              blurRadius: isHover ? 12 : 8,
              offset: const Offset(0, 3),
            )
          ],
        ),

        // ⭐ 不要 transform！！！
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面
            Container(
              height: dynamicHeight,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 120),
                  opacity: isHover ? 0.9 : 1,
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),

            // 内容
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    icon,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    slogan,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: subTextColor,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.folder, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.name,
                          style: const TextStyle(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 12),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}