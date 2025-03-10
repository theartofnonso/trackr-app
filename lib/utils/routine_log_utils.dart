import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/utils/sets_utils.dart';
import 'package:tracker_app/utils/string_utils.dart';

import '../controllers/exercise_and_routine_controller.dart';
import '../dtos/appsync/routine_log_dto.dart';
import '../dtos/set_dtos/reps_dto.dart';
import '../dtos/set_dtos/weight_and_reps_dto.dart';
import '../enums/exercise_type_enums.dart';
import 'exercise_logs_utils.dart';
import 'general_utils.dart';

String prepareLogInstruction({required BuildContext context, required RoutineLogDto routineLog, required}) {
  final exerciseLogs = loggedExercises(exerciseLogs: routineLog.exerciseLogs);

  final exerciseAndRoutineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

  final StringBuffer buffer = StringBuffer();

  for (final currentExerciseLog in exerciseLogs) {
    buffer.writeln("Exercise Id for ${currentExerciseLog.exercise.name}: ${currentExerciseLog.exercise.id}");

    List<String> currentSetSummaries = generateSetSummaries(currentExerciseLog);
    buffer.writeln(
        "Current Sets for ${currentExerciseLog.exercise.name} logged on ${currentExerciseLog.createdAt.withoutTime().formattedDayAndMonthAndYear()}: $currentSetSummaries");

    final pastExerciseLogs = exerciseAndRoutineLogController
        .whereExerciseLogsBefore(
            exercise: currentExerciseLog.exercise, date: currentExerciseLog.createdAt.withoutTime())
        .sorted((a, b) => b.createdAt.compareTo(a.createdAt));

    for (final pastExerciseLog in pastExerciseLogs) {
      List<String> pastSetSummaries = generateSetSummaries(pastExerciseLog);
      buffer.writeln(
          "Past sets for ${currentExerciseLog.exercise.name} logged on ${pastExerciseLog.createdAt.withoutTime().formattedDayAndMonthAndYear()}: $pastSetSummaries");
    }

    final exerciseType = currentExerciseLog.exercise.type;

    final previousSets = Provider.of<ExerciseAndRoutineController>(context, listen: false)
        .whereSetsForExercise(exercise: currentExerciseLog.exercise);

    /// Determine rep range using historic training data
    final reps = previousSets.map((set) {
      return switch (exerciseType) {
        ExerciseType.weights => (set as WeightAndRepsSetDto).reps,
        ExerciseType.bodyWeight => (set as RepsSetDto).reps,
        ExerciseType.duration => 0,
      };
    }).toList();

    final typicalRepRange = determineTypicalRepRange(reps: reps);

    buffer.writeln("Rep range for ${currentExerciseLog.exercise.name}: $typicalRepRange");
  }

  buffer.writeln();

  final muscleGroups = routineLog.exerciseLogs.map((exerciseLog) => exerciseLog.exercise.primaryMuscleGroup).toList();

  final trainingPrompt = generateTrainingPrompt(muscleGroups: muscleGroups);

  buffer.writeln(trainingPrompt);

  final completeInstructions = buffer.toString();

  return completeInstructions;
}

String generateTrainingPrompt({required List<MuscleGroup> muscleGroups}) {
  return """
          Analyse my training ${pluralize(word: "log", count: muscleGroups.length)} for ${joinWithAnd(items: muscleGroups.map((muscleGroup) => muscleGroup.name).toList())}.

          Considering my rep ranges and RPE, do I need to increase or decrease my working weights or reps?

          Please make your feedback personal, explanatory, and motivating.

          Note: All weights are measured in ${weightLabel()}.

        """;
}