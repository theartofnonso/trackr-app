import 'package:flutter/material.dart';
import 'package:tracker_app/widgets/routine/preview/set_rows/set_row.dart';

import '../../../../colors.dart';
import '../../../../dtos/pb_dto.dart';

class DoubleSetRow extends StatelessWidget {
  final String first;
  final String second;
  final EdgeInsets? margin;
  final List<PBDto> pbs;

  const DoubleSetRow({super.key, required this.first, required this.second, this.margin, this.pbs = const []});

  @override
  Widget build(BuildContext context) {

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return SetRow(
        pbs: pbs,
        child: Table(
            border: TableBorder.symmetric(inside: BorderSide(color: isDarkMode ? sapphireLighter.withOpacity(0.4) : Colors.white, width: 1.5)),
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
            },
            children: <TableRow>[
              TableRow(children: [
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Text(first, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                ),
                TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child:
                        Text(second, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center))
              ]),
            ]));
  }
}
