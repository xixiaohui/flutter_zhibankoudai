import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Clay 风格通用按钮
class ClayButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool loading;
  final bool outlined;
  final VoidCallback? onTap;

  const ClayButton({
    super.key,
    required this.label,
    this.icon,
    this.loading = false,
    this.outlined = false,
    this.onTap,
  });

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton> {
  final bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _hover
            ? (Matrix4.identity()..rotateZ(-0.14)..translateByDouble(0.0, -16.0, 0.0, 1.0))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: widget.outlined ? Colors.transparent : AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(widget.outlined ? 4 : 12),
          border: Border.all(
            color: widget.outlined ? AppTheme.ghostBorder : AppTheme.oatBorder,
            width: widget.outlined ? 1 : 1,
          ),
          boxShadow: _hover
              ? [const BoxShadow(color: AppTheme.clayBlack, blurRadius: 0, offset: Offset(-7, 7))]
              : widget.outlined ? [] : AppTheme.clayShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.loading)
              const SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2))
            else if (widget.icon != null)
              Icon(widget.icon, size: 18, color: AppTheme.clayBlack),
            if (widget.icon != null || widget.loading) const SizedBox(width: 6),
            Text(widget.label, style: const TextStyle(
              color: AppTheme.clayBlack,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            )),
          ],
        ),
      ),
    );
  }
}
