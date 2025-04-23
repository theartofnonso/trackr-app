import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/appsync/routine_plan_dto.dart';
import 'package:tracker_app/dtos/appsync/routine_template_dto.dart';
import 'package:tracker_app/screens/editors/routine_template_library_screen.dart';

import '../dtos/appsync/exercise_dto.dart';
import '../dtos/exercise_log_dto.dart';
import '../enums/exercise_type_enums.dart';
import '../screens/exercise/library/exercise_library_screen.dart';
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
      title: "Superset ${firstExerciseLog.exercise.name} with . . .",
      exercises: otherExerciseLogs,
      onSelect: onSelected,
      onSelectExercisesInLibrary: selectExercisesInLibrary,
    ),
  );
}

void showExercisesInLibrary(
    {required BuildContext context,
    required List<ExerciseDto> exercisesToExclude,
    required void Function(List<ExerciseDto> selectedExercises) onSelected,
    ExerciseType? type}) async {
  final selectedExercises = await Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ExerciseLibraryScreen(excludeExercises: exercisesToExclude, type: type,)))
      as List<ExerciseDto>?;

  if (context.mounted) {
    if (selectedExercises != null && selectedExercises.isNotEmpty) {
      onSelected.call(selectedExercises);
    }
  }
}

void showTemplatesInLibrary(
    {required BuildContext context,
      RoutinePlanDto? planDto,
      required List<RoutineTemplateDto> templatesToExclude,
      required void Function(List<RoutineTemplateDto> selectedTemplates) onSelected}) async {
  final selectedTemplates = await Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => RoutineTemplateLibraryScreen(excludeTemplates: templatesToExclude, planDto: planDto)))
  as List<RoutineTemplateDto>?;

  if (context.mounted) {
    if (selectedTemplates != null && selectedTemplates.isNotEmpty) {
      onSelected.call(selectedTemplates);
    }
  }
}
