import 'package:flutter/material.dart';

class TRKRCoachWidget extends StatelessWidget {
  const TRKRCoachWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Image.asset(
          'images/logo_transparent.png',
          fit: BoxFit.contain,
          height: 12, // Adjust the height as needed
        ));
  }
}
