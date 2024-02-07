import 'package:flutter/material.dart';
import 'package:tracker_app/colors.dart';

class MuscleGroupFrequencyMonitor extends StatelessWidget {
  final double value;

  const MuscleGroupFrequencyMonitor({
    Key? key,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: 8,
        backgroundColor: sapphireLight,
        strokeCap: StrokeCap.round,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white70),
      ),
    );
  }
}
