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
    return ClipOval(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: sapphireDark.withOpacity(0.3),
          borderRadius: BorderRadius.circular(5),
        ),
        child: CircularProgressIndicator(
          value: value,
          strokeWidth: 14,
          backgroundColor: sapphireDark80,
          strokeCap: StrokeCap.round,
          valueColor: AlwaysStoppedAnimation<Color>(consistencyHealthColor(value: value)),
        ),
      ),
    );
  }
}
