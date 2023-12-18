import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/backgrounds/gradient_background.dart';
import 'package:tracker_app/widgets/empty_states/text_empty_state.dart';

import '../../app_constants.dart';

class RoutineEmptyState extends StatelessWidget {
  const RoutineEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientBackground(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  tileColor: tealBlueLight,
                  dense: true,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  leading: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 35,
                  ),
                  title: Text("Legs Day 1", style: Theme.of(context).textTheme.labelLarge),
                  subtitle: Row(children: [
                    const Icon(
                      Icons.numbers,
                      color: Colors.white,
                      size: 12,
                    ),
                    Text("3 exercises",
                        style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
                  ]),
                  trailing: const Icon(Icons.more_horiz_rounded, color: Colors.white),
                ),
                const SizedBox(height: 8),
                ListTile(
                  tileColor: tealBlueLight,
                  dense: true,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                  leading: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 35,
                  ),
                  title: Text("Push Day", style: Theme.of(context).textTheme.labelLarge),
                  subtitle: Row(children: [
                    const Icon(
                      Icons.numbers,
                      color: Colors.white,
                      size: 12,
                    ),
                    Text("5 exercises",
                        style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
                  ]),
                  trailing: const Icon(Icons.more_horiz_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const TextEmptyState(message: "Tap the + button to create workouts"),
        ],
      ),
    );
  }
}
