import 'package:flutter/material.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/widgets/empty_states/double_set_row_empty_state.dart';
import 'package:tracker_app/widgets/routine/preview/exercise_log_widget.dart';

import '../../dtos/exercise_log_dto.dart';
import '../../dtos/set_dto.dart';
import '../../utils/general_utils.dart';
import '../empty_states/single_set_row_empty_state.dart';
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

List<Widget> setsToWidgets({required ExerciseType type, required List<SetDto> sets, PBViewModel? pbViewModel}) {
  Widget emptyState = type == ExerciseType.duration || type == ExerciseType.bodyWeightAndReps
      ? const SingleSetRowEmptyState()
      : const DoubleSetRowEmptyState();

  const margin = EdgeInsets.only(bottom: 6.0);

  final widgets = sets.map(((setDto) {
    final pb = pbViewModel != null && pbViewModel.set == setDto ? pbViewModel : null;

    switch (type) {
      case ExerciseType.weightAndReps:
      case ExerciseType.assistedBodyWeight:
      case ExerciseType.weightedBodyWeight:
        final firstLabel = isDefaultWeightUnit() ? setDto.value1 : toLbs(setDto.value1.toDouble());
        final secondLabel = setDto.value2;
        return DoubleSetRow(first: "$firstLabel", second: "$secondLabel", margin: margin, pbViewModel: pb);
      case ExerciseType.bodyWeightAndReps:
        final label = setDto.value2;
        return SingleSetRow(label: "$label", margin: margin);
      case ExerciseType.duration:
        final label = Duration(milliseconds: setDto.value1.toInt()).secondsOrMinutesOrHours();
        return SingleSetRow(label: label, margin: margin, pbViewModel: pb);
    }
  })).toList();

  return widgets.isNotEmpty ? widgets : [emptyState];
}
