import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/extensions/amplify_models/routine_log_extension.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/utils/routine_utils.dart';

import '../../dtos/appsync/exercise_dto.dart';
import '../../dtos/exercise_log_dto.dart';
import '../../dtos/set_dto.dart';
import '../../enums/exercise_type_enums.dart';
import '../../models/RoutineLog.dart';
import '../../models/RoutineTemplate.dart';
import '../../shared_prefs.dart';
import '../../utils/date_utils.dart';
import '../../utils/https_utils.dart';

class AmplifyRoutineLogRepository {
  List<RoutineLogDto> _logs = [];

  UnmodifiableListView<RoutineLogDto> get logs => UnmodifiableListView(_logs);

  Map<String, List<ExerciseLogDto>> _exerciseLogsById = {};

  UnmodifiableMapView<String, List<ExerciseLogDto>> get exerciseLogsById => UnmodifiableMapView(_exerciseLogsById);

  Map<ExerciseType, List<ExerciseLogDto>> _exerciseLogsByType = {};

  UnmodifiableMapView<ExerciseType, List<ExerciseLogDto>> get exerciseLogsByType =>
      UnmodifiableMapView(_exerciseLogsByType);

  void _normaliseLogs() {
    _exerciseLogsById = groupExerciseLogsByExerciseId(routineLogs: _logs);
    _exerciseLogsByType = groupExerciseLogsByExerciseType(routineLogs: _logs);
  }

  void loadLogStream({required List<RoutineLog> logs}) {
    _mapAndNormaliseLogs(logs: logs);
  }

  void _mapAndNormaliseLogs({required List<RoutineLog> logs}) {
    _logs = logs.map((log) => log.dto()).sorted((a, b) => a.createdAt.compareTo(b.createdAt));
    _normaliseLogs();
  }

  Future<void> loadLogsForFeed() async {
    final dateRange = yearToDateTimeRange();
    final startOfCurrentYear = dateRange.start.toIso8601String();
    final endOfCurrentYear = dateRange.end.toIso8601String();

    try {
      final response = await getAPI(
          endpoint: "/routine-logs", queryParameters: {"start": startOfCurrentYear, "end": endOfCurrentYear});
      if (response.isNotEmpty) {
        final json = jsonDecode(response);
        final data = json["data"];
        final body = data["routineLogByDate"];
        final _ = body["items"] as List<dynamic>;
      }
    } catch (e) {
      safePrint(e);
    }
  }

  Future<RoutineLogDto> saveLog({required RoutineLogDto logDto, TemporalDateTime? datetime}) async {
    final now = datetime ?? TemporalDateTime.now();

    final logToCreate = RoutineLog(data: jsonEncode(logDto), createdAt: now, updatedAt: now);
    await Amplify.DataStore.save<RoutineLog>(logToCreate);

    final updatedRoutineLogWithId = logDto.copyWith(id: logToCreate.id, owner: SharedPrefs().userId);
    final updatedRoutineWithExerciseIds = updatedRoutineLogWithId.copyWith(
        exerciseLogs:
            updatedRoutineLogWithId.exerciseLogs.map((log) => log.copyWith(routineLogId: logToCreate.id)).toList());

    _logs.add(updatedRoutineWithExerciseIds);
    _logs.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    _normaliseLogs();

    return updatedRoutineWithExerciseIds;
  }

  Future<void> updateLog({required RoutineLogDto log}) async {
    final result = (await Amplify.DataStore.query(
      RoutineLog.classType,
      where: RoutineLog.ID.eq(log.id),
    ));

    if (result.isNotEmpty) {
      final oldLog = result.first;
      final newLog = oldLog.copyWith(data: jsonEncode(log));
      await Amplify.DataStore.save<RoutineLog>(newLog);
      final index = _indexWhereLog(id: log.id);
      if (index > -1) {
        _logs[index] = log;
        _normaliseLogs();
      }
    }
  }

  Future<void> removeLog({required RoutineLogDto log}) async {
    final result = (await Amplify.DataStore.query(
      RoutineLog.classType,
      where: RoutineTemplate.ID.eq(log.id),
    ));

    if (result.isNotEmpty) {
      final oldTemplate = result.first;
      await Amplify.DataStore.delete<RoutineLog>(oldTemplate);
      final index = _indexWhereLog(id: log.id);
      if (index > -1) {
        _logs.removeAt(index);
        _normaliseLogs();
      }
    }
  }

  void cacheLog({required RoutineLogDto logDto}) {
    SharedPrefs().cachedRoutineLog = jsonEncode(logDto,
        toEncodable: (Object? value) =>
            value is RoutineLogDto ? value.toJson() : throw UnsupportedError('Cannot convert to JSON: $value'));
  }

  RoutineLogDto? cachedRoutineLog() {
    RoutineLogDto? routineLog;
    final cache = SharedPrefs().cachedRoutineLog;
    if (cache.isNotEmpty) {
      final json = jsonDecode(cache);
      routineLog = RoutineLogDto.fromJson(json, owner: SharedPrefs().userId);
    }
    return routineLog;
  }

  /// Helper methods

  int _indexWhereLog({required String id}) {
    return _logs.indexWhere((log) => log.id == id);
  }

  RoutineLogDto? logWhereId({required String id}) {
    return _logs.firstWhereOrNull((log) => log.id == id);
  }

  List<SetDto> whereSetsForExercise({required ExerciseDto exercise}) {
    final exerciseLogs = _exerciseLogsById[exercise.id]?.reversed ?? [];
    return exerciseLogs.isNotEmpty ? exerciseLogs.first.sets : [];
  }

  List<SetDto> whereSetsForExerciseBefore({required ExerciseDto exercise, required DateTime date}) {
    final exerciseLogs = _exerciseLogsById[exercise.id]?.where((log) => log.createdAt.isBefore(date)) ?? [];
    return exerciseLogs.isNotEmpty ? exerciseLogs.first.sets : [];
  }

  List<ExerciseLogDto> whereExerciseLogsBefore({required ExerciseDto exercise, required DateTime date}) {
    return _exerciseLogsById[exercise.id]?.where((log) => log.createdAt.isBefore(date)).toList() ?? [];
  }

  /// RoutineLog for the following [DateTime]
  /// Day, Month and Year - Looking for a log in the same day, hence the need to match the day, month and year
  /// Month and Year - Looking for a log in the same month day, hence the need to match the month and year
  /// Year - Looking for a log in the same year, hence the need to match the year
  RoutineLogDto? whereLogIsSameDay({required DateTime dateTime}) {
    return _logs.firstWhereOrNull((log) => log.createdAt.isSameDayMonthYear(dateTime));
  }

  RoutineLogDto? whereLogIsSameMonth({required DateTime dateTime}) {
    return _logs.firstWhereOrNull((log) => log.createdAt.isSameMonthYear(dateTime));
  }

  RoutineLogDto? whereLogIsSameYear({required DateTime dateTime}) {
    return _logs.firstWhereOrNull((log) => log.createdAt.isSameYear(dateTime));
  }

  /// RoutineLogs for the following [DateTime]
  /// Day, Month and Year - Looking for logs in the same day, hence the need to match the day, month and year
  /// Month and Year - Looking for logs in the same month day, hence the need to match the month and year
  /// Year - Looking for logs in the same year, hence the need to match the year
  List<RoutineLogDto> whereLogsIsSameDay({required DateTime dateTime}) {
    return _logs.where((log) => log.createdAt.isSameDayMonthYear(dateTime)).toList();
  }

  List<RoutineLogDto> whereLogsIsSameMonth({required DateTime dateTime}) {
    return _logs.where((log) => log.createdAt.isSameMonthYear(dateTime)).toList();
  }

  List<RoutineLogDto> whereLogsIsSameYear({required DateTime dateTime}) {
    return _logs.where((log) => log.createdAt.isSameYear(dateTime)).toList();
  }

  void clear() {
    _logs.clear();
    _exerciseLogsById.clear();
    _exerciseLogsByType.clear();
  }
}
