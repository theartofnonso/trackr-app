import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../dtos/set_dto.dart';

class SetTypeIcon extends StatelessWidget {
  const SetTypeIcon({super.key, required this.type, required this.label});

  final SetType type;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: GoogleFonts.lato(color: type.color, fontWeight: FontWeight.bold),
    );
  }
}
