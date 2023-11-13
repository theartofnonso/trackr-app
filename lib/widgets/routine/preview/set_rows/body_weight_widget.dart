import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/weighted_set_dto.dart';
import 'package:tracker_app/widgets/routine/preview/set_rows/set_text.dart';
import 'package:tracker_app/widgets/routine/preview/set_type_icon.dart';

import '../../../../app_constants.dart';

class BodyWeightWidget extends StatelessWidget {
  const BodyWeightWidget({super.key, required this.index, required this.workingIndex, required this.setDto});

  final int index;
  final int workingIndex;
  final WeightedSetDto setDto;

  @override
  Widget build(BuildContext context) {

    return ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        tileColor: tealBlueLight,
        leading: SetTypeIcon(type: setDto.type, label: workingIndex),
        dense: true,
        title: Row(
          children: [
            SetText(label: "REPS", number: setDto.second),
          ],
        ));
  }
}
