import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';

class PBIcon extends StatelessWidget {
  final Color color;
  final String label;

  const PBIcon({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const FaIcon(FontAwesomeIcons.solidStar, color: vibrantGreen, size: 14),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))
    ]);
  }
}
