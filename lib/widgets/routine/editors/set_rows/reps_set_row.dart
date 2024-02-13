import 'package:flutter/material.dart';
import 'package:tracker_app/widgets/routine/editors/textfields/int_textfield.dart';

import '../../../../colors.dart';
import '../../../../dtos/set_dto.dart';
import '../../../../enums/routine_editor_type_enums.dart';
import '../set_check_button.dart';
import '../set_delete_button.dart';

class RepsSetRow extends StatelessWidget {
  final SetDto setDto;
  final RoutineEditorMode editorType;
  final VoidCallback onRemoved;
  final VoidCallback onCheck;
  final (TextEditingController, TextEditingController) controllers;
  final void Function(num value) onChangedReps;

  const RepsSetRow({
    super.key,
    required this.setDto,
    required this.editorType,
    required this.onRemoved,
    required this.onCheck,
    required this.controllers,
    required this.onChangedReps,
  });

  @override
  Widget build(BuildContext context) {
    int reps = setDto.repsValue().toInt();

    return Table(
      border: TableBorder.all(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
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
            child: IntTextField(
              value: reps,
              onChanged: onChangedReps,
              controller: controllers.$2,
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
