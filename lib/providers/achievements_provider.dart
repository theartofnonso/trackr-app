import 'dart:convert';

import 'package:flutter/material.dart';

import '../dtos/exercise_log_dto.dart';
import '../enums/achievement_type_enums.dart';
import '../models/RoutineLog.dart';
import '../utils/general_utils.dart';

({int difference, double progress}) calculateProgress({required List<RoutineLog> logs, required AchievementType type}) {
  return switch (type) {
    AchievementType.days12 => _calculateDaysAchievement(logs: logs, type: type),
    AchievementType.days30 => _calculateDaysAchievement(logs: logs, type: type),
    AchievementType.days75 => _calculateDaysAchievement(logs: logs, type: type),
    AchievementType.days100 => _calculateDaysAchievement(logs: logs, type: type),
    AchievementType.supersetSpecialist => _calculateSuperSetSpecialistAchievement(logs: logs),
    AchievementType.obsessed => _calculateObsessedAchievement(logs: logs),
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
Map<DateTimeRange, List<RoutineLog>> _mapWeeksToRoutineLogs(
    List<RoutineLog> routineLogs, List<DateTimeRange> weekRanges) {
  Map<DateTimeRange, List<RoutineLog>> result = {};

  for (var weekRange in weekRanges) {
    List<RoutineLog> routinesInWeek = routineLogs
        .where((log) =>
            log.createdAt.getDateTimeInUtc().isAfter(weekRange.start) &&
            log.createdAt.getDateTimeInUtc().isBefore(weekRange.end.add(const Duration(days: 1))))
        .toList();

    result[weekRange] = routinesInWeek;
  }

  return result;
}

({List<DateTimeRange> occurrences, int consecutiveWeeks}) _findConsecutiveWeeksWithRoutineLogs(
    Map<DateTimeRange, List<RoutineLog>> weekToRoutineLogs, int n) {
  List<DateTimeRange> occurrences = [];
  int consecutiveWeeks = 0;
  int index = 0;

  for (var entry in weekToRoutineLogs.entries) {
    if (entry.value.isNotEmpty) {
      consecutiveWeeks++;

      if (consecutiveWeeks % n == 0) {
        final previousWeek = weekToRoutineLogs.entries.elementAt(index - 1);
        final DateTimeRange range = DateTimeRange(start: previousWeek.key.start, end: entry.key.end);
        occurrences.add(range);
      }
    } else {
      consecutiveWeeks = 0;
      occurrences = [];
    }
    index++;
  }

  return (occurrences: occurrences, consecutiveWeeks: consecutiveWeeks);
}

({int difference, double progress}) _calculateObsessedAchievement({required List<RoutineLog> logs}) {
  int target = 12;

  DateTime startDate = logs.first.createdAt.getDateTimeInUtc(); // Replace with your desired start date
  List<DateTimeRange> weekRanges = generateWeekRangesFrom(startDate);

  // Map each DateTimeRange to RoutineLogs falling within it
  Map<DateTimeRange, List<RoutineLog>> weekToRoutineLogs = _mapWeeksToRoutineLogs(logs, weekRanges);

  final result = _findConsecutiveWeeksWithRoutineLogs(weekToRoutineLogs, target);

  if (weekToRoutineLogs.length < target) {
    return (progress: result.consecutiveWeeks / target, difference: target - result.consecutiveWeeks);
  }

  final difference = target - result.consecutiveWeeks;

  final progress = result.occurrences.isNotEmpty ? 1 : result.consecutiveWeeks / target;

  return (progress: progress.toDouble(), difference: difference <= 0 ? 0 : difference);
}
