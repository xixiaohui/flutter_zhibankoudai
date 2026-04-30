import 'package:flutter/material.dart';
import '../config/theme.dart';

class ContentCard extends StatelessWidget {
  final String title;
  final String content;
  final Color color;
  final bool isAi;

  const ContentCard({
    super.key,
    required this.title,
    required this.content,
    required this.color,
    this.isAi = false,
  });

  @override
  Widget build(BuildContext context) {
    final paragraphs = content.split('\n\n');

    debugPrint("ContentCard: title='$title', content='${content.substring(0, content.length > 50 ? 50 : content.length)}...', isAi=$isAi");

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.clayShadow,
        border: Border.all(color: AppTheme.oatBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 内容块
          ...paragraphs.map((p) => _buildBlock(p)),

          const SizedBox(height: 12),

          // AI标签
          if (isAi)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.matcha300.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 14, color: AppTheme.matcha600),
                  SizedBox(width: 4),
                  Text(
                    'AI生成',
                    style: TextStyle(
                      color: AppTheme.matcha600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBlock(String text) {
    final isDialogue = text.contains('：') || text.contains(':');

    if (isDialogue) {
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7FB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text.trim(),
          style: const TextStyle(
            fontSize: 16,
            height: 1.7,
            color: AppTheme.clayBlack,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        text.trim(),
        style: const TextStyle(
          fontSize: 18,
          height: 1.8,
          color: AppTheme.clayBlack,
        ),
      ),
    );
  }
}