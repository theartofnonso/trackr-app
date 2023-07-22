import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DurationExtension on Duration {
  int _absoluteDuration(duration) {
    return duration > 59 ? (duration % 60) : duration;
  }

  String friendlyTime() {
    return "$inHours hrs  ${_absoluteDuration(inMinutes)} mins  ${_absoluteDuration(inSeconds)} secs";
  }
}

extension DateTimeExtension on DateTime {

  /// Get datetime format
  String formattedDay() {
    return DateFormat("dd", "en").format(this);
  }

  /// Get datetime format
  String formattedMonth() {
    return DateFormat("MMM", "en").format(this);
  }

  /// Get datetime format
  String formattedDate() {
    return DateFormat("EE dd, MMM", "en").format(this);
  }

  /// Get datetime format
  String formattedTime() {
    return DateFormat("Hm", "en").format(this);
  }

  bool isAfterOrEqual(DateTime other) {
    return isAtSameMomentAs(other) || isAfter(other);
  }

  bool isBeforeOrEqual(DateTime other) {
    return isAtSameMomentAs(other) || isBefore(other);
  }

  bool isBetween({required DateTime from, required DateTime to}) {
    return isAfterOrEqual(from) && isBeforeOrEqual(to);
  }

  bool isBetweenRange({required DateTimeRange range}) {
    return isBetween(from: range.start, to: range.end);
  }

  bool isBetweenExclusive({required DateTime from, required DateTime to}) {
    return isAfter(from) && isBefore(to);
  }

}

extension DateTimeRangeExtension on DateTimeRange {

  DateTimeRange endInclusive() {
    return start.isAtSameMomentAs(end) ? DateTimeRange(start: start, end: start.add(const Duration(days: 1))) : DateTimeRange(start: start, end: end.add(const Duration(days: 1)));
  }
}

