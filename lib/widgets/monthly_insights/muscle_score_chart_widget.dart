import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../colors.dart';
import '../../dtos/appsync/routine_log_dto.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../enums/chart_unit_enum.dart';
import '../../screens/insights/sets_reps_volume_insights_screen.dart';
import '../../utils/exercise_logs_utils.dart';
import '../chart/bar_chart.dart';

class MuscleScoreChartWidget extends StatelessWidget {
  final List<RoutineLogDto> logs;

  const MuscleScoreChartWidget({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {

    List<DateTime> scoreMonths = [];
    List<int> scoreCount = [];

    final logsAndMonths = groupBy(logs, (log) => log.createdAt.month);

    for (var logsAndMonths in logsAndMonths.entries) {
      final exerciseLogsForTheMonth =
          logsAndMonths.value.expand((log) => completedExercises(exerciseLogs: log.exerciseLogs)).toList();

      final muscleScorePercentage = calculateMuscleScoreForLogs(routineLogs: logsAndMonths.value);

      scoreMonths.add(exerciseLogsForTheMonth.first.createdAt);
      scoreCount.add(muscleScorePercentage);
    }

    final chartPoints =
        scoreCount.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();

    final scoreColors = scoreCount.map((score) => muscleGroupFrequencyColor(value: score / 100)).toList();

    final dateTimes = scoreMonths.map((month) => month.abbreviatedMonth()).toList();

    return GestureDetector(
      onTap: () {
        context.push(SetsAndRepsVolumeInsightsScreen.routeName);
      },
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Muscle Trend".toUpperCase(),
                    style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                const FaIcon(FontAwesomeIcons.arrowRightLong, color: Colors.white, size: 20),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
                height: 200,
                child: CustomBarChart(
                  chartPoints: chartPoints,
                  periods: dateTimes,
                  barColors: scoreColors,
                  unit: ChartUnit.number,
                  bottomTitlesInterval: 1,
                  showLeftTitles: true,
                  maxY: 100,
                  reservedSize: 25,
                ))
          ],
        ),
      ),
    );
  }
}
