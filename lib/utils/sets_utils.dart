import 'package:collection/collection.dart';
import 'package:tracker_app/dtos/weight_and_reps_set_dto.dart';

import '../dtos/set_dto.dart';

List<SetDTO> personalBestSets({required List<SetDTO> sets}) {
  var groupedByReps = groupBy(sets, (set) => (set as WeightAndRepsSetDTO).reps);

  final setsWithHeaviestWeight = <SetDTO>[];

  for (var group in groupedByReps.entries) {
    final weights = group.value.map((set) => (set as WeightAndRepsSetDTO).weight);
    final heaviestWeight = weights.max;
    setsWithHeaviestWeight.add(WeightAndRepsSetDTO(weight: heaviestWeight, reps: group.key, checked: false));
  }

  // Sort by value2
  setsWithHeaviestWeight.sort((a, b) => (a as WeightAndRepsSetDTO).reps.compareTo((b as WeightAndRepsSetDTO).reps));

  return setsWithHeaviestWeight;
}