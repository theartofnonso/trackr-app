import 'package:flutter/material.dart';

class ChipOne extends StatelessWidget {
  final String label;
  final Widget child;

  const ChipOne({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        child,
        const SizedBox(
          width: 6,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}