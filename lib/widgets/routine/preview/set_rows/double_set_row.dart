import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/routine/preview/set_rows/set_row.dart';

import '../../../../colors.dart';
import '../../../../dtos/pb_dto.dart';
import '../../../../enums/routine_preview_type_enum.dart';

class DoubleSetRow extends StatelessWidget {
  final String first;
  final String second;
  final EdgeInsets? margin;
  final List<PBDto> pbs;
  final RoutinePreviewType routinePreviewType;

  const DoubleSetRow({super.key, required this.first, required this.second, this.margin, this.pbs = const [], required this.routinePreviewType});

  @override
  Widget build(BuildContext context) {
    final color = routinePreviewType == RoutinePreviewType.ai ? Colors.black : Colors.white;
    return SetRow(
      routinePreviewType: routinePreviewType,
        margin: margin,
        pbs: pbs,
        child: Table(
            border: TableBorder.symmetric(inside: BorderSide(color: routinePreviewType == RoutinePreviewType.ai ? Colors.white70.withOpacity(0.2) : sapphireLighter.withOpacity(0.4), width: 1.5)),
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
            },
            children: <TableRow>[
              TableRow(children: [
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Text(first, style: GoogleFonts.ubuntu(color: color), textAlign: TextAlign.center),
                ),
                TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child:
                        Text(second, style: GoogleFonts.ubuntu(color: color), textAlign: TextAlign.center))
              ]),
            ]));
  }
}
