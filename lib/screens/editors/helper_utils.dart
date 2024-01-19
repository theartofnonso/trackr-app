import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/screens/reorder_exercises_screen.dart';

import '../../dtos/exercise_log_dto.dart';
import '../../dtos/template_changes_messages_dto.dart';
import '../../controllers/exercise_log_controller.dart';

Future<List<ExerciseLogDto>?> reOrderExerciseLogs({required BuildContext context, required List<ExerciseLogDto> exerciseLogs}) async {
  return await Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ReOrderExercisesScreen(exercises: exerciseLogs)))
      as List<ExerciseLogDto>?;
}

List<ExerciseLogDto> whereOtherExerciseLogsExcept(
    {required BuildContext context, required ExerciseLogDto firstProcedure}) {
  return Provider.of<ExerciseLogController>(context, listen: false)
      .exerciseLogs
      .where((procedure) => procedure.id != firstProcedure.id && procedure.superSetId.isEmpty)
      .toList();
}

List<TemplateChangesMessageDto> checkForChanges(
    {required BuildContext context,
    required List<ExerciseLogDto> exerciseLog1,
    required List<ExerciseLogDto> exerciseLog2}) {
  List<TemplateChangesMessageDto> unsavedChangesMessage = [];
  final procedureProvider = Provider.of<ExerciseLogController>(context, listen: false);

  /// Check if [ExerciseLogDto] have been added or removed
  final differentExercisesLengthMessage =
      procedureProvider.hasDifferentExerciseLogsLength(exerciseLog1: exerciseLog1, exerciseLog2: exerciseLog2);
  if (differentExercisesLengthMessage != null) {
    unsavedChangesMessage.add(differentExercisesLengthMessage);
  }

  /// Check if [ExerciseLogDto] has been re-ordered
  final differentExercisesOrderMessage =
      procedureProvider.hasReOrderedExercises(exerciseLog1: exerciseLog1, exerciseLog2: exerciseLog2);
  if (differentExercisesOrderMessage != null) {
    unsavedChangesMessage.add(differentExercisesOrderMessage);
  }

  /// Check if [SetDto]'s have been added or removed
  final differentSetsLengthMessage =
      procedureProvider.hasDifferentSetsLength(exerciseLog1: exerciseLog1, exerciseLog2: exerciseLog2);
  if (differentSetsLengthMessage != null) {
    unsavedChangesMessage.add(differentSetsLengthMessage);
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

  return unsavedChangesMessage;
}
