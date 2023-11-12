import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/weighted_set_dto.dart';
import 'package:tracker_app/widgets/routine/preview/sets/set_text.dart';
import 'package:tracker_app/widgets/routine/preview/sets/set_type_icon.dart';

import '../../../../app_constants.dart';
import '../../../../enums/exercise_type_enums.dart';
import '../../../../utils/general_utils.dart';

class WeightRepsWidget extends StatelessWidget {
  const WeightRepsWidget({super.key, required this.index, required this.workingIndex, required this.setDto, required this.exerciseType});

  final int index;
  final int workingIndex;
  final WeightedSetDto setDto;
  final ExerciseType exerciseType;

  @override
  Widget build(BuildContext context) {
    final weight = isDefaultWeightUnit() ? setDto.first : toLbs(setDto.first.toDouble());
    String weightPrefix = "";
    if(exerciseType == ExerciseType.weightedBodyWeight) {
      weightPrefix = "+";
    } else {
      weightPrefix = "-";
    }

    return ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        tileColor: tealBlueLight,
        leading: SetTypeIcon(type: setDto.type, label: workingIndex),
        dense: true,
        title: Row(
          children: [
            SetText(label: weightPrefix + weightLabel().toUpperCase(), number: weight),
            const SizedBox(width: 10),
            SetText(label: "REPS", number: setDto.second),
          ],
        ));
  }
}