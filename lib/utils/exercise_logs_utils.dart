import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';

import '../dtos/appsync/exercise_dto.dart';
import '../dtos/exercise_log_dto.dart';
import '../dtos/pb_dto.dart';
import '../dtos/set_dtos/duration_set_dto.dart';
import '../dtos/set_dtos/reps_dto.dart';
import '../dtos/set_dtos/set_dto.dart';
import '../dtos/set_dtos/weight_and_reps_dto.dart';
import '../enums/exercise_type_enums.dart';
import '../enums/muscle_group_enums.dart';
import '../enums/pb_enums.dart';
import '../enums/template_changes_type_message_enums.dart';

/// Highest value per [ExerciseLogDto]

WeightAndRepsSetDto heaviestWeightInSetForExerciseLog({required ExerciseLogDto exerciseLog}) {
  final weightSets = exerciseLog.sets.whereType<WeightAndRepsSetDto>().toList();

  if (weightSets.isEmpty) {
    return const WeightAndRepsSetDto(weight: 0.0, reps: 0, checked: false);
  }

  return weightSets
      .reduce((currentHeaviest, nextSet) => nextSet.weight > currentHeaviest.weight ? nextSet : currentHeaviest);
}

Duration longestDurationForExerciseLog({required ExerciseLogDto exerciseLog}) {
  final durationSets = exerciseLog.sets.whereType<DurationSetDto>();

  if (durationSets.isEmpty) {
    return Duration.zero;
  }

  return durationSets.map((set) => set.duration).reduce((max, duration) => duration > max ? duration : max);
}

Duration totalDurationExerciseLog({required ExerciseLogDto exerciseLog}) {
  return exerciseLog.sets.whereType<DurationSetDto>().fold<Duration>(
        Duration.zero,
        (total, set) => total + set.duration,
      );
}

int totalRepsForExerciseLog({required ExerciseLogDto exerciseLog}) {
  final exerciseType = exerciseLog.exercise.type;

  if (exerciseType == ExerciseType.bodyWeight) {
    return exerciseLog.sets.whereType<RepsSetDto>().fold(0, (total, set) => total + set.reps);
  } else if (exerciseType == ExerciseType.weights) {
    return exerciseLog.sets.whereType<WeightAndRepsSetDto>().fold(0, (total, set) => total + set.reps);
  }

  return 0;
}

int highestRepsForExerciseLog({required ExerciseLogDto exerciseLog}) {
  final exerciseType = exerciseLog.exercise.type;

  if (exerciseType == ExerciseType.bodyWeight) {
    final repsSets = exerciseLog.sets.whereType<RepsSetDto>();
    if (repsSets.isEmpty) return 0;
    return repsSets.map((set) => set.reps).reduce((curr, next) => curr > next ? curr : next);
  } else if (exerciseType == ExerciseType.weights) {
    final weightSets = exerciseLog.sets.whereType<WeightAndRepsSetDto>();
    if (weightSets.isEmpty) return 0;
    return weightSets.map((set) => set.reps).reduce((curr, next) => curr > next ? curr : next);
  }

  return 0;
}

double heaviestVolumeForExerciseLog({required ExerciseLogDto exerciseLog}) {
  final weightSets = exerciseLog.sets.whereType<WeightAndRepsSetDto>();

  if (weightSets.isEmpty) return 0.0;

  return weightSets.map((set) => set.volume()).reduce((prev, element) => element > prev ? element : prev);
}

WeightAndRepsSetDto heaviestSetVolumeForExerciseLog({required ExerciseLogDto exerciseLog}) {
  final weightSets = exerciseLog.sets.whereType<WeightAndRepsSetDto>();

  if (weightSets.isEmpty) {
    return SetDto.newType(type: ExerciseType.weights) as WeightAndRepsSetDto;
  }

  return weightSets
      .reduce((heaviestSet, currentSet) => currentSet.volume() > heaviestSet.volume() ? currentSet : heaviestSet);
}

/// Highest value across all [ExerciseDto]

(String?, SetDto) heaviestSetVolume({required List<ExerciseLogDto> exerciseLogs}) {
  if (exerciseLogs.isEmpty) {
    return (null, SetDto.newType(type: ExerciseType.weights));
  }

  String? logId;
  SetDto? heaviestSet;
  double heaviestVolume = 0.0;

  for (final log in exerciseLogs) {
    final currentSet = heaviestSetVolumeForExerciseLog(exerciseLog: log);
    final currentVolume = currentSet.volume();
    if (currentVolume > heaviestVolume) {
      logId = log.routineLogId;
      heaviestVolume = currentVolume;
      heaviestSet = currentSet;
    }
  }

  return heaviestSet != null ? (logId, heaviestSet) : (null, SetDto.newType(type: ExerciseType.weights));
}

(String?, double) heaviestWeight({required List<ExerciseLogDto> exerciseLogs}) {
  String? logId;
  double heaviestWeight = 0.0;

  for (final log in exerciseLogs) {
    final heaviestSet = heaviestWeightInSetForExerciseLog(exerciseLog: log);
    final weight = heaviestSet.weight;
    if (weight > heaviestWeight) {
      logId = log.routineLogId;
      heaviestWeight = weight;
    }
  }

  return (logId, heaviestWeight);
}

(String?, int) mostRepsInSet({required List<ExerciseLogDto> exerciseLogs}) {
  String? logId;
  int highestReps = 0;

  for (final log in exerciseLogs) {
    final exerciseType = log.exercise.type;
    int logHighestReps = 0;

    if (exerciseType == ExerciseType.bodyWeight) {
      final repsSets = log.sets.whereType<RepsSetDto>();
      if (repsSets.isNotEmpty) {
        logHighestReps = repsSets.map((set) => set.reps).reduce((curr, next) => curr > next ? curr : next);
      }
    } else if (exerciseType == ExerciseType.weights) {
      final weightSets = log.sets.whereType<WeightAndRepsSetDto>();
      if (weightSets.isNotEmpty) {
        logHighestReps = weightSets.map((set) => set.reps).reduce((curr, next) => curr > next ? curr : next);
      }
    }

    if (logHighestReps > highestReps) {
      logId = log.routineLogId;
      highestReps = logHighestReps;
    }
  }

  return (logId, highestReps);
}

(String?, int) mostRepsInSession({required List<ExerciseLogDto> exerciseLogs}) {
  String? logId;
  int mostReps = 0;

  for (final log in exerciseLogs) {
    final totalReps = totalRepsForExerciseLog(exerciseLog: log);
    if (totalReps > mostReps) {
      logId = log.routineLogId;
      mostReps = totalReps;
    }
  }

  return (logId, mostReps);
}

(String?, Duration) longestDuration({required List<ExerciseLogDto> exerciseLogs}) {
  Duration longestDuration = Duration.zero;
  String? logId;

  for (final log in exerciseLogs) {
    final duration = longestDurationForExerciseLog(exerciseLog: log);
    if (duration > longestDuration) {
      logId = log.routineLogId;
      longestDuration = duration;
    }
  }

  return (logId, longestDuration);
}

List<PBDto> calculatePBs(
    {required List<ExerciseLogDto> pastExerciseLogs,
    required ExerciseType exerciseType,
    required ExerciseLogDto exerciseLog}) {
  List<PBDto> pbs = [];

  if (pastExerciseLogs.isNotEmpty && exerciseLog.sets.isNotEmpty) {
    if (withWeightsOnly(type: exerciseType)) {
      final pastHeaviestWeight = pastExerciseLogs
          .map((log) => heaviestWeightInSetForExerciseLog(exerciseLog: log))
          .map((set) => set.weight)
          .max;

      final currentHeaviestWeightSets =
          exerciseLog.sets.whereType<WeightAndRepsSetDto>().where((set) => (set).weight > pastHeaviestWeight);
      if (currentHeaviestWeightSets.isNotEmpty) {
        final heaviestWeightSet =
            currentHeaviestWeightSets.reduce((curr, next) => ((curr).volume()) > ((next).volume()) ? curr : next);
        pbs.add(PBDto(set: heaviestWeightSet, exercise: exerciseLog.exercise, pb: PBType.weight));
      }

      final pastHeaviestSetVolume = pastExerciseLogs.map((log) => heaviestVolumeForExerciseLog(exerciseLog: log)).max;

      final currentHeaviestVolumeSets =
          exerciseLog.sets.where((set) => ((set as WeightAndRepsSetDto).volume()) > pastHeaviestSetVolume);
      if (currentHeaviestVolumeSets.isNotEmpty) {
        final heaviestVolumeSet = currentHeaviestVolumeSets.reduce((curr, next) =>
            ((curr as WeightAndRepsSetDto).volume()) > ((next as WeightAndRepsSetDto).volume()) ? curr : next);
        pbs.add(PBDto(set: heaviestVolumeSet, exercise: exerciseLog.exercise, pb: PBType.volume));
      }
    }

    if (withDurationOnly(type: exerciseType)) {
      final pastLongestDuration = pastExerciseLogs.map((log) => longestDurationForExerciseLog(exerciseLog: log)).max;

      final currentLongestDurations =
          exerciseLog.sets.whereType<DurationSetDto>().where((set) => (set).duration > pastLongestDuration);
      if (currentLongestDurations.isNotEmpty) {
        final longestDurationSet =
            currentLongestDurations.reduce((curr, next) => (curr).duration > (next).duration ? curr : next);
        pbs.add(PBDto(set: longestDurationSet, exercise: exerciseLog.exercise, pb: PBType.duration));
      }
    }
  }

  return pbs;
}

TemplateChange? hasDifferentExerciseLogsLength(
    {required List<ExerciseLogDto> exerciseLogs1, required List<ExerciseLogDto> exerciseLogs2}) {
  return exerciseLogs2.length != exerciseLogs1.length ? TemplateChange.exerciseLogLength : null;
}

TemplateChange? hasReOrderedExercises(
    {required List<ExerciseLogDto> exerciseLogs1, required List<ExerciseLogDto> exerciseLogs2}) {
  final length = exerciseLogs1.length > exerciseLogs2.length ? exerciseLogs2.length : exerciseLogs1.length;
  for (int i = 0; i < length; i++) {
    if (exerciseLogs1[i].exercise.id != exerciseLogs2[i].exercise.id) {
      return TemplateChange.exerciseOrder; // Re-orderedList
    }
  }
  return null;
}

TemplateChange? hasDifferentSetsLength(
    {required List<ExerciseLogDto> exerciseLogs1, required List<ExerciseLogDto> exerciseLogs2}) {
  final exerciseLog1Sets = exerciseLogs1.expand((logs) => logs.sets);
  final exerciseLog2Sets = exerciseLogs2.expand((logs) => logs.sets);

  return exerciseLog1Sets.length != exerciseLog2Sets.length ? TemplateChange.setsLength : null;
}

TemplateChange? hasExercisesChanged({
  required List<ExerciseLogDto> exerciseLogs1,
  required List<ExerciseLogDto> exerciseLogs2,
}) {
  Set<String> exerciseIds1 = exerciseLogs1.map((p) => p.exercise.id).toSet();
  Set<String> exerciseIds2 = exerciseLogs2.map((p) => p.exercise.id).toSet();

  int changes = exerciseIds1.difference(exerciseIds2).length;

  return changes > 0 ? TemplateChange.exerciseLogChange : null;
}

TemplateChange? hasSuperSetIdChanged({
  required List<ExerciseLogDto> exerciseLogs1,
  required List<ExerciseLogDto> exerciseLogs2,
}) {
  Set<String> superSetIds1 =
      exerciseLogs1.map((p) => p.superSetId).where((superSetId) => superSetId.isNotEmpty).toSet();
  Set<String> superSetIds2 =
      exerciseLogs2.map((p) => p.superSetId).where((superSetId) => superSetId.isNotEmpty).toSet();

  final changes = superSetIds2.difference(superSetIds1).length;

  return changes > 0 ? TemplateChange.supersetId : null;
}

TemplateChange? hasCheckedSetsChanged(
    {required List<ExerciseLogDto> exerciseLogs1, required List<ExerciseLogDto> exerciseLogs2}) {
  final exerciseLog1CompletedSets = exerciseLogs1.expand((log) => log.sets).where((set) => set.checked).toList();
  final exerciseLog2CompletedSets = exerciseLogs2.expand((log) => log.sets).where((set) => set.checked).toList();

  if (exerciseLog1CompletedSets.length != exerciseLog2CompletedSets.length) {
    return TemplateChange.checkedSets;
  }

  return null;
}

TemplateChange? hasSetValueChanged({
  required List<ExerciseLogDto> exerciseLogs1,
  required List<ExerciseLogDto> exerciseLogs2,
}) {
  final exerciseLog1Volume = exerciseLogs1.expand((logs) => logs.sets).fold(0.0, (previousValue, set) {
    return switch (set.type) {
      ExerciseType.weights => previousValue + (set as WeightAndRepsSetDto).volume(),
      ExerciseType.bodyWeight => previousValue + (set as RepsSetDto).reps,
      ExerciseType.duration => previousValue + (set as DurationSetDto).duration.inMilliseconds,
    };
  });

  final exerciseLog2Volume = exerciseLogs2.expand((logs) => logs.sets).fold(0.0, (previousValue, set) {
    return switch (set.type) {
      ExerciseType.weights => previousValue + (set as WeightAndRepsSetDto).volume(),
      ExerciseType.bodyWeight => previousValue + (set as RepsSetDto).reps,
      ExerciseType.duration => previousValue + (set as DurationSetDto).duration.inMilliseconds,
    };
  });

  return exerciseLog1Volume != exerciseLog2Volume ? TemplateChange.setValue : null;
}

Map<MuscleGroupFamily, double> muscleGroupFamilyFrequency({
  required List<ExerciseLogDto> exerciseLogs,
  bool includeSecondaryMuscleGroups = true,
}) {
  if (exerciseLogs.isEmpty) return <MuscleGroupFamily, double>{};

  final frequencyMap = <MuscleGroupFamily, int>{};

  // Counting the occurrences of each MuscleGroup, excluding MuscleGroupFamily.fullBody
  for (final log in exerciseLogs) {
    final primaryFamily = log.exercise.primaryMuscleGroup.family;
    if (primaryFamily != MuscleGroupFamily.fullBody) {
      frequencyMap.update(primaryFamily, (value) => value + 1, ifAbsent: () => 1);
    }

    if (includeSecondaryMuscleGroups) {
      for (var muscleGroup in log.exercise.secondaryMuscleGroups) {
        final secondaryFamily = muscleGroup.family;
        if (secondaryFamily != MuscleGroupFamily.fullBody) {
          frequencyMap.update(secondaryFamily, (value) => value + 1, ifAbsent: () => 1);
        }
      }
    }
  }

  if(frequencyMap.isEmpty) return <MuscleGroupFamily, double>{};

  final totalCount = frequencyMap.values.reduce((a, b) => a + b);
  final scaledFrequencyMap = <MuscleGroupFamily, double>{};

  // Scaling the frequencies from 0 to 1
  frequencyMap.forEach((key, value) {
    scaledFrequencyMap[key] = value / totalCount;
  });

  final sortedEntries = scaledFrequencyMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

  final sortedFrequencyMap = LinkedHashMap<MuscleGroupFamily, double>.fromEntries(sortedEntries);
  return sortedFrequencyMap;
}

Map<MuscleGroupFamily, int> _muscleGroupFamilyCountOn4WeeksScale({
  required List<ExerciseLogDto> exerciseLogs,
}) {
  final frequencyMap = <MuscleGroupFamily, int>{};

  final exerciseLogsByDay = groupBy(exerciseLogs, (log) => log.createdAt.day);

  // Counting the occurrences of each MuscleGroup
  for (var logAndDate in exerciseLogsByDay.entries) {
    final primaryMuscleGroupFamilies = logAndDate.value
        .map((log) => log.exercise.primaryMuscleGroup.family)
        .where((family) => family != MuscleGroupFamily.fullBody);

    final muscleGroupFamilies = {...primaryMuscleGroupFamilies};

    // We don't report these muscle groups
    muscleGroupFamilies.remove(MuscleGroupFamily.neck);

    for (var family in muscleGroupFamilies) {
      frequencyMap.update(family, (value) => value >= 8 ? 8 : value + 1, ifAbsent: () => 1);
    }
  }

  return frequencyMap;
}

Map<MuscleGroupFamily, double> muscleGroupFamilyFrequencyOn4WeeksScale({required List<ExerciseLogDto> exerciseLogs}) {
  final frequencyMap = _muscleGroupFamilyCountOn4WeeksScale(exerciseLogs: exerciseLogs);

  final scaledFrequencyMap = <MuscleGroupFamily, double>{};

  // Scaling the frequencies from 0 to 1
  frequencyMap.forEach((key, value) {
    final scaledValue = value / 8;
    scaledFrequencyMap[key] = scaledValue > 1 ? 1 : scaledValue;
  });

  final sortedEntries = scaledFrequencyMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

  final sortedFrequencyMap = LinkedHashMap<MuscleGroupFamily, double>.fromEntries(sortedEntries);

  return sortedFrequencyMap;
}

double cumulativeMuscleGroupFamilyFrequency({required List<ExerciseLogDto> exerciseLogs}) {
  final frequencyEntries = _muscleGroupFamilyCountOn4WeeksScale(exerciseLogs: exerciseLogs).entries;

  final frequencyMap = Map.fromEntries(frequencyEntries);

  final cumulativeFrequency = frequencyMap.entries.map((entry) => entry.value).sum;

  return cumulativeFrequency / 48;
}

bool withWeightsOnly({required ExerciseType type}) {
  return type == ExerciseType.weights;
}

bool withReps({required ExerciseType type}) {
  return type == ExerciseType.weights || type == ExerciseType.bodyWeight;
}

bool withRepsOnly({required ExerciseType type}) {
  return type == ExerciseType.bodyWeight;
}

bool withDurationOnly({required ExerciseType type}) {
  return type == ExerciseType.duration;
}

int _calculateMuscleScore({required List<ExerciseLogDto> exerciseLogs}) {
  final muscleGroupsFrequencyScore = cumulativeMuscleGroupFamilyFrequency(exerciseLogs: exerciseLogs);

  final percentageScore = (muscleGroupsFrequencyScore * 100).round();

  return percentageScore;
}

List<ExerciseLogDto> loggedExercises({required List<ExerciseLogDto> exerciseLogs}) {
  return exerciseLogs.where((exerciseLog) {
    final completedSets = exerciseLog.sets.where((set) => set.isNotEmpty() && set.checked);
    return completedSets.isNotEmpty;
  }).map((log) {
    final sets = log.sets.where((set) => set.isNotEmpty() && set.checked).toList();
    return log.copyWith(sets: sets);
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

(int, int) getRepRange({required ExerciseLogDto exerciseLog}) {

  final sets = exerciseLog.sets;

  final exerciseType = exerciseLog.exercise.type;

  final maxReps = exerciseLog.maxReps <= 0
      ? sets.isNotEmpty
      ? sets.map((set) {
    return switch (exerciseType) {
      ExerciseType.weights => (set as WeightAndRepsSetDto).reps,
      ExerciseType.bodyWeight => (set as RepsSetDto).reps,
      ExerciseType.duration => 0,
    };
  }).max
      : 10
      : exerciseLog.maxReps;

  final minReps = exerciseLog.minReps <= 0
      ? maxReps > 5
      ? maxReps - 2
      : 1
      : exerciseLog.minReps;

  return (minReps, maxReps);
}