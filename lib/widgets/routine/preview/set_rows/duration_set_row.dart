import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/widgets/routine/preview/set_type_icon.dart';


class DurationSetRow extends StatelessWidget {
  const DurationSetRow({super.key, required this.index, required this.workingIndex, required this.setDto});

  final int index;
  final int workingIndex;
  final SetDto setDto;

  @override
  Widget build(BuildContext context) {

    return Table(columnWidths: const <int, TableColumnWidth>{
      0: FixedColumnWidth(50),
      1: FlexColumnWidth(),
      2: FlexColumnWidth()
    }, children: <TableRow>[
      TableRow(children: [
        TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: SetTypeIcon(type: setDto.type, label: workingIndex)),
        TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Text(
              Duration(milliseconds: setDto.value1.toInt()).secondsOrMinutesOrHours(),
              style: GoogleFonts.lato(color: Colors.white), textAlign: TextAlign.center,
            )),
        const TableCell(child: SizedBox.shrink())
      ]),
    ]);
  }
}