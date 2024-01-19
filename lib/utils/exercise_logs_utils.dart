import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../dtos/exercise_dto.dart';
import '../dtos/exercise_log_dto.dart';
import '../dtos/pb_dto.dart';
import '../dtos/set_dto.dart';
import '../dtos/template_changes_messages_dto.dart';
import '../enums/exercise_type_enums.dart';
import '../enums/pb_enums.dart';
import '../controllers/routine_log_controller.dart';
import '../enums/template_changes_type_message_enums.dart';

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

TemplateChangesMessageDto? hasDifferentExerciseLogsLength(
    {required List<ExerciseLogDto> exerciseLog1, required List<ExerciseLogDto> exerciseLog2}) {
  final int difference = exerciseLog2.length - exerciseLog1.length;

  if (difference > 0) {
    return TemplateChangesMessageDto(
        message: "Added $difference exercise(s)", type: TemplateChangesMessageType.exerciseLogLength);
  } else if (difference < 0) {
    return TemplateChangesMessageDto(
        message: "Removed ${-difference} exercise(s)", type: TemplateChangesMessageType.exerciseLogLength);
  }

  return null; // No change in length
}

TemplateChangesMessageDto? hasReOrderedExercises(
    {required List<ExerciseLogDto> exerciseLog1, required List<ExerciseLogDto> exerciseLog2}) {
  final length = exerciseLog1.length > exerciseLog2.length ? exerciseLog2.length : exerciseLog1.length;
  for (int i = 0; i < length; i++) {
    if (exerciseLog1[i].exercise.id != exerciseLog2[i].exercise.id) {
      return TemplateChangesMessageDto(
          message: "Exercises have been re-ordered",
          type: TemplateChangesMessageType.exerciseOrder); // Re-orderedList
    }
  }
  return null;
}

TemplateChangesMessageDto? hasDifferentSetsLength(
    {required List<ExerciseLogDto> exerciseLog1, required List<ExerciseLogDto> exerciseLog2}) {
  int addedSetsCount = 0;
  int removedSetsCount = 0;

  for (ExerciseLogDto proc1 in exerciseLog1) {
    ExerciseLogDto? matchingProc2 = exerciseLog2.firstWhereOrNull((p) => p.exercise.id == proc1.exercise.id);

    if (matchingProc2 == null) continue;

    int difference = matchingProc2.sets.length - proc1.sets.length;
    if (difference > 0) {
      addedSetsCount += difference;
    } else if (difference < 0) {
      removedSetsCount -= difference; // Subtracting a negative number to add its absolute value
    }
  }

  String message = '';
  if (addedSetsCount > 0) {
    message = "Added $addedSetsCount set(s)";
  }

  if (removedSetsCount > 0) {
    if (message.isNotEmpty) message += ' and ';
    message += "Removed $removedSetsCount set(s)";
  }

  return message.isNotEmpty
      ? TemplateChangesMessageDto(message: message, type: TemplateChangesMessageType.setsLength)
      : null;
}

TemplateChangesMessageDto? hasExercisesChanged({
  required List<ExerciseLogDto> exerciseLog1,
  required List<ExerciseLogDto> exerciseLog2,
}) {
  Set<String> exerciseIds1 = exerciseLog1.map((p) => p.exercise.id).toSet();
  Set<String> exerciseIds2 = exerciseLog2.map((p) => p.exercise.id).toSet();

  int changes = exerciseIds1.difference(exerciseIds2).length;

  return changes > 0
      ? TemplateChangesMessageDto(
      message: "Changed $changes exercise(s)", type: TemplateChangesMessageType.exerciseLogChange)
      : null;
}

TemplateChangesMessageDto? hasSuperSetIdChanged({
  required List<ExerciseLogDto> exerciseLog1,
  required List<ExerciseLogDto> exerciseLog2,
}) {
  Set<String> superSetIds1 =
  exerciseLog1.map((p) => p.superSetId).where((superSetId) => superSetId.isNotEmpty).toSet();
  Set<String> superSetIds2 =
  exerciseLog2.map((p) => p.superSetId).where((superSetId) => superSetId.isNotEmpty).toSet();

  final changes = superSetIds2.difference(superSetIds1).length;

  return changes > 0
      ? TemplateChangesMessageDto(
      message: "Changed $changes supersets(s)", type: TemplateChangesMessageType.supersetId)
      : null;
}
