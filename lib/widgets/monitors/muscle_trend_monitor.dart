import 'package:flutter/material.dart';
import 'package:tracker_app/colors.dart';

import '../../utils/general_utils.dart';

class MuscleTrendMonitor extends StatelessWidget {
  final double value;
  final double width;
  final double height;
  final double strokeWidth;
  final StrokeCap? strokeCap;

  const MuscleTrendMonitor({
    super.key,
    required this.value,
    required this.width,
    required this.height,
    required this.strokeWidth,
    this.strokeCap
  });

  @override
  Widget build(BuildContext context) {

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return SizedBox(
      width: width,
      height: height,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: strokeWidth,
        backgroundColor: isDarkMode ? sapphireLighter : Colors.grey.shade200,
        strokeCap: strokeCap ?? StrokeCap.butt,
        valueColor: AlwaysStoppedAnimation<Color>(muscleFamilyFrequencyColor(value: value, isDarkMode: isDarkMode)),
      ),
    );
  }
}
