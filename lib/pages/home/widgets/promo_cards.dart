import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../design/radius.dart';
import '../../../design/elevation.dart';

class AiFriendCard extends StatelessWidget {
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const AiFriendCard({super.key, required this.textTheme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GestureDetector(
        onTap: () => context.push('/ai-friend'),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF5F5), Color(0xFFFFF0E8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.feature),
            border: Border.all(color: const Color(0x33FF9A9E)),
            boxShadow: AppElevation.card,
          ),
          child: Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x33FF9A9E), blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: const Center(child: Text('🧸', style: TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('情感陪伴', style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text('和"小智"聊聊天，分享你的心情',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              ]),
            ),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_forward_rounded, size: 18, color: colorScheme.onSurfaceVariant),
            ),
          ]),
        ),
      ),
    );
  }
}

class AiCareerCard extends StatelessWidget {
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const AiCareerCard({super.key, required this.textTheme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GestureDetector(
        onTap: () => context.push('/career'),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF0F4FF), Color(0xFFEDE9FE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.feature),
            border: Border.all(color: const Color(0x336366F1)),
            boxShadow: AppElevation.card,
          ),
          child: Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x336366F1), blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: const Center(child: Text('💼', style: TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('领域专家', style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text('与180+行业专家深度对话，获取专业见解',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              ]),
            ),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_forward_rounded, size: 18, color: colorScheme.onSurfaceVariant),
            ),
          ]),
        ),
      ),
    );
  }
}
