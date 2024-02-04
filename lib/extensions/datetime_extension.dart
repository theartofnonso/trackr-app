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

  Duration nextMorning() {
    DateTime now = DateTime.now();

    DateTime dayAfterNextMorning = DateTime(now.year, now.month, now.day + 2, 1, 0);

    Duration duration = dayAfterNextMorning.difference(now);

    return duration;
  }

  bool withinCurrentYear() {
    final datetime = DateTime(year, month, day);
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);
    final currentYearRange = DateTimeRange(start: startOfYear, end: endOfYear);

    return datetime.isBetweenRange(range: currentYearRange);
  }

  DateTime dateOnly() {
    return DateTime(year, month, day);
  }
}
