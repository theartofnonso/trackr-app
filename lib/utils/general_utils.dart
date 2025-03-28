import 'dart:convert';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health/health.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/extensions/muscle_group_extension.dart';
import 'package:tracker_app/screens/preferences/settings_screen.dart';

import '../colors.dart';
import '../dtos/appsync/routine_log_dto.dart';
import '../dtos/viewmodels/routine_log_arguments.dart';
import '../enums/routine_editor_type_enums.dart';
import '../screens/templates/readiness_screen.dart';
import '../shared_prefs.dart';
import 'data_trend_utils.dart';
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
    return Colors.yellow;
  } else if (result < 0.8) {
    return vibrantBlue;
  } else {
    return vibrantGreen;
  }
}

/// Higher values now get a "better" color (green)
Color lowToHighIntensityColor(double recoveryPercentage) {
  if (recoveryPercentage < 0.3) {
    // Severe DOMS (0–29%)
    return Colors.red;
  } else if (recoveryPercentage < 0.5) {
    return Colors.yellow;
  } else if (recoveryPercentage < 0.8) {
    return vibrantBlue;
  } else {
    return vibrantGreen;
  }
}

/// Lower values now get a "better" color (green)
Color highToLowIntensityColor(double recoveryPercentage) {
  if (recoveryPercentage < 0.3) {
    return vibrantGreen;
  } else if (recoveryPercentage < 0.5) {
    return vibrantBlue;
  } else if (recoveryPercentage < 0.8) {
    return Colors.yellow;
  } else {
    // Higher recovery values now get a "worse" color (red)
    return Colors.red;
  }
}

String recoveryMuscleIllustration({required double recoveryPercentage, required MuscleGroup muscleGroup}) {
  if (recoveryPercentage < 0.3) {
    // Severe DOMS (0–29%)
    return 'red_muscles_illustration/${muscleGroup.illustration()}.png';
  } else if (recoveryPercentage < 0.5) {
    // High soreness (30–49%)
    return 'yellow_muscles_illustration/${muscleGroup.illustration()}.png';
  } else if (recoveryPercentage < 0.8) {
    // Moderate soreness (50–79%)
    return 'blue_muscles_illustration/${muscleGroup.illustration()}.png';
  } else {
    // Mild or no soreness (80–100%)
    return 'muscles_illustration/${muscleGroup.illustration()}.png';
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

  bool hasPermissions = await Health().hasPermissions(types, permissions: permissions) ?? false;

  if (!hasPermissions) {
    // requesting access to the data types before reading them
    hasPermissions = await Health().requestAuthorization(types, permissions: permissions);
  } else {
    hasPermissions = true;
  }

  return hasPermissions;
}

Widget getTrendIcon({required Trend trend}) {
  return switch (trend) {
    Trend.up => FaIcon(
        FontAwesomeIcons.arrowTrendUp,
        color: vibrantGreen,
        size: 20,
      ),
    Trend.down => FaIcon(
        FontAwesomeIcons.arrowTrendDown,
        color: Colors.deepOrange,
        size: 20,
      ),
    Trend.stable => Container(
        width: 30,
        height: 30,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: vibrantGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Center(
          child: FaIcon(
            FontAwesomeIcons.check,
            size: 14,
            color: vibrantGreen,
          ),
        ),
      ),
    Trend.none => const SizedBox.shrink(),
  };
}

void logEmptyRoutine({required BuildContext context, String? workoutVideoUrl}) async {
  final readinessScores = await navigateWithSlideTransition(context: context, child: ReadinessScreen()) as List;
  final fatigue = readinessScores[0];
  final soreness = readinessScores[1];
  final log = RoutineLogDto(
      id: "",
      templateId: "",
      name: "${timeOfDay()} Session",
      exerciseLogs: [],
      notes: "",
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      owner: "",
      fatigueLevel: fatigue,
      sorenessLevel: soreness,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now());

  if (context.mounted) {
    final arguments = RoutineLogArguments(log: log, editorMode: RoutineEditorMode.log);
    navigateToRoutineLogEditor(context: context, arguments: arguments);
  }
}
