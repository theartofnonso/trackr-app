import 'package:flutter/cupertino.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/widgets/information_container_lite.dart';

import '../../utils/sets_utils.dart';
import '../routine/preview/set_headers/double_set_header.dart';
import '../routine/preview/set_rows/double_set_row.dart';

class SetRecordWidget extends StatelessWidget {
  final ExerciseType exerciseType;
  final List<SetDto> sets;

  const SetRecordWidget({super.key, required this.exerciseType, required this.sets});

  @override
  Widget build(BuildContext context) {
    final personaBestSets = personalBestSets(sets: sets);

    if (personaBestSets.isEmpty) {
      return const InformationContainerLite(
          content:
              "You haven't logged any sessions for this exercise yet. Your personal bests will be displayed here once you begin tracking them",
          color: sapphireBlue);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DoubleSetHeader(firstLabel: "Reps", secondLabel: 'Personal Best (${weightLabel().toUpperCase()})'),
        const SizedBox(height: 8),
        ...personaBestSets.map((set) {
          final firstLabel = set.repsValue();
          final secondLabel = weightWithConversion(value: set.weightValue());
          return DoubleSetRow(first: "$firstLabel", second: "$secondLabel", margin: const EdgeInsets.only(bottom: 6.0));
        }).toList(),
      ],
    );
  }
}
