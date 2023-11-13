import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/weighted_set_dto.dart';
import 'package:tracker_app/widgets/routine/preview/set_rows/set_text.dart';
import 'package:tracker_app/widgets/routine/preview/set_type_icon.dart';

import '../../../../app_constants.dart';
import '../../../../utils/general_utils.dart';

class WeightDistanceWidget extends StatelessWidget {
  const WeightDistanceWidget({super.key, required this.index, required this.workingIndex, required this.setDto});

  final int index;
  final int workingIndex;
  final WeightedSetDto setDto;

  @override
  Widget build(BuildContext context) {
    final weight = isDefaultWeightUnit() ? setDto.first : toLbs(setDto.first.toDouble());
    final distance = isDefaultDistanceUnit() ? setDto.second : setDto.second;

    return ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        tileColor: tealBlueLight,
        leading: SetTypeIcon(type: setDto.type, label: workingIndex),
        dense: true,
        title: Row(
          children: [
            SetText(label: weightLabel().toUpperCase(), number: weight),
            const SizedBox(width: 10),
            SetText(label: distanceLabel(), number: distance),
          ],
        ));
  }
}
