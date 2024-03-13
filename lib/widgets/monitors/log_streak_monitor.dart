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
    Key? key,
    required this.value,
    required this.width,
    required this.height,
    required this.strokeWidth, this.strokeCap, this.decoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: height,
      height: width,
      decoration: decoration,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: strokeWidth,
        backgroundColor: sapphireDark80,
        strokeCap: strokeCap ?? StrokeCap.butt,
        valueColor: AlwaysStoppedAnimation<Color>(logStreakColor(value: value)),
      ),
    );
  }
}
