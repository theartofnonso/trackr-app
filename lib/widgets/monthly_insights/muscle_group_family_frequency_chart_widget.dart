import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';

import '../../colors.dart';
import '../../controllers/routine_log_controller.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../enums/chart_unit_enum.dart';
import '../../screens/insights/sets_and_reps_insights_screen.dart';
import '../../utils/exercise_logs_utils.dart';
import '../chart/legend.dart';
import '../chart/line_chart_widget.dart';

class MuscleGroupFamilyFrequencyChartWidget extends StatelessWidget {
  const MuscleGroupFamilyFrequencyChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<RoutineLogController>(context, listen: true);

    final periodicalLogs = routineLogController.monthlyLogs;

    final muscleGroupsSplitFrequencyScores = [];

    for (var periodAndLogs in periodicalLogs.entries) {
      final exerciseLogsForTheMonth = periodAndLogs.value.expand((log) => log.exerciseLogs).toList();

      final muscleGroupsSplitFrequencyScore =
          cumulativeMuscleGroupFamilyFrequencies(exerciseLogs: exerciseLogsForTheMonth);
      final percentageScore = (muscleGroupsSplitFrequencyScore * 100).round();
      muscleGroupsSplitFrequencyScores.add(percentageScore);
    }

    final chartPoints = muscleGroupsSplitFrequencyScores
        .mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble()))
        .toList();

    final dateTimes = periodicalLogs.entries.map((monthEntry) => monthEntry.key.end.abbreviatedMonth()).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: sapphireDark80,
        border: Border.all(color: sapphireDark80.withOpacity(0.8), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Muscle Frequency Trend",
              style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: LineChartWidget(
              chartPoints: chartPoints,
              dateTimes: dateTimes,
              unit: ChartUnit.percentage,
              maxY: 100,
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: 80,
                    color: vibrantGreen,
                    strokeWidth: 1.5,
                    strokeCap: StrokeCap.round,
                    dashArray: [10],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      style: GoogleFonts.montserrat(color: vibrantGreen, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  HorizontalLine(
                    y: 50,
                    color: vibrantBlue,
                    strokeWidth: 1.5,
                    strokeCap: StrokeCap.round,
                    dashArray: [10],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      style: GoogleFonts.montserrat(color: vibrantBlue, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Column(children: [
            Legend(
              title: "50", //
              suffix: "%",
              subTitle: 'Sufficient',
              color: vibrantBlue,
            ),
            SizedBox(height: 6),
            Legend(
              title: "80",
              suffix: "%",
              subTitle: 'Optimal',
              color: vibrantGreen,
            ),
          ]),
          const SizedBox(height: 12),
          Text(
              "The average frequency of muscle groups trained in a week is 2 times. Trackr calculates this by tracking the number of times a muscle group is trained.",
              style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          CTextButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const SetsAndRepsInsightsScreen())),
              buttonColor: sapphireDark80,
              label: "See more insights",
              padding: EdgeInsets.zero,
              textStyle: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}
