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
}
