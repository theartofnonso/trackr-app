import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/widgets/routine/preview/set_type_icon.dart';

import '../../../../enums/exercise_type_enums.dart';
import '../../../../utils/general_utils.dart';

class WeightDistanceSetRow extends StatelessWidget {
  const WeightDistanceSetRow({super.key, required this.index, required this.workingIndex, required this.setDto});

  final int index;
  final int workingIndex;
  final SetDto setDto;

  @override
  Widget build(BuildContext context) {
    final weight = isDefaultWeightUnit() ? setDto.value1 : toLbs(setDto.value1.toDouble());
    final distance = isDefaultDistanceUnit() ? setDto.value2 : toKM(setDto.value2.toDouble(), type: ExerciseType.weightAndDistance);

    return Table(columnWidths: const <int, TableColumnWidth>{
      0: FixedColumnWidth(50),
      1: FlexColumnWidth(),
      2: FlexColumnWidth(),
    }, children: <TableRow>[
      TableRow(children: [
        TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: SetTypeIcon(type: setDto.type, label: workingIndex)),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Text(
            "$weight",
            style: GoogleFonts.lato(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Text(
              "$distance",
              style: GoogleFonts.lato(color: Colors.white),
              textAlign: TextAlign.center,
            ))
      ]),
    ]);
  }
}
