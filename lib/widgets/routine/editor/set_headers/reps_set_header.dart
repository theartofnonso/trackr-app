import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../screens/editor/routine_editor_screen.dart';

class RepsSetHeader extends StatelessWidget {
  final RoutineEditorType editorType;

  const RepsSetHeader({super.key, required this.editorType});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: editorType == RoutineEditorType.edit
          ? <int, TableColumnWidth>{
              0: const FixedColumnWidth(30),
              1: const FlexColumnWidth(3),
              2: const FlexColumnWidth(1),
            }
          : <int, TableColumnWidth>{
              0: const FixedColumnWidth(30),
              1: const FlexColumnWidth(3),
              2: const FlexColumnWidth(2),
              3: const FlexColumnWidth(1),
            },
      children: <TableRow>[
        TableRow(children: [
          Text("SET",
              style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center),
          Text("PREVIOUS",
              style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center),
          Text("REPS",
              style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center),
          if (editorType == RoutineEditorType.log)
            const TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Icon(
                  Icons.check,
                  size: 12,
                ))
        ]),
      ],
    );
  }
}
