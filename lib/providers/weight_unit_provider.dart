import 'package:flutter/cupertino.dart';
import 'package:tracker_app/screens/settings_screen.dart';

import '../shared_prefs.dart';

class WeightUnitProvider with ChangeNotifier {
  bool _isLbs = false;

  bool get isLbs => _isLbs;

  void toggleUnit() {
    _isLbs = SharedPrefs().weightUnit == WeightUnit.lbs.name;
    notifyListeners();
  }

  double toKg(double value) {
    final conversion = value / 2.205;
    return double.parse(conversion.toStringAsFixed(2));
  }

  double toLbs(double value) {
    final conversion = value * 2.205;
    return double.parse(conversion.toStringAsFixed(2));
  }
}
