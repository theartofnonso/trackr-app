import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/utils/sets_utils.dart';

import '../dtos/exercise_dto.dart';
import '../dtos/exercise_log_dto.dart';
import '../dtos/set_dto.dart';
import '../enums/exercise_type_enums.dart';
import '../providers/routine_log_provider.dart';
import '../widgets/routine/preview/exercise_log_widget.dart';

List<ExerciseLogDto> _pastLogsForExercise({required BuildContext context, required ExerciseDto exercise}) {
  return Provider.of<RoutineLogProvider>(context, listen: false).exerciseLogsById[exercise.id] ?? [];
}

/// Highest value per [RoutineLogDto]
///

SetDto _heaviestWeight({required List<SetDto> sets}) {

  SetDto maxSet = sets[0];
  num heaviestWeight = sets[0].value1;

  for (SetDto set in sets) {
    num currentWeight = set.value1;
    if (currentWeight > heaviestWeight) {
      maxSet = set;
    }
  }

  return maxSet;
}

SetDto heaviestWeightPerLog({required ExerciseLogDto exerciseLog}) {
  return _heaviestWeight(sets: exerciseLog.sets);
}

Duration longestDurationPerLog({required ExerciseLogDto exerciseLog}) {
  Duration longestDuration = Duration.zero;

  for (var set in exerciseLog.sets) {
    final duration = Duration(milliseconds: set.value1.toInt());
    if (duration > longestDuration) {
      longestDuration = duration;
    }
  }
  return longestDuration;
}

Duration totalDurationPerLog({required ExerciseLogDto exerciseLog}) {
  Duration totalDuration = Duration.zero;

  for (var set in exerciseLog.sets) {
    final duration = Duration(milliseconds: set.value1.toInt());
    totalDuration += duration;
  }
  return totalDuration;
}

int totalRepsForLog({required ExerciseLogDto exerciseLog}) {
  int totalReps = 0;

  final sets = exerciseLog.sets;

  for (var set in sets) {
    totalReps += set.value2.toInt();
  }
  return totalReps;
}

int highestRepsForLog({required ExerciseLogDto exerciseLog}) {
  int highestReps = 0;

  final sets = exerciseLog.sets;

  for (var set in sets) {
    final reps = set.value2;
    if (reps > highestReps) {
      highestReps = reps.toInt();
    }
  }

  return highestReps;
}

double heaviestSetVolumePerLog({required ExerciseLogDto exerciseLog}) {
  double heaviestVolume = 0;

  for (var set in exerciseLog.sets) {
    final volume = set.value1 * set.value2;
    if (volume > heaviestVolume) {
      heaviestVolume = volume.toDouble();
    }
  }

  return heaviestVolume;
}

double lightestSetVolumePerLog({required ExerciseLogDto exerciseLog}) {
  double lightestVolume = 0;

  for (var set in exerciseLog.sets) {
    final volume = set.value1 * set.value2;
    if (lightestVolume < volume) {
      lightestVolume = volume.toDouble();
    }
  }

  return lightestVolume;
}

DateTime dateTimePerLog({required ExerciseLogDto log}) {
  return log.createdAt;
}

double oneRepMaxPerLog({required ExerciseLogDto exerciseLog}) {
  final heaviestSet = heaviestWeightPerLog(exerciseLog: exerciseLog);

  final max = (heaviestSet.value1 * (1 + 0.0333 * heaviestSet.value2));

  return max;
}

/// Highest value across all [RoutineLogDto]

(String?, SetDto) heaviestSetForExercise({required BuildContext context, required ExerciseDto exercise}) {
  final pastLogs = _pastLogsForExercise(context: context, exercise: exercise);
  SetDto heaviestSet = const SetDto(0, 0, false);
  String? logId;
  if (pastLogs.isNotEmpty) {
    heaviestSet = pastLogs.first.sets.first;
    logId = pastLogs.first.routineLogId;
    for (var log in pastLogs) {
      for (var set in log.sets) {
        final volume = set.value1 * set.value2;
        if (volume > (heaviestSet.value1 * heaviestSet.value2)) {
          heaviestSet = set;
          logId = log.routineLogId;
        }
      }
    }
  }

  return (logId, heaviestSet);
}

(String?, SetDto) lightestSetForExercise({required BuildContext context, required ExerciseDto exercise}) {
  final pastLogs = _pastLogsForExercise(context: context, exercise: exercise);
  SetDto lightestSet = const SetDto(0, 0, false);
  String? logId;
  if (pastLogs.isNotEmpty) {
    lightestSet = pastLogs.first.sets.first;
    logId = pastLogs.first.routineLogId;
    for (var log in pastLogs) {
      for (var set in log.sets) {
        final volume = set.value1 * set.value2;
        if ((lightestSet.value1 * lightestSet.value2) > volume) {
          lightestSet = set;
          logId = log.routineLogId;
        }
      }
    }
  }

  return (logId, lightestSet);
}

(String?, double) heaviestWeightForExercise({required BuildContext context, required ExerciseDto exercise}) {
  final pastLogs = _pastLogsForExercise(context: context, exercise: exercise);
  double heaviestWeight = 0;
  String? logId;
  if (pastLogs.isNotEmpty) {
    heaviestWeight = pastLogs.first.sets.first.value1.toDouble();
    logId = pastLogs.first.routineLogId;
    for (var log in pastLogs) {
      for (var set in log.sets) {
        final weight = set.value1.toDouble();
        if (weight > heaviestWeight) {
          heaviestWeight = weight;
          logId = log.routineLogId;
        }
      }
    }
  }
  return (logId, heaviestWeight);
}

(String?, double) lightestWeightForExercise({required BuildContext context, required ExerciseDto exercise}) {
  final pastLogs = _pastLogsForExercise(context: context, exercise: exercise);
  double lightestWeight = 0;
  String? logId;
  if (pastLogs.isNotEmpty) {
    lightestWeight = pastLogs.first.sets.first.value1.toDouble();
    logId = pastLogs.first.routineLogId;
    for (var log in pastLogs) {
      for (var set in log.sets) {
        final weight = set.value1.toDouble();
        if (lightestWeight > weight) {
          lightestWeight = weight;
          logId = log.routineLogId;
        }
      }
    }
  }
  return (logId, lightestWeight);
}

(String?, int) highestRepsForExercise({required BuildContext context, required ExerciseDto exercise}) {
  final pastLogs = _pastLogsForExercise(context: context, exercise: exercise);
  int highestReps = 0;
  String? logId;
  if (pastLogs.isNotEmpty) {
    highestReps = pastLogs.first.sets.first.value2.toInt();
    logId = pastLogs.first.routineLogId;
    for (var log in pastLogs) {
      final reps = highestRepsForLog(exerciseLog: log);
      if (reps > highestReps) {
        highestReps = reps;
        logId = log.routineLogId;
      }
    }
  }
  return (logId, highestReps);
}

(String?, int) totalRepsForExercise({required BuildContext context, required ExerciseDto exercise}) {
  final pastLogs = _pastLogsForExercise(context: context, exercise: exercise);
  int mostReps = 0;
  String? logId;
  if (pastLogs.isNotEmpty) {
    mostReps = pastLogs.first.sets.first.value2.toInt();
    logId = pastLogs.first.routineLogId;
    for (var log in pastLogs) {
      final reps = totalRepsForLog(exerciseLog: log);
      if (reps > mostReps) {
        mostReps = reps;
        logId = log.routineLogId;
      }
    }
  }
  return (logId, mostReps);
}

(String?, Duration) longestDurationForExercise({required BuildContext context, required ExerciseDto exercise}) {
  final pastLogs = _pastLogsForExercise(context: context, exercise: exercise);
  Duration longestDuration = Duration.zero;
  String? logId;
  if (pastLogs.isNotEmpty) {
    longestDuration = Duration(milliseconds: pastLogs.first.sets.first.value1.toInt());
    logId = pastLogs.first.routineLogId;
    for (var log in pastLogs) {
      final duration = longestDurationPerLog(exerciseLog: log);
      if (duration > longestDuration) {
        longestDuration = duration;
        logId = log.routineLogId;
      }
    }
  }
  return (logId, longestDuration);
}

PBViewModel? calculatePBs({required BuildContext context, required ExerciseType exerciseType, required ExerciseLogDto exerciseLog}) {
  final provider = Provider.of<RoutineLogProvider>(context, listen: false);

  final pastSets =
  provider.wherePastSetsForExerciseBefore(exercise: exerciseLog.exercise, date: exerciseLog.createdAt);
  final pastExerciseLogs =
  provider.wherePastExerciseLogsBefore(exercise: exerciseLog.exercise, date: exerciseLog.createdAt);

  PBViewModel? pbViewModel;

  if (pastSets.isNotEmpty && pastExerciseLogs.isNotEmpty && exerciseLog.sets.isNotEmpty) {
    if (exerciseType == ExerciseType.weights) {
      final pastHeaviestSetWeight = _heaviestWeight(sets: pastSets);
      final pastHeaviestSetVolume = pastExerciseLogs.map((log) => heaviestSetVolumePerLog(exerciseLog: log)).max;
      final past1RM = pastExerciseLogs.map((log) => oneRepMaxPerLog(exerciseLog: log)).max;

      final currentHeaviestSetWeight = _heaviestWeight(sets: exerciseLog.sets);
      final currentHeaviestSetVolume = currentHeaviestSetWeight.value1 * currentHeaviestSetWeight.value2;
      final current1RM = (currentHeaviestSetWeight.value1 * (1 + 0.0333 * currentHeaviestSetWeight.value2));

      List<PBType> pbs = [];

      if (currentHeaviestSetWeight.value1 > pastHeaviestSetWeight.value1) {
        pbs.add(PBType.weight);
      }

      if (currentHeaviestSetVolume > pastHeaviestSetVolume) {
        pbs.add(PBType.volume);
      }

      if (current1RM > past1RM) {
        pbs.add(PBType.oneRepMax);
      }

      if (pbs.isNotEmpty) {
        pbViewModel = PBViewModel(set: currentHeaviestSetWeight, pbs: pbs);
      }
    }

    if (exerciseType == ExerciseType.duration) {
      final pastLongestDuration = pastExerciseLogs.map((log) => longestDurationPerLog(exerciseLog: log)).max;
      final currentLongestDurationSet = longestDurationSet(sets: exerciseLog.sets);
      final currentLongestDuration = Duration(milliseconds: currentLongestDurationSet.value1.toInt());

      if (currentLongestDuration > pastLongestDuration) {
        pbViewModel = PBViewModel(set: currentLongestDurationSet, pbs: [PBType.duration]);
      }
    }
  }
  return pbViewModel;
}