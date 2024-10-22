
import 'package:flutter/material.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

DateTimeRange yearToDateTimeRange({DateTime? datetime}) {
  final now = datetime ?? DateTime.now();
  final start = DateTime(now.year, 1);
  final end = DateTime(now.year, 12, 31);
  return DateTimeRange(start: start, end: end);
}

/// Returns a list of DateTimeRange representing each week in the given year.
List<DateTimeRange> getWeeksInYear(int year) {
  List<DateTimeRange> weeks = [];
  DateTime firstDayOfYear = DateTime(year, 1, 1);
  // Find the first Monday of the year
  DateTime firstMonday = firstDayOfYear.weekday == DateTime.monday
      ? firstDayOfYear
      : firstDayOfYear.add(Duration(days: 8 - firstDayOfYear.weekday));

  for (DateTime weekStart = firstMonday;
  weekStart.year == year;
  weekStart = weekStart.add(const Duration(days: 7))) {
    DateTime weekEnd = weekStart.add(const Duration(days: 6));
    // Adjust weekEnd if it goes beyond the year
    if (weekEnd.year > year) {
      weekEnd = DateTime(year, 12, 31);
    }
    weeks.add(DateTimeRange(start: weekStart, end: weekEnd));
  }

  return weeks;
}

/// Returns a list of DateTimeRange representing each week in the given month.
List<DateTimeRange> generateWeeksInMonth(DateTime monthDate) {
  List<DateTimeRange> weeks = [];
  DateTime firstDayOfMonth = monthDate.startOfMonth();
  DateTime lastDayOfMonth = monthDate.endOfMonth();

  // Find the first Monday on or before the first day of the month
  DateTime firstMonday = firstDayOfMonth.weekday == DateTime.monday
      ? firstDayOfMonth
      : firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - DateTime.monday));

  // Iterate through each week
  for (DateTime weekStart = firstMonday;
  weekStart.isBefore(lastDayOfMonth);
  weekStart = weekStart.add(const Duration(days: 7))) {
    DateTime weekEnd = weekStart.add(const Duration(days: 6));

    // Adjust weekStart and weekEnd to be within the month
    DateTime actualStart = weekStart.isBefore(firstDayOfMonth) ? firstDayOfMonth : weekStart;
    DateTime actualEnd = weekEnd.isAfter(lastDayOfMonth) ? lastDayOfMonth : weekEnd;

    weeks.add(DateTimeRange(start: actualStart, end: actualEnd));
  }

  return weeks;
}