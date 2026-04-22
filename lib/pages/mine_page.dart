import 'package:flutter/material.dart';
import '../config/theme.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 用户信息卡片
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(

                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Icon(Icons.person, size: 32, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '智伴口袋用户',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '每日知识，伴你成长',
                          style: TextStyle(

                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 功能列表
            _buildMenuSection(context, [
              _MenuItem(Icons.color_lens, '主题设置', '切换深色/浅色模式'),
              _menuItem(Icons.notifications, '通知提醒', '设置每日推送时间'),
              _menuItem(Icons.cleaning_services, '清除缓存', '清理本地缓存数据'),
            ]),

            const SizedBox(height: 16),

            _buildMenuSection(context, [
              _MenuItem(Icons.info, '关于我们', '版本 1.0.0'),
              _menuItem(Icons.star, '给个好评', '您的支持是我们前进的动力'),
              _menuItem(Icons.share, '分享给朋友', '推荐给更多人'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(

            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, color: AppTheme.primaryColor),
                title: Text(item.title),
                subtitle: Text(item.subtitle, style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => _handleMenuTap(context, item),
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  child: Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  _MenuItem _menuItem(IconData icon, String title, String subtitle) {
    return _MenuItem(icon, title, subtitle);
  }

  void _handleMenuTap(BuildContext context, _MenuItem item) {
    // TODO: 实现菜单点击
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.title} - 开发中')),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;

  _MenuItem(this.icon, this.title, this.subtitle);
}