import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/backgrounds/gradient_widget.dart';
import 'package:tracker_app/widgets/empty_states/text_empty_state.dart';

import '../../colors.dart';

class ExerciseEmptyState extends StatelessWidget {
  const ExerciseEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                  leading: const Icon(
                    Icons.timeline_rounded,
                    color: Colors.white,
                  ),
                  title: Text("Squat", style: GoogleFonts.montserrat(color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: 300,
                          child: Text(
                            "Primary: Quadriceps",
                            style: GoogleFonts.montserrat(color: Colors.white70).copyWith(overflow: TextOverflow.ellipsis),
                          )),
                    ],
                  )),
              const Divider(thickness: 1.0, color: sapphireLight),
              ListTile(
                  leading: const Icon(
                    Icons.timeline_rounded,
                    color: Colors.white,
                  ),
                  title: Text("Romanian Deadlift", style: GoogleFonts.montserrat(color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: 300,
                          child: Text(
                            "Primary: Hamstrings",
                            style: GoogleFonts.montserrat(color: Colors.white70).copyWith(overflow: TextOverflow.ellipsis),
                          )),
                      SizedBox(
                          width: 300,
                          child: Text(
                            "Secondary: Glutes",
                            style: GoogleFonts.montserrat(color: Colors.white70).copyWith(overflow: TextOverflow.ellipsis),
                          )),
                    ],
                  )),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const TextEmptyState(message: "Tap the + button to add exercises"),
      ],
    );
  }
}
