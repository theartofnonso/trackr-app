import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/dtos/sets_dtos/duration_set_dto.dart';
import 'package:tracker_app/dtos/sets_dtos/reps_set_dto.dart';
import 'package:tracker_app/dtos/sets_dtos/weight_and_reps_set_dto.dart';

import '../dtos/exercise_dto.dart';
import '../dtos/exercise_log_dto.dart';
import '../dtos/pb_dto.dart';
import '../dtos/sets_dtos/set_dto.dart';
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
      ((nextSet as WeightAndRepsSetDTO).weight > (currentHeaviest as WeightAndRepsSetDTO).weight)
          ? nextSet
          : currentHeaviest);
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

int totalRepsForExerciseLog({required ExerciseLogDTO exerciseLog}) => exerciseLog.sets.fold(0, (total, set) {
      final metric = exerciseLog.exerciseVariant.getExerciseMetricConfiguration("metrics");
      if (metric == SetType.reps) {
        return total + (set as RepsSetDTO).reps;
      } else if (metric == SetType.weightsAndReps) {
        return total + (set as WeightAndRepsSetDTO).reps;
      }
      return 0;
    });

int highestRepsForExerciseLog({required ExerciseLogDTO exerciseLog}) {
  if (exerciseLog.sets.isEmpty) return 0;

  return exerciseLog.sets
      .map((set) {
        final metric = exerciseLog.exerciseVariant.getExerciseMetricConfiguration("metrics");
        if (metric == SetType.reps) {
          return (set as RepsSetDTO).reps;
        } else if (metric == SetType.weightsAndReps) {
          return (set as WeightAndRepsSetDTO).reps;
        }
        return 0;
      })
      .reduce((curr, next) => curr > next ? curr : next)
      .toInt();
}

double heaviestVolumeForExerciseLog({required ExerciseLogDTO exerciseLog}) {
  return exerciseLog.sets
      .map((set) => (set as WeightAndRepsSetDTO).volume())
      .fold(0.0, (prev, element) => element > prev ? element : prev);
}

SetDTO heaviestSetVolumeForExerciseLog({required ExerciseLogDTO exerciseLog}) {
  final emptySet = SetDTO.newType(type: SetType.weightsAndReps);

  // Check if there are no sets in the exercise log
  if (exerciseLog.sets.isEmpty) {
    return emptySet;
  }

  double heaviestVolume = 0;
  SetDTO heaviestSet = emptySet;

  for (final set in exerciseLog.sets) {
    final volume = (set as WeightAndRepsSetDTO).volume();

    if (volume > heaviestVolume) {
      heaviestVolume = volume;
      heaviestSet = set;
    }
  }

  return heaviestSet;
}

/// Highest value across all [ExerciseDTO]

(String?, SetDTO) heaviestSetVolume({required List<ExerciseLogDTO> exerciseLogs}) {
  final emptySet = SetDTO.newType(type: SetType.weightsAndReps);

  // Return null if there are no past logs
  if (exerciseLogs.isEmpty) return (null, emptySet);

  String? logId;
  SetDTO heaviestSet = emptySet;

  num heaviestVolume = 0.0;

  for (var log in exerciseLogs) {
    final currentSet = heaviestSetVolumeForExerciseLog(exerciseLog: log);
    final currentVolume = (currentSet as WeightAndRepsSetDTO).volume();
    if (currentVolume > heaviestVolume) {
      logId = log.routineLogId;
      heaviestVolume = currentVolume;
      heaviestSet = currentSet;
    }
  }

  return (logId, heaviestSet);
}

(String?, double) heaviestWeight({required List<ExerciseLogDTO> exerciseLogs}) {
  String? logId;
  double heaviestWeight = 0;
  if (exerciseLogs.isNotEmpty) {
    for (var log in exerciseLogs) {
      final weight = (heaviestSetWeightForExerciseLog(exerciseLog: log) as WeightAndRepsSetDTO).weight;
      if (weight > heaviestWeight) {
        logId = log.routineLogId;
        heaviestWeight = weight;
      }
    }
  }
  return (logId, heaviestWeight);
}

(String?, int) mostRepsInSet({required List<ExerciseLogDTO> exerciseLogs}) {
  String? logId;
  int highestReps = 0;
  if (exerciseLogs.isNotEmpty) {
    for (var log in exerciseLogs) {
      final reps = highestRepsForExerciseLog(exerciseLog: log);
      if (reps > highestReps) {
        logId = log.routineLogId;
        highestReps = reps;
      }
    }
  }
  return (logId, highestReps);
}

(String?, int) mostRepsInSession({required List<ExerciseLogDTO> exerciseLogs}) {
  String? logId;
  int mostReps = 0;
  if (exerciseLogs.isNotEmpty) {
    for (var log in exerciseLogs) {
      final reps = totalRepsForExerciseLog(exerciseLog: log);
      if (reps > mostReps) {
        logId = log.routineLogId;
        mostReps = reps;
      }
    }
  }
  return (logId, mostReps);
}

(String?, Duration) longestDuration({required List<ExerciseLogDTO> exerciseLogs}) {
  Duration longestDuration = Duration.zero;
  String? logId;
  if (exerciseLogs.isNotEmpty) {
    for (var log in exerciseLogs) {
      final duration = longestDurationForExerciseLog(exerciseLog: log);
      if (duration > longestDuration) {
        logId = log.routineLogId;
        longestDuration = duration;
      }
    }
  }
  return (logId, longestDuration);
}

List<PBDto> calculatePBs(
    {required List<ExerciseLogDTO> pastExerciseLogs,
    required SetType exerciseMetric,
    required ExerciseLogDTO exerciseLog}) {
  List<PBDto> pbs = [];

  if (pastExerciseLogs.isNotEmpty && exerciseLog.sets.isNotEmpty) {
    if (withWeightsOnly(metric: exerciseMetric)) {
      final pastHeaviestWeight = pastExerciseLogs
          .map((log) => heaviestSetWeightForExerciseLog(exerciseLog: log))
          .map((set) => (set as WeightAndRepsSetDTO).weight)
          .max;
      final pastHeaviestSetVolume = pastExerciseLogs.map((log) => heaviestVolumeForExerciseLog(exerciseLog: log)).max;

      final currentHeaviestWeightSets =
          exerciseLog.sets.where((set) => (set as WeightAndRepsSetDTO).weight > pastHeaviestWeight);
      if (currentHeaviestWeightSets.isNotEmpty) {
        final heaviestWeightSet = currentHeaviestWeightSets.reduce((curr, next) =>
            ((curr as WeightAndRepsSetDTO).volume()) > ((next as WeightAndRepsSetDTO).volume()) ? curr : next);
        pbs.add(PBDto(set: heaviestWeightSet, exerciseVariant: exerciseLog.exerciseVariant, pb: PBType.weight));
      }

      final currentHeaviestVolumeSets =
          exerciseLog.sets.where((set) => ((set as WeightAndRepsSetDTO).volume()) > pastHeaviestSetVolume);
      if (currentHeaviestVolumeSets.isNotEmpty) {
        final heaviestVolumeSet = currentHeaviestVolumeSets.reduce((curr, next) =>
            ((curr as WeightAndRepsSetDTO).volume()) > ((next as WeightAndRepsSetDTO).volume()) ? curr : next);
        pbs.add(PBDto(set: heaviestVolumeSet, exerciseVariant: exerciseLog.exerciseVariant, pb: PBType.volume));
      }
    }

    if (withDurationOnly(metric: exerciseMetric)) {
      final pastLongestDuration = pastExerciseLogs.map((log) => longestDurationForExerciseLog(exerciseLog: log)).max;

      final currentLongestDurations =
          exerciseLog.sets.where((set) => (set as DurationSetDTO).duration > pastLongestDuration);
      if (currentLongestDurations.isNotEmpty) {
        final longestDurationSet = currentLongestDurations.reduce(
            (curr, next) => (curr as DurationSetDTO).duration > (next as DurationSetDTO).duration ? curr : next);
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
  final exerciseLog1Volume = exerciseLogs1
      .expand((logs) => logs.sets)
      .fold(0.0, (previousValue, set) => previousValue + ((set as WeightAndRepsSetDTO).volume()));
  final exerciseLog2Volume = exerciseLogs2
      .expand((logs) => logs.sets)
      .fold(0.0, (previousValue, set) => previousValue + ((set as WeightAndRepsSetDTO).volume()));

  return exerciseLog1Volume != exerciseLog2Volume ? TemplateChange.setValue : null;
}

Map<MuscleGroup, double> muscleGroupFrequency(
    {required List<ExerciseLogDTO> exerciseLogs, bool includeSecondaryMuscleGroups = true}) {
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
    final primaryMuscleGroups =
        logAndDate.value.map((log) => log.exerciseVariant.primaryMuscleGroups).expand((muscleGroup) => muscleGroup);
    final secondaryMuscleGroups =
        logAndDate.value.map((log) => log.exerciseVariant.secondaryMuscleGroups).expand((muscleGroup) => muscleGroup);
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

bool withWeightsOnly({required SetType metric}) {
  return metric == SetType.weightsAndReps;
}

bool withReps({required SetType metric}) {
  return metric == SetType.weightsAndReps || metric == SetType.reps;
}

bool withRepsOnly({required SetType metric}) {
  return metric == SetType.reps;
}

bool withDurationOnly({required SetType metric}) {
  return metric == SetType.duration;
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
