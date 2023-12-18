import 'package:flutter/material.dart';
import 'package:tracker_app/app_constants.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            tealBlueLight,
            tealBlueDark,
          ],
        ),
      ),
    );
  }
}
