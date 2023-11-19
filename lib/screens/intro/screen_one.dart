import 'package:flutter/material.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/widgets/backgrounds/gradient_background.dart';

class ScreenOne extends StatelessWidget {
  const ScreenOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: Image.asset(
            'assets/pexels.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        GradientBackground(
            height: double.infinity,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            color: tealBlueDark.withOpacity(0.05))
      ],
    );
  }
}
