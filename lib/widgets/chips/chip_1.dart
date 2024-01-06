import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ChipOne extends StatelessWidget {
  final Color color;
  final String label;

  const ChipOne({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const FaIcon(FontAwesomeIcons.solidStar, color: Colors.green, size: 14),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))
    ]);
  }
}