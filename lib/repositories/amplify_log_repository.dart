import 'dart:async';
import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/routine_log_extension.dart';
import 'package:tracker_app/utils/routine_utils.dart';

import '../dtos/exercise_dto.dart';
import '../dtos/exercise_log_dto.dart';
import '../dtos/set_dto.dart';
import '../enums/exercise_type_enums.dart';
import '../models/RoutineLog.dart';
import '../models/RoutineTemplate.dart';
import '../shared_prefs.dart';
import '../utils/date_utils.dart';

class AmplifyLogRepository {
  List<RoutineLogDto> _routineLogs = [];

  Map<DateTimeRange, List<RoutineLogDto>> _weeklyLogs = {};

  Map<DateTimeRange, List<RoutineLogDto>> _monthlyLogs = {};

  Map<String, List<ExerciseLogDto>> _exerciseLogsById = {};

  Map<ExerciseType, List<ExerciseLogDto>> _exerciseLogsByType = {};

  UnmodifiableListView<RoutineLogDto> get routineLogs => UnmodifiableListView(_routineLogs);

  UnmodifiableMapView<String, List<ExerciseLogDto>> get exerciseLogsById => UnmodifiableMapView(_exerciseLogsById);

  UnmodifiableMapView<ExerciseType, List<ExerciseLogDto>> get exerciseLogsByType =>
      UnmodifiableMapView(_exerciseLogsByType);

  UnmodifiableMapView<DateTimeRange, List<RoutineLogDto>> get weeklyLogs => UnmodifiableMapView(_weeklyLogs);

  UnmodifiableMapView<DateTimeRange, List<RoutineLogDto>> get monthlyLogs => UnmodifiableMapView(_monthlyLogs);

  void _normaliseLogs() {
    _groupRoutineLogs();
    _groupExerciseLogs();
  }

  void _groupRoutineLogs() {
    _weeklyLogs = groupRoutineLogsByWeek(routineLogs: _routineLogs);
    _monthlyLogs = groupRoutineLogsByMonth(routineLogs: _routineLogs);
  }

  void _groupExerciseLogs() {
    _exerciseLogsById = groupExerciseLogsByExerciseId(routineLogs: _routineLogs);
    _exerciseLogsByType = groupExerciseLogsByExerciseType(routineLogs: _routineLogs);
  }

  Future<void> fetchLogs({required bool firstLaunch}) async {
    if (firstLaunch) {
      final dateRange = yearToDateTimeRange();
      print(dateRange);
      List<RoutineLog> logs = await queryLogsCloud(range: dateRange);
      _mapAndNormaliseLogs(logs: logs);
    } else {
      List<RoutineLog> logs = await Amplify.DataStore.query(RoutineLog.classType);
      _mapAndNormaliseLogs(logs: logs);
    }
  }

  Future<RoutineLog?> fetchLogCloud({required String id}) async {
    try {
      final request = ModelQueries.get(
        RoutineLog.classType,
        RoutineLogModelIdentifier(id: id),
      );
      final response = await Amplify.API.query(request: request).response;
      return response.data;
    } on ApiException catch (_) {
      return null;
    }
  }

  Future<List<RoutineLog>> queryLogsCloud({required DateTimeRange range}) async {
    final startOfCurrentYear = range.start.toIso8601String();
    final endOfCurrentYear = range.end.toIso8601String();
    final whereDate = RoutineLog.CREATEDAT.between(startOfCurrentYear, endOfCurrentYear);
    final request = ModelQueries.list(RoutineLog.classType, where: whereDate, limit: 999);
    final response = await Amplify.API.query(request: request).response;
    final routineLogs = response.data?.items.whereType<RoutineLog>().toList();
    return routineLogs ?? [];
  }

  void _mapAndNormaliseLogs({required List<RoutineLog> logs}) {
    _routineLogs = logs.map((log) => log.dto()).sorted((a, b) => a.createdAt.compareTo(b.createdAt));
    _normaliseLogs();
  }

  Future<RoutineLogDto> saveLog({required RoutineLogDto logDto, TemporalDateTime? datetime}) async {
    final now = datetime ?? TemporalDateTime.now();

    final logToCreate = RoutineLog(data: jsonEncode(logDto), createdAt: now, updatedAt: now);
    await Amplify.DataStore.save(logToCreate);

    final updatedRoutineLogWithId = logDto.copyWith(id: logToCreate.id);
    final updatedRoutineWithExerciseIds = updatedRoutineLogWithId.copyWith(
        exerciseLogs:
            updatedRoutineLogWithId.exerciseLogs.map((log) => log.copyWith(routineLogId: logToCreate.id)).toList());

    _routineLogs.add(updatedRoutineWithExerciseIds);
    _routineLogs.sort((a, b) => a.createdAt.compareTo(b.createdAt));

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
      await Amplify.DataStore.save(newLog);
      final index = _indexWhereRoutineLog(id: log.id);
      _routineLogs[index] = log;
      _normaliseLogs();
    }
  }

  Future<void> removeLog({required RoutineLogDto log}) async {
    final result = (await Amplify.DataStore.query(
      RoutineLog.classType,
      where: RoutineTemplate.ID.eq(log.id),
    ));

    if (result.isNotEmpty) {
      final oldTemplate = result.first;
      await Amplify.DataStore.delete(oldTemplate);
      final index = _indexWhereRoutineLog(id: log.id);
      _routineLogs.removeAt(index);
      _normaliseLogs();
    }
  }

  void cacheLog({required RoutineLogDto logDto}) {
    SharedPrefs().cachedRoutineLog = jsonEncode(logDto);
  }

  RoutineLogDto? cachedRoutineLog() {
    RoutineLogDto? routineLog;
    final cache = SharedPrefs().cachedRoutineLog;
    if (cache.isNotEmpty) {
      final json = jsonDecode(cache);
      routineLog = RoutineLogDto.fromJson(json);
    }
    return routineLog;
  }

  /// Helper methods

  int _indexWhereRoutineLog({required String id}) {
    return _routineLogs.indexWhere((log) => log.id == id);
  }

  RoutineLogDto? logWhereId({required String id}) {
    return _routineLogs.firstWhereOrNull((log) => log.id == id);
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

  List<RoutineLogDto> logsWhereDate({required DateTime dateTime}) {
    return _routineLogs.where((log) => log.createdAt.isSameDayMonthYear(dateTime)).toList();
  }

  RoutineLogDto? logWhereDate({required DateTime dateTime}) {
    return _routineLogs.firstWhereOrNull((log) => log.createdAt.isSameDayMonthYear(dateTime));
  }

  void clear() {
    _routineLogs.clear();
    _exerciseLogsById.clear();
    _exerciseLogsByType.clear();
    _weeklyLogs.clear();
    _monthlyLogs.clear();
  }
}
