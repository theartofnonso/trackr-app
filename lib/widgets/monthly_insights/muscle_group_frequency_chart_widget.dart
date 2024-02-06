import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

import '../../colors.dart';
import '../../controllers/routine_log_controller.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../enums/chart_unit_enum.dart';
import '../../utils/exercise_logs_utils.dart';
import '../chart/line_chart_widget.dart';

class MuscleGroupFrequencyWidget extends StatelessWidget {
  const MuscleGroupFrequencyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<RoutineLogController>(context, listen: true);

    final monthlyLogs = routineLogController.monthlyLogs;

    final muscleGroupsSplitFrequencyScores = [];

    for (var monthAndLogs in monthlyLogs.entries) {
      final exerciseLogsForTheMonth = monthAndLogs.value.expand((log) => log.exerciseLogs).toList();

      final muscleGroupsSplitFrequencyScore = muscleGroupFrequencyScore(exerciseLogs: exerciseLogsForTheMonth);
      final percentageScore = (muscleGroupsSplitFrequencyScore * 100).toInt();
      muscleGroupsSplitFrequencyScores.add(percentageScore);
    }

    final chartPoints = muscleGroupsSplitFrequencyScores
        .mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble()))
        .toList();

    final dateTimes = monthlyLogs.entries.map((monthEntry) => monthEntry.key.start.abbreviatedMonth()).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: sapphireLight,
        border: Border.all(color: sapphireDark.withOpacity(0.8), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Muscle Split",
              style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(right: 30.0),
            child: LineChartWidget(
              chartPoints: chartPoints,
              dateTimes: dateTimes,
              unit: ChartUnit.percentage,
              bigData: false,
            ),
          ),
        ],
      ),
    );
  }
}
