import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/distance_duration_dto.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/routine/preview/set_rows/set_text.dart';
import 'package:tracker_app/widgets/routine/preview/set_type_icon.dart';

import '../../../../app_constants.dart';
import '../../../../utils/general_utils.dart';

class DistanceDurationWidget extends StatelessWidget {
  const DistanceDurationWidget({super.key, required this.index, required this.workingIndex, required this.setDto});

  final int index;
  final int workingIndex;
  final DistanceDurationDto setDto;

  @override
  Widget build(BuildContext context) {
    final distance = isDefaultDistanceUnit() ? setDto.distance : setDto.distance;

    return ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        tileColor: tealBlueLight,
        leading: SetTypeIcon(type: setDto.type, label: workingIndex),
        dense: true,
        title: Row(
          children: [
            SetText(label: distanceLabel(), number: distance),
            const SizedBox(width: 10),
            SetText(label: "TIME", string: setDto.duration.secondsOrMinutesOrHours()),
          ],
        ));
  }
}