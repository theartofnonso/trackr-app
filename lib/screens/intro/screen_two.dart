import 'package:flutter/material.dart';

import '../../app_constants.dart';
import '../../widgets/backgrounds/gradient_background.dart';

class ScreenTwo extends StatelessWidget {
  const ScreenTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: Image.asset(
            'assets/pexelss.jpg',
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
