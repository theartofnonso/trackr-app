import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tracker_app/utils/timezone_utils.dart';

const int notificationIDLongRunningSession = 999;
const int notificationIDPreferredTraining = 900;

List<DateTime> getPreferredDateAndTimes({required List<DateTime> historicDateTimes}) {
  final Map<String, List<DateTime>> timeGroups = {};
  final Map<String, DateTime> latestTimes = {};

  for (final log in historicDateTimes) {
    final key = '${log.weekday}-${log.hour}-${log.minute}';
    timeGroups.putIfAbsent(key, () => []).add(log);

    final currentLatest = latestTimes[key];
    if (currentLatest == null || log.isAfter(currentLatest)) {
      latestTimes[key] = log;
    }
  }

  if (timeGroups.isEmpty) return [];

  final maxCount = timeGroups.values.map((logs) => logs.length).reduce((a, b) => a > b ? a : b);

  final preferredTimes = timeGroups.entries
      .where((entry) => entry.value.length == maxCount)
      .map((entry) => latestTimes[entry.key]!)
      .toList();

  preferredTimes.sort((a, b) {
    final weekdayCompare = a.weekday.compareTo(b.weekday);
    if (weekdayCompare != 0) return weekdayCompare;

    final hourCompare = a.hour.compareTo(b.hour);
    if (hourCompare != 0) return hourCompare;

    return a.minute.compareTo(b.minute);
  });

  return preferredTimes;
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
      notificationIDPreferredTraining,
      "Time to Get Moving!",
      "You usually train around this time—let’s keep up the habit and crush today’s workout!",
      tzDateTime,
      const NotificationDetails(),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: matchDateTimeComponents,
      androidScheduleMode: AndroidScheduleMode.exact);
}
