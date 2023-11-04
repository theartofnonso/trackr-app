import 'package:shared_preferences/shared_preferences.dart';

const String userIdKey = "user_id_key";
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

  String get userId => _sharedPrefs?.getString(userIdKey) ?? "";
  set userId(String value) {
    _sharedPrefs?.setString(userIdKey, value);
  }

  String get cachedRoutineLog => _sharedPrefs?.getString(cachedRoutineLogKey) ?? "";
  set cachedRoutineLog(String value) {
    _sharedPrefs?.setString(cachedRoutineLogKey, value);
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
