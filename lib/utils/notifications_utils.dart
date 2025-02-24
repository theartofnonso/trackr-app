import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tracker_app/utils/timezone_utils.dart';

const int notificationIDLongRunningSession = 999;
const int notificationIDPreferredTraining = 900;

List<DateTime> getPreferredDateAndTimes({required List<DateTime> historicDateTimes}) {
  final Map<String, int> timeSlotCounts = {};

  // Count occurrences of each (weekday, hour, minute)
  for (final log in historicDateTimes) {
    final key = '${log.weekday}-${log.hour}-${log.minute}';
    timeSlotCounts[key] = (timeSlotCounts[key] ?? 0) + 1;
  }

  if (timeSlotCounts.isEmpty) return [];

  final maxCount = timeSlotCounts.values.reduce((a, b) => a > b ? a : b);

  final preferredSlots = timeSlotCounts.entries
      .where((entry) => entry.value == maxCount)
      .map((entry) {
    final parts = entry.key.split('-');
    final weekday = int.parse(parts[0]);
    final hour = int.parse(parts[1]);
    final minute = int.parse(parts[2]);
    return _getDateInCurrentWeek(weekday, hour, minute);
  }).toList();

  preferredSlots.sort((a, b) {
    final weekdayCompare = a.weekday.compareTo(b.weekday);
    if (weekdayCompare != 0) return weekdayCompare;

    final hourCompare = a.hour.compareTo(b.hour);
    if (hourCompare != 0) return hourCompare;

    return a.minute.compareTo(b.minute);
  });

  return preferredSlots;
}

DateTime _getDateInCurrentWeek(int weekday, int hour, int minute) {
  final now = DateTime.now();
  // Find Monday of the current week
  final monday = now.subtract(Duration(days: now.weekday - 1));
  // Calculate the date for the target weekday in the current week
  final date = monday.add(Duration(days: weekday - 1));
  // Set the time and return
  return DateTime(date.year, date.month, date.day, hour, minute);
}

void schedulePreferredTrainingReminders({required List<DateTime> historicDateTimes}) {
  if (Platform.isIOS) {
    final trainingTimes = getPreferredDateAndTimes(historicDateTimes: historicDateTimes);

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
