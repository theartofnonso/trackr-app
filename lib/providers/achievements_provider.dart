import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/progress_dto.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/routine_log_extension.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';

import '../dtos/exercise_log_dto.dart';
import '../enums/achievement_type_enums.dart';
import '../enums/muscle_group_enums.dart';

ProgressDto calculateProgress({required BuildContext context, required AchievementType type}) {
  final provider = Provider.of<RoutineLogProvider>(context, listen: false);
  final logs = provider.logs;
  final weekToLogs = provider.weekToLogs;
  return switch (type) {
    AchievementType.days12 => _calculateDaysAchievement(logs: logs, type: type),
    AchievementType.days30 => _calculateDaysAchievement(logs: logs, type: type),
    AchievementType.days75 => _calculateDaysAchievement(logs: logs, type: type),
    AchievementType.days100 => _calculateDaysAchievement(logs: logs, type: type),
    AchievementType.supersetSpecialist => _calculateSuperSetSpecialistAchievement(logs: logs),
    AchievementType.obsessed => _calculateObsessedAchievement(weekToLogs: weekToLogs, target: 16),
    AchievementType.neverSkipAMonday => _calculateNeverSkipAMondayAchievement(weekToLogs: weekToLogs, target: 16),
    AchievementType.neverSkipALegDay => _calculateNeverSkipALegDayAchievement(weekToLogs: weekToLogs, target: 16),
    AchievementType.weekendWarrior => _calculateWeekendWarriorAchievement(weekToLogs: weekToLogs, target: 8),
    AchievementType.sweatEquity => _calculateSweatEquityAchievement(logs: logs),
    _ => ProgressDto(value: 0.0, remainder: 0, dates: {}),
  };
}

int _adjustRemainder({required int remainder}) {
  if (remainder < 0) {
    return 0;
  }

  return remainder;
}

/// AchievementType.days12
/// AchievementType.days30
/// AchievementType.days75
/// AchievementType.days100
ProgressDto _calculateDaysAchievement({required List<RoutineLog> logs, required AchievementType type}) {
  int targetDays;
  switch (type) {
    case AchievementType.days12:
      targetDays = 12;
      break;
    case AchievementType.days30:
      targetDays = 30;
      break;
    case AchievementType.days75:
      targetDays = 75;
      break;
    case AchievementType.days100:
      targetDays = 100;
      break;
    default:
      return ProgressDto(value: 0, remainder: 0, dates: {});
  }

  final achievedLogs = logs.take(targetDays);

  final progress = achievedLogs.length / targetDays;
  final remainder = targetDays - achievedLogs.length;

  final dates = achievedLogs.map((log) => log.createdAt.getDateTimeInUtc().localDate()).toList();
  final datesByMonth = groupBy(dates, (date) => date.month);

  return ProgressDto(value: progress, remainder: _adjustRemainder(remainder: remainder), dates: datesByMonth);
}

/// AchievementType.supersetSpecialist
ProgressDto _calculateSuperSetSpecialistAchievement({required List<RoutineLog> logs}) {
  int target = 20;

  // Count RoutineLogs with at least two exercises that have a non-null superSetId
  final achievedLogs = logs.where((log) {
    var exercisesWithSuperSetId = log.procedures
        .map((json) => ExerciseLogDto.fromJson(routineLog: log, json: jsonDecode(json)))
        .where((exerciseLog) => exerciseLog.superSetId.isNotEmpty)
        .length;

    return exercisesWithSuperSetId >= 2;
  }).toList();

  final dates = achievedLogs.map((log) => log.createdAt.getDateTimeInUtc().localDate()).toList();
  final datesByMonth = groupBy(dates, (date) => date.month);

  final progress = achievedLogs.length / target;
  final remainder = target - achievedLogs.length;

  return ProgressDto(value: progress, remainder: _adjustRemainder(remainder: remainder), dates: datesByMonth);
}

/// AchievementType.obsessed
List<DateTimeRange> _consecutiveWeeksWithLogsWhere(
    {required Map<DateTimeRange, List<RoutineLog>> weekToRoutineLogs,
    required bool Function(MapEntry<DateTimeRange, List<RoutineLog>> week) evaluation}) {
  List<DateTimeRange> dateRanges = [];

  for (var entry in weekToRoutineLogs.entries) {
    final evaluated = evaluation(entry);
    if (evaluated) {
      dateRanges.add(entry.key);
    } else {
      dateRanges = [];
    }
  }

  return dateRanges;
}

ProgressDto _consecutiveAchievementProgress(
    {required List<DateTimeRange> dateTimeRanges,
    required int target,
    required Map<DateTimeRange, List<RoutineLog>> weekToLogs}) {
  final dates = dateTimeRanges
      .map((range) => weekToLogs[range] ?? [])
      .expand((log) => log)
      .map((log) => log.createdAt.getDateTimeInUtc().localDate())
      .toList();
  final datesByMonth = groupBy(dates, (date) => date.month);

  int remainder = target - dateTimeRanges.length;

  final progress = dateTimeRanges.length / target;

  return ProgressDto(value: progress, remainder: _adjustRemainder(remainder: remainder), dates: datesByMonth);
}

ProgressDto _calculateObsessedAchievement(
    {required Map<DateTimeRange, List<RoutineLog>> weekToLogs, required int target}) {
  final dateTimeRanges =
      _consecutiveWeeksWithLogsWhere(weekToRoutineLogs: weekToLogs, evaluation: (entry) => entry.value.isNotEmpty);
  return _consecutiveAchievementProgress(dateTimeRanges: dateTimeRanges, target: target, weekToLogs: weekToLogs);
}

bool _hasLegExercise(RoutineLog log) {
  return log.procedures.any((procedure) {
    final json = jsonDecode(procedure);
    final exerciseString = json["exercise"];
    final exercise = Exercise.fromJson(exerciseString);
    final muscleGroup = MuscleGroup.fromString(exercise.primaryMuscle);
    return muscleGroup.family == MuscleGroupFamily.legs;
  });
}

/// AchievementType.neverSkipAMonday
ProgressDto _calculateNeverSkipALegDayAchievement(
    {required Map<DateTimeRange, List<RoutineLog>> weekToLogs, required int target}) {
  final dateTimeRanges = _consecutiveWeeksWithLogsWhere(
      weekToRoutineLogs: weekToLogs, evaluation: (entry) => entry.value.any((log) => _hasLegExercise(log)));
  return _consecutiveAchievementProgress(dateTimeRanges: dateTimeRanges, target: target, weekToLogs: weekToLogs);
}

/// AchievementType.neverSkipAMonday
bool _loggedOnMonday(RoutineLog log) {
  return log.createdAt.getDateTimeInUtc().weekday == 1;
}

ProgressDto _calculateNeverSkipAMondayAchievement(
    {required Map<DateTimeRange, List<RoutineLog>> weekToLogs, required int target}) {
  final dateTimeRanges = _consecutiveWeeksWithLogsWhere(
      weekToRoutineLogs: weekToLogs, evaluation: (entry) => entry.value.any((log) => _loggedOnMonday(log)));
  return _consecutiveAchievementProgress(dateTimeRanges: dateTimeRanges, target: target, weekToLogs: weekToLogs);
}

/// AchievementType.weekendWarrior
bool _loggedOnWeekend(RoutineLog log) {
  return log.createdAt.getDateTimeInUtc().weekday == 6 || log.createdAt.getDateTimeInUtc().weekday == 7;
}

ProgressDto _calculateWeekendWarriorAchievement(
    {required Map<DateTimeRange, List<RoutineLog>> weekToLogs, required int target}) {
  final dateTimeRanges = _consecutiveWeeksWithLogsWhere(
      weekToRoutineLogs: weekToLogs,
      evaluation: (entry) => entry.value.where((log) => _loggedOnWeekend(log)).length == 2);
  return _consecutiveAchievementProgress(dateTimeRanges: dateTimeRanges, target: target, weekToLogs: weekToLogs);
}

/// AchievementType.sweatEquity
ProgressDto _calculateSweatEquityAchievement({required List<RoutineLog> logs}) {
  const targetHours = Duration(hours: 100);

  final duration = logs.map((log) => log.duration()).reduce((total, duration) => total + duration);

  final progress = duration.inHours / targetHours.inHours;

  final remainder = targetHours - duration;

  return ProgressDto(value: progress, remainder: _adjustRemainder(remainder: remainder.inHours), dates: {});
}
