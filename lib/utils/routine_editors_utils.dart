import 'package:flutter/material.dart';

import '../dtos/exercise_dto.dart';
import '../dtos/exercise_log_dto.dart';
import '../enums/exercise_type_enums.dart';
import '../screens/exercise/library/exercise_library_screen.dart';
import '../widgets/routine/editors/pickers/alternate_exercise_picker.dart';
import '../widgets/routine/editors/pickers/superset_exercise_log_picker.dart';
import 'dialog_utils.dart';

void showSuperSetExercisePicker(
    {required BuildContext context,
    required ExerciseLogDto firstExerciseLog,
    required List<ExerciseLogDto> otherExerciseLogs,
    required Function(ExerciseLogDto secondExercise) onSelected,
    required Function() selectExercisesInLibrary}) {
  displayBottomSheet(
    context: context,
    child: SuperSetExerciseLogPicker(
      title: "Superset ${firstExerciseLog.exercise.name} with",
      exercises: otherExerciseLogs,
      onSelect: onSelected,
      onSelectExercisesInLibrary: selectExercisesInLibrary,
    ),
  );
}

void showAlternateExercisePicker(
    {required BuildContext context,
      required ExerciseLogDto primaryExerciseLog,
      required List<ExerciseDto> otherExercises,
      required Function(ExerciseDto secondaryExercise) onSelected,
      required Function(ExerciseDto secondaryExercise) onRemoved,
      required Function() selectExercisesInLibrary}) {
  displayBottomSheet(
    context: context,
    child: AlternateExercisePicker(
      title: "Alternate ${primaryExerciseLog.exercise.name} with",
      exercises: otherExercises,
      onSelect: onSelected,
      onRemove: onRemoved,
      onSelectExercisesInLibrary: selectExercisesInLibrary,
    ),
  );
}


void showExercisesInLibrary(
    {required BuildContext context,
    required List<ExerciseDto> exclude,
    required void Function(List<ExerciseDto> selectedExercises) onSelected,
    required bool multiSelect,
    ExerciseType? filter}) async {
  final exercises = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              ExerciseLibraryScreen(preSelectedExercises: exclude, multiSelect: multiSelect, filter: filter)))
      as List<ExerciseDto>?;

  if (context.mounted) {
    if (exercises != null && exercises.isNotEmpty) {
      onSelected.call(exercises);
    }
  }
}
