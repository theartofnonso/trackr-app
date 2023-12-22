import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/routine_log_extension.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';

import '../dtos/exercise_log_dto.dart';
import '../enums/achievement_type_enums.dart';
import '../enums/muscle_group_enums.dart';
import '../models/Exercise.dart';
import '../models/RoutineLog.dart';

({int difference, double progress}) calculateProgress({required BuildContext context, required AchievementType type}) {
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
    _ => (progress: 0, difference: 0)
  };
}

/// AchievementType.days12
/// AchievementType.days30
/// AchievementType.days75
/// AchievementType.days100
({int difference, double progress}) _calculateDaysAchievement(
    {required List<RoutineLog> logs, required AchievementType type}) {
  final targetDays = switch (type) {
    AchievementType.days12 => 12,
    AchievementType.days30 => 30,
    AchievementType.days75 => 75,
    AchievementType.days100 => 100,
    _ => 0,
  };

  final difference = targetDays - logs.length;

  final progress = logs.length / targetDays;

  return (progress: progress, difference: difference < 0 ? 0 : difference);
}

/// AchievementType.supersetSpecialist
({int difference, double progress}) _calculateSuperSetSpecialistAchievement({required List<RoutineLog> logs}) {
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
  final difference = target - count;

  return (progress: progress, difference: difference < 0 ? 0 : difference);
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

({int difference, double progress}) _achievementProgress(
    {required int consecutiveWeeks,
    required List<DateTimeRange> occurrences,
    required int target,
    required hasSufficientLogs}) {
  if (hasSufficientLogs) {
    return (progress: consecutiveWeeks / target, difference: target - consecutiveWeeks);
  }

  int difference = target - consecutiveWeeks;

  final progress = occurrences.isNotEmpty ? 1 : consecutiveWeeks / target;

  if (occurrences.isNotEmpty || difference <= 0) {
    difference = 0;
  }

  return (progress: progress.toDouble(), difference: difference);
}

({int difference, double progress}) _calculateObsessedAchievement(
    {required Map<DateTimeRange, List<RoutineLog>> weekToLogs, required int target}) {
  final result = _consecutiveWeeksWithLogsWhere(
      weekToRoutineLogs: weekToLogs, targetWeeks: target, evaluation: (entry) => entry.value.isNotEmpty);
  return _achievementProgress(
      consecutiveWeeks: result.consecutiveWeeks,
      occurrences: result.occurrences,
      target: target,
      hasSufficientLogs: weekToLogs.length < target);
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
({int difference, double progress}) _calculateNeverSkipALegDayAchievement(
    {required Map<DateTimeRange, List<RoutineLog>> weekToLogs, required int target}) {
  final result = _consecutiveWeeksWithLogsWhere(
      weekToRoutineLogs: weekToLogs,
      targetWeeks: target,
      evaluation: (entry) => entry.value.any((log) => _hasLegExercise(log)));
  return _achievementProgress(
      consecutiveWeeks: result.consecutiveWeeks,
      occurrences: result.occurrences,
      target: target,
      hasSufficientLogs: weekToLogs.length < target);
}

/// AchievementType.neverSkipAMonday
bool _loggedOnMonday(RoutineLog log) {
  return log.createdAt.getDateTimeInUtc().weekday == 1;
}

({int difference, double progress}) _calculateNeverSkipAMondayAchievement(
    {required Map<DateTimeRange, List<RoutineLog>> weekToLogs, required int target}) {
  final result = _consecutiveWeeksWithLogsWhere(
      weekToRoutineLogs: weekToLogs,
      targetWeeks: target,
      evaluation: (entry) => entry.value.any((log) => _loggedOnMonday(log)));
  return _achievementProgress(
      consecutiveWeeks: result.consecutiveWeeks,
      occurrences: result.occurrences,
      target: target,
      hasSufficientLogs: weekToLogs.length < target);
}

/// AchievementType.weekendWarrior
bool _loggedOnWeekend(RoutineLog log) {
  return log.createdAt.getDateTimeInUtc().weekday == 6 || log.createdAt.getDateTimeInUtc().weekday == 7;
}

({int difference, double progress}) _calculateWeekendWarriorAchievement(
    {required Map<DateTimeRange, List<RoutineLog>> weekToLogs, required int target}) {
  final result = _consecutiveWeeksWithLogsWhere(
      weekToRoutineLogs: weekToLogs,
      targetWeeks: target,
      evaluation: (entry) => entry.value.where((log) => _loggedOnWeekend(log)).length == 2);
  return _achievementProgress(
      consecutiveWeeks: result.consecutiveWeeks,
      occurrences: result.occurrences,
      target: target,
      hasSufficientLogs: weekToLogs.length < target);
}

/// AchievementType.sweatEquity
({int difference, double progress}) _calculateSweatEquityAchievement({required List<RoutineLog> logs}) {
  const targetHours = Duration(hours: 90);

  final duration = logs.map((log) => log.duration()).reduce((total, duration) => total + duration);

  final progress = duration.inHours / targetHours.inHours;

  final difference = targetHours - duration;

  return (progress: progress, difference: difference < Duration.zero ? 0 : difference.inHours);
}
