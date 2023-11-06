import 'package:shared_preferences/shared_preferences.dart';

const String cachedRoutineLogKey = "cached_routine_log_key";
const String cachedPendingRoutineLogsKey = "cached_pending_routine_logs_key";
const String cachedRoutineRestIntervalKey = "cached_routine_rest_interval_key";
const String weightUnitKey = "weight_Unit_type_key";

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

  String get cachedRoutineLog => _sharedPrefs?.getString(cachedRoutineLogKey) ?? "";
  set cachedRoutineLog(String value) {
    _sharedPrefs?.setString(cachedRoutineLogKey, value);
  }

  List<String> get cachedPendingRoutineLogs => _sharedPrefs?.getStringList(cachedPendingRoutineLogsKey) ?? <String>[];
  set cachedPendingRoutineLogs(List<String> value) {
    _sharedPrefs?.setStringList(cachedPendingRoutineLogsKey, value);
  }

  /// Cached Rest timer interval during routine
  int get cachedRoutineRestInterval => _sharedPrefs?.getInt(cachedRoutineRestIntervalKey) ?? 0;
  set cachedRoutineRestInterval(int value) {
    _sharedPrefs?.setInt(cachedRoutineRestIntervalKey, value);
  }

  /// Weight Unit Type
  String get weightUnit => _sharedPrefs?.getString(weightUnitKey) ?? "";
  set weightUnit(String value) {
    _sharedPrefs?.setString(weightUnitKey, value);
  }
}
