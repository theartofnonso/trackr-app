import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../colors.dart';
import '../../controllers/routine_log_controller.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../enums/chart_unit_enum.dart';
import '../../utils/date_utils.dart';
import '../chart/bar_chart.dart';

class LogStreakChartWidget extends StatelessWidget {
  const LogStreakChartWidget({super.key});

  @override
  Widget build(BuildContext context) {

    final routineLogController = Provider.of<RoutineLogController>(context, listen: true);

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
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [sapphireDark80, sapphireDark],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Log Streak".toUpperCase(),
              style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          SizedBox(
              height: 200,
              child: CustomBarChart(
                chartPoints: chartPoints,
                periods: months,
                barColors: streakColor,
                unit: ChartUnit.number,
                bottomTitlesInterval: 1,
                showLeftTitles: true,
                maxY: streaks.isNotEmpty ? streaks.max.toDouble() : 31,
                reservedSize: 25,
              ))
        ],
      ),
    );
  }
}
