import 'package:flutter/material.dart';
import '../design/radius.dart';

/// Shimmer 骨架屏加载器
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.borderRadius = 7,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final base = widget.baseColor ?? colorScheme.outlineVariant;
    final highlight = widget.highlightColor ?? colorScheme.surfaceContainerHighest;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(base, highlight, _controller.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

/// 多行文本骨架屏
class SkeletonParagraph extends StatelessWidget {
  final int lines;
  final double spacing;

  const SkeletonParagraph({super.key, this.lines = 4, this.spacing = 8});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (i) {
        final widths = [0.8, 1.0, 0.6, 0.9];
        final fraction = i < widths.length ? widths[i] : 0.7;
        return Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: FractionallySizedBox(
            widthFactor: (i == lines - 1) ? 0.5 : fraction,
            child: SkeletonLoader(
              height: 14,
              borderRadius: AppRadius.sharp + 3,
            ),
          ),
        );
      }),
    );
  }
}
