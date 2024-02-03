import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';
import 'package:tracker_app/widgets/monthly_insights/exercises_sets_hours_volume_widget.dart';
import 'package:tracker_app/widgets/monthly_insights/training_and_rest_days_widget.dart';

import '../dtos/routine_log_dto.dart';
import '../enums/exercise_type_enums.dart';
import '../utils/string_utils.dart';
import '../widgets/monthly_insights/log_duration_widget.dart';

class MonthInsightsScreen extends StatelessWidget {
  final List<RoutineLogDto> monthAndLogs;

  const MonthInsightsScreen({super.key, required this.monthAndLogs});

  @override
  Widget build(BuildContext context) {
    final logHours = monthAndLogs.map((log) => log.duration().inMilliseconds);

    final trainingDays = monthAndLogs.length;
    final restDays = 30 - trainingDays;

    final exerciseLogs = monthAndLogs
        .map((log) => exerciseLogsWithCheckedSets(exerciseLogs: log.exerciseLogs))
        .expand((exerciseLogs) => exerciseLogs);
    final sets = exerciseLogs.expand((exercise) => exercise.sets);
    final numberOfExercises = exerciseLogs.length;
    final numberOfSets = sets.length;
    final totalHoursInMilliSeconds = monthAndLogs.map((log) => log.duration().inMilliseconds).sum;
    final totalHours = Duration(milliseconds: totalHoursInMilliSeconds);

    final exerciseLogsWithWeights =
        exerciseLogs.where((exerciseLog) => exerciseLog.exercise.type == ExerciseType.weights);
    final tonnage = exerciseLogsWithWeights.map((log) {
      final volume = log.sets.map((set) => set.value1 * set.value2).sum;
      return volume;
    }).sum;

    final totalVolumeInKg = volumeInKOrM(tonnage.toDouble());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("How many hours did you train?".toUpperCase(),
                style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            LogDurationWidget(logHours: logHours.isEmpty ? [0] : logHours.toList())
          ],
        ),
        const SizedBox(height: 28),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Training vs Rest Days".toUpperCase(),
                style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TrainingAndRestDaysWidget(trainingDays: trainingDays, restDays: restDays),
          ],
        ),
        const SizedBox(height: 28),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Summary of Sessions".toUpperCase(),
                style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ExercisesSetsHoursVolumeWidget(
                numberOfExercises: numberOfExercises,
                numberOfSets: numberOfSets,
                totalHours: totalHours,
                totalVolume: totalVolumeInKg)
          ],
        )
      ],
    );
  }
}
