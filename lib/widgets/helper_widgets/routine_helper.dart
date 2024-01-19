import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/routine_preview_type_enum.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/widgets/empty_states/double_set_row_empty_state.dart';

import '../../dtos/exercise_log_dto.dart';
import '../../dtos/pb_dto.dart';
import '../../dtos/set_dto.dart';
import '../../utils/general_utils.dart';
import '../empty_states/single_set_row_empty_state.dart';
import '../routine/preview/set_rows/single_set_row.dart';
import '../routine/preview/set_rows/double_set_row.dart';

ExerciseLogDto? whereOtherExerciseInSuperSet({required ExerciseLogDto firstExercise, required List<ExerciseLogDto> exercises}) {
  return exercises.firstWhere((exercise) =>
      exercise.superSetId.isNotEmpty &&
      exercise.superSetId == firstExercise.superSetId &&
      exercise.exercise.id != firstExercise.exercise.id);
}

List<Widget> setsToWidgets(
    {required ExerciseType type,
    required List<SetDto> sets,
    List<PBDto> pbs = const [],
    required RoutinePreviewType routinePreviewType}) {
  final durationTemplate = Center(
    child: Text("Timer will be available in log mode",
        style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.white70)),
  );

  Widget emptyState;

  if (type == ExerciseType.weights) {
    emptyState = const DoubleSetRowEmptyState();
  } else {
    if (type == ExerciseType.duration) {
      emptyState = durationTemplate;
    } else {
      emptyState = const SingleSetRowEmptyState();
    }
  }

  const margin = EdgeInsets.only(bottom: 6.0);

  final pbsBySet = groupBy(pbs, (pb) => pb.set);

  final widgets = sets.map(((setDto) {
    final pbsForSet = pbsBySet[setDto] ?? [];

    switch (type) {
      case ExerciseType.weights:
        final firstLabel = weightWithConversion(value: setDto.value1);
        final secondLabel = setDto.value2;
        return DoubleSetRow(first: "$firstLabel", second: "$secondLabel", margin: margin, pbs: pbsForSet);
      case ExerciseType.bodyWeight:
        final label = setDto.value2;
        return SingleSetRow(label: "$label", margin: margin);
      case ExerciseType.duration:
        if (routinePreviewType == RoutinePreviewType.template) {
          return durationTemplate;
        }
        final label = Duration(milliseconds: setDto.value1.toInt()).hmsAnalog();
        return SingleSetRow(label: label, margin: margin, pbs: pbsForSet);
    }
  })).toList();

  return widgets.isNotEmpty ? widgets : [emptyState];
}
