import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../xui/x_design.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      appBar: AppBar(
        title: const Text('我的'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // 用户信息卡（Clay 样式）
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.ube800,
              borderRadius: BorderRadius.circular(AppTheme.radiusFeature),
              border: Border.all(color: AppTheme.oatBorder),
              boxShadow: AppTheme.clayShadow,
            ),
            child: Row(children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                ),
                child: const Icon(Icons.person, size: 32, color: AppTheme.pureWhite),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('智伴口袋用户', style: XuiTheme.featureTitle().copyWith(color: AppTheme.pureWhite)),
                const SizedBox(height: 4),
                Text('每日知识，伴你成长', style: XuiTheme.caption().copyWith(color: AppTheme.pureWhite.withValues(alpha: 0.7))),
              ])),
            ]),
          ),

          const SizedBox(height: 24),

          // 菜单卡片组
          _clayMenuGroup(context, [
            _MenuItem(Icons.color_lens, '主题设置', '切换深色/浅色模式'),
            _MenuItem(Icons.notifications, '通知提醒', '设置每日推送时间'),
            _MenuItem(Icons.cleaning_services, '清除缓存', '清理本地缓存数据'),
          ]),

          const SizedBox(height: 16),

          _clayMenuGroup(context, [
            _MenuItem(Icons.info, '关于我们', '版本 1.0.0'),
            _MenuItem(Icons.star, '给个好评', '您的支持是我们前进的动力'),
            _MenuItem(Icons.share, '分享给朋友', '推荐给更多人'),
          ]),
        ]),
      ),
    );
  }

  Widget _clayMenuGroup(BuildContext context, List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.oatBorder),
        boxShadow: AppTheme.clayShadow,
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          final last = i == items.length - 1;
          return Column(children: [
            ListTile(
              leading: Icon(item.icon, color: AppTheme.clayBlack, size: 22),
              title: Text(item.title, style: XuiTheme.bodyMed()),
              subtitle: Text(item.subtitle, style: XuiTheme.caption()),
              trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.warmSilver),
              onTap: () => _handleTap(context, item),
            ),
            if (!last) const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, color: AppTheme.oatLight),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  void _handleTap(BuildContext context, _MenuItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.title} - 开发中'), backgroundColor: AppTheme.clayBlack),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  _MenuItem(this.icon, this.title, this.subtitle);
}