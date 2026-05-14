import 'package:flutter/material.dart';
import '../design/radius.dart';
import '../design/elevation.dart';
import '../design/spacing.dart';
import '../design/animation.dart';

/// 语义化卡片容器 — 替代 ClayCard / ClayContainer
/// Token 驱动，Light/Dark 自适应，移动端友好的按压反馈
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const SurfaceCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.borderRadius = AppRadius.card,
    this.backgroundColor,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final decoration = BoxDecoration(
      color: backgroundColor ?? colorScheme.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border ?? Border.all(color: colorScheme.outline, width: 0.5),
      boxShadow: boxShadow ?? AppElevation.card,
    );

    final card = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      child: child,
    );

    if (onTap == null) {
      return Container(decoration: decoration, child: card);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: 1.0,
        duration: AppMotion.short,
        curve: AppMotion.easeOut,
        child: Container(decoration: decoration, child: card),
      ),
    );
  }
}

/// 可交互的 SurfaceCard（带 Material state layer ripple）
class TappableSurfaceCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;

  const TappableSurfaceCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.borderRadius = AppRadius.card,
    this.backgroundColor,
  });

  @override
  State<TappableSurfaceCard> createState() => _TappableSurfaceCardState();
}

class _TappableSurfaceCardState extends State<TappableSurfaceCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _pressed = true),
      onTapCancel: widget.onTap == null ? null : () => setState(() => _pressed = false),
      onTapUp: widget.onTap == null ? null : (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? AppMotion.pressScale : 1.0,
        duration: AppMotion.micro,
        curve: AppMotion.easeOut,
        child: AnimatedContainer(
          duration: AppMotion.short,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? colorScheme.surface,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: colorScheme.outline, width: 0.5),
            boxShadow: _pressed ? AppElevation.raised : AppElevation.card,
          ),
          padding: widget.padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
          child: widget.child,
        ),
      ),
    );
  }
}
