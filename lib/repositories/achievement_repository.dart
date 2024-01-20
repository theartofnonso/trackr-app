import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/achievement_dto.dart';
import 'package:tracker_app/dtos/progress_dto.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/utils/routine_utils.dart';

import '../dtos/exercise_log_dto.dart';
import '../dtos/routine_log_dto.dart';
import '../enums/achievement_type_enums.dart';
import '../enums/exercise_type_enums.dart';
import '../enums/muscle_group_enums.dart';

class AchievementRepository {
  List<AchievementDto> _achievements = [];

  UnmodifiableListView<AchievementDto> get achievements => UnmodifiableListView(_achievements);

  void loadAchievements({required List<RoutineLogDto> routineLogs}) {
    final achievements = AchievementType.values.map((achievementType) {
      final progress = _calculateProgress(routineLogs: routineLogs, type: achievementType);
      return AchievementDto(type: achievementType, progress: progress);
    }).toList();

    _achievements = achievements;
  }

  void calculateAchievements({required List<RoutineLogDto> routineLogs}) {
    final achievements = AchievementType.values.map((achievementType) {
      final progress = _calculateProgress(routineLogs: routineLogs, type: achievementType);
      return AchievementDto(type: achievementType, progress: progress);
    }).toList();

    _achievements = achievements;
  }

  ProgressDto _calculateProgress({required List<RoutineLogDto> routineLogs, required AchievementType type}) {
    /// Filter logs to only include ones from the current year
    final routineLogsForCurrentYear = routineLogs.where((log) => log.createdAt.withinCurrentYear()).toList();

    /// Group ExerciseLogs by ExerciseType from the current year logs
    final exerciseLogsByType = groupRoutineLogsByExerciseType(routineLogs: routineLogsForCurrentYear);
    final exerciseLogsByTypeForCurrentYear = exerciseLogsByType.map((key, value) {
      final logs = value.where((log) => log.createdAt.withinCurrentYear());
      return MapEntry(key, logs.toList());
    });

    /// Group RoutineLogs by week from the current year logs
    final weeklyRoutineLogs = groupRoutineLogsByWeek(routineLogs: routineLogsForCurrentYear);
    final weeklyRoutineLogsForCurrentYear = weeklyRoutineLogs
        .map((key, value) => MapEntry(key, value.where((log) => log.createdAt.withinCurrentYear()).toList()));

    final progress = switch (type) {
      AchievementType.days12 => _calculateDaysAchievement(logs: routineLogsForCurrentYear, type: type),
      AchievementType.days30 => _calculateDaysAchievement(logs: routineLogsForCurrentYear, type: type),
      AchievementType.days75 => _calculateDaysAchievement(logs: routineLogsForCurrentYear, type: type),
      AchievementType.days100 => _calculateDaysAchievement(logs: routineLogsForCurrentYear, type: type),
      AchievementType.fiveMinutesToGo => _calculateTimeAchievement(logs: exerciseLogsByTypeForCurrentYear, type: type),
      AchievementType.tenMinutesToGo => _calculateTimeAchievement(logs: exerciseLogsByTypeForCurrentYear, type: type),
      AchievementType.fifteenMinutesToGo =>
        _calculateTimeAchievement(logs: exerciseLogsByTypeForCurrentYear, type: type),
      AchievementType.supersetSpecialist =>
        _calculateSuperSetSpecialistAchievement(logs: routineLogsForCurrentYear, target: type.target),
      AchievementType.obsessed =>
        _calculateObsessedAchievement(weekToLogs: weeklyRoutineLogsForCurrentYear, target: type.target),
      AchievementType.neverSkipAMonday =>
        _calculateNeverSkipAMondayAchievement(weekToLogs: weeklyRoutineLogsForCurrentYear, target: type.target),
      AchievementType.neverSkipALegDay =>
        _calculateNeverSkipALegDayAchievement(weekToLogs: weeklyRoutineLogsForCurrentYear, target: type.target),
      AchievementType.weekendWarrior =>
        _calculateWeekendWarriorAchievement(weekToLogs: weeklyRoutineLogsForCurrentYear, target: type.target),
      AchievementType.sweatMarathon =>
        _calculateSweatEquityAchievement(logs: routineLogsForCurrentYear, target: type.target),
      AchievementType.bodyweightChampion =>
        _calculateBodyWeightChampionAchievement(logs: exerciseLogsByTypeForCurrentYear, type: type),
      AchievementType.strongerThanEver =>
        _calculateStrongerThanEverAchievement(logs: exerciseLogsByTypeForCurrentYear, target: type.target),
      AchievementType.timeUnderTension =>
        _calculateTimeUnderTensionAchievement(logs: exerciseLogsByTypeForCurrentYear, target: type.target),
      AchievementType.oneMoreRep =>
        _calculateOneMoreRepAchievement(logs: exerciseLogsByTypeForCurrentYear, target: type.target)
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
  DateTime dateExtractorForExerciseLog(ExerciseLogDto log) => log.createdAt.localDate();

  DateTime dateExtractorForRoutineLog(RoutineLogDto log) => log.createdAt.localDate();

  /// [AchievementType.days12]
  /// [AchievementType.days30]
  /// [AchievementType.days75]
  /// [AchievementType.days100]
  ProgressDto _calculateDaysAchievement({required List<RoutineLogDto> logs, required AchievementType type}) {
    final achievedLogs = logs.take(type.target);

    final progress = achievedLogs.length / type.target;
    final remainder = type.target - achievedLogs.length;

    return generateProgress(
        achievedLogs: achievedLogs, progress: progress, remainder: remainder, dateSelector: dateExtractorForRoutineLog);
  }

  /// [AchievementType.supersetSpecialist]
  ProgressDto _calculateSuperSetSpecialistAchievement({required List<RoutineLogDto> logs, required int target}) {
    // Count RoutineLogs with at least two exercises that have a non-null superSetId
    final achievedLogs = logs.where((log) {
      var exercisesWithSuperSetId = log.exerciseLogs.where((exerciseLog) => exerciseLog.superSetId.isNotEmpty).length;

      return exercisesWithSuperSetId >= 2;
    }).toList();

    final progress = achievedLogs.length / target;
    final remainder = target - achievedLogs.length;

    return generateProgress(
        achievedLogs: achievedLogs, progress: progress, remainder: remainder, dateSelector: dateExtractorForRoutineLog);
  }

  /// [AchievementType.obsessed]
  List<DateTimeRange> _consecutiveDatesWhere(
      {required Map<DateTimeRange, List<RoutineLogDto>> weekToRoutineLogs,
      required bool Function(MapEntry<DateTimeRange, List<RoutineLogDto>> week) evaluation}) {
    List<DateTimeRange> dateRanges = [];

    for (var entry in weekToRoutineLogs.entries) {
      final evaluated = evaluation(entry);
      if (evaluated) {
        dateRanges.add(entry.key);
      } else {
        /// Only restart when we are at the end of the week
        /// This means that if we are at the end of the week
        /// and there has been no logs then this week is not consecutive
        if (DateTime.now().weekday == 7) {
          dateRanges = [];
        }
      }
    }

    return dateRanges;
  }

  ProgressDto _consecutiveAchievementProgress(
      {required List<DateTimeRange> dateTimeRanges,
      required int target,
      required Map<DateTimeRange, List<RoutineLogDto>> weekToLogs}) {
    final achievedLogs = dateTimeRanges
        .map((DateTimeRange range) => weekToLogs[range] ?? <RoutineLogDto>[])
        .expand((List<RoutineLogDto> logs) => logs);

    int remainder = target - dateTimeRanges.length;

    final progress = dateTimeRanges.length / target;

    return generateProgress(
        achievedLogs: achievedLogs, progress: progress, remainder: remainder, dateSelector: dateExtractorForRoutineLog);
  }

  ProgressDto _calculateObsessedAchievement(
      {required Map<DateTimeRange, List<RoutineLogDto>> weekToLogs, required int target}) {
    final dateTimeRanges =
        _consecutiveDatesWhere(weekToRoutineLogs: weekToLogs, evaluation: (entry) => entry.value.isNotEmpty);
    return _consecutiveAchievementProgress(dateTimeRanges: dateTimeRanges, target: target, weekToLogs: weekToLogs);
  }

  bool _hasLegExercise(RoutineLogDto log) {
    return log.exerciseLogs.any((exerciseLog) {
      final exercise = exerciseLog.exercise;
      final muscleGroup = exercise.primaryMuscleGroup;
      return muscleGroup.family == MuscleGroupFamily.legs;
    });
  }

  /// [AchievementType.neverSkipAMonday]
  ProgressDto _calculateNeverSkipALegDayAchievement(
      {required Map<DateTimeRange, List<RoutineLogDto>> weekToLogs, required int target}) {
    final dateTimeRanges = _consecutiveDatesWhere(
        weekToRoutineLogs: weekToLogs, evaluation: (entry) => entry.value.any((log) => _hasLegExercise(log)));
    return _consecutiveAchievementProgress(dateTimeRanges: dateTimeRanges, target: target, weekToLogs: weekToLogs);
  }

  /// [AchievementType.neverSkipAMonday]
  bool _loggedOnMonday(RoutineLogDto log) {
    return log.createdAt.weekday == 1;
  }

  ProgressDto _calculateNeverSkipAMondayAchievement(
      {required Map<DateTimeRange, List<RoutineLogDto>> weekToLogs, required int target}) {
    final dateTimeRanges = _consecutiveDatesWhere(
        weekToRoutineLogs: weekToLogs, evaluation: (entry) => entry.value.any((log) => _loggedOnMonday(log)));
    return _consecutiveAchievementProgress(dateTimeRanges: dateTimeRanges, target: target, weekToLogs: weekToLogs);
  }

  /// [AchievementType.weekendWarrior]
  bool _loggedOnWeekend(RoutineLogDto log) {
    return log.createdAt.weekday == 6 || log.createdAt.weekday == 7;
  }

  ProgressDto _calculateWeekendWarriorAchievement(
      {required Map<DateTimeRange, List<RoutineLogDto>> weekToLogs, required int target}) {
    final dateTimeRanges = _consecutiveDatesWhere(
        weekToRoutineLogs: weekToLogs,
        evaluation: (entry) => entry.value.where((log) => _loggedOnWeekend(log)).length == 2);
    return _consecutiveAchievementProgress(dateTimeRanges: dateTimeRanges, target: target, weekToLogs: weekToLogs);
  }

  /// [AchievementType.sweatMarathon]
  ProgressDto _calculateSweatEquityAchievement({required List<RoutineLogDto> logs, required int target}) {
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
    final achievedLogs = logs[ExerciseType.duration] ?? [];
    List<ExerciseLogDto> durations = achievedLogs.where((log) {
      return log.sets.any((set) => Duration(milliseconds: set.value1.toInt()) == Duration(minutes: type.target));
    }).toList();

    final progress = durations.length / type.target;
    final remainder = type.target - durations.length;

    return generateProgress(
        achievedLogs: achievedLogs,
        progress: progress,
        remainder: remainder,
        dateSelector: dateExtractorForExerciseLog);
  }

  /// [AchievementType.bodyweightChampion]
  ProgressDto _calculateBodyWeightChampionAchievement(
      {required Map<ExerciseType, List<ExerciseLogDto>> logs, required AchievementType type}) {
    final achievedLogs = logs[ExerciseType.bodyWeight] ?? [];

    final progress = achievedLogs.length / type.target;
    final remainder = type.target - achievedLogs.length;

    return generateProgress(
        achievedLogs: achievedLogs,
        progress: progress,
        remainder: remainder,
        dateSelector: dateExtractorForExerciseLog);
  }

  /// [AchievementType.strongerThanEver]
  ProgressDto _calculateStrongerThanEverAchievement(
      {required Map<ExerciseType, List<ExerciseLogDto>> logs, required int target}) {
    final achievedLogs = logs[ExerciseType.weights] ?? [];

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

    final totalDuration =
        durations.isNotEmpty ? durations.reduce((total, duration) => total + duration) : Duration.zero;

    final progress = totalDuration.inMilliseconds / targetHours.inMilliseconds;

    final remainder = targetHours - totalDuration;

    return generateProgress(
        achievedLogs: achievedLogs,
        progress: progress,
        remainder: remainder.inHours,
        dateSelector: dateExtractorForExerciseLog);
  }

  /// [AchievementType.oneMoreRep]
  ProgressDto _calculateOneMoreRepAchievement(
      {required Map<ExerciseType, List<ExerciseLogDto>> logs, required int target}) {
    final achievedLogs = logs[ExerciseType.weights] ?? [];

    final reps = achievedLogs.map((log) {
      final reps = log.sets.map((set) => set.value2).reduce((total, reps) => total + reps);
      return reps;
    });

    final totalReps = reps.isNotEmpty ? reps.reduce((total, rep) => total + rep) : 0;

    final progress = totalReps / target;

    final remainder = target - totalReps;

    return generateProgress(
        achievedLogs: achievedLogs,
        progress: progress,
        remainder: remainder.toInt(),
        dateSelector: dateExtractorForExerciseLog);
  }
}
