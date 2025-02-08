import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';

import '../../controllers/activity_log_controller.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../controllers/routine_user_controller.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../enums/chart_unit_enum.dart';
import '../../utils/data_trend_utils.dart';
import '../../utils/date_utils.dart';
import '../../utils/general_utils.dart';
import '../../utils/routine_utils.dart';
import '../chart/line_chart_widget.dart';

class CaloriesChart extends StatelessWidget {
  const CaloriesChart({super.key});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final routineUserController = Provider.of<RoutineUserController>(context, listen: false);

    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final activityLogController = Provider.of<ActivityLogController>(context, listen: false);

    final dateRange = theLastYearDateTimeRange();

    final routineLogs = routineLogController.whereLogsIsWithinRange(range: dateRange).toList();

    final activityLogs = activityLogController.whereLogsIsWithinRange(range: dateRange).toList();

    final weeksInLastYear = generateWeeksInRange(range: dateRange).reversed.take(13).toList().reversed;

    final allLogs = [...routineLogs, ...activityLogs];

    List<String> months = [];
    List<int> calories = [];
    for (final week in weeksInLastYear) {
      final startOfWeek = week.start;
      final endOfWeek = week.end;
      final logsForTheWeek = allLogs.where((log) => log.createdAt.isBetweenInclusive(from: startOfWeek, to: endOfWeek));
      final values = logsForTheWeek
          .map((log) => calculateCalories(
              duration: log.duration(), bodyWeight: routineUserController.weight(), activity: log.activityType))
          .sum;
      calories.add(values);
      months.add(startOfWeek.abbreviatedMonth());
    }

    final averageCalories = calories.isNotEmpty ? calories.average.round() : 0;

    final chartPoints =
        calories.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();

    final trendSummary = _analyzeWeeklyTrends(caloriesBurned: calories);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                getTrendIcon(trend: trendSummary.trend),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: "$averageCalories",
                        style: Theme.of(context).textTheme.headlineSmall,
                        children: [
                          TextSpan(
                            text: " ",
                          ),
                          TextSpan(
                            text: "KCAL".toUpperCase(),
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
              "Energy Burned".toUpperCase(),
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
        const SizedBox(height: 30),
        LineChartWidget(
          chartPoints: chartPoints,
          periods: months,
          unit: ChartUnit.number,
          aspectRation: 4,
          hasLeftAxisTitles: false,
          interval: 6,
        )
      ],
    );
  }

  TrendSummary _analyzeWeeklyTrends({required List<int> caloriesBurned}) {
    // 1. Handle edge cases
    if (caloriesBurned.isEmpty) {
      return TrendSummary(
          trend: Trend.none,
          summary: "No data on calories burned yet. Log some sessions or activities to start tracking!");
    }

    if (caloriesBurned.length == 1) {
      return TrendSummary(
          trend: Trend.none,
          summary: "You've logged your first week's calorie burn (${caloriesBurned.first}). "
              "Great job! Keep logging more data to see trends over time.");
    }

    // 2. Identify the last week's volume and the average of all previous weeks
    final lastWeekVolume = caloriesBurned.last;

    if (lastWeekVolume == 0) {
      return TrendSummary(
          trend: Trend.none,
          summary: "No training data available for this week. Log some workouts to continue tracking your progress!");
    }

    final previousVolumes = caloriesBurned.sublist(0, caloriesBurned.length - 1);
    final averageOfPrevious = previousVolumes.reduce((a, b) => a + b) / previousVolumes.length;

    // 3. Compare last week's volume to the average of previous volumes
    final difference = lastWeekVolume - averageOfPrevious;

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
            summary: "This week's calorie burn is $variation higher than your average. "
                "Fantastic effort—you're on the rise!");
      case Trend.down:
        return TrendSummary(
            trend: Trend.down,
            summary: "This week's calorie burn is $variation lower than your average. "
                "Consider adjusting your routine or intensity if this wasn't intentional.");
      case Trend.stable:
        return TrendSummary(
            trend: Trend.stable,
            summary: "Your calorie burn changed by about $variation compared to your average. "
                "You're maintaining consistency—great job! Keep refining your plan for steady progress.");
      case Trend.none:
        return TrendSummary(trend: Trend.none, summary: "Unable to identify trends");
    }
  }
}
