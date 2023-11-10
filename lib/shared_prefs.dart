
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

  /// Cached Rest timer interval during routine
  final String _cachedRoutineRestIntervalKey = "cached_routine_rest_interval_key";
  int get cachedRoutineRestInterval => _sharedPrefs?.getInt(_cachedRoutineRestIntervalKey) ?? 0;
  set cachedRoutineRestInterval(int value) {
    _sharedPrefs?.setInt(_cachedRoutineRestIntervalKey, value);
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
}
