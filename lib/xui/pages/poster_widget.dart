import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';

class PosterWidget extends StatelessWidget {
  final Map item;

  const PosterWidget({super.key, required this.item});

  
  double getMaxFontSize(String text) {
    final len = text.length;

    if (len < 50) {
      return 48; // ⭐ 很短 → 大字海报感
    } else if (len < 150) {
      return 38;
    } else if (len < 300) {
      return 34;
    } else {
      return 27; // ⭐ 长文本 → 自动压缩
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = item['title'] ?? '';
    final content = item['content'] ?? '';
    final isAI = item['isAIGenerated'] ?? false;


    // ⭐ 使用当前时间（核心优化）
    final date = DateFormat('yyyy.MM.dd').format(DateTime.now());

    final maxSize = getMaxFontSize(content);

    return AspectRatio(
      aspectRatio: 3 / 4, // ⭐ 核心

      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),

          // ⭐ 更有品牌感的渐变
          gradient: const LinearGradient(
            colors: [Color(0xFFF8FAFF), Color(0xFFEFF3FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Stack(
          children: [
            /// ⭐ 背景光斑（蓝 + 紫）
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              bottom: -60,
              left: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            /// ⭐ 水印（品牌感更强）
            Positioned(
              top: 150,
              left: 40,
              child: Text(
                "ZHIBANKOUDAI",
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.withOpacity(0.04),
                ),
              ),
            ),

            /// ⭐ 主体
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ⭐ 顶部
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (isAI)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "AI 解读",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),

                      const Icon(
                        Icons.auto_awesome,
                        size: 18,
                        color: Colors.blueGrey,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  /// ⭐ 标题
                  AutoSizeText(
                    title,
                    maxLines: 3,
                    minFontSize: 40, // ⭐ 放大
                    maxFontSize: 64,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      letterSpacing: 0.5,
                      color: Color(0xFF1E293B),
                    ),
                  ),

                  const SizedBox(height: 48),

                  /// ⭐ 内容块
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(32), // ⭐ 更宽松
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: AutoSizeText(
                          content,
                          textAlign: TextAlign.left,
                          maxLines: 100,
                          minFontSize: 14, // ⭐ 放大
                          maxFontSize: maxSize,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            height: 1.8,
                            color: Color(0xFF334155),
                            fontFamily: 'NotoSerifSC-Regular',
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  /// ⭐ 底部
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 16, // ⭐ 放大
                          color: Color(0xFF64748B),
                          letterSpacing: 1,
                        ),
                      ),
                      const Text(
                        "#智伴口袋",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontSize: 16, // ⭐ 放大
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// ⭐ 边角线（柔和一点）
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                width: 40,
                height: 2,
                color: Colors.blueGrey.withOpacity(0.3),
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                width: 2,
                height: 40,
                color: Colors.blueGrey.withOpacity(0.3),
              ),
            ),

            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                width: 40,
                height: 2,
                color: Colors.blueGrey.withOpacity(0.3),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                width: 2,
                height: 40,
                color: Colors.blueGrey.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
