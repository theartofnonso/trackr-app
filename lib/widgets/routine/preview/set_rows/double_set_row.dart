import 'package:flutter/material.dart';
import '../../../../colors.dart';

import '../../../../dtos/pb_dto.dart';
import '../../../pbs/pb_icon.dart';

class DoubleSetRow extends StatelessWidget {
  final String first;
  final String second;
  final List<PBDto> pbs;

  const DoubleSetRow(
      {super.key,
      required this.first,
      required this.second,
      this.pbs = const []});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final color = isDarkMode ? darkBorder : Colors.black38;

    final pbsForSet = pbs
        .map((pb) => PBIcon(
              label: pb.pb.name,
              size: 8,
              textStyle:
                  Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
            ))
        .toList();

    return Badge(
      alignment: Alignment.topLeft,
      backgroundColor: Colors.transparent,
      label: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4),
        decoration: BoxDecoration(
          color: pbs.isNotEmpty
              ? (isDarkMode ? darkSurfaceContainer : Colors.grey.shade200)
              : null,
          borderRadius: BorderRadius.circular(radiusSM), // Rounded corners
        ),
        child: Row(spacing: 6, children: pbsForSet),
      ),
      child: Table(
          border: TableBorder.all(
              color: color,
              borderRadius: BorderRadius.circular(radiusSM),
              width: 1),
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
                  child: Text(first,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center),
                ),
              ),
              TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(second,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center),
                  ))
            ]),
          ]),
    );
  }
}
