import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/widgets/routine/preview/set_type_icon.dart';

import '../../../../app_constants.dart';

class DurationSetRow extends StatelessWidget {
  const DurationSetRow({super.key, required this.setDto});

  final SetDto setDto;

  @override
  Widget build(BuildContext context) {
    return Table(
        border: TableBorder.all(color: tealBlueLighter, borderRadius: BorderRadius.circular(5)),
        columnWidths: const <int, TableColumnWidth>{
          0: FixedColumnWidth(50),
          1: FlexColumnWidth()
        },
        children: <TableRow>[
          TableRow(children: [
            TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: SizedBox(
                    height: 50,
                    child:
                        Align(alignment: Alignment.center, child: SetTypeIcon(type: setDto.type, label: setDto.id)))),
            TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Text(
                  Duration(milliseconds: setDto.value1.toInt()).secondsOrMinutesOrHours(),
                  style: GoogleFonts.lato(color: Colors.white),
                  textAlign: TextAlign.center,
                ))
          ]),
        ]);
  }
}
