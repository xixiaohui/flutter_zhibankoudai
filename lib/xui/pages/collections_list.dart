import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/xui/x_design.dart' as xui;
import 'package:flutter_application_zhiban/xui/pages/experts.dart';
import 'package:flutter_application_zhiban/xui/utils/module.dart';
import 'package:http/http.dart' as http;

class CollectionsListPage extends StatefulWidget {
  const CollectionsListPage({super.key});

  @override
  State<CollectionsListPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsListPage> {
  final List<dynamic> _list = [];

  final ScrollController _controller = ScrollController();

  int page = 1;
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();

    _fetchData();

    // ⭐ Web强制监听（关键！！）
    _controller.addListener(() {
      debugPrint(
        "ScrollController 监听滚动: ${_controller.position.pixels} / ${_controller.position.maxScrollExtent}",
      );
      if (!mounted || isLoading || !hasMore) return;

      final max = _controller.position.maxScrollExtent;
      final current = _controller.position.pixels;

      if (current >= max - 200) {
        debugPrint("ScrollController 触底");
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
        Uri.parse('https://www.xclaw.living/api/hunyuan/meta?page=$page&limit=10'),
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

  // ⭐ 移动端监听
  bool _onScroll(ScrollNotification notification) {
    if (!mounted || isLoading || !hasMore) return false;

    final metrics = notification.metrics;

    if (metrics.pixels >= metrics.maxScrollExtent - 200) {
      debugPrint("Notification 触底");
      _fetchData();
    }

    return false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: xui.XuiTheme.warmCream,
      appBar: AppBar(
        backgroundColor: xui.XuiTheme.pureWhite,
        elevation: 0,
        foregroundColor: xui.XuiTheme.clayBlack,
        title: const Text("数据库列表"),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: xui.XuiTheme.oatBorder),
        ),
      ),

      body: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,

        child: RefreshIndicator(
          onRefresh: () => _fetchData(isRefresh: true),

          child: ListView.builder(
            controller: _controller, // ⭐ 必须加
            physics: const AlwaysScrollableScrollPhysics(),

            itemCount: _list.length + 1,

            itemBuilder: (context, index) {
              if (index < _list.length) {
                final item = _list[index];
                return _CollectionItem(name: item['name']);
              }

              if (isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (!hasMore) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text("没有更多数据")),
                );
              }

              // ⭐ 底部加载更多区域
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(child: _buildLoadMore()),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget? _buildLoadMore() {
    if (isLoading) {
      return const CircularProgressIndicator();
    }

    if (!hasMore) {
      return const Text("没有更多数据了");
    }

    return ElevatedButton(
      onPressed: () {
        _fetchData();
      },
      child: const Text("加载更多"),
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

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: isHover
            ? (Matrix4.identity()..translate(0, -4))
            : Matrix4.identity(),

        child: _buildCard(context),
      ),
    );
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

  Widget _buildCard(BuildContext context) {
    final module = findModuleByCollection(widget.name);

    // ⭐ fallback（避免空）
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

    final subTextColor = colors != null
        ? hexToColor(colors.textSecondary)
        : Colors.grey;

    final accentColor = colors != null
        ? hexToColor(colors.accent)
        : Colors.blue;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExpertsPage(
                  collectionName: widget.name, // ⭐ 仍然用真实 collection
                ),
              ),
            );
          },
          onHover: (hover) {
            setState(() {
              isHover = hover;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gradientStart, gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: xui.XuiTheme.clayShadow,
              border: Border.all(color: xui.XuiTheme.oatBorder, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  // ⭐ Icon 区域
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(icon, style: xui.XuiTheme.bodyLarge().copyWith(fontSize: 24)),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // ⭐ 文本区域
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: xui.XuiTheme.featureTitle().copyWith(color: textColor),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          slogan,
                          style: xui.XuiTheme.bodyStd().copyWith(color: subTextColor),
                        ),
                      ],
                    ),
                  ),

                  // ⭐ 右箭头
                  Icon(Icons.arrow_forward_ios, size: 16, color: subTextColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
