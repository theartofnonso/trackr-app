import 'package:flutter/material.dart';
import 'package:tracker_app/app_constants.dart';

class BarChartEmptyState extends StatelessWidget {
  const BarChartEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [50, 100, 150, 80, 120].map((value) => _buildBar(value, context)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(int value, BuildContext context) {
    return Container(
        width: 10,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        height: value.toDouble(), // Height of the bar is based on the value
        color: sapphireLight // Color of the bar
        );
  }
}
