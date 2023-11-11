import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/weight_reps_dto.dart';
import 'package:tracker_app/widgets/routine/preview/sets/set_text.dart';
import 'package:tracker_app/widgets/routine/preview/sets/set_type_icon.dart';

import '../../../../app_constants.dart';
import '../../../../utils/general_utils.dart';

class WeightRepsWidget extends StatelessWidget {
  const WeightRepsWidget({super.key, required this.index, required this.workingIndex, required this.setDto});

  final int index;
  final int workingIndex;
  final WeightRepsDto setDto;

  @override
  Widget build(BuildContext context) {
    final weight = isDefaultWeightUnit() ? setDto.weight : toLbs(setDto.weight);

    return ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        tileColor: tealBlueLight,
        leading: SetTypeIcon(type: setDto.type, label: workingIndex),
        dense: true,
        title: Row(
          children: [
            SetText(label: weightLabel().toUpperCase(), number: weight),
            const SizedBox(width: 10),
            SetText(label: "REPS", number: setDto.reps),
          ],
        ));
  }
}