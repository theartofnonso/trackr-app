import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../dtos/exercise_dto.dart';
import '../dtos/exercise_log_dto.dart';
import '../dtos/pb_dto.dart';
import '../dtos/set_dto.dart';
import '../enums/exercise_type_enums.dart';
import '../enums/pb_enums.dart';
import '../controllers/routine_log_controller.dart';

/// Highest value per [ExerciseLogDto]

SetDto heaviestSetWeightForExerciseLog({required ExerciseLogDto exerciseLog}) {
  if (exerciseLog.sets.isEmpty) {
    return const SetDto(0, 0, false);
  }

  return exerciseLog.sets.reduce((SetDto currentHeaviest, SetDto nextSet) =>
      (nextSet.value1 > currentHeaviest.value1) ? nextSet : currentHeaviest);
}

Duration longestDurationForExerciseLog({required ExerciseLogDto exerciseLog}) {
  return exerciseLog.sets
      .map((set) => Duration(milliseconds: set.value1.toInt()))
      .fold(Duration.zero, (max, duration) => duration > max ? duration : max);
}

Duration totalDurationExerciseLog({required ExerciseLogDto exerciseLog}) {
  return exerciseLog.sets.fold<Duration>(
    Duration.zero,
    (total, set) => total + Duration(milliseconds: set.value1.toInt()),
  );
}

int totalRepsForExerciseLog({required ExerciseLogDto exerciseLog}) =>
    exerciseLog.sets.fold(0, (total, set) => total + set.value2.toInt());

int highestRepsForExerciseLog({required ExerciseLogDto exerciseLog}) {
  if (exerciseLog.sets.isEmpty) return 0;

  return exerciseLog.sets.map((set) => set.value2).reduce((curr, next) => curr > next ? curr : next).toInt();
}

double heaviestVolumeForExerciseLog({required ExerciseLogDto exerciseLog}) {
  return exerciseLog.sets
      .map((set) => set.value1 * set.value2)
      .fold(0.0, (prev, element) => element > prev ? element.toDouble() : prev);
}

SetDto heaviestSetVolumeForExerciseLog({required ExerciseLogDto exerciseLog}) {
  // Check if there are no sets in the exercise log
  if (exerciseLog.sets.isEmpty) {
    return const SetDto(0, 0, false);
  }

  double heaviestVolume = 0;
  SetDto heaviestSet = const SetDto(0, 0, false);

  for (final set in exerciseLog.sets) {
    final num volume = set.value1 * set.value2;

    if (volume > heaviestVolume) {
      heaviestVolume = volume.toDouble();
      heaviestSet = set;
    }
  }

  return heaviestSet;
}

DateTime dateTimePerLog({required ExerciseLogDto log}) {
  return log.createdAt;
}

/// Highest value across all [ExerciseDto]

(String?, SetDto) heaviestSetVolume({required List<ExerciseLogDto> exerciseLogs}) {
  // Return null if there are no past logs
  if (exerciseLogs.isEmpty) return ("", const SetDto(0, 0, false));

  SetDto heaviestSet = exerciseLogs.first.sets.first;
  String? logId = exerciseLogs.first.routineLogId;

  double heaviestVolume = 0.0;

  for (var log in exerciseLogs) {
    final currentSet = heaviestSetVolumeForExerciseLog(exerciseLog: log);
    final currentVolume = currentSet.value1 * currentSet.value2;
    if (currentVolume > heaviestVolume) {
      heaviestSet = currentSet;
      logId = log.routineLogId;
    }
  }

  return (logId, heaviestSet);
}

(String?, double) heaviestWeight({required List<ExerciseLogDto> exerciseLogs}) {
  double heaviestWeight = 0;
  String? logId;
  if (exerciseLogs.isNotEmpty) {
    heaviestWeight = exerciseLogs.first.sets.first.value1.toDouble();
    logId = exerciseLogs.first.routineLogId;
    for (var log in exerciseLogs) {
      final weight = heaviestSetWeightForExerciseLog(exerciseLog: log).value1.toDouble();
      if (weight > heaviestWeight) {
        heaviestWeight = weight;
        logId = log.routineLogId;
      }
    }
  }
  return (logId, heaviestWeight);
}

(String?, int) highestReps({required List<ExerciseLogDto> exerciseLogs}) {
  int highestReps = 0;
  String? logId;
  if (exerciseLogs.isNotEmpty) {
    highestReps = exerciseLogs.first.sets.first.value2.toInt();
    logId = exerciseLogs.first.routineLogId;
    for (var log in exerciseLogs) {
      final reps = highestRepsForExerciseLog(exerciseLog: log);
      if (reps > highestReps) {
        highestReps = reps;
        logId = log.routineLogId;
      }
    }
  }
  return (logId, highestReps);
}

(String?, int) totalReps({required List<ExerciseLogDto> exerciseLogs}) {
  int mostReps = 0;
  String? logId;
  if (exerciseLogs.isNotEmpty) {
    mostReps = exerciseLogs.first.sets.first.value2.toInt();
    logId = exerciseLogs.first.routineLogId;
    for (var log in exerciseLogs) {
      final reps = totalRepsForExerciseLog(exerciseLog: log);
      if (reps > mostReps) {
        mostReps = reps;
        logId = log.routineLogId;
      }
    }
  }
  return (logId, mostReps);
}

(String?, Duration) longestDuration({required List<ExerciseLogDto> exerciseLogs}) {
  Duration longestDuration = Duration.zero;
  String? logId;
  if (exerciseLogs.isNotEmpty) {
    longestDuration = Duration(milliseconds: exerciseLogs.first.sets.first.value1.toInt());
    logId = exerciseLogs.first.routineLogId;
    for (var log in exerciseLogs) {
      final duration = longestDurationForExerciseLog(exerciseLog: log);
      if (duration > longestDuration) {
        longestDuration = duration;
        logId = log.routineLogId;
      }
    }
  }
  return (logId, longestDuration);
}

List<PBDto> calculatePBs(
    {required BuildContext context, required ExerciseType exerciseType, required ExerciseLogDto exerciseLog}) {
  final provider = Provider.of<RoutineLogController>(context, listen: false);

  final pastSets = provider.wherePastSetsForExerciseBefore(exercise: exerciseLog.exercise, date: exerciseLog.createdAt);
  final pastExerciseLogs =
      provider.wherePastExerciseLogsBefore(exercise: exerciseLog.exercise, date: exerciseLog.createdAt);

  List<PBDto> pbs = [];

  if (pastSets.isNotEmpty && pastExerciseLogs.isNotEmpty && exerciseLog.sets.isNotEmpty) {
    if (exerciseType == ExerciseType.weights) {
      final pastHeaviestWeight =
          pastExerciseLogs.map((log) => heaviestSetWeightForExerciseLog(exerciseLog: log)).map((set) => set.value1).max;
      final pastHeaviestSetVolume = pastExerciseLogs.map((log) => heaviestVolumeForExerciseLog(exerciseLog: log)).max;

      final currentHeaviestWeightSets = exerciseLog.sets.where((set) => set.value1 > pastHeaviestWeight);
      if (currentHeaviestWeightSets.isNotEmpty) {
        final heaviestWeightSet = currentHeaviestWeightSets
            .reduce((curr, next) => (curr.value1 * curr.value2) > (next.value1 * next.value2) ? curr : next);
        pbs.add(PBDto(set: heaviestWeightSet, exercise: exerciseLog.exercise, pb: PBType.weight));
      }

      final currentHeaviestVolumeSets =
          exerciseLog.sets.where((set) => (set.value1 * set.value2) > pastHeaviestSetVolume);
      if (currentHeaviestVolumeSets.isNotEmpty) {
        final heaviestVolumeSet = currentHeaviestVolumeSets
            .reduce((curr, next) => (curr.value1 * curr.value2) > (next.value1 * next.value2) ? curr : next);
        pbs.add(PBDto(set: heaviestVolumeSet, exercise: exerciseLog.exercise, pb: PBType.volume));
      }
    }

    if (exerciseType == ExerciseType.duration) {
      final pastLongestDuration = pastExerciseLogs.map((log) => longestDurationForExerciseLog(exerciseLog: log)).max;

      final currentLongestDurations =
          exerciseLog.sets.where((set) => Duration(milliseconds: set.value1.toInt()) > pastLongestDuration);
      if (currentLongestDurations.isNotEmpty) {
        final longestDurationSet = currentLongestDurations.reduce((curr, next) =>
            Duration(milliseconds: curr.value1.toInt()) > Duration(milliseconds: next.value1.toInt()) ? curr : next);
        pbs.add(PBDto(set: longestDurationSet, exercise: exerciseLog.exercise, pb: PBType.duration));
      }
    }
  }

  return pbs;
}
