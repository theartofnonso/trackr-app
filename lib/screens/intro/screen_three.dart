import 'package:flutter/material.dart';

import '../../app_constants.dart';
import '../../widgets/backgrounds/gradient_background.dart';

class ScreenThree extends StatelessWidget {
  const ScreenThree({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: Image.asset(
            'assets/pexelsss.jpg',
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
