import 'package:flutter/material.dart';

import '../../colors.dart';

class TRKRCoachWidget extends StatelessWidget {
  const TRKRCoachWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                vibrantBlue,
                vibrantBlue,
                vibrantGreen,
                vibrantGreen // End color
              ],
              begin: Alignment.topLeft, // Gradient starts from top-left
              end: Alignment.bottomRight, // Gradient ends at bottom-right
            ),
            borderRadius: BorderRadius.circular(5)),
        child: Image.asset(
          'images/trkr_single_icon.png',
          fit: BoxFit.contain,
          height: 12, // Adjust the height as needed
        ));
  }
}
