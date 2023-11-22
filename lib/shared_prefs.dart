
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

  /// RoutineLog that is currently running
  final String _cachedRoutineLogKey = "cached_routine_log_key";
  String get cachedRoutineLog => _sharedPrefs?.getString(_cachedRoutineLogKey) ?? "";
  set cachedRoutineLog(String value) {
    _sharedPrefs?.setString(_cachedRoutineLogKey, value);
  }

  /// RoutineLogs that are yet to be update
  final String _cachedPendingRoutineLogsKey = "cached_pending_routine_logs_key";
  List<String> get cachedPendingRoutineLogs => _sharedPrefs?.getStringList(_cachedPendingRoutineLogsKey) ?? <String>[];
  set cachedPendingRoutineLogs(List<String> value) {
    _sharedPrefs?.setStringList(_cachedPendingRoutineLogsKey, value);
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
  final String _firstLaunchKey = "_first_launch_key";
  bool get firstLaunch => _sharedPrefs?.getBool(_firstLaunchKey) ?? true;
  set firstLaunch(bool value) {
    _sharedPrefs?.setBool(_firstLaunchKey, value);
  }

  /// User Email
  final String _userEmailKey = "_user_email_key";
  String get userEmail => _sharedPrefs?.getString(_userEmailKey) ?? "";
  set userEmail(String value) {
    _sharedPrefs?.setString(_userEmailKey, value);
  }

  /// User Id
  final String _userIdKey = "_user_id_key";
  String get userId => _sharedPrefs?.getString(_userIdKey) ?? "";
  set userId(String value) {
    _sharedPrefs?.setString(_userIdKey, value);
  }
}
