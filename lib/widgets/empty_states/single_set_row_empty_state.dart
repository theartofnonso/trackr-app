import 'package:flutter/material.dart';

import '../../colors.dart';

class SingleSetRowEmptyState extends StatelessWidget {
  const SingleSetRowEmptyState({super.key});

  @override
  Widget build(BuildContext context) {

    final bar = Align(
      alignment: Alignment.center,
      widthFactor: 0.5,
      child: Container(
          width: 30,
          height: 5,
          decoration: BoxDecoration(
            color: sapphireLighter,
            borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
          )),
    );

    return Table(
        border: const TableBorder.symmetric(inside: BorderSide(color: sapphireLighter, width: 2)),
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(1),
        },
        children: <TableRow>[
          TableRow(children: [
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: bar,
            ),
          ]),
        ]);
  }
}
