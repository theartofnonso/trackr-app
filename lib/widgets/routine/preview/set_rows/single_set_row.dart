import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app_constants.dart';
import '../../preview/set_rows/set_row.dart';
import '../exercise_log_widget.dart';

class SingleSetRow extends StatelessWidget {
  final String label;
  final EdgeInsets? margin;
  final PBViewModel? pbViewModel;

  const SingleSetRow({super.key, required this.label, this.margin, this.pbViewModel});

  @override
  Widget build(BuildContext context) {
    return SetRow(
        margin: margin,
        pbViewModel: pbViewModel,
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
                style: GoogleFonts.montserrat(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            // const TableCell(child: SizedBox.shrink())
          ]),
        ]));
  }
}
