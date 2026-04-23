
// 通用基础组件（Reusable Widgets）

import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final Function onPressed;

  const AppButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPressed(),
      child: Text(text),
    );
  }
}


class AppInput extends StatelessWidget{

  final String hintText;
  final Function(String) onChanged;

  const AppInput({super.key, required this.hintText, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(),
      ),
      onChanged: (value) => onChanged(value),
    );
  }
}


class AppCard extends StatelessWidget {
  final Widget child;

  const AppCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}

