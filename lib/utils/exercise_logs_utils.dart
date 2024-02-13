import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../dtos/exercise_dto.dart';
import '../dtos/exercise_log_dto.dart';
import '../dtos/pb_dto.dart';
import '../dtos/set_dto.dart';
import '../enums/exercise_type_enums.dart';
import '../enums/muscle_group_enums.dart';
import '../enums/pb_enums.dart';
import '../enums/template_changes_type_message_enums.dart';

/// Highest value per [ExerciseLogDto]

SetDto heaviestSetWeightForExerciseLog({required ExerciseLogDto exerciseLog}) {
  if (exerciseLog.sets.isEmpty) {
    return const SetDto(0, 0, false);
  }

  return exerciseLog.sets.reduce((SetDto currentHeaviest, SetDto nextSet) =>
      (nextSet.weightValue() > currentHeaviest.weightValue()) ? nextSet : currentHeaviest);
}

Duration longestDurationForExerciseLog({required ExerciseLogDto exerciseLog}) {
  return exerciseLog.sets
      .map((set) => Duration(milliseconds: set.durationValue()))
      .fold(Duration.zero, (max, duration) => duration > max ? duration : max);
}

Duration totalDurationExerciseLog({required ExerciseLogDto exerciseLog}) {
  return exerciseLog.sets.fold<Duration>(
    Duration.zero,
    (total, set) => total + Duration(milliseconds: set.durationValue()),
  );
}

int totalRepsForExerciseLog({required ExerciseLogDto exerciseLog}) =>
    exerciseLog.sets.fold(0, (total, set) => total + set.repsValue());

int highestRepsForExerciseLog({required ExerciseLogDto exerciseLog}) {
  if (exerciseLog.sets.isEmpty) return 0;

  return exerciseLog.sets.map((set) => set.repsValue()).reduce((curr, next) => curr > next ? curr : next).toInt();
}

double heaviestVolumeForExerciseLog({required ExerciseLogDto exerciseLog}) {
  return exerciseLog.sets
      .map((set) => set.volume())
      .fold(0.0, (prev, element) => element > prev ? element : prev);
}

SetDto heaviestSetVolumeForExerciseLog({required ExerciseLogDto exerciseLog}) {
  // Check if there are no sets in the exercise log
  if (exerciseLog.sets.isEmpty) {
    return const SetDto(0, 0, false);
  }

  double heaviestVolume = 0;
  SetDto heaviestSet = const SetDto(0, 0, false);

  for (final set in exerciseLog.sets) {
    final volume = set.volume();

    if (volume > heaviestVolume) {
      heaviestVolume = volume;
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

(String?, double) heaviestWeight({required List<ExerciseLogDto> exerciseLogs}) {
  double heaviestWeight = 0;
  String? logId;
  if (exerciseLogs.isNotEmpty) {
    heaviestWeight = exerciseLogs.first.sets.first.weightValue();
    logId = exerciseLogs.first.routineLogId;
    for (var log in exerciseLogs) {
      final weight = heaviestSetWeightForExerciseLog(exerciseLog: log).weightValue();
      if (weight > heaviestWeight) {
        heaviestWeight = weight;
        logId = log.routineLogId;
      }
    }
  }
  return (logId, heaviestWeight);
}

(String?, int) mostRepsInSet({required List<ExerciseLogDto> exerciseLogs}) {
  int highestReps = 0;
  String? logId;
  if (exerciseLogs.isNotEmpty) {
    highestReps = exerciseLogs.first.sets.first.repsValue().toInt();
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

(String?, int) mostRepsInSession({required List<ExerciseLogDto> exerciseLogs}) {
  int mostReps = 0;
  String? logId;
  if (exerciseLogs.isNotEmpty) {
    mostReps = exerciseLogs.first.sets.first.repsValue().toInt();
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
    longestDuration = Duration(milliseconds: exerciseLogs.first.sets.first.durationValue().toInt());
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
    {required List<ExerciseLogDto> pastExerciseLogs,
    required ExerciseType exerciseType,
    required ExerciseLogDto exerciseLog}) {
  List<PBDto> pbs = [];

  if (pastExerciseLogs.isNotEmpty && exerciseLog.sets.isNotEmpty) {
    if (withWeightsOnly(type: exerciseType)) {
      final pastHeaviestWeight =
          pastExerciseLogs.map((log) => heaviestSetWeightForExerciseLog(exerciseLog: log)).map((set) => set.weightValue()).max;
      final pastHeaviestSetVolume = pastExerciseLogs.map((log) => heaviestVolumeForExerciseLog(exerciseLog: log)).max;

      final currentHeaviestWeightSets = exerciseLog.sets.where((set) => set.weightValue() > pastHeaviestWeight);
      if (currentHeaviestWeightSets.isNotEmpty) {
        final heaviestWeightSet = currentHeaviestWeightSets
            .reduce((curr, next) => (curr.volume()) > (next.volume()) ? curr : next);
        pbs.add(PBDto(set: heaviestWeightSet, exercise: exerciseLog.exercise, pb: PBType.weight));
      }

      final currentHeaviestVolumeSets =
          exerciseLog.sets.where((set) => (set.volume()) > pastHeaviestSetVolume);
      if (currentHeaviestVolumeSets.isNotEmpty) {
        final heaviestVolumeSet = currentHeaviestVolumeSets
            .reduce((curr, next) => (curr.volume()) > (next.volume()) ? curr : next);
        pbs.add(PBDto(set: heaviestVolumeSet, exercise: exerciseLog.exercise, pb: PBType.volume));
      }
    }

    if (withDurationOnly(type: exerciseType)) {
      final pastLongestDuration = pastExerciseLogs.map((log) => longestDurationForExerciseLog(exerciseLog: log)).max;

      final currentLongestDurations =
          exerciseLog.sets.where((set) => Duration(milliseconds: set.durationValue()) > pastLongestDuration);
      if (currentLongestDurations.isNotEmpty) {
        final longestDurationSet = currentLongestDurations.reduce((curr, next) =>
            Duration(milliseconds: curr.durationValue()) > Duration(milliseconds: next.durationValue()) ? curr : next);
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
  final exerciseLog1Volume = exerciseLogs1
      .expand((logs) => logs.sets)
      .fold(0.0, (previousValue, set) => previousValue + (set.volume()));
  final exerciseLog2Volume = exerciseLogs2
      .expand((logs) => logs.sets)
      .fold(0.0, (previousValue, set) => previousValue + (set.volume()));

  return exerciseLog1Volume != exerciseLog2Volume ? TemplateChange.setValue : null;
}

List<ExerciseLogDto> exerciseLogsWithCheckedSets({required List<ExerciseLogDto> exerciseLogs}) {
  return exerciseLogs
      .map((exerciseLog) {
        final completedSets = exerciseLog.sets.where((set) => set.isNotEmpty() && set.checked).toList();
        return completedSets.isNotEmpty ? exerciseLog.copyWith(sets: completedSets) : null;
      })
      .whereType<ExerciseLogDto>()
      .toList();
}

Map<MuscleGroupFamily, int> _muscleGroupFamilyFrequencies({required List<ExerciseLogDto> exerciseLogs}) {

  final frequencyMap = <MuscleGroupFamily, int>{};

  final exerciseLogsBySession = groupBy(exerciseLogs, (log) => log.routineLogId);

  // Counting the occurrences of each MuscleGroup
  for (var logAndDate in exerciseLogsBySession.entries) {
    final muscleGroupFamilies = logAndDate.value.map((log) => log.exercise.primaryMuscleGroup.family).toSet();
    for (var family in muscleGroupFamilies) {
      frequencyMap.update(family, (value) => value > 8 ? 8 : value + 1, ifAbsent: () => 1);
    }
  }

  return frequencyMap;
}

Map<MuscleGroupFamily, double> weeklyScaledMuscleGroupFamilyFrequencies({required List<ExerciseLogDto> exerciseLogs}) {

  final frequencyMap = _muscleGroupFamilyFrequencies(exerciseLogs: exerciseLogs);

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

double cumulativeMuscleGroupFamilyFrequencies({required List<ExerciseLogDto> exerciseLogs}) {
  final frequencyEntries = _muscleGroupFamilyFrequencies(exerciseLogs: exerciseLogs).entries.where((entry) => popularMuscleGroupFamilies().contains(entry.key));

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