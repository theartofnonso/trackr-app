import 'package:flutter/material.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';

DateTimeRange yearToDateTimeRange({DateTime? datetime}) {
  final now = datetime ?? DateTime.now();
  final start = DateTime(now.year, 1);
  final end = DateTime(now.year, 12, 31);
  return DateTimeRange(start: start, end: end);
}

DateTimeRange theLastYearDateTimeRange() {
  DateTime now = DateTime.now().withoutTime();
  DateTime oneYearAgo = now.subtract(const Duration(days: 365));

  // Create a DateTimeRange from one year ago to now
  return DateTimeRange(start: oneYearAgo, end: now);
}

/// Returns a list of DateTimeRange representing each week in the given year.
List<DateTimeRange> generateWeeksInYear({required DateTimeRange range}) {
  List<DateTimeRange> weeks = [];

  // Ensure that the startDate is not after the endDate
  if (range.start.isAfter(range.end)) {
    return weeks; // Return empty list if dates are invalid
  }

  DateTime currentStartDate = DateTime(range.start.year, range.start.month, range.start.day - (range.start.weekday - 1) % 7);

  while (!currentStartDate.isAfter(range.end)) {
    // Calculate the end date for the current week
    DateTime currentEndDate = currentStartDate.add(const Duration(days: 6));

    // If the calculated end date is after the overall end date, adjust it
    if (currentEndDate.isAfter(currentEndDate)) {
      currentEndDate = currentEndDate;
    }

    weeks.add(DateTimeRange(start: currentStartDate, end: currentEndDate));

    // Move to the next week
    currentStartDate = currentEndDate.add(const Duration(days: 1));
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
