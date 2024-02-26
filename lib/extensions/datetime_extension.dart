import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  /// Get datetime format
  String abbreviatedMonth() {
    return DateFormat("LLL", "en").format(this);
  }

  /// Get datetime format
  String abbreviatedMonthAndYear() {
    return DateFormat("LLL, yy", "en").format(this);
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
  String shortDayAndMonthAndYear() {
    return DateFormat("dd MMM, yy", "en").format(this);
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
    return isSameDayMonthYear(other) || isAfter(other);
  }

  bool isBeforeOrEqual(DateTime other) {
    return isSameDayMonthYear(other) || isBefore(other);
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

  bool isSameDayMonthYear(DateTime other) {
    final date = this;
    return date.day == other.day && date.month == other.month && date.year == other.year;
  }

  bool isSameMonthYear(DateTime other) {
    final date = this;
    return date.month == other.month && date.year == other.year;
  }

  String durationSinceOrDate() {
    final now = DateTime.now();
    final duration = now.difference(this);

    if (duration.inDays > 29) {
      return formattedDayAndMonthAndYear();
    } else if (duration.inDays >= 20) {
      return "3 weeks ago";
    } else if (duration.inDays >= 13) {
      return "2 weeks ago";
    } else if (duration.inDays >= 6) {
      return "1 week ago";
    } else if (duration.inDays >= 1) {
      return _pluralize(duration.inDays, "day");
    } else if (duration.inHours >= 23) {
      return "Yesterday";
    } else if (duration.inHours >= 1) {
      return _pluralize(duration.inHours, "hour");
    } else if (duration.inMinutes >= 1) {
      return _pluralize(duration.inMinutes, "minute");
    } else {
      return "now";
    }
  }

  String _pluralize(int count, String noun) {
    return "$count $noun${count > 1 ? 's' : ''} ago";
  }

  DateTime lastWeekDay() {
    // Calculate the last day of the current week (Sunday)
    int daysToAdd = DateTime.sunday - weekday;

    // Create a DateTime object representing the last moment of the current week
    DateTime endOfWeek = DateTime(year, month, day + daysToAdd, 23, 59, 59);

    return endOfWeek;
  }

  DateTime lastDayOfMonth() {
    // Calculate the first day of the next month
    DateTime firstDayNextMonth = (month < 12) ? DateTime(year, month + 1, 1) : DateTime(year + 1, 1, 1);

    // Subtract one day to get the last day of the current month
    DateTime lastDayCurrentMonth = firstDayNextMonth.subtract(const Duration(days: 1));

    // Create a DateTime object representing the last moment of the current month
    DateTime endOfMonth =
        DateTime(lastDayCurrentMonth.year, lastDayCurrentMonth.month, lastDayCurrentMonth.day, 23, 59, 59);

    return endOfMonth;
  }

  DateTime localDate() {
    return DateTime(year, month, day, 0, 0, 0);
  }

  bool withinCurrentYear() {
    final datetime = DateTime(year, month, day);
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);
    final currentYearRange = DateTimeRange(start: startOfYear, end: endOfYear);

    return datetime.isBetweenRange(range: currentYearRange);
  }

  DateTime withoutTime() {
    return DateTime(year, month, day);
  }

  DateTime withHourOnly() {
    return DateTime(year, month, day, hour);
  }

  DateTime previous90Days() {
    return subtract(const Duration(days: 90)).withoutTime();
  }

  List<DateTime> datesForWeek() {
    List<DateTime> weekDates = [];
    // Subtract the weekday number from the current date to get to the first day of the week
    // Dart's DateTime.weekday returns 1 for Monday and 7 for Sunday
    DateTime firstDayOfWeek = subtract(Duration(days: weekday - 1));

    // Iterate from the first day of the week to the next 7 days
    for (int i = 0; i < 7; i++) {
      // Add each day to the list
      weekDates.add(firstDayOfWeek.add(Duration(days: i)).withoutTime());
    }

    return weekDates;
  }

  DateTimeRange lastWeekRange() {
    DateTime today = DateTime(year, month, day);
    DateTime endOfLastWeek = today.subtract(Duration(days: today.weekday)); // Assuming week starts on Sunday
    DateTime startOfLastWeek = endOfLastWeek.subtract(const Duration(days: 6));
    return DateTimeRange(start: startOfLastWeek, end: endOfLastWeek);
  }

  DateTimeRange currentWeekRange() {
    DateTime today = DateTime(year, month, day); // Use DateTime.now() to get the current date and time
    DateTime startOfCurrentWeek = today.subtract(const Duration(days: 6));
    DateTime endOfCurrentWeek = startOfCurrentWeek.add(const Duration(days: 6));
    return DateTimeRange(start: startOfCurrentWeek, end: endOfCurrentWeek);
  }

  DateTime oneWeekFromToday() {
    DateTime today = DateTime(year, month, day);
    final numberOfDaysUntilNextWeek = 7 - today.weekday;
    return today.add(Duration(days: numberOfDaysUntilNextWeek + 1));
  }
}
