import 'package:timezone/timezone.dart' as tz;

tz.TZDateTime _nextInstanceOfHour({required int hour, required int minutes}) {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minutes);
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}

tz.TZDateTime nextInstanceOfWeekDayAndHour({required int hour, required minutes,  required int weekday}) {
  tz.TZDateTime scheduledDate = _nextInstanceOfHour(hour: hour, minutes: minutes);
  while (scheduledDate.weekday != weekday) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}