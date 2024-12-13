import 'package:flutter/material.dart';

import '../../../../dtos/pb_dto.dart';
import '../../preview/set_rows/set_row.dart';

class SingleSetRow extends StatelessWidget {
  final String label;
  final List<PBDto> pbs;

  const SingleSetRow({super.key, required this.label, this.pbs = const []});

  @override
  Widget build(BuildContext context) {

    return SetRow(
        pbs: pbs,
        child: Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(),
            },
            children: <TableRow>[
              TableRow(children: [
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ]),
            ]));
  }
}
