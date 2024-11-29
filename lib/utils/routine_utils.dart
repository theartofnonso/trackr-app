import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/routine_preview_type_enum.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/extensions/week_days_extension.dart';
import 'package:tracker_app/utils/string_utils.dart';

import '../dtos/appsync/routine_log_dto.dart';
import '../dtos/appsync/routine_template_dto.dart';
import '../dtos/exercise_log_dto.dart';
import '../dtos/viewmodels/exercise_log_view_model.dart';
import '../enums/activity_type_enums.dart';
import '../enums/routine_schedule_type_enums.dart';
import '../enums/template_changes_type_message_enums.dart';
import '../screens/exercise/reorder_exercises_screen.dart';
import 'exercise_logs_utils.dart';
import 'general_utils.dart';

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
  if (isEditor) {
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

Map<String, List<ExerciseLogDto>> groupExerciseLogsByExerciseId({required List<RoutineLogDto> routineLogs}) {
  final exerciseLogs = routineLogs.expand((log) => log.exerciseLogs);
  return groupBy(exerciseLogs, (exerciseLog) => exerciseLog.exercise.id);
}

String superSetId({required ExerciseLogDto firstExerciseLog, required ExerciseLogDto secondExerciseLog}) {
  return "superset_id_${firstExerciseLog.exercise.id}_${secondExerciseLog.exercise.id}";
}

String scheduledDaysSummary({required RoutineTemplateDto template, bool showFullName = false}) {
  if (template.scheduleType == RoutineScheduleType.days) {
    final scheduledDays = template.scheduledDays;

    if (scheduledDays.isNotEmpty) {
      final scheduledDayNames = scheduledDays.map((day) => showFullName ? day.longName : day.shortName).toList();

      return scheduledDays.length == 7 ? "Everyday" : "Every ${joinWithAnd(items: scheduledDayNames)}";
    }
  }

  return "No schedule";
}

List<ExerciseLogViewModel> exerciseLogsToViewModels({required List<ExerciseLogDto> exerciseLogs}) {
  return exerciseLogs.map((exerciseLog) {
    return ExerciseLogViewModel(
        exerciseLog: exerciseLog,
        superSet: whereOtherExerciseInSuperSet(firstExercise: exerciseLog, exercises: exerciseLogs));
  }).toList();
}

String copyRoutineAsText(
    {required RoutinePreviewType routineType,
    required String name,
    required String notes,
    DateTime? dateTime,
    required List<ExerciseLogDto> exerciseLogs}) {
  StringBuffer routineText = StringBuffer();

  routineText.writeln(name);

  if (notes.isNotEmpty) {
    routineText.writeln("\n Notes: $notes");
  }
  if (routineType == RoutinePreviewType.log) {
    if (dateTime != null) {
      routineText.writeln(dateTime.formattedDayAndMonthAndYear());
    }
  }

  for (var exerciseLog in exerciseLogs) {
    var exercise = exerciseLog.exercise;
    routineText.writeln("\n- Exercise: ${exercise.name}");
    routineText.writeln("  Muscle Group: ${exercise.primaryMuscleGroup.name}");
    if (exerciseLog.notes.isNotEmpty) {
      routineText.writeln("  Notes: ${exerciseLog.notes}");
    }
    for (var i = 0; i < exerciseLog.sets.length; i++) {
      switch (exerciseLog.exercise.type) {
        case ExerciseType.weights:
          routineText.writeln("   • Set ${i + 1}: ${exerciseLog.sets[i].summary()}");
          break;
        case ExerciseType.bodyWeight:
          routineText.writeln("   • Set ${i + 1}: ${exerciseLog.sets[i].summary()}");
          break;
        case ExerciseType.duration:
          routineText.writeln("   • Set ${i + 1}: ${exerciseLog.sets[i].summary()}");
          break;
      }
    }
  }
  return routineText.toString();
}

int calculateCalories({required Duration duration, required double bodyWeight, required ActivityType activity}) {
  const oxygenInMils = 3.5;
  final bodyWeightInKG = isDefaultWeightUnit() ? bodyWeight : toKg(bodyWeight.toDouble());
  final caloriesPerMinute = (activity.met * bodyWeightInKG * oxygenInMils) / 200;
  return (caloriesPerMinute * duration.inMinutes).floor();
}
