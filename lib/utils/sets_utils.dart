import 'package:collection/collection.dart';

import '../dtos/set_dto.dart';

List<SetDTO> personalBestSets({required List<SetDTO> sets}) {
  var groupedByReps = groupBy(sets, (set) => set.reps());

  final setsWithHeaviestWeight = <SetDTO>[];

  for (var group in groupedByReps.entries) {
    final weights = group.value.map((set) => set.weight());
    final heaviestWeight = weights.max;
    setsWithHeaviestWeight.add(SetDTO(heaviestWeight, group.key, false));
  }

  // Sort by value2
  setsWithHeaviestWeight.sort((a, b) => a.reps().compareTo(b.reps()));

  return setsWithHeaviestWeight;
}