import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../colors.dart';

class TRKRLoadingScreen extends StatelessWidget {
  const TRKRLoadingScreen({super.key, this.opacity = 0.6, this.action});

  final double opacity;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        color: sapphireDark.withOpacity(opacity),
        child: Stack(
          children: [
            if (action != null)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SafeArea(
                    minimum: const EdgeInsets.all(10.0),
                    child: IconButton(
                      icon: const FaIcon(FontAwesomeIcons.solidCircleXmark, color: Colors.white, size: 28),
                      onPressed: action,
                    ),
                  ),
                ),
              ),
            Center(
              child: Image.asset(
                'images/trkr.png',
                fit: BoxFit.contain,
                height: 16, // Adjust the height as needed
              ),
            ),
          ],
        ));
  }
}
