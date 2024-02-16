import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

import '../../colors.dart';
import '../../controllers/routine_log_controller.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../enums/chart_unit_enum.dart';
import '../../screens/insights/sets_reps_volume_insights_screen.dart';
import '../../utils/exercise_logs_utils.dart';
import '../chart/bar_chart.dart';
import '../chart/legend.dart';

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
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(SetsAndRepsVolumeInsightsScreen.routeName),
            child: Container(
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Muscle Trend".toUpperCase(),
                      style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                  const FaIcon(FontAwesomeIcons.arrowRightLong, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
              height: 200,
              child: CustomBarChart(
                chartPoints: chartPoints,
                periods: dateTimes,
                unit: ChartUnit.number,
                bottomTitlesInterval: 1,
                showLeftTitles: true,
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
              )),
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
          //const SizedBox(height: 12),
          // Text(
          //     "The average frequency of muscle groups trained in a week is 2 times. Trackr calculates this by tracking the number of times a muscle group is trained.",
          //     style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
