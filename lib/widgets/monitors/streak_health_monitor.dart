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
        color: sapphireDark.withOpacity(0.7),
        width: 120,
        height: 120,
        child: CircularProgressIndicator(
          value: value,
          strokeWidth: 14,
          backgroundColor: sapphireLight,
          strokeCap: StrokeCap.round,
          valueColor: AlwaysStoppedAnimation<Color>(consistencyHealthColor(value: value)),
        ),
      ),
    );
  }
}