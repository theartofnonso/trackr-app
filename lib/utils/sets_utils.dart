import 'package:collection/collection.dart';
import 'package:tracker_app/dtos/set_dtos/duration_set_dto.dart';

import '../dtos/exercise_log_dto.dart';
import '../dtos/set_dtos/reps_dto.dart';
import '../dtos/set_dtos/set_dto.dart';
import '../dtos/set_dtos/weight_and_reps_dto.dart';
import '../enums/exercise_type_enums.dart';

List<SetDto> personalBestSets({required List<SetDto> sets}) {
  final groupedByReps = groupBy(sets, (set) => (set as WeightAndRepsSetDto).reps);

  final setsWithHeaviestWeight = <SetDto>[];

  for (var group in groupedByReps.entries) {
    final weights = group.value.map((set) => (set as WeightAndRepsSetDto).weight);
    final heaviestWeight = weights.max;
    setsWithHeaviestWeight.add(WeightAndRepsSetDto(weight: heaviestWeight, reps: group.key, checked: false));
  }

  // Sort by value2
  setsWithHeaviestWeight.sort((a, b) => (a as WeightAndRepsSetDto).reps.compareTo((b as WeightAndRepsSetDto).reps));

  return setsWithHeaviestWeight;
}

List<String> generateSetSummaries(ExerciseLogDto exerciseLog) {
  final setSummaries = exerciseLog.sets.mapIndexed((index, set) {
    return switch (exerciseLog.exercise.type) {
      ExerciseType.weights =>
        "Set ${index + 1}: ${exerciseLog.sets[index].summary()} and Rate of Perceived Exertion is ${exerciseLog.sets[index].rpeRating}",
      ExerciseType.bodyWeight =>
        "Set ${index + 1}: ${exerciseLog.sets[index].summary()} and Rate of Perceived Exertion is ${exerciseLog.sets[index].rpeRating}",
      ExerciseType.duration =>
        "Set ${index + 1}: ${exerciseLog.sets[index].summary()} and Rate of Perceived Exertion is ${exerciseLog.sets[index].rpeRating}",
    };
  }).toList();
  return setSummaries;
}

List<WeightAndRepsSetDto> markHighestWeightSets(List<SetDto> sets) {
  // Extract all WeightAndRepsSetDto instances and find max weight

  if (sets.isEmpty) return [];

  final weightsSets = sets.map((set) => set as WeightAndRepsSetDto);

  final maxWeight = weightsSets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);

  // Map original list and update working sets
  return weightsSets.map((set) {
    return WeightAndRepsSetDto(
        weight: set.weight,
        reps: set.reps,
        checked: set.checked,
        rpeRating: set.rpeRating,
        isWorkingSet: set.weight == maxWeight);
  }).toList();
}

List<RepsSetDto> markHighestRepsSets(List<SetDto> sets) {
  // Extract all RepsSetDto instances and find max weight

  if (sets.isEmpty) return [];

  final repsSets = sets.map((set) => set as RepsSetDto);

  final maxReps = repsSets.map((s) => s.reps).reduce((a, b) => a > b ? a : b);

  // Map original list and update working sets
  return repsSets.map((set) {
    return RepsSetDto(
        reps: set.reps,
        checked: set.checked,
        rpeRating: set.rpeRating,
        isWorkingSet: set.reps == maxReps);
  }).toList();
}

List<DurationSetDto> markHighestDurationSets(List<SetDto> sets) {
  // Extract all DurationSetDto instances and find max weight

  if (sets.isEmpty) return [];

  final durationSets = sets.map((set) => set as DurationSetDto);

  final maxDuration = durationSets.map((s) => s.duration).reduce((a, b) => a > b ? a : b);

  // Map original list and update working sets
  return durationSets.map((set) {
    return DurationSetDto(
        duration: set.duration,
        checked: set.checked,
        rpeRating: set.rpeRating,
        isWorkingSet: set.duration == maxDuration);
  }).toList();
}
