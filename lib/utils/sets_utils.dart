import 'package:collection/collection.dart';

import '../dtos/set_dto.dart';

List<SetDto> personalBestSets({required List<SetDto> sets}) {
  var groupedByReps = groupBy(sets, (set) => set.value2);

  final setsWithHeaviestWeight = <SetDto>[];

  for (var group in groupedByReps.entries) {
    final weights = group.value.map((set) => set.value1);
    final heaviestWeight = weights.max;
    setsWithHeaviestWeight.add(SetDto(heaviestWeight, group.key, false));
  }

  // Sort by value2
  setsWithHeaviestWeight.sort((a, b) => a.value2.compareTo(b.value2));

  return setsWithHeaviestWeight;
}

SetDto heaviestSet({required List<SetDto> sets}) {

  SetDto maxSet = sets[0];
  num maxVolume = sets[0].value1 * sets[0].value2;

  for (SetDto set in sets) {
    num currentSet = set.value1 * set.value2;
    if (currentSet > maxVolume) {
      maxVolume = currentSet;
      maxSet = set;
    }
  }

  return maxSet;
}

SetDto longestDurationSet({required List<SetDto> sets}) {

  SetDto longestSet = sets[0];
  num longestDuration = sets[0].value1;

  for (SetDto set in sets) {
    num currentSet = set.value1;
    if (currentSet > longestDuration) {
      longestDuration = currentSet;
      longestSet = set;
    }
  }

  return longestSet;
}