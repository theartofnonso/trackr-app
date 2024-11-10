import 'package:collection/collection.dart';

import '../dtos/set_dto.dart';

List<SetDto> personalBestSets({required List<SetDto> sets}) {
  var groupedByReps = groupBy(sets, (set) => set.reps());

  final setsWithHeaviestWeight = <SetDto>[];

  for (var group in groupedByReps.entries) {
    final weights = group.value.map((set) => set.weight());
    final heaviestWeight = weights.max;
    setsWithHeaviestWeight.add(SetDto(heaviestWeight, group.key, false));
  }

  // Sort by value2
  setsWithHeaviestWeight.sort((a, b) => a.reps().compareTo(b.reps()));

  return setsWithHeaviestWeight;
}