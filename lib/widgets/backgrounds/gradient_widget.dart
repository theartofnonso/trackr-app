import 'package:flutter/material.dart';
import 'package:tracker_app/colors.dart';

class GradientWidget extends StatelessWidget {
  final Widget child;

  const GradientWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.6),
          ),
        )
      ],
    );
  }
}
