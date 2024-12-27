import 'package:flutter/material.dart';

class MuscleTrendMonitor extends StatelessWidget {
  final double value;
  final double width;
  final double height;
  final double strokeWidth;
  final StrokeCap? strokeCap;
  final bool forceDarkMode;

  const MuscleTrendMonitor({
    super.key,
    required this.value,
    required this.width,
    required this.height,
    required this.strokeWidth,
    this.strokeCap, this.forceDarkMode = false
  });

  @override
  Widget build(BuildContext context) {

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark || forceDarkMode;

    return SizedBox(
      width: width,
      height: height,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: strokeWidth,
        backgroundColor: isDarkMode ? Colors.black12 : Colors.grey.shade200,
        strokeCap: strokeCap ?? StrokeCap.butt,
        valueColor: AlwaysStoppedAnimation<Color>(isDarkMode ? Colors.white: Colors.black),
      ),
    );
  }
}
