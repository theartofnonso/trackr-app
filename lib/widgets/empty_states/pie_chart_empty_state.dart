import 'package:flutter/material.dart';

import '../../app_constants.dart';

class PieChartEmptyState extends StatelessWidget {
  const PieChartEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
        width: 150,
        height: 150,
        child: CircularProgressIndicator(
          value: 1,
          strokeWidth: 10,
          color: tealBlueLighter,
        ));
  }
}
