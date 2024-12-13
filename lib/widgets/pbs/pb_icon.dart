import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../colors.dart';

class PBIcon extends StatelessWidget {
  final Color color;
  final String label;

  const PBIcon({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const FaIcon(
          FontAwesomeIcons.solidStar, color: vibrantGreen, size: 14),
      const SizedBox(width: 6),
      Text(label, style: Theme.of(context).textTheme.bodySmall!)
    ]);
  }
}
