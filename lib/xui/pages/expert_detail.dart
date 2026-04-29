import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/xui/x_design.dart' as xui;
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
      backgroundColor: xui.XuiTheme.warmCream,
      appBar: AppBar(
        backgroundColor: xui.XuiTheme.pureWhite,
        elevation: 0,
        foregroundColor: xui.XuiTheme.clayBlack,
        title: const Text("详情"),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: xui.XuiTheme.oatBorder),
        ),
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
                decoration: xui.XuiTheme.cardDecoration(radius: 40, color: xui.XuiTheme.pureWhite),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ⭐ 标题
                    Text(
                      title,
                      style: xui.XuiTheme.sectionHeading(),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ⭐ 日期
                        Text(
                          date,
                          style: xui.XuiTheme.bodyStd().copyWith(
                            fontSize: 14,
                            color: xui.XuiTheme.warmSilver,
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
                      style: xui.XuiTheme.body().copyWith(
                        height: 1.8,
                        fontFamily: 'NotoSerifSC-Regular',
                        color: xui.XuiTheme.darkCharcoal,
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
    
    );
  }
}