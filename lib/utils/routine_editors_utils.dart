import 'package:flutter/material.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

import '../dtos/appsync/exercise_dto.dart';
import '../dtos/exercise_log_dto.dart';
import '../enums/exercise_type_enums.dart';
import '../screens/exercise/library/exercise_library_screen.dart';
import '../widgets/routine/editors/pickers/substitute_exercise_picker.dart';
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

void showSubstituteExercisePicker(
    {required BuildContext context,
    required ExerciseLogDto primaryExerciseLog,
    required List<ExerciseDto> otherExercises,
    required Function(ExerciseDto secondaryExercise) onSelected,
    required Function(ExerciseDto secondaryExercise) onRemoved,
    required Function() selectExercisesInLibrary}) {
  displayBottomSheet(
    context: context,
    child: SubstituteExercisePicker(
      title: "Substitute ${primaryExerciseLog.exercise.name} for",
      exercises: otherExercises,
      onSelect: onSelected,
      onRemove: onRemoved,
      onSelectExercisesInLibrary: selectExercisesInLibrary,
    ),
  );
}

void showExercisesInLibrary(
    {required BuildContext context,
    List<ExerciseDto> excludeExercises = const [],
    required void Function(List<ExerciseDto> selectedExercises) onSelected,
    ExerciseType? type,
    MuscleGroupFamily? muscleGroupFamily,
    MuscleGroup? muscleGroup}) async {
  final exercises = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ExerciseLibraryScreen(
            excludeExercises: excludeExercises,
            type: type,
            muscleGroupFamily: muscleGroupFamily,
            muscleGroup: muscleGroup,
          ))) as List<ExerciseDto>?;

  if (context.mounted) {
    if (exercises != null && exercises.isNotEmpty) {
      onSelected.call(exercises);
    }
  }
}
