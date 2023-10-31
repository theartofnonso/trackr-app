import 'package:tracker_app/screens/settings_screen.dart';

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