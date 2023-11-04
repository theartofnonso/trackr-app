import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:tracker_app/screens/settings_screen.dart';

import '../models/User.dart';
import '../shared_prefs.dart';

String weightLabel() {
  final unitType = SharedPrefs().weightUnit == WeightUnit.kg.name ? WeightUnit.kg : WeightUnit.lbs;
  return unitType.name;
}

double toKg(double value) {
  final conversion = value / 2.205;
  return double.parse(conversion.toStringAsFixed(2));
}

double toLbs(double value) {
  final conversion = value * 2.205;
  return double.parse(conversion.toStringAsFixed(2));
}

Future<User> user() async {
  final authUser = await Amplify.Auth.getCurrentUser();
  final signInDetails  = authUser.signInDetails.toJson();
  final email = signInDetails["username"] as String;
  final userId = authUser.userId;
  final user = User(id: userId, email: email);
  return user;
}