import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/utils/sets_utils.dart';

import '../controllers/exercise_and_routine_controller.dart';
import '../dtos/appsync/routine_log_dto.dart';
import 'exercise_logs_utils.dart';
import 'general_utils.dart';

String prepareLogInstruction({required BuildContext context, required RoutineLogDto routineLog, required}) {
  final exerciseLogs = loggedExercises(exerciseLogs: routineLog.exerciseLogs);

  final exerciseAndRoutineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

  final StringBuffer buffer = StringBuffer();

  buffer.writeln(
      "Please analyze my performance in my ${routineLog.name} workout by comparing the sets in each exercise with ones from my previous logs for the same exercise.");

  buffer.writeln();

  for (final currentExerciseLog in exerciseLogs) {
    List<String> currentSetSummaries = generateSetSummaries(currentExerciseLog);
    buffer.writeln("Current Sets for ${currentExerciseLog.exercise.name} logged on ${currentExerciseLog.createdAt.withoutTime().formattedDayAndMonthAndYear()}: $currentSetSummaries");

    final pastExerciseLogs = exerciseAndRoutineLogController
        .whereExerciseLogsBefore(
            exercise: currentExerciseLog.exercise, date: currentExerciseLog.createdAt.withoutTime())
        .sorted((a, b) => b.createdAt.compareTo(a.createdAt));

    for (final pastExerciseLog in pastExerciseLogs) {
      List<String> pastSetSummaries = generateSetSummaries(pastExerciseLog);
      buffer.writeln(
          "Past sets for ${currentExerciseLog.exercise.name} logged on ${pastExerciseLog.createdAt.withoutTime().formattedDayAndMonthAndYear()}: $pastSetSummaries");
    }

    buffer.writeln();
  }

  buffer.writeln();

  buffer.writeln("""
          Please provide feedback on the following aspects of my workout performance:
                1.	Weights Lifted: Analyze the progression or consistency in the weights I’ve used.
    	          2.	Repetitions: Evaluate the number of repetitions performed per set and identify any trends or changes.
    	          3.	Volume Lifted: Calculate the total volume lifted (weight × repetitions) and provide insights into its progression over time.
    	          4.	Number of Sets: Assess the number of sets performed and how it aligns with my overall workout goals.
          Note: All weights are measured in ${weightLabel()}.
          Note: Your report should sound personal.
        """);

  final completeInstructions = buffer.toString();
  return completeInstructions;
}
