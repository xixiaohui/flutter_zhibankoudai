import 'package:flutter/material.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../design/radius.dart';

class NotificationDialog extends StatefulWidget {
  const NotificationDialog({super.key});

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  int _hour = 9;
  int _minute = 0;
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      title: Text(l10n.notification),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.enableDailyPush),
          value: _enabled,
          onChanged: (v) => setState(() => _enabled = v),
          activeTrackColor: const Color(0xFFc1b0ff).withValues(alpha: 0.3),
          activeThumbColor: const Color(0xFF43089f),
        ),
        const SizedBox(height: 8),
        Text(l10n.selectPushTime,
          style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary)),
        const SizedBox(height: 16),
        _TimeTile(
          label: l10n.morningTime, desc: l10n.morningDesc, selected: _hour == 7,
          onTap: _enabled ? () => setState(() { _hour = 7; _minute = 0; }) : null,
        ),
        _TimeTile(
          label: l10n.forenoonTime, desc: l10n.forenoonDesc, selected: _hour == 9,
          onTap: _enabled ? () => setState(() { _hour = 9; _minute = 0; }) : null,
        ),
        _TimeTile(
          label: l10n.eveningTime, desc: l10n.eveningDesc, selected: _hour == 20,
          onTap: _enabled ? () => setState(() { _hour = 20; _minute = 0; }) : null,
        ),
      ]),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel, style: TextStyle(color: colorScheme.secondary)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(_enabled
                ? l10n.pushSet('${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}')
                : l10n.pushDisabled),
              backgroundColor: const Color(0xFF059669),
            ));
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label, desc;
  final bool selected;
  final VoidCallback? onTap;

  const _TimeTile({
    required this.label, required this.desc, required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
