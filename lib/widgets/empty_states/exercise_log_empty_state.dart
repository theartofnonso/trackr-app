import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/empty_states/text_empty_state.dart';

import '../../app_constants.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../routine/editors/set_headers/weight_reps_set_header.dart';

class EmptyStateExerciseLog extends StatelessWidget {
  final RoutineEditorMode mode;
  final String message;

  const EmptyStateExerciseLog({
    super.key,
    required this.mode,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Opacity(
          opacity: 0.7,
          child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: tealBlueLight, // Set the background color
                borderRadius: BorderRadius.circular(5), // Set the border radius to make it rounded
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("Hamstring Curls",
                      style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const Icon(Icons.more_horiz_rounded, color: Colors.white)
                ]),
                const SizedBox(height: 10),
                Container(
                    width: double.infinity,
                    //height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    decoration: BoxDecoration(
                      color: tealBlueLighter, // Container background color
                      borderRadius: BorderRadius.circular(5.0), // Border radius
                    ),
                    child: Text("Enter notes",
                        style: GoogleFonts.lato(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 14))),
                const SizedBox(height: 10),
                WeightRepsSetHeader(editorType: mode, firstLabel: 'KG', secondLabel: 'REPS')
              ])),
        ),
        const SizedBox(height: 10),
        TextEmptyState(message: message)
      ],
    );
  }
}

