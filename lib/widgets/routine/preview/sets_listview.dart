import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/set_dtos/duration_set_dto.dart';
import 'package:tracker_app/dtos/set_dtos/reps_dto.dart';
import 'package:tracker_app/dtos/set_dtos/weight_and_reps_dto.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';
import 'package:tracker_app/widgets/routine/preview/set_rows/double_set_row.dart';
import 'package:tracker_app/widgets/routine/preview/set_rows/single_set_row.dart';

import '../../../dtos/pb_dto.dart';
import '../../../dtos/set_dtos/set_dto.dart';
import '../../../enums/exercise_type_enums.dart';

class SetsListview extends StatelessWidget {
  final ExerciseType type;
  final List<SetDto> sets;
  final List<PBDto> pbs;

  const SetsListview({super.key, required this.type, required this.sets, this.pbs = const []});

  @override
  Widget build(BuildContext context) {
    if (sets.isEmpty) {
      return Center(
          child: SizedBox(
            width: double.infinity,
            child: OpacityButtonWidget(
                label: "No Sets have been logged for this exercise",
                buttonColor: Colors.deepOrange,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
          ));
    }

    final pbsBySet = groupBy(pbs, (pb) => pb.set);

    return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final set = sets[index];
          final pbsForSet = pbsBySet[set] ?? [];
          switch (set.type) {
            case ExerciseType.weights:
              final firstLabel = (set as WeightAndRepsSetDto).weight;
              final secondLabel = set.reps;
              return DoubleSetRow(
                  first: "$firstLabel", second: "$secondLabel", pbs: pbsForSet);
            case ExerciseType.bodyWeight:
              final label = (set as RepsSetDto).reps;
              return SingleSetRow(label: "$label");
            case ExerciseType.duration:
              final label = (set as DurationSetDto).duration.hmsDigital();
              return SingleSetRow(label: label, pbs: pbsForSet);
          }
        },
        separatorBuilder: (context, index) => SizedBox(height: 8),
        itemCount: sets.length);
  }
}
