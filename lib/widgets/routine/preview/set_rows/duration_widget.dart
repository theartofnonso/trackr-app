import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/routine/preview/set_type_icon.dart';

import '../../../../dtos/duration_dto.dart';

class DurationWidget extends StatelessWidget {
  const DurationWidget({super.key, required this.index, required this.workingIndex, required this.setDto});

  final int index;
  final int workingIndex;
  final DurationDto setDto;

  @override
  Widget build(BuildContext context) {

    return Table(columnWidths: const <int, TableColumnWidth>{
      0: FixedColumnWidth(30),
      1: FlexColumnWidth(1),
    }, children: <TableRow>[
      TableRow(children: [
        TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: SetTypeIcon(type: setDto.type, label: workingIndex)),
        TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Text(
              setDto.duration.secondsOrMinutesOrHours(),
              style: GoogleFonts.lato(color: Colors.white), textAlign: TextAlign.center,
            ))
      ]),
    ]);
  }
}