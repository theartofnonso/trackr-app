
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

  /// RoutineLogs that are yet to be updated
  final String cachedPendingRoutineLogsKey = "cached_pending_routine_logs_key";
  List<String> get cachedPendingRoutineLogs => _sharedPrefs?.getStringList(cachedPendingRoutineLogsKey) ?? <String>[];
  set cachedPendingRoutineLogs(List<String> value) {
    _sharedPrefs?.setStringList(cachedPendingRoutineLogsKey, value);
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

  /// User Email
  final String _userEmailKey = "user_email_key";
  String get userEmail => _sharedPrefs?.getString(_userEmailKey) ?? "";
  set userEmail(String value) {
    _sharedPrefs?.setString(_userEmailKey, value);
  }

  /// User Id
  final String _userIdKey = "user_id_key";
  String get userId => _sharedPrefs?.getString(_userIdKey) ?? "";
  set userId(String value) {
    _sharedPrefs?.setString(_userIdKey, value);
  }
}
