import 'package:flutter/material.dart';
import 'package:tracker_app/colors.dart';

import '../../utils/general_utils.dart';

class StreakHealthMonitor extends StatelessWidget {
  final double value;

  const StreakHealthMonitor({
    Key? key,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: sapphireDark.withOpacity(0.35),
        borderRadius: BorderRadius.circular(100),
      ),
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: 8,
        backgroundColor: sapphireDark80,
        strokeCap: StrokeCap.butt,
        valueColor: AlwaysStoppedAnimation<Color>(consistencyHealthColor(value: value)),
      ),
    );
  }
}
