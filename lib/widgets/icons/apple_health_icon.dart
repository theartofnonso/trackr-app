
import 'package:flutter/material.dart';

class AppleHealthIcon extends StatelessWidget {
  const AppleHealthIcon({
    super.key,
    required this.isDarkMode,
    required this.height,
  });

  final bool isDarkMode;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          boxShadow: isDarkMode
              ? null
              : [
            BoxShadow(
              color: Colors.grey.shade300,
              spreadRadius: 3,
              blurRadius: 10,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Image.asset(
          'images/apple_health.png',
          fit: BoxFit.contain,
          height: height, // Adjust the height as needed
        ));
  }
}