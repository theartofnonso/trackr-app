import 'package:flutter/material.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/routine/preview/set_rows/set_text.dart';
import 'package:tracker_app/widgets/routine/preview/set_type_icon.dart';

import '../../../../app_constants.dart';
import '../../../../dtos/duration_dto.dart';

class DurationWidget extends StatelessWidget {
  const DurationWidget({super.key, required this.index, required this.workingIndex, required this.setDto});

  final int index;
  final int workingIndex;
  final DurationDto setDto;

  @override
  Widget build(BuildContext context) {

    return ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        tileColor: tealBlueLight,
        leading: SetTypeIcon(type: setDto.type, label: workingIndex),
        dense: true,
        title: SetText(label: "TIME", string: setDto.duration.secondsOrMinutesOrHours()),);
  }
}