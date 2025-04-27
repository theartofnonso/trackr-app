import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/enums/training_archetype.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';

import 'date_utils.dart';

TrainingFrequencyArchetype trainingFrequencyArchetype({required int avgSessions}) {
  if (avgSessions <= 2) return TrainingFrequencyArchetype.rarelyTrains;
  if (avgSessions <= 4) return TrainingFrequencyArchetype.oftenTrains;
  return TrainingFrequencyArchetype.alwaysTrains;
}

TrainingDurationArchetype trainingDurationArchetype({required Duration avgDuration}) {
  final minutes = avgDuration.inMinutes;
  if (minutes < 30) return TrainingDurationArchetype.shortSession;
  if (minutes < 60) return TrainingDurationArchetype.standardSession;
  return TrainingDurationArchetype.extendedSession;
}

RpeArchetype rpeArchetype({required double highRpeRatio}) {
  if (highRpeRatio < 0.10) return RpeArchetype.rarelyPushesToFailure;
  if (highRpeRatio < 0.50) return RpeArchetype.occasionallyPushesToFailure;
  return RpeArchetype.alwaysPushesToFailure;
}

MuscleFocusArchetype muscleFocusArchetype({required List<RoutineLogDto> logs}) {
  int upperSets = 0;
  int lowerSets = 0;

  for (final log in logs) {
    for (final exerciseLog in log.exerciseLogs) {
      final primaryMuscleGroup = exerciseLog.exercise.primaryMuscleGroup;
      final sets = exerciseLog.sets.length;
      if (MuscleGroup.upper.contains(primaryMuscleGroup)) {
        upperSets += sets;
      } else if (MuscleGroup.lower.contains(primaryMuscleGroup)) {
        lowerSets += sets;
      }
    }
  }

  final total = upperSets + lowerSets;
  if (total == 0) return MuscleFocusArchetype.fullBodyBalanced; // fallback

  final upperRatio = upperSets / total;
  final lowerRatio = lowerSets / total;

  if (upperRatio >= 0.60) return MuscleFocusArchetype.upperBodyFocus;
  if (lowerRatio >= 0.60) return MuscleFocusArchetype.lowerBodyFocus;
  return MuscleFocusArchetype.fullBodyBalanced;
}

/// Returns both archetypes for the supplied [logs] (any order).
List<TrainingArchetype> classifyTrainingArchetypes({
  required List<RoutineLogDto> logs,
}) {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  /// Returns a rounded‐up mean for any list of ints.
  int _safeAverage(List<int> values) => values.isEmpty ? 0 : (values.reduce((a, b) => a + b) / values.length).round();

  // ---------------------------------------------------------------------------
  // 1. Collect the last 13 calendar weeks
  // ---------------------------------------------------------------------------
  final dateRange = theLastYearDateTimeRange();
  final weeksInLastQuarter =
      generateWeeksInRange(range: dateRange).reversed.take(13).toList().reversed; // chronological order

  // ---------------------------------------------------------------------------
  // 2. Compute weekly session counts & store every single workout duration
  // ---------------------------------------------------------------------------
  final List<int> sessionsPerWeek = <int>[];
  final List<int> allDurations = <int>[]; // in minutes

  for (final week in weeksInLastQuarter) {
    final weekLogs = logs.where(
      (log) => log.createdAt.isBetweenInclusive(from: week.start, to: week.end),
    );

    sessionsPerWeek.add(weekLogs.length);
    allDurations.addAll(weekLogs.map((log) => log.duration().inMinutes));
  }

  // ---------------------------------------------------------------------------
  // 3. Weekly-average archetypes (safe even when the lists are empty)
  // ---------------------------------------------------------------------------
  final trainingFrequencyArch = trainingFrequencyArchetype(avgSessions: _safeAverage(sessionsPerWeek));

  final trainingDurationArch = trainingDurationArchetype(
    avgDuration: Duration(minutes: _safeAverage(allDurations)),
  );

  // ---------------------------------------------------------------------------
  // 4. RPE / effort archetype
  // ---------------------------------------------------------------------------
  final allSets = logs.expand((l) => l.exerciseLogs).expand((e) => e.sets);
  final setsNearFail = allSets.where((s) => s.rpeRating >= 8).length;
  final failureRatio = allSets.isNotEmpty ? setsNearFail / allSets.length : 0.0;

  final rpeArch = rpeArchetype(highRpeRatio: failureRatio);

  // ---------------------------------------------------------------------------
  // 5. Muscle-focus archetype
  // ---------------------------------------------------------------------------
  final muscleFocusArch = muscleFocusArchetype(logs: logs);

  // ---------------------------------------------------------------------------
  // 6. Return the archetype bundle
  // ---------------------------------------------------------------------------
  return [
    trainingFrequencyArch,
    trainingDurationArch,
    rpeArch,
    muscleFocusArch,
  ];
}
