import 'package:flutter/cupertino.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/utils/general_utils.dart';

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
      personaBestSets.add(const SetDto(0, 0, false));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DoubleSetHeader(firstLabel: "Reps", secondLabel: 'Personal Best (${weightLabel().toUpperCase()})'),
        const SizedBox(height: 8),
        ...personaBestSets.map((set) {
          final firstLabel = set.repsValue();
          final secondLabel = weightWithConversion(value: set.weightValue());
          return DoubleSetRow(first: "$firstLabel", second: "$secondLabel", margin: const EdgeInsets.only(bottom: 6.0));
        }),
      ],
    );
  }
}
