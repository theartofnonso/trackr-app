import 'package:flutter/material.dart';
import 'package:tracker_app/colors.dart';

import '../../utils/general_utils.dart';

class StreakHealthMonitor extends StatefulWidget {
  final double value;

  const StreakHealthMonitor({
    Key? key,
    required this.value,
  }) : super(key: key);

  @override
  State<StreakHealthMonitor> createState() => _StreakHealthMonitorState();
}

class _StreakHealthMonitorState extends State<StreakHealthMonitor> {
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
        value: widget.value,
        strokeWidth: 8,
        backgroundColor: sapphireDark80,
        strokeCap: StrokeCap.butt,
        valueColor: AlwaysStoppedAnimation<Color>(consistencyHealthColor(value: widget.value)),
      ),
    );
  }
}
