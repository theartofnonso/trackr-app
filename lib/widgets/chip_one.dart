import 'package:flutter/material.dart';

class ChipOne extends StatelessWidget {
  final String label;
  final Widget child;
  final Color color;

  const ChipOne({super.key, required this.label, required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 30,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Center(
            child: child,
          ),
        ),
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