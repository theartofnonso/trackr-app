import 'package:flutter/material.dart';
import 'package:tracker_app/app_constants.dart';

class GradientWidget extends StatelessWidget {
  final Widget child;

  const GradientWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  sapphireDark.withOpacity(0.2),
                  sapphireDark,
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
