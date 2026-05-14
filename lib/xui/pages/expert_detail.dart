import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/design/colors.dart';
import 'package:flutter_application_zhiban/design/typography.dart';
import 'package:flutter_application_zhiban/design/elevation.dart';
import 'package:flutter_application_zhiban/xui/pages/experts.dart';

class ExpertDetailPage extends StatelessWidget {
  final Map item;

  const ExpertDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final title = item['title'] ?? '';
    final content = item['content'] ?? item['summary'] ?? '';
    final date = item['date'] ?? '';
    final compact = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        foregroundColor: AppColors.clayBlack,
        title: const Text("详情"),
        actions: [
          IconButton(
            icon: const Icon(Icons.image_outlined),
            tooltip: "生成海报",
            onPressed: () => showPosterPreview(context, item),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppColors.oatBorder),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              compact ? 14 : 24,
              compact ? 14 : 24,
              compact ? 14 : 24,
              28 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Container(
              padding: EdgeInsets.all(compact ? 18 : 26),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(compact ? 24 : 32),
                border: Border.all(color: AppColors.oatBorder, width: 1),
                boxShadow: AppElevation.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                          fontSize: compact ? 28 : 36,
                          height: 1.2,
                          letterSpacing: 0,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    date,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          color: AppColors.warmSilver,
                        ),
                  ),
                  const Divider(height: 30),
                  Text(
                    content,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: compact ? 17 : 18,
                          height: 1.75,
                          letterSpacing: 0,
                          fontFamily: 'NotoSerifSC',
                          color: AppColors.darkCharcoal,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
