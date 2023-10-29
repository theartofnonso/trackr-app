import 'package:shared_preferences/shared_preferences.dart';

const String lastActivityStartDatetimeKey = "last_activity_start_datetime_key";
const String lastActivityIdKey = "last_activity_id_key";
const String lastActivityKey = "last_activity_key";
const String cachedRoutineLogKey = "cached_routine_log_key";
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

  String get lastActivity => _sharedPrefs?.getString(lastActivityKey) ?? "";

  set lastActivity(String value) {
    _sharedPrefs?.setString(lastActivityKey, value);
  }

  void removeLastActivity() {
    _sharedPrefs?.remove(lastActivityKey);
  }

  String get lastActivityId => _sharedPrefs?.getString(lastActivityIdKey) ?? "";

  set lastActivityId(String value) {
    _sharedPrefs?.setString(lastActivityIdKey, value);
  }

  void removeLastActivityId() {
    _sharedPrefs?.remove(lastActivityIdKey);
  }

  int get lastActivityStartDatetime => _sharedPrefs?.getInt(lastActivityStartDatetimeKey) ?? 0;

  set lastActivityStartDatetime(int value) {
    _sharedPrefs?.setInt(lastActivityStartDatetimeKey, value);
  }

  void removeLastActivityStartDatetime() {
    _sharedPrefs?.remove(lastActivityStartDatetimeKey);
  }

  /// Cached [RoutineLogDto]
  set cachedRoutineLog(String value) {
    _sharedPrefs?.setString(cachedRoutineLogKey, value);
  }

  String get cachedRoutineLog => _sharedPrefs?.getString(cachedRoutineLogKey) ?? "";

  /// Cached Rest timer interval during routine
  set cachedRoutineRestInterval(int value) {
    _sharedPrefs?.setInt(cachedRoutineRestIntervalKey, value);
  }

  int get cachedRoutineRestInterval => _sharedPrefs?.getInt(cachedRoutineRestIntervalKey) ?? 0;

  /// Weight Unit Type
  set weightUnit(String value) {
    _sharedPrefs?.setString(weightUnitKey, value);
  }

  String get weightUnit => _sharedPrefs?.getString(weightUnitKey) ?? "";
}
