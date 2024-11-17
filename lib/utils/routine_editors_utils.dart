import 'package:flutter/material.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

import '../dtos/exercise_dto.dart';
import '../dtos/exercise_log_dto.dart';
import '../enums/exercise/exercise_metrics_enums.dart';
import '../screens/exercise/library/exercise_library_screen.dart';
import '../widgets/routine/editors/pickers/substitute_exercise_picker.dart';
import '../widgets/routine/editors/pickers/superset_exercise_log_picker.dart';
import 'dialog_utils.dart';

void showSuperSetExercisePicker(
    {required BuildContext context,
    required ExerciseLogDTO firstExerciseLog,
    required List<ExerciseLogDTO> otherExerciseLogs,
    required Function(ExerciseLogDTO secondExercise) onSelected,
    required Function() selectExercisesInLibrary}) {
  displayBottomSheet(
    context: context,
    child: SuperSetExerciseLogPicker(
      title: "Superset ${firstExerciseLog.exerciseVariant.name} with",
      exercises: otherExerciseLogs,
      onSelect: onSelected,
      onSelectExercisesInLibrary: selectExercisesInLibrary,
    ),
  );
}

void showSubstituteExercisePicker(
    {required BuildContext context,
    required ExerciseLogDTO primaryExerciseLog,
    required List<ExerciseDTO> otherExercises,
    required Function(ExerciseDTO secondaryExercise) onSelected,
    required Function(ExerciseDTO secondaryExercise) onRemoved,
    required Function() selectExercisesInLibrary}) {
  displayBottomSheet(
    context: context,
    child: SubstituteExercisePicker(
      title: "Substitute ${primaryExerciseLog.exerciseVariant.name} for",
      exercises: otherExercises,
      onSelect: onSelected,
      onRemove: onRemoved,
      onSelectExercisesInLibrary: selectExercisesInLibrary,
    ),
  );
}

void showExercisesInLibrary(
    {required BuildContext context,
    List<String> exercisesToExclude = const [],
    required void Function(List<ExerciseDTO> selectedExercises) onSelected,
    ExerciseMetric? type,
    MuscleGroup? muscleGroup}) async {
  final exercises = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ExerciseLibraryScreen(
            exercisesToExclude: exercisesToExclude,
            exerciseMetric: type,
            muscleGroup: muscleGroup,
          ))) as List<ExerciseDTO>?;

  if (context.mounted) {
    if (exercises != null && exercises.isNotEmpty) {
      onSelected.call(exercises);
    }
  }
}
