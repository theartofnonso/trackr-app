import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/widgets/routine/preview/set_rows/double_set_row.dart';
import 'package:tracker_app/widgets/routine/preview/set_rows/single_set_row.dart';

import '../../../dtos/pb_dto.dart';
import '../../../dtos/set_dto.dart';
import '../../../enums/exercise_type_enums.dart';

class SetsListview extends StatelessWidget {
  final ExerciseType type;
  final List<SetDto> sets;
  final List<PBDto> pbs;

  const SetsListview({super.key, required this.type, required this.sets, this.pbs = const []});

  @override
  Widget build(BuildContext context) {

    const margin = EdgeInsets.only(bottom: 6.0);

    final pbsBySet = groupBy(pbs, (pb) => pb.set);

    final widgets = sets.map(((setDto) {
      final pbsForSet = pbsBySet[setDto] ?? [];

      switch (type) {
        case ExerciseType.weights:
          final firstLabel = setDto.weight();
          final secondLabel = setDto.reps();
          return DoubleSetRow(first: "$firstLabel", second: "$secondLabel", margin: margin, pbs: pbsForSet);
        case ExerciseType.bodyWeight:
          final label = setDto.reps();
          return SingleSetRow(label: "$label", margin: margin);
        case ExerciseType.duration:
          final label = Duration(milliseconds: setDto.duration()).hmsAnalog();
          return SingleSetRow(label: label, margin: margin, pbs: pbsForSet);
      }
    })).toList();

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets);
  }
}
