import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/set_dtos/reps_dto.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/utils/string_utils.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../dtos/set_dtos/weight_and_reps_dto.dart';
import '../../enums/chart_unit_enum.dart';
import '../../enums/exercise_type_enums.dart';
import '../../utils/data_trend_utils.dart';
import '../../utils/date_utils.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/general_utils.dart';
import '../chart/line_chart_widget.dart';

class VolumeChart extends StatelessWidget {
  const VolumeChart({super.key});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final dateRange = theLastYearDateTimeRange();

    final logs = routineLogController
        .whereLogsIsWithinRange(range: dateRange)
        .map((log) => routineWithLoggedExercises(log: log))
        .toList();

    final weeksInLastYear = generateWeeksInRange(range: dateRange).reversed.take(13).toList().reversed;

    List<String> months = [];
    List<double> volumes = [];
    for (final week in weeksInLastYear) {
      final startOfWeek = week.start;
      final endOfWeek = week.end;
      final logsForTheWeek = logs.where((log) => log.createdAt.isBetweenInclusive(from: startOfWeek, to: endOfWeek));
      final values = logsForTheWeek
          .expand((log) => log.exerciseLogs)
          .expand((exerciseLog) => exerciseLog.sets)
          .map((set) {
            return switch (set.type) {
              ExerciseType.weights => (set as WeightAndRepsSetDto).volume(),
              ExerciseType.bodyWeight => (set as RepsSetDto).reps,
              ExerciseType.duration => 0,
            };
          })
          .sum
          .toDouble();
      volumes.add(values);
      months.add(startOfWeek.abbreviatedMonth());
    }

    final chartPoints =
        volumes.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();

    final trendSummary = _analyzeWeeklyTrends(volumes: volumes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              children: [
                trendSummary.trend == Trend.none ? const SizedBox.shrink() : getTrendIcon(trend: trendSummary.trend),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: volumeInKOrM(trendSummary.average),
                        style: Theme.of(context).textTheme.headlineSmall,
                        children: [
                          TextSpan(
                            text: " ",
                          ),
                          TextSpan(
                            text: weightLabel().toUpperCase(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "Weekly AVERAGE".toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                )
              ],
            ),
            const Spacer(),
            Text(
              "Volume".toUpperCase(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(trendSummary.summary,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
        const SizedBox(height: 20),
        LineChartWidget(
          chartPoints: chartPoints,
          periods: months,
          unit: ChartUnit.weight,
          hasLeftAxisTitles: false,
          aspectRation: 4,
          interval: 6,
        )
      ],
    );
  }

  TrendSummary _analyzeWeeklyTrends({required List<double> volumes}) {
    // 1. Handle edge cases
    if (volumes.isEmpty) {
      return TrendSummary(
          trend: Trend.none,
          summary: "No training data available yet. Log some sessions to start tracking your progress!");
    }

    if (volumes.length == 1) {
      return TrendSummary(
          trend: Trend.none,
          summary: "You've logged your first week's volume (${volumes.first})."
              " Great job! Keep logging more data to see trends over time.");
    }

    // 2. Identify the last week's volume and the average of all previous weeks
    final lastWeekVolume = volumes.last;

    if (lastWeekVolume == 0) {
      return TrendSummary(
          trend: Trend.none,
          summary: "No training data available for this week. Log some workouts to continue tracking your progress!");
    }

    final previousVolumes = volumes.sublist(0, volumes.length - 1);
    final averageOfPrevious = previousVolumes.reduce((a, b) => a + b) / previousVolumes.length;

    // 3. Compare last week's volume to the average of previous volumes
    final difference = lastWeekVolume - averageOfPrevious;

    // Special check for no difference
    final differenceIsZero = difference == 0;

    // If the average is zero, treat it as a special case for percentage change
    final bool averageIsZero = averageOfPrevious == 0;
    final double percentageChange = averageIsZero ? 100.0 : (difference / averageOfPrevious) * 100;

    // 4. Decide the trend
    const threshold = 5; // Adjust this threshold for "stable" as needed
    late final Trend trend;
    if (percentageChange > threshold) {
      trend = Trend.up;
    } else if (percentageChange < -threshold) {
      trend = Trend.down;
    } else {
      trend = Trend.stable;
    }

    // 5. Generate a friendly, concise message based on the trend
    final variation = "${percentageChange.abs().toStringAsFixed(1)}%";

    switch (trend) {
      case Trend.up:
        return TrendSummary(
            trend: Trend.up,
            average: averageOfPrevious,
            summary: "This week's volume is $variation higher than your average. "
                "Awesome job building momentum!");
      case Trend.down:
        return TrendSummary(
            trend: Trend.down,
            average: averageOfPrevious,
            summary: "This week's volume is $variation lower than your average. "
                "Consider extra rest, checking your technique, or planning a deload.");
      case Trend.stable:
        final summary = differenceIsZero
            ? "You've matched your average exactly! Stay consistent to see long-term progress."
            : "Your volume changed by about $variation compared to your average. "
                "A great chance to refine your form and maintain consistency.";
        return TrendSummary(trend: Trend.stable, average: averageOfPrevious, summary: summary);
      case Trend.none:
        return TrendSummary(trend: Trend.none, summary: "Unable to identify trends");
    }
  }
}
