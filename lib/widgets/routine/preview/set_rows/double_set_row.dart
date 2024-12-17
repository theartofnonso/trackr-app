import 'package:flutter/material.dart';

import '../../../../dtos/pb_dto.dart';
import '../../../pbs/pb_icon.dart';

class DoubleSetRow extends StatelessWidget {
  final String first;
  final String second;
  final List<PBDto> pbs;
  final Color? borderColor;

  const DoubleSetRow({super.key, required this.first, required this.second, this.pbs = const [], this.borderColor});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final color = borderColor ?? (isDarkMode ? Colors.white10 : Colors.white);

    final pbsForSet = pbs
        .map((pb) => PBIcon(label: pb.pb.name))
        .toList();

    return Badge(
      alignment: Alignment.topLeft,
      backgroundColor: Colors.transparent,
      label: Row(
          spacing: 6,
          children: pbsForSet),
      child: Table(
          border: TableBorder.all(color: color, borderRadius: BorderRadius.circular(5), width: 1),
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(second, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  ))
            ]),
          ]),
    );
  }
}
