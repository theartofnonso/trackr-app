import 'package:flutter/material.dart';

class CTextButtonWidget extends StatelessWidget {

  final void Function() onPressed;
  final String label;
  final TextStyle? style;

  const CTextButtonWidget({super.key, required this.onPressed, required this.label, this.style});

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: onPressed, child: Text(label, style: style ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),),);
  }
}
