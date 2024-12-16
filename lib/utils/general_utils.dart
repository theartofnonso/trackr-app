import 'dart:convert';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tracker_app/screens/preferences/settings_screen.dart';

import '../colors.dart';
import '../shared_prefs.dart';

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

Color logStreakColor({required double value}) {
  if (value < 0.3) {
    return Colors.red;
  } else if (value < 0.5) {
    return Colors.deepOrangeAccent;
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
