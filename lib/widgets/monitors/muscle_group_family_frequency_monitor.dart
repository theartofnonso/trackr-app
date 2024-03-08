import 'package:flutter/material.dart';
import 'package:tracker_app/colors.dart';

import '../../utils/general_utils.dart';

class MuscleGroupFamilyFrequencyMonitor extends StatelessWidget {
  final double value;

  const MuscleGroupFamilyFrequencyMonitor({
    Key? key,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: 6,
        backgroundColor: sapphireDark80,
        strokeCap: StrokeCap.butt,
        valueColor: AlwaysStoppedAnimation<Color>(muscleFamilyFrequencyColor(value: value)),
      ),
    );
  }
}