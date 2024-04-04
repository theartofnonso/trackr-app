import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../colors.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../dtos/routine_log_dto.dart';
import '../../enums/chart_unit_enum.dart';
import '../chart/bar_chart.dart';

class LogStreakChartWidget extends StatelessWidget {

  final Map<DateTimeRange, List<RoutineLogDto>> monthlyLogs;

  const LogStreakChartWidget({super.key, required this.monthlyLogs});

  @override
  Widget build(BuildContext context) {
    List<int> logsStreak = [];

    for (var periodAndLogs in monthlyLogs.entries) {
      final logsByDay = groupBy(periodAndLogs.value, (log) => log.createdAt.day);
      logsStreak.add(logsByDay.values.length);
    }

    final chartPoints = logsStreak
        .mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble()))
        .toList();

    final streakColor = logsStreak.map((streak) => logStreakColor(value: streak / 12)).toList();

    final dateTimes = monthlyLogs.entries.map((monthEntry) => monthEntry.key.end.abbreviatedMonth()).toList();

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
          Text("Log Steak".toUpperCase(),
              style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
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
                maxY: logsStreak.isNotEmpty ? logsStreak.max.toDouble() : 31,
                reservedSize: 25,
              ))
        ],
      ),
    );
  }
}
