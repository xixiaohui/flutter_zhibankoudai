import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class PosterWidget extends StatelessWidget {
  final Map item;

  const PosterWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final title = item['title'] ?? '';
    final content = item['content'] ?? '';
    final date = item['date'] ?? '';
    final isAI = item['isAIGenerated'] ?? false;

    return Container(
      width: 800,
      height: 900,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          // colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
          colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ⭐ 顶部
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isAI)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "AI解读",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              const Icon(Icons.auto_awesome, color: Colors.blue),
            ],
          ),

          const SizedBox(height: 24),

          /// ⭐ 标题（自动缩放）
          AutoSizeText(
            title,
            maxLines: 3,
            minFontSize: 24,
            maxFontSize: 34,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 24),

          /// ⭐ 中间内容（核心优化）
          Expanded(
            child: Center(
              child: AutoSizeText(
                content,
                textAlign: TextAlign.left,
                
                maxLines: 70,
                minFontSize: 21,
                maxFontSize: 34,
                overflow: TextOverflow.ellipsis,
                
                style: const TextStyle(
                  height: 1.6,
                  color: Colors.black87,
                  fontFamily: 'NotoSerifSC-Regular',
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          /// ⭐ 底部
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Text(
                "#智伴口袋",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// ⭐ 二维码区域
          // Container(
          //   height: 80,
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   child: const Center(child: Text("二维码")),
          // ),
        ],
      ),
    );
  }
}