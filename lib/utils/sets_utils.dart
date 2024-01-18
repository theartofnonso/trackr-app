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

SetDto heaviestSetVolume({required List<SetDto> sets}) {

  double heaviestVolume = 0;
  SetDto heaviestSet = const SetDto(0, 0, false);

      longestDuration = currentSet;
  for (final set in sets) {
    final num volume = set.value1 * set.value2;

    if (volume > heaviestVolume) {
      heaviestVolume = volume.toDouble();
      heaviestSet = set;
    }
  }

  return heaviestSet;
}