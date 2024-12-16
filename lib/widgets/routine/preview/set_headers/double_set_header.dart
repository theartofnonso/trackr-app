import 'package:flutter/material.dart';

class DoubleSetHeader extends StatelessWidget {
  final String firstLabel;
  final String secondLabel;

  const DoubleSetHeader({super.key, required this.firstLabel, required this.secondLabel});

  @override
  Widget build(BuildContext context) {

    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(),
      },
      children: <TableRow>[
        TableRow(children: [
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Text(firstLabel,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Text(secondLabel,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
          ),
        ]),
      ],
    );
  }
}
