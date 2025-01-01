import 'package:flutter/material.dart';

class RepsSetHeader extends StatelessWidget {

  const RepsSetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths:  <int, TableColumnWidth>{
        0: const FixedColumnWidth(50),
        1: const FlexColumnWidth(1),
        2: const FixedColumnWidth(60),
      },
      children: <TableRow>[
        TableRow(children: [
          const TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: SizedBox.shrink(),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Text("REPS",
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
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
