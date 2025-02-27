import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tracker_app/utils/timezone_utils.dart';

const int notificationIDLongRunningSession = 999;

class _ReminderTime {
  final int weekday;
  final int hour;

  _ReminderTime({required this.weekday, required this.hour});

  @override
  String toString() => '$weekday at $hour:00';
}

List<_ReminderTime> _getExerciseReminders(List<DateTime> logDates) {
  // Group exercise hours by weekday
  final Map<int, List<int>> weekdayHours = {};
  for (final logDate in logDates) {
    final hour = logDate.hour;
    weekdayHours.putIfAbsent(logDate.weekday, () => []).add(hour);
  }

  final List<_ReminderTime> reminders = [];

  // Process each weekday to find most frequent hour
  weekdayHours.forEach((weekday, hours) {
    if (hours.isEmpty) return;

    // Count frequency of each hour
    final hourCounts = <int, int>{};
    for (final hour in hours) {
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    // Sort hours by frequency (desc) and time (asc)
    final sortedEntries = hourCounts.entries.toList()
      ..sort((a, b) {
        final countCompare = b.value.compareTo(a.value);
        return countCompare != 0 ? countCompare : a.key.compareTo(b.key);
      });

    reminders.add(_ReminderTime(
      weekday: weekday,
      hour: sortedEntries.first.key,
    ));
  });

  reminders.sort((a, b) => a.weekday.compareTo(b.weekday));

  return reminders;
}

void schedulePreferredTrainingReminders({required List<DateTime> historicDateTimes}) {
  if (Platform.isIOS) {
    final trainingTimes = _getExerciseReminders(historicDateTimes);

    for (final trainingTime in trainingTimes) {
      final hour = Duration(hours: trainingTime.hour);
      final weekDay = trainingTime.weekday;
      _scheduleNotification(duration: hour, weekday: weekDay);
    }
  }
}

Future<void> _scheduleNotification({required Duration duration, required int weekday}) async {
  final tzDateTime = nextInstanceOfHourAndWeekDay(hours: duration.inHours, weekday: weekday);

  const matchDateTimeComponents = DateTimeComponents.dayOfWeekAndTime;

  await FlutterLocalNotificationsPlugin().zonedSchedule(
      weekday,
      "Time to Get Moving!",
      "You usually train around this time—let’s keep up the habit and crush today’s workout!",
      tzDateTime,
      const NotificationDetails(),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: matchDateTimeComponents,
      androidScheduleMode: AndroidScheduleMode.exact);
}
