import 'package:flutter/material.dart';

import '../../../../app_constants.dart';
import '../../../../dtos/set_dto.dart';
import '../../../../enums/routine_editor_type_enums.dart';
import '../set_check_button.dart';
import '../set_delete_button.dart';
import '../timer_widget.dart';

class DurationSetRow extends StatelessWidget {
  final SetDto setDto;
  final RoutineEditorMode editorType;
  final VoidCallback onRemoved;
  final VoidCallback onCheck;
  final void Function(Duration duration) onChangedDuration;

  const DurationSetRow({
    super.key,
    required this.setDto,
    required this.editorType,
    required this.onRemoved,
    required this.onCheck,
    required this.onChangedDuration,
  });

  @override
  Widget build(BuildContext context) {
    Duration duration = Duration(milliseconds: setDto.value1.toInt());

    return Table(
      border: TableBorder.all(color: tealBlueLighter, borderRadius: BorderRadius.circular(5)),
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
      children: [
        TableRow(children: [
          TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Center(child: SetDeleteButton(onDelete: onRemoved))),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: InlineTimerWidget(
              stopped: setDto.checked,
              duration: duration,
              onChangedDuration: (Duration duration) => onChangedDuration(duration),
            ),
          ),
          if (editorType == RoutineEditorMode.log)
            TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: SetCheckButton(setDto: setDto, onCheck: onCheck))
        ])
      ],
    );
  }
}
