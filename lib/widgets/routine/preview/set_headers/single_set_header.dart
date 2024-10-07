import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../enums/routine_preview_type_enum.dart';

class SingleSetHeader extends StatelessWidget {
  final String label;
  final TextAlign textAlign;
  final RoutinePreviewType routinePreviewType;

  const SingleSetHeader({super.key, required this.label, this.textAlign = TextAlign.center, required this.routinePreviewType});

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
            child: Text(label,
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                textAlign: textAlign),
          ),
        ]),
      ],
    );
  }
}
