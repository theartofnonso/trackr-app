import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SingleSetHeader extends StatelessWidget {
  final String label;
  const SingleSetHeader({super.key, required this.label});

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
                style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center),
          ),
        ]),
      ],
    );
  }
}