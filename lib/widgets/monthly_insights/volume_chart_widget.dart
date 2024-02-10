import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

import '../../colors.dart';
import '../../controllers/routine_log_controller.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/general_utils.dart';
import '../chart/line_chart_widget.dart';

class VolumeChartWidget extends StatelessWidget {
  const VolumeChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<RoutineLogController>(context, listen: true);

    final periodicalLogs = routineLogController.weeklyLogs;

    final periodicalTonnage = [];

    for (var periodAndLogs in periodicalLogs.entries) {
      final tonnageForPeriod = periodAndLogs.value
          .map((log) => exerciseLogsWithCheckedSets(exerciseLogs: log.exerciseLogs))
          .expand((exerciseLogs) => exerciseLogs)
          .map((log) {
        final volume = log.sets.map((set) => set.volume()).sum;
        return volume.toDouble();
      }).sum;

      periodicalTonnage.add(tonnageForPeriod);
    }

    final chartPoints =
        periodicalTonnage.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();

    final dateTimes = periodicalLogs.entries.map((periodEntry) => periodEntry.key.end.abbreviatedMonth()).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: sapphireDark80,
        border: Border.all(color: sapphireDark80.withOpacity(0.8), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
              text: TextSpan(
                  text: "Volume Trend",
                  style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                  children: [
                    const TextSpan(text: " "),
                    TextSpan(
                        text: weightLabel().toUpperCase(),
                        style: GoogleFonts.montserrat(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
                  ])),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: LineChartWidget(
              chartPoints: chartPoints,
              dateTimes: dateTimes,
              unit: chartWeightUnitLabel(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
              "Volume trend indicates the intensity of your workouts. Trackr calculates this by multiplying the weight lifted by the number of reps.",
              style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
