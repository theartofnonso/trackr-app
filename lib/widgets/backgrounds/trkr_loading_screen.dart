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
        padding: const EdgeInsets.all(10.0),
        width: double.infinity,
        height: double.infinity,
        color: sapphireDark.withOpacity(opacity),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(action != null)
              SafeArea(
              child: IconButton(
                icon: const FaIcon(FontAwesomeIcons.xmark, color: Colors.white, size: 28),
                onPressed: action,
              ),
            ),
            const Spacer(),
            Center(
              child: Image.asset(
                'images/trkr.png',
                fit: BoxFit.contain,
                height: 16, // Adjust the height as needed
              ),
            ),
            const Spacer(),
          ],));
  }
}
