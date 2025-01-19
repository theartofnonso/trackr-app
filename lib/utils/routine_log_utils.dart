import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/utils/sets_utils.dart';
import 'package:tracker_app/utils/string_utils.dart';

import '../controllers/exercise_and_routine_controller.dart';
import '../dtos/appsync/routine_log_dto.dart';
import '../enums/training_goal_enums.dart';
import 'exercise_logs_utils.dart';
import 'general_utils.dart';
import 'one_rep_max_calculator.dart';

String prepareLogInstruction(
    {required BuildContext context, required RoutineLogDto routineLog, required, required TrainingGoal trainingGoal}) {
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

    final heaviestSetWeight = heaviestWeightInSetForExerciseLog(exerciseLog: exerciseLogs.last);
    final oneRepMax = average1RM(weight: (heaviestSetWeight).weight, reps: (heaviestSetWeight).reps);

    buffer.writeln("One Rep Max for ${currentExerciseLog.exercise.name}: $oneRepMax");
  }

  buffer.writeln();

  final muscleGroups = routineLog.exerciseLogs.map((exerciseLog) => exerciseLog.exercise.primaryMuscleGroup).toList();

  final trainingPrompt = generateTrainingPrompt(trainingGoal: trainingGoal, muscleGroups: muscleGroups);

  buffer.writeln(trainingPrompt);

  final completeInstructions = buffer.toString();

  return completeInstructions;
}

String generateTrainingPrompt({required TrainingGoal trainingGoal, required List<MuscleGroup> muscleGroups}) {
  return """
          I’m currently focused on achieving ${trainingGoal.displayName} for my ${joinWithAnd(items: muscleGroups.map((muscleGroup) => muscleGroup.name).toList())}.

          Below is information about different rep ranges and their corresponding training goals and recommended intensity levels:
	              •	1–5 reps is for Strength with 80–90% of my 1RM
	              •	6–12 reps is for Hypertrophy (Muscle Growth) with 65–80% of my 1RM
	              •	12–20+ reps is for Muscular Endurance with 50–65% of my 1RM

          Please provide feedback on the following metrics in my training performance:
                1.	Weights Lifted: Analyze the progression and assess whether the weights are appropriate for ${trainingGoal.displayName} (e.g., 65–80% of 1RM for hypertrophy) and suggest adjustments if necessary.
    	          2.	Repetitions: Determine if my rep ranges align with ${trainingGoal.displayName} and recommend changes if I’m consistently outside the target range.
    	          3.	Volume Lifted: Calculate the total volume lifted (weight × repetitions) and provide insights into its progression over time.
    	          4.	Number of Sets: Assess the number of sets performed and their suitability for ${trainingGoal.displayName} .
    	          5.  Rate of perceived exertion: Compare my current and previous RPE values, using the idea that RPE indicates how many reps I could still perform before failure. If RPE is consistently low (e.g., 1–5), it might be time to add weight or increase reps. If it’s often high (8–10), consider reducing the load or increasing rest. Use these insights to determine whether to push harder, maintain, or scale back to optimize training intensity. Also evaluate whether my RPE aligns with ${trainingGoal.displayName}.
                6.  Based on the recommended rep ranges, training goals, intensity levels, and my current one-rep max, evaluate my training intensity (weight and reps) and provide specific, actionable recommendations on whether I should increase or decrease my working weights and reps for ${trainingGoal.displayName}.

          Note: All weights are measured in ${weightLabel()}.
          Note: Ensure your feedback is ${trainingGoal.displayName}-specific and actionable. If my performance does not align with ${trainingGoal.displayName}, provide clear suggestions to correct course.
	        Note: Make the feedback sound personal, explanatory and motivating.
        """;
}
