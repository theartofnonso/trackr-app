import 'package:shared_preferences/shared_preferences.dart';

const String lastActivityStartDatetimeKey = "last_activity_start_datetime_key";
const String lastActivityIdKey = "last_activity_id_key";

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

  String get lastActivityId => _sharedPrefs?.getString(lastActivityIdKey) ?? "";

  set lastActivityId(String value) {
    _sharedPrefs?.setString(lastActivityIdKey, value);
  }

  int get lastActivityStartDatetime => _sharedPrefs?.getInt(lastActivityStartDatetimeKey) ?? 0;

  set lastActivityStartDatetime(int value) {
    _sharedPrefs?.setInt(lastActivityStartDatetimeKey, value);
  }

}
