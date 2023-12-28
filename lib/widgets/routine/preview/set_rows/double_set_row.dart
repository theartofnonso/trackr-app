import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app_constants.dart';

class DoubleSetRow extends StatelessWidget {
  final String first;
  final String second;
  final EdgeInsets? margin;

  const DoubleSetRow({super.key, required this.first, required this.second, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: tealBlueLight, // Container color
        borderRadius: BorderRadius.circular(5.0), // Radius for rounded corners
      ),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Table(
          border: TableBorder.symmetric(inside: const BorderSide(color: tealBlueLighter, width: 2)),
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
          },
          children: <TableRow>[
            TableRow(children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Text(first, style: GoogleFonts.lato(color: Colors.white), textAlign: TextAlign.center),
              ),
              TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Text(second, style: GoogleFonts.lato(color: Colors.white), textAlign: TextAlign.center))
            ]),
          ]),
    );
  }
}
