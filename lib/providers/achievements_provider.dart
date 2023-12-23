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

/// AchievementType.days12
/// AchievementType.days30
/// AchievementType.days75
/// AchievementType.days100
ProgressDto _calculateDaysAchievement({required List<RoutineLog> logs, required AchievementType type}) {
  Iterable<RoutineLog> achievedLogs = switch (type) {
    AchievementType.days12 => logs.take(12),
    AchievementType.days30 => logs.take(30),
    AchievementType.days75 => logs.take(75),
    AchievementType.days100 => logs.take(100),
    _ => [],
  };

  double progress = switch (type) {
    AchievementType.days12 => achievedLogs.length / 12,
    AchievementType.days30 => achievedLogs.length / 30,
    AchievementType.days75 => achievedLogs.length / 75,
    AchievementType.days100 => achievedLogs.length / 100,
    _ => 0.0,
  };

  int remainder = switch (type) {
    AchievementType.days12 => 12 - achievedLogs.length,
    AchievementType.days30 => 30 - achievedLogs.length,
    AchievementType.days75 => 75 - achievedLogs.length,
    AchievementType.days100 => 100 - achievedLogs.length,
    _ => 0,
  };

  final dates = achievedLogs.map((log) => log.createdAt.getDateTimeInUtc().localDate()).toList();
  final datesByMonth = groupBy(dates, (date) => date.month);

  return ProgressDto(value: progress, remainder: remainder < 0 ? 0 : remainder, dates: datesByMonth);
}

/// AchievementType.supersetSpecialist
ProgressDto _calculateSuperSetSpecialistAchievement({required List<RoutineLog> logs}) {
  int target = 20;
  // Count RoutineLogs with at least two exercises that have a non-null superSetId
  int count = 0;

  for (var log in logs) {
    int exercisesWithSuperSetId = log.procedures
        .map((json) => ExerciseLogDto.fromJson(routineLog: log, json: jsonDecode(json)))
        .where((exerciseLog) => exerciseLog.superSetId.isNotEmpty)
        .length;

    if (exercisesWithSuperSetId >= 2) {
      count++;
    }
  }

  final progress = count / target;
  final remainder = target - count;

  return ProgressDto(value: progress, remainder: remainder, dates: {});
}

/// AchievementType.obsessed
({List<DateTimeRange> occurrences, int consecutiveWeeks}) _consecutiveWeeksWithLogsWhere(
    {required Map<DateTimeRange, List<RoutineLog>> weekToRoutineLogs,
    required int targetWeeks,
    required bool Function(MapEntry<DateTimeRange, List<RoutineLog>> week) evaluation}) {
  List<DateTimeRange> occurrences = [];
  int consecutiveWeeks = 0;
  int index = 0;

  for (var entry in weekToRoutineLogs.entries) {
    final evaluated = evaluation(entry);
    if (evaluated) {
      consecutiveWeeks++;
      if (consecutiveWeeks % targetWeeks == 0) {
        final startWeek = weekToRoutineLogs.entries.elementAt(index - (targetWeeks - 1));
        final DateTimeRange range = DateTimeRange(start: startWeek.key.start, end: entry.key.end);
        occurrences.add(range);
        consecutiveWeeks = 0;
      }
    } else {
      if (occurrences.isEmpty) {
        occurrences = [];
      }
    }
    index++;
  }

  return (occurrences: occurrences, consecutiveWeeks: consecutiveWeeks);
}

ProgressDto _achievementProgress(
    {required int consecutiveWeeks,
    required List<DateTimeRange> occurrences,
    required int target,
    required insufficientLogs}) {
  if (insufficientLogs) {
    return ProgressDto(value: consecutiveWeeks / target, remainder: target - consecutiveWeeks, dates: {});
  }

  int remainder = target - consecutiveWeeks;

  final progress = occurrences.isNotEmpty ? 1.0 : consecutiveWeeks / target;

  if (occurrences.isNotEmpty || remainder <= 0) {
    remainder = 0;
  }

  return ProgressDto(value: progress, remainder: remainder, dates: {});
}

ProgressDto _calculateObsessedAchievement(
    {required Map<DateTimeRange, List<RoutineLog>> weekToLogs, required int target}) {
  final result = _consecutiveWeeksWithLogsWhere(
      weekToRoutineLogs: weekToLogs, targetWeeks: target, evaluation: (entry) => entry.value.isNotEmpty);
  return _achievementProgress(
      consecutiveWeeks: result.consecutiveWeeks,
      occurrences: result.occurrences,
      target: target,
      insufficientLogs: weekToLogs.length < target);
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
  final result = _consecutiveWeeksWithLogsWhere(
      weekToRoutineLogs: weekToLogs,
      targetWeeks: target,
      evaluation: (entry) => entry.value.any((log) => _hasLegExercise(log)));
  return _achievementProgress(
      consecutiveWeeks: result.consecutiveWeeks,
      occurrences: result.occurrences,
      target: target,
      insufficientLogs: weekToLogs.length < target);
}

/// AchievementType.neverSkipAMonday
bool _loggedOnMonday(RoutineLog log) {
  return log.createdAt.getDateTimeInUtc().weekday == 1;
}

ProgressDto _calculateNeverSkipAMondayAchievement(
    {required Map<DateTimeRange, List<RoutineLog>> weekToLogs, required int target}) {
  final result = _consecutiveWeeksWithLogsWhere(
      weekToRoutineLogs: weekToLogs,
      targetWeeks: target,
      evaluation: (entry) => entry.value.any((log) => _loggedOnMonday(log)));
  return _achievementProgress(
      consecutiveWeeks: result.consecutiveWeeks,
      occurrences: result.occurrences,
      target: target,
      insufficientLogs: weekToLogs.length < target);
}

/// AchievementType.weekendWarrior
bool _loggedOnWeekend(RoutineLog log) {
  return log.createdAt.getDateTimeInUtc().weekday == 6 || log.createdAt.getDateTimeInUtc().weekday == 7;
}

ProgressDto _calculateWeekendWarriorAchievement(
    {required Map<DateTimeRange, List<RoutineLog>> weekToLogs, required int target}) {
  final result = _consecutiveWeeksWithLogsWhere(
      weekToRoutineLogs: weekToLogs,
      targetWeeks: target,
      evaluation: (entry) => entry.value.where((log) => _loggedOnWeekend(log)).length == 2);
  return _achievementProgress(
      consecutiveWeeks: result.consecutiveWeeks,
      occurrences: result.occurrences,
      target: target,
      insufficientLogs: weekToLogs.length < target);
}

/// AchievementType.sweatEquity
ProgressDto _calculateSweatEquityAchievement({required List<RoutineLog> logs}) {
  const targetHours = Duration(hours: 100);

  final duration = logs.map((log) => log.duration()).reduce((total, duration) => total + duration);

  final progress = duration.inHours / targetHours.inHours;

  final remainder = targetHours - duration;

  return ProgressDto(value: progress, remainder: remainder < Duration.zero ? 0 : remainder.inHours, dates: {});
}
