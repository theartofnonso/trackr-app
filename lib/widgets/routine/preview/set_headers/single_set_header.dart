import 'package:flutter/material.dart';

class SingleSetHeader extends StatelessWidget {
  final String label;
  final TextAlign textAlign;

  const SingleSetHeader({super.key, required this.label, this.textAlign = TextAlign.center});

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
            child: Text(label,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: textAlign),
          ),
        ]),
      ],
    );
  }
}
