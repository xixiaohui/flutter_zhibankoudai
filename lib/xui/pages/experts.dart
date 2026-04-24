import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/xui/pages/expert_detail.dart';
import 'package:flutter_application_zhiban/xui/pages/poster_preview.dart';
import 'package:flutter_application_zhiban/xui/pages/poster_widget.dart';
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
  late Future<List<dynamic>> _future;

  // ⚠️ 本地开发注意：
  static const baseUrl = "http://localhost:3000"; // Android模拟器
  // iOS用：http://localhost:3000
  // 真机用：你的局域网IP

  @override
  void initState() {
    super.initState();
    _future = fetchExperts();
  }

  Future<List<dynamic>> fetchExperts() async {
    final res = await http.get(Uri.parse('$baseUrl/api/experts?collection=${Uri.encodeComponent(widget.collectionName)}'));

    if (res.statusCode == 200) {
      final jsonData = json.decode(res.body);
      return jsonData['data'];
    } else {
      throw Exception('加载失败');
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _future = fetchExperts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("专家内容"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("错误: ${snapshot.error}"));
          }

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return const Center(child: Text("暂无数据"));
          }

          // ⭐ 自适应列数（核心优化）
          final width = MediaQuery.of(context).size.width;
          final crossAxisCount = (width / 140).floor().clamp(2, 4);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                return _ExpertCard(item: list[index]);
              },
            ),
          );
        },
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
    final content = item['content'] ?? '';
    final date = item['date'] ?? '';
    final isAI = item['isAIGenerated'] ?? false;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExpertDetailPage(item: item),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 顶部：AI标签
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isAI)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "AI",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  const Icon(Icons.arrow_forward_ios, size: 14),
                ],
              ),

              // 中间：标题
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // 内容摘要
              Text(
                content,
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontFamily: "NotoSerifSC-Regular",
                ),
              ),

              // 底部：日期
              Text(
                date,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),

              IconButton(
                icon: const Icon(Icons.image),
                onPressed: () => showPosterPreview(context, item),
              )
            ],
          ),
        ),
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


Future<void> generatePoster(Map item) async {
  final controller = ScreenshotController();

  final image = await controller.captureFromWidget(
    PosterWidget(item: item),
    delay: const Duration(milliseconds: 100),
  );

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/poster.png');
  await file.writeAsBytes(image);

  print("海报路径: ${file.path}");
}