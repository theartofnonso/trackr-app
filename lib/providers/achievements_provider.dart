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
import '../enums/exercise_type_enums.dart';
import '../enums/muscle_group_enums.dart';

ProgressDto calculateProgress({required BuildContext context, required AchievementType type}) {
  final routineLogsProvider = Provider.of<RoutineLogProvider>(context, listen: false);
  final routineLogs = routineLogsProvider.logs;
  final exerciseLogs = routineLogsProvider.exerciseLogsByType;
  final weekToLogs = routineLogsProvider.weekToLogs;
  final progress = switch (type) {
    AchievementType.days12 => _calculateDaysAchievement(logs: routineLogs, type: type),
    AchievementType.days30 => _calculateDaysAchievement(logs: routineLogs, type: type),
    AchievementType.days75 => _calculateDaysAchievement(logs: routineLogs, type: type),
    AchievementType.days100 => _calculateDaysAchievement(logs: routineLogs, type: type),
    AchievementType.fiveMinutesToGo => _calculateTimeAchievement(logs: exerciseLogs, type: type),
    AchievementType.tenMinutesToGo => _calculateTimeAchievement(logs: exerciseLogs, type: type),
    AchievementType.fifteenMinutesToGo => _calculateTimeAchievement(logs: exerciseLogs, type: type),
    AchievementType.templeRun => _calculateRunningTimeAchievement(logs: exerciseLogs, type: type),
    AchievementType.supersetSpecialist => _calculateSuperSetSpecialistAchievement(logs: routineLogs),
    AchievementType.obsessed => _calculateObsessedAchievement(weekToLogs: weekToLogs, target: type.target),
    AchievementType.neverSkipAMonday =>
      _calculateNeverSkipAMondayAchievement(weekToLogs: weekToLogs, target: type.target),
    AchievementType.neverSkipALegDay =>
      _calculateNeverSkipALegDayAchievement(weekToLogs: weekToLogs, target: type.target),
    AchievementType.weekendWarrior => _calculateWeekendWarriorAchievement(weekToLogs: weekToLogs, target: type.target),
    AchievementType.sweatEquity => _calculateSweatEquityAchievement(logs: routineLogs, target: type.target),
    AchievementType.bodyweightChampion => _calculateBodyWeightAchievement(logs: exerciseLogs, type: type),
    AchievementType.strongerThanEver => _calculateStrongerThanEverAchievement(logs: exerciseLogs, target: type.target),
    AchievementType.timeUnderTension => _calculateTimeUnderTensionAchievement(logs: exerciseLogs, target: type.target),
    AchievementType.assistedToUnAssisted =>
      _calculateAssistedToUnAssistedAchievement(logs: exerciseLogs, target: type.target),
    _ => ProgressDto(value: 0.0, remainder: 0, dates: {}),
  };

  return progress;
}

int _adjustRemainder({required int remainder}) {
  if (remainder < 0) {
    return 0;
  }

  return remainder;
}

ProgressDto generateProgress<T>(
    {required Iterable<T> achievedLogs,
    required double progress,
    required int remainder,
    required DateTime Function(T) dateSelector}) {
  final dates = achievedLogs.map(dateSelector).toList();
  final datesByMonth = groupBy(dates, (date) => date.month);

  return ProgressDto(value: progress, remainder: _adjustRemainder(remainder: remainder), dates: datesByMonth);
}

/// Date Extractors
DateTime dateExtractorForExerciseLog(ExerciseLogDto log) => log.createdAt.getDateTimeInUtc().localDate();

DateTime dateExtractorForRoutineLog(RoutineLog log) => log.createdAt.getDateTimeInUtc().localDate();

/// [AchievementType.days12]
/// [AchievementType.days30]
/// [AchievementType.days75]
/// [AchievementType.days100]
ProgressDto _calculateDaysAchievement({required List<RoutineLog> logs, required AchievementType type}) {
  final achievedLogs = logs.take(type.target);

  final progress = achievedLogs.length / type.target;
  final remainder = type.target - achievedLogs.length;

  return generateProgress(
      achievedLogs: achievedLogs, progress: progress, remainder: remainder, dateSelector: dateExtractorForRoutineLog);
}

/// [AchievementType.supersetSpecialist]
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

  final progress = achievedLogs.length / target;
  final remainder = target - achievedLogs.length;

  return generateProgress(
      achievedLogs: achievedLogs, progress: progress, remainder: remainder, dateSelector: dateExtractorForRoutineLog);
}

/// [AchievementType.obsessed]
List<DateTimeRange> _consecutiveDatesWhere(
    {required Map<DateTimeRange, List<RoutineLog>> weekToRoutineLogs,
    required bool Function(MapEntry<DateTimeRange, List<RoutineLog>> week) evaluation}) {
  List<DateTimeRange> dateRanges = [];

  for (var entry in weekToRoutineLogs.entries) {
    final evaluated = evaluation(entry);
    if (evaluated) {
      dateRanges.add(entry.key);
    } else {
      /// Only restart when we are at the end of the week
      /// This means that if we are at the end of the week
      /// and there has been no logs then this week is not consecutive
      if(DateTime.now().weekday == 7) {
        dateRanges = [];
      }
    }
  }

  return dateRanges;
}

ProgressDto _consecutiveAchievementProgress(
    {required List<DateTimeRange> dateTimeRanges,
    required int target,
    required Map<DateTimeRange, List<RoutineLog>> weekToLogs}) {
  final achievedLogs = dateTimeRanges
      .map((DateTimeRange range) => weekToLogs[range] ?? <RoutineLog>[])
      .expand((List<RoutineLog> logs) => logs);

  int remainder = target - dateTimeRanges.length;

  final progress = dateTimeRanges.length / target;

  return generateProgress(
      achievedLogs: achievedLogs, progress: progress, remainder: remainder, dateSelector: dateExtractorForRoutineLog);
}

ProgressDto _calculateObsessedAchievement(
    {required Map<DateTimeRange, List<RoutineLog>> weekToLogs, required int target}) {
  final dateTimeRanges =
      _consecutiveDatesWhere(weekToRoutineLogs: weekToLogs, evaluation: (entry) => entry.value.isNotEmpty);
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

/// [AchievementType.neverSkipAMonday]
ProgressDto _calculateNeverSkipALegDayAchievement(
    {required Map<DateTimeRange, List<RoutineLog>> weekToLogs, required int target}) {
  final dateTimeRanges = _consecutiveDatesWhere(
      weekToRoutineLogs: weekToLogs, evaluation: (entry) => entry.value.any((log) => _hasLegExercise(log)));
  return _consecutiveAchievementProgress(dateTimeRanges: dateTimeRanges, target: target, weekToLogs: weekToLogs);
}

/// [AchievementType.neverSkipAMonday]
bool _loggedOnMonday(RoutineLog log) {
  return log.createdAt.getDateTimeInUtc().weekday == 1;
}

ProgressDto _calculateNeverSkipAMondayAchievement(
    {required Map<DateTimeRange, List<RoutineLog>> weekToLogs, required int target}) {
  final dateTimeRanges = _consecutiveDatesWhere(
      weekToRoutineLogs: weekToLogs, evaluation: (entry) => entry.value.any((log) => _loggedOnMonday(log)));
  return _consecutiveAchievementProgress(dateTimeRanges: dateTimeRanges, target: target, weekToLogs: weekToLogs);
}

/// [AchievementType.weekendWarrior]
bool _loggedOnWeekend(RoutineLog log) {
  return log.createdAt.getDateTimeInUtc().weekday == 6 || log.createdAt.getDateTimeInUtc().weekday == 7;
}

ProgressDto _calculateWeekendWarriorAchievement(
    {required Map<DateTimeRange, List<RoutineLog>> weekToLogs, required int target}) {
  final dateTimeRanges = _consecutiveDatesWhere(
      weekToRoutineLogs: weekToLogs,
      evaluation: (entry) => entry.value.where((log) => _loggedOnWeekend(log)).length == 2);
  return _consecutiveAchievementProgress(dateTimeRanges: dateTimeRanges, target: target, weekToLogs: weekToLogs);
}

/// [AchievementType.sweatEquity]
ProgressDto _calculateSweatEquityAchievement({required List<RoutineLog> logs, required int target}) {
  final targetHours = Duration(hours: target);

  final durations = logs.map((log) => log.duration());

  final duration = durations.isNotEmpty ? durations.reduce((total, duration) => total + duration) : Duration.zero;

  final progress = duration.inHours / targetHours.inHours;

  final remainder = targetHours - duration;

  return generateProgress(
      achievedLogs: logs, progress: progress, remainder: remainder.inHours, dateSelector: dateExtractorForRoutineLog);
}

/// [AchievementType.fiveMinutesToGo]
/// [AchievementType.tenMinutesToGo]
/// [AchievementType.fifteenMinutesToGo]
ProgressDto _calculateTimeAchievement(
    {required Map<ExerciseType, List<ExerciseLogDto>> logs, required AchievementType type}) {
  final exerciseLogsWithDurationOnly = logs[ExerciseType.duration] ?? [];
  final exerciseLogsWithDurationAndDistanceOnly = logs[ExerciseType.durationAndDistance] ?? [];
  final exerciseLogsWithDuration = [...exerciseLogsWithDurationOnly, ...exerciseLogsWithDurationAndDistanceOnly];
  List<ExerciseLogDto> achievedLogs = exerciseLogsWithDuration.where((log) {
    return log.sets.any((set) => Duration(milliseconds: set.value1.toInt()) == Duration(minutes: type.target));
  }).toList();

  final progress = achievedLogs.length / 50;
  final remainder = 50 - achievedLogs.length;

  return generateProgress(
      achievedLogs: achievedLogs, progress: progress, remainder: remainder, dateSelector: dateExtractorForExerciseLog);
}

/// [AchievementType.templeRun]
ProgressDto _calculateRunningTimeAchievement(
    {required Map<ExerciseType, List<ExerciseLogDto>> logs, required AchievementType type}) {
  final exerciseLogsWithDistanceAndDuration = logs[ExerciseType.durationAndDistance] ?? [];
  List<ExerciseLogDto> achievedLogs = exerciseLogsWithDistanceAndDuration.where((log) {
    return log.sets.any((set) => Duration(milliseconds: set.value1.toInt()) == Duration(minutes: type.target));
  }).toList();

  final progress = achievedLogs.length / 50;
  final remainder = 50 - achievedLogs.length;

  return generateProgress(
      achievedLogs: achievedLogs, progress: progress, remainder: remainder, dateSelector: dateExtractorForExerciseLog);
}

/// [AchievementType.bodyweightChampion]
ProgressDto _calculateBodyWeightAchievement(
    {required Map<ExerciseType, List<ExerciseLogDto>> logs, required AchievementType type}) {
  final achievedLogs = logs[ExerciseType.bodyWeightAndReps] ?? [];

  final progress = achievedLogs.length / type.target;
  final remainder = type.target - achievedLogs.length;

  return generateProgress(
      achievedLogs: achievedLogs, progress: progress, remainder: remainder, dateSelector: dateExtractorForExerciseLog);
}

/// [AchievementType.strongerThanEver]
ProgressDto _calculateStrongerThanEverAchievement(
    {required Map<ExerciseType, List<ExerciseLogDto>> logs, required int target}) {
  final weightAndReps = logs[ExerciseType.weightAndReps] ?? [];
  final weightedBodyWeight = logs[ExerciseType.weightedBodyWeight] ?? [];
  final weightAndDistance = logs[ExerciseType.weightAndDistance] ?? [];

  final achievedLogs = [...weightAndReps, ...weightedBodyWeight, ...weightAndDistance];

  final tonnages = achievedLogs.map((log) {
    final volume = log.sets.map((set) => set.value1 * set.value2).reduce((total, tonnage) => total + tonnage);
    return volume;
  });

  final tonnage = tonnages.isNotEmpty ? tonnages.reduce((total, tonnage) => total + tonnage) : 0;

  final progress = tonnage / target;

  final remainder = target - tonnage;

  return generateProgress(
      achievedLogs: achievedLogs,
      progress: progress,
      remainder: remainder.toInt(),
      dateSelector: dateExtractorForExerciseLog);
}

/// [AchievementType.timeUnderTension]
ProgressDto _calculateTimeUnderTensionAchievement(
    {required Map<ExerciseType, List<ExerciseLogDto>> logs, required int target}) {
  final targetHours = Duration(hours: target);

  final achievedLogs = logs[ExerciseType.duration] ?? [];

  final durations = achievedLogs.map((log) {
    final duration = log.sets.map((set) => set.value1).reduce((total, tonnage) => total + tonnage);
    return Duration(milliseconds: duration.toInt());
  });

  final duration = durations.isNotEmpty ? durations.reduce((total, duration) => total + duration) : Duration.zero;

  final progress = duration.inHours / targetHours.inHours;

  final remainder = targetHours - duration;

  return generateProgress(
      achievedLogs: achievedLogs,
      progress: progress,
      remainder: remainder.inHours,
      dateSelector: dateExtractorForExerciseLog);
}

/// [AchievementType.assistedToUnAssisted]
ProgressDto _calculateAssistedToUnAssistedAchievement(
    {required Map<ExerciseType, List<ExerciseLogDto>> logs, required int target}) {
  final assistedBodyWeight = logs[ExerciseType.assistedBodyWeight] ?? [];

  final achievedLogs = assistedBodyWeight.where((log) => log.sets.any((set) => set.value1 == target));

  final progress = achievedLogs.length / assistedBodyWeight.length;
  final remainder = assistedBodyWeight.length - achievedLogs.length;

  return generateProgress(
      achievedLogs: achievedLogs,
      progress: progress.isNaN ? 0 : progress,
      remainder: remainder,
      dateSelector: dateExtractorForExerciseLog);
}
