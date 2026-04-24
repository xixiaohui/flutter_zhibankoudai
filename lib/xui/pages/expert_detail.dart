
import 'package:flutter/material.dart';

class ExpertDetailPage extends StatelessWidget {
  final Map item;

  const ExpertDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item['title'] ?? '详情'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          item['content'] ?? '',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}