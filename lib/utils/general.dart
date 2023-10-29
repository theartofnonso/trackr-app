import 'package:tracker_app/screens/settings_screen.dart';

import '../shared_prefs.dart';

String weightLabel() {
  final unitType = SharedPrefs().weightUnit == WeightUnit.kg.name ? WeightUnit.kg : WeightUnit.lbs;
  return unitType.name;
}

WeightUnit weightType() {
  return SharedPrefs().weightUnit == WeightUnit.kg.name ? WeightUnit.kg : WeightUnit.lbs;
}