import 'package:flutter/material.dart';

import '../../utils/general_utils.dart';

class LogStreakMonitor extends StatelessWidget {
  final num value;
  final double width;
  final double height;
  final double strokeWidth;
  final StrokeCap? strokeCap;
  final bool forceDarkMode;

  const LogStreakMonitor({
    super.key,
    this.value = 0,
    required this.width,
    required this.height,
    required this.strokeWidth, this.strokeCap, this.forceDarkMode = false
  });

  @override
  Widget build(BuildContext context) {

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark || forceDarkMode;

    return SizedBox(
      width: height,
      height: width,
      child: CircularProgressIndicator(
        value: value.toDouble(),
        strokeWidth: strokeWidth,
        backgroundColor: isDarkMode ? Colors.black12 : Colors.grey.shade200,
        strokeCap: strokeCap ?? StrokeCap.butt,
        valueColor: AlwaysStoppedAnimation<Color>(logStreakColor(value)),
      ),
    );
  }
}
