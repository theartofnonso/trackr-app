import 'package:flutter/material.dart';
import 'package:tracker_app/colors.dart';

import '../../utils/general_utils.dart';

class MuscleGroupFamilyFrequencyMonitor extends StatelessWidget {
  final double value;
  final double width;
  final double height;
  final double strokeWidth;
  final StrokeCap? strokeCap;
  final Decoration? decoration;

  const MuscleGroupFamilyFrequencyMonitor({
    Key? key,
    required this.value,
    required this.width,
    required this.height,
    required this.strokeWidth,
    this.strokeCap, this.decoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: decoration,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: strokeWidth,
        backgroundColor: sapphireDark80,
        strokeCap: strokeCap ?? StrokeCap.butt,
        valueColor: AlwaysStoppedAnimation<Color>(muscleFamilyFrequencyColor(value: value)),
      ),
    );
  }
}
