import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/duration_num_pair.dart';
import 'package:tracker_app/dtos/double_num_pair.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/widgets/routine/preview/set_rows/distance_duration_set_row.dart';
import 'package:tracker_app/widgets/routine/preview/set_rows/duration_set_row.dart';

import '../../app_constants.dart';
import '../../dtos/procedure_dto.dart';
import '../../dtos/set_dto.dart';
import '../../providers/procedures_provider.dart';
import '../empty_states/list_tile_empty_state.dart';
import '../routine/preview/set_rows/reps_set_row.dart';
import '../routine/preview/set_rows/weighted_set_row.dart';

ProcedureDto? whereOtherSuperSetProcedure({required BuildContext context, required ProcedureDto firstProcedure}) {
  final procedures = Provider.of<ProceduresProvider>(context, listen: false).procedures;
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
  int workingSets = 0;

  final widgets = sets.mapIndexed(((index, setDto) {
    final workingIndex = setDto.type == SetType.working ? workingSets : -1;

    final widget = Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Container(
        decoration: BoxDecoration(
          color: tealBlueLight,
          borderRadius: BorderRadius.circular(3),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: switch (type) {
          ExerciseType.weightAndReps ||
          ExerciseType.weightedBodyWeight ||
          ExerciseType.assistedBodyWeight ||
          ExerciseType.weightAndDistance =>
            WeightedSetRow(
              index: index,
              workingIndex: workingIndex,
              setDto: setDto as DoubleNumPair,
            ),
          ExerciseType.bodyWeightAndReps => RepsSetRow(
              index: index,
              workingIndex: workingIndex,
              setDto: setDto as DoubleNumPair,
            ),
          ExerciseType.duration => DurationSetRow(
              index: index,
              workingIndex: workingIndex,
              setDto: setDto as DurationNumPair,
            ),
          ExerciseType.distanceAndDuration => DistanceDurationSetRow(
              index: index,
              workingIndex: workingIndex,
              setDto: setDto as DurationNumPair,
            ),
        },
      ),
    );

    if (setDto.type == SetType.working) {
      workingSets += 1;
    }

    return widget;
  })).toList();

  return widgets.isNotEmpty ? widgets : [const ListStyleEmptyState()];
}
