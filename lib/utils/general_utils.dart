import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/screens/preferences/settings_screen.dart';

import '../colors.dart';
import '../enums/muscle_group_enums.dart';
import '../shared_prefs.dart';

bool _isDefaultWeightUnit() {
  final weightString = SharedPrefs().weightUnit;
  final weightUnit = WeightUnit.fromString(weightString);
  return weightUnit == WeightUnit.kg;
}

double weightWithConversion({required num value}) {
  return _isDefaultWeightUnit() ? value.toDouble() : toLbs(value.toDouble());
}

String weightLabel() {
  return SharedPrefs().weightUnit;
}

double toKg(double value) {
  final conversion = value / 2.205;
  return double.parse(conversion.toStringAsFixed(2));
}

double toLbs(double value) {
  final conversion = value * 2.205;
  return double.parse(conversion.toStringAsFixed(2));
}

void toggleWeightUnit({required WeightUnit unit}) {
  SharedPrefs().weightUnit = unit.name;
}

String timeOfDay() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Morning';
  }
  if (hour < 17) {
    return 'Afternoon';
  }
  return 'Evening';
}

DateTimeRange thisWeekDateRange() {
  final now = DateTime.now();
  final currentWeekDate = DateTime(now.year, now.month, now.day);
  final startOfWeek = currentWeekDate.subtract(Duration(days: currentWeekDate.weekday - 1));
  final endOfWeek = currentWeekDate.add(Duration(days: 7 - currentWeekDate.weekday));
  return DateTimeRange(start: startOfWeek, end: endOfWeek);
}

DateTimeRange thisMonthDateRange({DateTime? endDate}) {
  final now = DateTime.now();
  final currentWeekDate = DateTime(now.year, now.month, now.day);
  final startOfMonth = DateTime(currentWeekDate.year, currentWeekDate.month, 1);
  final endOfMonth = endDate ?? DateTime(currentWeekDate.year, currentWeekDate.month + 1, 0);
  return DateTimeRange(start: startOfMonth, end: endOfMonth);
}

DateTimeRange thisYearDateRange() {
  final now = DateTime.now();
  final startOfYear = DateTime(now.year, 1, 1);
  final endOfYear = DateTime(now.year, 12, 31);
  return DateTimeRange(start: startOfYear, end: endOfYear);
}

List<DateTimeRange> generateWeekRangesFrom({required DateTime startDate, required DateTime endDate}) {
  DateTime lastDayOfCurrentWeek = endDate.lastWeekDay();

  List<DateTimeRange> weekRanges = [];

  // Find the first day of the week for the given start date
  startDate = startDate.localDate().subtract(Duration(days: startDate.weekday - 1));

  while (startDate.isBefore(lastDayOfCurrentWeek)) {
    DateTime endDate = startDate.add(const Duration(days: 6));
    endDate = endDate.isBefore(lastDayOfCurrentWeek) ? endDate : lastDayOfCurrentWeek;

    weekRanges.add(DateTimeRange(start: startDate, end: endDate));

    // Move to the next week
    startDate = endDate.add(const Duration(days: 1));
  }
  return weekRanges;
}

List<DateTimeRange> generateMonthRangesFrom({required DateTime startDate, required DateTime endDate}) {
  // Find the last day of the current month
  DateTime lastDayOfCurrentMonth = endDate.lastDayOfMonth();
  List<DateTimeRange> monthRanges = [];

  // Adjust the start date to the first day of the month
  startDate = DateTime(startDate.year, startDate.month, 1);

  while (startDate.isBefore(lastDayOfCurrentMonth)) {
    // Find the last day of the month for the current startDate
    DateTime endDate = DateTime(startDate.year, startDate.month + 1, 0);

    monthRanges.add(DateTimeRange(start: startDate, end: endDate));

    // Move to the first day of the next month
    startDate = DateTime(startDate.year, startDate.month + 1, 1);
  }

  return monthRanges;
}

Future<bool> batchDeleteUserData({required String document, required String documentKey}) async {
  final operation = Amplify.API.mutate(
    request: GraphQLRequest<dynamic>(document: document),
  );
  final response = await operation.response;
  final result = jsonDecode(response.data);
  return result[documentKey];
}

Future<NotificationsEnabledOptions> checkIosNotificationPermission() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  return await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions() ??
      const NotificationsEnabledOptions(
          isEnabled: false,
          isSoundEnabled: false,
          isAlertEnabled: false,
          isBadgeEnabled: false,
          isProvisionalEnabled: false,
          isCriticalEnabled: false);
}

Future<bool> requestIosNotificationPermission() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  return await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
      false;
}

List<DateTime> datesInRange(DateTimeRange range) {
  List<DateTime> dates = [];

  for (DateTime date = range.start;
      date.isBefore(range.end) || date.isAtSameMomentAs(range.end);
      date = date.add(const Duration(days: 1))) {
    dates.add(date);
  }

  return dates;
}

List<DateTimeRange> monthRangesForYear(int year) {
  List<DateTimeRange> monthRanges = [];

  for (int month = 1; month <= 12; month++) {
    DateTime start = DateTime(year, month, 1);
    DateTime end = (month < 12)
        ? DateTime(year, month + 1, 1).subtract(const Duration(days: 1))
        : DateTime(year + 1, 1, 1).subtract(const Duration(days: 1));

    monthRanges.add(DateTimeRange(start: start, end: end));
  }

  return monthRanges;
}

int levelFromXp({required int daysLogged}) {
  return daysLogged > 50 ? 50 : daysLogged;
}

Color logStreakColor({required double value}) {
  if (value < 0.3) {
    return Colors.red;
  } else if (value < 0.5) {
    return Colors.orange;
  } else if (value < 0.8) {
    return vibrantBlue;
  } else {
    return vibrantGreen;
  }
}

Color setsTrendColor({required int sets}) {
  if (sets >= 12) {
    return vibrantGreen;
  } else if (sets >= 6) {
    return vibrantBlue;
  } else {
    return Colors.orange;
  }
}

Color repsTrendColor({required int reps}) {
  if (reps >= 120) {
    return vibrantGreen;
  } else if (reps >= 60) {
    return vibrantBlue;
  } else {
    return Colors.orange;
  }
}

Color muscleFamilyFrequencyColor({required double value}) {
  return Colors.white.withOpacity(value);
}

List<MuscleGroupFamily> popularMuscleGroupFamilies() {
  return [
    MuscleGroupFamily.chest,
    MuscleGroupFamily.back,
    MuscleGroupFamily.legs,
    MuscleGroupFamily.shoulders,
    MuscleGroupFamily.arms,
    MuscleGroupFamily.core
  ];
}
