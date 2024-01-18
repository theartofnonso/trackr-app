import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app_constants.dart';
import '../../../../dtos/pb_dto.dart';
import '../../preview/set_rows/set_row.dart';

class SingleSetRow extends StatelessWidget {
  final String label;
  final EdgeInsets? margin;
  final List<PBDto> pbs;

  const SingleSetRow({super.key, required this.label, this.margin, this.pbs = const []});

  @override
  Widget build(BuildContext context) {
    return SetRow(
        margin: margin,
        pbs: pbs,
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
              ]),
            ]));
  }
}
