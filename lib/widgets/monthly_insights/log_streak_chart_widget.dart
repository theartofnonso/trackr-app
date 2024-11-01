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

    final dateRange = theLastYearDateTimeRange();

    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);

    final logs = routineLogController.whereLogsIsWithinRange(range: dateRange);

    List<DateTime> streakMonths = [];
    List<int> streakCount = [];

    final logsAndMonths = groupBy(logs, (log) => log.createdAt.month);

    for (var logsAndMonths in logsAndMonths.entries) {
      final logsForMonth = logsAndMonths.value;
      final logsAndDays = groupBy(logsForMonth, (log) => log.createdAt.day);
      streakMonths.add(logsForMonth.first.createdAt);
      streakCount.add(logsAndDays.length);
    }

    final chartPoints =
        streakCount.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();

    final streakColor = streakCount.map((streak) => logStreakColor(value: streak / 12)).toList();

    final dateTimes = streakMonths.map((month) => month.abbreviatedMonth()).toList();

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
                periods: dateTimes,
                barColors: streakColor,
                unit: ChartUnit.number,
                bottomTitlesInterval: 1,
                showLeftTitles: true,
                maxY: streakCount.isNotEmpty ? streakCount.max.toDouble() : 31,
                reservedSize: 25,
              ))
        ],
      ),
    );
  }
}
