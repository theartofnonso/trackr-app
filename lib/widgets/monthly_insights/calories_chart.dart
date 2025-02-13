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
              spacing: 10,
              children: [
                trendSummary.trend == Trend.none ? const SizedBox.shrink() : getTrendIcon(trend: trendSummary.trend),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: "${trendSummary.average.toInt()}",
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
    // 1. If there's no data at all, return immediately.
    if (caloriesBurned.isEmpty) {
      return TrendSummary(
        trend: Trend.none,
        average: 0,
        summary: "🤔 No data on calories burned yet. Log some sessions or activities to start tracking!",
      );
    }

    // 2. If there's only one logged value, avoid sublist/reduce on an empty list.
    if (caloriesBurned.length == 1) {
      final singleCalories = caloriesBurned.first;
      // No "previous" data, so the average of previous volumes is 0 by default.
      return TrendSummary(
        trend: Trend.up, // You labeled the first entry as an "up" trend.
        average: 0,
        summary: "🌟 You've logged your first week's calorie burn ($singleCalories). "
            "Great job! Keep logging more data to see trends over time.",
      );
    }

    // 3. Now we can safely do sublist & reduce because we know there's at least 2 entries.
    final previousVolumes = caloriesBurned.sublist(0, caloriesBurned.length - 1);
    final averageOfPrevious = previousVolumes.reduce((a, b) => a + b) / previousVolumes.length;

    // 4. Identify the latest week's calorie burn
    final lastWeekVolume = caloriesBurned.last;

    if (lastWeekVolume == 0) {
      return TrendSummary(
        trend: Trend.none,
        average: averageOfPrevious,
        summary: "🤔 No training data available for this week. "
            "Log some workouts to continue tracking your progress!",
      );
    }

    // 5. Compare the most recent to the average of previous
    final difference = lastWeekVolume - averageOfPrevious;
    final differenceIsZero = difference == 0;

    // Special handling if averageOfPrevious == 0
    final bool averageIsZero = averageOfPrevious == 0;
    final double percentageChange = averageIsZero ? 100.0 : (difference / averageOfPrevious) * 100;

    // 6. Decide the trend based on a threshold
    const threshold = 5; // ±5%
    late final Trend trend;
    if (percentageChange > threshold) {
      trend = Trend.up;
    } else if (percentageChange < -threshold) {
      trend = Trend.down;
    } else {
      trend = Trend.stable;
    }

    // 7. Create a concise message based on the trend
    final variation = "${percentageChange.abs().toStringAsFixed(1)}%";

    switch (trend) {
      case Trend.up:
        return TrendSummary(
          trend: Trend.up,
          average: averageOfPrevious,
          summary: "🌟🌟 This week's calorie burn is $variation higher than your average. "
              "Fantastic effort—you're on the rise!",
        );

      case Trend.down:
        return TrendSummary(
          trend: Trend.down,
          average: averageOfPrevious,
          summary: "📉 This week's calorie burn is $variation lower than your average. "
              "Consider adjusting your routine or intensity if this wasn't intentional.",
        );

      case Trend.stable:
        final summary = differenceIsZero
            ? "🌟 You've matched your average exactly! Stay consistent to see long-term progress."
            : "🔄 Your calorie burn changed by about $variation compared to your average. "
                "You're maintaining consistency—great job! Keep refining your plan for steady progress.";
        return TrendSummary(
          trend: Trend.stable,
          average: averageOfPrevious,
          summary: summary,
        );

      case Trend.none:
        // Fallback for completeness — you typically won't reach here
        return TrendSummary(
          trend: Trend.none,
          average: averageOfPrevious,
          summary: "🤔 Unable to identify trends",
        );
    }
  }
}
