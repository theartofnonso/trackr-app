import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../screens/editor/routine_editor_screen.dart';

class WeightRepsSetHeader extends StatelessWidget {
  final RoutineEditorType editorType;
  final String firstLabel;
  final String secondLabel;

  const WeightRepsSetHeader({super.key, required this.editorType, required this.firstLabel, required this.secondLabel});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: editorType == RoutineEditorType.edit
          ? <int, TableColumnWidth>{
              0: const FixedColumnWidth(30),
              1: const FlexColumnWidth(3),
              2: const FlexColumnWidth(2),
              3: const FlexColumnWidth(2),
            }
          : <int, TableColumnWidth>{
              0: const FixedColumnWidth(30),
              1: const FlexColumnWidth(3),
              2: const FlexColumnWidth(2),
              3: const FlexColumnWidth(2),
              4: const FlexColumnWidth(1),
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
            child: Text("PREVIOUS",
                style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Text(firstLabel,
                style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Text(secondLabel,
                style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center),
          ),
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
