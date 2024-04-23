import 'package:collection/collection.dart';

import '../dtos/set_dto.dart';

List<SetDto> personalBestSets({required List<SetDto> sets}) {
  var groupedByReps = groupBy(sets, (set) => set.repsValue());

  final setsWithHeaviestWeight = <SetDto>[];

  for (var group in groupedByReps.entries) {
    final weights = group.value.map((set) => set.weightValue());
    final heaviestWeight = weights.max;
    setsWithHeaviestWeight.add(SetDto(value1: heaviestWeight, value2: group.key, checked: false));
  }

  // Sort by value2
  setsWithHeaviestWeight.sort((a, b) => a.repsValue().compareTo(b.repsValue()));

  return setsWithHeaviestWeight;
}