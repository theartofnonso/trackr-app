import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../colors.dart';

class UserIconWidget extends StatelessWidget {

  final double size;
  final double iconSize;

  const UserIconWidget({super.key, required this.size, required this.iconSize});

  @override
  Widget build(BuildContext context) {

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Container(
        width: size, // Width and height should be equal to make a perfect circle
        height: size,
        decoration: BoxDecoration(
          color: isDarkMode ? sapphireDark80 : Colors.grey.shade200,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5), // Optional border
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? sapphireDark.withValues(alpha:0.5) : Colors.grey.shade400,
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Center(child: FaIcon(FontAwesomeIcons.personWalking, color: isDarkMode ? Colors.white54 : Colors.black, size: iconSize)));
  }
}
