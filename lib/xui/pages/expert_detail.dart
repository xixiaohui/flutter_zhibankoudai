import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/xui/pages/experts.dart';

class ExpertDetailPage extends StatelessWidget {
  final Map item;

  const ExpertDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final title = item['title'] ?? '';
    final content = item['content'] ?? item['summary']??'';
    final date = item['date'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("详情"),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // ⭐ 控制阅读宽度（核心）
          double maxWidth = 800;
          double width = constraints.maxWidth;

          double contentWidth = width > maxWidth ? maxWidth : width;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Container(
                width: contentWidth,
                padding: const EdgeInsets.all(24),

                // ⭐ 卡片效果
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ⭐ 标题
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                        color: Colors.black87
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ⭐ 日期
                        Text(
                          date,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.image, size: 18),
                          tooltip: "生成海报",
                          onPressed: () => showPosterPreview(context, item),
                        ),
                      ],
                    ),

                    const Divider(height: 32),

                    // ⭐ 正文（核心优化）
                    Text(
                      content,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.8, // ⭐ 行高很关键
                        color: Colors.black87,
                        fontFamily: 'NotoSerifSC-Regular',
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      backgroundColor: const Color(0xFFF5F6FA), // ⭐ 页面背景灰
    );
  }
}