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
      width: 110,
      height: 110,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: 8,
        backgroundColor: sapphireDark.withOpacity(0.6),
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white70),
      ),
    );
  }
}
