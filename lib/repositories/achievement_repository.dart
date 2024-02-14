import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/achievement_dto.dart';
import 'package:tracker_app/dtos/progress_dto.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/datetime_range_extension.dart';
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
    _achievements = fetchAchievements(routineLogs: routineLogs);
  }

  List<AchievementDto> fetchAchievements({required List<RoutineLogDto> routineLogs}) {
    return AchievementType.values.map((achievementType) {
      final progress = _calculateProgress(routineLogs: routineLogs, type: achievementType);
      return AchievementDto(type: achievementType, progress: progress);
    }).toList();
  }

  List<AchievementDto> calculateNewLogAchievements({required List<RoutineLogDto> routineLogs}) {
    final newAchievements = AchievementType.values.map((achievementType) {
      final progress = _calculateProgress(routineLogs: routineLogs, type: achievementType);
      return AchievementDto(type: achievementType, progress: progress);
    });

    List<AchievementDto> updatedAchievements = [];

    for (var newAchievement in newAchievements) {
      // Try to find the same achievement in the old list
      var oldAchievement = _achievements.firstWhereOrNull((old) => old.type == newAchievement.type);

      if (oldAchievement == null) {
        continue;
      }

      /// New achievement has a lower remainder value
      if (newAchievement.progress.remainder < oldAchievement.progress.remainder) {
        /// New achievement has reached 0 and is now complete
        if (newAchievement.progress.remainder == 0) {
          updatedAchievements.add(newAchievement);
        }
      }
    }

    /// Update achievements
    /// Achievements are only loaded when the app starts, this is to ensure that we can calculate new achievements by comparing the old and new list
    /// Once we have calculated the new achievements, we can update the list
    loadAchievements(routineLogs: routineLogs);

    return updatedAchievements;
  }

  ProgressDto _calculateProgress({required List<RoutineLogDto> routineLogs, required AchievementType type}) {
    /// Filter logs to only include ones from the current year
    final routineLogsForCurrentYear = routineLogs.where((log) => log.createdAt.withinCurrentYear()).toList();

    /// Group ExerciseLogs by ExerciseType from the current year logs
    final exerciseLogsByType = groupExerciseLogsByExerciseType(routineLogs: routineLogsForCurrentYear);

    /// Group RoutineLogs by week from the current year logs
    final weeklyRoutineLogs = groupRoutineLogsByWeek(routineLogs: routineLogsForCurrentYear);

    final progress = switch (type) {
      AchievementType.days12 => _calculateDaysAchievement(logs: routineLogsForCurrentYear, type: type),
      AchievementType.days30 => _calculateDaysAchievement(logs: routineLogsForCurrentYear, type: type),
      AchievementType.days75 => _calculateDaysAchievement(logs: routineLogsForCurrentYear, type: type),
      AchievementType.days100 => _calculateDaysAchievement(logs: routineLogsForCurrentYear, type: type),
      AchievementType.fiveMinutesToGo => _calculateTimeAchievement(logs: exerciseLogsByType, type: type),
      AchievementType.tenMinutesToGo => _calculateTimeAchievement(logs: exerciseLogsByType, type: type),
      AchievementType.fifteenMinutesToGo => _calculateTimeAchievement(logs: exerciseLogsByType, type: type),
      AchievementType.supersetSpecialist =>
        _calculateSuperSetSpecialistAchievement(logs: routineLogsForCurrentYear, target: type.target),
      AchievementType.obsessed => _calculateObsessedAchievement(weekToLogs: weeklyRoutineLogs, target: type.target),
      AchievementType.neverSkipAMonday =>
        _calculateNeverSkipAMondayAchievement(weekToLogs: weeklyRoutineLogs, target: type.target),
      AchievementType.neverSkipALegDay =>
        _calculateNeverSkipALegDayAchievement(weekToLogs: weeklyRoutineLogs, target: type.target),
      AchievementType.weekendWarrior =>
        _calculateWeekendWarriorAchievement(weekToLogs: weeklyRoutineLogs, target: type.target),
      AchievementType.sweatMarathon =>
        _calculateSweatMarathonAchievement(logs: routineLogsForCurrentYear, target: type.target),
      AchievementType.bodyweightChampion =>
        _calculateBodyWeightChampionAchievement(logs: exerciseLogsByType, type: type),
      AchievementType.strongerThanEver =>
        _calculateStrongerThanEverAchievement(logs: exerciseLogsByType, target: type.target),
      AchievementType.timeUnderTension =>
        _calculateTimeUnderTensionAchievement(logs: exerciseLogsByType, target: type.target),
      AchievementType.oneMoreRep => _calculateOneMoreRepAchievement(logs: exerciseLogsByType, target: type.target)
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

  List<DateTimeRange> _consecutiveDatesWhere(
      {required Map<DateTimeRange, List<RoutineLogDto>> weekToRoutineLogs,
      required bool Function(MapEntry<DateTimeRange, List<RoutineLogDto>> week) evaluation, required AchievementType type}) {
    List<DateTimeRange> dateRanges = [];

    for (var entry in weekToRoutineLogs.entries) {

      final evaluated = evaluation(entry);
      if (evaluated) {
        dateRanges.add(entry.key);
      } else {
        if(type == AchievementType.obsessed || type == AchievementType.neverSkipALegDay || type == AchievementType.weekendWarrior) {
          final now = DateTime.now();
          final lastDayOfWeek = entry.key.dates.where((date) => date.isBeforeOrEqual(DateTime(now.year, now.month, now.day))).lastOrNull;
          if(lastDayOfWeek == null) {
            continue;
          }
          if (lastDayOfWeek.weekday == 7) {
            dateRanges = [];
          }
        } else {
          if(type == AchievementType.neverSkipAMonday) {
            final secondDayOfWeek = entry.key.dates[1];
            if (secondDayOfWeek.weekday == 2) {
              dateRanges = [];
            }
          }
        }
      }
    }
    return dateRanges;
  }

  ProgressDto _consecutiveAchievementProgress(
      {required List<DateTimeRange> dateTimeRanges,
      required int target,
      required Map<DateTimeRange, List<RoutineLogDto>> weekToLogs,
      required bool Function(RoutineLogDto log) evaluation}) {
    final achievedLogs = dateTimeRanges
        .map((DateTimeRange range) => weekToLogs[range] ?? <RoutineLogDto>[])
        .expand((List<RoutineLogDto> logs) => logs)
        .where((log) => evaluation(log));

    int remainder = target - dateTimeRanges.length;

    final progress = dateTimeRanges.length / target;

    return generateProgress(
        achievedLogs: achievedLogs, progress: progress, remainder: remainder, dateSelector: dateExtractorForRoutineLog);
  }

  /// [AchievementType.obsessed]
  ProgressDto _calculateObsessedAchievement(
      {required Map<DateTimeRange, List<RoutineLogDto>> weekToLogs, required int target}) {
    final dateTimeRanges =
        _consecutiveDatesWhere(weekToRoutineLogs: weekToLogs, evaluation: (entry) => entry.value.isNotEmpty, type: AchievementType.obsessed)
            .take(target)
            .toList();
    return _consecutiveAchievementProgress(
        dateTimeRanges: dateTimeRanges,
        target: target,
        weekToLogs: weekToLogs,
        evaluation: (log) {
          return log.exerciseLogs.isNotEmpty;
        });
  }

  bool _hasLegExercise(RoutineLogDto log) {
    return log.exerciseLogs.any((exerciseLog) {
      final exercise = exerciseLog.exercise;
      final muscleGroup = exercise.primaryMuscleGroup;
      return muscleGroup.family == MuscleGroupFamily.legs;
    });
  }

  /// [AchievementType.neverSkipALegDay]
  ProgressDto _calculateNeverSkipALegDayAchievement(
      {required Map<DateTimeRange, List<RoutineLogDto>> weekToLogs, required int target}) {
    final dateTimeRanges = _consecutiveDatesWhere(
        weekToRoutineLogs: weekToLogs,
        evaluation: (entry) => entry.value.any((log) => _hasLegExercise(log)), type: AchievementType.neverSkipALegDay).take(target).toList();
    return _consecutiveAchievementProgress(
        dateTimeRanges: dateTimeRanges, target: target, weekToLogs: weekToLogs, evaluation: _hasLegExercise);
  }

  /// [AchievementType.neverSkipAMonday]
  bool _loggedOnMonday(RoutineLogDto log) {
    return log.createdAt.weekday == 1;
  }

  ProgressDto _calculateNeverSkipAMondayAchievement(
      {required Map<DateTimeRange, List<RoutineLogDto>> weekToLogs, required int target}) {
    final dateTimeRanges = _consecutiveDatesWhere(
        weekToRoutineLogs: weekToLogs,
        evaluation: (entry) => entry.value.any((log) => _loggedOnMonday(log)), type: AchievementType.neverSkipAMonday).take(target).toList();
    return _consecutiveAchievementProgress(
        dateTimeRanges: dateTimeRanges, target: target, weekToLogs: weekToLogs, evaluation: _loggedOnMonday);
  }

  /// [AchievementType.weekendWarrior]
  bool _loggedOnWeekend(RoutineLogDto log) {
    return log.createdAt.weekday == 6 || log.createdAt.weekday == 7;
  }

  ProgressDto _calculateWeekendWarriorAchievement(
      {required Map<DateTimeRange, List<RoutineLogDto>> weekToLogs, required int target}) {
    final dateTimeRanges = _consecutiveDatesWhere(
        weekToRoutineLogs: weekToLogs,
        evaluation: (entry) => entry.value.any((log) => _loggedOnWeekend(log)), type: AchievementType.weekendWarrior).take(target).toList();
    return _consecutiveAchievementProgress(
        dateTimeRanges: dateTimeRanges, target: target, weekToLogs: weekToLogs, evaluation: _loggedOnWeekend);
  }

  /// [AchievementType.sweatMarathon]
  ProgressDto _calculateSweatMarathonAchievement({required List<RoutineLogDto> logs, required int target}) {
    final targetDuration = Duration(hours: target);

    final totalHours = logs.map((log) => log.duration().inHours).sum;

    final progress = totalHours / targetDuration.inHours;

    final remainder = targetDuration.inHours - totalHours;

    return generateProgress(
        achievedLogs: logs, progress: progress, remainder: remainder, dateSelector: dateExtractorForRoutineLog);
  }

  /// [AchievementType.fiveMinutesToGo]
  /// [AchievementType.tenMinutesToGo]
  /// [AchievementType.fifteenMinutesToGo]
  ProgressDto _calculateTimeAchievement(
      {required Map<ExerciseType, List<ExerciseLogDto>> logs, required AchievementType type}) {
    final durationLogs = logs[ExerciseType.duration] ?? [];
    List<ExerciseLogDto> achievedLogs = durationLogs.where((log) {
      return log.sets.any((set) => Duration(milliseconds: set.durationValue()) == Duration(minutes: type.target));
    }).toList();

    final progress = achievedLogs.length / type.target;
    final remainder = type.target - achievedLogs.length;

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
    final tonnage = achievedLogs.map((log) {
      final volume = log.sets.map((set) => set.volume()).sum;
      return volume;
    }).sum;

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

    final milliSeconds = achievedLogs.map((log) => log.sets.map((set) => set.durationValue()).sum).sum;

    final totalDuration = Duration(milliseconds: milliSeconds.toInt());

    final progress = totalDuration.inHours / targetHours.inHours;

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
    final weightsLogs = logs[ExerciseType.weights] ?? [];
    final bodyWeightLogs = logs[ExerciseType.bodyWeight] ?? [];
    final achievedLogs = [...weightsLogs, ...bodyWeightLogs];

    final totalReps = achievedLogs.map((log) => log.sets.map((set) => set.repsValue()).sum).sum;

    final progress = totalReps / target;

    final remainder = target - totalReps;

    return generateProgress(
        achievedLogs: achievedLogs,
        progress: progress,
        remainder: remainder.toInt(),
        dateSelector: dateExtractorForExerciseLog);
  }
}
