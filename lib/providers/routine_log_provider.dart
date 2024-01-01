import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/extensions/routine_log_extension.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

import '../dtos/exercise_dto.dart';
import '../dtos/exercise_log_dto.dart';
import '../dtos/routine_log_dto.dart';
import '../enums/exercise_type_enums.dart';
import '../utils/general_utils.dart';

const emptyTemplateId = "empty_template_id";

class RoutineLogProvider with ChangeNotifier {
  Map<String, List<ExerciseLogDto>> _exerciseLogsById = {};

  Map<ExerciseType, List<ExerciseLogDto>> _exerciseLogsByType = {};

  List<RoutineLogDto> _logs = [];

  Map<DateTimeRange, List<RoutineLogDto>> _weekToLogs = {};

  Map<DateTimeRange, List<RoutineLogDto>> _monthToLogs = {};

  UnmodifiableMapView<String, List<ExerciseLogDto>> get exerciseLogsById => UnmodifiableMapView(_exerciseLogsById);

  UnmodifiableMapView<ExerciseType, List<ExerciseLogDto>> get exerciseLogsByType =>
      UnmodifiableMapView(_exerciseLogsByType);

  UnmodifiableListView<RoutineLogDto> get logs => UnmodifiableListView(_logs);

  UnmodifiableMapView<DateTimeRange, List<RoutineLogDto>> get weekToLogs => UnmodifiableMapView(_weekToLogs);

  UnmodifiableMapView<DateTimeRange, List<RoutineLogDto>> get monthToLogs => UnmodifiableMapView(_monthToLogs);

  void listLogs({List<RoutineLog>? logs}) async {
    final queries = logs ?? await Amplify.DataStore.query(RoutineLog.classType);
    _logs = queries.map((log) => log.dto()).toList();
    _logs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _normaliseLogs();
    notifyListeners();
  }

  void _orderExerciseLogs() {
    List<ExerciseLogDto> exerciseLogs = _logs.expand((log) => log.exerciseLogs).toList();
    _exerciseLogsById = groupBy(exerciseLogs, (exerciseLog) => exerciseLog.exercise.id);
    _exerciseLogsByType = groupBy(exerciseLogs, (exerciseLog) {
      final exerciseType = exerciseLog.exercise.type;
      return exerciseType;
    });
  }

  void _loadWeekToLogs() {
    if (_logs.isEmpty) {
      return;
    }

    final weekToLogs = <DateTimeRange, List<RoutineLogDto>>{};

    DateTime startDate = _logs.first.createdAt;
    List<DateTimeRange> weekRanges = generateWeekRangesFrom(startDate);

    // Map each DateTimeRange to RoutineLogs falling within it
    for (var weekRange in weekRanges) {
      List<RoutineLogDto> routinesInWeek = _logs
          .where((log) =>
              log.createdAt.isAfter(weekRange.start) &&
              log.createdAt.isBefore(weekRange.end.add(const Duration(days: 1))))
          .toList();
      weekToLogs[weekRange] = routinesInWeek;
    }

    _weekToLogs = weekToLogs;
  }

  void _loadMonthToLogs() {
    if (_logs.isEmpty) {
      return;
    }

    final monthToLogs = <DateTimeRange, List<RoutineLogDto>>{};

    DateTime startDate = _logs.first.createdAt;
    List<DateTimeRange> monthRanges = generateMonthRangesFrom(startDate);

    // Map each DateTimeRange to RoutineLogs falling within it
    for (var monthRange in monthRanges) {
      List<RoutineLogDto> routinesInMonth = _logs
          .where((log) =>
              log.createdAt.isAfter(monthRange.start) &&
              log.createdAt.isBefore(monthRange.end.add(const Duration(days: 1))))
          .toList();
      monthToLogs[monthRange] = routinesInMonth;
    }
    _monthToLogs = monthToLogs;
  }

  void _normaliseLogs() {
    _orderExerciseLogs();
    _loadWeekToLogs();
    _loadMonthToLogs();
  }

  Future<RoutineLogDto> saveRoutineLog({required RoutineLogDto logDto}) async {
    final now = TemporalDateTime.now();

    final logToCreate = RoutineLog(data: jsonEncode(logDto), createdAt: now, updatedAt: now);

    await Amplify.DataStore.save(logToCreate);

    final updatedWithId = logDto.copyWith(id: logToCreate.id);
    final updatedWithRoutineIds = updatedWithId.copyWith(
        exerciseLogs: updatedWithId.exerciseLogs.map((log) => log.copyWith(routineLogId: logToCreate.id)).toList());
    _logs.add(updatedWithRoutineIds);
    _logs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _normaliseLogs();
    notifyListeners();

    return updatedWithRoutineIds;
  }

  Future<void> updateRoutineLog({required RoutineLogDto log}) async {
    final result = (await Amplify.DataStore.query(
      RoutineLog.classType,
      where: RoutineLog.ID.eq(log.id),
    ));

    if (result.isNotEmpty) {
      final oldLog = result.first;
      final newLog = oldLog.copyWith(data: jsonEncode(log));
      await Amplify.DataStore.save(newLog);
      final index = _indexWhereRoutineLog(id: log.id);
      _logs[index] = log;
      _normaliseLogs();
      notifyListeners();
    }
  }

  void cacheRoutineLog({required RoutineLogDto logDto}) {
    SharedPrefs().cachedRoutineLog = jsonEncode(logDto);
  }

  Future<void> removeLog({required String id}) async {
    final result = (await Amplify.DataStore.query(
      RoutineLog.classType,
      where: RoutineTemplate.ID.eq(id),
    ));

    if (result.isNotEmpty) {
      final oldTemplate = result.first;
      await Amplify.DataStore.delete(oldTemplate);
      final index = _indexWhereRoutineLog(id: id);
      _logs.removeAt(index);
      _normaliseLogs();
      notifyListeners();
    }
  }

  int _indexWhereRoutineLog({required String id}) {
    return _logs.indexWhere((log) => log.id == id);
  }

  RoutineLogDto? whereRoutineLog({required String id}) {
    return _logs.firstWhereOrNull((log) => log.id == id);
  }

  List<SetDto> wherePastSets({required ExerciseDto exercise}) {
    final exerciseLogs = _exerciseLogsById[exercise.id]?.reversed.toList() ?? [];
    return exerciseLogs.isNotEmpty ? exerciseLogs.first.sets : [];
  }

  List<SetDto> setsForMuscleGroupWhereDateRange(
      {required MuscleGroupFamily muscleGroupFamily, required DateTimeRange range}) {
    bool hasMatchingBodyPart(ExerciseLogDto log) {
      final primaryMuscle = log.exercise.primaryMuscleGroup;
      return primaryMuscle.family == muscleGroupFamily;
    }

    List<List<ExerciseLogDto>> allLogs = _exerciseLogsById.values.toList();

    return allLogs.flattened
        .where((log) => hasMatchingBodyPart(log))
        .where((log) => log.createdAt.isBetweenRange(range: range))
        .expand((log) => log.sets)
        .toList();
  }

  List<RoutineLogDto> logsWhereDate({required DateTime dateTime}) {
    return _logs.where((log) => log.createdAt.isSameDateAs(dateTime)).toList();
  }

  RoutineLogDto? logWhereDate({required DateTime dateTime}) {
    return _logs.firstWhereOrNull((log) => log.createdAt.isSameDateAs(dateTime));
  }

  List<ExerciseLogDto> exerciseLogsWhereDateRange({required DateTimeRange range, required ExerciseDto exercise}) {
    final values = _exerciseLogsById[exercise.id] ?? [];
    return values.where((log) => log.createdAt.isBetweenRange(range: range)).toList();
  }

  List<RoutineLogDto> logsWhereDateRange({required DateTimeRange range}) {
    return _logs.where((log) => log.createdAt.isBetweenRange(range: range)).toList();
  }

  void reset() {
    _logs.clear();
    _exerciseLogsById.clear();
    _exerciseLogsByType.clear();
    _weekToLogs.clear();
    _monthToLogs.clear();
    notifyListeners();
  }
}
