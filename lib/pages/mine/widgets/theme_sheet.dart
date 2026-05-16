import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../providers/theme_provider.dart';

class ThemeSheet extends StatelessWidget {
  const ThemeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();
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

  const _ThemeOption({
    required this.icon, required this.label, required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
