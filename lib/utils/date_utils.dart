import 'package:flutter/material.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';

DateTimeRange yearToDateTimeRange({required DateTime datetime}) {
  final now = datetime.withoutTime();
  final start = DateTime(now.year, 1);
  final end = DateTime(now.year, datetime.month, datetime.day);
  return DateTimeRange(start: start, end: end);
}

DateTimeRange theLastYearDateTimeRange() {
  DateTime now = DateTime.now().withoutTime();
  DateTime oneYearAgo = now.subtract(const Duration(days: 365));
  DateTime then = DateTime(oneYearAgo.year, oneYearAgo.month, 1);

  // Create a DateTimeRange from one year ago to now
  return DateTimeRange(start: then, end: now);
}

/// Returns a list of DateTimeRange representing each week in the given year.
List<DateTimeRange> generateWeeksInRange({required DateTimeRange range}) {
  List<DateTimeRange> weeks = [];

  if (range.start.isAfter(range.end)) {
    return weeks;
  }

  // Adjust a date to the previous Monday (or same day if it's Monday)
  DateTime getMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // Adjust a date to the next Sunday (or same day if it's Sunday)
  DateTime getSunday(DateTime date) {
    return date.add(Duration(days: DateTime.daysPerWeek - date.weekday));
  }

  // Calculate the first Monday (start of the first week)
  DateTime firstMonday = getMonday(range.start);
  // Calculate the last Sunday (end of the last week)
  DateTime lastSunday = getSunday(range.end);

  DateTime currentMonday = firstMonday;
  while (currentMonday.isBefore(lastSunday) || currentMonday == lastSunday) {
    DateTime currentSunday = currentMonday.add(const Duration(days: 6));
    weeks.add(DateTimeRange(start: currentMonday, end: currentSunday));
    currentMonday = currentMonday.add(const Duration(days: 7));
  }

  return weeks;
}

/// Returns a list of DateTimeRange representing each month in the given range.
List<DateTimeRange> generateMonthsInRange({required DateTimeRange range}) {
  List<DateTimeRange> months = [];

  // Ensure that the startDate is not after the endDate
  if (range.start.isAfter(range.end)) {
    return months; // Return empty list if dates are invalid
  }

  // Set currentStartDate to the first day of the month of range.start
  DateTime currentStartDate = DateTime(range.start.year, range.start.month, 1);

  while (!currentStartDate.isAfter(range.end)) {
    // Get the last day of the current month
    DateTime currentEndDate = DateTime(currentStartDate.year, currentStartDate.month + 1, 0);

    /// Adjust currentEndDate if it's beyond range.end
    /// Only uncomment this if you want last day to be current date
    // if (currentEndDate.isAfter(range.end)) {
    //   currentEndDate = range.end;
    // }

    months.add(DateTimeRange(start: currentStartDate, end: currentEndDate));

    // Move currentStartDate to the first day of the next month
    currentStartDate = DateTime(currentStartDate.year, currentStartDate.month + 1, 1);
  }

  return months;
}

DateTimeRange thisMonthDateRange({DateTime? endDate}) {
  final now = DateTime.now();
  final currentWeekDate = DateTime(now.year, now.month, now.day);
  final startOfMonth = DateTime(currentWeekDate.year, currentWeekDate.month, 1);
  final endOfMonth = endDate ?? DateTime(currentWeekDate.year, currentWeekDate.month + 1, 0);
  return DateTimeRange(start: startOfMonth, end: endOfMonth);
}