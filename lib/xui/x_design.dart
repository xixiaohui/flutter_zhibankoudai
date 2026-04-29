
import 'package:flutter/material.dart';

/// Xui 设计系统（基于 AppTheme + Clay 设计规范）
class XuiTheme {
  static const String primaryFont = 'Roobert';
  static const String monoFont = 'Space Mono';

  static const Color warmCream = Color(0xFFfaf9f7);
  static const Color pureWhite = Color(0xFFffffff);
  static const Color clayBlack = Color(0xFF000000);
  
  static const Color matcha300 = Color(0xFF84e7a5);
  static const Color matcha600 = Color(0xFF078a52);
  static const Color matcha800 = Color(0xFF02492a);

  static const Color slushie500 = Color(0xFF3bd3fd);
  static const Color slushie800 = Color(0xFF0089ad);

  static const Color lemon400 = Color(0xFFf8cc65);
  static const Color lemon500 = Color(0xFFfbbd41);
  static const Color lemon700 = Color(0xFFd08a11);
  static const Color lemon800 = Color(0xFF9d6a09);

  static const Color ube300 = Color(0xFFc1b0ff);
  static const Color ube800 = Color(0xFF43089f);
  static const Color ube900 = Color(0xFF32037d);

  static const Color pomegranate400 = Color(0xFFfc7981);
  static const Color blueberry800 = Color(0xFF01418d);

  static const Color oatBorder = Color(0xFFdad4c8);
  static const Color oatLight = Color(0xFFeee9df);
  static const Color coolBorder = Color(0xFFe6e8ec);

  static const Color warmSilver = Color(0xFF9f9b93);
  static const Color warmCharcoal = Color(0xFF55534e);
  static const Color darkCharcoal = Color(0xFF333333);

  static List<BoxShadow> get clayShadow => const [
    BoxShadow(color: Color(0x1A000000), blurRadius: 1, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 1, offset: Offset(0, -1)),
    BoxShadow(color: Color(0x0D000000), blurRadius: 1, offset: Offset(0, -0.5)),
  ];
  
  static TextStyle displayHero() => const TextStyle(
        fontFamily: primaryFont,
        fontWeight: FontWeight.w600,
        fontSize: 60,
        height: 1.0,
        letterSpacing: -2.4,
        color: clayBlack,
        fontFeatures: [
          FontFeature.enable('ss01'),
          FontFeature.enable('ss03'),
          FontFeature.enable('ss10'),
          FontFeature.enable('ss11'),
          FontFeature.enable('ss12'),
        ],
      );
  static TextStyle sectionHeading() => const TextStyle(
        fontFamily: primaryFont,
        fontWeight: FontWeight.w600,
        fontSize: 44,
        height: 1.1,
        letterSpacing: -1.32,
        color: clayBlack,
        fontFeatures: [
          FontFeature.enable('ss01'),
          FontFeature.enable('ss03'),
          FontFeature.enable('ss10'),
          FontFeature.enable('ss11'),
          FontFeature.enable('ss12'),
        ],
      );
  static TextStyle cardHeading() => const TextStyle(
        fontFamily: primaryFont,
        fontWeight: FontWeight.w600,
        fontSize: 32,
        height: 1.1,
        letterSpacing: -0.64,
        color: clayBlack,
        fontFeatures: [
          FontFeature.enable('ss01'),
          FontFeature.enable('ss03'),
          FontFeature.enable('ss10'),
          FontFeature.enable('ss11'),
          FontFeature.enable('ss12'),
        ],
      );
  static TextStyle featureTitle() => const TextStyle(
        fontFamily: primaryFont,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        height: 1.4,
        letterSpacing: -0.4,
        color: clayBlack,
        fontFeatures: [
          FontFeature.enable('ss01'),
          FontFeature.enable('ss03'),
          FontFeature.enable('ss10'),
          FontFeature.enable('ss11'),
          FontFeature.enable('ss12'),
        ],
      );
  static TextStyle subHeading() => const TextStyle(
        fontFamily: primaryFont,
        fontWeight: FontWeight.w500,
        fontSize: 20,
        height: 1.5,
        letterSpacing: -0.16,
        color: warmCharcoal,
        fontFeatures: [
          FontFeature.enable('ss03'),
          FontFeature.enable('ss10'),
          FontFeature.enable('ss11'),
          FontFeature.enable('ss12'),
        ],
      );
  static TextStyle bodyLarge() => const TextStyle(
        fontFamily: primaryFont,
        fontWeight: FontWeight.w400,
        fontSize: 20,
        height: 1.4,
        color: clayBlack,
        fontFeatures: [
          FontFeature.enable('ss03'),
          FontFeature.enable('ss10'),
          FontFeature.enable('ss11'),
          FontFeature.enable('ss12'),
        ],
      );
  static TextStyle body() => const TextStyle(
        fontFamily: primaryFont,
        fontWeight: FontWeight.w400,
        fontSize: 18,
        height: 1.6,
        letterSpacing: -0.36,
        color: clayBlack,
        fontFeatures: [
          FontFeature.enable('ss03'),
          FontFeature.enable('ss10'),
          FontFeature.enable('ss11'),
          FontFeature.enable('ss12'),
        ],
      );
  static TextStyle bodyStd() => const TextStyle(
        fontFamily: primaryFont,
        fontWeight: FontWeight.w400,
        fontSize: 16,
        height: 1.5,
        color: clayBlack,
        fontFeatures: [
          FontFeature.enable('ss03'),
          FontFeature.enable('ss10'),
          FontFeature.enable('ss11'),
          FontFeature.enable('ss12'),
        ],
      );
  static TextStyle bodyMed() => const TextStyle(
        fontFamily: primaryFont,
        fontWeight: FontWeight.w500,
        fontSize: 16,
        height: 1.4,
        letterSpacing: -0.16,
        color: clayBlack,
        fontFeatures: [
          FontFeature.enable('ss03'),
          FontFeature.enable('ss10'),
          FontFeature.enable('ss11'),
          FontFeature.enable('ss12'),
        ],
      );
  static TextStyle buttonText() => const TextStyle(
        fontFamily: primaryFont,
        fontWeight: FontWeight.w500,
        fontSize: 16,
        height: 1.5,
        letterSpacing: -0.16,
        color: clayBlack,
        fontFeatures: [
          FontFeature.enable('ss03'),
          FontFeature.enable('ss10'),
          FontFeature.enable('ss11'),
          FontFeature.enable('ss12'),
        ],
      );
  static TextStyle uppercaseLabel() => const TextStyle(
        fontFamily: primaryFont,
        fontWeight: FontWeight.w600,
        fontSize: 12,
        height: 1.2,
        letterSpacing: 1.08,
        color: warmCharcoal,
        fontFeatures: [
          FontFeature.enable('ss03'),
          FontFeature.enable('ss10'),
          FontFeature.enable('ss11'),
          FontFeature.enable('ss12'),
        ],
      );

  static BoxDecoration cardDecoration({Color color = pureWhite, double radius = 24, BoxBorder? border}) => BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: border ?? Border.all(color: oatBorder, width: 1),
        boxShadow: clayShadow,
      );

  static InputDecoration inputDecoration({String? hintText}) => InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: pureWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF717989), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF717989), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF146EF5), width: 2),
        ),
      );
}

/// Clay 风格可交互容器：圆角24px/12px，燕麦边框，三层阴影，
/// 悬停时上移 + 硬偏移阴影，按钮附带旋转。
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
    super.key, required this.child, this.onTap,
    this.isButton = false, this.borderRadius = 24,
    this.color, this.padding, this.dashed = false, this.customBorder,
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
          ..translate(0.0, dy)
          ..rotateZ(-0.14);
      } else {
        matrix.translate(0.0, dy);
      }
    }
    if (_pressed && widget.onTap != null) {
      matrix.scale(0.985, 0.985);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: widget.onTap == null ? null : (_) => setState(() => _pressed = true),
        onTapCancel: widget.onTap == null ? null : () => setState(() => _pressed = false),
        onTapUp: widget.onTap == null ? null : (_) => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: matrix,
          transformAlignment: Alignment.center,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.color ?? XuiTheme.pureWhite,
            borderRadius: BorderRadius.circular(widget.isButton ? 24 : widget.borderRadius),
            border: widget.customBorder ?? Border.all(color: XuiTheme.oatBorder, width: 1),
            boxShadow: (_hover && widget.onTap != null)
                ? const [BoxShadow(color: XuiTheme.clayBlack, blurRadius: 0, offset: Offset(-7, 7))]
                : XuiTheme.clayShadow,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// 大写 Section 标题（12px uppercase, letter-spacing 1.08px）
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
      child: Text(title.toUpperCase(), style: XuiTheme.uppercaseLabel()),
    );
  }
}
