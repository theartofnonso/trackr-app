import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/widgets/empty_states/text_empty_state.dart';

class ExerciseEmptyState extends StatelessWidget {
  const ExerciseEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
                leading: const Icon(
                  Icons.timeline_rounded,
                  color: Colors.white70,
                ),
                title: Text("Squat", style: GoogleFonts.montserrat(color: Colors.white70)),
                subtitle: Text(
                  "Primary: ${MuscleGroup.quadriceps.name}",
                  style: GoogleFonts.montserrat(color: Colors.white70).copyWith(overflow: TextOverflow.ellipsis),
                )),
            const SizedBox(height: 8),
            ListTile(
                leading: const Icon(
                  Icons.timeline_rounded,
                  color: Colors.white70,
                ),
                title: Text("Romanian Deadlift", style: GoogleFonts.montserrat(color: Colors.white70)),
                subtitle: Text(
                  "Primary: ${MuscleGroup.hamstrings.name}",
                  style: GoogleFonts.montserrat(color: Colors.white70).copyWith(overflow: TextOverflow.ellipsis),
                )),
          ],
        ),
        const SizedBox(height: 10),
        const TextEmptyState(message: "Tap the + button to add exercises"),
      ],
    );
  }
}
