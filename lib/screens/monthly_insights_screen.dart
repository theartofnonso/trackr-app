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
import '../widgets/monthly_insights/muscle_groups_widget.dart';
import '../widgets/monthly_insights/reps_chart_widget.dart';
import '../widgets/monthly_insights/volume_chart_widget.dart';

class MonthlyInsightsScreen extends StatelessWidget {
  final List<RoutineLogDto> monthAndLogs;
  final int daysInMonth;

  const MonthlyInsightsScreen({super.key, required this.monthAndLogs, required this.daysInMonth});

  @override
  Widget build(BuildContext context) {
    final logHours = monthAndLogs.map((log) => log.duration().inMilliseconds);

    final exerciseLogs = monthAndLogs
        .map((log) => exerciseLogsWithCheckedSets(exerciseLogs: log.exerciseLogs))
        .expand((exerciseLogs) => exerciseLogs)
        .toList();
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
        LogDurationWidget(logHours: logHours.isEmpty ? [0] : logHours.toList()),
        const SizedBox(height: 28),
        TrainingAndRestDaysWidget(monthAndLogs: monthAndLogs, daysInMonth: daysInMonth),
        const SizedBox(height: 28),
        ExercisesSetsHoursVolumeWidget(
            numberOfExercises: numberOfExercises,
            numberOfSets: numberOfSets,
            totalHours: totalHours,
            totalVolume: totalVolumeInKg),
        const SizedBox(height: 28),
        MuscleGroupsWidget(exerciseLogs: exerciseLogs),
        const SizedBox(height: 16),
        Text("Intensity of training for ${DateTime.now().year}".toUpperCase(),
            style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const RepsChartWidget(),
        const SizedBox(height: 20),
        const VolumeChartWidget(),
      ],
    );
  }
}
