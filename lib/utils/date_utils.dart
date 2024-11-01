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
List<DateTimeRange> generateWeeksInRange({required DateTimeRange range}) {
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
