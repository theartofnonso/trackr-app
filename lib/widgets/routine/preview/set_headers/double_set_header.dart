import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoubleSetHeader extends StatelessWidget {
  final String firstLabel;
  final String secondLabel;

  const DoubleSetHeader({super.key, required this.firstLabel, required this.secondLabel});

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
                style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Text(secondLabel,
                style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center),
          ),
        ]),
      ],
    );
  }
}
