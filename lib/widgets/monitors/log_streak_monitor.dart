import 'package:flutter/material.dart';
import 'package:tracker_app/colors.dart';

import '../../utils/general_utils.dart';

class LogStreakMonitor extends StatelessWidget {
  final double value;
  final double width;
  final double height;
  final double strokeWidth;
  final StrokeCap? strokeCap;
  final Decoration? decoration;

  const LogStreakMonitor({
    super.key,
    required this.value,
    required this.width,
    required this.height,
    required this.strokeWidth, this.strokeCap, this.decoration,
  });

  @override
  Widget build(BuildContext context) {

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Container(
      width: height,
      height: width,
      decoration: decoration,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: strokeWidth,
        backgroundColor: isDarkMode ? sapphireLighter : Colors.grey.shade200,
        strokeCap: strokeCap ?? StrokeCap.butt,
        valueColor: AlwaysStoppedAnimation<Color>(logStreakColor(value: value)),
      ),
    );
  }
}
