import 'package:collection/collection.dart';
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

class TrainingArchetypeClassifier {

  /// Returns both archetypes for the supplied [logs] (any order).
  static List<TrainingArchetype> classify({required List<RoutineLogDto> logs}) {

    final dateRange = theLastYearDateTimeRange();

    final weeksInLastQuarter = generateWeeksInRange(range: dateRange).reversed.take(13).toList().reversed;

    List<int> trainingSessions = [];
    List<int> trainingDurations = [];
    for (final week in weeksInLastQuarter) {
      final startOfWeek = week.start;
      final endOfWeek = week.end;
      final logsForTheWeek = logs.where((log) => log.createdAt.isBetweenInclusive(from: startOfWeek, to: endOfWeek));
      trainingSessions.add(logsForTheWeek.length);
      final durationsInMinutes = logsForTheWeek.map((log) => log.duration().inMinutes);
      trainingDurations.addAll(durationsInMinutes);
    }

    /// Weekly averages
    final trainingFrequencyArch = trainingFrequencyArchetype(avgSessions: trainingSessions.average.round());
    final trainingDurationArch = trainingDurationArchetype(avgDuration: Duration(minutes: trainingDurations.average.round()));

    /// Percentage of high RPE sets
    final exerciseLogs = logs.expand((log) => log.exerciseLogs);
    final totalSets = exerciseLogs
        .expand((ex) => ex.sets);

    final setsNearFail = totalSets
        .where((s) => s.rpeRating >= 8)
        .length;

    final failureRatio = setsNearFail / totalSets.length;

    final rpeArch = rpeArchetype(highRpeRatio: failureRatio);

    /// Frequency of [MuscleGroup]
    final muscleFocusArch = muscleFocusArchetype(logs: logs);

    return [trainingFrequencyArch, trainingDurationArch, rpeArch, muscleFocusArch];
  }

}