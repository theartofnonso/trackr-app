import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../enums/routine_editor_type_enums.dart';

class DurationSetHeader extends StatelessWidget {
  final RoutineEditorMode editorType;

  const DurationSetHeader({super.key, required this.editorType});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: editorType == RoutineEditorMode.edit
          ? <int, TableColumnWidth>{
              0: const FixedColumnWidth(50),
              1: const FlexColumnWidth(1),
            }
          : <int, TableColumnWidth>{
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
            child: Text("TIME",
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
          ),
          if (editorType == RoutineEditorMode.log)
            const TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: FaIcon(
                  FontAwesomeIcons.check,
                  size: 12,
                ))
        ]),
      ],
    );
  }
}
