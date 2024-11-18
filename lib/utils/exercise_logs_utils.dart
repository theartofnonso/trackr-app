import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/dtos/duration_set_dto.dart';
import 'package:tracker_app/dtos/reps_set_dto.dart';
import 'package:tracker_app/dtos/weight_and_reps_set_dto.dart';

import '../dtos/exercise_dto.dart';
import '../dtos/exercise_log_dto.dart';
import '../dtos/pb_dto.dart';
import '../dtos/set_dto.dart';
import '../enums/exercise/exercise_metrics_enums.dart';
import '../enums/muscle_group_enums.dart';
import '../enums/pb_enums.dart';
import '../enums/template_changes_type_message_enums.dart';

/// Highest value per [ExerciseLogDTO]

SetDTO heaviestSetWeightForExerciseLog({required ExerciseLogDTO exerciseLog}) {
  if (exerciseLog.sets.isEmpty) {
    return const WeightAndRepsSetDTO(weight: 0, reps: 0, checked: false);
  }

  return exerciseLog.sets.reduce((SetDTO currentHeaviest, SetDTO nextSet) =>
      ((nextSet as WeightAndRepsSetDTO).weight > (currentHeaviest as WeightAndRepsSetDTO).weight) ? nextSet : currentHeaviest);
}

Duration longestDurationForExerciseLog({required ExerciseLogDTO exerciseLog}) {
  return exerciseLog.sets
      .map((set) => (set as DurationSetDTO).duration)
      .fold(Duration.zero, (max, duration) => duration > max ? duration : max);
}

Duration totalDurationExerciseLog({required ExerciseLogDTO exerciseLog}) {
  return exerciseLog.sets.fold<Duration>(
    Duration.zero,
    (total, set) => total + (set as DurationSetDTO).duration,
  );
}

int totalRepsForExerciseLog({required ExerciseLogDTO exerciseLog}) =>
    exerciseLog.sets.fold(0, (total, set) {
      final metric = exerciseLog.exerciseVariant.metric;
      if(metric == ExerciseMetric.reps) {
        return total + (set as RepsSetDTO).reps;
      } else if(metric == ExerciseMetric.weights) {
        return total + (set as WeightAndRepsSetDTO).reps;
      }
      return 0;
    });

int highestRepsForExerciseLog({required ExerciseLogDTO exerciseLog}) {
  if (exerciseLog.sets.isEmpty) return 0;

  return exerciseLog.sets.map((set) {
    final metric = exerciseLog.exerciseVariant.metric;
    if(metric == ExerciseMetric.reps) {
      return (set as RepsSetDTO).reps;
    } else if(metric == ExerciseMetric.weights) {
      return (set as WeightAndRepsSetDTO).reps;
    }
    set.reps()).reduce((curr, next) => curr > next ? curr : next
  }).toInt();
}

double heaviestVolumeForExerciseLog({required ExerciseLogDTO exerciseLog}) {
  return exerciseLog.sets.map((set) => set.volume()).fold(0.0, (prev, element) => element > prev ? element : prev);
}

SetDTO heaviestSetVolumeForExerciseLog({required ExerciseLogDTO exerciseLog}) {
  // Check if there are no sets in the exercise log
  if (exerciseLog.sets.isEmpty) {
    return const SetDTO(0, 0, false);
  }

  double heaviestVolume = 0;
  SetDTO heaviestSet = const SetDTO(0, 0, false);

  for (final set in exerciseLog.sets) {
    final volume = set.volume();

    if (volume > heaviestVolume) {
      heaviestVolume = volume;
      heaviestSet = set;
    }
  }

  return heaviestSet;
}

DateTime dateTimePerLog({required ExerciseLogDTO log}) {
  return log.createdAt;
}

/// Highest value across all [ExerciseDTO]

(String?, SetDTO) heaviestSetVolume({required List<ExerciseLogDTO> exerciseLogs}) {
  // Return null if there are no past logs
  if (exerciseLogs.isEmpty) return ("", const SetDTO(0, 0, false));

  SetDTO heaviestSet = exerciseLogs.first.sets.first;
  String? logId = exerciseLogs.first.routineLogId;

  num heaviestVolume = 0.0;

  for (var log in exerciseLogs) {
    final currentSet = heaviestSetVolumeForExerciseLog(exerciseLog: log);
    final currentVolume = currentSet.volume();
    if (currentVolume > heaviestVolume) {
      heaviestVolume = currentVolume;
      heaviestSet = currentSet;
      logId = log.routineLogId;
    }
  }

  return (logId, heaviestSet);
}

(String?, double) heaviestWeight({required List<ExerciseLogDTO> exerciseLogs}) {
  double heaviestWeight = 0;
  String? logId;
  if (exerciseLogs.isNotEmpty) {
    heaviestWeight = exerciseLogs.first.sets.first.weight();
    logId = exerciseLogs.first.routineLogId;
    for (var log in exerciseLogs) {
      final weight = heaviestSetWeightForExerciseLog(exerciseLog: log).weight();
      if (weight > heaviestWeight) {
        heaviestWeight = weight;
        logId = log.routineLogId;
      }
    }
  }
  return (logId, heaviestWeight);
}

(String?, int) mostRepsInSet({required List<ExerciseLogDTO> exerciseLogs}) {
  int highestReps = 0;
  String? logId;
  if (exerciseLogs.isNotEmpty) {
    highestReps = exerciseLogs.first.sets.first.reps().toInt();
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

(String?, int) mostRepsInSession({required List<ExerciseLogDTO> exerciseLogs}) {
  int mostReps = 0;
  String? logId;
  if (exerciseLogs.isNotEmpty) {
    mostReps = exerciseLogs.first.sets.first.reps().toInt();
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

(String?, Duration) longestDuration({required List<ExerciseLogDTO> exerciseLogs}) {
  Duration longestDuration = Duration.zero;
  String? logId;
  if (exerciseLogs.isNotEmpty) {
    longestDuration = Duration(milliseconds: exerciseLogs.first.sets.first.duration());
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
    {required List<ExerciseLogDTO> pastExerciseLogs,
      required ExerciseMetric exerciseMetric,
      required ExerciseLogDTO exerciseLog}) {
  List<PBDto> pbs = [];

  if (pastExerciseLogs.isNotEmpty && exerciseLog.sets.isNotEmpty) {
    if (withWeightsOnly(metric: exerciseMetric)) {
      final pastHeaviestWeight = pastExerciseLogs
          .map((log) => heaviestSetWeightForExerciseLog(exerciseLog: log))
          .map((set) => set.weight())
          .max;
      final pastHeaviestSetVolume = pastExerciseLogs.map((log) => heaviestVolumeForExerciseLog(exerciseLog: log)).max;

      final currentHeaviestWeightSets = exerciseLog.sets.where((set) => set.weight() > pastHeaviestWeight);
      if (currentHeaviestWeightSets.isNotEmpty) {
        final heaviestWeightSet =
        currentHeaviestWeightSets.reduce((curr, next) => (curr.volume()) > (next.volume()) ? curr : next);
        pbs.add(PBDto(set: heaviestWeightSet, exerciseVariant: exerciseLog.exerciseVariant, pb: PBType.weight));
      }

      final currentHeaviestVolumeSets = exerciseLog.sets.where((set) => (set.volume()) > pastHeaviestSetVolume);
      if (currentHeaviestVolumeSets.isNotEmpty) {
        final heaviestVolumeSet =
        currentHeaviestVolumeSets.reduce((curr, next) => (curr.volume()) > (next.volume()) ? curr : next);
        pbs.add(PBDto(set: heaviestVolumeSet, exerciseVariant: exerciseLog.exerciseVariant, pb: PBType.volume));
      }
    }

    if (withDurationOnly(metric: exerciseMetric)) {
      final pastLongestDuration = pastExerciseLogs.map((log) => longestDurationForExerciseLog(exerciseLog: log)).max;

      final currentLongestDurations =
      exerciseLog.sets.where((set) => Duration(milliseconds: set.duration()) > pastLongestDuration);
      if (currentLongestDurations.isNotEmpty) {
        final longestDurationSet = currentLongestDurations.reduce((curr, next) =>
        Duration(milliseconds: curr.duration()) > Duration(milliseconds: next.duration()) ? curr : next);
        pbs.add(PBDto(set: longestDurationSet, exerciseVariant: exerciseLog.exerciseVariant, pb: PBType.duration));
      }
    }
  }

  return pbs;
}

TemplateChange? hasDifferentExerciseLogsLength(
    {required List<ExerciseLogDTO> exerciseLogs1, required List<ExerciseLogDTO> exerciseLogs2}) {
  return exerciseLogs2.length != exerciseLogs1.length ? TemplateChange.exerciseLogLength : null;
}

TemplateChange? hasReOrderedExercises(
    {required List<ExerciseLogDTO> exerciseLogs1, required List<ExerciseLogDTO> exerciseLogs2}) {
  final length = exerciseLogs1.length > exerciseLogs2.length ? exerciseLogs2.length : exerciseLogs1.length;
  for (int i = 0; i < length; i++) {
    if (exerciseLogs1[i].exerciseVariant.name != exerciseLogs2[i].exerciseVariant.name) {
      return TemplateChange.exerciseOrder; // Re-orderedList
    }
  }
  return null;
}

TemplateChange? hasDifferentSetsLength(
    {required List<ExerciseLogDTO> exerciseLogs1, required List<ExerciseLogDTO> exerciseLogs2}) {
  final exerciseLog1Sets = exerciseLogs1.expand((logs) => logs.sets);
  final exerciseLog2Sets = exerciseLogs2.expand((logs) => logs.sets);

  return exerciseLog1Sets.length != exerciseLog2Sets.length ? TemplateChange.setsLength : null;
}

TemplateChange? hasExercisesChanged({
  required List<ExerciseLogDTO> exerciseLogs1,
  required List<ExerciseLogDTO> exerciseLogs2,
}) {
  Set<String> exerciseIds1 = exerciseLogs1.map((p) => p.exerciseVariant.name).toSet();
  Set<String> exerciseIds2 = exerciseLogs2.map((p) => p.exerciseVariant.name).toSet();

  int changes = exerciseIds1.difference(exerciseIds2).length;

  return changes > 0 ? TemplateChange.exerciseLogChange : null;
}

TemplateChange? hasSuperSetIdChanged({
  required List<ExerciseLogDTO> exerciseLogs1,
  required List<ExerciseLogDTO> exerciseLogs2,
}) {
  Set<String> superSetIds1 =
      exerciseLogs1.map((p) => p.superSetId).where((superSetId) => superSetId.isNotEmpty).toSet();
  Set<String> superSetIds2 =
      exerciseLogs2.map((p) => p.superSetId).where((superSetId) => superSetId.isNotEmpty).toSet();

  final changes = superSetIds2.difference(superSetIds1).length;

  return changes > 0 ? TemplateChange.supersetId : null;
}

TemplateChange? hasCheckedSetsChanged(
    {required List<ExerciseLogDTO> exerciseLogs1, required List<ExerciseLogDTO> exerciseLogs2}) {
  final exerciseLog1CompletedSets = exerciseLogs1.expand((log) => log.sets).where((set) => set.checked).toList();
  final exerciseLog2CompletedSets = exerciseLogs2.expand((log) => log.sets).where((set) => set.checked).toList();

  if (exerciseLog1CompletedSets.length != exerciseLog2CompletedSets.length) {
    return TemplateChange.checkedSets;
  }

  return null;
}

TemplateChange? hasSetValueChanged({
  required List<ExerciseLogDTO> exerciseLogs1,
  required List<ExerciseLogDTO> exerciseLogs2,
}) {
  final exerciseLog1Volume =
      exerciseLogs1.expand((logs) => logs.sets).fold(0.0, (previousValue, set) => previousValue + (set.volume()));
  final exerciseLog2Volume =
      exerciseLogs2.expand((logs) => logs.sets).fold(0.0, (previousValue, set) => previousValue + (set.volume()));

  return exerciseLog1Volume != exerciseLog2Volume ? TemplateChange.setValue : null;
}

Map<MuscleGroup, double> muscleGroupFrequency({required List<ExerciseLogDTO> exerciseLogs, bool includeSecondaryMuscleGroups = true}) {
  final frequencyMap = <MuscleGroup, int>{};

  // Counting the occurrences of each MuscleGroup
  for (var log in exerciseLogs) {
    for (final muscleGroup in log.exerciseVariant.primaryMuscleGroups) {
      frequencyMap.update(muscleGroup, (value) => value + 1, ifAbsent: () => 1);
    }
    if (includeSecondaryMuscleGroups) {
      for (var muscleGroup in log.exerciseVariant.secondaryMuscleGroups) {
        frequencyMap.update(muscleGroup, (value) => value + 1, ifAbsent: () => 1);
      }
    }
  }

  int totalCount = frequencyMap.values.sum;
  final scaledFrequencyMap = <MuscleGroup, double>{};

  // Scaling the frequencies from 0 to 1
  frequencyMap.forEach((key, value) {
    scaledFrequencyMap[key] = value / totalCount;
  });

  final sortedEntries = scaledFrequencyMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

  final sortedFrequencyMap = LinkedHashMap<MuscleGroup, double>.fromEntries(sortedEntries);
  return sortedFrequencyMap;
}

Map<MuscleGroup, int> _muscleGroupCountOn4WeeksScale({required List<ExerciseLogDTO> exerciseLogs}) {
  final frequencyMap = <MuscleGroup, int>{};

  final exerciseLogsByDay = groupBy(exerciseLogs, (log) => log.createdAt.day);

  // Counting the occurrences of each MuscleGroup
  for (var logAndDate in exerciseLogsByDay.entries) {
    final primaryMuscleGroups = logAndDate.value
        .map((log) => log.exerciseVariant.primaryMuscleGroups)
        .expand((muscleGroup) => muscleGroup);
    final secondaryMuscleGroups = logAndDate.value
        .map((log) => log.exerciseVariant.secondaryMuscleGroups)
        .expand((muscleGroup) => muscleGroup);
    final muscleGroups = {...primaryMuscleGroups, ...secondaryMuscleGroups};

    for (final muscleGroup in muscleGroups) {
      frequencyMap.update(muscleGroup, (value) => value >= 8 ? 8 : value + 1, ifAbsent: () => 1);
    }
  }

  return frequencyMap;
}

Map<MuscleGroup, double> muscleGroupFrequencyOn4WeeksScale({required List<ExerciseLogDTO> exerciseLogs}) {
  final frequencyMap = _muscleGroupCountOn4WeeksScale(exerciseLogs: exerciseLogs);

  final scaledFrequencyMap = <MuscleGroup, double>{};

  // Scaling the frequencies from 0 to 1
  frequencyMap.forEach((key, value) {
    final scaledValue = value / 8;
    scaledFrequencyMap[key] = scaledValue > 1 ? 1 : scaledValue;
  });

  final sortedEntries = scaledFrequencyMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

  final sortedFrequencyMap = LinkedHashMap<MuscleGroup, double>.fromEntries(sortedEntries);

  return sortedFrequencyMap;
}

double cumulativeMuscleGroupFamilyFrequency({required List<ExerciseLogDTO> exerciseLogs}) {
  final frequencyEntries = _muscleGroupCountOn4WeeksScale(exerciseLogs: exerciseLogs).entries;

  final frequencyMap = Map.fromEntries(frequencyEntries);

  final cumulativeFrequency = frequencyMap.entries.map((entry) => entry.value).sum;

  return cumulativeFrequency / 56;
}

bool withWeightsOnly({required ExerciseMetric metric}) {
  return metric == ExerciseMetric.weights;
}

bool withReps({required ExerciseMetric metric}) {
  return metric == ExerciseMetric.weights || metric == ExerciseMetric.reps;
}

bool withRepsOnly({required ExerciseMetric metric}) {
  return metric == ExerciseMetric.reps;
}

bool withDurationOnly({required ExerciseMetric metric}) {
  return metric == ExerciseMetric.duration;
}

int _calculateMuscleScore({required List<ExerciseLogDTO> exerciseLogs}) {
  final muscleGroupsFrequencyScore = cumulativeMuscleGroupFamilyFrequency(exerciseLogs: exerciseLogs);

  final percentageScore = (muscleGroupsFrequencyScore * 100).round();

  return percentageScore;
}

List<ExerciseLogDTO> completedExercises({required List<ExerciseLogDTO> exerciseLogs}) {
  return exerciseLogs.where((exerciseLog) {
    final completedSets = exerciseLog.sets.where((set) => set.isNotEmpty() && set.checked);
    return completedSets.isNotEmpty;
  }).toList();
}

int calculateMuscleScoreForLogs({required List<RoutineLogDto> routineLogs}) {
  final exerciseLogs = routineLogs.expand((log) => log.exerciseLogs).toList();

  final percentageScore = _calculateMuscleScore(exerciseLogs: exerciseLogs);

  return percentageScore;
}

int calculateMuscleScoreForLog({required RoutineLogDto routineLog}) {
  final percentageScore = _calculateMuscleScore(exerciseLogs: routineLog.exerciseLogs);

  return percentageScore;
}
