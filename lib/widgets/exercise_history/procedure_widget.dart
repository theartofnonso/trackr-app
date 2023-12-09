import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';

import '../../enums/exercise_type_enums.dart';
import '../../utils/general_utils.dart';
import '../helper_widgets/routine_helper.dart';
import '../routine/preview/set_headers/duration_distance_set_header.dart';
import '../routine/preview/set_headers/duration_set_header.dart';
import '../routine/preview/set_headers/reps_set_header.dart';
import '../routine/preview/set_headers/weighted_set_header.dart';

class ProcedureWidget extends StatelessWidget {
  final ExerciseLogDto exerciseLog;

  const ProcedureWidget({
    super.key,
    required this.exerciseLog,
  });

  @override
  Widget build(BuildContext context) {

    final exerciseString = exerciseLog.exercise.type;
    final exerciseType = ExerciseType.fromString(exerciseString);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        exerciseLog.notes.isNotEmpty
            ? Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(exerciseLog.notes,
              style: GoogleFonts.lato(fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.8), fontSize: 15)),
        )
            : const SizedBox.shrink(),
        switch (exerciseType) {
          ExerciseType.weightAndReps => WeightedSetHeader(firstLabel: weightLabel().toUpperCase(), secondLabel: 'REPS',),
          ExerciseType.weightedBodyWeight => WeightedSetHeader(firstLabel: "+${weightLabel().toUpperCase()}", secondLabel: 'REPS',),
          ExerciseType.assistedBodyWeight => WeightedSetHeader(firstLabel: '-${weightLabel().toUpperCase()}', secondLabel: 'REPS',),
          ExerciseType.weightAndDistance => WeightedSetHeader(firstLabel: weightLabel().toUpperCase(), secondLabel: distanceTitle(type: ExerciseType.weightAndDistance)),
          ExerciseType.bodyWeightAndReps => const RepsSetHeader(),
          ExerciseType.duration => const DurationSetHeader(),
          ExerciseType.durationAndDistance => const DurationDistanceSetHeader(),
        },
        const SizedBox(height: 8),
        ...setsToWidgets(type: ExerciseType.fromString(exerciseLog.exercise.type), sets: exerciseLog.sets),
      ],
    );
  }
}
