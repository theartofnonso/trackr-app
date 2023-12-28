
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracker_app/screens/settings_screen.dart';

class SharedPrefs {
  static SharedPreferences? _sharedPrefs;

  factory SharedPrefs() => SharedPrefs._internal();

  SharedPrefs._internal();

  Future<void> init() async {
    _sharedPrefs ??= await SharedPreferences.getInstance();
  }

  void clear() {
    _sharedPrefs?.clear();
  }

  void remove({required String key}) {
    _sharedPrefs?.remove(key);
  }

  Future<void> reload() async {
    await _sharedPrefs?.reload();
  }

  /// RoutineLog that is currently running
  final String cachedRoutineLogKey = "cached_routine_log_key";
  String get cachedRoutineLog => _sharedPrefs?.getString(cachedRoutineLogKey) ?? "";
  set cachedRoutineLog(String value) {
    _sharedPrefs?.setString(cachedRoutineLogKey, value);
  }

  /// Weight Unit Type
  final String _weightUnitKey = "weight_unit_type_key";
  String get weightUnit => _sharedPrefs?.getString(_weightUnitKey) ?? WeightUnit.kg.name;
  set weightUnit(String value) {
    _sharedPrefs?.setString(_weightUnitKey, value);
  }

  /// Distance Unit Type
  final String _distanceUnitKey = "distance_unit_type_key";
  String get distanceUnit => _sharedPrefs?.getString(_distanceUnitKey) ?? DistanceUnit.mi.name;
  set distanceUnit(String value) {
    _sharedPrefs?.setString(_distanceUnitKey, value);
  }

  /// First launch flag
  final String _firstLaunchKey = "first_launch_key";
  bool get firstLaunch => _sharedPrefs?.getBool(_firstLaunchKey) ?? true;
  set firstLaunch(bool value) {
    _sharedPrefs?.setBool(_firstLaunchKey, value);
  }

  /// User
  final String _userKey = "user_key";
  String get user => _sharedPrefs?.getString(_userKey) ?? "";
  set user(String value) {
    _sharedPrefs?.setString(_userKey, value);
  }
}
