import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ExpertsPage extends StatefulWidget {
  const ExpertsPage({super.key});

  @override
  State<ExpertsPage> createState() => _ExpertsPageState();
}

class _ExpertsPageState extends State<ExpertsPage> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = fetchExperts();
  }

  Future<List<dynamic>> fetchExperts() async {
    final res = await http.get(
      Uri.parse('http://localhost:3000/api/experts'),
    );

    if (res.statusCode == 200) {
      final jsonData = json.decode(res.body);
      return jsonData['data'];
    } else {
      throw Exception('加载失败');
    }
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
          // 加载中
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 错误
          if (snapshot.hasError) {
            return Center(child: Text("错误: ${snapshot.error}"));
          }

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return const Center(child: Text("暂无数据"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];

              return _ExpertCard(item: item);
            },
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题 + AI标签
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isAI)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "AI",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // 内容摘要（限制行数）
            Text(
              content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[700]),
            ),

            const SizedBox(height: 10),

            // 日期
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}