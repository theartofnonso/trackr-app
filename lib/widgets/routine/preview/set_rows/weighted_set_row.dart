import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/weighted_set_dto.dart';
import 'package:tracker_app/widgets/routine/preview/set_rows/set_text.dart';
import 'package:tracker_app/widgets/routine/preview/set_type_icon.dart';

import '../../../../enums/exercise_type_enums.dart';
import '../../../../utils/general_utils.dart';

class WeightedSetRow extends StatelessWidget {
  const WeightedSetRow(
      {super.key, required this.index, required this.workingIndex, required this.setDto});

  final int index;
  final int workingIndex;
  final WeightedSetDto setDto;

  @override
  Widget build(BuildContext context) {
    final weight = isDefaultWeightUnit() ? setDto.first : toLbs(setDto.first.toDouble());

    return Table(columnWidths: const <int, TableColumnWidth>{
      0: FixedColumnWidth(30),
      1: FlexColumnWidth(2),
      2: FlexColumnWidth(2),
    }, children: <TableRow>[
      TableRow(children: [
        TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: SetTypeIcon(type: setDto.type, label: workingIndex)),
        TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: SetText(label: weightLabel().toUpperCase(), number: weight)),
        TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: SetText(label: "REPS", number: setDto.second))
      ]),
    ]);

  }
}
