import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../config/constants.dart';
import '../config/theme.dart';
import '../providers/theme_provider.dart';
import '../services/cache_service.dart';
import '../xui/x_design.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
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
          _UserCard(),
          const SizedBox(height: 24),
          _clayMenuGroup(context, [
            _MenuItem(Icons.color_lens, '主题设置', themeProvider.modeLabel, _onTheme),
            _MenuItem(Icons.notifications, '通知提醒', '设置每日推送时间', _onNotification),
            _MenuItem(Icons.cleaning_services, '清除缓存', '清理本地缓存数据', _onClearCache),
          ]),
          const SizedBox(height: 16),
          _clayMenuGroup(context, [
            _MenuItem(Icons.info, '关于我们', '版本 ${AppConstants.appVersion}', _onAbout),
            _MenuItem(Icons.star, '给个好评', '您的支持是我们前进的动力', _onRate),
            _MenuItem(Icons.share, '分享给朋友', '推荐给更多人', _onShare),
          ]),
          const SizedBox(height: 32),
          Text(
            '© ${DateTime.now().year} ${AppConstants.appNameEn}',
            style: XuiTheme.small().copyWith(color: AppTheme.warmSilver),
          ),
          const SizedBox(height: 24),
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
          final last = e.key == items.length - 1;
          return Column(children: [
            ListTile(
              leading: Icon(e.value.icon, color: AppTheme.clayBlack, size: 22),
              title: Text(e.value.title, style: XuiTheme.bodyMed()),
              subtitle: Text(e.value.subtitle, style: XuiTheme.caption()),
              trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.warmSilver),
              onTap: () => e.value.onTap(context),
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

  // ═══════ 主题设置 ═══════
  void _onTheme(BuildContext context) {
    final provider = context.read<ThemeProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ThemeSheet(provider: provider),
    );
  }

  // ═══════ 通知设置 ═══════
  void _onNotification(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _NotificationDialog(),
    );
  }

  // ═══════ 清除缓存 ═══════
  void _onClearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有本地缓存数据吗？\n这将清除已保存的内容和设置。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消', style: TextStyle(color: AppTheme.warmSilver)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final cache = await CacheService.instance;
              await cache.clear();
              if (ctx.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('缓存已清除'), backgroundColor: AppTheme.matcha600),
                );
              }
            },
            child: const Text('确定', style: TextStyle(color: AppTheme.pomegranate400)),
          ),
        ],
      ),
    );
  }

  // ═══════ 关于我们 ═══════
  void _onAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppTheme.ube800,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            ),
            child: const Icon(Icons.auto_awesome, color: AppTheme.pureWhite, size: 28),
          ),
          const SizedBox(width: 12),
          const Text(AppConstants.appName),
        ]),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('每日知识，伴你成长', style: TextStyle(color: AppTheme.warmCharcoal)),
            SizedBox(height: 16),
            _AboutRow('版本', AppConstants.appVersion),
            _AboutRow('构建', 'Flutter · Tencent CloudBase'),
            _AboutRow('设计', 'Clay Design System'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  // ═══════ 评分 ═══════
  void _onRate(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('给个好评 🌟'),
        content: const Text('感谢您的支持！您的每一次好评都是我们前进的动力。\n\n请前往应用商店为我们评分，或分享给更多朋友。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('稍后再说', style: TextStyle(color: AppTheme.warmSilver)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _onShare(context);
            },
            child: const Text('分享给朋友'),
          ),
        ],
      ),
    );
  }

  // ═══════ 分享 ═══════
  void _onShare(BuildContext context) {
    SharePlus.instance.share(
      ShareParams(
        text: '智伴口袋 — 每日知识，伴你成长！\n'
            '60+专家模块，每天为你推送优质内容。\n'
            '快来下载体验吧！',
        subject: AppConstants.appName,
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// 主题切换底部弹窗
// ═══════════════════════════════════════════════
class _ThemeSheet extends StatelessWidget {
  final ThemeProvider provider;
  const _ThemeSheet({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppTheme.oatLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('主题设置', style: XuiTheme.featureTitle()),
            const SizedBox(height: 16),
            for (final mode in ThemeMode.values)
              _ThemeOption(
                icon: _themeIcon(mode),
                label: _themeLabel(mode),
                selected: provider.mode == mode,
                onTap: () {
                  provider.setMode(mode);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  IconData _themeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.settings_suggest;
    }
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
      case ThemeMode.system:
        return '跟随系统';
    }
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: selected ? AppTheme.ube300.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Icon(icon, color: selected ? AppTheme.ube800 : AppTheme.clayBlack, size: 24),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: XuiTheme.bodyMed())),
              if (selected)
                const Icon(Icons.check, color: AppTheme.ube800, size: 22),
            ]),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// 通知时间设置弹窗
// ═══════════════════════════════════════════════
class _NotificationDialog extends StatefulWidget {
  const _NotificationDialog();

  @override
  State<_NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<_NotificationDialog> {
  int _hour = 9;
  int _minute = 0;
  bool _enabled = true;

  static const _times = [
    ('☀️ 早晨', 7, 0, '开启活力一天'),
    ('🌤 上午', 9, 0, '黄金学习时间'),
    ('🌙 晚间', 20, 0, '睡前轻松阅读'),
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.pureWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('通知提醒'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('开启每日推送'),
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
            activeTrackColor: AppTheme.ube300,
            activeThumbColor: AppTheme.ube800,
          ),
          const SizedBox(height: 8),
          const Text(
            '选择每日推送时间（当前为示例设置，具体推送由后端支持）',
            style: TextStyle(fontSize: 13, color: AppTheme.warmSilver),
          ),
          const SizedBox(height: 16),
          for (final t in _times)
            _TimeTile(
              label: t.$1,
              desc: t.$4,
              selected: _hour == t.$2,
              onTap: _enabled
                  ? () => setState(() {
                        _hour = t.$2;
                        _minute = t.$3;
                      })
                  : null,
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消', style: TextStyle(color: AppTheme.warmSilver)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_enabled ? '已设置每日 ${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')} 推送' : '已关闭每日推送'),
                backgroundColor: AppTheme.matcha600,
              ),
            );
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label;
  final String desc;
  final bool selected;
  final VoidCallback? onTap;

  const _TimeTile({
    required this.label,
    required this.desc,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: selected ? AppTheme.ube300.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: XuiTheme.bodyMed()),
                    Text(desc, style: XuiTheme.caption()),
                  ],
                ),
              ),
              if (selected) const Icon(Icons.check, color: AppTheme.ube800, size: 22),
            ]),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// 用户头像卡片
// ═══════════════════════════════════════════════
class _UserCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('智伴口袋用户', style: XuiTheme.featureTitle().copyWith(color: AppTheme.pureWhite)),
              const SizedBox(height: 4),
              Text('每日知识，伴你成长', style: XuiTheme.caption().copyWith(color: AppTheme.pureWhite.withValues(alpha: 0.7))),
            ],
          ),
        ),
        Icon(Icons.edit, color: AppTheme.pureWhite.withValues(alpha: 0.5), size: 20),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;
  const _AboutRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(
          width: 60,
          child: Text(label, style: const TextStyle(color: AppTheme.warmSilver, fontSize: 14)),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ]),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final void Function(BuildContext) onTap;
  _MenuItem(this.icon, this.title, this.subtitle, this.onTap);
}
