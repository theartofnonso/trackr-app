import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/db/exercise_dto.dart';
import 'package:tracker_app/dtos/db/routine_log_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/set_dtos/set_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';
import 'package:tracker_app/utils/routine_utils.dart';

class MockRoutineLogRepository {
  List<RoutineLogDto> _logs = [];

  UnmodifiableListView<RoutineLogDto> get logs => UnmodifiableListView(_logs);

  Map<String, List<ExerciseLogDto>> _exerciseLogsByExerciseId = {};
  UnmodifiableMapView<String, List<ExerciseLogDto>>
      get exerciseLogsByExerciseId =>
          UnmodifiableMapView(_exerciseLogsByExerciseId);

  Map<MuscleGroup, List<ExerciseLogDto>> _exerciseLogsByMuscleGroup = {};
  UnmodifiableMapView<MuscleGroup, List<ExerciseLogDto>>
      get exerciseLogsByMuscleGroup =>
          UnmodifiableMapView(_exerciseLogsByMuscleGroup);

  void loadLogs({required List<RoutineLogDto> logs}) {
    _logs = logs;
    _group();
  }

  Future<RoutineLogDto> saveLog(
      {required RoutineLogDto logDto, DateTime? datetime}) async {
    final id = logDto.id.isEmpty
        ? DateTime.now().microsecondsSinceEpoch.toString()
        : logDto.id;
    final start = datetime ?? logDto.startTime;
    final created = logDto.copyWith(
        id: id, startTime: start, createdAt: start, updatedAt: DateTime.now());
    _logs = [created, ..._logs];
    _group();
    return created;
  }

  Future<void> updateLog({required RoutineLogDto log}) async {
    _logs = _logs
        .map(
            (l) => l.id == log.id ? log.copyWith(updatedAt: DateTime.now()) : l)
        .toList();
    _group();
  }

  Future<void> removeLog({required RoutineLogDto log}) async {
    _logs = _logs.where((l) => l.id != log.id).toList();
    _group();
  }

  RoutineLogDto? logWhereId({required String id}) {
    return _logs.firstWhereOrNull((log) => log.id == id);
  }

  RoutineLogDto? whereLogIsSameDay({required DateTime dateTime}) {
    return _logs.firstWhereOrNull(
        (log) => _isSameDayMonthYear(log.createdAt, dateTime));
  }

  RoutineLogDto? whereLogIsSameMonth({required DateTime dateTime}) {
    return _logs
        .firstWhereOrNull((log) => _isSameMonthYear(log.createdAt, dateTime));
  }

  RoutineLogDto? whereLogIsSameYear({required DateTime dateTime}) {
    return _logs
        .firstWhereOrNull((log) => _isSameYear(log.createdAt, dateTime));
  }

  List<RoutineLogDto> whereLogsIsSameDay({required DateTime dateTime}) {
    return _logs
        .where((log) => _isSameDayMonthYear(log.createdAt, dateTime))
        .toList();
  }

  List<RoutineLogDto> whereLogsIsSameMonth({required DateTime dateTime}) {
    return _logs
        .where((log) => _isSameMonthYear(log.createdAt, dateTime))
        .toList();
  }

  List<RoutineLogDto> whereLogsIsSameYear({required DateTime dateTime}) {
    return _logs.where((log) => _isSameYear(log.createdAt, dateTime)).toList();
  }

  List<RoutineLogDto> whereLogsIsWithinRange({required DateTimeRange range}) {
    return _logs
        .where((log) =>
            log.createdAt.isAfter(range.start) &&
            log.createdAt.isBefore(range.end))
        .toList();
  }

  List<RoutineLogDto> whereRoutineLogsBefore(
      {required String templateId, required DateTime date}) {
    return _logs
        .where((log) =>
            log.templateId == templateId && log.createdAt.isBefore(date))
        .toList();
  }

  List<RoutineLogDto> whereLogsWithTemplateId({required String templateId}) {
    return _logs.where((log) => log.templateId == templateId).toList();
  }

  List<RoutineLogDto> whereLogsWithTemplateName(
      {required String templateName}) {
    return _logs.where((log) => log.name == templateName).toList();
  }

  List<ExerciseLogDto> whereExerciseLogsBefore(
      {required ExerciseDto exercise, required DateTime date}) {
    final exerciseLogs = _exerciseLogsByExerciseId[exercise.id]
            ?.where((log) => log.createdAt.isBefore(date))
            .toList() ??
        [];
    final completedExercises =
        loggedExercises(exerciseLogs: exerciseLogs.toList());
    return completedExercises;
  }

  List<SetDto> whereRecentSetsForExercise({required ExerciseDto exercise}) {
    final exerciseLogs = _exerciseLogsByExerciseId[exercise.id]?.reversed ?? [];
    final completedExercises =
        loggedExercises(exerciseLogs: exerciseLogs.toList());
    return completedExercises.isNotEmpty ? completedExercises.first.sets : [];
  }

  List<SetDto> wherePrevSetsForExercise(
      {required ExerciseDto exercise, int? take}) {
    final logs = _exerciseLogsByExerciseId[exercise.id];
    if (logs == null || logs.isEmpty) return const [];
    final Iterable<ExerciseLogDto> recent =
        take == null ? logs.reversed : logs.reversed.take(take);
    return [
      for (final log in recent)
        for (final set in log.sets)
          if (set.checked && set.isNotEmpty()) set
    ];
  }

  List<SetDto> wherePrevSetsGroupForIndex(
      {required ExerciseDto exercise, required int index, int? take}) {
    if (index < 0) return const [];
    final logs = _exerciseLogsByExerciseId[exercise.id];
    if (logs == null || logs.isEmpty) return const [];
    final Iterable<ExerciseLogDto> recent =
        take == null ? logs.reversed : logs.reversed.take(take);
    final result = <SetDto>[];
    for (final log in recent) {
      if (index < log.sets.length) result.add(log.sets[index]);
    }
    return result;
  }

  void clear() {
    _logs.clear();
    _exerciseLogsByExerciseId.clear();
    _exerciseLogsByMuscleGroup.clear();
  }

  void _group() {
    _exerciseLogsByExerciseId =
        groupExerciseLogsByExerciseId(routineLogs: _logs);
    _exerciseLogsByMuscleGroup =
        groupExerciseLogsByMuscleGroup(routineLogs: _logs);
  }

  bool _isSameDayMonthYear(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  bool _isSameMonthYear(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;
  bool _isSameYear(DateTime a, DateTime b) => a.year == b.year;
}
