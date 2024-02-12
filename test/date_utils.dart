List<DateTime> generateWeeklyDateTimes({required int size, required DateTime startDate}) {
  List<DateTime> dateTimes = [];

  for (int i = 0; i < size; i++) {
    // Add 7 days for each week
    DateTime nextDate = startDate.add(Duration(days: 7 * i));
    dateTimes.add(nextDate);
  }

  return dateTimes;
}

List<DateTime> generateDailyDateTimes({required int size, required DateTime startDate}) {
  List<DateTime> dateTimes = [];

  for (int i = 0; i < size; i++) {
    // Add 7 days for each week
    DateTime nextDate = startDate.add(Duration(days: 1 * i));
    dateTimes.add(nextDate);
  }

  return dateTimes;
}
