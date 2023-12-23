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

({int progressRemainder, double progressValue}) calculateProgress(
    {required BuildContext context, required AchievementType type}) {
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
    _ => (progressValue: 0, progressRemainder: 0)
  };
}

/// AchievementType.days12
/// AchievementType.days30
/// AchievementType.days75
/// AchievementType.days100
({int progressRemainder, double progressValue}) _calculateDaysAchievement(
    {required List<RoutineLog> logs, required AchievementType type}) {
  final targetDays = switch (type) {
    AchievementType.days12 => 12,
    AchievementType.days30 => 30,
    AchievementType.days75 => 75,
    AchievementType.days100 => 100,
    _ => 0,
  };

  final progressRemainder = targetDays - logs.length;

  final progressValue = logs.length / targetDays;

  return (progressValue: progressValue, progressRemainder: progressRemainder < 0 ? 0 : progressRemainder);
}

/// AchievementType.supersetSpecialist
({int progressRemainder, double progressValue}) _calculateSuperSetSpecialistAchievement(
    {required List<RoutineLog> logs}) {
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

  final progressValue = count / target;
  final progressRemainder = target - count;

  return (progressValue: progressValue, progressRemainder: progressRemainder < 0 ? 0 : progressRemainder);
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

({int progressRemainder, double progressValue}) _achievementProgress(
    {required int consecutiveWeeks,
    required List<DateTimeRange> occurrences,
    required int target,
    required hasSufficientLogs}) {
  if (hasSufficientLogs) {
    return (progressValue: consecutiveWeeks / target, progressRemainder: target - consecutiveWeeks);
  }

  int progressRemainder = target - consecutiveWeeks;

  final progressValue = occurrences.isNotEmpty ? 1 : consecutiveWeeks / target;

  if (occurrences.isNotEmpty || progressRemainder <= 0) {
    progressRemainder = 0;
  }

  return (progressValue: progressValue.toDouble(), progressRemainder: progressRemainder);
}

({int progressRemainder, double progressValue}) _calculateObsessedAchievement(
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
({int progressRemainder, double progressValue}) _calculateNeverSkipALegDayAchievement(
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

({int progressRemainder, double progressValue}) _calculateNeverSkipAMondayAchievement(
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

({int progressRemainder, double progressValue}) _calculateWeekendWarriorAchievement(
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
({int progressRemainder, double progressValue}) _calculateSweatEquityAchievement({required List<RoutineLog> logs}) {
  const targetHours = Duration(hours: 100);

  final duration = logs.map((log) => log.duration()).reduce((total, duration) => total + duration);

  final progressValue = duration.inHours / targetHours.inHours;

  final progressRemainder = targetHours - duration;

  return (
    progressValue: progressValue,
    progressRemainder: progressRemainder < Duration.zero ? 0 : progressRemainder.inHours
  );
}
