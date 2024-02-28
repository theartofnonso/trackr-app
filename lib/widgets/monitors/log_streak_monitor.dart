import 'package:flutter/material.dart';
import 'package:tracker_app/colors.dart';

import '../../utils/general_utils.dart';

class LogStreakMonitor extends StatelessWidget {
  final double value;

  const LogStreakMonitor({
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
        strokeWidth: 6,
        backgroundColor: sapphireDark80,
        strokeCap: StrokeCap.butt,
        valueColor: AlwaysStoppedAnimation<Color>(logStreakColor(value: value)),
      ),
    );
  }
}
