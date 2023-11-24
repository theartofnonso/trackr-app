import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
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

void persistUserCredentials() async {
  final authUser = await Amplify.Auth.getCurrentUser();
  final signInDetails = authUser.signInDetails.toJson();
  final email = signInDetails["username"] as String;
  final id = authUser.userId;
  SharedPrefs().userEmail = email;
  SharedPrefs().userId = id;
}
