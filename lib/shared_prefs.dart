import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracker_app/screens/preferences/settings_screen.dart';

class SharedPrefs {
  static SharedPreferences? _sharedPrefs;

  factory SharedPrefs() => SharedPrefs._internal();

  SharedPrefs._internal();

  Future<void> init() async {
    _sharedPrefs ??= await SharedPreferences.getInstance();
  }

  void clear() {
    remove(key: _weightUnitKey);
    remove(key: _userIdKey);
    remove(key: _userEmailKey);
    remove(key: routineLogKey);
    remove(key: _readinessScore);
  }

  void remove({required String key}) {
    _sharedPrefs?.remove(key);
  }

  Future<void> reload() async {
    await _sharedPrefs?.reload();
  }

  /// Weight Unit Type
  final String _weightUnitKey = "weight_unit_type_key";

  String get weightUnit => _sharedPrefs?.getString(_weightUnitKey) ?? WeightUnit.kg.name;

  set weightUnit(String value) {
    _sharedPrefs?.setString(_weightUnitKey, value);
  }

  /// First launch flag
  final String _firstLaunchKey = "first_launch_key";

  bool get firstLaunch => _sharedPrefs?.getBool(_firstLaunchKey) ?? true;

  set firstLaunch(bool value) {
    _sharedPrefs?.setBool(_firstLaunchKey, value);
  }

  /// User
  final String _userIdKey = "user_id_key";

  String get userId => _sharedPrefs?.getString(_userIdKey) ?? "";

  set userId(String value) {
    _sharedPrefs?.setString(_userIdKey, value);
  }

  final String _userEmailKey = "user_email_key";

  String get userEmail => _sharedPrefs?.getString(_userEmailKey) ?? "";

  set userEmail(String value) {
    _sharedPrefs?.setString(_userEmailKey, value);
  }

  final String routineLogKey = "routine_log_key";

  String get routineLog => _sharedPrefs?.getString(routineLogKey) ?? "";

  set routineLog(String value) {
    _sharedPrefs?.setString(routineLogKey, value);
  }

  /// Readiness Score
  final String _readinessScore = "readiness_score";

  int get readinessScore => _sharedPrefs?.getInt(_readinessScore) ?? 0;

  set readinessScore(int value) {
    _sharedPrefs?.setInt(_readinessScore, value);
  }
}
