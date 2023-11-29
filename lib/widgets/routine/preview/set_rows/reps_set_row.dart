import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/widgets/routine/preview/set_type_icon.dart';

class RepsSetRow extends StatelessWidget {
  const RepsSetRow({super.key, required this.setDto});

  final SetDto setDto;

  @override
  Widget build(BuildContext context) {

    return Table(columnWidths: const <int, TableColumnWidth>{
      0: FixedColumnWidth(50),
      1: FlexColumnWidth(),
      2: FlexColumnWidth(),
    }, children: <TableRow>[
      TableRow(children: [
        TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: SetTypeIcon(type: setDto.type, label: setDto.id)),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Text(
            "${setDto.value2}",
            style: GoogleFonts.lato(color: Colors.white), textAlign: TextAlign.center,
          ),
        ),
        const TableCell(child: SizedBox.shrink())
      ]),
    ]);
  }
}
