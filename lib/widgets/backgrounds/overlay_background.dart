import 'package:flutter/material.dart';

import '../../colors.dart';

class OverlayBackground extends StatelessWidget {
  const OverlayBackground({super.key, this.opacity = 0.7});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: Container(
            width: double.infinity,
            height: double.infinity,
            color: sapphireDark.withOpacity(opacity),
            child: Center(
                child: Image.asset(
              'images/trkr.png',
              fit: BoxFit.contain,
              height: 16, // Adjust the height as needed
            ))));
  }
}
