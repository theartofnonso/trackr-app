import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/utils/sets_utils.dart';

import '../controllers/exercise_and_routine_controller.dart';
import '../dtos/appsync/routine_log_dto.dart';
import 'exercise_logs_utils.dart';
import 'general_utils.dart';
import 'one_rep_max_calculator.dart';

String prepareLogInstruction({required BuildContext context, required RoutineLogDto routineLog, required}) {
  final exerciseLogs = loggedExercises(exerciseLogs: routineLog.exerciseLogs);

  final exerciseAndRoutineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

  final StringBuffer buffer = StringBuffer();

  buffer.writeln(
      "Please analyze my performance in my ${routineLog.name} workout by comparing the sets in each exercise with ones from my previous logs for the same exercise.");

  buffer.writeln();

  for (final currentExerciseLog in exerciseLogs) {

    buffer.writeln(
        "Rep Range for ${currentExerciseLog.exercise.name}: ${currentExerciseLog.minReps} to ${currentExerciseLog.maxReps}");
    List<String> currentSetSummaries = generateSetSummaries(currentExerciseLog);
    buffer.writeln(
        "Current Sets for ${currentExerciseLog.exercise.name} logged on ${currentExerciseLog.createdAt.withoutTime().formattedDayAndMonthAndYear()}: $currentSetSummaries");

    final pastExerciseLogs = exerciseAndRoutineLogController
        .whereExerciseLogsBefore(
            exercise: currentExerciseLog.exercise, date: currentExerciseLog.createdAt.withoutTime())
        .sorted((a, b) => b.createdAt.compareTo(a.createdAt));

    for (final pastExerciseLog in pastExerciseLogs) {
      buffer.writeln(
          "Rep Range for ${currentExerciseLog.exercise.name}: ${pastExerciseLog.minReps} to ${pastExerciseLog.maxReps}");
      List<String> pastSetSummaries = generateSetSummaries(pastExerciseLog);
      buffer.writeln(
          "Past sets for ${currentExerciseLog.exercise.name} logged on ${pastExerciseLog.createdAt.withoutTime().formattedDayAndMonthAndYear()}: $pastSetSummaries");
    }

    final completedPastExerciseLogs = loggedExercises(exerciseLogs: pastExerciseLogs);
    if (completedPastExerciseLogs.isNotEmpty) {
      final previousLog = completedPastExerciseLogs.last;
      final heaviestSetWeight = heaviestWeightInSetForExerciseLog(exerciseLog: previousLog);
      final oneRepMax = average1RM(weight: (heaviestSetWeight).weight, reps: (heaviestSetWeight).reps);

      buffer.writeln("One Rep Max for ${currentExerciseLog.exercise.name}: $oneRepMax");

      buffer.writeln();
    }
  }

  buffer.writeln();

  buffer.writeln("""

          Below is information about different rep ranges and their corresponding training goals and recommended intensity levels:
	              •	1–5 reps: Strength & Power, Heavy (80–90% of 1RM)
	              •	6–12 reps: Hypertrophy (Muscle Growth), Moderate-Heavy (65–80% of 1RM)
	              •	12–20+ reps: Muscular Endurance, Light-Moderate (50–65% of 1RM)

          Please provide feedback on the following aspects of my workout performance:
                1.	Weights Lifted: Analyze the progression or consistency in the weights I’ve used.
    	          2.	Repetitions: Evaluate the number of repetitions performed per set and identify any trends or changes.
    	          3.	Volume Lifted: Calculate the total volume lifted (weight × repetitions) and provide insights into its progression over time.
    	          4.	Number of Sets: Assess the number of sets performed and how it aligns with my overall workout goals.
    	          5.  Rate of perceived exertion: Compare current RPE and previous ones and determine when to increase/decrease weight or adjust reps.
                6.  Using the above guidelines on reps ranges, training goals, intensity levels and my one Rep Max, analyze my training intensity (weight and reps) and provide clear, actionable recommendations on whether the I should increase or decrease the weights.

          Note: All weights are measured in ${weightLabel()}.
          Note: Your report should sound personal.
        """);

  final completeInstructions = buffer.toString();
  return completeInstructions;
}
