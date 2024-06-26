import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/empty_states/text_empty_state.dart';

import '../../colors.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../routine/editors/set_headers/weight_reps_set_header.dart';

class ExerciseLogEmptyState extends StatelessWidget {
  final RoutineEditorMode mode;
  final String message;

  const ExerciseLogEmptyState({
    super.key,
    required this.mode,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: sapphireDark80, // Set the background color
              borderRadius: BorderRadius.circular(5), // Set the border radius to make it rounded
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Hamstring Curl",
                    style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
                const Icon(Icons.more_horiz_rounded, color: Colors.white70)
              ]),
              const SizedBox(height: 10),
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  decoration: BoxDecoration(
                    color: sapphireDark.withOpacity(0.6), // Container background color
                    borderRadius: BorderRadius.circular(5.0), // Border radius
                  ),
                  child: Text("Enter notes",
                      style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 14))),
              const SizedBox(height: 10),
              WeightRepsSetHeader(editorType: mode, firstLabel: 'KG', secondLabel: 'REPS')
            ])),
        const SizedBox(height: 10),
        TextEmptyState(message: message)
      ],
    );
  }
}
