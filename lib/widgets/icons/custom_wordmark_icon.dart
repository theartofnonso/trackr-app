import 'package:flutter/material.dart';

class CustomWordMarkIcon extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color color;
  final String label;

  const CustomWordMarkIcon(this.label, {super.key, this.width, this.height, this.padding, required this.color});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Text(label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: isDarkMode ? color : Colors.white,
        ));
  }
}
