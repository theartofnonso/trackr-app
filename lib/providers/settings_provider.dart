import 'package:flutter/cupertino.dart';
import 'package:tracker_app/screens/settings_screen.dart';

import '../shared_prefs.dart';

class SettingsProvider with ChangeNotifier {
  bool _isLbs = false;

  bool get isLbs => _isLbs;

  void toggleUnit({required WeightUnit unit}) {
    SharedPrefs().weightUnit = unit.name;
    _isLbs = unit == WeightUnit.lbs;
    notifyListeners();
  }

  void setDefaultUnit() {
    final previousUnit = SharedPrefs().weightUnit;
    if(previousUnit.isNotEmpty) {
      _isLbs = previousUnit == WeightUnit.lbs.name;
    } else {
      SharedPrefs().weightUnit = WeightUnit.kg.name;
      _isLbs = false;
    }
    notifyListeners();
  }

}
