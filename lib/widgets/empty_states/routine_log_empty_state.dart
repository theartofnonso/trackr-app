import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';

class RoutineLogEmptyState extends StatelessWidget {
  const RoutineLogEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          tileColor: sapphireLight,
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          title: Text("Legs Day 1",
              style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
          subtitle:
              Text("3 exercises", style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.w500)),
          trailing: Text("59m 39s",
              style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 14)),
        ),
        const SizedBox(height: 8),
        ListTile(
          tileColor: sapphireLight,
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          title: Text("Push Day",
              style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
          subtitle:
              Text("5 exercises", style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.w500)),
          trailing: Text("47m 39s",
              style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 14)),
        ),
      ],
    );
  }
}
