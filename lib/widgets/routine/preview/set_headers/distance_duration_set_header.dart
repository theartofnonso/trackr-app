import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../enums/exercise_type_enums.dart';
import '../../../../utils/general_utils.dart';

class DistanceDurationSetHeader extends StatelessWidget {
  const DistanceDurationSetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: FixedColumnWidth(50),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
      },
      children: <TableRow>[
        TableRow(children: [
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Text("SET",
                style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Text(distanceTitle(type: ExerciseType.distanceAndDuration),
                style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Text("TIME",
                style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center),
          ),
        ]),
      ],
    );
  }
}
