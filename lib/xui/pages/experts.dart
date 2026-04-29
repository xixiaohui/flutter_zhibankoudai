import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/xui/x_design.dart' as xui;
import 'package:flutter_application_zhiban/xui/pages/expert_detail.dart';
import 'package:flutter_application_zhiban/xui/pages/poster_preview.dart';
import 'package:flutter_application_zhiban/xui/pages/poster_widget.dart';
import 'package:flutter_application_zhiban/xui/utils/module.dart';
import 'package:http/http.dart' as http;
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';

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
  final List<dynamic> _list = [];

  int page = 1;
  bool isLoading = false;
  bool hasMore = true;

  static const baseUrl = "https://www.xclaw.living/api/hunyuan";

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchData();

    _controller.addListener(() {
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
        Uri.parse(
          '$baseUrl/experts?collection=${Uri.encodeComponent(widget.collectionName)}&page=$page&limit=2',
        ),
      );

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

    setState(() => isLoading = false);
  }

  Future<void> _refresh() async {
    await _fetchData(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = (width / 140).floor().clamp(2, 4);

    final module = findModuleByCollection(widget.collectionName);
    String agentName = "";

    if(module!=null){
      agentName = module.name;
    }
    return Scaffold(
      backgroundColor: xui.XuiTheme.warmCream,
      appBar: AppBar(
        backgroundColor: xui.XuiTheme.pureWhite,
        elevation: 0,
        foregroundColor: xui.XuiTheme.clayBlack,
        title: Text(agentName),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: xui.XuiTheme.oatBorder),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _list.length + 1,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            if (index < _list.length) {
              return _ExpertCard(item: _list[index]);
            }

            // ⭐ 底部区域
            return _buildLoadMore();
          },
        ),
      ),
    );
  }

  Widget _buildLoadMore() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!hasMore) {
      return const Center(child: Text("没有更多数据"));
    }

    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: xui.XuiTheme.lemon500,
          foregroundColor: xui.XuiTheme.clayBlack,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: _fetchData,
        child: const Text("加载更多"),
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
          MaterialPageRoute(
            builder: (_) => ExpertDetailPage(item: item),
          ),
        );
      },
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ⭐ 顶部：标签 + 箭头
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isAI)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: xui.XuiTheme.pureWhite,
                    border: Border.all(color: xui.XuiTheme.pomegranate400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "AI解读",
                    style: xui.XuiTheme.bodyStd().copyWith(
                      color: xui.XuiTheme.pomegranate400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                const SizedBox(),

              const Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),

          const SizedBox(height: 12),

          // ⭐ 标题（核心）
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: xui.XuiTheme.cardHeading(),
          ),

          const SizedBox(height: 10),

          // ⭐ 内容摘要（优化重点）
          Expanded(
            child: Text(
              content,
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
              style: xui.XuiTheme.body().copyWith(fontFamily: "NotoSerifSC-Regular"),
            ),
          ),

          const SizedBox(height: 12),

              // ⭐ 底部：日期 + 操作
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date,
                    style: xui.XuiTheme.bodyStd().copyWith(
                      fontSize: 11,
                      color: xui.XuiTheme.warmSilver,
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.image, size: 18),
                    tooltip: "生成海报",
                    onPressed: () => showPosterPreview(context, item),
                  )
                ],
              ),
            ],
          ),
        );
  }
}

void showPosterPreview(BuildContext context, Map item) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: PosterPreview(item: item),
    ),
  );
}

final GlobalKey posterKey = GlobalKey();

Widget buildPoster(Map item) {
  return Center(
    child: RepaintBoundary(
      key: posterKey,
      child: SizedBox(
        width: 360,   // ⭐ UI缩小显示（适配屏幕）
        height: 480,  // ⭐ 3:4比例
        child: PosterWidget(item: item),
      ),
    ),
  );
}

Future<void> generatePoster(Map item) async {
  final controller = ScreenshotController();

  final image = await controller.captureFromWidget(
    buildPoster(item),
    delay: const Duration(milliseconds: 100),
  );

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/poster.png');
  await file.writeAsBytes(image);

  print("海报路径: ${file.path}");
}