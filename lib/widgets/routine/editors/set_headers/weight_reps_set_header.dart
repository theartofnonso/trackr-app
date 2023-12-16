import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../enums/routine_editor_type_enums.dart';

class WeightRepsSetHeader extends StatelessWidget {
  final RoutineEditorMode editorType;
  final String firstLabel;
  final String secondLabel;

  const WeightRepsSetHeader({super.key, required this.editorType, required this.firstLabel, required this.secondLabel});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: editorType == RoutineEditorMode.edit
          ? <int, TableColumnWidth>{
              0: const FixedColumnWidth(50),
              1: const FlexColumnWidth(1),
              2: const FlexColumnWidth(1),
            }
          : <int, TableColumnWidth>{
              0: const FixedColumnWidth(50),
              1: const FlexColumnWidth(1),
              2: const FlexColumnWidth(1),
              3: const FixedColumnWidth(50),
            },
      children: <TableRow>[
        TableRow(children: [
          const TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: SizedBox.shrink(),
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
          if (editorType == RoutineEditorMode.log)
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
