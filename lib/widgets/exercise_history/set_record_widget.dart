import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../routine/preview/set_headers/double_set_header.dart';
import '../routine/preview/set_rows/double_set_row.dart';

class SetRecordWidget extends StatelessWidget {
  final ExerciseType exerciseType;
  final List<SetDto> sets;

  const SetRecordWidget({super.key, required this.exerciseType, required this.sets});

  @override
  Widget build(BuildContext context) {

    final personaBestSets = personalBestSets();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DoubleSetHeader(firstLabel: "Reps", secondLabel: 'Personal Best (${weightLabel().toUpperCase()})'),
        const SizedBox(height: 8),
        ...personaBestSets.map((set) {
          final firstLabel = set.value2;
          final secondLabel = isDefaultWeightUnit() ? set.value1 : toLbs(set.value1.toDouble());
          return DoubleSetRow(first: "$firstLabel", second: "$secondLabel", margin: const EdgeInsets.only(bottom: 6.0));
        }).toList(),
      ],
    );
  }

  List<SetDto> personalBestSets() {
    var groupedByReps = groupBy(sets, (set) => set.value2);

    final setsWithHeaviestWeight = <SetDto>[];

    for (var group in groupedByReps.entries) {
      final weights = group.value.map((set) => set.value1);
      final heaviestWeight = weights.max;
      setsWithHeaviestWeight.add(SetDto(heaviestWeight, group.key, false));
    }

    // Sort by value2
    setsWithHeaviestWeight.sort((a, b) => b.value2.compareTo(a.value2));

    return setsWithHeaviestWeight;
  }
}
