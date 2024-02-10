import 'package:flutter/material.dart';
import 'package:tracker_app/colors.dart';

class MuscleGroupFamilyFrequencyMonitor extends StatelessWidget {
  final double value;

  const MuscleGroupFamilyFrequencyMonitor({
    Key? key,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: 8,
        backgroundColor: sapphireLight,
        strokeCap: StrokeCap.round,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }
}
