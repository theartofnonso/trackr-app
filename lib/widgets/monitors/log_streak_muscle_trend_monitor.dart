import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/screens/logs/routine_logs_screen.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/utils/navigation_utils.dart';
import 'package:tracker_app/utils/string_utils.dart';

import '../../colors.dart';
import '../../controllers/exercise_and_routine_controller.dart';
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

  const LogStreakMuscleTrendMonitor({super.key, required this.dateTime, this.showInfo = true});

  @override
  Widget build(BuildContext context) {
    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final routineLogs = exerciseAndRoutineController.whereLogsIsSameMonth(dateTime: dateTime);

    final routineLogsByDay = groupBy(routineLogs, (log) => log.createdAt.withoutTime().day);

    final monthlyProgress = routineLogsByDay.length / 12;

    final muscleScorePercentage =
        calculateMuscleScoreForLogs(routineLogs: routineLogs);

    return Stack(children: [
      if (showInfo)
        Positioned.fill(
          left: 12,
          child: GestureDetector(
            onTap: () => _showMonitorInfo(context: context),
            child: const Align(
                alignment: Alignment.bottomLeft,
                child: FaIcon(FontAwesomeIcons.circleInfo, color: Colors.white38, size: 18)),
          ),
        ),
      if (showInfo)
        Positioned.fill(
          right: 12,
          child: GestureDetector(
            onTap: () => _showShareBottomSheet(context: context),
            child: const Align(
                alignment: Alignment.bottomRight,
                child: FaIcon(FontAwesomeIcons.arrowUpFromBracket, color: Colors.white, size: 19)),
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
                ),
              )),
          const SizedBox(width: 20),
          GestureDetector(
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
              MuscleTrendMonitor(
                  value: muscleScorePercentage / 100, width: 70, height: 70, strokeWidth: 6),
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
            onTap: () => _showSetsAndRepsVolumeInsightsScreen(context: context),
            child: Container(
              color: Colors.transparent,
              width: 80,
              child: _MonitorScore(
                value: "$muscleScorePercentage%",
                color: Colors.white,
                title: "Muscle",
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
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

  void _showShareBottomSheet({required BuildContext context}) {
    displayBottomSheet(
        context: context,
        child: SafeArea(
          child: Column(children: [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(Icons.monitor_heart_rounded, size: 18),
              horizontalTitleGap: 6,
              title: Text("Share Streak and Muscle Monitor",
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: () {
                Navigator.of(context).pop();
                _onShareMonitor(context: context);
              },
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.calendar, size: 18),
              horizontalTitleGap: 6,
              title: Text("Share Log Calendar",
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: () {
                Navigator.of(context).pop();
                _onShareCalendar(context: context);
              },
            ),
          ]),
        ));
  }

  void _onShareMonitor({required BuildContext context}) {
    onShare(
        context: context,
        globalKey: monitorKey,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white70,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Monthly Overview".toUpperCase(),
                      style: GoogleFonts.ubuntu(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 1),
                  Text(DateTime.now().formattedDayAndMonthAndYear(),
                      style: GoogleFonts.ubuntu(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
              child: LogStreakMuscleTrendMonitor(
                dateTime: dateTime,
                showInfo: false,
              ),
            ),
            const SizedBox(height: 14),
          ],
        ));
  }

  void _onShareCalendar({required BuildContext context}) {
    onShare(
        context: context,
        globalKey: calendarKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(dateTime.formattedMonthAndYear(),
                  textAlign: TextAlign.left,
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
            ),
            Calendar(dateTime: dateTime),
            const SizedBox(height: 12),
            Image.asset(
              'images/trkr.png',
              fit: BoxFit.contain,
              height: 8, // Adjust the height as needed
            ),
          ],
        ));
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
