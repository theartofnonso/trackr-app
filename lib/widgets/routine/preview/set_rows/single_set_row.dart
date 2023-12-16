import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app_constants.dart';

class SingleSetRow extends StatelessWidget {
  final String label;

  const SingleSetRow({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tealBlueLight, // Container color
        borderRadius: BorderRadius.circular(5.0), // Radius for rounded corners
      ),
      child: Table(
          border: TableBorder.all(color: tealBlueDark, borderRadius: BorderRadius.circular(3)),
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
