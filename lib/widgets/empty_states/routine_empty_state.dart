import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/empty_states/text_empty_state.dart';

import '../../colors.dart';

class RoutineEmptyState extends StatelessWidget {
  const RoutineEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              tileColor: sapphireDark80,
              dense: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              leading: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white70,
                size: 35,
              ),
              title: Text("Legs Day 1", style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14)),
              subtitle: Text("3 exercises",
                  style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.more_horiz_rounded, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            ListTile(
              tileColor: sapphireDark80,
              dense: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
              leading: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white70,
                size: 35,
              ),
              title: Text("Push Day", style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14)),
              subtitle: Text("5 exercises",
                  style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.more_horiz_rounded, color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const TextEmptyState(message: "Tap the + button to create workout templates"),
      ],
    );
  }
}
