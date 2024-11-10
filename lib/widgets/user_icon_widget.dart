import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../colors.dart';

class UserIconWidget extends StatelessWidget {

  final double size;
  final double iconSize;

  const UserIconWidget({super.key, required this.size, required this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size, // Width and height should be equal to make a perfect circle
        height: size,
        decoration: BoxDecoration(
          color: sapphireDark80,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5), // Optional border
          boxShadow: [
            BoxShadow(
              color: sapphireDark.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Center(child: FaIcon(FontAwesomeIcons.solidUser, color: Colors.white54, size: iconSize)));
  }
}
