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

  /// Show calendar dates
  final String _showCalendarDatesKey = "show_calendar_dates_key";

  bool get showCalendarDates => _sharedPrefs?.getBool(_showCalendarDatesKey) ?? true;

  set showCalendarDates(bool value) {
    _sharedPrefs?.setBool(_showCalendarDatesKey, value);
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

  /// Untrained muscle group families
  final String cachedUntrainedMGFNotificationKey = "cached_untrained_MGF_notification_key";

  String get cachedUntrainedMGFNotification => _sharedPrefs?.getString(cachedUntrainedMGFNotificationKey) ?? "{}";

  set cachedUntrainedMGFNotification(String value) {
    _sharedPrefs?.setString(cachedUntrainedMGFNotificationKey, value);
  }

  /// RoutineLog metadata
  final String routineLogMetadataKey = "cached_untrained_MGF_notification_key";

  // String get cachedUntrainedMGFNotification => _sharedPrefs?.getString(cachedUntrainedMGFNotificationKey) ?? "{}";
  //
  // set cachedUntrainedMGFNotification(String value) {
  //   _sharedPrefs?.setString(cachedUntrainedMGFNotificationKey, value);
  // }
}
