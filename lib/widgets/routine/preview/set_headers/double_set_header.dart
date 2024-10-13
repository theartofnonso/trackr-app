import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../enums/routine_preview_type_enum.dart';

class DoubleSetHeader extends StatelessWidget {
  final String firstLabel;
  final String secondLabel;
  final RoutinePreviewType routinePreviewType;

  const DoubleSetHeader({super.key, required this.firstLabel, required this.secondLabel, required this.routinePreviewType});

  @override
  Widget build(BuildContext context) {

    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(),
      },
      children: <TableRow>[
        TableRow(children: [
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Text(firstLabel,
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Text(secondLabel,
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center),
          ),
        ]),
      ],
    );
  }
}
