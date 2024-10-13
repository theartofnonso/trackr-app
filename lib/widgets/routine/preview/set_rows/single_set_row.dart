import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../dtos/pb_dto.dart';
import '../../../../enums/routine_preview_type_enum.dart';
import '../../preview/set_rows/set_row.dart';

class SingleSetRow extends StatelessWidget {
  final String label;
  final EdgeInsets? margin;
  final List<PBDto> pbs;
  final RoutinePreviewType routinePreviewType;

  const SingleSetRow({super.key, required this.label, this.margin, this.pbs = const [], required this.routinePreviewType});

  @override
  Widget build(BuildContext context) {

    return SetRow(
      routinePreviewType: routinePreviewType,
        margin: margin,
        pbs: pbs,
        child: Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(),
            },
            children: <TableRow>[
              TableRow(children: [
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Text(
                    label,
                    style: GoogleFonts.ubuntu(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ]),
            ]));
  }
}
