import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum DurationType {
  seconds("Seconds", "Secs"), minutes("Minutes", "Mins"), hours("Hours", "Hrs");

  const DurationType(this.longName, this.shortName);

  final String longName;
  final String shortName;
}

extension DurationExtension on Duration {
  String _absoluteDuration(duration) {
    final durationInNum = duration > 59 ? (duration % 60) : duration;
    return durationInNum.toString().padLeft(2, "0");
  }

  String friendlyTime() {
    return "${inHours.toString().padLeft(2, "0")} : ${_absoluteDuration(inMinutes)} : ${_absoluteDuration(inSeconds)}";
  }

  ({DurationType type, int durationValue}) nearestDuration() {

    final duration = this;

    if(duration.inHours > 0) {
      return (durationValue: duration.inHours, type: DurationType.hours);
    }

    if(duration.inMinutes > 0) {
      return (durationValue: duration.inMinutes, type: DurationType.minutes);
    }

    return (durationValue: duration.inSeconds.round(), type: DurationType.seconds);
  }

}

extension DateTimeExtension on DateTime {

  /// Get datetime format
  String formattedDay() {
    return DateFormat("dd", "en").format(this);
  }

  /// Get datetime format
  String formattedMonthAndYear() {
    return DateFormat("MMMM, yyyy", "en").format(this);
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

  bool isNow() {
    final date = this;
    final now = DateTime.now();
    return date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
  }

  bool isSameDateAs({required DateTime other}) {
    final date = this;
    return date.day == other.day &&
        date.month == other.month &&
        date.year == other.year;
  }

}

extension DateTimeRangeExtension on DateTimeRange {

  DateTimeRange endInclusive() {
    return start.isAtSameMomentAs(end) ? DateTimeRange(start: start, end: start.add(const Duration(days: 1))) : DateTimeRange(start: start, end: end.add(const Duration(days: 1)));
  }
}

