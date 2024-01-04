import 'package:flutter/material.dart';

import '../../app_constants.dart';

class DoubleSetRowEmptyState extends StatelessWidget {
  const DoubleSetRowEmptyState({super.key});

  @override
  Widget build(BuildContext context) {

    final bar = Align(
      alignment: Alignment.center,
      widthFactor: 0.5,
      child: Container(
          width: 30,
          height: 5,
          decoration: BoxDecoration(
            color: tealBlueLighter,
            borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
          )),
    );

    return Table(
        border: TableBorder.symmetric(inside: const BorderSide(color: tealBlueLighter, width: 2)),
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1),
        },
        children: <TableRow>[
          TableRow(children: [
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: bar,
            ),
            TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: bar),
          ]),
        ]);
  }
}
