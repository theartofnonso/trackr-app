import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/screens/insights/sets_reps_volume_insights_screen.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/utils/navigation_utils.dart';
import 'package:tracker_app/utils/string_utils.dart';

import '../../colors.dart';
import '../../dtos/routine_log_dto.dart';
import '../../strings.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/general_utils.dart';
import 'log_streak_monitor.dart';
import 'muscle_group_family_frequency_monitor.dart';

class OverviewMonitor extends StatelessWidget {
  final List<RoutineLogDto> routineLogs;

  const OverviewMonitor({super.key, required this.routineLogs});

  @override
  Widget build(BuildContext context) {

    final routineLogDays = groupBy(routineLogs, (log) => log.createdAt.withoutTime().day);

    final monthlyProgress = routineLogDays.length / 12;

    final exerciseLogsForTheMonth = routineLogs.expand((log) => log.exerciseLogs).toList();

    final muscleGroupsSplitFrequencyScore =
        cumulativeMuscleGroupFamilyFrequency(exerciseLogs: exerciseLogsForTheMonth);

    final splitPercentage = (muscleGroupsSplitFrequencyScore * 100).round();

    return Center(
      child: Stack(children: [
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
                onTap: () => navigateToRoutineLogs(context: context, logs: routineLogs),
                child: Container(
                  color: Colors.transparent,
                  width: 100,
                  child: _MonitorScore(
                    value: "${routineLogDays.length} ${pluralize(word: "day", count: routineLogDays.length)}",
                    title: "Log Streak",
                    color: logStreakColor(value: monthlyProgress),
                    crossAxisAlignment: CrossAxisAlignment.end,
                  ),
                )),
            const SizedBox(width: 20),
            GestureDetector(
              //onTap: () => _navigateToLeaderBoard(context: context),
              child: Stack(alignment: Alignment.center, children: [
                LogStreakMonitor(
                    value: monthlyProgress,
                    width: 100,
                    height: 100,
                    strokeWidth: 6,
                    decoration: BoxDecoration(
                      color: sapphireDark.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(100),
                    )),
                MuscleGroupFamilyFrequencyMonitor(
                    value: muscleGroupsSplitFrequencyScore, width: 70, height: 70, strokeWidth: 6),
                Image.asset(
                  'images/trkr.png',
                  fit: BoxFit.contain,
                  color: Colors.white54,
                  height: 8, // Adjust the height as needed
                )
              ]),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () {
                context.push(SetsAndRepsVolumeInsightsScreen.routeName);
              },
              child: Container(
                color: Colors.transparent,
                width: 100,
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
      ]),
    );
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
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          value,
          style: GoogleFonts.ubuntu(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.ubuntu(
            color: color.withOpacity(0.7),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        )
      ],
    );
  }
}
