import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/models/Exercise.dart';
import 'package:tracker_app/models/Routine.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

import '../dtos/exercise_log_dto.dart';
import '../enums/exercise_type_enums.dart';
import '../models/RoutineLog.dart';
import '../utils/general_utils.dart';

class RoutineLogProvider with ChangeNotifier {
  Map<String, List<ExerciseLogDto>> _exerciseLogsById = {};

  Map<ExerciseType, List<ExerciseLogDto>> _exerciseLogsByType = {};

  List<RoutineLog> _logs = [];

  Map<DateTimeRange, List<RoutineLog>> _weekToLogs = {};

  Map<DateTimeRange, List<RoutineLog>> _monthToLogs = {};

  UnmodifiableMapView<String, List<ExerciseLogDto>> get exerciseLogsById => UnmodifiableMapView(_exerciseLogsById);

  UnmodifiableMapView<ExerciseType, List<ExerciseLogDto>> get exerciseLogsByType => UnmodifiableMapView(_exerciseLogsByType);

  UnmodifiableListView<RoutineLog> get logs => UnmodifiableListView(_logs);

  UnmodifiableMapView<DateTimeRange, List<RoutineLog>> get weekToLogs => UnmodifiableMapView(_weekToLogs);

  UnmodifiableMapView<DateTimeRange, List<RoutineLog>> get monthToLogs => UnmodifiableMapView(_monthToLogs);

  RoutineLog? cachedRoutineLog;

  List<RoutineLog> _cachedPendingLogs = [];

  List<RoutineLog> get cachedPendingLogs => _cachedPendingLogs;

  void clearCachedPendingLogs() {
    _cachedPendingLogs = [];
    SharedPrefs().cachedPendingRoutineLogs = [];
    notifyListeners();
  }

  void listRoutineLogs() async {
    final routineLogOwner = user();
    final request = ModelQueries.list(RoutineLog.classType, where: RoutineLog.USER.eq(routineLogOwner.id));
    final response = await Amplify.API.query(request: request).response;

    final routineLogs = response.data?.items;
    if (routineLogs != null) {
      _logs = routineLogs.whereType<RoutineLog>().toList();
      _logs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      _normaliseLogs();
      notifyListeners();
    }
  }

  void _orderExercises() {
    List<ExerciseLogDto> exerciseLogs = _logs
        .map((log) => log.procedures.map((json) => ExerciseLogDto.fromJson(routineLog: log, json: jsonDecode(json))))
        .expand((exerciseLogs) => exerciseLogs)
        .toList();
    _exerciseLogsById = groupBy(exerciseLogs, (exerciseLog) => exerciseLog.exercise.id);
    _exerciseLogsByType = groupBy(exerciseLogs, (exerciseLog) {
      final exerciseTypeString = exerciseLog.exercise.type;
      final exerciseType = ExerciseType.fromString(exerciseTypeString);
      return exerciseType;
    });
  }

  void _loadWeekToLogs() {
    if (_logs.isEmpty) {
      return;
    }

    final weekToLogs = <DateTimeRange, List<RoutineLog>>{};

    DateTime startDate = logs.first.createdAt.getDateTimeInUtc();
    List<DateTimeRange> weekRanges = generateWeekRangesFrom(startDate);

    // Map each DateTimeRange to RoutineLogs falling within it
    for (var weekRange in weekRanges) {
      List<RoutineLog> routinesInWeek = logs
          .where((log) =>
              log.createdAt.getDateTimeInUtc().isAfter(weekRange.start) &&
              log.createdAt.getDateTimeInUtc().isBefore(weekRange.end.add(const Duration(days: 1))))
          .toList();
      weekToLogs[weekRange] = routinesInWeek;
    }

    _weekToLogs = weekToLogs;
  }

  void _loadMonthToLogs() {
    if (_logs.isEmpty) {
      return;
    }

    final monthToLogs = <DateTimeRange, List<RoutineLog>>{};

    DateTime startDate = logs.first.createdAt.getDateTimeInUtc();
    List<DateTimeRange> monthRanges = generateMonthRangesFrom(startDate);

    // Map each DateTimeRange to RoutineLogs falling within it
    for (var monthRange in monthRanges) {
      List<RoutineLog> routinesInMonth = logs
          .where((log) =>
              log.createdAt.getDateTimeInUtc().isAfter(monthRange.start) &&
              log.createdAt.getDateTimeInUtc().isBefore(monthRange.end.add(const Duration(days: 1))))
          .toList();
      monthToLogs[monthRange] = routinesInMonth;
    }
    _monthToLogs = monthToLogs;
  }

  void _normaliseLogs() {
    _orderExercises();
    _loadWeekToLogs();
    _loadMonthToLogs();
  }

  Map<String, dynamic> _fixJson(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    json.update("routine", (value) {
      return {"serializedData": value};
    });
    json.update("user", (value) {
      return {"serializedData": value};
    });
    return json;
  }

  void retrieveCachedPendingRoutineLogs(BuildContext context) {
    final cachedLogs = SharedPrefs().cachedPendingRoutineLogs;
    if (cachedLogs.isNotEmpty) {
      _cachedPendingLogs = cachedLogs.map((log) {
        final json = _fixJson(log);
        return RoutineLog.fromJson(json);
      }).toList();
    }
  }

  Future<RoutineLog> saveRoutineLog(
      {required BuildContext context,
      required String name,
      required String notes,
      required List<ExerciseLogDto> exerciseLogs,
      required TemporalDateTime startTime,
      required Routine? routine}) async {
    final exerciseLogJsons = exerciseLogs.map((log) => log.toJson()).toList();

    final logToCreate = RoutineLog(
        name: name,
        notes: notes,
        procedures: exerciseLogJsons,
        startTime: startTime,
        endTime: TemporalDateTime.now(),
        createdAt: TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now(),
        routine: routine,
        user: user());

    try {
      final request = ModelMutations.create(logToCreate);
      final response = await Amplify.API.mutate(request: request).response;
      final createdLog = response.data;
      if (createdLog != null) {
        _addToLogs(createdLog);
        _normaliseLogs();
      }
    } catch (_) {
      _cachePendingLogs(logToCreate);
    }

    return logToCreate;
  }

  void _cachePendingLogs(RoutineLog pendingLog) {
    _cachedPendingLogs.add(pendingLog);
    final pendingLogs = SharedPrefs().cachedPendingRoutineLogs;
    final json = jsonEncode(pendingLog);
    pendingLogs.add(json);
    SharedPrefs().cachedPendingRoutineLogs = pendingLogs;
    notifyListeners();
  }

  void retryPendingRoutineLogs() async {
    final cachedPendingRoutineLogs = SharedPrefs().cachedPendingRoutineLogs;
    for (int index = 0; index < _cachedPendingLogs.length; index++) {
      final pendingLog = _cachedPendingLogs[index];
      final request = ModelMutations.create(pendingLog);
      final response = await Amplify.API.mutate(request: request).response;
      final createdLog = response.data;
      if (createdLog != null) {
        /// Remove from caches i.e both [_cachedPendingLogs] and [SharedPrefs().cachedPendingRoutineLogs]
        _cachedPendingLogs.removeAt(index);
        cachedPendingRoutineLogs.removeAt(index);
        SharedPrefs().cachedPendingRoutineLogs = cachedPendingRoutineLogs;

        /// Add to logs
        _addToLogs(createdLog);
      }
    }
  }

  void _addToLogs(RoutineLog log) {
    _logs.add(log);
    _logs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  void cacheRoutineLog(
      {required String name,
      required String notes,
      required List<ExerciseLogDto> procedures,
      required TemporalDateTime startTime,
      TemporalDateTime? createdAt,
      required Routine? routine}) async {
    final currentTime = TemporalDateTime.now();

    final exerciseLogJson = procedures.map((procedure) => procedure.toJson()).toList();

    final logToCache = RoutineLog(
        name: name,
        notes: notes,
        routine: routine,
        procedures: exerciseLogJson,
        startTime: startTime,
        endTime: currentTime,
        createdAt: createdAt ?? currentTime,
        updatedAt: currentTime,
        user: user());
    cachedRoutineLog = logToCache;
    SharedPrefs().cachedRoutineLog = jsonEncode(logToCache);
  }

  Future<void> removeLog({required String id}) async {
    final index = _indexWhereRoutineLog(id: id);
    final logToBeRemoved = _logs[index];
    final request = ModelMutations.delete(logToBeRemoved);
    final response = await Amplify.API.mutate(request: request).response;
    final deletedLog = response.data;
    if (deletedLog != null) {
      final index = _indexWhereRoutineLog(id: id);
      _logs.removeAt(index);
      _normaliseLogs();
      notifyListeners();
    }
  }

  int _indexWhereRoutineLog({required String id}) {
    return _logs.indexWhere((log) => log.id == id);
  }

  RoutineLog? whereRoutineLog({required String id}) {
    return _logs.firstWhereOrNull((log) => log.id == id);
  }

  List<SetDto> wherePastSets({required Exercise exercise}) {
    final exerciseLogs = _exerciseLogsById[exercise.id]?.reversed.toList() ?? [];
    return exerciseLogs.isNotEmpty ? exerciseLogs.first.sets : [];
  }

  List<SetDto> setsForMuscleGroupWhereDateRange(
      {required MuscleGroupFamily muscleGroupFamily, required DateTimeRange range}) {
    bool hasMatchingBodyPart(ExerciseLogDto log) {
      final primaryMuscle = MuscleGroup.fromString(log.exercise.primaryMuscle);
      return primaryMuscle.family == muscleGroupFamily;
    }

    List<List<ExerciseLogDto>> allLogs = _exerciseLogsById.values.toList();

    return allLogs.flattened
        .where((log) => hasMatchingBodyPart(log))
        .where((log) => log.createdAt.getDateTimeInUtc().isBetweenRange(range: range))
        .expand((log) => log.sets)
        .toList();
  }

  bool isLatestLogForTemplate({required String templateId, required logId}) {
    final logsForTemplate = _logs.firstWhereOrNull((log) => log.routine?.id == templateId);
    if (logsForTemplate == null) {
      return false;
    } else {
      return logsForTemplate.id == logId;
    }
  }

  List<RoutineLog> logsWhereDate({required DateTime dateTime}) {
    return _logs.where((log) => log.createdAt.getDateTimeInUtc().isSameDateAs(dateTime)).toList();
  }

  RoutineLog? logWhereDate({required DateTime dateTime}) {
    return _logs.firstWhereOrNull((log) => log.createdAt.getDateTimeInUtc().isSameDateAs(dateTime));
  }

  List<ExerciseLogDto> exerciseLogsWhereDateRange({required DateTimeRange range, required Exercise exercise}) {
    final values = _exerciseLogsById[exercise.id] ?? [];
    return values.where((log) => log.createdAt.getDateTimeInUtc().isBetweenRange(range: range)).toList();
  }

  List<RoutineLog> logsWhereDateRange({required DateTimeRange range}) {
    return _logs.where((log) => log.createdAt.getDateTimeInUtc().isBetweenRange(range: range)).toList();
  }

  void reset() {
    _logs.clear();
    notifyListeners();
  }
}
