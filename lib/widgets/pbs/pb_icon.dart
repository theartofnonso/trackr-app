import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../colors.dart';

class PBIcon extends StatelessWidget {
  final String label;
  final int? size;

  const PBIcon({super.key, required this.label, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      FaIcon(
          FontAwesomeIcons.solidStar, color: vibrantGreen, size: (size ?? 14).toDouble()),
      const SizedBox(width: 6),
      Text(label, style: Theme.of(context).textTheme.bodySmall!)
    ]);
  }
}
