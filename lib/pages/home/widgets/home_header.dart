import 'package:flutter/material.dart';
import '../../../design/radius.dart';

class HomeHeader extends StatelessWidget {
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const HomeHeader({super.key, required this.textTheme, required this.colorScheme});

  String _dateStr() {
    final now = DateTime.now();
    const wd = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return '${now.year}年${now.month}月${now.day}日 ${wd[now.weekday - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_dateStr(), style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Row(children: [
          Text('智伴口袋', style: textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFf8cc65).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text('每日更新', style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurface)),
          ),
        ]),
        const SizedBox(height: 6),
        Text('您的个人专家知识库', style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary)),
      ]),
    );
  }
}
