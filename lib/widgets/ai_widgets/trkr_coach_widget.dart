import 'package:flutter/material.dart';

class TRKRCoachWidget extends StatelessWidget {
  const TRKRCoachWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Image.asset(
          'images/framer_logo.png',
          fit: BoxFit.cover,
          height: 30, // Adjust the height as needed
        ));
  }
}
