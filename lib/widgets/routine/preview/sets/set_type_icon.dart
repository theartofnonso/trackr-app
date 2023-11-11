import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../dtos/set_dto.dart';

class SetTypeIcon extends StatelessWidget {

  const SetTypeIcon({super.key, required this.type, required this.label});

  final SetType type;
  final int label;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      child: Text(
        type == SetType.working ? "${label + 1}" : type.label,
        style: GoogleFonts.lato(color: type.color, fontWeight: FontWeight.bold),
      ),
    );
  }
}