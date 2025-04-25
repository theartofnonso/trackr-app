import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/enums/training_archetype.dart';

TrainingFrequencyArchetype trainingFrequencyArchetype({required int sessions}) {
  if (sessions <= 2) return TrainingFrequencyArchetype.rarelyTrains;
  if (sessions <= 4) return TrainingFrequencyArchetype.oftenTrains;
  return TrainingFrequencyArchetype.alwaysTrains;
}

TrainingDurationArchetype trainingDurationArchetype({required Duration duration}) {
  final minutes = duration.inMinutes;
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