import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/utils/string_utils.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../enums/posthog_analytics_event.dart';
import '../../strings/strings.dart';
import '../../utils/general_utils.dart';
import '../../utils/shareables_utils.dart';
import '../calendar/calendar.dart';

GlobalKey monitorKey = GlobalKey();

class LogStreakMonitor extends StatelessWidget {
  final DateTime dateTime;
  final bool showInfo;
  final bool forceDarkMode;

  const LogStreakMonitor({super.key, required this.dateTime, this.showInfo = true, this.forceDarkMode = false});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark || forceDarkMode;

    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final routineLogs = exerciseAndRoutineController.whereLogsIsSameMonth(dateTime: dateTime);

    final routineLogsByDay = groupBy(routineLogs, (log) => log.createdAt.withoutTime().day);

    final monthlyProgress = routineLogsByDay.length;

    final trainingDays = routineLogs.map((log) => log.createdAt).toList();
    final averageRestDays = _calculateAverageRestDays(dates: trainingDays);

    return Stack(children: [
      if (showInfo)
        Positioned.fill(
          left: 12,
          child: GestureDetector(
            onTap: () => _showMonitorInfo(context: context),
            child: const Align(alignment: Alignment.bottomLeft, child: FaIcon(FontAwesomeIcons.circleInfo, size: 18)),
          ),
        ),
      if (showInfo)
        Positioned.fill(
          right: 12,
          child: GestureDetector(
            onTap: () => _showShareBottomSheet(context: context),
            child: const Align(
                alignment: Alignment.bottomRight, child: FaIcon(FontAwesomeIcons.arrowUpFromBracket, size: 19)),
          ),
        ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: _MonitorScore(
                value:
                    "${routineLogsByDay.length} ${pluralize(word: "DAY", count: routineLogsByDay.length).toUpperCase()}",
                title: "Log Streak",
                color: logStreakColor(monthlyProgress),
                crossAxisAlignment: CrossAxisAlignment.end,
                forceDarkMode: isDarkMode),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            child: Stack(alignment: Alignment.center, children: [
              LogStreakWidget(
                  value: monthlyProgress, width: 100, height: 100, strokeWidth: 6, forceDarkMode: isDarkMode),
              Image.asset(
                'images/trkr.png',
                fit: BoxFit.contain,
                color: isDarkMode ? Colors.white70 : Colors.black,
                height: 8, // Adjust the height as needed
              )
            ]),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 80,
            child: _MonitorScore(
                value: "$averageRestDays ${pluralize(word: "day", count: averageRestDays).toUpperCase()}",
                color: Colors.white,
                title: "AVG Rest",
                crossAxisAlignment: CrossAxisAlignment.start,
                forceDarkMode: isDarkMode),
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
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(Icons.monitor_heart_rounded, size: 18),
              horizontalTitleGap: 6,
              title: Text("Share Streak Monitor"),
              onTap: () {
                Navigator.of(context).pop();
                _onShareMonitor(context: context, dateTime: dateTime);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.calendar, size: 18),
              horizontalTitleGap: 6,
              title: Text("Share Log Calendar"),
              onTap: () {
                Navigator.of(context).pop();
                _onShareCalendar(context: context);
              },
            ),
          ]),
        ));
  }

  void _onShareMonitor({required DateTime dateTime, required BuildContext context}) {
    Posthog().capture(eventName: PostHogAnalyticsEvent.shareMonitor.displayName);
    onShare(
        context: context,
        globalKey: monitorKey,
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("${dateTime.abbreviatedMonthAndYear()} Overview".toUpperCase(),
                  style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              LogStreakMonitor(
                dateTime: dateTime,
                showInfo: false,
                forceDarkMode: true,
              ),
            ],
          ),
        ));
  }

  void _onShareCalendar({required BuildContext context}) {
    Posthog().capture(eventName: PostHogAnalyticsEvent.shareCalendar.displayName);
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
            Calendar(dateTime: dateTime, forceDarkMode: true),
            const SizedBox(height: 12),
            Image.asset(
              'images/trkr.png',
              fit: BoxFit.contain,
              height: 8,
              color: Colors.white70, // Adjust the height as needed
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

class LogStreakWidget extends StatelessWidget {
  final num value;
  final double width;
  final double height;
  final double strokeWidth;
  final bool forceDarkMode;

  const LogStreakWidget(
      {super.key,
      this.value = 0,
      required this.width,
      required this.height,
      required this.strokeWidth,
      this.forceDarkMode = false});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark || forceDarkMode;

    return SizedBox(
      width: height,
      height: width,
      child: CircularProgressIndicator(
        value: value / 12,
        strokeWidth: strokeWidth,
        backgroundColor: isDarkMode ? Colors.black12 : Colors.grey.shade200,
        strokeCap: StrokeCap.butt,
        valueColor: AlwaysStoppedAnimation<Color>(logStreakColor(value)),
      ),
    );
  }
}

int _calculateAverageRestDays({required List<DateTime> dates}) {
  if (dates.isEmpty) {
    return 0;
  }

  // Check if all dates are in the same month
  final firstDate = dates.first;
  for (final date in dates) {
    if (date.year != firstDate.year || date.month != firstDate.month) {
      throw ArgumentError('All training dates must be in the same month.');
    }
  }

  // Calculate total days in the month
  final year = firstDate.year;
  final month = firstDate.month;
  final firstDayNextMonth = DateTime(year, month + 1, 1);
  final lastDayOfMonth = firstDayNextMonth.subtract(const Duration(days: 1));
  final totalDays = lastDayOfMonth.day;

  // Extract training days (day of month)
  final trainingDays = dates.map((date) => date.day).toList();

  // Calculate number of weeks (ceiling division)
  final numberOfWeeks = (totalDays + 6) ~/ 7;
  var totalRestDays = 0;

  for (var week = 1; week <= numberOfWeeks; week++) {
    final startDay = (week - 1) * 7 + 1;
    var endDay = week * 7;
    if (endDay > totalDays) {
      endDay = totalDays;
    }

    final daysInWeek = endDay - startDay + 1;
    final trainingInWeek = trainingDays.where((day) => day >= startDay && day <= endDay).length;
    final restDays = daysInWeek - trainingInWeek;

    totalRestDays += restDays;
  }

  return (totalRestDays / numberOfWeeks).round();
}
