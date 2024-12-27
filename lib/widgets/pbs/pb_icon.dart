import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../colors.dart';

class PBIcon extends StatelessWidget {
  final String label;
  final int? size;
  final TextStyle? textStyle;

  const PBIcon({super.key, required this.label, this.size = 14, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      FaIcon(
          FontAwesomeIcons.solidStar, color: vibrantGreen, size: (size ?? 14).toDouble()),
      const SizedBox(width: 6),
      Text(label, style: textStyle ?? Theme.of(context).textTheme.bodySmall!)
    ]);
  }
}
