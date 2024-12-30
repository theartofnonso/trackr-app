import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../colors.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../enums/chart_unit_enum.dart';
import '../../utils/date_utils.dart';
import '../chart/line_chart_widget.dart';

class LogStreakChartWidget extends StatelessWidget {
  const LogStreakChartWidget({super.key});

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
      streaks.add(values.length);
      months.add(startOfMonth.abbreviatedMonth());
    }

    final chartPoints =
        streaks.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();

    final streakColor = streaks.map((streak) => logStreakColor(value: streak / 12)).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? sapphireDark80 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Log Streak".toUpperCase(), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 30),
          LineChartWidget(
              chartPoints: chartPoints,
              periods: months,
              unit: ChartUnit.number,
              aspectRation: 2,
              reservedSize: 20,
              interval: 1,
              colors: streakColor)
        ],
      ),
    );
  }
}
