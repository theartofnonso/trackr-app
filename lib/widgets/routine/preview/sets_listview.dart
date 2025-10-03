import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/set_dtos/duration_set_dto.dart';
import 'package:tracker_app/dtos/set_dtos/reps_dto.dart';
import 'package:tracker_app/dtos/set_dtos/weight_and_reps_dto.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/utils/sets_utils.dart';
import 'package:tracker_app/widgets/routine/preview/set_rows/double_set_row.dart';
import 'package:tracker_app/widgets/routine/preview/set_rows/single_set_row.dart';
import 'package:tracker_app/widgets/routine/set_mode_badge.dart';

import '../../../dtos/pb_dto.dart';
import '../../../dtos/set_dtos/set_dto.dart';
import '../../../enums/exercise_type_enums.dart';

class SetsListview extends StatelessWidget {
  final ExerciseType type;
  final List<SetDto> sets;
  final List<PBDto> pbs;

  const SetsListview(
      {super.key, required this.type, required this.sets, this.pbs = const []});

  @override
  Widget build(BuildContext context) {
    final workingSets = switch (type) {
      ExerciseType.weights => markHighestWeightSets(sets),
      ExerciseType.bodyWeight => markHighestRepsSets(sets),
      ExerciseType.duration => markHighestDurationSets(sets),
    };

    final pbsBySet = groupBy(pbs, (pb) => pb.set);

    final children = sets.mapIndexed((index, set) {
      final set = sets[index];
      final workingSet = workingSets[index];
      final pbsForSet = pbsBySet[set] ?? [];
      switch (set.type) {
        case ExerciseType.weights:
          final firstLabel = (set as WeightAndRepsSetDto).weight;
          final secondLabel = set.reps;
          return SetModeBadge(
            setDto: (workingSet as WeightAndRepsSetDto?) ?? set,
            child: DoubleSetRow(
                first: "$firstLabel", second: "$secondLabel", pbs: pbsForSet),
          );
        case ExerciseType.bodyWeight:
          final label = (set as RepsSetDto).reps;
          return SetModeBadge(
              setDto: (workingSet as RepsSetDto?) ?? set,
              child: SingleSetRow(label: "$label"));
        case ExerciseType.duration:
          final label = (set as DurationSetDto).duration.hmsDigital();
          return SetModeBadge(
              setDto: (workingSet as DurationSetDto?) ?? set,
              child: SingleSetRow(label: label, pbs: pbsForSet));
      }
    }).toList();

    return Column(spacing: 8, children: children);
  }
}
