import 'dart:convert';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:health/health.dart';
import 'package:tracker_app/screens/preferences/settings_screen.dart';

import '../colors.dart';
import '../dtos/appsync/routine_log_dto.dart';
import '../enums/routine_editor_type_enums.dart';
import '../screens/editors/routine_log_editor_screen.dart';
import '../screens/logs/routine_log_screen.dart';
import '../shared_prefs.dart';
import 'navigation_utils.dart';

bool isDefaultWeightUnit() {
  final weightString = SharedPrefs().weightUnit;
  final weightUnit = WeightUnit.fromString(weightString);
  return weightUnit == WeightUnit.kg;
}

double weightWithConversion({required num value}) {
  return isDefaultWeightUnit() ? value.toDouble() : toLbs(value.toDouble());
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

String timeOfDay({DateTime? datetime}) {
  var hour = datetime?.hour ?? DateTime.now().hour;
  if (hour < 12) {
    return 'Morning';
  }
  if (hour < 17) {
    return 'Afternoon';
  }
  return 'Evening';
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

Future<bool> requestNotificationPermission() async {
  return Platform.isIOS ? _requestIosNotificationPermission() : _requestAndroidNotificationPermission();
}

Future<bool> _requestIosNotificationPermission() async {
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

Future<bool> _requestAndroidNotificationPermission() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  return await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission() ??
      false;
}

Color logStreakColor(num value) {
  final result = value / 12;
  if (result < 0.3) {
    return Colors.red;
  } else if (result < 0.5) {
    return Colors.deepOrangeAccent;
  } else if (result < 0.8) {
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
    return Colors.deepOrangeAccent;
  }
}

Color setsMilestoneColor({required double progress}) {
  if (progress >= 0.7) {
    return vibrantGreen;
  } else if (progress >= 0.5) {
    return vibrantBlue;
  } else if (progress >= 0.3) {
    return Colors.yellow;
  } else {
    return Colors.deepOrangeAccent;
  }
}

Color repsTrendColor({required int reps}) {
  if (reps >= 120) {
    return vibrantGreen;
  } else if (reps >= 60) {
    return vibrantBlue;
  } else {
    return Colors.deepOrangeAccent;
  }
}

LinearGradient themeGradient({required BuildContext context}) {
  Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
  final isDarkMode = systemBrightness == Brightness.dark;

  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      isDarkMode ? sapphireDark80 : Colors.white,
      isDarkMode ? sapphireDark : Colors.white12,
    ],
  );
}

Future<bool> requestAppleHealth() async {

  await Health().configure();

  // define the types to get
  final types = [HealthDataType.SLEEP_ASLEEP, HealthDataType.WORKOUT];

  final permissions = [HealthDataAccess.READ, HealthDataAccess.WRITE];

  bool hasPermissions =
      await Health().hasPermissions(types, permissions: permissions) ?? false;

  if (!hasPermissions) {
    // requesting access to the data types before reading them
    hasPermissions = await Health().requestAuthorization(types, permissions: permissions);
  } else {
    hasPermissions = true;
  }

  return hasPermissions;
}

Future<DateTimeRange?> calculateSleepDuration() async {
  await Health().configure();

  // fetch health data from the last 24 hours
  final now = DateTime.now();

  final pastDay = now.subtract(const Duration(hours: 24));

  final values =
      await Health().getHealthDataFromTypes(types: [HealthDataType.SLEEP_ASLEEP], startTime: pastDay, endTime: now);
  final uniqueValues = Health().removeDuplicates(values);

  DateTimeRange? sleepTime;

  if (values.isNotEmpty) {
    Iterable<DateTime> dateFrom = uniqueValues.map((value) => value.dateFrom);
    Iterable<DateTime> dateTo = uniqueValues.map((value) => value.dateTo);

    DateTime minDateTime = dateFrom.reduce((a, b) => a.isBefore(b) ? a : b);
    DateTime maxDateTime = dateTo.reduce((a, b) => a.isAfter(b) ? a : b);

    sleepTime = DateTimeRange(start: minDateTime, end: maxDateTime);
  }

  return sleepTime;
}

Color getImprovementColor({required bool improved, required num difference}) {

  Color color = vibrantBlue;

  if(improved && difference > 0) {
    color = vibrantGreen;
  } else if(!improved && difference > 0) {
    color = Colors.deepOrange;
  }
  return color;
}

final Map<int, Color> rpeIntensityToColor = {
  1: vibrantGreen, // Bright green - very light
  2: Color(0xFF66FF66), // Light green
  3: Color(0xFF99FF99), // Soft green
  4: Color(0xFFFFFF66), // Yellow-green transition
  5: Color(0xFFFFFF33), // Yellow - moderate intensity
  6: Color(0xFFFFCC33), // Amber - challenging intensity
  7: Color(0xFFFF9933), // Orange - very hard
  8: Color(0xFFFF6633), // Deep orange - near maximal
  9: Color(0xFFFF3333), // Bright red - maximal effort
  10: Color(0xFFFF0000), // Red - absolute limit
};

IconData getImprovementIcon({required bool improved, required num difference}) {

  IconData icon = FontAwesomeIcons.arrowsUpDown;

  if(improved && difference > 0) {
    icon = FontAwesomeIcons.arrowTrendUp;
  } else if(!improved && difference > 0) {
    icon = FontAwesomeIcons.arrowTrendDown;
  }
  return icon;
}

void logEmptyRoutine({required BuildContext context, String workoutVideoUrl = ""}) async {
  final log = RoutineLogDto(
      id: "",
      templateId: "",
      name: "${timeOfDay()} Session",
      exerciseLogs: [],
      notes: "",
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      owner: "",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now());
  final recentLog = await navigateWithSlideTransition(
      context: context, child: RoutineLogEditorScreen(log: log, mode: RoutineEditorMode.log, workoutVideoUrl: workoutVideoUrl,));
  if (recentLog != null) {
    if (context.mounted) {
      context.push(RoutineLogScreen.routeName, extra: {"log": recentLog, "showSummary": true, "isEditable": true});
    }
  }
}