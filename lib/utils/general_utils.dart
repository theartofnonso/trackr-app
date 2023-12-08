import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/screens/settings_screen.dart';

import '../models/User.dart';
import '../providers/exercise_provider.dart';
import '../providers/routine_log_provider.dart';
import '../providers/routine_provider.dart';
import '../shared_prefs.dart';

bool isDefaultWeightUnit() {
  final weightString = SharedPrefs().weightUnit;
  final weightUnit = WeightUnit.fromString(weightString);
  return weightUnit == WeightUnit.kg;
}

bool isDefaultDistanceUnit() {
  final distanceString = SharedPrefs().distanceUnit;
  final distanceUnit = DistanceUnit.fromString(distanceString);
  return distanceUnit == DistanceUnit.mi;
}

String weightLabel() {
  return SharedPrefs().weightUnit;
}

String distanceLabel({required ExerciseType type}) {
  if (type == ExerciseType.durationAndDistance) {
    return isDefaultDistanceUnit() ? "mi" : "km";
  } else {
    return isDefaultDistanceUnit() ? "yd" : "m";
  }
}

String distanceTitle({required ExerciseType type}) {
  if (type == ExerciseType.durationAndDistance) {
    return isDefaultDistanceUnit() ? "MI" : "KM";
  } else {
    return isDefaultDistanceUnit() ? "YARDS" : "METRES";
  }
}

double toKg(double value) {
  final conversion = value / 2.205;
  return double.parse(conversion.toStringAsFixed(2));
}

double toLbs(double value) {
  final conversion = value * 2.205;
  return double.parse(conversion.toStringAsFixed(2));
}

double toMI(double value, {required ExerciseType type}) {
  double conversion = 0;
  if (type == ExerciseType.durationAndDistance) {
    conversion = value / 1.609;
  } else {
    conversion = value * 1.094;
  }
  return double.parse(conversion.toStringAsFixed(2));
}

double toKM(double value, {required ExerciseType type}) {
  double conversion = 0;
  if (type == ExerciseType.durationAndDistance) {
    conversion = value * 1.609;
  } else {
    conversion = value / 1.094;
  }
  return double.parse(conversion.toStringAsFixed(2));
}

void toggleWeightUnit({required WeightUnit unit}) {
  SharedPrefs().weightUnit = unit.name;
}

void toggleDistanceUnit({required DistanceUnit unit}) {
  SharedPrefs().distanceUnit = unit.name;
}

User user() {
  final email = SharedPrefs().userEmail;
  final userId = SharedPrefs().userId;
  return User(id: userId, email: email);
}

Future<void> persistUserCredentials() async {
  final authUser = await Amplify.Auth.getCurrentUser();
  final signInDetails = authUser.signInDetails.toJson();
  final email = signInDetails["username"] as String;
  final id = authUser.userId;
  SharedPrefs().userEmail = email;
  SharedPrefs().userId = id;
}

DateTimeRange thisWeekDateRange() {
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final endOfWeek = now.add(Duration(days: 7 - now.weekday));
  return DateTimeRange(start: startOfWeek, end: endOfWeek);
}

DateTimeRange thisMonthDateRange() {
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0);
  return DateTimeRange(start: startOfMonth, end: endOfMonth);
}

DateTimeRange thisYearDateRange() {
  final now = DateTime.now();
  final startOfYear = DateTime(now.year, 1, 1);
  final endOfYear = DateTime(now.year, 12, 31);
  return DateTimeRange(start: startOfYear, end: endOfYear);
}

Future<void> loadAppData(BuildContext context) async {
  final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
  final routineProvider = Provider.of<RoutineProvider>(context, listen: false);
  final routineLogProvider = Provider.of<RoutineLogProvider>(context, listen: false);

  /// Retrieve pending logs
  routineLogProvider.retrieveCachedPendingRoutineLogs(context);
  routineProvider.retrieveCachedPendingRoutines(context);
  exerciseProvider.listExercises().then((_) {
    routineProvider.listRoutines();
    routineLogProvider.listRoutineLogs();
  });
}
