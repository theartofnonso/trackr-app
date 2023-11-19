import 'package:flutter/material.dart';

import '../../app_constants.dart';
import '../../widgets/backgrounds/gradient_background.dart';
import '../../widgets/buttons/text_button_widget.dart';

class ScreenFour extends StatelessWidget {
  final VoidCallback onStartTracking;
  const ScreenFour({super.key, required this.onStartTracking});

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
            color: tealBlueDark.withOpacity(0.05)),
        Align(
          alignment: Alignment.bottomCenter,
          child: CTextButton(
            onPressed: onStartTracking,
            label: 'Start Tracking performance',
            textStyle: const TextStyle(fontSize: 16),
            buttonColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
          ),
        )
      ],
    );
  }
}
