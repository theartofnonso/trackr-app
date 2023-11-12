import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DurationTableHeader extends StatelessWidget {
  const DurationTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(1),
      },
      children: <TableRow>[
        TableRow(children: [
          Text("SET",
              style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center),
          Text("PREVIOUS",
              style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center),
          Text("TIME",
              style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center),
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
