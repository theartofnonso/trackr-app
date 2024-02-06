import 'package:flutter/material.dart';
import 'package:tracker_app/colors.dart';

import '../../utils/general_utils.dart';

class ConsistencyHealthMonitor extends StatelessWidget {
  final double value;

  const ConsistencyHealthMonitor({
    Key? key,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: 8,
        backgroundColor: sapphireDark.withOpacity(0.6),
        valueColor: AlwaysStoppedAnimation<Color>(consistencyHealthColor(value: value)),
      ),
    );
  }
}
