
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:tracker_app/screens/settings_screen.dart';

import '../models/User.dart';
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

String distanceLabel() {
  final unitString = SharedPrefs().distanceUnit;
  final unit = DistanceUnit.fromString(unitString);
  return unit == DistanceUnit.mi ? "yd" : "m";
}

String distanceTitle() {
  final unitString = SharedPrefs().distanceUnit;
  final unit = DistanceUnit.fromString(unitString);
  return unit == DistanceUnit.mi ? "YARDS" : "METRES";
}

double toKg(double value) {
  final conversion = value / 2.205;
  return double.parse(conversion.toStringAsFixed(2));
}

double toLbs(double value) {
  final conversion = value * 2.205;
  return double.parse(conversion.toStringAsFixed(2));
}

double toMI(double value) {
  final conversion = value / 2.205;
  return double.parse(conversion.toStringAsFixed(2));
}

double toKM(double value) {
  final conversion = value * 2.205;
  return double.parse(conversion.toStringAsFixed(2));
}

void toggleWeightUnit({required WeightUnit unit}) {
  SharedPrefs().weightUnit = unit.name;
}

void toggleDistanceUnit({required DistanceUnit unit}) {
  SharedPrefs().distanceUnit = unit.name;
}

Future<User> user() async {
  final authUser = await Amplify.Auth.getCurrentUser();
  final signInDetails  = authUser.signInDetails.toJson();
  final email = signInDetails["username"] as String;
  final userId = authUser.userId;
  final user = User(id: userId, email: email);
  return user;
}