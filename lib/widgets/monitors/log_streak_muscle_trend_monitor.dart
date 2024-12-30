import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/screens/logs/routine_logs_screen.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/utils/navigation_utils.dart';
import 'package:tracker_app/utils/string_utils.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../enums/posthog_analytics_event.dart';
import '../../screens/insights/sets_reps_volume_insights_screen.dart';
import '../../strings/strings.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/general_utils.dart';
import '../../utils/shareables_utils.dart';
import '../calendar/calendar.dart';
import 'log_streak_monitor.dart';
import 'muscle_trend_monitor.dart';

GlobalKey monitorKey = GlobalKey();

class LogStreakMuscleTrendMonitor extends StatelessWidget {
  final DateTime dateTime;
  final bool showInfo;
  final bool forceDarkMode;

  const LogStreakMuscleTrendMonitor(
      {super.key, required this.dateTime, this.showInfo = true, this.forceDarkMode = false});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark || forceDarkMode;

    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final routineLogs = exerciseAndRoutineController.whereLogsIsSameMonth(dateTime: dateTime);

    final routineLogsByDay = groupBy(routineLogs, (log) => log.createdAt.withoutTime().day);

    final monthlyProgress = routineLogsByDay.length / 12;

    final muscleScorePercentage = calculateMuscleScoreForLogs(routineLogs: routineLogs);

    return Stack(children: [
      if (showInfo)
        Positioned.fill(
          left: 12,
          child: GestureDetector(
            onTap: () => _showMonitorInfo(context: context),
            child: const Align(alignment: Alignment.bottomLeft, child: FaIcon(FontAwesomeIcons.circleInfo, size: 18)),
          ),
        ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
              onTap: () => _showRoutineLogsScreen(context: context),
              child: Container(
                color: Colors.transparent,
                width: 80,
                child: _MonitorScore(
                    value: "${routineLogsByDay.length} ${pluralize(word: "day", count: routineLogsByDay.length)}",
                    title: "Log Streak",
                    color: logStreakColor(value: monthlyProgress),
                    crossAxisAlignment: CrossAxisAlignment.end,
                    forceDarkMode: isDarkMode),
              )),
          const SizedBox(width: 20),
          GestureDetector(
            child: Stack(alignment: Alignment.center, children: [
              LogStreakMonitor(
                  value: monthlyProgress, width: 100, height: 100, strokeWidth: 6, forceDarkMode: isDarkMode),
              MuscleTrendMonitor(
                value: muscleScorePercentage / 100,
                width: 70,
                height: 70,
                strokeWidth: 6,
                forceDarkMode: forceDarkMode,
              ),
              Image.asset(
                'images/trkr.png',
                fit: BoxFit.contain,
                color: isDarkMode ? Colors.white70 : Colors.black,
                height: 8, // Adjust the height as needed
              )
            ]),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () => _showSetsAndRepsVolumeInsightsScreen(context: context),
            child: SizedBox(
              width: 80,
              child: _MonitorScore(
                  value: "$muscleScorePercentage%",
                  color: Colors.white,
                  title: "Muscle",
                  crossAxisAlignment: CrossAxisAlignment.start,
                  forceDarkMode: isDarkMode),
            ),
          ),
        ],
      ),
    ]);
  }

  void _showSetsAndRepsVolumeInsightsScreen({required BuildContext context}) {
    navigateWithSlideTransition(context: context, child: SetsAndRepsVolumeInsightsScreen());
  }

  void _showRoutineLogsScreen({required BuildContext context}) {
    navigateWithSlideTransition(context: context, child: RoutineLogsScreen(dateTime: dateTime));
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
  final bool forceDarkMode;

  const _MonitorScore(
      {required this.value,
      required this.title,
      required this.color,
      required this.crossAxisAlignment,
      this.forceDarkMode = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: forceDarkMode ? Colors.white : Colors.black),
        ),
        const SizedBox(height: 4),
        Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: forceDarkMode ? Colors.white70 : Colors.black),
        )
      ],
    );
  }
}
