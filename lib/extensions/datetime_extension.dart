import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  /// Get datetime format
  String formattedDay() {
    return DateFormat("dd", "en").format(this);
  }

  /// Get datetime format
  String formattedMonthAndYear() {
    return DateFormat("MMMM yyyy", "en").format(this);
  }

  /// Get datetime format
  String formattedDayAndMonth() {
    return DateFormat("MMM dd", "en").format(this);
  }

  /// Get datetime format
  String formattedDayAndMonthAndYear() {
    return DateFormat("EE dd MMM, yyyy", "en").format(this);
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
    return isSameDateAs(other) || isAfter(other);
  }

  bool isBeforeOrEqual(DateTime other) {
    return isSameDateAs(other) || isBefore(other);
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
    return date.day == now.day && date.month == now.month && date.year == now.year;
  }

  bool isSameDateAs(DateTime other) {
    final date = this;
    return date.day == other.day && date.month == other.month && date.year == other.year;
  }

  String durationSinceOrDate() {

    String display;

    final date = this;
    final duration = DateTime.now().difference(date);

    if(duration.inDays > 29) {
      display = date.formattedDayAndMonthAndYear();
    } else if(duration.inDays > 20) {
      display = "3 weeks ago";
    } else if(duration.inDays > 13) {
      display = "2 weeks ago";
    } else if(duration.inDays > 6) {
      display = "1 week ago";
    } else if(duration.inDays == 1) {
      display = "Yesterday";
    } else if(duration.inHours > 24) {
      display = "${duration.inDays} days ago";
    } else if(duration.inMinutes > 59) {
      display = duration.inHours == 1 ? "${duration.inHours} hour ago" : "${duration.inHours} hours ago";
    } else if(duration.inSeconds > 59) {
      display = duration.inMinutes == 1 ? "${duration.inMinutes} minute ago" : "${duration.inMinutes} minutes ago";
    } else {
      display = "now";
    }

    return display;
  }

  DateTime lastWeekDay() {

    // Calculate the number of days remaining until the end of the week (Sunday)
    int remainingDays = 7 - weekday;

    // Add the remaining days to the current date
    DateTime lastDayOfCurrentWeek = add(Duration(days: remainingDays));

    // Set the time to the end of the day (23:59:59)
    lastDayOfCurrentWeek = DateTime(
      lastDayOfCurrentWeek.year,
      lastDayOfCurrentWeek.month,
      lastDayOfCurrentWeek.day,
      23,
      59,
      59,
    );

    return lastDayOfCurrentWeek;
  }
}

