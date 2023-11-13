import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/weighted_set_dto.dart';
import 'package:tracker_app/widgets/routine/preview/set_type_icon.dart';

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
          child: Text(
            "$weight",
            style: GoogleFonts.lato(color: Colors.white),
          ),
        ),
        TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Text(
              "${setDto.second}",
              style: GoogleFonts.lato(color: Colors.white),
            ))
      ]),
    ]);

  }
}
