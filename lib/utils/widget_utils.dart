import 'package:flutter/cupertino.dart';

import '../dtos/exercise_log_dto.dart';
import '../widgets/routine/editors/superset_exercise_log_picker.dart';
import 'dialog_utils.dart';

void showSuperSetExercisePicker(
    {required BuildContext context,
    required ExerciseLogDto firstExerciseLog,
    required List<ExerciseLogDto> exerciseLogs,
    required Function(ExerciseLogDto secondExercise) onSelected,
    required Function() selectExercisesInLibrary}) {

  displayBottomSheet(
    context: context,
    child: SuperSetExerciseLogPicker(
      title: "Superset ${firstExerciseLog.exercise.name} with",
      exercises: exerciseLogs,
      onSelect: onSelected,
      onSelectExercisesInLibrary: selectExercisesInLibrary,
    ),
  );
}
