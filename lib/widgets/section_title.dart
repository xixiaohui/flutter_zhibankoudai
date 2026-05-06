import 'package:flutter/material.dart';
import '../xui/x_design.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry? padding;

  const SectionTitle(this.title, {super.key, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Text(title.toUpperCase(), style: XuiTheme.uppercaseLabel()),
    );
  }
}
