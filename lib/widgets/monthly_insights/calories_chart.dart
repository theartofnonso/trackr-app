import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';

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

    final dateRange = theLastYearDateTimeRange();

    final logs = routineLogController.whereLogsIsWithinRange(range: dateRange).toList();

    final weeksInLastYear = generateWeeksInRange(range: dateRange).reversed.take(13).toList().reversed;

    List<String> months = [];
    List<int> calories = [];
    for (final week in weeksInLastYear) {
      final startOfWeek = week.start;
      final endOfWeek = week.end;
      final logsForTheWeek = logs.where((log) => log.createdAt.isBetweenInclusive(from: startOfWeek, to: endOfWeek));
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

    Trend trend = detectTrend(calories);
    String caloriesFeedback = _analyzeWeeklyCalories(caloriesBurned: calories, trend: trend);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                getTrendIcon(trend: trend),
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
        Text(caloriesFeedback,
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

  String _analyzeWeeklyCalories({required List<int> caloriesBurned, required Trend trend}) {
    // 1. Handle edge cases
    if (caloriesBurned.isEmpty) {
      return "No data on calories burned yet. Log some workouts or activities to start tracking!";
    }

    if (caloriesBurned.length == 1) {
      return "You've recorded your first week's calorie burn (${caloriesBurned.first}). "
          "Great job! Keep logging more data to see trends over time.";
    }

    // 2. Compare the last two entries to determine a trend
    final secondToLast = caloriesBurned[caloriesBurned.length - 2];
    final last = caloriesBurned.last;
    final difference = last - secondToLast;

    // If secondToLast is zero, treat it as a special case
    final bool secondToLastIsZero = secondToLast == 0;

    // 3. Compute percentage change (avoid divide-by-zero)
    final percentageChange = secondToLastIsZero ? 100.0 : (difference / secondToLast) * 100;

    // 4. Decide the trend
    const threshold = 5; // e.g., 5% is considered the “stable” range
    late Trend trend;
    if (percentageChange > threshold) {
      trend = Trend.up;
    } else if (percentageChange < -threshold) {
      trend = Trend.down;
    } else {
      trend = Trend.stable;
    }

    // 5. Construct a friendly message based on the trend
    final variation = "${percentageChange.abs().toStringAsFixed(1)}%";

    switch (trend) {
      case Trend.up:
        return "📈 This week's calorie burn is $variation higher than last week's. "
            "Fantastic effort—you're on the rise!";
      case Trend.down:
        return "📉 This week's calorie burn is $variation lower than last week's. "
            "Consider adjusting your routine or intensity if this wasn't intentional.";
      case Trend.stable:
        return "➡️ Your weekly calorie burn changed by about $variation from last week. "
            "You're maintaining consistency—great job! Keep refining your plan for steady progress.";
    }
  }
}
