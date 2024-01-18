import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/routine_log_extension.dart';

import '../dtos/exercise_dto.dart';
import '../dtos/exercise_log_dto.dart';
import '../dtos/set_dto.dart';
import '../enums/exercise_type_enums.dart';
import '../enums/muscle_group_enums.dart';
import '../models/RoutineLog.dart';
import '../models/RoutineTemplate.dart';
import '../shared_prefs.dart';
import '../utils/general_utils.dart';

class AmplifyLogsRepository {
  List<RoutineLogDto> _routineLogs = [];

  Map<DateTimeRange, List<RoutineLogDto>> _weeklyLogs = {};

  Map<DateTimeRange, List<RoutineLogDto>> _monthlyLogs = {};

  Map<String, List<ExerciseLogDto>> _exerciseLogsById = {};

  Map<ExerciseType, List<ExerciseLogDto>> _exerciseLogsByType = {};

  StreamSubscription<QuerySnapshot<RoutineLog>>? _routineLogStream;

  List<RoutineLogDto> get routineLogs => _routineLogs;

  Map<DateTimeRange, List<RoutineLogDto>> get weeklyLogs => _weeklyLogs;

  Map<DateTimeRange, List<RoutineLogDto>> get monthlyLogs => _monthlyLogs;

  Map<String, List<ExerciseLogDto>> get exerciseLogsById => _exerciseLogsById;

  Map<ExerciseType, List<ExerciseLogDto>> get exerciseLogsByType => _exerciseLogsByType;

  void _normaliseLogs() {
    _orderExerciseLogs();
    _loadWeeklyLogs();
    _loadMonthlyLogs();
  }

  void _loadWeeklyLogs() {
    if (_routineLogs.isEmpty) {
      return;
    }

    final map = <DateTimeRange, List<RoutineLogDto>>{};

    DateTime startDate = _routineLogs.first.createdAt;

    List<DateTimeRange> weekRanges = generateWeekRangesFrom(startDate);
    for (var weekRange in weekRanges) {
      map[weekRange] = _routineLogs.where((log) => log.createdAt.isBetweenRange(range: weekRange)).toList();
    }

    _weeklyLogs = map;
  }

  void _loadMonthlyLogs() {
    if (_routineLogs.isEmpty) {
      return;
    }

    final map = <DateTimeRange, List<RoutineLogDto>>{};

    DateTime startDate = _routineLogs.first.createdAt;

    List<DateTimeRange> monthRanges = generateMonthRangesFrom(startDate);

    for (var monthRange in monthRanges) {
      map[monthRange] = _routineLogs.where((log) => log.createdAt.isBetweenRange(range: monthRange)).toList();
    }
    _monthlyLogs = map;
  }

  void _orderExerciseLogs() {
    List<ExerciseLogDto> exerciseLogs = _routineLogs.expand((log) => log.exerciseLogs).toList();
    _exerciseLogsById = groupBy(exerciseLogs, (exerciseLog) => exerciseLog.exercise.id);
    _exerciseLogsByType = groupBy(exerciseLogs, (exerciseLog) => exerciseLog.exercise.type);
  }

  Future<void> fetchLogs({required void Function() onDone}) async {
    List<RoutineLog> logs = await Amplify.DataStore.query(RoutineLog.classType);
    if (logs.isNotEmpty) {
      _loadLogs(logs: logs);
    } else {
      _observeRoutineLogQuery(onDone: onDone);
    }
  }

  void _loadLogs({required List<RoutineLog> logs}) {
    _routineLogs = logs.map((log) => log.dto()).sorted((a, b) => a.createdAt.compareTo(b.createdAt));
    _normaliseLogs();
  }

  Future<RoutineLogDto> saveLog({required RoutineLogDto logDto}) async {
    final now = TemporalDateTime.now();

    final logToCreate = RoutineLog(data: jsonEncode(logDto), createdAt: now, updatedAt: now);

    await Amplify.DataStore.save(logToCreate);

    final updatedWithId = logDto.copyWith(id: logToCreate.id);
    final updatedWithRoutineIds = updatedWithId.copyWith(
        exerciseLogs: updatedWithId.exerciseLogs.map((log) => log.copyWith(routineLogId: logToCreate.id)).toList());
    _routineLogs.add(updatedWithRoutineIds);
    _routineLogs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _normaliseLogs();

    return updatedWithRoutineIds;
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

  void _observeRoutineLogQuery({required void Function() onDone}) {
    _routineLogStream =
        Amplify.DataStore.observeQuery(RoutineLog.classType).listen((QuerySnapshot<RoutineLog> snapshot) {
      if (snapshot.items.isNotEmpty) {
        _loadLogs(logs: snapshot.items);
        onDone();
        _routineLogStream?.cancel();
      }
    })
          ..onDone(() {
            _routineLogStream?.cancel();
          });
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

  List<SetDto> setsForMuscleGroupWhereDateRange({required MuscleGroupFamily muscleGroupFamily, DateTimeRange? range}) {
    bool hasMatchingBodyPart(ExerciseLogDto log) {
      final primaryMuscle = log.exercise.primaryMuscleGroup;
      return primaryMuscle.family == muscleGroupFamily;
    }

    List<List<ExerciseLogDto>> allLogs = _exerciseLogsById.values.toList();

    return allLogs.flattened
        .where((log) => hasMatchingBodyPart(log))
        .where((log) => range != null ? log.createdAt.isBetweenRange(range: range) : true)
        .expand((log) => log.sets)
        .toList();
  }

  List<RoutineLogDto> logsWhereDate({required DateTime dateTime}) {
    return _routineLogs.where((log) => log.createdAt.isSameDateAs(dateTime)).toList();
  }

  RoutineLogDto? logWhereDate({required DateTime dateTime}) {
    return _routineLogs.firstWhereOrNull((log) => log.createdAt.isSameDateAs(dateTime));
  }

  List<ExerciseLogDto> exerciseLogsForExercise({required ExerciseDto exercise}) {
    return _exerciseLogsById[exercise.id] ?? [];
  }

  void reset() {
    _routineLogs.clear();
    _exerciseLogsById.clear();
    _exerciseLogsByType.clear();
    _weeklyLogs.clear();
    _monthlyLogs.clear();
  }
}
