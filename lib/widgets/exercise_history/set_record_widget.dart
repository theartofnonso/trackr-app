import 'package:flutter/cupertino.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/dtos/weight_and_reps_set_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_metrics_enums.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../enums/routine_preview_type_enum.dart';
import '../../utils/sets_utils.dart';
import '../routine/preview/set_headers/double_set_header.dart';
import '../routine/preview/set_rows/double_set_row.dart';

class SetRecordWidget extends StatelessWidget {
  final SetType exerciseMetric;
  final List<SetDTO> sets;

  const SetRecordWidget({super.key, required this.exerciseMetric, required this.sets});

  @override
  Widget build(BuildContext context) {
    final personaBestSets = personalBestSets(sets: sets);

    if (personaBestSets.isEmpty) {
      personaBestSets.add(SetDTO.newType(type: exerciseMetric));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DoubleSetHeader(firstLabel: "Reps", secondLabel: 'Personal Best (${weightLabel().toUpperCase()})', routinePreviewType: RoutinePreviewType.log),
        const SizedBox(height: 8),
        ...personaBestSets.map((set) {
          final firstLabel = (set as WeightAndRepsSetDTO).reps;
          final secondLabel = set.weight;
          return DoubleSetRow(first: "$firstLabel", second: "$secondLabel", margin: const EdgeInsets.only(bottom: 6.0), routinePreviewType: RoutinePreviewType.log,);
        }),
      ],
    );
  }
}
