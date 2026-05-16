import 'package:flutter/material.dart';
import '../design/colors.dart';
import '../design/elevation.dart';

/// Clay 风格可交互容器
/// 圆角24px/12px，燕麦边框，悬停上移+阴影变化
class ClayContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isButton;
  final double borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final bool dashed;
  final BoxBorder? customBorder;

  const ClayContainer({
    super.key,
    required this.child,
    this.onTap,
    this.isButton = false,
    this.borderRadius = 24,
    this.color,
    this.padding,
    this.dashed = false,
    this.customBorder,
  });

  @override
  State<ClayContainer> createState() => _ClayContainerState();
}

class _ClayContainerState extends State<ClayContainer> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final matrix = Matrix4.identity();
    if (_hover && widget.onTap != null) {
      final dy = widget.isButton ? -8.0 : -4.0;
      if (widget.isButton) {
        matrix
          ..translateByDouble(0.0, dy, 0.0, 1.0)
          ..rotateZ(-0.14);
      } else {
        matrix.translateByDouble(0.0, dy, 0.0, 1.0);
      }
    }
    if (_pressed && widget.onTap != null) {
      matrix.scaleByDouble(0.985, 0.985, 1.0, 1.0);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown:
            widget.onTap == null ? null : (_) => setState(() => _pressed = true),
        onTapCancel:
            widget.onTap == null ? null : () => setState(() => _pressed = false),
        onTapUp:
            widget.onTap == null ? null : (_) => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: matrix,
          transformAlignment: Alignment.center,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.color ?? AppColors.pureWhite,
            borderRadius:
                BorderRadius.circular(widget.isButton ? 24 : widget.borderRadius),
            border: widget.customBorder ??
                Border.all(
                  color: widget.dashed ? AppColors.oatLight : AppColors.oatBorder,
                  width: 1,
                ),
            boxShadow: (_hover && widget.onTap != null)
                ? const [
                    BoxShadow(
                      color: AppColors.clayBlack,
                      blurRadius: 0,
                      offset: Offset(-7, 7),
                    )
                  ]
                : AppElevation.card,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Section 标题组件
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              letterSpacing: 1.08,
            ),
      ),
    );
  }
}
