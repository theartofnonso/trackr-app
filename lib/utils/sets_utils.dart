import 'package:collection/collection.dart';

import '../dtos/exercise_log_dto.dart';
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
      ExerciseType.weights => "Set ${index + 1}: ${exerciseLog.sets[index].summary()}",
      ExerciseType.bodyWeight => "Set ${index + 1}: ${exerciseLog.sets[index].summary()}",
      ExerciseType.duration => "Set ${index + 1}: ${exerciseLog.sets[index].summary()}",
    };
  }).toList();
  return setSummaries;
}