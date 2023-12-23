import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {

  /// Get datetime format
  String abbreviatedMonth() {
    return DateFormat("LLL", "en").format(this);
  }

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

    // Calculate the last day of the current week (Sunday)
    int daysToAdd = DateTime.sunday - weekday;

    // Create a DateTime object representing the last moment of the current week
    DateTime endOfWeek = DateTime(year, month, day + daysToAdd, 23, 59, 59);

    return endOfWeek;
  }

  DateTime lastMonthDay() {

    // Calculate the first day of the next month
    DateTime firstDayNextMonth = (month < 12) ?
    DateTime(year, month + 1, 1) :
    DateTime(year + 1, 1, 1);

    // Subtract one day to get the last day of the current month
    DateTime lastDayCurrentMonth = firstDayNextMonth.subtract(const Duration(days: 1));

    // Create a DateTime object representing the last moment of the current month
    DateTime endOfMonth = DateTime(lastDayCurrentMonth.year, lastDayCurrentMonth.month, lastDayCurrentMonth.day, 23, 59, 59);

    return endOfMonth;
  }

  DateTime localDate() {
    return DateTime(year, month, day, 0, 0, 0);
  }
}

