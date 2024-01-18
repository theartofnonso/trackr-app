import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

import '../enums/exercise_type_enums.dart';
import '../utils/general_utils.dart';
import 'exercise_log_dto.dart';

class Logs {
  List<RoutineLogDto> routineLogs = [];

  Map<DateTimeRange, List<RoutineLogDto>> weeklyLogs = {};

  Map<DateTimeRange, List<RoutineLogDto>> monthlyLogs = {};

  Map<String, List<ExerciseLogDto>> exerciseLogsById = {};

  Map<ExerciseType, List<ExerciseLogDto>> exerciseLogsByType = {};

  Logs(this.routineLogs) {
    _orderExerciseLogs();
    _loadWeeklyLogs();
    _loadMonthlyLogs();
  }

  void _loadWeeklyLogs() {
    if (routineLogs.isEmpty) {
      return;
    }

    final map = <DateTimeRange, List<RoutineLogDto>>{};

    DateTime startDate = routineLogs.first.createdAt;

    List<DateTimeRange> weekRanges = generateWeekRangesFrom(startDate);
    for (var weekRange in weekRanges) {
      map[weekRange] = routineLogs.where((log) => log.createdAt.isBetweenRange(range: weekRange)).toList();
    }

    weeklyLogs = map;
  }

  void _loadMonthlyLogs() {
    if (routineLogs.isEmpty) {
      return;
    }

    final map = <DateTimeRange, List<RoutineLogDto>>{};

    DateTime startDate = routineLogs.first.createdAt;

    List<DateTimeRange> monthRanges = generateMonthRangesFrom(startDate);

    for (var monthRange in monthRanges) {
      map[monthRange] = routineLogs.where((log) => log.createdAt.isBetweenRange(range: monthRange)).toList();
    }
    monthlyLogs = map;
  }

  void _orderExerciseLogs() {
    List<ExerciseLogDto> exerciseLogs = routineLogs.expand((log) => log.exerciseLogs).toList();
    exerciseLogsById = groupBy(exerciseLogs, (exerciseLog) => exerciseLog.exercise.id);
    exerciseLogsByType = groupBy(exerciseLogs, (exerciseLog) => exerciseLog.exercise.type);
  }

  List<RoutineLogDto> logsWhereDate({required DateTime dateTime}) {
    return routineLogs.where((log) => log.createdAt.isSameDateAs(dateTime)).toList();
  }
}
