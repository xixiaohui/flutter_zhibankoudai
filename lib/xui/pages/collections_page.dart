import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/xui/pages/experts.dart';
import 'package:http/http.dart' as http;

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({super.key});

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = fetchCollections();
  }

  Future<List<dynamic>> fetchCollections() async {
    final res = await http.get(
      Uri.parse('http://localhost:3000/api/meta'),
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
      appBar: AppBar(title: const Text("数据库列表")),
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

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              final name = item['name'] ?? '';

              return _CollectionItem(name: name);
            },
          );
        },
      ),
    );
  }
}


class _CollectionItem extends StatelessWidget {
  final String name;

  const _CollectionItem({required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text("点击查看数据"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),

        // ⭐ 点击跳转（后面扩展）
        onTap: () {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text("点击了: $name")),
          // );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExpertsPage(
                collectionName: name, // ⭐ 传参数
              ),
            ),
          );
        },
      ),
    );
  }
}