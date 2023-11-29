import 'package:flutter/material.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/widgets/routine/preview/set_rows/duration_distance_set_row.dart';
import 'package:tracker_app/widgets/routine/preview/set_rows/duration_set_row.dart';

import '../../dtos/procedure_dto.dart';
import '../../dtos/set_dto.dart';
import '../empty_states/list_tile_empty_state.dart';
import '../routine/preview/set_rows/weight_distance_set_row.dart';
import '../routine/preview/set_rows/reps_set_row.dart';
import '../routine/preview/set_rows/weight_reps_set_row.dart';

ProcedureDto? whereOtherSuperSetProcedure(
    {required ProcedureDto firstProcedure, required List<ProcedureDto> procedures}) {
  for (var procedure in procedures) {
    bool isSameSuperset = procedure.superSetId.isNotEmpty && procedure.superSetId == firstProcedure.superSetId;
    bool isDifferentProcedure = procedure.exercise.id != firstProcedure.exercise.id;

    if (isSameSuperset && isDifferentProcedure) {
      return procedure;
    }
  }

  return null; // Explicitly return null if no matching procedure is found
}

List<Widget> setsToWidgets({required ExerciseType type, required List<SetDto> sets}) {
  final widgets = sets.map(((setDto) {
    final widget = Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: switch (type) {
        ExerciseType.weightAndReps ||
        ExerciseType.weightedBodyWeight ||
        ExerciseType.assistedBodyWeight =>
          WeightRepsSetRow(setDto: setDto),
        ExerciseType.bodyWeightAndReps => RepsSetRow(setDto: setDto),
        ExerciseType.duration => DurationSetRow(setDto: setDto),
        ExerciseType.durationAndDistance => DurationDistanceSetRow(setDto: setDto),
        ExerciseType.weightAndDistance => WeightDistanceSetRow(setDto: setDto),
      },
    );

    return widget;
  })).toList();

  return widgets.isNotEmpty ? widgets : [const ListTileEmptyState()];
}
