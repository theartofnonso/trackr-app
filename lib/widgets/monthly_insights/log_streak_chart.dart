import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../enums/chart_unit_enum.dart';
import '../../utils/date_utils.dart';
import '../chart/line_chart_widget.dart';

class LogStreakChart extends StatelessWidget {
  const LogStreakChart({super.key});

  @override
  Widget build(BuildContext context) {

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final dateRange = theLastYearDateTimeRange();

    final logs = routineLogController.whereLogsIsWithinRange(range: dateRange);

    final monthsInYear = generateMonthsInRange(range: dateRange);

    List<String> months = [];
    List<int> streaks = [];
    for (final month in monthsInYear) {
      final startOfMonth = month.start;
      final endOfMonth = month.end;
      final values = logs.where((log) => log.createdAt.isBetweenInclusive(from: startOfMonth, to: endOfMonth));
      final routineLogsByDay = groupBy(values, (log) => log.createdAt.withoutTime().day);
      streaks.add(routineLogsByDay.length);
      months.add(startOfMonth.abbreviatedMonth());
    }

    final chartPoints =
        streaks.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();

    final averageStreaks = streaks.isNotEmpty ? streaks.average.round() : 0;

    final streakColor = streaks.map((streak) => logStreakColor(streak)).toList();

    final logStreakFeedback = _logStreakFeedback(averageStreaks);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: "$averageStreaks",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: logStreakColor(averageStreaks)),
                children: [
                  TextSpan(
                    text: " ",
                  ),
                  TextSpan(
                    text: "days log streak".toUpperCase(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Text(
              "Monthly AVERAGE".toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Text(
                logStreakFeedback,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
          ],
        ),
        const SizedBox(height: 30),
        LineChartWidget(
            chartPoints: chartPoints,
            periods: months,
            unit: ChartUnit.number,
            aspectRation: 2,
            leftReservedSize: 19,
            interval: 1,
            colors: streakColor)
      ],
    );
  }

  String _logStreakFeedback(num value) {

    final result = value / 12;

    if (result < 0.3) {
      return "Your log frequency is quite low. Try logging each session to track progress.";
    } else if (result < 0.5) {
      return "You're logging somewhat regularly. Keep aiming for consistency!";
    } else if (result < 0.8) {
      return "Great job logging your sessions! You're staying consistent.";
    } else {
      return "Fantastic! You’re on a roll with consistently logging your workouts.";
    }
  }
}
