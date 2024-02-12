import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/routine_preview_type_enum.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/widgets/empty_states/double_set_row_empty_state.dart';

import '../dtos/exercise_log_dto.dart';
import '../dtos/pb_dto.dart';
import '../dtos/routine_log_dto.dart';
import '../dtos/set_dto.dart';
import '../enums/template_changes_type_message_enums.dart';
import '../screens/reorder_exercises_screen.dart';
import 'exercise_logs_utils.dart';
import 'general_utils.dart';
import '../widgets/empty_states/single_set_row_empty_state.dart';
import '../widgets/routine/preview/set_rows/single_set_row.dart';
import '../widgets/routine/preview/set_rows/double_set_row.dart';

Future<List<ExerciseLogDto>?> reOrderExerciseLogs(
    {required BuildContext context, required List<ExerciseLogDto> exerciseLogs}) async {
  return await Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ReOrderExercisesScreen(exercises: exerciseLogs)))
      as List<ExerciseLogDto>?;
}

List<ExerciseLogDto> whereOtherExerciseLogsExcept(
    {required ExerciseLogDto exerciseLog, required List<ExerciseLogDto> others}) {
  return others.where((procedure) => procedure.id != exerciseLog.id && procedure.superSetId.isEmpty).toList();
}

List<TemplateChange> checkForChanges(
    {required List<ExerciseLogDto> exerciseLog1, required List<ExerciseLogDto> exerciseLog2, bool isEditor = true}) {
  List<TemplateChange?> unsavedChangesMessage = [];

  /// Check if [ExerciseLogDto] have been added or removed
  final differentExercisesLengthMessage =
      hasDifferentExerciseLogsLength(exerciseLogs1: exerciseLog1, exerciseLogs2: exerciseLog2);
  unsavedChangesMessage.add(differentExercisesLengthMessage);

  /// Check if [ExerciseLogDto] has been re-ordered
  final differentExercisesOrderMessage =
      hasReOrderedExercises(exerciseLogs1: exerciseLog1, exerciseLogs2: exerciseLog2);
  unsavedChangesMessage.add(differentExercisesOrderMessage);

  /// Check if [SetDto]'s have been added or removed
  final differentSetsLengthMessage = hasDifferentSetsLength(exerciseLogs1: exerciseLog1, exerciseLogs2: exerciseLog2);
  unsavedChangesMessage.add(differentSetsLengthMessage);

  /// Check if [ExerciseType] for [Exercise] in [ExerciseLogDto] has been changed
  final differentExerciseTypesChangeMessage =
      hasExercisesChanged(exerciseLogs1: exerciseLog1, exerciseLogs2: exerciseLog2);
  unsavedChangesMessage.add(differentExerciseTypesChangeMessage);

  /// Check if superset in [ExerciseLogDto] has been changed i.e. added or removed
  final differentSuperSetIdsChangeMessage =
      hasSuperSetIdChanged(exerciseLogs1: exerciseLog1, exerciseLogs2: exerciseLog2);
  unsavedChangesMessage.add(differentSuperSetIdsChangeMessage);

  /// Check if set values have been changed
  if(isEditor) {
    final updatedSetValuesChangeMessage = hasSetValueChanged(exerciseLogs1: exerciseLog1, exerciseLogs2: exerciseLog2);
    unsavedChangesMessage.add(updatedSetValuesChangeMessage);
  }

  return unsavedChangesMessage.whereType<TemplateChange>().toList();
}

ExerciseLogDto? whereOtherExerciseInSuperSet(
    {required ExerciseLogDto firstExercise, required List<ExerciseLogDto> exercises}) {
  return exercises.firstWhereOrNull((exercise) =>
      exercise.superSetId.isNotEmpty &&
      exercise.superSetId == firstExercise.superSetId &&
      exercise.exercise.id != firstExercise.exercise.id);
}

List<Widget> setsToWidgets(
    {required ExerciseType type,
    required List<SetDto> sets,
    List<PBDto> pbs = const [],
    required RoutinePreviewType routinePreviewType}) {
  final durationTemplate = Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: Center(
      child: Text("Timer will be available in log mode",
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.white70)),
    ),
  );

  Widget emptyState;

  if (withWeightsOnly(type: type)) {
    emptyState = const DoubleSetRowEmptyState();
  } else {
    if (withDurationOnly(type: type)) {
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
        final firstLabel = weightWithConversion(value: setDto.weightValue());
        final secondLabel = setDto.repsValue();
        return DoubleSetRow(first: "$firstLabel", second: "$secondLabel", margin: margin, pbs: pbsForSet);
      case ExerciseType.bodyWeight:
        final label = setDto.repsValue();
        return SingleSetRow(label: "$label", margin: margin);
      case ExerciseType.duration:
        if (routinePreviewType == RoutinePreviewType.template) {
          return durationTemplate;
        }
        final label = Duration(milliseconds: setDto.durationValue().toInt()).hmsAnalog();
        return SingleSetRow(label: label, margin: margin, pbs: pbsForSet);
    }
  })).toList();

  return widgets.isNotEmpty ? widgets : [emptyState];
}

Map<DateTimeRange, List<RoutineLogDto>> groupRoutineLogsByWeek({required List<RoutineLogDto> routineLogs, DateTime? endDate}) {
  final map = <DateTimeRange, List<RoutineLogDto>>{};

  DateTime startDate = routineLogs.firstOrNull?.createdAt ?? DateTime.now();

  DateTime lastDate = endDate ?? routineLogs.lastOrNull?.createdAt ?? DateTime.now();

  List<DateTimeRange> weekRanges = generateWeekRangesFrom(startDate: startDate, endDate: lastDate);

  for (final weekRange in weekRanges) {
    map[weekRange] = routineLogs.where((log) => log.createdAt.isBetweenRange(range: weekRange)).toList();
  }

  return map;
}

Map<DateTimeRange, List<RoutineLogDto>> groupRoutineLogsByMonth({required List<RoutineLogDto> routineLogs}) {
  final map = <DateTimeRange, List<RoutineLogDto>>{};

  DateTime startDate = routineLogs.firstOrNull?.createdAt ?? DateTime.now();

  DateTime lastDate = routineLogs.lastOrNull?.createdAt ?? DateTime.now();

  List<DateTimeRange> monthRanges = generateMonthRangesFrom(startDate: startDate, endDate: lastDate);

  for (final monthRange in monthRanges) {
    map[monthRange] = routineLogs.where((log) => log.createdAt.isBetweenRange(range: monthRange)).toList();
  }
  return map;
}

Map<String, List<ExerciseLogDto>> groupRoutineLogsByExerciseLogId({required List<RoutineLogDto> routineLogs}) {
  List<ExerciseLogDto> exerciseLogs = routineLogs.expand((log) => log.exerciseLogs).toList();
  return groupBy(exerciseLogs, (exerciseLog) => exerciseLog.exercise.id);
}

Map<ExerciseType, List<ExerciseLogDto>> groupRoutineLogsByExerciseType({required List<RoutineLogDto> routineLogs}) {
  List<ExerciseLogDto> exerciseLogs = routineLogs.expand((log) => log.exerciseLogs).toList();
  return groupBy(exerciseLogs, (exerciseLog) => exerciseLog.exercise.type);
}

String superSetId({required ExerciseLogDto firstExerciseLog, required ExerciseLogDto secondExerciseLog}) {
  return "superset_id_${firstExerciseLog.exercise.id}_${secondExerciseLog.exercise.id}";
}
