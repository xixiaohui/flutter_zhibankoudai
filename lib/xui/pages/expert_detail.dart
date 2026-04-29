import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/xui/pages/experts.dart';
import 'package:flutter_application_zhiban/xui/x_design.dart' as xui;

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
      backgroundColor: xui.XuiTheme.warmCream,
      appBar: AppBar(
        backgroundColor: xui.XuiTheme.pureWhite,
        elevation: 0,
        foregroundColor: xui.XuiTheme.clayBlack,
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
          child: Divider(height: 1, thickness: 1, color: xui.XuiTheme.oatBorder),
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
              decoration: xui.XuiTheme.cardDecoration(
                radius: compact ? 24 : 32,
                color: xui.XuiTheme.pureWhite,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: xui.XuiTheme.sectionHeading().copyWith(
                          fontSize: compact ? 28 : 36,
                          height: 1.2,
                          letterSpacing: 0,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    date,
                    style: xui.XuiTheme.bodyStd().copyWith(
                          fontSize: 13,
                          color: xui.XuiTheme.warmSilver,
                        ),
                  ),
                  const Divider(height: 30),
                  Text(
                    content,
                    textAlign: TextAlign.left,
                    style: xui.XuiTheme.body().copyWith(
                          fontSize: compact ? 17 : 18,
                          height: 1.75,
                          letterSpacing: 0,
                          fontFamily: 'NotoSerifSC-Regular',
                          color: xui.XuiTheme.darkCharcoal,
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
