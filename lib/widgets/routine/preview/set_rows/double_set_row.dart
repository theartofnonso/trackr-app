import 'package:flutter/material.dart';
import 'package:tracker_app/widgets/routine/preview/set_rows/set_row.dart';

import '../../../../dtos/pb_dto.dart';

class DoubleSetRow extends StatelessWidget {
  final String first;
  final String second;
  final List<PBDto> pbs;

  const DoubleSetRow({super.key, required this.first, required this.second, this.pbs = const []});

  @override
  Widget build(BuildContext context) {

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return SetRow(
        pbs: pbs,
        child: Table(
            border: TableBorder.all(color: isDarkMode ? Colors.white10 : Colors.white, borderRadius: BorderRadius.circular(5)),
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
            },
            children: <TableRow>[
              TableRow(children: [
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(first, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  ),
                ),
                TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child:
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(second, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                        ))
              ]),
            ]));
  }
}
