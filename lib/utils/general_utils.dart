import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/screens/settings_screen.dart';

import '../dtos/routine_log_dto.dart';
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

DateTimeRange thisMonthDateRange() {
  final now = DateTime.now();
  final currentWeekDate = DateTime(now.year, now.month, now.day);
  final startOfMonth = DateTime(currentWeekDate.year, currentWeekDate.month, 1);
  final endOfMonth = DateTime(currentWeekDate.year, currentWeekDate.month + 1, 0);
  return DateTimeRange(start: startOfMonth, end: endOfMonth);
}

DateTimeRange thisYearDateRange() {
  final now = DateTime.now();
  final startOfYear = DateTime(now.year, 1, 1);
  final endOfYear = DateTime(now.year, 12, 31);
  return DateTimeRange(start: startOfYear, end: endOfYear);
}

List<DateTimeRange> generateWeekRangesFrom(DateTime startDate) {
  DateTime lastDayOfCurrentWeek = DateTime.now().lastWeekDay();

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

List<DateTimeRange> generateMonthRangesFrom(DateTime startDate) {
  // Find the last day of the current month
  DateTime lastDayOfCurrentMonth = DateTime.now().lastMonthDay();
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

RoutineLogDto? cachedRoutineLog() {
  RoutineLogDto? routineLog;
  final cache = SharedPrefs().cachedRoutineLog;
  if (cache.isNotEmpty) {
    final json = jsonDecode(cache);
    routineLog = RoutineLogDto.fromJson(json);
  }
  return routineLog;
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
