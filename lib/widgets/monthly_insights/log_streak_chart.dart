import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../enums/chart_unit_enum.dart';
import '../../utils/data_trend_utils.dart';
import '../../utils/date_utils.dart';
import '../../utils/general_utils.dart';
import '../chart/line_chart_widget.dart';

class LogStreakChart extends StatelessWidget {
  const LogStreakChart({super.key});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final dateRange = theLastYearDateTimeRange();

    final logs = routineLogController.whereLogsIsWithinRange(range: dateRange).toList();

    final weeksInLastYear = generateWeeksInRange(range: dateRange).reversed.take(13).toList().reversed;

    List<String> months = [];
    List<int> days = [];
    for (final week in weeksInLastYear) {
      final startOfWeek = week.start;
      final endOfWeek = week.end;
      final logsForTheWeek = logs.where((log) => log.createdAt.isBetweenInclusive(from: startOfWeek, to: endOfWeek));
      final routineLogsByDay = groupBy(logsForTheWeek, (log) => log.createdAt.withoutTime().day);
      days.add(routineLogsByDay.length);
      months.add(startOfWeek.abbreviatedMonth());
    }

    final averageDays = days.isNotEmpty ? days.average.round() : 0;

    final chartPoints = days.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();

    Trend trend = detectTrend(days);
    String daysFeedback = _analyzeWeeklyTrainingDays(daysTrained: days, trend: trend);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                getTrendIcon(trend: trend),
                const SizedBox(width: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: "$averageDays",
                        style: Theme.of(context).textTheme.headlineSmall,
                        children: [
                          TextSpan(
                            text: " ",
                          ),
                          TextSpan(
                            text: "days".toUpperCase(),
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
              "Training sessions".toUpperCase(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(daysFeedback,
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

  String _analyzeWeeklyTrainingDays({required List<int> daysTrained, required Trend trend}) {
    // 1. Handle edge cases
    if (daysTrained.isEmpty) {
      return "No training data available yet. Log some sessions to start tracking your progress!";
    }

    if (daysTrained.length == 1) {
      return "You’ve logged your first week: ${daysTrained.first} day(s) of training."
          " Great job! Log more weeks to identify trends over time.";
    }

    // 2. Compare the last two weekly entries to determine a trend
    final secondToLast = daysTrained[daysTrained.length - 2];
    final last = daysTrained.last;

    if(last == 0) {
      return "No training data available for this week. Log some sessions to continue tracking your progress!";
    }

    final difference = (last - secondToLast).toDouble(); // Convert to double for % calculations

    // If secondToLast is zero, treat it as a special case (avoid division by zero)
    final bool secondToLastIsZero = secondToLast == 0;

    // 3. Compute a basic percentage change if possible
    final percentageChange = secondToLastIsZero
        ? 100.0
        : (difference / secondToLast) * 100;

    // 4. Decide the trend (up, down, or stable)
    // Adjust the threshold if you want finer or broader distinction
    Trend trend;
    const threshold = 25; // e.g., 25% difference for "stable" range
    if (percentageChange > threshold) {
      trend = Trend.up;
    } else if (percentageChange < -threshold) {
      trend = Trend.down;
    } else {
      trend = Trend.stable;
    }

    // 5. Generate a concise, supportive message based on the trend
    final variation = "${percentageChange.abs().toStringAsFixed(1)}%";

    switch (trend) {
      case Trend.up:
        return "📈 You're training $variation more days than last week!"
            " Keep it going—you’re building solid habits!";
      case Trend.down:
        return "📉 You're training ${difference.toInt().abs()} days lesser than last week."
            " Consider your schedule, rest, or motivation to stay on track.";
      case Trend.stable:
        return "📉 Your training days only varied by about $variation from last week."
            " Keep refining your routine for ongoing consistency!";
    }
  }
}
