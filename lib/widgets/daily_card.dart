import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/daily_content.dart';
import '../models/module_config.dart';

/// DailyCard — Clay 风格卡片
class DailyCard extends StatefulWidget {
  final ModuleConfig module;
  final DailyContent? content;
  final bool isLoading;
  final bool isGenerating;
  final VoidCallback? onTap;
  final VoidCallback? onRefresh;
  final VoidCallback? onShare;

  const DailyCard({
    super.key,
    required this.module,
    this.content,
    this.isLoading = false,
    this.isGenerating = false,
    this.onTap,
    this.onRefresh,
    this.onShare,
  });

  @override
  State<DailyCard> createState() => _DailyCardState();
}

class _DailyCardState extends State<DailyCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.fromHex(widget.module.color);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        transform: _hover ? (Matrix4.identity()..rotateZ(-0.14)..translateByDouble(0.0, -16.0, 0.0, 1.0)) : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.oatBorder, width: 1),
          boxShadow: _hover
              ? [const BoxShadow(color: Colors.black, blurRadius: 0, offset: Offset(-7, 7))]
              : AppTheme.clayShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(right: -20, top: -20,
                child: Text(widget.module.icon, style: const TextStyle(fontSize: 80, color: Color(0x22FFFFFF))),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(color),
                    const SizedBox(height: 16),
                    _body(context),
                    const SizedBox(height: 16),
                    _footer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(Color c) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(1584)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(widget.module.icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(widget.module.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ]),
        ),
        const Spacer(),
        if (widget.isGenerating)
          const SizedBox(width: 16, height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
          ),
      ],
    );
  }

  Widget _body(BuildContext context) {
    if (widget.isLoading) return _shimmer();

    final c = widget.content;
    if (c == null || c.content.isEmpty) {
      return const Text('暂无内容', style: TextStyle(color: Colors.white70, fontSize: 16));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (c.categoryIcon.isNotEmpty || c.category.isNotEmpty)
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(1584)),
          child: Text('${c.categoryIcon} ${c.category}', style: const TextStyle(color: Colors.white, fontSize: 11)),
        ),
      Text(c.content, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500, height: 1.5),
        maxLines: 5, overflow: TextOverflow.ellipsis),
      if (c.title.isNotEmpty) ...[
        const SizedBox(height: 10),
        Text('— ${c.title}', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14, fontStyle: FontStyle.italic)),
      ],
      if (c.subtitle.isNotEmpty) ...[
        const SizedBox(height: 2),
        Text(c.subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
      ],
      if (c.isAiGenerated) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(1584)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.auto_awesome, size: 12, color: Colors.white),
            SizedBox(width: 3),
            Text('AI 生成', style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
        ),
      ],
    ]);
  }

  Widget _footer() {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      _actionBtn(Icons.refresh, '换一条', widget.onRefresh),
      const SizedBox(width: 12),
      _actionBtn(Icons.share, '分享', widget.onShare),
    ]);
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: () {
        setState(() => _hover = true);
        Future.delayed(const Duration(milliseconds: 200), () { if (mounted) setState(() => _hover = false); });
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(1584)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _shimmer() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: List.generate(4, (i) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: [80.0, double.infinity, 240.0, 160.0][i],
        height: 14,
        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(7)),
      ),
    )));
  }
}