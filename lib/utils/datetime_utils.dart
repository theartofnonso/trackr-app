import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum DurationType {
  seconds("Seconds", "Secs"),
  minutes("Minutes", "Mins"),
  hours("Hours", "Hrs");

  const DurationType(this.longName, this.shortName);

  final String longName;
  final String shortName;
}

extension DurationExtension on Duration {
  String _absoluteDuration(duration) {
    final durationInNum = duration > 59 ? (duration % 60) : duration;
    return durationInNum.toString().padLeft(2, "0");
  }

  String secondsOrMinutesOrHours() {
    String display;
    final remainingSeconds = inSeconds.remainder(60);
    final remainingMinutes = inMinutes.remainder(60);
    final remainingHours = inHours.remainder(24);
    if (inHours > 24) {
      if(remainingHours > 0 && remainingMinutes > 0 && remainingSeconds > 0) {
        display = "${inDays}d ${remainingHours}h ${remainingMinutes}m ${remainingSeconds}s";
      } else if(remainingHours > 0 && remainingMinutes > 0 && remainingSeconds <= 0) {
        display = "${inDays}d ${inHours}h ${remainingMinutes}m";
      } else if(remainingHours > 0 && remainingMinutes <= 0 && remainingSeconds <= 0) {
        display = "${inDays}d ${inHours}h";
      }  else {
        display = "${inHours}h";
      }
    } else if (inMinutes > 59) {
      if(remainingMinutes > 0 && remainingSeconds > 0) {
        display = "${inHours}h ${remainingMinutes}m ${remainingSeconds}s";
      } else if(remainingMinutes > 0 && remainingSeconds <= 0) {
        display = "${inHours}h ${remainingMinutes}m";
      }  else {
        display = "${inHours}h";
      }
    } else if (inSeconds > 59) {
      display = remainingSeconds > 0 ? "${inMinutes}m ${remainingSeconds}s" : "${inMinutes}m";
    } else {
      display = "${inSeconds}s";
    }
    return display;
  }

  String friendlyTime() {
    return "${inHours.toString().padLeft(2, "0")} : ${_absoluteDuration(inMinutes)} : ${_absoluteDuration(inSeconds)}";
  }

  ({DurationType type, int durationValue}) nearestDuration() {
    final duration = this;

    if (duration.inHours > 0) {
      return (durationValue: duration.inHours, type: DurationType.hours);
    }

    if (duration.inMinutes > 0) {
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
    return date.day == now.day && date.month == now.month && date.year == now.year;
  }

  bool isSameDateAs({required DateTime other}) {
    final date = this;
    return date.day == other.day && date.month == other.month && date.year == other.year;
  }

  String durationSinceOrDate() {

    String display;

    final date = this;
    final duration = DateTime.now().difference(date);

    if(duration.inDays > 30) {
      display = date.formattedDayAndMonthAndYear();
    } else if(duration.inDays > 21) {
      display = "3 weeks ago";
    } else if(duration.inDays > 14) {
      display = "2 weeks ago";
    } else if(duration.inDays > 7) {
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

  String timeOfDay() {
    var hour = this.hour;
    if (hour < 12) {
      return 'Morning';
    }
    if (hour < 17) {
      return 'Afternoon';
    }
    return 'Evening';
  }
}

extension DateTimeRangeExtension on DateTimeRange {
  DateTimeRange endInclusive() {
    return start.isAtSameMomentAs(end)
        ? DateTimeRange(start: start, end: start.add(const Duration(days: 1)))
        : DateTimeRange(start: start, end: end.add(const Duration(days: 1)));
  }
}
