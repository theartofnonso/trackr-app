import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/screens/insights/sets_reps_volume_insights_screen.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/utils/navigation_utils.dart';
import 'package:tracker_app/utils/string_utils.dart';

import '../../colors.dart';
import '../../controllers/exercise_controller.dart';
import '../../controllers/routine_log_controller.dart';
import '../../enums/share_content_type_enum.dart';
import '../../strings.dart';
import '../../utils/app_analytics.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/general_utils.dart';
import '../../utils/shareables_utils.dart';
import '../buttons/opacity_button_widget.dart';
import '../calendar/calendar.dart';
import 'log_streak_monitor.dart';
import 'muscle_group_family_frequency_monitor.dart';

GlobalKey monitorKey = GlobalKey();

class OverviewMonitor extends StatelessWidget {
  final DateTime dateTime;
  final bool showInfo;

  const OverviewMonitor({super.key, required this.dateTime, this.showInfo = true});

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<RoutineLogController>(context, listen: true);

    final routineLogs = routineLogController.whereLogsIsSameMonth(dateTime: dateTime);

    final routineLogsByDay = groupBy(routineLogs, (log) => log.createdAt.withoutTime().day);

    final monthlyProgress = routineLogsByDay.length / 12;

    final exerciseController = Provider.of<ExerciseController>(context, listen: false);

    final muscleScorePercentage = calculateMuscleScoreForLogs(routineLogs: routineLogs, exercises: exerciseController.exercises);

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
              onTap: () => navigateToRoutineLogs(context: context, dateTime: dateTime),
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
              MuscleGroupFamilyFrequencyMonitor(
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
            onTap: () {
              context.push(SetsAndRepsVolumeInsightsScreen.routeName);
            },
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
    displayBottomSheet(
      context: context,
      child: Column(
        children: [
          RepaintBoundary(
            key: monitorKey,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      sapphireDark80,
                      sapphireDark,
                    ],
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Monthly Overview".toUpperCase(),
                        style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(DateTime.now().formattedDayAndMonthAndYear(),
                        style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400)),
                    const SizedBox(height: 20),
                    OverviewMonitor(
                      dateTime: dateTime,
                      showInfo: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          OpacityButtonWidget(
              onPressed: () {
                captureImage(key: monitorKey, pixelRatio: 5);
                contentShared(contentType: ShareContentType.monitor);
                Navigator.of(context).pop();
              },
              label: "Share",
              buttonColor: vibrantGreen,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14))
        ],
      ),
    );
  }

  void _onShareCalendar({required BuildContext context}) {
    displayBottomSheet(
        context: context,
        isScrollControlled: true,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RepaintBoundary(
                  key: calendarKey,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              sapphireDark80,
                              sapphireDark,
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(dateTime.formattedMonthAndYear(),
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                            ),
                            Calendar(dateTime: dateTime),
                            const SizedBox(height: 12),
                            Image.asset(
                              'images/trkr.png',
                              fit: BoxFit.contain,
                              height: 8, // Adjust the height as needed
                            ),
                          ],
                        )),
                  )),
              const SizedBox(height: 20),
              OpacityButtonWidget(
                  onPressed: () {
                    captureImage(key: calendarKey, pixelRatio: 5);
                    contentShared(contentType: ShareContentType.calender);
                    Navigator.of(context).pop();
                  },
                  label: "Share",
                  buttonColor: vibrantGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14))
            ]));
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
