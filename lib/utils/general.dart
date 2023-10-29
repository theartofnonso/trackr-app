import 'package:tracker_app/screens/settings_screen.dart';

import '../shared_prefs.dart';

double convertWeight(double value) {
  final unitType = SharedPrefs().weightUnitType == WeightUnitType.kg.name ? WeightUnitType.kg : WeightUnitType.lbs;
  final conversion = switch(unitType) {
    WeightUnitType.kg => value,
    WeightUnitType.lbs => value * 2.2
  };
  return conversion;
}

String weightLabel() {
  final unitType = SharedPrefs().weightUnitType == WeightUnitType.kg.name ? WeightUnitType.kg : WeightUnitType.lbs;
  return unitType.name;
}