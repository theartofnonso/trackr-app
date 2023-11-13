import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../screens/editor/routine_editor_screen.dart';
import '../../../../utils/general_utils.dart';

class DistanceDurationSetHeader extends StatelessWidget {
  const DistanceDurationSetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: FixedColumnWidth(30),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
      },
      children: <TableRow>[
        TableRow(children: [
          Text("SET",
              style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center),
          Text(distanceLabel(),
              style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center),
          Text("TIME",
              style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center),
        ]),
      ],
    );
  }
}
