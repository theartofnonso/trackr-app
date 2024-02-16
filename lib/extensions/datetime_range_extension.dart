import 'package:flutter/material.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

extension DateTimeRangeExtension on DateTimeRange {

  List<DateTime> get dates {
    List<DateTime> dates = [];
    DateTime currentDate = start;

    while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
      // Add current date to the list
      dates.add(currentDate);
      // Move to the next day
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return dates;
  }

  List<DateTime> get datesToNow {
    List<DateTime> dates = [];
    final now = DateTime.now();
    DateTime startDate = start;
    DateTime endDateDate = now.isSameMonthYear(end) ? now : end;

    while (startDate.isBefore(endDateDate) || startDate.isAtSameMomentAs(endDateDate)) {
      // Add current date to the list
      dates.add(startDate);
      // Move to the next day
      startDate = startDate.add(const Duration(days: 1));
    }

    return dates;
  }
}