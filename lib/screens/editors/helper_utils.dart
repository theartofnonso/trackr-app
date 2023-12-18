import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/screens/reorder_exercises_screen.dart';

import '../../dtos/exercise_log_dto.dart';
import '../../dtos/unsaved_changes_messages_dto.dart';
import '../../providers/exercise_log_provider.dart';

void reOrderExercises({required BuildContext context}) async {
  final provider = Provider.of<ExerciseLogProvider>(context, listen: false);
  final exercises = List<ExerciseLogDto>.from(provider.exerciseLogs);
  final reOrderedList = await Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ReOrderExercisesScreen(exercises: exercises)))
      as List<ExerciseLogDto>?;

  if (reOrderedList != null) {
    if (context.mounted) {
      provider.reOrderExerciseLogs(reOrderedList: reOrderedList);
    }
  }
}

void removeExerciseFromSuperSet({required BuildContext context, required String superSetId}) {
  Provider.of<ExerciseLogProvider>(context, listen: false).removeSuperSetForLogs(superSetId: superSetId);
}

void removeExercise({required BuildContext context, required String exerciseId}) {
  Provider.of<ExerciseLogProvider>(context, listen: false).removeExerciseLog(logId: exerciseId);
}

List<ExerciseLogDto> whereOtherExerciseLogsExcept(
    {required BuildContext context, required ExerciseLogDto firstProcedure}) {
  return Provider.of<ExerciseLogProvider>(context, listen: false)
      .exerciseLogs
      .where((procedure) => procedure.id != firstProcedure.id && procedure.superSetId.isEmpty)
      .toList();
}

List<UnsavedChangesMessageDto> checkForChanges(
    {required BuildContext context,
    required List<ExerciseLogDto> exerciseLog1,
    required List<ExerciseLogDto> exerciseLog2}) {
  List<UnsavedChangesMessageDto> unsavedChangesMessage = [];
  final procedureProvider = Provider.of<ExerciseLogProvider>(context, listen: false);

  /// Check if [ExerciseLogDto] have been added or removed
  final differentExercisesChangeMessage =
      procedureProvider.hasDifferentExerciseLogsLength(exerciseLog1: exerciseLog1, exerciseLog2: exerciseLog2);
  if (differentExercisesChangeMessage != null) {
    unsavedChangesMessage.add(differentExercisesChangeMessage);
  }

  /// Check if [ExerciseLogDto] has been re-ordered
  final differentExercisesOrderMessage =
      procedureProvider.hasReOrderedExercises(exerciseLog1: exerciseLog1, exerciseLog2: exerciseLog2);
  if (differentExercisesOrderMessage != null) {
    unsavedChangesMessage.add(differentExercisesOrderMessage);
  }

  /// Check if [SetDto]'s have been added or removed
  final differentSetsChangeMessage =
      procedureProvider.hasDifferentSetsLength(exerciseLog1: exerciseLog1, exerciseLog2: exerciseLog2);
  if (differentSetsChangeMessage != null) {
    unsavedChangesMessage.add(differentSetsChangeMessage);
  }

  /// Check if [ExerciseType] for [Exercise] in [ExerciseLogDto] has been changed
  final differentExerciseTypesChangeMessage =
      procedureProvider.hasExercisesChanged(exerciseLog1: exerciseLog1, exerciseLog2: exerciseLog2);
  if (differentExerciseTypesChangeMessage != null) {
    unsavedChangesMessage.add(differentExerciseTypesChangeMessage);
  }

  /// Check if superset in [ExerciseLogDto] has been changed
  final differentSuperSetIdsChangeMessage =
      procedureProvider.hasSuperSetIdChanged(exerciseLog1: exerciseLog1, exerciseLog2: exerciseLog2);
  if (differentSuperSetIdsChangeMessage != null) {
    unsavedChangesMessage.add(differentSuperSetIdsChangeMessage);
  }

  /// Check if [SetDto] value has been changed
  final differentSetValueChangeMessage =
      procedureProvider.hasSetValueChanged(exerciseLog1: exerciseLog1, exerciseLog2: exerciseLog2);
  if (differentSetValueChangeMessage != null) {
    unsavedChangesMessage.add(differentSetValueChangeMessage);
  }
  return unsavedChangesMessage;
}
