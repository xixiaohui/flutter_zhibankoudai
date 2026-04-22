import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/daily_content.dart';
import '../models/module_config.dart';

/// 每日内容卡片组件
/// 对应微信小程序的 components/dailyCard
class DailyCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final moduleColor = AppTheme.fromHex(module.color);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              moduleColor.withValues(alpha: 0.85),
              moduleColor.withValues(alpha: 0.65),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: moduleColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // 背景装饰
              Positioned(
                right: -20,
                top: -20,
                child: Text(
                  module.icon,
                  style: TextStyle(fontSize: 80, color: Colors.white.withValues(alpha: 0.15)),
                ),
              ),

              // 内容区域
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 头部：模块图标+名称
                    _buildHeader(moduleColor),
                    const SizedBox(height: 16),

                    // 内容主体
                    _buildContent(context),

                    const SizedBox(height: 16),

                    // 底部操作栏
                    _buildFooter(moduleColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader(Color moduleColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(module.icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                module.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (isGenerating)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
      ],
    );
  }

  /// 构建内容区域
  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return _buildShimmer();
    }

    if (content == null || content!.content.isEmpty) {
      return const Text(
        '暂无内容',
        style: TextStyle(color: Colors.white70, fontSize: 16),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 分类标签
        if (content!.categoryIcon.isNotEmpty || content!.category.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${content!.categoryIcon} ${content!.category}',
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),

        // 主要内容
        Text(
          content!.content,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),

        // 标题/副标题
        if (content!.title.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            '— ${content!.title}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        if (content!.subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            content!.subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],

        // AI生成标识
        if (content!.isAiGenerated) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 12, color: Colors.white),
                SizedBox(width: 3),
                Text(
                  'AI 生成',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// 构建底部操作栏
  Widget _buildFooter(Color moduleColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // AI刷新按钮
        _buildActionButton(
          icon: Icons.refresh,
          label: '换一条',
          onTap: onRefresh,
        ),
        const SizedBox(width: 12),
        // 分享按钮
        _buildActionButton(
          icon: Icons.share,
          label: '分享',
          onTap: onShare,
        ),
      ],
    );
  }

  /// 操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// 加载骨架屏
  Widget _buildShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 240,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 160,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(7),
          ),
        ),
      ],
    );
  }
}