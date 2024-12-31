import 'package:flutter/material.dart';

class WeightAndRepsSetHeader extends StatelessWidget {
  final String firstLabel;
  final String secondLabel;

  const WeightAndRepsSetHeader(
      {super.key, required this.firstLabel, required this.secondLabel});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: <int, TableColumnWidth>{
        0: const FixedColumnWidth(50),
        1: const FlexColumnWidth(1),
        2: const FlexColumnWidth(1),
        3: const FixedColumnWidth(60),
      },
      children: <TableRow>[
        TableRow(children: [
          const TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: SizedBox.shrink(),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Text(firstLabel, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Text(secondLabel, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ),
            const TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Icon(
                  Icons.check,
                  size: 12,
                ))
        ]),
      ],
    );
  }
}
