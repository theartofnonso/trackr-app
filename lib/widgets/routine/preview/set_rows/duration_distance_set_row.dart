import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/widgets/routine/preview/set_type_icon.dart';

import '../../../../utils/general_utils.dart';

class DurationDistanceSetRow extends StatelessWidget {
  const DurationDistanceSetRow({super.key, required this.setDto});

  final SetDto setDto;

  @override
  Widget build(BuildContext context) {
    final distance = isDefaultDistanceUnit() ? setDto.value2 : toKM(setDto.value2.toDouble(), type: ExerciseType.durationAndDistance);

    return Table(columnWidths: const <int, TableColumnWidth>{
      0: FixedColumnWidth(50),
      1: FlexColumnWidth(2),
      2: FlexColumnWidth(2),
    }, children: <TableRow>[
      TableRow(children: [
        TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: SetTypeIcon(type: setDto.type, label: setDto.id)),
        TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Text(
              "$distance",
              style: GoogleFonts.lato(color: Colors.white), textAlign: TextAlign.center,
            )),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Text(
            Duration(milliseconds: setDto.value1.toInt()).secondsOrMinutesOrHours(),
            style: GoogleFonts.lato(color: Colors.white), textAlign: TextAlign.center,
          ),
        )
      ]),
    ]);
  }
}