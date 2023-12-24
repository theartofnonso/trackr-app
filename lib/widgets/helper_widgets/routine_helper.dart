import 'package:flutter/material.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/extensions/duration_extension.dart';

import '../../dtos/exercise_log_dto.dart';
import '../../dtos/set_dto.dart';
import '../../utils/general_utils.dart';
import '../empty_states/list_tile_empty_state.dart';
import '../routine/preview/set_rows/single_set_row.dart';
import '../routine/preview/set_rows/double_set_row.dart';

ExerciseLogDto? whereOtherExerciseInSuperSet(
    {required ExerciseLogDto firstExercise, required List<ExerciseLogDto> exercises}) {
  for (var exercise in exercises) {
    bool isSameSuperset = exercise.superSetId.isNotEmpty && exercise.superSetId == firstExercise.superSetId;
    bool isDifferentProcedure = exercise.exercise.id != firstExercise.exercise.id;

    if (isSameSuperset && isDifferentProcedure) {
      return exercise;
    }
  }

  return null; // Explicitly return null if no matching procedure is found
}

List<Widget> setsToWidgets({required ExerciseType type, required List<SetDto> sets}) {
  const margin = EdgeInsets.only(bottom: 6.0);

  final widgets = sets.map(((setDto) {
    switch (type) {
      case ExerciseType.weightAndReps:
      case ExerciseType.assistedBodyWeight:
      case ExerciseType.weightedBodyWeight:
        final firstLabel = isDefaultWeightUnit() ? setDto.value1 : toLbs(setDto.value1.toDouble());
        final secondLabel = setDto.value2;
        return DoubleSetRow(first: "$firstLabel", second: "$secondLabel", margin: margin);
      case ExerciseType.bodyWeightAndReps:
        final label = setDto.value2;
        return SingleSetRow(label: "$label", margin: margin);
      case ExerciseType.duration:
        final label = Duration(milliseconds: setDto.value1.toInt()).secondsOrMinutesOrHours();
        return SingleSetRow(label: label, margin: margin);
      case ExerciseType.durationAndDistance:
        final firstLabel = Duration(milliseconds: setDto.value1.toInt()).secondsOrMinutesOrHours();
        final secondLabel = isDefaultDistanceUnit()
            ? setDto.value2
            : toKM(setDto.value2.toDouble(), type: ExerciseType.durationAndDistance);
        return DoubleSetRow(first: firstLabel, second: "$secondLabel", margin: margin);
      case ExerciseType.weightAndDistance:
        final firstLabel = isDefaultWeightUnit() ? setDto.value1 : toLbs(setDto.value1.toDouble());
        final secondLabel = isDefaultDistanceUnit()
            ? setDto.value2
            : toKM(setDto.value2.toDouble(), type: ExerciseType.weightAndDistance);
        return DoubleSetRow(first: "$firstLabel", second: "$secondLabel", margin: margin);
    }
  })).toList();

  return widgets.isNotEmpty ? widgets : [const ListTileEmptyState()];
}
