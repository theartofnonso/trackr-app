import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/duration_dto.dart';
import 'package:tracker_app/dtos/weight_reps_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/widgets/routine/preview/sets/duration_widget.dart';

import '../../dtos/procedure_dto.dart';
import '../../dtos/set_dto.dart';
import '../empty_states/list_tile_empty_state.dart';
import '../routine/preview/sets/weight_reps_widget.dart';
import '../routine/preview/sets/body_weight_widget.dart';

ProcedureDto? whereOtherSuperSetProcedure(
    {required ProcedureDto firstProcedure, required List<ProcedureDto> procedures}) {
  return procedures.firstWhereOrNull((procedure) =>
      procedure.superSetId.isNotEmpty &&
      procedure.superSetId == firstProcedure.superSetId &&
      procedure.exercise.id != firstProcedure.exercise.id);
}

List<Widget> setsToWidgets({required ExerciseType type, required List<SetDto> sets}) {
  int workingSets = 0;

  final widgets = sets.mapIndexed(((index, setDto) {
    final workingIndex = setDto.type == SetType.working ? workingSets : -1;

    final widget = Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: switch (type) {
        ExerciseType.weightAndReps ||
        ExerciseType.weightedBodyWeight ||
        ExerciseType.assistedBodyWeight =>
          WeightRepsWidget(
            index: index,
            workingIndex: workingIndex,
            setDto: setDto as WeightRepsDto,
          ),
        ExerciseType.bodyWeightAndReps => BodyWeightWidget(
            index: index,
            workingIndex: workingIndex,
            setDto: setDto as WeightRepsDto,
          ),
        ExerciseType.duration => DurationWidget(
            index: index,
            workingIndex: workingIndex,
            setDto: setDto as DurationDto,
          ),
        ExerciseType.distanceAndDuration => null,
        ExerciseType.weightAndDistance => null,
      },
    );

    if (setDto.type == SetType.working) {
      workingSets += 1;
    }

    return widget;
  })).toList();

  return widgets.isNotEmpty ? widgets : [const ListStyleEmptyState()];
}
