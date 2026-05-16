import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/design/colors.dart';
import 'package:flutter_application_zhiban/design/elevation.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';

class PosterWidget extends StatelessWidget {
  final Map item;

  const PosterWidget({super.key, required this.item});

  double getMaxFontSize(String text) {
    final len = text.length;

    if (len < 50) {
      return 48;
    } else if (len < 150) {
      return 38;
    } else if (len < 300) {
      return 34;
    } else {
      return 27;
    }
  }

  double getMinFontSize(String text) {
    final len = text.length;

    if (len <= 50) return 28;
    if (len <= 100) return 25;
    if (len <= 150) return 24;
    if (len <= 200) return 23;
    if (len <= 250) return 21;
    if (len <= 300) return 18;
    if (len <= 350) return 17;
    if (len <= 400) return 16;
    if (len <= 1200) return 10;

    return 10;
  }

  @override
  Widget build(BuildContext context) {
    final title = item['title'] ?? '';
    final content = item['content'] ?? item['summary'] ?? '';
    final isAI = item['isAIGenerated'] ?? false;
    final date = DateFormat('yyyy.MM.dd').format(DateTime.now());

    final maxSize = getMaxFontSize(content);
    final minSize = getMinFontSize(content);

    // 根据内容长度动态设置行数上限，确保长文本不被截断
    final contentLines = content.length > 1200 ? 800 : 200;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.oatLight, width: 1),
        boxShadow: AppElevation.card,
        gradient: const LinearGradient(
          colors: [AppColors.warmCream, AppColors.lightFrost],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // 背景光斑
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.slushie500.withValues(alpha: 0.08),
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
                color: AppColors.ube800.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // 水印
          Positioned(
            top: 150,
            left: 40,
            child: Text(
              "ZHIBANKOUDAI",
              style: TextStyle(
                fontSize: 67,
                fontWeight: FontWeight.bold,
                color: AppColors.slushie500.withValues(alpha: 0.04),
              ),
            ),
          ),

          // 主体 — 使用 IntrinsicHeight 让 Column 内容撑开高度
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 顶部标签
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isAI)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.blueberry800, AppColors.ube800],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "AI 解读",
                          style: TextStyle(
                            color: AppColors.pureWhite,
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    const Icon(Icons.auto_awesome, size: 18, color: AppColors.warmCharcoal),
                  ],
                ),

                const SizedBox(height: 30),

                // 标题
                AutoSizeText(
                  title,
                  maxLines: 3,
                  minFontSize: 40,
                  maxFontSize: 64,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    letterSpacing: 0.5,
                    color: AppColors.clayBlack,
                  ),
                ),

                const SizedBox(height: 30),

                // 内容块 — 移除 Expanded，让内容自由撑开高度
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.slushie500.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: AutoSizeText(
                    content,
                    textAlign: TextAlign.left,
                    maxLines: contentLines,
                    minFontSize: minSize,
                    maxFontSize: maxSize,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      height: 1.8,
                      color: AppColors.darkCharcoal,
                      fontFamily: 'NotoSerifSC',
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 底部
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.warmCharcoal,
                        letterSpacing: 1,
                      ),
                    ),
                    const Text(
                      "#智伴口袋",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        fontSize: 16,
                        color: AppColors.blueberry800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 边角线
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              width: 40, height: 2,
              color: AppColors.warmCharcoal.withValues(alpha: 0.3),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              width: 2, height: 40,
              color: AppColors.warmCharcoal.withValues(alpha: 0.3),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              width: 40, height: 2,
              color: AppColors.warmCharcoal.withValues(alpha: 0.3),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              width: 2, height: 40,
              color: AppColors.warmCharcoal.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
