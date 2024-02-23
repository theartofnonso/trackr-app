import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/screens/insights/sets_reps_volume_insights_screen.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/utils/navigation_utils.dart';
import 'package:tracker_app/utils/string_utils.dart';

import '../../dtos/routine_log_dto.dart';
import '../../strings.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/general_utils.dart';
import '../../utils/google_analytics.dart';
import 'streak_health_monitor.dart';
import 'muscle_group_family_frequency_monitor.dart';

class OverviewMonitor extends StatelessWidget {
  final List<RoutineLogDto> routineLogs;

  const OverviewMonitor({super.key, required this.routineLogs});

  @override
  Widget build(BuildContext context) {
    final monthlyProgress = routineLogs.length / 12;

    final exerciseLogsForTheMonth = routineLogs.expand((log) => log.exerciseLogs).toList();

    final muscleGroupsSplitFrequencyScore =
        cumulativeMuscleGroupFamilyFrequencies(exerciseLogs: exerciseLogsForTheMonth);

    final splitPercentage = (muscleGroupsSplitFrequencyScore * 100).round();

    return Stack(children: [
      Positioned.fill(
        right: 14,
        child: GestureDetector(
          onTap: () => _showMonitorInfo(context: context),
          child: const Align(
              alignment: Alignment.bottomRight,
              child: FaIcon(FontAwesomeIcons.circleInfo, color: Colors.white38, size: 18)),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 20),
          Stack(alignment: Alignment.center, children: [
            StreakHealthMonitor(value: monthlyProgress),
            MuscleGroupFamilyFrequencyMonitor(value: muscleGroupsSplitFrequencyScore),
            Image.asset(
              'images/trackr.png',
              fit: BoxFit.contain,
              color: Colors.white54,
              height: 8, // Adjust the height as needed
            )
          ]),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                  onTap: () => navigateToRoutineLogs(context: context, logs: routineLogs),
                  child: Container(
                    color: Colors.transparent,
                    child: _MonitorScore(
                      value: "${routineLogs.length} ${pluralize(word: "day", count: routineLogs.length)}",
                      title: "Streak",
                      color: consistencyHealthColor(value: monthlyProgress),
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                  )),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  recordViewMuscleTrendEvent();
                  Navigator.of(context).pushNamed(SetsAndRepsVolumeInsightsScreen.routeName);
                },
                child: Container(
                  color: Colors.transparent,
                  child: _MonitorScore(
                    value: "$splitPercentage%",
                    color: Colors.white,
                    title: "Muscle",
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ]);
  }

  void _showMonitorInfo({required BuildContext context}) {
    showBottomSheetWithNoAction(context: context, title: "Streak and Muscle", description: overviewMonitor);
  }
}

class _MonitorScore extends StatelessWidget {
  final String value;
  final String title;
  final Color color;
  final CrossAxisAlignment crossAxisAlignment;

  const _MonitorScore(
      {required this.value, required this.title, required this.color, required this.crossAxisAlignment});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        Text(
          value,
          style: GoogleFonts.montserrat(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            color: color.withOpacity(0.5),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        )
      ],
    );
  }
}
