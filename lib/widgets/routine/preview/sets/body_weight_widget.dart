import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/weight_reps_dto.dart';
import 'package:tracker_app/widgets/routine/preview/sets/set_text.dart';
import 'package:tracker_app/widgets/routine/preview/sets/set_type_icon.dart';

import '../../../../app_constants.dart';

class BodyWeightWidget extends StatelessWidget {
  const BodyWeightWidget({super.key, required this.index, required this.workingIndex, required this.setDto});

  final int index;
  final int workingIndex;
  final WeightRepsDto setDto;

  @override
  Widget build(BuildContext context) {

    return ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        tileColor: tealBlueLight,
        leading: SetTypeIcon(type: setDto.type, label: workingIndex),
        dense: true,
        title: Row(
          children: [
            SetText(label: "REPS", number: setDto.reps),
          ],
        ));
  }
}
