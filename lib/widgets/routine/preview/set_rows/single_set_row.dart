import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app_constants.dart';

class SingleSetRow extends StatelessWidget {
  final String label;
  final EdgeInsets? margin;

  const SingleSetRow({super.key, required this.label, this.margin});

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
            0: FlexColumnWidth(),
          },
          children: <TableRow>[
            TableRow(children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Text(
                  label,
                  style: GoogleFonts.lato(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              // const TableCell(child: SizedBox.shrink())
            ]),
          ]),
    );
  }
}
