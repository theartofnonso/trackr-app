import 'package:timezone/timezone.dart' as tz;

tz.TZDateTime _nextInstanceOfHour({required int hour, required int minutes}) {
  final DateTime now = DateTime.now();
  tz.TZDateTime scheduledDate = tz.TZDateTime.from(
    DateTime(now.year, now.month, now.day, hour, 0, 0, 0, 0),
    tz.local,
  );

  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }

  return scheduledDate;
}

tz.TZDateTime nextInstanceOfWeekDayAndHour({required int hour, required minutes, required int weekday}) {
  tz.TZDateTime scheduledDate = _nextInstanceOfHour(hour: hour, minutes: minutes);
  while (scheduledDate.weekday != weekday) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  print(scheduledDate);
  return scheduledDate;
}
