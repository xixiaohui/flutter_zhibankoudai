import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../config/constants.dart';
import '../design/radius.dart';
import '../l10n/gen/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../services/cache_service.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.bottomNavMine),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _UserCard(textTheme: textTheme, colorScheme: colorScheme),
          const SizedBox(height: 24),
          _menuGroup(context, textTheme, colorScheme, [
            _MenuItem(Icons.color_lens, AppLocalizations.of(context)!.themeSettings, switch (themeProvider.mode) {
              ThemeMode.light => AppLocalizations.of(context)!.lightMode,
              ThemeMode.dark => AppLocalizations.of(context)!.darkMode,
              ThemeMode.system => AppLocalizations.of(context)!.followSystem,
            }, _onTheme),
            _MenuItem(Icons.notifications, AppLocalizations.of(context)!.notification, AppLocalizations.of(context)!.notificationDesc, _onNotification),
            _MenuItem(Icons.cleaning_services, AppLocalizations.of(context)!.clearCache, AppLocalizations.of(context)!.clearCacheDesc, _onClearCache),
          ]),
          const SizedBox(height: 16),
          _menuGroup(context, textTheme, colorScheme, [
            _MenuItem(Icons.info, AppLocalizations.of(context)!.aboutUs, AppLocalizations.of(context)!.aboutVersion(AppConstants.appVersion), _onAbout),
            _MenuItem(Icons.star, AppLocalizations.of(context)!.rateUs, AppLocalizations.of(context)!.rateUsDesc, _onRate),
            _MenuItem(Icons.share, AppLocalizations.of(context)!.shareToFriend, AppLocalizations.of(context)!.shareRecommend, _onShare),
          ]),
          const SizedBox(height: 32),
          Text(
            '© ${DateTime.now().year} ${AppConstants.appNameEn}',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _menuGroup(BuildContext context, TextTheme textTheme, ColorScheme colorScheme, List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colorScheme.outline, width: 0.5),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final last = e.key == items.length - 1;
          return Column(children: [
            ListTile(
              leading: Icon(e.value.icon, color: colorScheme.onSurface, size: 22),
              title: Text(e.value.title, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: colorScheme.onSurface)),
              subtitle: Text(e.value.subtitle, style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary)),
              trailing: Icon(Icons.chevron_right, size: 20, color: colorScheme.secondary),
              onTap: () => e.value.onTap(context),
            ),
            if (!last) Divider(height: 1, indent: 16, endIndent: 16, color: colorScheme.outlineVariant),
          ]);
        }).toList(),
      ),
    );
  }

  void _onTheme(BuildContext context) {
    final provider = context.read<ThemeProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ThemeSheet(provider: provider),
    );
  }

  void _onNotification(BuildContext context) {
    showDialog(context: context, builder: (_) => const _NotificationDialog());
  }

  void _onClearCache(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
        title: Text(AppLocalizations.of(ctx)!.clearCache),
        content: Text(AppLocalizations.of(ctx)!.clearCacheConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(ctx)!.cancel, style: TextStyle(color: colorScheme.secondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final cache = await CacheService.instance;
              await cache.clear();
              if (ctx.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.cacheCleared), backgroundColor: const Color(0xFF059669)),
                );
              }
            },
            child: Text(AppLocalizations.of(ctx)!.confirm, style: const TextStyle(color: Color(0xFFDC2626))),
          ),
        ],
      ),
    );
  }

  void _onAbout(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
        title: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF43089f),
              borderRadius: BorderRadius.circular(AppRadius.standard),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          const Text(AppConstants.appName),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppLocalizations.of(dialogContext)!.aboutSlogan, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          _AboutRow(AppLocalizations.of(dialogContext)!.aboutVersionLabel, AppConstants.appVersion, textTheme, colorScheme),
          _AboutRow(AppLocalizations.of(dialogContext)!.aboutBuildLabel, AppLocalizations.of(dialogContext)!.aboutBuildValue, textTheme, colorScheme),
          _AboutRow(AppLocalizations.of(dialogContext)!.aboutDesignLabel, AppLocalizations.of(dialogContext)!.aboutDesignValue, textTheme, colorScheme),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(AppLocalizations.of(dialogContext)!.aboutGotIt)),
        ],
      ),
    );
  }

  void _onRate(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
        title: Text(AppLocalizations.of(ctx)!.rateTitle),
        content: Text(AppLocalizations.of(ctx)!.rateContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(ctx)!.rateLater, style: TextStyle(color: colorScheme.secondary)),
          ),
          TextButton(
            onPressed: () { Navigator.pop(ctx); _onShare(context); },
            child: Text(AppLocalizations.of(ctx)!.shareToFriend),
          ),
        ],
      ),
    );
  }

  void _onShare(BuildContext context) {
    SharePlus.instance.share(ShareParams(
      text: AppLocalizations.of(context)!.shareText,
      subject: AppConstants.appName,
    ));
  }
}

// ═══════ 主题切换底部弹窗 ═══════
class _ThemeSheet extends StatelessWidget {
  final ThemeProvider provider;
  const _ThemeSheet({required this.provider});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.themeSettings, style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface)),
          const SizedBox(height: 16),
          for (final mode in ThemeMode.values)
            _ThemeOption(
              icon: _themeIcon(mode),
              label: _themeLabel(mode, context),
              selected: provider.mode == mode,
              onTap: () { provider.setMode(mode); Navigator.pop(context); },
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
        ]),
      ),
    );
  }

  IconData _themeIcon(ThemeMode mode) => switch (mode) {
    ThemeMode.light => Icons.light_mode,
    ThemeMode.dark => Icons.dark_mode,
    ThemeMode.system => Icons.settings_suggest,
  };

  String _themeLabel(ThemeMode mode, BuildContext context) => switch (mode) {
    ThemeMode.light => AppLocalizations.of(context)!.lightMode,
    ThemeMode.dark => AppLocalizations.of(context)!.darkMode,
    ThemeMode.system => AppLocalizations.of(context)!.followSystem,
  };
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _ThemeOption({
    required this.icon, required this.label, required this.selected,
    required this.onTap, required this.textTheme, required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: selected ? const Color(0xFFc1b0ff).withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Icon(icon, color: selected ? const Color(0xFF43089f) : colorScheme.onSurface, size: 24),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface))),
              if (selected) const Icon(Icons.check, color: Color(0xFF43089f), size: 22),
            ]),
          ),
        ),
      ),
    );
  }
}

// ═══════ 通知时间设置弹窗 ═══════
class _NotificationDialog extends StatefulWidget {
  const _NotificationDialog();

  @override
  State<_NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<_NotificationDialog> {
  int _hour = 9;
  int _minute = 0;
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      title: Text(AppLocalizations.of(context)!.notification),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(AppLocalizations.of(context)!.enableDailyPush),
          value: _enabled,
          onChanged: (v) => setState(() => _enabled = v),
          activeTrackColor: const Color(0xFFc1b0ff).withValues(alpha: 0.3),
          activeThumbColor: const Color(0xFF43089f),
        ),
        const SizedBox(height: 8),
        Text(AppLocalizations.of(context)!.selectPushTime,
          style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary)),
        const SizedBox(height: 16),
        _TimeTile(
          label: AppLocalizations.of(context)!.morningTime, desc: AppLocalizations.of(context)!.morningDesc, selected: _hour == 7,
          onTap: _enabled ? () => setState(() { _hour = 7; _minute = 0; }) : null,
          textTheme: textTheme, colorScheme: colorScheme,
        ),
        _TimeTile(
          label: AppLocalizations.of(context)!.forenoonTime, desc: AppLocalizations.of(context)!.forenoonDesc, selected: _hour == 9,
          onTap: _enabled ? () => setState(() { _hour = 9; _minute = 0; }) : null,
          textTheme: textTheme, colorScheme: colorScheme,
        ),
        _TimeTile(
          label: AppLocalizations.of(context)!.eveningTime, desc: AppLocalizations.of(context)!.eveningDesc, selected: _hour == 20,
          onTap: _enabled ? () => setState(() { _hour = 20; _minute = 0; }) : null,
          textTheme: textTheme, colorScheme: colorScheme,
        ),
      ]),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: colorScheme.secondary)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(_enabled
                ? AppLocalizations.of(context)!.pushSet('${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}')
                : AppLocalizations.of(context)!.pushDisabled),
              backgroundColor: const Color(0xFF059669),
            ));
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label, desc;
  final bool selected;
  final VoidCallback? onTap;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _TimeTile({
    required this.label, required this.desc, required this.selected,
    required this.onTap, required this.textTheme, required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: selected ? const Color(0xFFc1b0ff).withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(label, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: colorScheme.onSurface)),
                  Text(desc, style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary)),
                ]),
              ),
              if (selected) const Icon(Icons.check, color: Color(0xFF43089f), size: 22),
            ]),
          ),
        ),
      ),
    );
  }
}

// ═══════ 用户头像卡片 ═══════
class _UserCard extends StatelessWidget {
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _UserCard({required this.textTheme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF43089f),
        borderRadius: BorderRadius.circular(AppRadius.feature),
      ),
      child: Row(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: const Icon(Icons.person, size: 32, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(AppLocalizations.of(context)!.userCardName, style: textTheme.titleLarge?.copyWith(color: Colors.white)),
            const SizedBox(height: 4),
            Text(AppLocalizations.of(context)!.aboutSlogan, style: textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.7))),
          ]),
        ),
        Icon(Icons.edit, color: Colors.white.withValues(alpha: 0.5), size: 20),
      ]),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label, value;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _AboutRow(this.label, this.value, this.textTheme, this.colorScheme);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(width: 60, child: Text(label, style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary))),
        Expanded(child: Text(value, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface))),
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
