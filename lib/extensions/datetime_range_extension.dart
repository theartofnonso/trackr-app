import 'package:flutter/material.dart';

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
}