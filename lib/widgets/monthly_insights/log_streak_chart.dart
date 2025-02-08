import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/utils/string_utils.dart';

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

    final chartPoints = days.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();

    final trendSummary = _analyzeWeeklyTrends(daysTrained: days);

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

  TrendSummary _analyzeWeeklyTrends({required List<int> daysTrained}) {
    // 1. Handle edge cases
    if (daysTrained.isEmpty) {
      return TrendSummary(
          trend: Trend.none,
          summary: "No training data available yet. Log some sessions to start tracking your progress!");
    }

    if (daysTrained.length == 1) {
      return TrendSummary(
          trend: Trend.none,
          summary: "You’ve logged your first week: ${daysTrained.first} day(s) of training."
              " Great job! Log more weeks to identify trends over time.");
    }

    // 2. Identify the last week's volume and the average of all previous weeks
    final lastWeekVolume = daysTrained.last;

    if (lastWeekVolume == 0) {
      return TrendSummary(
          trend: Trend.none,
          summary: "No training data available for this week. Log some sessions to continue tracking your progress!");
    }

    final previousVolumes = daysTrained.sublist(0, daysTrained.length - 1);
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
            average: averageOfPrevious,
            summary:
                "You're training $variation more ${pluralize(word: "day", count: daysTrained.length)} than your average!"
                " Keep it going—you’re building solid habits!");
      case Trend.down:
        final diffAbs = difference.toInt().abs();
        return TrendSummary(
            trend: Trend.down,
            average: averageOfPrevious,
            summary:
                "You're training $diffAbs ${pluralize(word: "day", count: diffAbs)} lesser than your average."
                " Consider your schedule, rest, or motivation to stay on track.");
      case Trend.stable:
        return TrendSummary(
            trend: Trend.stable,
            average: averageOfPrevious,
            summary:
                "Your training ${pluralize(word: "day", count: daysTrained.length)} only varied by about $variation compared to your average."
                " Keep refining your routine for ongoing consistency!");
      case Trend.none:
        return TrendSummary(trend: Trend.none, summary: "Unable to identify trends");
    }
  }
}
